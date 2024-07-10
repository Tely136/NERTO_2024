function H = regrid(lat, lon, lat_corners, lon_corners, latgrid, longrid)

    n = numel(lat_corners(1,:,:));

    num_rows = size(latgrid,1);
    num_cols = size(latgrid,2);

    old_rows = size(lat_corners,2);
    old_cols = size(lat_corners,3);
    valid_pixel = find(~isnan(lat) & ~isnan(lon));

    grid_lat_spacing = latgrid(1,2) - latgrid(1,1);
    grid_lon_spacing = longrid(2,1) - longrid(1,1);

    H = zeros((num_rows)*(num_cols), n);

    for i = 1:num_rows-1
        for j = 1:num_cols-1
            v = sub2ind([num_rows, num_cols], i,j);

            grid_lats = [latgrid(i,j) latgrid(i,j+1) latgrid(i+1,j+1) latgrid(i+1,j) latgrid(i,j)];
            grid_lons = [longrid(i,j) longrid(i,j+1) longrid(i+1,j+1) longrid(i+1,j) longrid(i,j)];


            [sub_rows, sub_cols] = get_indices2(lat, lon, [latgrid(i,j)-grid_lat_spacing latgrid(i+1,j+1)+grid_lat_spacing], [longrid(i,j)-grid_lon_spacing longrid(i+1,j+1)+grid_lon_spacing]);
            if ~isempty(sub_rows) & ~isempty(sub_cols)
        
                intersections = nan(old_rows, old_cols);
                for l = sub_rows(1):sub_rows(2)
                    for m = sub_cols(1):sub_cols(2)
                        ind = sub2ind(size(lat), l, m);
                        if ismember(ind, valid_pixel)
                            pixel_lats = flip(lat_corners(:,l,m));
                            pixel_lons = flip(lon_corners(:,l,m));
                
                            temp_pixel_lats = [pixel_lats(1) pixel_lats(2) pixel_lats(3) pixel_lats(4) pixel_lats(1)];
                            temp_pixel_lons = [pixel_lons(1) pixel_lons(2) pixel_lons(3) pixel_lons(4) pixel_lons(1)];
                
                            temp_pixel_lats(isnan(temp_pixel_lats)) = [];
                            temp_pixel_lons(isnan(temp_pixel_lons)) = [];
                
                            if check_intersection(temp_pixel_lats, temp_pixel_lons, grid_lats, grid_lons) | inpolygon(temp_pixel_lats, temp_pixel_lons, grid_lats, grid_lons)
                                intersections(l,m) = 1;
                
                            end
                        end
                        
                        good = find(intersections==1);
                        for f=1:length(good)

                            H(v, good(f)) = 1 ./ numel(intersections(intersections==1));
                        end
                    end
                end
            end
        end
    end
end