clc; clearvars; close all; 

tempo_files = tempo_table('/mnt/disks/data-disk/data/tempo_data');
tempo_files = tempo_files(strcmp(tempo_files.Product,'NO2'),:);

tropomi_files = tropomi_table('/mnt/disks/data-disk/data/tropomi_data/');
tropomi_files = tropomi_files(strcmp(tropomi_files.Product,'NO2'),:);

latbounds = [39 40];
lonbounds = [-77 -76];

file = tempo_files(2,:);
[rows, cols] = get_indices(file, latbounds, lonbounds);
tempo_data = read_tempo_netcdf(file, rows, cols);
bg_lat = tempo_data.lat(:);
bg_lon = tempo_data.lon(:);
bg_lat_corners = reshape(tempo_data.lat_corners, 4, []);
bg_lon_corners = reshape(tempo_data.lon_corners, 4, []);
bg_no2 = tempo_data.no2(:);
bg_no2_u = tempo_data.no2_u(:);
bg_size = [rows(2)-rows(1)+1 cols(2)-cols(1)+1];

file = tropomi_files(1,:);
[rows, cols] = get_indices(file, latbounds, lonbounds);
tropomi_data = read_tropomi_netcdf(file, rows, cols);
obs_lat = tropomi_data.lat(:);
obs_lon = tropomi_data.lon(:);
obs_lat_corners = reshape(tropomi_data.lat_corners, 4, []);
obs_lon_corners = reshape(tropomi_data.lon_corners, 4, []);
obs_no2 = tropomi_data.no2(:);
obs_no2_u = tropomi_data.no2_u(:);
obs_size = [rows(2)-rows(1)+1 cols(2)-cols(1)+1];


H = interpolation_operator(bg_lat, bg_lon, bg_lat_corners, bg_lon_corners, obs_lat, obs_lon, obs_lat_corners, obs_lon_corners, 'mean');


dat = H * bg_no2(:);
new_data = reshape(dat, obs_size);

bg_lat_plt = reshape(bg_lat, bg_size);
bg_lon_plt = reshape(bg_lon, bg_size);
bg_no2_plt = reshape(bg_no2, bg_size);

obs_lat_plt = reshape(obs_lat, obs_size);
obs_lon_plt = reshape(obs_lon, obs_size);
obs_no2_plt = reshape(obs_no2, obs_size);

%
close all
clim = [0 10^16];

fig = tiledlayout(1,3);
nexttile
ax = worldmap(latbounds, lonbounds);
surfm(bg_lat_plt, bg_lon_plt, bg_no2_plt)
ax.CLim = clim;

nexttile
ax = worldmap(latbounds, lonbounds);
surfm(obs_lat_plt, obs_lon_plt, obs_no2_plt)
ax.CLim = clim;

nexttile
ax = worldmap(latbounds, lonbounds);
surfm(obs_lat_plt, obs_lon_plt, new_data)
ax.CLim = clim;

cb = colorbar;
cb.Layout.Tile = 'east';


