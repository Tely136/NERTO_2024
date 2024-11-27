clc; clearvars;

lat_bounds = [38.75 41.3];
lon_bounds = [-77.5 -73.3];


% tempo_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TEMPO_data";
tempo_path = "C:\NERTO_drive\TEMPO_data";
tempo_file1 = "TEMPO_NO2_L2_V03_20240525T161528Z_S008G03.nc";
tempo_file2 = "TEMPO_NO2_L2_V03_20240525T171528Z_S009G03.nc";
tempo_file3 = "TEMPO_NO2_L2_V03_20240525T181528Z_S010G03.nc";

tempo_fullpath = fullfile(tempo_path, tempo_file1);

no21 = ncread(tempo_fullpath, '/product/vertical_column_troposphere');
lat1 = ncread(tempo_fullpath, '/geolocation/latitude');
lon1 = ncread(tempo_fullpath, '/geolocation/longitude');
step1 = ncread(tempo_fullpath, '/mirror_step');

tempo_fullpath = fullfile(tempo_path, tempo_file2);

no22 = ncread(tempo_fullpath, '/product/vertical_column_troposphere');
lat2 = ncread(tempo_fullpath, '/geolocation/latitude');
lon2 = ncread(tempo_fullpath, '/geolocation/longitude');
step2 = ncread(tempo_fullpath, '/mirror_step');

tempo_fullpath = fullfile(tempo_path, tempo_file3);

no23 = ncread(tempo_fullpath, '/product/vertical_column_troposphere');
lat3 = ncread(tempo_fullpath, '/geolocation/latitude');
lon3 = ncread(tempo_fullpath, '/geolocation/longitude');
step3 = ncread(tempo_fullpath, '/mirror_step');


no2 = cat(3,no21,no22,no23);
lat = cat(3,lat1,lat2,lat3);
lon = cat(3,lon1,lon2,lon3);
step = cat(3,step1,step2,step3);



subset_size = km2deg(100); % degrees
L = km2deg(30); 


lat_is = lat_bounds(1):subset_size:lat_bounds(2);
lon_is = lon_bounds(1):subset_size:lon_bounds(2);

if lat_is(end) < lat_bounds(2)
    lat_is(end+1) = lat_bounds(2);
end

if lon_is(end) < lon_bounds(2)
    lon_is(end+1) = lon_bounds(2);
end


lat_minus = lat_is - L;
lat_plus = lat_is + L;

lon_minus = lon_is - L;
lon_plus = lon_is + L;


[lat_grid, lon_grid] = meshgrid(lat_is, lon_is);
[lat_grid_m, lon_grid_m] = meshgrid(lat_minus, lon_minus);
[lat_grid_p, lon_grid_p] = meshgrid(lat_plus, lon_plus);

for lat_subset = 2:length(lat_is)-1
    for lon_subset = 2:length(lon_is)-1

        outer_ind = lat >= lat_minus(lat_subset) & lat <= lat_plus(lat_subset+1) ...
            & lon >= lon_minus(lon_subset) & lon <= lon_plus(lon_subset+1);

        [outer_rows, outer_cols, ~] = ind2sub(size(outer_ind), find(outer_ind));
        
        rows = min(outer_rows):max(outer_rows);
        cols = min(outer_cols):max(outer_cols);

        outer_lat = lat(rows,cols,:);
        outer_lon = lon(rows,cols,:);
        outer_no2 = no2(rows,cols,:);

        break
    end
end

lat_diff = lat_plus(lat_subset+1) - lat_minus(lat_subset);
lon_diff = lon_plus(lon_subset+1) - lon_minus(lon_subset);

%% 
 close all


figure('WindowStyle','docked');
usamap([39.5 44],[-76 -71])
% usamap([lat_minus(1) lat_plus(2)], [lon_minus(1) lon_plus(2)])
% surfacem(lat_sub, lon_sub, no2_sub)
hold on
% scatterm(lat_is, lon_is, 'green')
% scatterm(lat_minus, lon_minus, 'red')
% scatterm(lat_plus, lon_plus, 'blue')

% surfacem(inner_lat, inner_lon, inner_no2)
surfacem(outer_lat, outer_lon, outer_no2)

scatterm(lat_grid, lon_grid, 'green')
scatterm(lat_grid_m, lon_grid_m, 'red')
scatterm(lat_grid_p, lon_grid_p, 'red')

hold off