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


no2_diff = NaN(0);
sza_diff = NaN(0);
vza_diff = NaN(0);
S_diff = NaN(0);

for i = 1:size(tropomi_no2_files,1)
    tropomi_file = tropomi_no2_files(i,:);
    trop_filename = tropomi_no2_files.Filename(i);

    disp(['Starting TROPOMI file: ', num2str(i), ' out of ', num2str(size(tropomi_no2_files,1))])

    [rows, cols] = get_indices(tropomi_file, lat_range, lon_range);
    if isempty(rows) | isempty(cols)
        continue
    end

    trop_data = read_tropomi_netcdf(tropomi_file, rows, cols);

    trop_no2 = trop_data.no2 .* conversion_factor;
    trop_lat = trop_data.lat;
    trop_lon = trop_data.lon;
    trop_sza = trop_data.sza;
    trop_vza = trop_data.vza;
    trop_qa = trop_data.qa;
    trop_time = trop_data.time;

    [rows, cols] = get_indices(tropomi_file, baltimore_lat, baltimore_lon);
    trop_data_point = read_tropomi_netcdf(tropomi_file, rows, cols);
    trop_point_time = trop_data_point.time;

    trop_no2(trop_qa < 0.75) = NaN;

    trop_no2_interp = regrid(trop_lat, trop_lon, trop_no2, lat_grid, lon_grid);
    trop_sza_interp = regrid(trop_lat, trop_lon, trop_sza, lat_grid, lon_grid);
    trop_vza_interp = regrid(trop_lat, trop_lon, trop_vza, lat_grid, lon_grid);

    
    % loop over tempo no2 within the set time bound
    for j = 1:size(tempo_no2_files,1)
        tempo_file = tempo_no2_files(j,:);
        tempo_filename = tempo_no2_files.Filename(j);

        [rows, cols] = get_indices(tempo_file, baltimore_lat, baltimore_lon);
        tempo_data_point = read_tempo_netcdf(tempo_file, rows, cols);
        tempo_point_time = tempo_data_point.time;

        if abs(tempo_point_time - trop_point_time) < time_threshold

            [rows, cols] = get_indices(tempo_file, lat_range, lon_range);

            tempo_data = read_tempo_netcdf(tempo_file, rows, cols);
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

            tropomi_S = cosd(trop_sza_interp) + cosd(trop_vza_interp);
            tempo_S = cosd(tempo_sza_interp) + cosd(tempo_vza_interp);

            temp_no2_diff = tempo_no2_interp(:) - trop_no2_interp(:);
            temp_sza_diff = tempo_sza_interp(:) - trop_sza_interp(:);
            temp_vza_diff = tempo_vza_interp(:) - trop_vza_interp(:);
            temp_S_diff = tempo_S(:) - tropomi_S(:);
            

            no2_diff = [no2_diff; temp_no2_diff];
            sza_diff = [sza_diff; temp_sza_diff];
            vza_diff = [vza_diff; temp_vza_diff];
            S_diff = [S_diff; temp_S_diff];

        end
    end
end


% Bin data

bins = -50:10:50;

no2_avg_sza = NaN(length(bins)-1,1);
no2_avg_vza = NaN(length(bins)-1,1);
angle_bins = NaN(length(bins)-1,1);

for i = 1:length(bins)-1
    bin = bins(i);

    sza_indices = find(sza_diff>=bins(i) & sza_diff<bins(i+1));
    vza_indices = find(vza_diff>=bins(i) & vza_diff<bins(i+1));

    no2_avg_sza(i) = mean(no2_diff(sza_indices), 'omitmissing');
    no2_avg_vza(i) = mean(no2_diff(vza_indices), 'omitmissing');

    angle_bins(i) = median([bins(i), bins(i+1)]);
end


bins = -0.5:0.1:0.5;

length_bins = NaN(length(bins)-1,1);
no2_avg_S = NaN(length(bins)-1,1);

for i = 1:length(bins)-1
    bin = bins(i);

    S_indices = find(S_diff>=bins(i) & S_diff<bins(i+1));

    no2_avg_S(i) = mean(no2_diff(S_indices), 'omitmissing');

    length_bins(i) = median([bins(i), bins(i+1)]);
end


save_path = '/mnt/disks/data-disk/figures/no2_bias';

% Plot NO2 sifference as function of SZA and VZA difference seperately
create_and_save_fig_scatter([sza_diff vza_diff], [no2_diff no2_diff], save_path, 'bias', '', {'Solar Zenith Angle', 'Viewing Zenith Angle'}, 'Angle difference (TEMPO - TROPOMI) [degrees]', {'Tropospheric NO2 Column Difference', '(TEMPO - TROPOMI) [molec/cm^2]'})

% Plot NO2 sifference as function of SZA and VZA difference seperately (binned)
create_and_save_fig_scatter([angle_bins angle_bins], [no2_avg_sza no2_avg_vza], save_path, 'bias_binned', '', {'Solar Zenith Angle', 'Viewing Zenith Angle'}, 'Angle difference (TEMPO - TROPOMI) [degrees]', {'Tropospheric NO2 Column Difference', '(TEMPO - TROPOMI) [molec/cm^2]'})

% Plot NO2 sifference as function of total path length difference
create_and_save_fig_scatter(S_diff,  no2_diff, save_path, 'bias_S', '', 'S', 'S difference', {'Tropospheric NO2 Column Difference', '(TEMPO - TROPOMI) [molec/cm^2]'})

% Plot NO2 sifference as function of total path length difference (binned)
create_and_save_fig_scatter(length_bins,  no2_avg_S, save_path, 'bias_S_binned', '', 'S', 'S difference', {'Tropospheric NO2 Column Difference', '(TEMPO - TROPOMI) [molec/cm^2]'})

