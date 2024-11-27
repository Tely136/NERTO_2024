clc; clearvars;

lat_bounds = [40 41.5];
lon_bounds = [-74.5 -73];
% lat_bounds = [40 43];
% lon_bounds = [-76 -71];

tempo_path = "C:\NERTO_drive\TEMPO_data";
tempo_file1 = "\TEMPO_NO2_L2_V03_20240525T161528Z_S008G03.nc";
tempo_file2 = "TEMPO_NO2_L2_V03_20240525T171528Z_S009G03.nc";

tempo_fullpath = fullfile(tempo_path, tempo_file1);

no21 = ncread(tempo_fullpath, '/product/vertical_column_troposphere');
lat1 = ncread(tempo_fullpath, '/geolocation/latitude');
lon1 = ncread(tempo_fullpath, '/geolocation/longitude');

tempo_fullpath = fullfile(tempo_path, tempo_file2);

no22 = ncread(tempo_fullpath, '/product/vertical_column_troposphere');
lat2 = ncread(tempo_fullpath, '/geolocation/latitude');
lon2 = ncread(tempo_fullpath, '/geolocation/longitude');

no2 = cat(3,no21,no22);
lat = cat(3,lat1,lat2);
lon = cat(3,lon1,lon2);

no2 = no2(:,:,1);
lat = lat(:,:,1);
lon = lon(:,:,1);

%%

subset_size = km2deg(100); % degrees
L = km2deg(30); 


% ind = lat >= lat_bounds(1) & lat <= lat_bounds(2) & lon >= lon_bounds(1) & lon <= lon_bounds(2);
% [row_ind, col_ind, ~] = ind2sub(size(ind), find(ind));
% 
% subset_rows = min(row_ind):max(row_ind);
% subset_cols = min(col_ind):max(col_ind);
% no2_new = no2(subset_rows,subset_cols,:);
% lat_new = lat(subset_rows,subset_cols,:);
% lon_new = lon(subset_rows,subset_cols,:);




%%

n = numel(lat);

corr_area = ceil(2*L/km2deg(2));
[rows, cols] = ind2sub(size(lat), find(lat));

% for i = 1:n
for i = 100000:n

    current_lat = lat(i);
    current_lon = lon(i);
    
    % sub_rows = rows(i)-corr_area:rows(i)+corr_area;
    % sub_cols = cols(i)-corr_area:cols(i)+corr_area;
    % 
    % sub_rows(sub_rows<1) = [];
    % sub_cols(sub_cols<1) = [];
    % 
    % sub_rows(sub_rows>size(lat,1)) = [];
    % sub_cols(sub_cols>size(lat,2)) = [];

    % sub_lat = lat(sub_rows, sub_cols);
    % sub_lon = lon(sub_rows, sub_cols);
    % sub_no2 = no2(sub_rows, sub_cols);

    sub_ind = rows>=rows(i)-corr_area & rows<=rows(i)+corr_area...
        & cols>=cols(i)-corr_area & cols<=cols(i)+corr_area;

    sub_lat = lat(sub_ind);
    sub_lon = lon(sub_ind);
    sub_no2 = no2(sub_ind);

    distances = distance(current_lat, current_lon, sub_lat, sub_lon);
    distances = gaspari_cohn(distances./L);

    break
end

%%
close all

% figure('WindowStyle','docked')
% figure()
% 
% imagesc(distances)
% colormap('hot')
% colorbar

d = corr_area * km2deg(2);
lat_plot = NaN(size(lat));
lat_plot(sub_ind) = sub_lat;

lon_plot = NaN(size(lat));
lon_plot(sub_ind) = sub_lon;

no2_plot = NaN(size(lat));
no2_plot(sub_ind) = sub_no2;

d_plot = NaN(size(lat));
d_plot(sub_ind) = distances;

figure;
% usamap(lat_bounds, lon_bounds)
% usamap([lat(i)-d,lat(i)+d], [lon(i)-d,lon(i)+d])
usamap([lat(i)-5*d,lat(i)+5*d], [lon(i)-5*d,lon(i)+5*d])

hold on
% surfacem(sub_lat, sub_lon, sub_no2)
surfacem(lat_plot, lon_plot, d_plot)
% surfacem(lat, lon, no2)

scatterm(lat(i), lon(i))
hold off
