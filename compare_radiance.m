clearvars; clc; close all;
addpath('functions/')

tempo_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
tropomi_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tempo_rad_table_path);
load(tropomi_rad_table_path);

save_path = '/mnt/disks/data-disk/figures/radiance';

baltimore_lat = 39.3; baltimore_lon = -76.6;
newyork_lat = 40.5; newyork_lon = -74;

conversion_factor = 6.022 .* 10.^19; % convert from mol/s/m^2/nm/sr to ph/s/cm^2/nm/sr

day = 13;
month = 5;
year = 2024;

plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');

scan = 9; % change this to the scan closest to tropomi
granule = 3;

tempo_rad_table = tempo_files_table(strcmp(tempo_files_table.Product, 'RAD') & ...
    tempo_files_table.Date>=day_tz & tempo_files_table.Date<day_tz+days(1) & tempo_files_table.Scan==scan & ...
    tempo_files_table.Granule==granule,:);

tempo_irrad_table = tempo_files_table(strcmp(tempo_files_table.Product, 'IRR'), :); % get irradiance file nearest to radiance measurement

tempo_no2_table = tempo_files_table(strcmp(tempo_files_table.Product, 'NO2') & tempo_files_table.Date == tempo_rad_table.Date & tempo_files_table.Scan==tempo_rad_table.Scan & tempo_files_table.Granule == tempo_rad_table.Granule, :);

[~, y] = min(abs(tempo_rad_table.Date - tempo_irrad_table.Date));
tempo_irrad_table = tempo_irrad_table(y,:);

tropomi_rad_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'RA') & ...
    tropomi_files_table.Date>=day_tz & tropomi_files_table.Date<day_tz+days(1), :);

tropomi_rad_table = tropomi_rad_table(1,:);

tropomi_irrad_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'IR'),:);

tropomi_no2_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'NO2') & ...
    tropomi_files_table.Granule == tropomi_rad_table.Granule, :);

[~, y] = min(abs(tropomi_rad_table.Date - tropomi_irrad_table.Date));
tropomi_irrad_table = tropomi_irrad_table(y,:);

% Tempo
tempo_rad_filename = tempo_rad_table.Filename;
tempo_lat = ncread(tempo_rad_filename, '/band_290_490_nm/latitude');
tempo_lon = ncread(tempo_rad_filename, '/band_290_490_nm/longitude');

tempo_irrad_filename = tempo_irrad_table.Filename;
tempo_no2_filename = tempo_no2_table.Filename;

[baltimore_arclen, ~] = distance(tempo_lat, tempo_lon, baltimore_lat, baltimore_lon);
[newyork_arclen, ~] = distance(tempo_lat, tempo_lon, newyork_lat, newyork_lon);

[~, baltimore_min_i] = min(baltimore_arclen(:));
[~, newyork_min_i] = min(newyork_arclen(:));

[r_b, c_b] = ind2sub(size(baltimore_arclen), baltimore_min_i);
[r_n, c_n] = ind2sub(size(newyork_arclen), newyork_min_i);

