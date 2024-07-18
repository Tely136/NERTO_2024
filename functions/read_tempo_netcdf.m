function tempo_data = read_tempo_netcdf(file, rows, cols)
    arguments
        file
        rows = [];
        cols = []
    end

    % conversion_factor = 6.022 .* 10.^19; % convert from mol/s/m^2/nm/sr to ph/s/cm^2/nm/sr

    filename = file.Filename;
    product = file.Product;

    if isempty(rows) & isempty(cols)
        % load all
        start_row = 1;
        start_col = 1;

        dim = ncinfo(filename, '/geolocation/latitude').Size;

        row_inc = dim(1);
        col_inc = dim(2);
    else
        start_row = rows(1);
        start_col = cols(1);

        row_inc = rows(2) - rows(1) + 1;
        col_inc = cols(2) - cols(1) + 1;
    end

    tempo_data = struct;
    switch product
        case 'NO2'
            % Read the data from the netCDF file for the subgrid
            no2 = ncread(filename, '/product/vertical_column_troposphere', [start_row, start_col], [row_inc, col_inc]); % molec/cm^2
            no2_u = ncread(filename, '/product/vertical_column_troposphere_uncertainty', [start_row, start_col], [row_inc, col_inc]); % uncertainty in molec/cm^2
            lat = ncread(filename, '/geolocation/latitude', [start_row, start_col], [row_inc, col_inc]);
            lon = ncread(filename, '/geolocation/longitude', [start_row, start_col], [row_inc, col_inc]);
            lat_corners = ncread(filename, '/geolocation/latitude_bounds', [1 start_row, start_col], [4 row_inc, col_inc]);
            lon_corners = ncread(filename, '/geolocation/longitude_bounds', [1 start_row, start_col], [4 row_inc, col_inc]);
            sza = ncread(filename, '/geolocation/solar_zenith_angle', [start_row, start_col], [row_inc, col_inc]);
            vza = ncread(filename, '/geolocation/viewing_zenith_angle', [start_row, start_col], [row_inc, col_inc]);
            qa = ncread(filename, '/product/main_data_quality_flag', [start_row, start_col], [row_inc, col_inc]);
            cld = ncread(filename, '/support_data/eff_cloud_fraction', [start_row, start_col], [row_inc, col_inc]);
            time = ncread(filename, '/geolocation/time', start_col, col_inc); 
            time = datetime(time, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06', 'TimeZone', 'UTC');

            tempo_data.no2 = no2;
            tempo_data.no2_u = no2_u;
            tempo_data.lat = lat;
            tempo_data.lon = lon;
            tempo_data.lat_corners = lat_corners;
            tempo_data.lon_corners = lon_corners;
            tempo_data.sza = sza;
            tempo_data.vza = vza;
            tempo_data.qa = qa;
            tempo_data.cld = cld;
            tempo_data.time = time;


        case 'RAD'
            rad = ncread(filename, '/band_290_490_nm/radiance', [1 start_row, start_col], [1028 row_inc, col_inc]);
            wl = ncread(filename, '/band_290_490_nm/nominal_wavelength', [1 start_row], [1028 row_inc]);
            lat = ncread(filename, '/band_290_490_nm/latitude', [start_row, start_col], [row_inc, col_inc]);
            lon = ncread(filename, '/band_290_490_nm/longitude', [start_row, start_col], [row_inc, col_inc]);
            sza = ncread(filename, '/band_290_490_nm/solar_zenith_angle', [start_row, start_col], [row_inc, col_inc]);
            vza = ncread(filename, '/band_290_490_nm/viewing_zenith_angle', [start_row, start_col], [row_inc, col_inc]);
            time = ncread(filename, '/time', start_col, col_inc); 
            time = datetime(time, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06', 'TimeZone', 'UTC');

            tempo_data.rad = rad;
            tempo_data.wl = wl;
            tempo_data.lat = lat;
            tempo_data.lon = lon;
            tempo_data.sza = sza;
            tempo_data.vza = vza;
            tempo_data.time = time;


        case 'IRR'
            irrad = ncread(filename, '/band_290_490_nm/irradiance', [1 start_row, 1], [1028 row_inc, 1]);
            wl = ncread(filename, '/band_290_490_nm/nominal_wavelength', [1 start_row], [1028 row_inc]);
            
            tempo_data.irrad = irrad;
            tempo_data.wl = wl;
    end
end


       

