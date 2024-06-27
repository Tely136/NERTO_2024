clearvars; clc; close all;

tempo_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
tropomi_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tempo_rad_table_path);
load(tropomi_rad_table_path);

day = 13;
month = 5;
year = 2024;

plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');

lat_bounds = [39 40];
lon_bounds = [-76.7, -76.3];

tropomi_filename = "/mnt/disks/data-disk/data/tropomi_data/S5P_OFFL_L2__NO2____20240513T163121_20240513T181252_34111_03_020600_20240515T094133.nc";
tempo_filename = "/mnt/disks/data-disk/data/tempo_data/TEMPO_NO2_L2_V03_20240513T181448Z_S010G03.nc";

tropomi_temp = tropomi_files_table(strcmp(tropomi_files_table.Filename,tropomi_filename),:);
tempo_temp = tempo_files_table(strcmp(tempo_files_table.Filename, tempo_filename),:);

[rows_trop, cols_trop] = get_indices(tropomi_temp, lat_bounds, lon_bounds);
trop_dim = [rows_trop(end)-rows_trop(1)+1, cols_trop(end)-cols_trop(1)+1];
tropomi_temp_data = read_tropomi_netcdf(tropomi_temp, rows_trop, cols_trop);
trop_no2 = tropomi_temp_data.no2(:);
trop_lat = tropomi_temp_data.lat(:);
trop_lon = tropomi_temp_data.lon(:);

[rows_tempo, cols_tempo] = get_indices(tempo_temp, lat_bounds, lon_bounds);
tempo_dim = [rows_tempo(end)-rows_tempo(1)+1, cols_tempo(end)-cols_tempo(1)+1];
tempo_temp_data = read_tempo_netcdf(tempo_temp, rows_tempo, cols_tempo);
tempo_no2 = tempo_temp_data.no2(:);
tempo_lat = tempo_temp_data.lat(:);
tempo_lon = tempo_temp_data.lon(:);

n_tropomi = length(trop_no2);
n_tempo = length(tempo_no2);

H = observation_operator(tempo_lat, tempo_lon, trop_lat, trop_lon);

tempo_no2_interp = H * tempo_no2;
tempo_no2_interp_plt = reshape(tempo_no2_interp, trop_dim);

tempo_no2_plt = reshape(tempo_no2, tempo_dim);
tempo_lat_plt = reshape(tempo_lat, tempo_dim);
tempo_lon_plt = reshape(tempo_lon, tempo_dim);

trop_no2_plt = reshape(trop_no2, trop_dim);
trop_lat_plt = reshape(trop_lat, trop_dim);
trop_lon_plt = reshape(trop_lon, trop_dim);

% %% Test with plots
% states_low_res = readgeotable("usastatehi.shp");
% clim = [0 10^16];

% fig1 = figure;

% % usamap(lat_bounds, lon_bounds)
% usamap('MD')
% hold on;
% surfacem(tempo_lat_plt, tempo_lon_plt, tempo_no2_plt)
% geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
% hold off
% colorbar
% ax = gca;
% ax.CLim = clim;

% fig2 = figure;

% % usamap(lat_bounds, lon_bounds)
% usamap('MD')
% hold on;
% surfacem(trop_lat_plt, trop_lon_plt, tempo_no2_interp_plt)
% geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
% hold off
% colorbar
% ax = gca;
% ax.CLim = clim;

