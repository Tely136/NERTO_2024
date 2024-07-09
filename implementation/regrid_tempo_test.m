clc; clearvars; close all; 

tempo_files = tempo_table('/mnt/disks/data-disk/data/tempo_data');
tempo_files = tempo_files(strcmp(tempo_files.Product,'NO2'),:);
latbounds = [39 40];
lonbounds = [-77 -76];

cellsize = 0.02;
[latgrid, longrid] = create_grid(latbounds, lonbounds, cellsize, cellsize);

file = tempo_files(2,:);
[rows, cols] = get_indices(file, latbounds, lonbounds);
tempo_data = read_tempo_netcdf(file, rows, cols);
lat = tempo_data.lat;
lon = tempo_data.lon;
lat_corners = tempo_data.lat_corners;
lon_corners = tempo_data.lon_corners;
no2 = tempo_data.no2;
no2_u = tempo_data.no2_u;


%% Function start

num_rows = size(latgrid,1);
num_cols = size(latgrid,2);
new_data = nan(num_rows, num_cols);

old_rows = size(lat,1);
old_cols = size(lat,2);
valid_pixel = find(~isnan(lat) & ~isnan(lon));

grid_lat_spacing = latgrid(1,2) - latgrid(1,1);
grid_lon_spacing = longrid(2,1) - longrid(1,1);

H = zeros((num_rows-1)*(num_cols-1), length(new_data(:)));

count = 1;
for i = 1:num_rows-1
    for j = 1:num_cols-1

        grid_lats = [latgrid(i,j) latgrid(i,j+1) latgrid(i+1,j+1) latgrid(i+1,j) latgrid(i,j)];
        grid_lons = [longrid(i,j) longrid(i,j+1) longrid(i+1,j+1) longrid(i+1,j) longrid(i,j)];


        [sub_rows, sub_cols] = get_indices2(lat, lon, [latgrid(i,j)-grid_lat_spacing latgrid(i+1,j+1)+grid_lat_spacing], [longrid(i,j)-grid_lon_spacing longrid(i+1,j+1)+grid_lon_spacing]);
        if ~isempty(sub_rows) & ~isempty(sub_cols)
            sub_lat = lat(sub_rows(1):sub_rows(2), sub_cols(1):sub_cols(2));
            sub_lon = lon(sub_rows(1):sub_rows(2), sub_cols(1):sub_cols(2));
            sub_no2 = no2(sub_rows(1):sub_rows(2), sub_cols(1):sub_cols(2));
            sub_lat_corners = lat_corners(:,sub_rows(1):sub_rows(2), sub_cols(1):sub_cols(2));
            sub_lon_corners = lon_corners(:,sub_rows(1):sub_rows(2), sub_cols(1):sub_cols(2));
            valid_pixel = find(~isnan(sub_lat) & ~isnan(sub_lon));
    
            old_rows = size(sub_lat,1);
            old_cols = size(sub_lat,2);
    
            intersections = nan(old_rows, old_cols);
            for k = 1:length(valid_pixel)
                [l,m] = ind2sub([old_rows, old_cols], valid_pixel(k));
                pixel_lats = flip(sub_lat_corners(:,l,m));
                pixel_lons = flip(sub_lon_corners(:,l,m));
    
                temp_pixel_lats = [pixel_lats(1) pixel_lats(2) pixel_lats(3) pixel_lats(4) pixel_lats(1)];
                temp_pixel_lons = [pixel_lons(1) pixel_lons(2) pixel_lons(3) pixel_lons(4) pixel_lons(1)];
    
                temp_pixel_lats(isnan(temp_pixel_lats)) = [];
                temp_pixel_lons(isnan(temp_pixel_lons)) = [];
    
                if check_intersection(temp_pixel_lats, temp_pixel_lons, grid_lats, grid_lons)
                    intersections(l,m) = 1;
    
                elseif inpolygon(temp_pixel_lats, temp_pixel_lons, grid_lats, grid_lons)
                    intersections(l,m) = 1;
    
                end
            end
            new_data(i,j) = mean(sub_no2(intersections==1));

        end

        count = count + 1;
        disp(num2str(100 * (count-1) / ((num_rows-1)*(num_cols-1))))
    end
end


%%
close all
clim = [0 10^16];

fig = tiledlayout(1,2);
nexttile
ax = worldmap(latbounds, lonbounds);
surfm(lat, lon, no2)
ax.CLim = clim;

nexttile
ax = worldmap(latbounds, lonbounds);
surfm(latgrid, longrid, new_data)
ax.CLim = clim;

cb = colorbar;
cb.Layout.Tile = 'east';


%%

function is_intersecting = check_intersection(lat1, lon1, lat2, lon2)
    [xi, yi] = polyxpoly(lat1, lon1, lat2, lon2);

    is_intersecting = ~isempty(xi) & ~isempty(yi);
end


