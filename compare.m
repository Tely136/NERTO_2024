clearvars; clc; close all;

tempo_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
tropomi_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tempo_rad_table_path);
load(tropomi_rad_table_path);

save_path = '/mnt/disks/data-disk/figures/angles';
conversion_factor = 6.022 .* 10.^19; % convert from mol/s/m^2/nm/sr to ph/s/cm^2/nm/sr

day = 13;
month = 5;
year = 2024;

plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');

scan = 10; % change this to the scan closest to tropomi
granule = 3;

tempo_rad_table = tempo_files_table(strcmp(tempo_files_table.Product, 'RAD') & tempo_files_table.Date>=day_tz & tempo_files_table.Date<day_tz+days(1) & tempo_files_table.Scan==scan & tempo_files_table.Granule==granule,:);
tempo_irrad_table = tempo_files_table(strcmp(tempo_files_table.Product, 'IRR'), :); % get irradiance file nearest to radiance measurement
tempo_no2_table = tempo_files_table(strcmp(tempo_files_table.Product, 'NO2') & tempo_files_table.Date == tempo_rad_table.Date & tempo_files_table.Scan==tempo_rad_table.Scan & tempo_files_table.Granule == tempo_rad_table.Granule, :);

[~, y] = min(abs(tempo_rad_table.Date - tempo_irrad_table.Date)); % Get irradiance file closest to radiance data
tempo_irrad_table = tempo_irrad_table(y,:);

tropomi_rad_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'RA') & tropomi_files_table.Date>=day_tz & tropomi_files_table.Date<day_tz+days(1), :);
tropomi_rad_table = tropomi_rad_table(1,:);
tropomi_irrad_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'IR'),:);
tropomi_no2_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'NO2') &  tropomi_files_table.Granule == tropomi_rad_table.Granule, :);

[~, y] = min(abs(tropomi_rad_table.Date - tropomi_irrad_table.Date));
tropomi_irrad_table = tropomi_irrad_table(y,:); % Get irradiance file closest to radiance data


lat_bounds = [23 50];
lon_bounds = [-93 -53];
[lat_grid, lon_grid] = create_grid(lat_bounds, lon_bounds, .1, .1);

[rows, cols] = get_indices(tropomi_no2_table, lat_bounds, lon_bounds);
trop_no2_data = read_tropomi_netcdf(tropomi_no2_table, rows, cols);
trop_datetime = tropomi_no2_table.Date;
trop_lat = trop_no2_data.lat;
trop_lon = trop_no2_data.lon;
trop_sza = trop_no2_data.sza;
trop_vza = trop_no2_data.vza;
trop_qa = trop_no2_data.qa;

trop_sza_interp = griddata(trop_lat(:), trop_lon(:), trop_sza(:), lat_grid, lon_grid);
trop_vza_interp = griddata(trop_lat(:), trop_lon(:), trop_vza(:), lat_grid, lon_grid);

[rows, cols] = get_indices(tempo_no2_table, lat_bounds, lon_bounds);
tempo_no2_data = read_tempo_netcdf(tempo_no2_table, rows, cols);
tempo_datetime = tempo_no2_table.Date;
tempo_lat = tempo_no2_data.lat;
tempo_lon = tempo_no2_data.lon;
tempo_sza = tempo_no2_data.sza;
tempo_vza = tempo_no2_data.vza;
tempo_qa = tempo_no2_data.qa;

tempo_sza_interp = griddata(tempo_lat(:), tempo_lon(:), tempo_sza(:), lat_grid, lon_grid);
tempo_vza_interp = griddata(tempo_lat(:), tempo_lon(:), tempo_vza(:), lat_grid, lon_grid);

% Find the coordinate in original data closest to min viewing difference with high QA
% plot radiance, irradiance, and reflectance at that point

vza_diff = tempo_vza_interp - trop_vza_interp;
[~, vza_min_index] = min(abs(vza_diff(:)));

marker = struct;
marker.lat = lat_grid(vza_min_index);
marker.lon = lon_grid(vza_min_index);

% make_map_fig(lat_grid, lon_grid, trop_vza_interp, lat_bounds, lon_bounds, fullfile(save_path, 'test1'), string(datetime(trop_datetime, 'TimeZone', plot_timezone)))
% make_map_fig(lat_grid, lon_grid, tempo_vza_interp, lat_bounds, lon_bounds, fullfile(save_path, 'test2'), string(datetime(tempo_datetime, 'TimeZone', plot_timezone)))
% make_map_fig(lat_grid, lon_grid, vza_diff, lat_bounds, lon_bounds, fullfile(save_path, 'test3'), string(datetime(tempo_datetime, 'TimeZone', plot_timezone)), marker)





