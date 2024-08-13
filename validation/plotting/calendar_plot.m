clearvars; close all; clc;

% TODO: add dummy data one month before and after final data in arrays before executing retime function

% save_folder = '/mnt/disks/data-disk/figures/validation/calendar/temporal_on';
% load('/mnt/disks/data-disk/data/time_series/merged_time_series_data_temporal_on.mat');

save_folder = '/mnt/disks/data-disk/figures/validation/calendar/temporal_off';
load('/mnt/disks/data-disk/data/time_series/merged_time_series_data_temporal_off.mat');

% save_folder = '/mnt/disks/data-disk/figures/validation/calendar/temporal_strict';
% load('/mnt/disks/data-disk/data/time_series/merged_time_series_data_temporal_strict.mat');


% Thresholds to filter out Tempo data with high SZA and cloud fraction
cld_threshold = 0.2;
sza_threshold = 70;

% lowqa_alpha = 0.65;
lowqa_alpha = 0;

% Load Tempo and Merged data co-located to pandora sites and Pandora data
load('/mnt/disks/data-disk/data/time_series/tempo_time_series_data.mat');
load('/mnt/disks/data-disk/data/pandora_data/pandora_data.mat');

% Convert data tables to timetable and filter data
tempo_timetable = table2timetable(data_table);
merged_timetable = table2timetable(merged_data_table);
% merged_timetable.time = merged_timetable.time + hours(4);
pandora_timetable = table2timetable(pandora_data);

% Params for each Pandora site
all_sites = {'ccny', 'nybg', 'queens', 'essex', 'beltsville', 'greenbelt2', 'greenbelt32', 'DC'};
title_strings = {'New York-CCNY (135)', 'New York-NYBG (180)', 'New York-Queens College (55)', 'Maryland-Essex (75)', 'Maryland-Beltsville (80)', 'Maryland-Greenbelt (2)', 'Maryland-Greenbelt(32)', 'Washington DC (140)'};
clim = [0 10^3];
clims = [[0 700]; clim; clim; [0 300]; [0 200]; [0 200]; [0 200]; [0 300]];

tz = 'America/New_York';
tempo_time = sort(tempo_timetable.time);

% How many minutes to bin Pandora data
bin_mins = 20;
% Number of days per month
% TODO: Make it so this isn't a set value and corresponds to the number of days in each month
n_days = 30;

years = [2024];
months = [6];


