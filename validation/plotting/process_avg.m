function [lat_grid,lon_grid,no2_interp,no2_u_interp] = process_avg(files, savename, dataset, overwrite_on)
    arguments
        files string
        savename string
        dataset string
        overwrite_on logical = false
    end

    lat_bounds = [10 60];
    lon_bounds = [-130 -60];

    
    if ~exist(savename, "file") || overwrite_on
        % disp('Calculating averages')
    
        % Regular grid
        grid_lat = lat_bounds(1):0.05:lat_bounds(2);
        grid_lon = lon_bounds(1):0.05:lon_bounds(2);
    
        % Create meshgrid for the regular grid
        [lon_grid, lat_grid] = meshgrid(grid_lon, grid_lat);
    
        % Initialize arrays for Tempo and Tropomi data
        grid_dim = size(lon_grid);  % Dimensions of the regular grid
    
        no2_interp = NaN(grid_dim);
        no2_u_interp = NaN(grid_dim);
        counter_no2 = zeros(grid_dim);
        counter_no2_u = zeros(grid_dim);

        update_interp = NaN(grid_dim);
        counter_update = zeros(grid_dim);

        f_name = split(savename,'\');
        f_name = f_name(end);
        f = waitbar(0, char(strjoin(["Creating",f_name])));

        for i = 1:length(files)
            fname = files(i);
            ncid = netcdf.open(fname, 'NOWRITE');

            if strcmp(dataset,'tempo')
                product_id = netcdf.inqNcid(ncid, 'product');
                geolocation_id = netcdf.inqNcid(ncid, 'geolocation');
                support_id = netcdf.inqNcid(ncid, 'support_data');

                lat_varid = netcdf.inqVarID(geolocation_id, 'latitude');
                lon_varid = netcdf.inqVarID(geolocation_id, 'longitude');
                no2_varid = netcdf.inqVarID(product_id, 'vertical_column_troposphere');
                no2_u_varid = netcdf.inqVarID(product_id, 'vertical_column_troposphere_uncertainty');
                qa_varid = netcdf.inqVarID(product_id, 'main_data_quality_flag');
                sza_varid = netcdf.inqVarID(geolocation_id, 'solar_zenith_angle');
                vza_varid = netcdf.inqVarID(geolocation_id, 'viewing_zenith_angle');
                cld_frac_varid = netcdf.inqVarID(support_id, 'eff_cloud_fraction');

                lat = double(netcdf.getVar(geolocation_id, lat_varid));
                lon = double(netcdf.getVar(geolocation_id, lon_varid));
                no2 = netcdf.getVar(product_id, no2_varid);
                no2_u = netcdf.getVar(product_id, no2_u_varid);
                qa = netcdf.getVar(product_id, qa_varid); 
                sza = netcdf.getVar(geolocation_id, sza_varid);
                vza = netcdf.getVar(geolocation_id, vza_varid);
                cld_frac = netcdf.getVar(support_id, cld_frac_varid);


                valid_ind = qa == 0 & sza <= 70 & vza <= 70 & cld_frac <= 0.15 & lat>=lat_bounds(1) & lat<=lat_bounds(2) & lon >= lon_bounds(1) & lon <= lon_bounds(2);

            elseif strcmp(dataset, 'tropomi')
                product_id = netcdf.inqNcid(ncid, 'PRODUCT');

                lat_varid = netcdf.inqVarID(product_id, 'latitude');
                lon_varid = netcdf.inqVarID(product_id, 'longitude');
                no2_varid = netcdf.inqVarID(product_id, 'nitrogendioxide_tropospheric_column');
                no2_u_varid = netcdf.inqVarID(product_id, 'nitrogendioxide_tropospheric_column_precision');
                qa_varid = netcdf.inqVarID(product_id, 'qa_value');

                lat = double(netcdf.getVar(product_id, lat_varid));
                lon = double(netcdf.getVar(product_id, lon_varid));
                no2 = double(netcdf.getVar(product_id, no2_varid));
                no2_u = double(netcdf.getVar(product_id, no2_u_varid));
                qa = netcdf.getVar(product_id, qa_varid); 

                valid_ind = qa >= 0.75 & lat >= lat_bounds(1) & lat <= lat_bounds(2) & lon >= lon_bounds(1) & lon <= lon_bounds(2);

            elseif strcmp(dataset, 'merged')
                product_id = netcdf.inqNcid(ncid, 'product');
                geolocation_id = netcdf.inqNcid(ncid, 'geolocation');

                lat_varid = netcdf.inqVarID(geolocation_id, 'latitude');
                lon_varid = netcdf.inqVarID(geolocation_id, 'longitude');
                no2_varid = netcdf.inqVarID(product_id, 'vertical_column_troposphere');
                no2_u_varid = netcdf.inqVarID(product_id, 'vertical_column_troposphere_uncertainty');
                update_varid = netcdf.inqVarID(product_id, 'vertical_column_troposphere_update');

                lat = double(netcdf.getVar(geolocation_id, lat_varid));
                lon = double(netcdf.getVar(geolocation_id, lon_varid));
                no2 = netcdf.getVar(product_id, no2_varid);
                no2_u = netcdf.getVar(product_id, no2_u_varid);
                update = netcdf.getVar(product_id, update_varid);

                valid_ind = ~isnan(no2);
            end        

            netcdf.close(ncid);
        
            F_no2 = scatteredInterpolant(lon(valid_ind), lat(valid_ind), no2(valid_ind), 'linear', 'none');
            F_no2_u = scatteredInterpolant(lon(valid_ind), lat(valid_ind), no2_u(valid_ind), 'linear', 'none');

            temp_no2_interp = F_no2(lon_grid, lat_grid);
            temp_no2_u_interp = F_no2_u(lon_grid, lat_grid);

            no2_interp = sum(cat(3, no2_interp, temp_no2_interp), 3, 'omitnan');
            no2_u_interp = sum(cat(3, no2_u_interp, temp_no2_u_interp), 3, 'omitnan');

            counter_no2(~isnan(temp_no2_interp)) = counter_no2(~isnan(temp_no2_interp)) + 1;
            counter_no2_u(~isnan(temp_no2_u_interp)) = counter_no2_u(~isnan(temp_no2_u_interp)) + 1;

            if exist("update", "var")
                F_update = scatteredInterpolant(lon(valid_ind), lat(valid_ind), update(valid_ind), 'linear', 'none');
                temp_update_interp = F_update(lon_grid, lat_grid);
                update_interp = sum(cat(3, update_interp, temp_update_interp), 3, 'omitnan');
                counter_update(~isnan(temp_update_interp)) = counter_update(~isnan(temp_update_interp)) + 1;
            end

            waitbar(i/length(files), f, char(strjoin(["Creating",f_name])))
        end
    
        % Calculate averages, avoid division by zero
        no2_interp(counter_no2~=0) = no2_interp(counter_no2~=0)./counter_no2(counter_no2~=0);
        no2_u_interp(counter_no2_u~=0) = no2_u_interp(counter_no2_u~=0)./counter_no2_u(counter_no2_u~=0);

        no2_interp(no2_interp<=0) = NaN;
        no2_u_interp(no2_u_interp<=0) = NaN;


        if exist("update", "var")
            update_interp(counter_update~=0) = update_interp(counter_update~=0)./counter_update(counter_update~=0);
            update_interp(counter_update==0) = NaN;
            save(savename, 'no2_interp','no2_u_interp','update_interp','lat_grid','lon_grid') % save the lat lon and no2
        else
            save(savename, 'no2_interp','no2_u_interp','lat_grid','lon_grid') % save the lat lon and no2
        end

       delete(f)
    else
        disp('File already exists')
    end
    

