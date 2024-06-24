clearvars; clc; close all;

tempo_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
tropomi_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tempo_rad_table_path);
load(tropomi_rad_table_path);

save_path = '/mnt/disks/data-disk/figures/radiance';
conversion_factor = 6.022 .* 10.^19; % convert from mol/s/m^2/nm/sr to ph/s/cm^2/nm/sr

baltimore_lat = 40.9; baltimore_lon = -76.9;

day = 13;
month = 5;
year = 2024;

plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');

scan = 9; % change this to the scan closest to tropomi
granule = 3;

tempo_rad_table = tempo_files_table(strcmp(tempo_files_table.Product, 'RAD') & tempo_files_table.Date>=day_tz & tempo_files_table.Date<day_tz+days(1) & tempo_files_table.Scan==scan & tempo_files_table.Granule==granule,:);
tempo_irrad_table = tempo_files_table(strcmp(tempo_files_table.Product, 'IRR'), :); % get irradiance file nearest to radiance measurement
tempo_no2_table = tempo_files_table(strcmp(tempo_files_table.Product, 'NO2') & tempo_files_table.Date == tempo_rad_table.Date & tempo_files_table.Scan==tempo_rad_table.Scan & tempo_files_table.Granule == tempo_rad_table.Granule, :);

[~, y] = min(abs(tempo_rad_table.Date - tempo_irrad_table.Date));
tempo_irrad_table = tempo_irrad_table(y,:);

tropomi_rad_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'RA') & tropomi_files_table.Date>=day_tz & tropomi_files_table.Date<day_tz+days(1), :);
tropomi_rad_table = tropomi_rad_table(1,:);
tropomi_irrad_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'IR'),:);
tropomi_no2_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'NO2') &  tropomi_files_table.Granule == tropomi_rad_table.Granule, :);

[~, y] = min(abs(tropomi_rad_table.Date - tropomi_irrad_table.Date));
tropomi_irrad_table = tropomi_irrad_table(y,:);

% Tempo
[rows, cols] = get_indices(tempo_rad_table, baltimore_lat, baltimore_lon);
tempo_no2_data = read_tempo_netcdf(tempo_no2_table, rows, cols);
tempo_rad_data = read_tempo_netcdf(tempo_rad_table, rows, cols);
tempo_irrad_data = read_tempo_netcdf(tempo_irrad_table, rows, cols);

tempo_qa = tempo_no2_data.qa;

tempo_rad = tempo_rad_data.rad;
tempo_wl = tempo_rad_data.wl;
tempo_lat = tempo_rad_data.lat;
tempo_lon = tempo_rad_data.lon;
tempo_sza = tempo_rad_data.sza;
tempo_vza = tempo_rad_data.vza;
tempo_time = tempo_rad_data.time;

tempo_irrad = tempo_irrad_data.irrad;

tempo_r = pi * tempo_rad ./ (cosd(tempo_sza) .* tempo_irrad);

% Tropomi
[rows, cols] = get_indices(tropomi_rad_table, baltimore_lat, baltimore_lon);
tropomi_no2_data = read_tropomi_netcdf(tropomi_no2_table, rows, cols);
tropomi_rad_data = read_tropomi_netcdf(tropomi_rad_table, rows, cols);
tropomi_irrad_data = read_tropomi_netcdf(tropomi_irrad_table, rows, cols);

tropomi_qa = tropomi_no2_data.qa;

tropomi_rad = tropomi_rad_data.rad;
tropomi_wl = tropomi_rad_data.wl;
tropomi_lat = tropomi_rad_data.lat;
tropomi_lon = tropomi_rad_data.lon;
tropomi_sza = tropomi_rad_data.sza;
tropomi_vza = tropomi_rad_data.vza;
tropomi_time = tropomi_rad_data.time;

tropomi_irrad = tropomi_irrad_data.irrad;

tropomi_r = pi * tropomi_rad ./ (cosd(tropomi_sza) .* tropomi_irrad);


%%
disp(['TEMPO lat,lon at location: ', num2str(tempo_lat), ', ', num2str(tempo_lon)])
disp(['TROPOMI lat,lon at location: ', num2str(tropomi_lat), ', ', num2str(tropomi_lon)])

disp(['TEMPO QA at location: ', num2str(tempo_qa)])
disp(['TROPOMI QA at location: ', num2str(tropomi_qa)])

disp(['TEMPO VZA at location: ', num2str(tempo_vza)])
disp(['TROPOMI VZA at location: ', num2str(tropomi_vza)])

disp(['TEMPO time at location: ', char(datetime(tempo_time, 'TimeZone', plot_timezone))])
disp(['TROPOMI time at location: ', char(datetime(tropomi_time, 'TimeZone', plot_timezone))])


lw = 2;
font_size = 20;
resolution = 300;
dim = [0, 0, 1200, 900];
xbounds = [400 465];

% Radiance Comparison
create_and_save_fig(pad_matrix(tempo_wl,tropomi_wl), pad_matrix(tempo_rad,tropomi_rad), save_path, 'radiance_comparison',...
     'TEMPO TROPOMI Radiance Comparison',  {'TEMPO', 'TROPOMI'}, 'Wavelength (nm)', 'Radiance (ph/s/cm^2/nm/sr)', xbounds)

% Iradiance Comparison
create_and_save_fig(pad_matrix(tempo_wl,tropomi_wl), pad_matrix(tempo_irrad,tropomi_irrad), save_path, 'irradiance_comparison',...
    'TEMPO TROPOMI Irradiance Comparison',  {'TEMPO', 'TROPOMI'}, 'Wavelength (nm)', 'Irradiance (ph/s/cm^2/nm)', xbounds)

% Reflectance Comparison
create_and_save_fig(pad_matrix(tempo_wl,tropomi_wl), pad_matrix(tempo_r,tropomi_r), save_path, 'reflectance_comparison',...
    'TEMPO TROPOMI Reflectance Comparison',  {'TEMPO', 'TROPOMI'}, 'Wavelength (nm)', 'Reflectance', xbounds)