% Load in needed values directly from netcdf
tempo_rad_b = ncread(tempo_rad_filename, '/band_290_490_nm/radiance', [1 r_b c_b], [1028 1 1]);
tempo_irrad_b = ncread(tempo_irrad_filename, '/band_290_490_nm/irradiance', [1 r_b, 1], [1028, 1, 1]);
tempo_sza_b = ncread(tempo_rad_filename, '/band_290_490_nm/solar_zenith_angle', [r_b, c_b], [1 1]);
tempo_vza_b = ncread(tempo_rad_filename, '/band_290_490_nm/viewing_zenith_angle', [r_b, c_b], [1 1]);
tempo_wl_b = ncread(tempo_rad_filename, '/band_290_490_nm/nominal_wavelength', [1 r_b], [1028 1]); %  replace with calibrated wavelengths
tempo_time_b = ncread(tempo_rad_filename, '/time', c_b, 1);
tempo_time_b = datetime(tempo_time_b, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06', 'TimeZone', 'UTC');
tempo_qa_b = ncread(tempo_no2_filename, '/product/main_data_quality_flag', [r_b, c_b], [1 1]);

tempo_rad_n = ncread(tempo_rad_filename, '/band_290_490_nm/radiance', [1 r_n c_n], [1028 1 1]);
tempo_irrad_n = ncread(tempo_irrad_filename, '/band_290_490_nm/irradiance', [1 r_n, 1], [1028, 1, 1]);
tempo_sza_n = ncread(tempo_rad_filename, '/band_290_490_nm/solar_zenith_angle', [r_n, c_n], [1 1]);
tempo_vza_n = ncread(tempo_rad_filename, '/band_290_490_nm/viewing_zenith_angle', [r_n, c_n], [1 1]);
tempo_wl_n = ncread(tempo_rad_filename, '/band_290_490_nm/nominal_wavelength', [1 r_n], [1028 1]); %  replace with calibrated wavelengths
tempo_time_n = ncread(tempo_rad_filename, '/time', c_n, 1);
tempo_time_n = datetime(tempo_time_n, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06', 'TimeZone', 'UTC');
tempo_qa_n = ncread(tempo_no2_filename, '/product/main_data_quality_flag', [r_n, c_n], [1 1]);

tempo_r_b = pi .* tempo_rad_b ./ (cosd(tempo_sza_b) .* tempo_irrad_b); % check if sza is per pixel
% tempo_r_b = pi .* tempo_rad_b ./ (cosd(tempo_sza_b) .* cosd(tempo_vza_b) .* tempo_irrad_b);
tempo_r_n = pi .* tempo_rad_n ./ (cosd(tempo_sza_n) .* tempo_irrad_n);


%% Tropomi
tropomi_rad_filename = tropomi_rad_table.Filename;
tropomi_lat = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/latitude');
tropomi_lon = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/longitude');

tropomi_irrad_filename = tropomi_irrad_table.Filename;
tropomi_no2_filename = tropomi_no2_table.Filename;

[baltimore_arclen, ~] = distance(tropomi_lat, tropomi_lon, baltimore_lat, baltimore_lon);
[newyork_arclen, ~] = distance(tropomi_lat, tropomi_lon, newyork_lat, newyork_lon);

[~, baltimore_min_i] = min(baltimore_arclen(:));
[~, newyork_min_i] = min(newyork_arclen(:));

[r_b, c_b] = ind2sub(size(baltimore_arclen), baltimore_min_i);
[r_n, c_n] = ind2sub(size(newyork_arclen), newyork_min_i);

tropomi_rad_b = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/OBSERVATIONS/radiance', [1, r_b, c_b, 1], [497, 1, 1, 1]) .* conversion_factor;
tropomi_irrad_b = ncread(tropomi_irrad_filename, '/BAND4_IRRADIANCE/STANDARD_MODE/OBSERVATIONS/irradiance', [1 r_b 1 1], [497 1 1 1]) .* conversion_factor;
tropomi_sza_b = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/solar_zenith_angle', [r_b c_b 1], [1 1 1]);
tropomi_vza_b = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/viewing_zenith_angle', [r_b c_b 1], [1 1 1]);
tropomi_wl_b = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/INSTRUMENT/nominal_wavelength', [1 r_b 1], [497 1 1]); %  replace with calibrated wavelengths
tropomi_time_b = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/OBSERVATIONS/delta_time', [c_b 1], [1 1]); 
tropomi_time_b = datetime(tropomi_time_b ./ 1000, 'ConvertFrom', 'epochtime', 'Epoch', datetime(day_utc, 'Format', 'uuuu-MM-dd'), 'TimeZone', 'UTC');
tropomi_qa_b = ncread(tropomi_no2_filename, '/PRODUCT/qa_value', [r_b c_b 1], [1 1 1]);

tropomi_rad_n = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/OBSERVATIONS/radiance', [1, r_n, c_n, 1], [497, 1, 1, 1]) .* conversion_factor;
tropomi_irrad_n = ncread(tropomi_irrad_filename, '/BAND4_IRRADIANCE/STANDARD_MODE/OBSERVATIONS/irradiance', [1 r_n 1 1], [497 1 1 1]) .* conversion_factor;
tropomi_sza_n = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/solar_zenith_angle', [r_n c_n 1], [1 1 1]);
tropomi_vza_n = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/viewing_zenith_angle', [r_n c_n 1], [1 1 1]);
tropomi_wl_n = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/INSTRUMENT/nominal_wavelength', [1 r_n 1], [497 1 1]); %  replace with calibrated wavelengths
tropomi_time_n = ncread(tropomi_rad_filename, '/BAND4_RADIANCE/STANDARD_MODE/OBSERVATIONS/delta_time', [c_n 1], [1 1]); 
tropomi_time_n = datetime(tropomi_time_n ./ 1000, 'ConvertFrom', 'epochtime', 'Epoch', datetime(day_utc, 'Format', 'uuuu-MM-dd'), 'TimeZone', 'UTC');
tropomi_qa_n = ncread(tropomi_no2_filename, '/PRODUCT/qa_value', [r_n c_n 1], [1 1 1]);

tropomi_r_b = pi .* tropomi_rad_b ./ (cosd(tropomi_sza_b) .* tropomi_irrad_b);
% tropomi_r_b = pi .* tropomi_rad_b ./ (cosd(tropomi_sza_b) .* cosd(tropomi_vza_b) .* tropomi_irrad_b);
tropomi_r_n = pi .* tropomi_rad_n ./ (cosd(tropomi_sza_n) .* tropomi_irrad_n);

%%
disp(['TEMPO QA at Baltimore: ', num2str(tempo_qa_b)])
disp(['TROPOMI QA at Baltimore: ', num2str(tropomi_qa_b)])

disp(['TEMPO QA at New York: ', num2str(tempo_qa_n)])
disp(['TROPOMI QA at New York: ', num2str(tropomi_qa_n)])

disp(['TEMPO time at Baltimore: ', char(datetime(tempo_time_b, 'TimeZone', plot_timezone))])
disp(['TROPOMI time at Baltimore: ', char(datetime(tropomi_time_b, 'TimeZone', plot_timezone))])

disp(['TEMPO time at New York: ', char(datetime(tempo_time_n, 'TimeZone', plot_timezone))])
disp(['TROPOMI time at New York: ', char(datetime(tropomi_time_n, 'TimeZone', plot_timezone))])

lw = 2;
font_size = 20;
resolution = 300;
dim = [0, 0, 1200, 900];
xbounds = [400 465];

% Baltimore Radiance Comparison
create_and_save_fig(pad_matrix(tempo_wl_b,tropomi_wl_b), pad_matrix(tempo_rad_b,tropomi_rad_b), save_path, 'baltimore_radiance_comparison',...
     'TEMPO TROPOMI Radiance Comparison - Baltimore',  {'TEMPO', 'TROPOMI'}, 'Wavelength (nm)', 'Radiance (ph/s/cm^2/nm/sr)', xbounds)

     % Baltimore Iradiance Comparison
create_and_save_fig(pad_matrix(tempo_wl_b,tropomi_wl_b), pad_matrix(tempo_irrad_b,tropomi_irrad_b), save_path, 'baltimore_irradiance_comparison',...
    'TEMPO TROPOMI Irradiance Comparison - Baltimore',  {'TEMPO', 'TROPOMI'}, 'Wavelength (nm)', 'Irradiance (ph/s/cm^2/nm)', xbounds)

% Baltimore Reflectance Comparison
create_and_save_fig(pad_matrix(tempo_wl_b,tropomi_wl_b), pad_matrix(tempo_r_b,tropomi_r_b), save_path, 'baltimore_reflectance_comparison',...
    'TEMPO TROPOMI Reflectance Comparison - Baltimore',  {'TEMPO', 'TROPOMI'}, 'Wavelength (nm)', 'Reflectance', xbounds)


% % New York Radiance Comparison
% create_and_save_fig(pad_matrix(tempo_wl_n,tropomi_wl_n), pad_matrix(tempo_rad_n,tropomi_rad_n), save_path, 'newyork_radiance_comparison',...
%     'TEMPO TROPOMI Radiance Comparison - New York City',  {'TEMPO', 'TROPOMI'}, 'Wavelength (nm)', 'Radiance (ph/s/cm^2/nm/sr)', xbounds)

% % New York Iradiance Comparison
% create_and_save_fig(pad_matrix(tempo_wl_n,tropomi_wl_n), pad_matrix(tempo_irrad_n,tropomi_irrad_n), save_path, 'newyork_irradiance_comparison',...
%    'TEMPO TROPOMI Irradiance Comparison - New York City',  {'TEMPO', 'TROPOMI'}, 'Wavelength (nm)', 'Iradiance (ph/s/cm^2/nm)', xbounds)

% % New York Reflectance Comparison
% create_and_save_fig(pad_matrix(tempo_wl_n,tropomi_wl_n), pad_matrix(tempo_r_n,tropomi_r_n), save_path, 'newyork_reflectance_comparison',...
%     'TEMPO TROPOMI Reflectance Comparison - New York City',  {'TEMPO', 'TROPOMI'}, 'Wavelength (nm)', 'Reflectance', xbounds)


%% Functions
% function create_and_save_fig(x_data, y_data, path, name, ttext, leg, xtext, ytext, xbound, ybound, dim)

%     arguments
%         x_data
%         y_data
%         path
%         name
%         ttext = []
%         leg = []
%         xtext = []
%         ytext = []
%         xbound = []
%         ybound = []
%         dim = []
%     end


%     lw = 2;
%     font_size = 20;
%     resolution = 300;

%     if isempty(dim)
%         dim = [0, 0, 1200, 900];
%     end

%     fig = figure('Visible', 'off', 'Position', dim);

%     hold on;
%     for i = 1:size(x_data,2)
%         temp_x = x_data(:,i);
%         temp_y = y_data(:,i);

%         plot(temp_x, temp_y, 'LineWidth', lw)
%     end
%     hold off;

%     if ~isempty(xbound)
%         xlim(xbound)
%     end

%     if ~isempty(ybound)
%         ylim(ybound)
%     end

%     if ~isempty(leg)
%         legend(leg, 'Location', 'southwest')
%     end
    
%     if ~isempty(ttext)
%         title(ttext)
%     end
    
%     if ~isempty(xtext)
%         xlabel(xtext)
%     end
    
%     if ~isempty(ytext)
%         ylabel(ytext)
%     end

%     fontsize(font_size, 'points')

%     save_path = fullfile(path, name);
%     print(fig, save_path, '-dpng', ['-r' num2str(resolution)])

%     close(fig);
% end

% function M = pad_matrix(A, B)
%     max_l = max(length(A), length(B));

%     A_padded = [A; nan(max_l - length(A), 1)];
%     B_padded = [B; nan(max_l - length(B), 1)];

%     M = [A_padded B_padded];
% end

