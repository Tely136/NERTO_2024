function plot_results_avg(start_date, end_date, lat_bounds, lon_bounds, save_path, options)
    arguments
        start_date string
        end_date string
        lat_bounds double
        lon_bounds double
        save_path string
        options.tempo_clim double = [0 300]
        options.tropomi_clim double = [0 300]
        options.merged_clim double = [0 300]
        options.update_clim double = [-100 100]
    end

timezone = 'America/New_York';

start_date = datetime(start_date, "InputFormat", 'uuuuMMdd', 'TimeZone', timezone);
end_date = datetime(end_date, "InputFormat", 'uuuuMMdd', 'TimeZone', timezone);
run_days = start_date:end_date;

data_path = '/mnt/disks/results-disk/merged_data/';

if ~exist(save_path, 'dir')
    mkdir(save_path)
end

load('/mnt/disks/data-disk/NERTO_2024/misc/USA.mat'); %#ok<LOAD>

if ~exist(fullfile(save_path, "average_data.mat"), "file")
    disp('Calculating averages')

    files = dir(fullfile(data_path, '*.nc'));

    % Regular grid
    grid_lat = lat_bounds(1):0.05:lat_bounds(2);
    grid_lon = lon_bounds(1):0.05:lon_bounds(2);

    % Create meshgrid for the regular grid
    [lon_grid, lat_grid] = meshgrid(grid_lon, grid_lat);

    % Initialize arrays for Tempo and Tropomi data
    tempo_dim = [2100, 500];
    trop_dim = [500 4200];
    grid_dim = size(lon_grid);  % Dimensions of the regular grid

    tempo_no2_sum = zeros(tempo_dim);
    tempo_counter = zeros(tempo_dim);

    trop_no2_sum = zeros(grid_dim);
    trop_counter = zeros(grid_dim);

    analysis_no2_sum = zeros(tempo_dim);
    analysis_counter = zeros(tempo_dim);

    % Loop over each file in merged data
    for i = 1:length(files)
        name = files(i).name;
        name_splt = strsplit(name, '_');
        date = datetime(string(name_splt{4}), "Format", "uuuuMMdd", "TimeZone", timezone);

        if ismember(date, run_days)
            file_path = fullfile(files(i).folder, name);

            % Update tempo data and counter
            valid_tempo = logical(ncread(file_path, '/tempo/tempo_valid_ind'));
            temp_tempo_no2 = ncread(file_path, '/tempo/tempo_no2');
            tempo_no2_sum(valid_tempo) = tempo_no2_sum(valid_tempo) + temp_tempo_no2(valid_tempo);
            tempo_counter(valid_tempo) = tempo_counter(valid_tempo) + 1;

            % Store lat/lon data for bounds (assuming they don't change)
            if ~exist('tempo_lat', 'var')
                tempo_lat = ncread(file_path, '/tempo/tempo_lat');
                tempo_lon = ncread(file_path, '/tempo/tempo_lon');
            end

            % Update tropomi data and counter
            n_tropomi_scans = ncinfo(file_path, '/tropomi/tropomi_no2');
            n_tropomi_scans = n_tropomi_scans.Size(3);
            for j = 1:size(n_tropomi_scans, 3)
                obs_no2_page = ncread(file_path, '/tropomi/tropomi_no2', [1, 1, j], [trop_dim(1), trop_dim(2), j]);
                obs_lat_page = ncread(file_path, '/tropomi/tropomi_lat', [1, 1, j], [trop_dim(1), trop_dim(2), j]);
                obs_lon_page = ncread(file_path, '/tropomi/tropomi_lon', [1, 1, j], [trop_dim(1), trop_dim(2), j]);
                valid_trop = logical(ncread(file_path, '/tropomi/tropomi_valid_ind', [1, 1, j], [trop_dim(1), trop_dim(2), j]));
                if any(valid_trop(:))
                    F = scatteredInterpolant(obs_lon_page(valid_trop), obs_lat_page(valid_trop), obs_no2_page(valid_trop), 'linear', 'none');
                    interpolated_values = F(lon_grid, lat_grid);

                    valid_interpolated = ~isnan(interpolated_values);
                    trop_no2_sum(valid_interpolated) = trop_no2_sum(valid_interpolated) + interpolated_values(valid_interpolated);
                    trop_counter(valid_interpolated) = trop_counter(valid_interpolated) + 1;
                end
            end

            % Update analysis data and counter
            temp_analysis_no2 = ncread(file_path, 'analysis/analysis_no2');
            analysis_no2_sum(valid_tempo) = analysis_no2_sum(valid_tempo) + temp_analysis_no2(valid_tempo);
            analysis_counter(valid_tempo) = analysis_counter(valid_tempo) + 1;
        end
    end

    % Calculate averages, avoid division by zero
    tempo_no2 = NaN(size(tempo_no2_sum));
    tempo_no2(tempo_counter > 0) = 10^6 .* tempo_no2_sum(tempo_counter > 0) ./ tempo_counter(tempo_counter > 0);

    trop_no2 = NaN(size(trop_no2_sum));
    trop_no2(trop_counter > 0) = 10^6 .* trop_no2_sum(trop_counter > 0) ./ trop_counter(trop_counter > 0);

    analysis_no2 = NaN(size(analysis_no2_sum));
    analysis_no2(analysis_counter > 0) = 10^6 .* analysis_no2_sum(analysis_counter > 0) ./ analysis_counter(analysis_counter > 0);

    update = analysis_no2 - tempo_no2;

    tempo_F = scatteredInterpolant(tempo_lon(tempo_counter > 0), tempo_lat(tempo_counter > 0), tempo_no2(tempo_counter > 0), 'linear', 'none');
    tempo_reg = tempo_F(lon_grid, lat_grid);

    trop_tempo_diff = trop_no2 - tempo_reg;

    save(fullfile(save_path, 'average_data.mat'), 'tempo_no2', 'trop_no2', 'analysis_no2', 'update', 'tempo_reg', 'trop_tempo_diff', 'tempo_lat', 'tempo_lon', 'lon_grid', 'lat_grid', 'lat_bounds', 'lon_bounds')
else
    load(fullfile(save_path, 'average_data.mat')) %#ok<LOAD>
end

disp('Making maps')

dim = [0, 0, 1000, 1000];
cb_str = 'umol/m^2';

title_str = sprintf('Average TEMPO NO2 Column %s %s', string(month(start_date, 'name')), string(year(start_date)));
make_map_fig(tempo_lat, tempo_lon, tempo_no2, lat_bounds, lon_bounds, fullfile(save_path, 'avg_tempo.png'), title_str, cb_str, options.tempo_clim, [], dim);

title_str = sprintf('Average TROPOMI NO2 Column %s %s', string(month(start_date, 'name')), string(year(start_date)));
make_map_fig(lat_grid, lon_grid, trop_no2, lat_bounds, lon_bounds, fullfile(save_path, 'avg_tropomi.png'), title_str, cb_str, options.tropomi_clim, [], dim);

title_str = sprintf('Average Analysis NO2 Column %s %s', string(month(start_date, 'name')), string(year(start_date)));
make_map_fig(tempo_lat, tempo_lon, analysis_no2, lat_bounds, lon_bounds, fullfile(save_path, 'avg_merged.png'), title_str, cb_str, options.merged_clim, [], dim);

title_str = sprintf('Analysis Increment %s %s', string(month(start_date, 'name')), string(year(start_date)));
make_map_fig(tempo_lat, tempo_lon, update, lat_bounds, lon_bounds, fullfile(save_path, 'update.png'), title_str, cb_str, options.update_clim, [], dim, USA);

title_str = sprintf('Average TEMPO NO2 Column %s %s', string(month(start_date, 'name')), string(year(start_date)));
make_map_fig(lat_grid, lon_grid, tempo_reg, lat_bounds, lon_bounds, fullfile(save_path, 'avg_tempo_reg.png'), title_str, cb_str, options.tempo_clim, [], dim);

% title_str = sprintf('Tropomi - TEMPO \n %s - %s', string(start_date), string(end_date));
% make_map_fig(lat_grid, lon_grid, trop_tempo_diff, lat_bounds, lon_bounds, fullfile(save_path, 'trop_tempo_diff.png'), title_str, cb_str, options.update_clim, [], dim, USA);
