clearvars; clc; close all;

results_path = '/mnt/disks/data-disk/data/merged_data';
save_path = '/mnt/disks/data-disk/figures/results';
states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');
files = dir(fullfile(results_path,'*.mat'));

[filename, path] = uigetfile('/mnt/disks/data-disk/data/merged_data/');
file = load(fullfile(path, filename));

bg_no2 = file.save_data.bg_no2 .* 10^6;
bg_no2_u = file.save_data.bg_no2_u .* 10^6;
bg_lat = file.save_data.bg_lat;
bg_lon = file.save_data.bg_lon;
bg_qa = file.save_data.bg_qa;
bg_cld = file.save_data.bg_cld;
bg_time = file.save_data.bg_time;


obs_no2 = file.save_data.obs_no2(:,:,2) .* 10^6;
obs_no2_u = file.save_data.obs_no2_u(:,:,2) .* 10^6;
obs_lat = file.save_data.obs_lat(:,:,2);
obs_lon = file.save_data.obs_lon(:,:,2);
obs_qa = file.save_data.obs_qa;
obs_time = file.save_data.obs_time;
obs_time = obs_time(1);


analysis_no2 = file.save_data.analysis_no2 .* 10^6;
analysis_no2_u = file.save_data.analysis_no2_u .* 10^6;


update = analysis_no2 - bg_no2;


lat_bounds = [min(bg_lat(:)) max(bg_lat(:))];
lon_bounds = [min(bg_lon(:)) max(bg_lon(:))];

day = 20;
month = 5;
year = 2024;

plot_timezone = 'America/New_York';



font_size = 20;
resolution = 300;
dim = [0, 0, 900, 1000];
lw = 2;


clim_no2 = [0 300];
clim_no2_u = [0 100];

cb_str = 'umol/m^2';

title = strjoin(['TEMPO TropNO2 Column', string(mean(bg_time)), 'UTC']);
make_map_fig(bg_lat, bg_lon, bg_no2, lat_bounds, lon_bounds, fullfile(save_path, 'tempo'), title, cb_str, clim_no2, [], dim);

title = strjoin(['TEMPO TropNO2 Uncertainty', string(mean(bg_time)), 'UTC']);
make_map_fig(bg_lat, bg_lon, bg_no2_u, lat_bounds, lon_bounds, fullfile(save_path, 'tempo_u'), title, cb_str, [0 150], [], dim);


title = strjoin(['TROPOMI TropNO2 Column', string(mean(obs_time)), 'UTC']);
make_map_fig(obs_lat, obs_lon, obs_no2, lat_bounds, lon_bounds, fullfile(save_path, 'tropomi'), title, cb_str, clim_no2, [], dim);

title = strjoin(['TROPOMI TropNO2 Uncertainty', string(mean(obs_time)), 'UTC']);
make_map_fig(obs_lat, obs_lon, obs_no2_u, lat_bounds, lon_bounds, fullfile(save_path, 'tropomi_u'), title, cb_str, [0 30], [], dim);


title = 'Merged TropNO2 Column';
make_map_fig(bg_lat, bg_lon, analysis_no2, lat_bounds, lon_bounds, fullfile(save_path, 'merged'), title, cb_str, clim_no2, [], dim);

title = 'Merged TropNO2 Uncertainty';
make_map_fig(bg_lat, bg_lon, analysis_no2_u, lat_bounds, lon_bounds, fullfile(save_path, 'merged_u'), title, cb_str, [0 10], [], dim);


title = 'Analysis Minus Background';
make_map_fig(bg_lat, bg_lon, update, lat_bounds, lon_bounds, fullfile(save_path, 'update'), title, cb_str, [-100 100], [], dim);