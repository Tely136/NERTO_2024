function [rows, cols] = get_indices(file, lat_bounds, lon_bounds)
    filename = file.Filename;

    if contains(filename, 'tropomi')
        switch file.Product
            case 'NO2'
                lat_grid = ncread(filename, '/PRODUCT/latitude');
                lon_grid = ncread(filename, '/PRODUCT/longitude');

            case 'RA'
                lat_grid = ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/latitude');
                lon_grid = ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/longitude');
        end

    elseif contains(filename, 'tempo')
        switch file.Product
            case 'NO2'
                lat_grid = ncread(filename, '/geolocation/latitude');
                lon_grid = ncread(filename, '/geolocation/longitude');

            case 'RAD'
                lat_grid = ncread(filename, '/band_290_490_nm/latitude');
                lon_grid = ncread(filename, '/band_290_490_nm/longitude');
        end
    end

    if is_within_bounds(lat_bounds, lon_bounds, lat_grid, lon_grid)

        if isscalar(lat_bounds) && isscalar(lon_bounds)
            [row, col] = find_nearest_pixel(lat_bounds, lon_bounds, lat_grid, lon_grid);

            rows = [row, row];
            cols = [col, col];

        elseif length(lat_bounds) ==2 & length(lon_bounds) == 2
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

    else
        rows = [];
        cols = [];
    end
end