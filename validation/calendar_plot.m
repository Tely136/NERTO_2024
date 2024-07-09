clearvars; close all; clc;


load('/mnt/disks/data-disk/NERTO_2024/validation/tempo_time_series_data.mat');
load('/mnt/disks/data-disk/data/pandora_data/pandora_data.mat');

tempo_timetable = table2timetable(data_table);
pandora_timetable = table2timetable(pandora_data);

conversion_factor = 6.022 .* 10.^19;

all_sites = {'ccny', 'nybg', 'queens', 'greenbelt2', 'greenbelt32'};

start_day = datetime(2024, 6, 1, 0,0,0, 'TimeZone', 'America/New_York');
end_day = datetime(2024, 7, 1, 0,0,0, 'TimeZone', 'America/New_York');

period = timerange(start_day, end_day, "openright");

for k = 1:length(all_sites)
    site = all_sites(k);

    tempo_site = tempo_timetable(strcmp(tempo_timetable.Site, site),:);
    tempo_site.Site = [];
    tempo_site.QA = [];
    tempo_site.Uncertainty = [];
    tempo_site.VZA = [];
    tempo_site.SZA = [];

    pandora_site = pandora_timetable(strcmp(pandora_timetable.Site, site),:);
    pandora_site.Site = [];
    pandora_site.qa = [];


    tempo_site_mean = retime(tempo_site, "hourly", "mean");
    tempo_site_mean = tempo_site_mean(period,:);
    tempo_site_mean.time = datetime(tempo_site_mean.time, 'TimeZone', "America/New_York");

    pandora_site_mean = retime(pandora_site, "hourly", "mean");
    pandora_site_mean = pandora_site_mean(period, :);
    pandora_site_mean.Date = datetime(pandora_site_mean.Date, "TimeZone", "America/New_York");

    if isempty(tempo_site_mean) | isempty(pandora_site_mean)
        continue
    end

    tempo_mean = NaN([24, 30]);
    pandora_mean = NaN([24, 30]);
    date_array = NaT("TimeZone", "America/New_York");
    hour_array = 0:23;

    count = 1;
    for j = 1:size(tempo_mean, 2)
        date_array(j) = start_day + j -1;

        for i = 1:size(tempo_mean ,1)

            temp_tempo = tempo_site_mean.NO2(count);
            temp_pandora = pandora_site_mean.NO2(count);
            
            if ~isempty(temp_tempo)
                tempo_mean(i,j) = temp_tempo;
            end

            if ~isempty(temp_pandora)
                pandora_mean(i,j) = temp_pandora .* conversion_factor;
            end
        
            count = count + 1;
        end
    end

    %%
    lw = 2;
    font_size = 20;
    resolution = 300;
    dim = [0, 0, 1800, 600];

    y_lim = [0 24];
    % clim = [0 max([tempo_mean(:); pandora_mean(:)])];
    clim = [0 5*10^16];

    fig = figure('Visible', 'off', 'Position', dim);

    tiledlayout(1,2)
    nexttile

    I = imagesc(date_array, hour_array, tempo_mean); 
    title("TEMPO")
    xticks(date_array)
    xtickformat('eeeee')
    xtickangle(0)
    yticks([6 9 12 15 18])
    ylim(y_lim)
    ax = gca;
    ax.YDir = 'normal';
    ax.CLim = clim;
    set(I, 'AlphaData', ~isnan(tempo_mean))

    nexttile
    I = imagesc(date_array, hour_array, pandora_mean);
    title('Pandora')
    xticks(date_array)
    xtickformat('eeeee')
    xtickangle(0)
    yticks([6 9 12 15 18])
    ylim(y_lim)
    ax = gca;
    ax.YDir = 'normal';
    ax.CLim = clim;
    set(I, 'AlphaData', ~isnan(pandora_mean))

    cb = colorbar;
    cb.Layout.Tile = 'south';
    colormap('jet')
    fontsize(font_size, 'points')
    sgtitle(site)

    save_path = fullfile('/mnt/disks/data-disk/figures/validation', string(site));
    print(fig, save_path, '-dpng', ['-r' num2str(resolution)])

    close(fig);
end