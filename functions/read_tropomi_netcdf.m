function tropomi_data = read_tropomi_netcdf(file, rows, cols)
    arguments
        file
        rows = []
        cols = []
    end

    filename = file.Filename;
    product = file.Product;

    if isempty(rows) & isempty(cols)
        % load all
        start_row = 1;
        start_col = 1;

        dim = ncinfo(filename, '/PRODUCT/latitude').Size;

        row_inc = dim(1);
        col_inc = dim(2);
    else
        start_row = rows(1);
        start_col = cols(1);

        row_inc = rows(2) - rows(1) + 1;
        col_inc = cols(2) - cols(1) + 1;
    end

    tropomi_data = struct;
    switch product
        case 'NO2'
            no2 = ncread(filename, '/PRODUCT/nitrogendioxide_tropospheric_column', [start_row, start_col 1], [row_inc, col_inc 1]);
            no2_u = ncread(filename, '/PRODUCT/nitrogendioxide_tropospheric_column_precision', [start_row, start_col 1], [row_inc, col_inc 1]); % precision
            lat = ncread(filename, '/PRODUCT/latitude', [start_row, start_col 1], [row_inc, col_inc 1]);
            lon = ncread(filename, '/PRODUCT/longitude', [start_row, start_col 1], [row_inc, col_inc 1]);
            lat_corners = ncread(filename, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/latitude_bounds', [1 start_row, start_col 1], [4 row_inc, col_inc 1]);
            lon_corners = ncread(filename, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/longitude_bounds', [1 start_row, start_col 1], [4 row_inc, col_inc 1]);
            sza = ncread(filename, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/solar_zenith_angle', [start_row, start_col 1], [row_inc, col_inc 1]);
            vza = ncread(filename, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/viewing_zenith_angle', [start_row, start_col 1], [row_inc, col_inc 1]);
            qa = ncread(filename, '/PRODUCT/qa_value', [start_row, start_col 1], [row_inc, col_inc 1]);
            time = ncread(filename, '/PRODUCT/time_utc', [start_col, 1], [col_inc, 1]); 
            time = datetime(time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z''', 'TimeZone', 'UTC');

            tropomi_data.no2 = no2;
            tropomi_data.no2_u = no2_u;
            tropomi_data.lat = lat;
            tropomi_data.lon = lon;
            tropomi_data.lat_corners = lat_corners;
            tropomi_data.lon_corners = lon_corners;
            tropomi_data.sza = sza;
            tropomi_data.vza = vza;
            tropomi_data.qa = qa;
            tropomi_data.time = time;

        case 'RA'
            rad = ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/OBSERVATIONS/radiance', [1, start_row, start_col, 1], [497, row_inc, col_inc, 1]);
            wl = ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/INSTRUMENT/nominal_wavelength', [1 start_row 1], [497 row_inc 1]); %  replace with calibrated wavelengths
            lat = ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/latitude', [start_row start_col 1], [row_inc, col_inc 1]);
            lon = ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/longitude', [start_row start_col 1], [row_inc, col_inc 1]);
            sza = ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/solar_zenith_angle', [start_row, start_col 1], [row_inc, col_inc 1]);
            vza = ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/GEODATA/viewing_zenith_angle', [start_row, start_col 1], [row_inc, col_inc 1]);
            deltatime = ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/OBSERVATIONS/delta_time', [start_col 1], [col_inc 1]); 
            time = datetime(ncread(filename, '/BAND4_RADIANCE/STANDARD_MODE/OBSERVATIONS/time'), 'ConvertFrom', 'epochtime', 'Epoch', datetime(2010,1,1,0,0,0, 'TimeZone', 'UTC'));
            time = datetime(deltatime ./ 1000, 'ConvertFrom', 'epochtime', 'Epoch', datetime(time, 'Format', 'uuuuMMdd''T''HHmmss'), 'TimeZone', 'UTC');

            tropomi_data.rad = rad;
            tropomi_data.wl = wl;
            tropomi_data.lat = lat;
            tropomi_data.lon = lon;
            tropomi_data.sza = sza;
            tropomi_data.vza = vza;
            tropomi_data.time = time;

        case 'IR'
            irrad = ncread(filename, '/BAND4_IRRADIANCE/STANDARD_MODE/OBSERVATIONS/irradiance', [1 start_row 1 1], [497 row_inc 1 1]);
            wl = ncread(filename, '/BAND4_IRRADIANCE/STANDARD_MODE/INSTRUMENT/calibrated_wavelength', [1 start_row 1], [497 row_inc 1]);

            tropomi_data.irrad = irrad;
            tropomi_data.wl = wl;
    end
end
