clearvars; clc; close all;

results_path = '/mnt/disks/data-disk/data/merged_data/non_temporal/testing';
save_path = '/mnt/disks/data-disk/figures/results/averages';
files = dir(fullfile(results_path, '*.mat'));

states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');

plot_timezone = 'America/New_York';

start_day = datetime(2024,6,1,0,0,0, 'TimeZone', plot_timezone);
end_day = datetime(2024,7,1, 'TimeZone', plot_timezone);


% Regular grid
grid_lat = 38:0.1:42;
grid_lon = -78:0.1:-72;

% Create meshgrid for the regular grid
[lon_grid, lat_grid] = meshgrid(grid_lon, grid_lat);

% Initialize arrays for Tempo and Tropomi data
tempo_dim = [2100, 500];  % Assuming these dimensions are correct
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
    date = datetime(string(name_splt{4}), "Format", "uuuuMMdd", "TimeZone", plot_timezone);

    if date >= start_day && date < end_day
        file = load(fullfile(files(i).folder, name));

        % Update tempo data and counter
        valid_tempo = ~isnan(file.save_data.bg_no2);
        tempo_no2_sum(valid_tempo) = tempo_no2_sum(valid_tempo) + file.save_data.bg_no2(valid_tempo);
        tempo_counter(valid_tempo) = tempo_counter(valid_tempo) + 1;

        % Store lat/lon data for bounds (assuming they don't change)
        if ~exist('tempo_lat', 'var')
            tempo_lat = file.save_data.bg_lat;
            tempo_lon = file.save_data.bg_lon;
        end

        % Update tropomi data and counter
        for j = 1:size(file.save_data.obs_no2, 3)
            obs_no2_page = file.save_data.obs_no2(:,:,j);
            obs_lat_page = file.save_data.obs_lat(:,:,j);
            obs_lon_page = file.save_data.obs_lon(:,:,j);
            valid_trop = ~isnan(obs_no2_page);
            if any(valid_trop(:))
                F = scatteredInterpolant(obs_lon_page(valid_trop), obs_lat_page(valid_trop), obs_no2_page(valid_trop), 'linear', 'none');
                interpolated_values = F(lon_grid, lat_grid);
                % TODO: add lat-lon bounds to file so that any data that is interpolated outside of this bound can be ignored 

                valid_interpolated = ~isnan(interpolated_values);
                trop_no2_sum(valid_interpolated) = trop_no2_sum(valid_interpolated) + interpolated_values(valid_interpolated);
                trop_counter(valid_interpolated) = trop_counter(valid_interpolated) + 1;
            end
        end

        % Update analysis data and counter
        valid_analysis = ~isnan(file.save_data.analysis_no2);
        analysis_no2_sum(valid_analysis) = analysis_no2_sum(valid_analysis) + file.save_data.analysis_no2(valid_analysis);
        analysis_counter(valid_analysis) = analysis_counter(valid_analysis) + 1;
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

lat_bounds = [min(tempo_lat(:)) max(tempo_lat(:))];
lon_bounds = [min(tempo_lon(:)) max(tempo_lon(:))];

font_size = 20;
resolution = 300;
dim = [0, 0, 900, 1000];
lw = 2;

clim_no2 = [0 300];
clim_no2_u = [0 100];
cb_str = 'umol/m^2';

title_str = sprintf('Average TEMPO TropNO2 Column \n %s - %s', string(start_day), string(end_day - days(1)));
make_map_fig(tempo_lat, tempo_lon, tempo_no2, lat_bounds, lon_bounds, fullfile(save_path, 'avg_tempo.png'), title_str, cb_str, clim_no2, [], dim);

title_str = sprintf('Average TROPOMI TropNO2 Column \n %s - %s', string(start_day), string(end_day - days(1)));
make_map_fig(lat_grid, lon_grid, trop_no2, lat_bounds, lon_bounds, fullfile(save_path, 'avg_tropomi.png'), title_str, cb_str, clim_no2, [], dim);

title_str = 'Average Merged TropNO2 Column';
make_map_fig(tempo_lat, tempo_lon, analysis_no2, lat_bounds, lon_bounds, fullfile(save_path, 'avg_merged.png'), title_str, cb_str, clim_no2, [], dim);

title_str = 'Merged Minus TEMPO';
make_map_fig(tempo_lat, tempo_lon, update, lat_bounds, lon_bounds, fullfile(save_path, 'update.png'), title_str, cb_str, [-100 100], [], dim);
