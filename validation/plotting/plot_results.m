clearvars; clc; close all;

results_path = '/mnt/disks/data-disk/data/merged_data';
save_path = '/mnt/disks/data-disk/figures/results';
states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');

date = datetime(2024, 5, 20, 'Format', 'uuuuMMdd');
scan = 10;

f = strjoin(['*', string(date), '_S', num2str(scan),'*.mat'],  '');
fileobj = dir(fullfile('/mnt/disks/data-disk/data/merged_data/temporal/testing', f));
% fileobj = dir(fullfile('/mnt/disks/data-disk/data/merged_data/non_temporal/testing', f));

file = load(fullfile(fileobj.folder, fileobj.name));

bg_no2 = file.save_data.bg_no2 .* 10^6;
bg_no2_u = file.save_data.bg_no2_u .* 10^6;
bg_lat = file.save_data.bg_lat;
bg_lon = file.save_data.bg_lon;
% bg_qa = file.save_data.bg_qa;
% bg_cld = file.save_data.bg_cld;
bg_time = file.save_data.bg_time;

bg_no2_u(isnan(bg_no2)) = NaN;

obs_no2 = file.save_data.obs_no2 .* 10^6;
obs_no2_u = file.save_data.obs_no2_u .* 10^6;
obs_lat = file.save_data.obs_lat;
obs_lon = file.save_data.obs_lon;
% obs_qa = file.save_data.obs_qa;
obs_time = file.save_data.obs_time;
obs_time = obs_time(1);

obs_no2_u(isnan(obs_no2)) = NaN;

analysis_no2 = file.save_data.analysis_no2 .* 10^6;
analysis_no2_u = file.save_data.analysis_no2_u .* 10^6;

update = analysis_no2 - bg_no2;
% update(update==0) = NaN;

% obs_var = file.save_data.obs_var .* 10^6;
% bg_var = file.save_data.bg_var .* 10^6;
% bg_cor = file.save_data.bg_cor;
% bg_cov = file.save_data.bg_cov .* 10^6;
% obs_operator = file.save_data.obs_operator;
% kalman_gain = file.save_data.kalman_gain;
% ana_cov = file.save_data.ana_cov .* 10^6;

lat_bounds = [min(bg_lat(~isnan(analysis_no2))) max(bg_lat(~isnan(analysis_no2)))];
lon_bounds = [min(bg_lon(~isnan(analysis_no2))) max(bg_lon(~isnan(analysis_no2)))];

plot_timezone = 'America/New_York';

font_size = 20;
resolution = 300;
dim = [0, 0, 1000, 1300];
lw = 2;
load('USA.mat');


clim_no2 = [0 300];
clim_no2_u = [0 50];

cb_str = 'umol/m^2';

title = strjoin(['TEMPO TropNO2 Column', string(mean(bg_time)), 'UTC']);
make_map_fig(bg_lat, bg_lon, bg_no2, lat_bounds, lon_bounds, fullfile(save_path, 'tempo.png'), title, cb_str, clim_no2, [], dim);

title = strjoin(['TROPOMI TropNO2 Column', string(mean(obs_time)), 'UTC']);
make_map_fig(obs_lat, obs_lon, obs_no2, lat_bounds, lon_bounds, fullfile(save_path, 'tropomi.png'), title, cb_str, clim_no2, [], dim);

title = 'Merged TropNO2 Column';
make_map_fig(bg_lat, bg_lon, analysis_no2, lat_bounds, lon_bounds, fullfile(save_path, 'merged.png'), title, cb_str, clim_no2, [], dim);

title = 'Analysis Minus Background';
make_map_fig(bg_lat, bg_lon, update, lat_bounds, lon_bounds, fullfile(save_path, 'update.png'), title, cb_str, [-100 100], [], dim);

% title = strjoin(['TEMPO TropNO2 Uncertainty', string(mean(bg_time)), 'UTC']);
% make_map_fig(bg_lat, bg_lon, bg_no2_u, lat_bounds, lon_bounds, fullfile(save_path, 'tempo_u.png'), title, cb_str, clim_no2_u, [], dim);

% title = strjoin(['TROPOMI TropNO2 Uncertainty', string(mean(obs_time)), 'UTC']);
% make_map_fig(obs_lat, obs_lon, obs_no2_u, lat_bounds, lon_bounds, fullfile(save_path, 'tropomi_u.png'), title, cb_str, clim_no2_u, [], dim);

% title = 'Merged TropNO2 Uncertainty';
% make_map_fig(bg_lat, bg_lon, analysis_no2_u, lat_bounds, lon_bounds, fullfile(save_path, 'merged_u'), title, cb_str, [0 10], [], dim);


% matrix_image(bg_cor, 'Correlation Matrix', fullfile(save_path, 'C'), 'hot') % models correlation between locations in background data
% matrix_image(bg_var, 'Background Variance Matrix', fullfile(save_path, 'D'), 'hot', clim_no2_u) % Diagonal matrix of background data variances
% matrix_image(obs_var, 'Observation Covariance Matrix', fullfile(save_path, 'R'), 'hot', clim_no2_u) % Diagonal matrix of observation data variances
% matrix_image(bg_cov, 'Background Covariance Matrix', fullfile(save_path, 'Pb'), 'hot', clim_no2_u) % Background covariance data with correlation model incorporated
% matrix_image(obs_operator, 'Observation Transformation Matrix', fullfile(save_path, 'H'), 'gray') % Observation transformation operator
% % matrix_image(S, 'Innovation Covariance Matrix', fullfile(save_path, 'S'), 'hot', clim_no2_u) % Innovation covariance matrix
% matrix_image(kalman_gain, 'Kalman Gain Matrix', fullfile(save_path, 'K'), USA, [-.5 .5]) % Determines weight of the innovation
% matrix_image(ana_cov, 'Analysis Error Covariance', fullfile(save_path, 'Pa'), 'hot', [0 10]) % Analysis error covariance