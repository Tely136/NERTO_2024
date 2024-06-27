function tempo_data = read_gems_netcdf(file, rows, cols)

    % conversion_factor = 6.022 .* 10.^19; % convert from mol/s/m^2/nm/sr to ph/s/cm^2/nm/sr

    filename = file.Filename;
    product = file.Product;

    start_row = rows(1);
    start_col = cols(1);

    row_inc = rows(2) - rows(1) + 1;
    col_inc = cols(2) - cols(1) + 1;

    tempo_data = struct;
    switch product
        case 'NO2'
            % Read the data from the netCDF file for the subgrid
            no2 = ncread(filename, '/ScienceData/ScienceData/', [start_row, start_col], [row_inc, col_inc]); % molec/cm^2
            % no2_u = ncread(filename, '/product/vertical_column_troposphere_uncertainty', [start_row, start_col], [row_inc, col_inc]); % uncertainty in molec/cm^2
            lat = ncread(filename, '/GeolocationData/Latitude', [start_row, start_col], [row_inc, col_inc]);
            lon = ncread(filename, '/GeolocationData/Longitude', [start_row, start_col], [row_inc, col_inc]);
            sza = ncread(filename, '/GeolocationData/SolarZenithAngle', [start_row, start_col], [row_inc, col_inc]);
            vza = ncread(filename, '/GeolocationData/SolarZenithAngle', [start_row, start_col], [row_inc, col_inc]);
            qa = ncread(filename, '/ScienceData/PixelQualityFlags', [start_row, start_col], [row_inc, col_inc]);
            % time = ncread(filename, '/geolocation/time', start_col, col_inc); 
            % time = datetime(time, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06', 'TimeZone', 'UTC');

            tempo_data.no2 = no2;
            % tempo_data.no2_u = no2_u;
            tempo_data.lat = lat;
            tempo_data.lon = lon;
            tempo_data.sza = sza;
            tempo_data.vza = vza;
            tempo_data.qa = qa;
            % tempo_data.time = time;


        case 'RAD'

        case 'IRR'
   
    end
end


       

