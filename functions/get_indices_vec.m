function ind = get_indices_vec(lat_grid, lon_grid, lat_bounds, lon_bounds)

    % Find the indices of the grid points within the specified bounds
    ind = find(lat_grid >= lat_bounds(1) & lat_grid <= lat_bounds(2) & ...
        lon_grid >= lon_bounds(1) & lon_grid <= lon_bounds(2));

end