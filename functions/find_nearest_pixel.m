function [r, c] = find_nearest_pixel(lat_point, lon_point, lat_grid, lon_grid)

    [arclen, ~] = distance(lat_grid, lon_grid, lat_point, lon_point);
    [~, min_i] = min(arclen(:));
    [r, c] = ind2sub(size(arclen), min_i);

end
