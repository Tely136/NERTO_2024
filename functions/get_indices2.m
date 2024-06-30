function [rows, cols] = get_indices2(lat_grid, lon_grid, lat_bounds, lon_bounds)

    if isscalar(lat_bounds) && isscalar(lon_bounds)
        [row, col] = find_nearest_pixel(lat_bounds, lon_bounds, lat_grid, lon_grid);

        rows = [row, row];
        cols = [col, col];

        if row==1 || col==1
            rows = [];
            cols = [];
        end

    elseif length(lat_bounds) == 2 & length(lon_bounds) == 2
        % Find the indices of the grid points within the specified bounds
        [lat_indices, lon_indices] = find(lat_grid >= lat_bounds(1) & lat_grid <= lat_bounds(2) & ...
            lon_grid >= lon_bounds(1) & lon_grid <= lon_bounds(2));

        % Extract the bounding box for the subgrid
        min_row = min(lat_indices);
        max_row = max(lat_indices);
        min_col = min(lon_indices);
        max_col = max(lon_indices);

        rows = [min_row, max_row];
        cols = [min_col, max_col];
    end
end