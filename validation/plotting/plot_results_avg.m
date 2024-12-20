function plot_results_avg(start_date, end_date, lat_bounds, lon_bounds, input_data_path, fig_save_path, options)
    arguments
        start_date string
        end_date string
        lat_bounds double
        lon_bounds double
        input_data_path string
        fig_save_path string
        options.tempo_clim double = [0 300] %#ok<INUSA>
        options.tropomi_clim double = [0 300]
        options.merged_clim double = [0 300]
        options.update_clim double = [-100 100]
        options.overwrite_on logical = false;
    end

timezone = 'America/New_York';

start_date = datetime(start_date, "InputFormat", 'uuuuMMdd', 'TimeZone', timezone);
end_date = datetime(end_date, "InputFormat", 'uuuuMMdd', 'TimeZone', timezone);
run_days = start_date:end_date;


if ~exist(fig_save_path, 'dir')
    mkdir(fig_save_path)
end

USA = load("USA.mat");
USA = USA.USA;

if ~exist(fullfile(fig_save_path, "average_data.mat"), "file") || options.overwrite_on
    disp('Calculating averages')

    files = dir(fullfile(input_data_path, '*.nc'));

    % Regular grid
    grid_lat = lat_bounds(1):0.05:lat_bounds(2);
    grid_lon = lon_bounds(1):0.05:lon_bounds(2);

    % Create meshgrid for the regular grid
    [lon_grid, lat_grid] = meshgrid(grid_lon, grid_lat);

    % Initialize arrays for Tempo and Tropomi data
    tempo_dim = [2100, 1400];
    trop_dim = [500 4200];
    grid_dim = size(lon_grid);  % Dimensions of the regular grid

    tempo_no2_sum = zeros(tempo_dim);
    tempo_counter = zeros(tempo_dim);

    trop_no2_sum = zeros(grid_dim);
    trop_counter = zeros(grid_dim);

    analysis_no2_sum = zeros(tempo_dim);
    analysis_counter = zeros(tempo_dim);

    tempo_no2_sum_interp = zeros(grid_dim);
    tempo_counter_interp = zeros(grid_dim);

    analysis_no2_sum_interp = zeros(grid_dim);
    analysis_counter_interp = zeros(grid_dim);

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

            % Update analysis data and counter
            temp_analysis_no2 = ncread(file_path, 'analysis/analysis_no2');
            analysis_no2_sum(valid_tempo) = analysis_no2_sum(valid_tempo) + temp_analysis_no2(valid_tempo);
            analysis_counter(valid_tempo) = analysis_counter(valid_tempo) + 1;

            % Store lat/lon data for bounds (assuming they don't change)
            if ~exist('tempo_lat', 'var')
                tempo_lat = ncread(file_path, '/tempo/tempo_lat');
                tempo_lon = ncread(file_path, '/tempo/tempo_lon');
            end

            tempo_F = scatteredInterpolant(tempo_lon(valid_tempo), tempo_lat(valid_tempo), temp_tempo_no2(valid_tempo), 'linear', 'none');
            tempo_interpolated_values = tempo_F(lon_grid, lat_grid);
            valid_tempo_interp = ~isnan(tempo_interpolated_values);

            tempo_no2_sum_interp(valid_tempo_interp) = tempo_no2_sum_interp(valid_tempo_interp) + tempo_interpolated_values(valid_tempo_interp);
            tempo_counter_interp(valid_tempo_interp) = tempo_counter_interp(valid_tempo_interp) + 1;

            
            analysis_F = scatteredInterpolant(tempo_lon(valid_tempo), tempo_lat(valid_tempo), temp_analysis_no2(valid_tempo), 'linear', 'none');
            analysis_interpolated_values = analysis_F(lon_grid, lat_grid);
            valid_analysis_interp = ~isnan(analysis_interpolated_values);

            analysis_no2_sum_interp(valid_analysis_interp) = analysis_no2_sum_interp(valid_analysis_interp) + analysis_interpolated_values(valid_analysis_interp);
            analysis_counter_interp(valid_analysis_interp) = analysis_counter_interp(valid_analysis_interp) + 1;


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
        end
    end

    % Calculate averages, avoid division by zero
    tempo_no2 = NaN(size(tempo_no2_sum));
    tempo_no2(tempo_counter > 0) = 10^6 .* tempo_no2_sum(tempo_counter > 0) ./ tempo_counter(tempo_counter > 0);

    trop_no2 = NaN(size(trop_no2_sum));
    trop_no2(trop_counter > 0) = 10^6 .* trop_no2_sum(trop_counter > 0) ./ trop_counter(trop_counter > 0);

    analysis_no2 = NaN(size(analysis_no2_sum));
    analysis_no2(analysis_counter > 0) = 10^6 .* analysis_no2_sum(analysis_counter > 0) ./ analysis_counter(analysis_counter > 0);

    tempo_no2_interp = NaN(size(tempo_no2_sum_interp));
    tempo_no2_interp(tempo_counter_interp > 0) = 10^6 .* tempo_no2_sum_interp(tempo_counter_interp > 0) ./ tempo_counter_interp(tempo_counter_interp > 0);

    analysis_no2_interp = NaN(size(analysis_no2_sum_interp));
    analysis_no2_interp(analysis_counter_interp > 0) = 10^6 .* analysis_no2_sum_interp(analysis_counter_interp > 0) ./ analysis_counter_interp(analysis_counter_interp > 0);

    update = analysis_no2 - tempo_no2;
    update_interp = analysis_no2_interp - tempo_no2_interp;

    trop_tempo_diff = trop_no2 - tempo_no2_interp;

    save(fullfile(fig_save_path, 'average_data.mat'), 'tempo_no2', 'trop_no2', 'analysis_no2', 'analysis_no2_interp', 'update', 'update_interp', 'tempo_no2_interp', 'trop_tempo_diff', 'tempo_lat', 'tempo_lon', 'lon_grid', 'lat_grid', 'lat_bounds', 'lon_bounds')
else
    load(fullfile(fig_save_path, 'average_data.mat')) %#ok<LOAD>
end

disp('Making maps')

dim = [0, 0, 1500, 1000];
cb_str = 'umol/m^2';

no2_lim_inc = 10;
update_lim_inc = 10;

tempo_no2_test = rmoutliers(tempo_no2_interp);
trop_no2_test = rmoutliers(trop_no2);
merged_no2_test = rmoutliers(analysis_no2_interp);

tempo_max_no2 = max(tempo_no2_test, [], 'all');
tempo_min_no2 = min(tempo_no2_test, [], 'all');

tropomi_max_no2 = max(trop_no2_test, [], 'all');
tropomi_min_no2 = min(trop_no2_test, [], 'all');

merged_max_no2 =  max(merged_no2_test, [], 'all');
merged_min_no2 = min(merged_no2_test, [], 'all');

update_max =  max(abs(update_interp), [], 'all');

max_no2 = max([tempo_max_no2; tropomi_max_no2; merged_max_no2]);
% min_no2 = min([tempo_min_no2; tropomi_min_no2; merged_min_no2]);
min_no2 = 0;

no2_clim = [no2_lim_inc*round(min_no2/no2_lim_inc) no2_lim_inc*round(max_no2/no2_lim_inc)];
no2_clim(1) = max([0; no2_clim(1)]);

no2_clim = [0 100];

update_clim = [-update_lim_inc*round(update_max/update_lim_inc), update_lim_inc*round(update_max/update_lim_inc)];
if all(update_clim==0)
    update_clim = [];
end

% title_str = sprintf('Avg. TEMPO NO_{2} %s %s', string(month(start_date, 'name')), string(year(start_date)));
% make_map_fig(tempo_lat, tempo_lon, tempo_no2, lat_bounds, lon_bounds, fullfile(fig_save_path, 'avg_tempo'), title_str, cb_str, no2_clim, [], dim);

title_str = sprintf('Avg. TEMPO NO_{2} %s %s', string(month(start_date, 'name')), string(year(start_date)));
make_map_fig(lat_grid, lon_grid, tempo_no2_interp, lat_bounds, lon_bounds, fullfile(fig_save_path, 'avg_tempo_interp'), '', cb_str, no2_clim, [], dim);


title_str = sprintf('Avg. TROPOMI NO_{2} %s %s', string(month(start_date, 'name')), string(year(start_date)));
make_map_fig(lat_grid, lon_grid, trop_no2, lat_bounds, lon_bounds, fullfile(fig_save_path, 'avg_tropomi'), '', cb_str, no2_clim, [], dim);


% title_str = sprintf('Avg. Merged NO_{2} %s %s', string(month(start_date, 'name')), string(year(start_date)));
% make_map_fig(tempo_lat, tempo_lon, analysis_no2, lat_bounds, lon_bounds, fullfile(fig_save_path, 'avg_merged'), title_str, cb_str, no2_clim, [], dim);

title_str = sprintf('Avg. Merged NO_{2} %s %s', string(month(start_date, 'name')), string(year(start_date)));
make_map_fig(lat_grid, lon_grid, analysis_no2_interp, lat_bounds, lon_bounds, fullfile(fig_save_path, 'avg_merged_interp'), '', cb_str, no2_clim, [], dim);


% title_str = sprintf('Avg. NO_{2} Increment %s %s', string(month(start_date, 'name')), string(year(start_date)));
% make_map_fig(tempo_lat, tempo_lon, update, lat_bounds, lon_bounds, fullfile(fig_save_path, 'update'), title_str, cb_str, update_clim, [], dim, USA);

title_str = sprintf('Avg. NO_{2} Increment %s %s', string(month(start_date, 'name')), string(year(start_date)));
make_map_fig(lat_grid, lon_grid, update_interp, lat_bounds, lon_bounds, fullfile(fig_save_path, 'update_interp'), '', cb_str, update_clim, [], dim, USA);


