clearvars; close all; clc;

load('/mnt/disks/data-disk/NERTO_2024/validation/tempo_time_series_data.mat');
load('/mnt/disks/data-disk/data/pandora_data/pandora_data.mat');

cld_threshold = 1;
sza_threshold = 90;

tempo_timetable = table2timetable(data_table);
tempo_timetable = tempo_timetable(tempo_timetable.QA==0&tempo_timetable.SZA<=sza_threshold&tempo_timetable.Cld_frac<=cld_threshold,:);

pandora_timetable = table2timetable(pandora_data);
% pandora_timetable = pandora_timetable(pandora_timetable.qa==0|pandora_timetable.qa==1|pandora_timetable.qa==10|pandora_timetable.qa==11,:);
pandora_timetable = pandora_timetable(pandora_timetable.qa==0|pandora_timetable.qa==1|pandora_timetable.qa==2|pandora_timetable.qa==10|pandora_timetable.qa==11|pandora_timetable.qa==12,:);

clim = [0 10^3];

all_sites = {'ccny', 'nybg', 'queens', 'essex', 'beltsville', 'greenbelt2', 'greenbelt32', 'DC'};
title_strings = {'New York-CCNY (135)', 'New York-NYBG (180)', 'New York-Queens College (55)', 'Maryland-Essex (75)', 'Maryland-Beltsville (80)', 'Maryland-Greenbelt (2)', 'Maryland-Greenbelt(32)', 'Washington DC (140)'};
clims = [[0 700]; clim; clim; [0 300]; [0 200]; [0 200]; [0 200]; [0 300]];

start_day = datetime(2024, 6, 1, 0,0,0, 'TimeZone', 'America/New_York');
end_day = datetime(2024, 7, 1, 0,0,0, 'TimeZone', 'America/New_York');

period = timerange(start_day, end_day, "openright");
bin_mins = 20;
n_days = 30;

to_plot = [1 2 3 4 5 6 7 8];
for k = 1:length(to_plot)
    ind = to_plot(k);

    site = all_sites(ind);

    tempo_site = tempo_timetable(strcmp(tempo_timetable.Site, site),:);
    tempo_site.Site = [];
    tempo_site.QA = [];
    tempo_site.Uncertainty = [];
    tempo_site.VZA = [];
    tempo_site.SZA = [];

    pandora_site = pandora_timetable(strcmp(pandora_timetable.Site, site),:);
    pandora_site.Site = [];
    pandora_site.qa = [];

    tempo_site_mean = retime(tempo_site, 'hourly', 'mean');
    tempo_site_mean = tempo_site_mean(period,:);
    tempo_site_mean.time = datetime(tempo_site_mean.time, 'TimeZone', "America/New_York");

    pandora_site_mean = retime(pandora_site,'regular','mean', 'TimeStep', minutes(bin_mins));
    pandora_site_mean = pandora_site_mean(period, :);
    pandora_site_mean.Date = datetime(pandora_site_mean.Date, "TimeZone", "America/New_York");

    if isempty(pandora_site_mean)
        disp(strjoin([site, 'no pandora data']))
        continue
    end

    if isempty(tempo_site_mean)
        disp(strjoin([site, 'no tempo data']))
        continue
    end

    dim = [24*(60/bin_mins), n_days];

    tempo_mean = NaN([24 n_days]);
    pandora_mean = NaN(dim);
    date_array = NaT("TimeZone", "America/New_York");
    hour_array = 0:23;

    count = 1;
    for j = 1:size(tempo_mean, 2)
        date_array(j) = start_day + j -1;

        for i = 1:size(tempo_mean ,1)
            temp_tempo = tempo_site_mean.NO2(count);
            
            if ~isempty(temp_tempo)
                tempo_mean(i,j) = temp_tempo ./ conversion_factor('trop-tempo') * 10^6;
            end

            count = count + 1;
        end
    end

    count = 1;
    for j = 1:size(pandora_mean, 2)
        date_array(j) = start_day + j -1;

        for i = 1:size(pandora_mean ,1)
            temp_pandora = pandora_site_mean.NO2(count);

            if ~isempty(temp_pandora)
                pandora_mean(i,j) = temp_pandora * 10^6;
            end
        
            count = count + 1;
            if count==numel(pandora_site_mean.NO2)
                break
            end
        end
        if count==numel(pandora_site_mean.NO2)
            break
        end
    end

    %%
    lw = 2;
    font_size = 20;
    resolution = 300;
    y_tick = [0 3 6 9 12 15 18 21 24];

    y_lim = [3 21];

    cb_str = 'tropNO2 (umol/m^2)';

    % dim = [0, 0, 1800, 600];
    dim = [0, 0, 1200, 1200];

    fig = figure('Visible', 'off', 'Position', dim);

    % tiledlayout(1,2)
    tiledlayout(2,1, "TileSpacing", 'compact', 'Padding', 'compact')

    nexttile

    I = imagesc(date_array, hour_array, tempo_mean); 
    title("TEMPO")
    xticks(date_array)
    xtickformat('eeeee')
    xtickangle(0)
    yticks(y_tick)
    ylim(y_lim)
    ylabel('Local Time')
    ax = gca;
    ax.YDir = 'normal';
    ax.CLim = clims(ind,:);
    set(I, 'AlphaData', ~isnan(tempo_mean))

    nexttile
    I = imagesc(date_array, hour_array, pandora_mean);
    title('PANDORA')
    xticks(date_array)
    xtickformat('eeeee')
    xtickangle(0)
    yticks(y_tick)
    ylim(y_lim)
    ylabel('Local Time')
    ax = gca;
    ax.YDir = 'normal';
    ax.CLim = clims(ind,:);
    set(I, 'AlphaData', ~isnan(pandora_mean))

    cb = colorbar;
    cb.Layout.Tile = 'south';
    cb.Label.String = cb_str;
    colormap('jet')
    fontsize(font_size, 'points')
    sgtitle(strjoin([title_strings(ind), string(start_day), '-', string(end_day-days(1))]))

    save_path = fullfile('/mnt/disks/data-disk/figures/validation', string(site));
    print(fig, save_path, '-dpng', ['-r' num2str(resolution)])

    close(fig);
end