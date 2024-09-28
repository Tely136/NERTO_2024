clc; clearvars;

lat_bounds = [40 41.5];
lon_bounds = [-74.5 -73];


tempo_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TEMPO_data";
tempo_file = "\TEMPO_NO2_L2_V03_20240525T161528Z_S008G03.nc";
tempo_fullpath = fullfile(tempo_path, tempo_file);

tropomi_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TROPOMI_data";
tropomi_file = "\S5P_OFFL_L2__NO2____20240525T160624_20240525T174754_34281_03_020600_20240527T081504.nc";
tropomi_fullpath = fullfile(tropomi_path, tropomi_file);

tempo_no2 = ncread(tempo_fullpath, '/product/vertical_column_troposphere') .* 10^6 ./ conversion_factor('trop-tempo');
tempo_lat = ncread(tempo_fullpath, '/geolocation/latitude');
tempo_lon = ncread(tempo_fullpath, '/geolocation/longitude');
tempo_lat_corners = reshape(ncread(tempo_fullpath, '/geolocation/latitude_bounds'), 4,[]);
tempo_lon_corners = reshape(ncread(tempo_fullpath, '/geolocation/longitude_bounds'), 4,[]);

tempo_ind = tempo_lat>=lat_bounds(1) & tempo_lat<=lat_bounds(2) & tempo_lon>=lon_bounds(1) & tempo_lon<=lon_bounds(2);
[tempo_row, tempo_col] = ind2sub(size(tempo_lat), find(tempo_ind));
tempo_no2_crop = tempo_no2(tempo_ind);
tempo_lat_crop = tempo_lat(tempo_ind);
tempo_lon_crop = tempo_lon(tempo_ind);
tempo_lat_corners_crop = tempo_lat_corners(:,tempo_ind);
tempo_lon_corners_crop = tempo_lon_corners(:,tempo_ind);


trop_no2 = ncread(tropomi_fullpath, '/PRODUCT/nitrogendioxide_tropospheric_column') .* 10^6;
trop_lat = ncread(tropomi_fullpath, '/PRODUCT/latitude');
trop_lon = ncread(tropomi_fullpath, '/PRODUCT/longitude');
trop_lat_corners = reshape(ncread(tropomi_fullpath, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/latitude_bounds'), 4, []);
trop_lon_corners = reshape(ncread(tropomi_fullpath, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/longitude_bounds'), 4, []);

trop_ind = trop_lat>=lat_bounds(1) & trop_lat<=lat_bounds(2) & trop_lon>=lon_bounds(1) & trop_lon<=lon_bounds(2);
[trop_row, trop_col] = ind2sub(size(trop_lat), find(trop_ind));
trop_no2_crop = trop_no2(trop_ind);
trop_lat_crop = trop_lat(trop_ind);
trop_lon_crop = trop_lon(trop_ind);
trop_lat_corners_crop = trop_lat_corners(:,trop_ind);
trop_lon_corners_crop = trop_lon_corners(:,trop_ind);

interpolation_struct = struct;
interpolation_struct.tempo_lat = tempo_lat_crop;
interpolation_struct.tempo_lon = tempo_lon_crop;
interpolation_struct.tempo_lat_corners = tempo_lat_corners_crop;
interpolation_struct.tempo_lon_corners = tempo_lon_corners_crop;
interpolation_struct.tempo_time = repmat(datetime('today'), size(tempo_lat_crop));

interpolation_struct.trop_lat = trop_lat_crop;
interpolation_struct.trop_lon = trop_lon_crop;
interpolation_struct.trop_lat_corners = trop_lat_corners_crop;
interpolation_struct.trop_lon_corners = trop_lon_corners_crop;
interpolation_struct.trop_time = repmat(datetime('today'), size(tempo_lat_crop));

interpolation_struct.time_window = minutes(30);
interpolation_struct.search_area = 0.1;

H = interpolation_operator(interpolation_struct, 'mean');

tempo_interp = H * tempo_no2_crop(:);
tempo_interp_plot = NaN(size(trop_no2));
tempo_interp_plot(trop_ind) = tempo_interp;

NY_counties = readgeotable('cb_2023_36_cousub_500k.shp');
clim = [0 500];

close all;

figure('WindowState', 'maximized');
tiledlayout(2,2)
nexttile
usamap(lat_bounds, lon_bounds);
surfacem(tempo_lat, tempo_lon, tempo_no2)
geoshow(NY_counties, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', 1);
ax = gca;
ax.CLim = clim;

nexttile
usamap(lat_bounds, lon_bounds);
surfacem(trop_lat, trop_lon, trop_no2)
geoshow(NY_counties, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', 1);
ax = gca;
ax.CLim = clim;

nexttile
usamap(lat_bounds, lon_bounds);
surfacem(trop_lat, trop_lon, tempo_interp_plot)
geoshow(NY_counties, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', 1);
ax = gca;
ax.CLim = clim;


