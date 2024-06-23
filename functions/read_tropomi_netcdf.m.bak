function tropomi_data = read_tropomi_netcdf(filename, lat_bounds, lon_bounds)
    lat_grid = ncread(filename, '/PRODUCT/latitude');
    lon_grid = ncread(filename, '/PRODUCT/longitude');

    if isscalar(lat_bounds) && isscalar(lon_bounds)

        if ~is_within_bounds(lat_bounds, lon_bounds, filename)
            tropomi_data = [];
            return

        else
            [row, col] = find_nearest_pixel(lat_bounds, lon_bounds, lat_grid, lon_grid);

            trop_lat = ncread(filename, '/PRODUCT/latitude', [row col 1], [1 1 1]);
            trop_lon = ncread(filename, '/PRODUCT/longitude', [row col 1], [1 1 1]);
            trop_no2 = ncread(filename, '/PRODUCT/nitrogendioxide_tropospheric_column', [row col 1], [1 1 1]); % mol/m^2
            trop_sza = ncread(filename, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/solar_zenith_angle', [row col 1], [1 1 1]);
            trop_vza = ncread(filename,'/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/viewing_zenith_angle', [row col 1], [1 1 1]);
            trop_qa = ncread(filename, '/PRODUCT/qa_value', [row col 1], [1 1 1]);
            trop_time = ncread(filename, '/PRODUCT/time_utc', [col 1], [1 1]); 
            trop_time = datetime(trop_time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z''', 'TimeZone', 'UTC');
        end
    elseif length(lat_bounds) ==2 & length(lon_bounds) == 2

        [lat_indices, lon_indices] = find(lat_grid >= lat_bounds(1) & lat_grid <= lat_bounds(2) & ...
                                      lon_grid >= lon_bounds(1) & lon_grid <= lon_bounds(2));

        % Extract the bounding box for the subgrid
        min_row = min(lat_indices);
        max_row = max(lat_indices);
        min_col = min(lon_indices);
        max_col = max(lon_indices);

        if isempty(lat_indices) || isempty(lon_indices)
            tropomi_data = [];
            return
        else
            % Read the data from the netCDF file for the subgrid
            trop_lat = ncread(filename, '/PRODUCT/latitude', [min_row, min_col, 1], [max_row - min_row + 1, max_col - min_col + 1, 1]);
            trop_lon = ncread(filename, '/PRODUCT/longitude', [min_row, min_col, 1], [max_row - min_row + 1, max_col - min_col + 1, 1]);
            trop_no2 = ncread(filename, '/PRODUCT/nitrogendioxide_tropospheric_column', [min_row, min_col, 1], [max_row - min_row + 1, max_col - min_col + 1, 1]); % mol/m^2
            trop_sza = ncread(filename, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/solar_zenith_angle', [min_row, min_col, 1], [max_row - min_row + 1, max_col - min_col + 1, 1]);
            trop_vza = ncread(filename,'/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/viewing_zenith_angle', [min_row, min_col, 1], [max_row - min_row + 1, max_col - min_col + 1, 1]);
            trop_qa = ncread(filename, '/PRODUCT/qa_value', [min_row, min_col, 1], [max_row - min_row + 1, max_col - min_col + 1, 1]);
            trop_time = ncread(filename, '/PRODUCT/time_utc', [min_col, 1], [max_col - min_col + 1, 1]); 
            trop_time = datetime(trop_time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z''', 'TimeZone', 'UTC');
        end
    else
        error('Lat and lon dimensions are not correct')
    end


    tropomi_data = struct;
    tropomi_data.lat = trop_lat;
    tropomi_data.lon = trop_lon;
    tropomi_data.no2 = trop_no2;
    tropomi_data.sza = trop_sza;
    tropomi_data.vza = trop_vza;
    tropomi_data.qa = trop_qa;
    tropomi_data.time = trop_time;
end
