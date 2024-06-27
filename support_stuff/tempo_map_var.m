clearvars; clc; close all;

table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
load(table_path);

states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');
states_low_res = readgeotable("usastatehi.shp");
tracts = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_24_tract_500k/cb_2023_24_tract_500k.shp');

% plot_timezone = 'UTC';
plot_timezone = 'America/New_York';

day = datetime(2024, 3, 25, 'TimeZone', plot_timezone);
level = 2;
product = 'NO2';
scan = 9;
granule = 3;

table = tempo_files_table(strcmp(tempo_files_table.Product,product) & tempo_files_table.Level==level & tempo_files_table.Date>=day & ...
    tempo_files_table.Date<day+days(1) & tempo_files_table.Scan==scan & tempo_files_table.Granule==granule,:);


file = table.Filename;
lat = ncread(file, '/geolocation/latitude');
lon = ncread(file, '/geolocation/longitude');
qa = ncread(file, '/product/main_data_quality_flag');
cloud_frac = ncread(file, '/support_data/eff_cloud_fraction');

bounds_lat = [24 50];
bounds_lon = [-125 -66];

resolution = 300;

dim = [0, 0, 1200, 900];

% colors = [
%     1, 0, 0;  % Red for value 1
%     0, 1, 0;  % Green for value 2
%     0, 0, 1;  % Blue for value 3
% ];

fig = figure('Visible', 'off', 'Position', dim);
usamap('MD')
% usamap(bounds_lat, bounds_lon)

hold on;
surfm(lat, lon, cloud_frac)
geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);

setm(gca, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off')
% colormap(colors)
colorbar;

hold off;




print(fig, fullfile('/mnt/disks/data-disk/NERTO_2024', 'temp_fig'), '-dpng', ['-r' num2str(resolution)])