% Loop over years present in Tempo data
for year_i = 1:length(years)
    current_year = years(year_i);

    % Loop over all months
    for month_i = 1:length(months)
        current_month = months(month_i);

        disp(['****', num2str(current_month), ' ', num2str(current_year), '****'])

        % Get the start and end day of the month
        start_day = datetime(current_year, current_month, 1, 0,0,0, 'TimeZone', tz);
        if current_month==12
            end_day = datetime(current_year+1,1,1, 0,0,0, 'TimeZone', tz);
        else
            end_day = datetime(current_year, current_month+1, 1, 0,0,0, 'TimeZone', tz);
        end

        % time period filter to retrieve data from current month only
        period = timerange(start_day, end_day, "openright");

        for ind = 1:length(all_sites)
            site = all_sites(ind);

            % Filter Tempo, Merged and Pandora data by site
            % Create tables with only high QA data and one with all data
            tempo_table_site = tempo_timetable(strcmp(tempo_timetable.Site, site),:);
            tempo_table_site_highqa = tempo_table_site;
            tempo_table_site_highqa.TEMPO_NO2(~(tempo_table_site.QA==0&tempo_table_site.SZA<=sza_threshold&tempo_table_site.Cld_frac<=cld_threshold)) = NaN;
            tempo_table_site = timetable(tempo_table_site.time, tempo_table_site.TEMPO_NO2);
            tempo_table_site_highqa = timetable(tempo_table_site_highqa.time, tempo_table_site_highqa.TEMPO_NO2);

            merged_table_site = merged_timetable(strcmp(merged_timetable.Site, site),:);
            merged_table_site = timetable(merged_table_site.time, merged_table_site.Merged_NO2);

            pandora_table_site = pandora_timetable(strcmp(pandora_timetable.Site, site),:);
            pandora_table_site_highqa = pandora_table_site;
            pandora_table_site_highqa.NO2(~(pandora_table_site.qa==0|pandora_table_site.qa==1|pandora_table_site.qa==10|pandora_table_site.qa==11)) = NaN;
            pandora_table_site = timetable(pandora_table_site.Date, pandora_table_site.NO2);
            pandora_table_site_highqa = timetable(pandora_table_site_highqa.Date, pandora_table_site_highqa.NO2);


            % Bin Tempo data hourly and Pandora data according to bin_mins
            % Binning takes the average of all data in the bin
            tempo_site_mean = retime(tempo_table_site, 'hourly', 'mean');
            tempo_site_mean = tempo_site_mean(period,:);
            tempo_site_mean.Time = datetime(tempo_site_mean.Time, 'TimeZone', "America/New_York");

            tempo_site_mean_highqa = retime(tempo_table_site_highqa, 'hourly', 'mean');
            tempo_site_mean_highqa = tempo_site_mean_highqa(period,:);
            tempo_site_mean_highqa.Time = datetime(tempo_site_mean_highqa.Time, 'TimeZone', "America/New_York");

            merged_site_mean = retime(merged_table_site, 'hourly', 'mean');
            merged_site_mean = merged_site_mean(period,:);
            merged_site_mean.Time = datetime(merged_site_mean.Time, 'TimeZone', "America/New_York");

            pandora_site_mean = retime(pandora_table_site,'regular','mean', 'TimeStep', minutes(bin_mins));
            pandora_site_mean = pandora_site_mean(period, :);
            pandora_site_mean.Time = datetime(pandora_site_mean.Time, "TimeZone", "America/New_York");

            pandora_site_mean_highqa = retime(pandora_table_site_highqa,'regular','mean', 'TimeStep', minutes(bin_mins));
            pandora_site_mean_highqa = pandora_site_mean_highqa(period, :);
            pandora_site_mean_highqa.Time = datetime(pandora_site_mean_highqa.Time, "TimeZone", "America/New_York");

            % If there is no Tempo or Pandora data at the site, skip making this figure
            if isempty(pandora_site_mean)
                disp(strjoin([site, 'no pandora data']))
                continue
            end
            if isempty(tempo_site_mean)
                disp(strjoin([site, 'no tempo data']))
                continue
            end
            if isempty(merged_site_mean)
                disp(strjoin([site, 'no merged data']))
                continue
            end

            % Dimension of Pandora plot
            dim = [24*(60/bin_mins), n_days];

            tempo_mean = NaN([24 n_days]);
            tempo_alpha = zeros([24 n_days]);

            merged_mean = NaN([24 n_days]);

            pandora_mean = NaN(dim);
            pandora_alpha = zeros(dim);
            date_array = NaT("TimeZone", "America/New_York");
            hour_array = 0:23;

            % Loop over each day
            count = 1;
            for j = 1:size(tempo_mean, 2)
                date_array(j) = start_day + j - 1;

                % Tempo Loop over each time bin
                for i = 1:size(tempo_mean, 1)
                    temp_tempo = tempo_site_mean.Var1(count);
                    temp_tempo_high_qa = tempo_site_mean_highqa.Var1(count);

                    % If data is present add it to the array that will be plotted
                    if ~isnan(temp_tempo_high_qa)
                        tempo_mean(i,j) = temp_tempo_high_qa ./ conversion_factor('trop-tempo') * 10^6;
                        tempo_alpha(i,j) = 1;

                    elseif ~isnan(temp_tempo)
                        tempo_mean(i,j) = temp_tempo ./ conversion_factor('trop-tempo') * 10^6;
                        tempo_alpha(i,j) = lowqa_alpha;

                    end

                    % Break out of loop if at the end
                    if count == size(tempo_site_mean,1)
                        break
                    else
                        count = count + 1;
                    end
                end
                if count == size(tempo_site_mean)
                    break
                end
            end

            count = 1;
            for j = 1:size(merged_mean, 2)
                date_array(j) = start_day + j - 1;

                for i = 1:size(merged_mean, 1)
                    temp_merged = merged_site_mean.Var1(count);

                    % If data is present add it to the array that will be plotted
                    if ~isnan(temp_merged)
                        merged_mean(i,j) = temp_merged * 10^6;
                    end

                    % Break out of loop if at the end
                    if count == size(merged_site_mean,1)
                        break
                    else
                        count = count + 1;
                    end
                end
                if count == size(merged_site_mean)
                    break
                end
            end

            count = 1;
            for j = 1:size(pandora_mean, 2)
                date_array(j) = start_day + j -1;

                for i = 1:size(pandora_mean ,1)
                    temp_pandora = pandora_site_mean.Var1(count);
                    temp_pandora_highqa = pandora_site_mean_highqa.Var1(count);

                    if ~isnan(temp_pandora_highqa)
                        pandora_mean(i,j) = temp_pandora_highqa * 10^6;
                        pandora_alpha(i,j) = 1;

                    elseif ~isnan(temp_pandora)
                        pandora_mean(i,j) = temp_pandora * 10^6;
                        pandora_alpha(i,j) = lowqa_alpha;
                    end
                
                    count = count + 1;
                    if count==numel(pandora_site_mean.Var1)
                        break
                    end
                end
                if count==numel(pandora_site_mean.Var1)
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

            dim = [0, 0, 1000, 1000];

            fig = figure('Visible', 'off', 'Position', dim);

            tiledlayout(2,2, "TileSpacing", 'compact', 'Padding', 'compact')

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
            % set(I, 'AlphaData', ~isnan(tempo_mean))
            set(I, 'AlphaData', tempo_alpha)

            nexttile
            I = imagesc(date_array, hour_array, merged_mean); 
            title("Merged")
            xticks(date_array)
            xtickformat('eeeee')
            xtickangle(0)
            yticks(y_tick)
            ylim(y_lim)
            ylabel('Local Time')
            ax = gca;
            ax.YDir = 'normal';
            ax.CLim = clims(ind,:);
            set(I, 'AlphaData', ~isnan(merged_mean))

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
            set(I, 'AlphaData', pandora_alpha)

            cb = colorbar;
            cb.Layout.Tile = 'south';
            cb.Label.String = cb_str;
            colormap('jet')
            fontsize(font_size, 'points')
            sgtitle(strjoin([title_strings(ind), string(start_day), '-', string(end_day-days(1))]))

            save_path = fullfile(save_folder, strjoin([num2str(current_month),'_', num2str(current_year),'_', string(site),'.png'],''));
            exportgraphics(fig, save_path, 'Resolution', 300)

            close(fig);
        end
    end
end