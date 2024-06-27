clearvars; clc; close all;

table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(table_path);

states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');
states_low_res = readgeotable("usastatehi.shp");
tracts = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_24_tract_500k/cb_2023_24_tract_500k.shp');

day = datetime(2024, 3, 25, 'TimeZone', 'UTC');
day_table = tropomi_files_table(tropomi_files_table.Level==2 & tropomi_files_table.Date>=day & ...
    tropomi_files_table.Date<day+days(1),:);
    
temp_file = day_table(1,:).Filename;

bounds_lat = [24 50];
bounds_lon = [-125 -66];

color_lim = [0 90];
dim = [0, 0, 1200, 300];

fig = figure('Visible', 'off', 'Position', dim);
t = tiledlayout(1, 2);

% Plot SZA
ax1 = nexttile;
usamap(bounds_lat, bounds_lon);
temp_lat = ncread(temp_file, '/PRODUCT/latitude');
temp_lon = ncread(temp_file, '/PRODUCT/longitude');
temp_sza = ncread(temp_file, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/solar_zenith_angle');
surfm(temp_lat, temp_lon, temp_sza);
geoshow(ax1, states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
setm(ax1, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off')
title(ax1, 'Solar Zenith Angle')
ax1.CLim = color_lim;

% Plot VZA
ax2 = nexttile;
usamap(bounds_lat, bounds_lon);
temp_vza = ncread(temp_file, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/viewing_zenith_angle');
surfm(temp_lat, temp_lon, temp_vza);
geoshow(ax2, states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
setm(ax2, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off')
title(ax2, 'Viewing Zenith Angle')
ax2.CLim = color_lim;

cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = 'degrees';

dt_est = datetime(day_table.Date(1,:), "TimeZone", 'America/New_York');

title_string = strjoin(['TROPOMI', string(dt_est), 'EST']);
sgtitle(title_string)

savename = strjoin(['TROPOMI_VZA_SZA_', string(datetime(dt_est, 'Format', 'yyyy-MM-dd''T''HHmmss'))], '');
save_path = '/mnt/disks/data-disk/figures';

resolution = 300;

print(fig, fullfile(save_path, savename), '-dpng', ['-r' num2str(resolution)])

close(fig);

