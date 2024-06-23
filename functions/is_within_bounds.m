function t = is_within_bounds(lat_point, lon_point, lat_grid, lon_grid)
    % Check min and max longitude at the latitude of the point
    
    [r, c] = find_nearest_pixel(lat_point, lon_point, lat_grid, lon_grid);


    if r == 1 || c == 1
        t = false;
    else
        t = true;
    end
    
end
