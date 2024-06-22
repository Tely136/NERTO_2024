clearvars; clc; close all;
addpath('functions/')

tempo_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
tropomi_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tempo_rad_table_path);
load(tropomi_rad_table_path);

plot_timezone = 'America/New_York';

conversion_factor = 6.022 .* 10.^19; % convert from mol/m^2 to particle/cm^2

start_day = 13; start_month = 5; start_year = 2024;
end_day = 1; end_month = 6; end_year = 2024;

start_date = datetime(start_year, start_month, start_day, 'TimeZone', plot_timezone);
start_date_utc = datetime(start_year, start_month, start_day, 'TimeZone', 'UTC');

end_date = datetime(end_year, end_month, end_day, 'TimeZone', plot_timezone);
end_date_utc = datetime(end_year, end_month, end_day, 23, 59, 59, 'TimeZone', 'UTC');


time_threshold = minutes(30);

baltimore_lat = 39.3; baltimore_lon = -76.6;

lat_range = [38.75 39.75];
lon_range = [-77.25 -76.25];

lat_inc = 0.1;
lon_inc = 0.1;
[lat_grid, lon_grid] = create_grid(lat_range, lon_range, lat_inc, lon_inc);


tempo_no2_files = tempo_files_table(strcmp(tempo_files_table.Product,'NO2') & tempo_files_table.Date>=start_date_utc & ...
    tempo_files_table.Date<=end_date_utc,:);

tropomi_no2_files = tropomi_files_table(strcmp(tropomi_files_table.Product,'NO2') & tropomi_files_table.Date>=start_date_utc & ...
    tropomi_files_table.Date<=end_date_utc,:);

% loop through each no2 file, get no2, sza, vza at baltimore, and plot bias as function of angle difference
% loop over tropomi no2, check for tempo no2 within a time range

% I need to change this to look at all pixels within a certain area, not just a point

no2_diff = NaN(0);
sza_diff = NaN(0);
vza_diff = NaN(0);

for i = 1:size(tropomi_no2_files,1)
    trop_filename = tropomi_no2_files.Filename(i);

    disp(['Starting TROPOMI file: ', num2str(i), ' out of ', num2str(size(tropomi_no2_files,1))])

    trop_data = read_tropomi_netcdf(trop_filename, lat_range, lon_range);
    if isempty(trop_data)
        continue
    end
    trop_no2 = trop_data.no2 .* conversion_factor;
    trop_lat = trop_data.lat;
    trop_lon = trop_data.lon;
    trop_sza = trop_data.sza;
    trop_vza = trop_data.vza;
    trop_qa = trop_data.qa;
    trop_time = trop_data.time;

    trop_data_point = read_tropomi_netcdf(trop_filename, baltimore_lat, baltimore_lon);
    % trop_point_lat = trop_data_point.lat
    % trop_point_lon = trop_data_point.lon
    trop_point_time = trop_data_point.time;

    trop_no2(trop_qa < 0.75) = NaN;

    trop_no2_interp = regrid(trop_lat, trop_lon, trop_no2, lat_grid, lon_grid);
    trop_sza_interp = regrid(trop_lat, trop_lon, trop_sza, lat_grid, lon_grid);
    trop_vza_interp = regrid(trop_lat, trop_lon, trop_vza, lat_grid, lon_grid);

    % make_map_fig(trop_lat, trop_lon, trop_sza, lat_range, lon_range, '/mnt/disks/data-disk/NERTO_2024/test1', 'original data')
    % make_map_fig(lat_grid, lon_grid, trop_sza_interp, lat_range, lon_range, '/mnt/disks/data-disk/NERTO_2024/test2', 'regridded data')

    % loop over tempo no2 within the set time bound
    for j = 1:size(tempo_no2_files,1)
        tempo_filename = tempo_no2_files.Filename(j);

        tempo_data_point = read_tempo_netcdf(tempo_filename, baltimore_lat, baltimore_lon);
        tempo_point_time = tempo_data_point.time;

        if abs(tempo_point_time - trop_point_time) < time_threshold
            tempo_data = read_tempo_netcdf(tempo_filename, lat_range, lon_range);
            tempo_no2 = tempo_data.no2;
            tempo_lat = tempo_data.lat;
            tempo_lon = tempo_data.lon;
            tempo_sza = tempo_data.sza;
            tempo_vza = tempo_data.vza;
            tempo_qa = tempo_data.qa;
            tempo_time = tempo_data.time;

            tempo_no2(tempo_qa~=0) = NaN;

            tempo_no2_interp = regrid(tempo_lat, tempo_lon, tempo_no2, lat_grid, lon_grid);
            tempo_sza_interp = regrid(tempo_lat, tempo_lon, tempo_sza, lat_grid, lon_grid);
            tempo_vza_interp = regrid(tempo_lat, tempo_lon, tempo_vza, lat_grid, lon_grid);


            temp_no2_diff = tempo_no2_interp(:) - trop_no2_interp(:);
            temp_sza_diff = tempo_sza_interp(:) - trop_sza_interp(:);
            temp_vza_diff = tempo_vza_interp(:) - trop_vza_interp(:);

            no2_diff = [no2_diff; temp_no2_diff];
            sza_diff = [sza_diff; temp_sza_diff];
            vza_diff = [vza_diff; temp_vza_diff];
        end
    end

end

%%
lw = 2;
font_size = 20;
resolution = 300;
dim = [0, 0, 1200, 900];
save_path = '/mnt/disks/data-disk/figures/no2_bias';

fig = figure('Visible','off', 'Position', dim);

hold on;

scatter(sza_diff, no2_diff, 'LineWidth', 1)
scatter(vza_diff, no2_diff, 'LineWidth', 1)

hold off;

xlabel('Angle difference (TEMPO - TROPOMI) [degrees]')
ylabel({'Tropospheric NO2 Column Difference', '(TEMPO - TROPOMI) [molec/cm^2]'})

legend('Solar Zenith Angle', 'Viewing Zenith Angle')

fontsize(font_size, 'points')

file_path = fullfile(save_path, 'bias');
print(fig, file_path, '-dpng', ['-r' num2str(resolution)])

close(fig);





