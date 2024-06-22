function t = is_within_bounds(lat_point, lon_point, filename)
    % Check min and max longitude at the latitude of the point

    lat_grid = ncread(filename, '/PRODUCT/latitude');
    lon_grid = ncread(filename, '/PRODUCT/longitude');

    [r, c] = find_nearest_pixel(lat_point, lon_point, lat_grid, lon_grid)

    % lat_center = ncread(filename, '/PRODUCT/latitude', [r, c, 1], [1, 1, 1]);
    % lon_center= ncread(filename, '/PRODUCT/longitude', [r, c, 1], [1, 1, 1]);

    if r == 1 || c == 1
        t = false;
    else
        t = true;
    end
    
end
