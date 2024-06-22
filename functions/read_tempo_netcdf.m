function tempo_data = read_tempo_netcdf(filename, lat_bounds, lon_bounds)
    lat_grid = ncread(filename, '/geolocation/latitude');
    lon_grid = ncread(filename, '/geolocation/longitude');


    if isscalar(lat_bounds) && isscalar(lon_bounds)
        [row, col] = find_nearest_pixel(lat_bounds, lon_bounds, lat_grid, lon_grid);

        tempo_lat = ncread(filename, '/geolocation/latitude', [row, col], [1 1]);
        tempo_lon = ncread(filename, '/geolocation/longitude', [row, col], [1 1]);
        tempo_no2 = ncread(filename, '/product/vertical_column_troposphere', [row, col], [1 1]); %molec/cm^2
        tempo_sza = ncread(filename, '/geolocation/solar_zenith_angle', [row, col], [1 1]);
        tempo_vza = ncread(filename, '/geolocation/viewing_zenith_angle', [row, col], [1 1]);
        tempo_qa = ncread(filename, '/product/main_data_quality_flag', [row, col], [1 1]);
        tempo_time = ncread(filename, '/geolocation/time', col, 1); 
        tempo_time = datetime(tempo_time, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06', 'TimeZone', 'UTC');

    elseif length(lat_bounds) ==2 & length(lon_bounds) == 2
        % Find the indices of the grid points within the specified bounds
        [lat_indices, lon_indices] = find(lat_grid >= lat_bounds(1) & lat_grid <= lat_bounds(2) & ...
            lon_grid >= lon_bounds(1) & lon_grid <= lon_bounds(2));

        % Extract the bounding box for the subgrid
        min_row = min(lat_indices);
        max_row = max(lat_indices);
        min_col = min(lon_indices);
        max_col = max(lon_indices);

        % Read the data from the netCDF file for the subgrid
        tempo_lat = ncread(filename, '/geolocation/latitude', [min_row, min_col], [max_row - min_row + 1, max_col - min_col + 1]);
        tempo_lon = ncread(filename, '/geolocation/longitude', [min_row, min_col], [max_row - min_row + 1, max_col - min_col + 1]);
        tempo_no2 = ncread(filename, '/product/vertical_column_troposphere', [min_row, min_col], [max_row - min_row + 1, max_col - min_col + 1]); % molec/cm^2
        tempo_sza = ncread(filename, '/geolocation/solar_zenith_angle', [min_row, min_col], [max_row - min_row + 1, max_col - min_col + 1]);
        tempo_vza = ncread(filename, '/geolocation/viewing_zenith_angle', [min_row, min_col], [max_row - min_row + 1, max_col - min_col + 1]);
        tempo_qa = ncread(filename, '/product/main_data_quality_flag', [min_row, min_col], [max_row - min_row + 1, max_col - min_col + 1]);
        tempo_time = ncread(filename, '/geolocation/time', min_col, max_col - min_col + 1); 
        tempo_time = datetime(tempo_time, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06', 'TimeZone', 'UTC');

    else
        error('Lat and lon dimensions are not correct')
    end

    tempo_data = struct;
    tempo_data.lat = tempo_lat;
    tempo_data.lon = tempo_lon;
    tempo_data.no2 = tempo_no2;
    tempo_data.sza = tempo_sza;
    tempo_data.vza = tempo_vza;
    tempo_data.qa = tempo_qa;
    tempo_data.time = tempo_time;
end