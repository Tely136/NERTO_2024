function calendar_plot(months_years, satellite_input_data_path, pandora_input_data_path, save_folder)
    arguments
        months_years double
        satellite_input_data_path char
        pandora_input_data_path char
        save_folder char
    end

% Load Tempo and Merged data co-located to pandora sites and Pandora data
satellite_data = load(satellite_input_data_path);
pandora_data = load(pandora_input_data_path);

% Convert data tables to timetable and filter data
merged_timetable = table2timetable(satellite_data.merged_data_table);
pandora_timetable = table2timetable(pandora_data.pandora_data);
pandora_timetable = pandora_timetable(pandora_timetable.qa==0|pandora_timetable.qa==1|pandora_timetable.qa==10|pandora_timetable.qa==11,:);

% Params for each Pandora site
all_sites = {'ccny', 'nybg', 'queens', 'essex', 'beltsville', 'greenbelt2', 'greenbelt32', 'DC'};
title_strings = {'New York-CCNY (135)', 'New York-NYBG (180)', 'New York-Queens College (55)', 'Maryland-Essex (75)', 'Maryland-Beltsville (80)', 'Maryland-Greenbelt (2)', 'Maryland-Greenbelt(32)', 'Washington DC (140)'};
clims = [[0 700]; [0 1000]; [0 1000]; [0 300]; [0 200]; [0 200]; [0 200]; [0 300]];

tz = 'America/New_York';

% How many minutes to bin Pandora data
bin_mins = 20;


USA = load("USA.mat"); 
USA = USA.USA;

% Loop over all months
for i = 1:size(months_years,1)
    current_month = months_years(i,1);
    current_year = months_years(i,2);

    n_days = eomday(current_year, current_month);

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

        merged_table_site = merged_timetable(strcmp(merged_timetable.Site, site),:);
        merged_table_site = timetable(merged_table_site.time, merged_table_site.TEMPO_NO2, merged_table_site.Merged_NO2);

        pandora_table_site = pandora_timetable(strcmp(pandora_timetable.Site, site),:);
        pandora_table_site = timetable(pandora_table_site.Date, pandora_table_site.NO2);


        % Bin Tempo data hourly and Pandora data according to bin_mins
        merged_site_mean = retime(merged_table_site, 'hourly', 'mean');
        merged_site_mean = merged_site_mean(period,:);
        merged_site_mean.Time = datetime(merged_site_mean.Time, 'TimeZone', "America/New_York");

        pandora_site_mean = retime(pandora_table_site,'regular','mean', 'TimeStep', minutes(bin_mins));
        pandora_site_mean = pandora_site_mean(period, :);
        pandora_site_mean.Time = datetime(pandora_site_mean.Time, "TimeZone", "America/New_York");

        % If there is no Tempo or Pandora data at the site, skip making this figure
        if isempty(pandora_site_mean)
            disp(strjoin([site, 'no pandora data']))
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
        merged_alpha = zeros([24 n_days]);

        pandora_mean = NaN(dim);
        pandora_alpha = zeros(dim);

        hour_array = 0:23;
        date_array = start_day:days(1):start_day+days(n_days-1);
        date_array.TimeZone = "America/New_York";

        mins_array = 0:minutes(bin_mins):hours(24)-minutes(bin_mins);

        % Loop over each day
        for j = 1:n_days
            for k = hour_array
                current_datetime = date_array(j) + hours(k);
                tempo_no2 = merged_site_mean(merged_site_mean.Time==current_datetime,:).Var1;
                merged_no2 = merged_site_mean(merged_site_mean.Time==current_datetime,:).Var2;

                if ~isempty(tempo_no2) & ~isnan(tempo_no2)
                    tempo_mean(k+1,j) = 10^6 * tempo_no2;
                    tempo_alpha(k+1,j) = 1;
                end

                if ~isempty(merged_no2) & ~isnan(merged_no2)
                    merged_mean(k+1,j) = 10^6 * merged_no2;
                    merged_alpha(k+1,j) = 1;
                end
            end

            for k = 1:size(pandora_mean,1)
                current_datetime = date_array(j) + mins_array(k);
                pandora_no2 = pandora_site_mean(pandora_site_mean.Time==current_datetime,:).Var1;

                if ~isempty(pandora_no2) & ~isnan(pandora_no2)
                    pandora_mean(k+1,j) = 10^6 * pandora_no2;
                    pandora_alpha(k+1,j) = 1;
                end
            end
        end

        update = merged_mean - tempo_mean;

        %%
        font_size = 30;
        y_tick = [0 3 6 9 12 15 18 21 24];
        y_lim = [3 21];

        cb_str = 'tropNO2 (umol/m^2)';

        pltdim = [0, 0, 2000, 1500];

        fig = figure('Visible', 'off', 'Position', pltdim);

        tiledlayout(2,2, "TileSpacing", 'loose', 'Padding', 'compact')

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
        cb = colorbar;
        cb.Label.String = cb_str;
        colormap(ax, 'jet')
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
        cb = colorbar;
        cb.Label.String = cb_str;
        colormap(ax,'jet')
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
        cb = colorbar;
        cb.Label.String = cb_str;
        colormap(ax,'jet')
        set(I, 'AlphaData', pandora_alpha)

        nexttile
        I = imagesc(date_array, hour_array, update); 
        title("Update")
        xticks(date_array)
        xtickformat('eeeee')
        xtickangle(0)
        yticks(y_tick)
        ylim(y_lim)
        ylabel('Local Time')
        ax = gca;
        ax.YDir = 'normal';
        ax.CLim = [-100 100];
        cb = colorbar;
        cb.Label.String = cb_str;
        colormap(ax,USA)
        set(I, 'AlphaData', merged_alpha)

        % cb.Layout.Tile = 'south';
        fontsize(font_size, "points")
        sgtitle(strjoin([title_strings(ind), string(start_day), '-', string(end_day-days(1))]))

        save_path = fullfile(save_folder, [num2str(current_month),'_', num2str(current_year)]); 

        if ~exist(save_path, 'dir')
            mkdir(save_path)
        end
        exportgraphics(fig, fullfile(save_path, strjoin([string(site),'.png'],'')), 'Resolution', 300)
        savefig(fig, fullfile(save_path, strjoin([string(site),'.fig'],'')))

        close(fig);
    end
end
