close all; clc; clearvars;
set(0,'DefaultFigureWindowStyle','docked')

day = 20;
month = 5;
year = 2024;

plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');

tempo_files = tempo_table('/mnt/disks/data-disk/data/tempo_data');
tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2') & tempo_files.Date >= day_tz & tempo_files.Date < day_tz + days(1), :);
tropomi_files = tropomi_table('/mnt/disks/data-disk/data/tropomi_data/');
tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2') & tropomi_files.Date >= day_tz & tropomi_files.Date < day_tz + days(1), :);

data_save_path = '/mnt/disks/data-disk/data/merged_data';

% lat_bounds = [40 42]; % new york
% lon_bounds = [-75, -72];

lat_bounds = [39 40]; % maryland
lon_bounds = [-77 -76];

[latgrid, longrid] = create_grid(lat_bounds, lon_bounds, 0.2, 0.2);
n_rows = size(latgrid,1)-1;
n_cols = size(latgrid,2)-1;
lat_grid_corners = NaN(4,n_rows, n_cols);
lon_grid_corners = NaN(4,n_rows, n_cols);
lat_grid_center = NaN(n_rows, n_cols);
lon_grid_center = NaN(n_rows, n_cols);

for i = 1:n_rows
    for j = 1:n_cols
        lat_grid_corners(1,i,j) = latgrid(i,j);
        lat_grid_corners(2,i,j) = latgrid(i,j+1);
        lat_grid_corners(3,i,j) = latgrid(i+1,j+1);
        lat_grid_corners(4,i,j) = latgrid(i+1,j);

        lon_grid_corners(1,i,j) = longrid(i,j);
        lon_grid_corners(2,i,j) = longrid(i,j+1);
        lon_grid_corners(3,i,j) = longrid(i+1,j+1);
        lon_grid_corners(4,i,j) = longrid(i+1,j);

        lat_grid_center(i,j) = mean([latgrid(i,j) latgrid(i,j+1)]);
        lon_grid_center(i,j) = mean([longrid(i,j) longrid(i+1,j)]);
    end
end

lat_grid_center = lat_grid_center(:);
lon_grid_center = lon_grid_center(:);
lat_grid_corners = reshape(lat_grid_corners, 4, []);
lon_grid_corners = reshape(lon_grid_corners, 4, []);


temp_file = tempo_files(2,:);
tempo_temp_data = read_tempo_netcdf(temp_file);

tempo_no2 = tempo_temp_data.no2;
tempo_dim = size(tempo_no2);
tempo_no2 = tempo_no2(:);
tempo_lat = tempo_temp_data.lat(:);
tempo_lon = tempo_temp_data.lon(:);
tempo_lat_corners = reshape(tempo_temp_data.lat_corners, 4, []);
tempo_lon_corners = reshape(tempo_temp_data.lon_corners, 4, []);
tempo_qa = tempo_temp_data.qa(:);
tempo_no2_u = tempo_temp_data.no2_u(:);

tic;
H_regrid = interpolation_operator(tempo_lat, tempo_lon, tempo_lat_corners, tempo_lon_corners, lat_grid_center, lon_grid_center, lat_grid_corners, lon_grid_corners, 'mean');
time = toc;
disp(num2str(time))


lat_plt = reshape(tempo_lat, tempo_dim);
lon_plt = reshape(tempo_lon, tempo_dim);
no2_plt = reshape(tempo_no2, tempo_dim);

new_data = H_regrid * tempo_no2;
new_data = reshape(new_data, [n_rows, n_cols]);

%
figure;

subplot(1,2,1)
usamap(lat_bounds, lon_bounds)
surfm(lat_plt, lon_plt, no2_plt)

subplot(1,2,2)
usamap(lat_bounds, lon_bounds)
surfm(latgrid, longrid, new_data)
