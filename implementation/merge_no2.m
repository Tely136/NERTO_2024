function merge_no2(run_day, lat_bounds, lon_bounds, tempo_input_path, tropomi_input_path, data_save_path, options)
    arguments
        run_day datetime
        lat_bounds double
        lon_bounds double
        tempo_input_path char
        tropomi_input_path char
        data_save_path char
        options.suffix char = ''
        options.overwrite_on logical = false
        options.use_gpu logical = false
    end
    use_gpu = options.use_gpu;
    suffix = options.suffix;
    overwrite_on = options.overwrite_on;

    tropomi_qa_filter = 0.75;
    tempo_cld_filter = 0.15;
    tempo_sza_filter = 70;

    tempo_lat_width = km2deg(2);
    tempo_lon_width = km2deg(4.75);

    tropomi_lat_width = km2deg(5.5);
    tropomi_lon_width = km2deg(3.5);

    % If overwrite is off, check which processed files already exist and take them out of run_days
    if ~overwrite_on
        processed_files = dir(fullfile(data_save_path, '*.nc'));

        for i = 1:length(processed_files)
            temp_name = processed_files(i).name;
            temp_name = strsplit(temp_name,'_');
            temp_date = string(temp_name(4));
    
            if any(string(datetime(run_day, "Format","uuuuMMdd"))==temp_date)
                disp('This day was already processed')
                return
            end
        end
    end

    % Tempo scans to be processed
    scans = 1:12;

    % Load Tempo and Tropomi Files
    tempo_files = table2timetable(tempo_table(tempo_input_path));
    tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);

    tropomi_files = table2timetable(tropomi_table(tropomi_input_path));
    tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);

    if ~exist(data_save_path, 'dir')
        mkdir(data_save_path)
    end

    % Correlation length in km
    subset_size = km2deg(100); % degrees
    L = km2deg(30); 

    corr_area = ceil(2*L/km2deg(2));

    lat_is = lat_bounds(1):subset_size:lat_bounds(2);
    lon_is = lon_bounds(1):subset_size:lon_bounds(2);

    if lat_is(end) < lat_bounds(2)
        lat_is(end+1) = lat_bounds(2);
    end
    
    if lon_is(end) < lon_bounds(2)
        lon_is(end+1) = lon_bounds(2);
    end
    
    lat_minus = lat_is(1:end-1) - L;
    lat_plus = lat_is(2:end) + L;
    
    lon_minus = lon_is(1:end-1) - L;
    lon_plus = lon_is(2:end) + L;

    d_lat = lat_plus(1) - lat_minus(1);
    d_lon = lon_plus(1) - lon_minus(1);

    % Set up dimensions for Tempo and Tropomi data
    tempo_dim = [2048, 1400];
    trop_dim = [450 4173];

    day_period = timerange(run_day, run_day+days(1));

    disp(strjoin(['Processing data for', string(run_day)]))

    tempo_files_day = tempo_files(day_period,:); % all tempo files for this day
    trop_files_day = tropomi_files(day_period,:); % all tropomi files for this day

    % Skip this day if there are not tempo or tropomi files
    if isempty(tempo_files_day) | isempty(trop_files_day)
        disp('No TEMPO or TROPOMI files on this day')
        return;
    end

    % Initialize arrays to hold full day of Tropomi data
    trop_2d_dim = [trop_dim(2), size(trop_files_day,1)];
    trop_3d_dim = [trop_dim(1), trop_dim(2), size(trop_files_day, 1)];
    trop_4d_dim = [NaN(4, trop_dim(1), trop_dim(2),size(trop_files_day, 1))];

    trop_lat = single(NaN(trop_3d_dim));
    trop_lon = single(NaN(trop_3d_dim));
    trop_lat_corners = single(trop_4d_dim);
    trop_lon_corners = single(trop_4d_dim);
    trop_no2 = NaN(trop_3d_dim);
    trop_no2_u = NaN(trop_3d_dim);
    trop_qa = single(NaN(trop_3d_dim));
    trop_time = NaT(trop_2d_dim, 'TimeZone', 'UTC');

    % Loop over all Tropomi files on this day
    for j = 1:size(trop_files_day,1)

        % Read the file and add contents to holding arrays
        ncid = netcdf.open(trop_files_day.Filename(j), 'NOWRITE');
        product_id = netcdf.inqNcid(ncid, 'PRODUCT');
        support_id = netcdf.inqNcid(product_id, 'SUPPORT_DATA');
        geolocation_id = netcdf.inqNcid(support_id, 'GEOLOCATIONS');
        
        no2_varid = netcdf.inqVarID(product_id, 'nitrogendioxide_tropospheric_column');
        no2_u_varid = netcdf.inqVarID(product_id, 'nitrogendioxide_tropospheric_column_precision');
        qa_varid = netcdf.inqVarID(product_id, 'qa_value');
        lat_varid = netcdf.inqVarID(product_id, 'latitude');
        lon_varid = netcdf.inqVarID(product_id, 'longitude');
        time_varid = netcdf.inqVarID(product_id, 'time_utc');
        lat_corners_varid = netcdf.inqVarID(geolocation_id, 'latitude_bounds');
        lon_corners_varid = netcdf.inqVarID(geolocation_id, 'longitude_bounds');
        scanline_varid = netcdf.inqVarID(product_id, 'scanline');       

        scanline = netcdf.getVar(product_id, scanline_varid)+1;
        trop_no2(:,scanline,j) = netcdf.getVar(product_id, no2_varid);
        trop_no2_u(:,scanline,j) = netcdf.getVar(product_id, no2_u_varid);
        trop_qa(:,scanline,j) = netcdf.getVar(product_id, qa_varid);
        trop_lat(:,scanline,j) = netcdf.getVar(product_id, lat_varid);
        trop_lon(:,scanline,j) = netcdf.getVar(product_id, lon_varid);
        trop_lat_corners(:,:,scanline,j) = netcdf.getVar(geolocation_id, lat_corners_varid);
        trop_lon_corners(:,:,scanline,j) = netcdf.getVar(geolocation_id, lon_corners_varid);
        trop_time(scanline,j) = datetime(netcdf.getVar(product_id, time_varid), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z''', 'TimeZone', 'UTC');

        netcdf.close(ncid);
    end

    % Filters for Tropomi QA value
    trop_qa_filter = trop_qa>=tropomi_qa_filter;

    % Number of Tempo scans to process 
    n_scans = length(scans);

    % Initialize arrays to hold all Tempo data for the current day
    tempo_2d_dim = [tempo_dim(2), n_scans];
    tempo_3d_dim = [tempo_dim(1), tempo_dim(2), n_scans];
    tempo_4d_dim = [4, tempo_dim(1), tempo_dim(2), n_scans];

    tempo_lat = single(NaN(tempo_3d_dim));
    tempo_lon = single(NaN(tempo_3d_dim));
    tempo_lat_corners = single(NaN(tempo_4d_dim));
    tempo_lon_corners = single(NaN(tempo_4d_dim));
    tempo_no2 = NaN(tempo_3d_dim);
    tempo_no2_u = NaN(tempo_3d_dim);
    tempo_qa = NaN(tempo_3d_dim);
    tempo_cld = NaN(tempo_3d_dim);
    tempo_sza = NaN(tempo_3d_dim);
    tempo_time = NaT(tempo_2d_dim, 'TimeZone', 'UTC');

    % Loop over Tempo scans for current day
    for j = 1:n_scans
        scan = scans(j);

        % Get all Tempo granules for current scan
        tempo_files_scan = tempo_files_day(tempo_files_day.Scan==scan,:);

        % Loop over Tempo granules in current scan
        if ~isempty(tempo_files_scan)
            for k = 1:size(tempo_files_scan,1)
                % Load tempo data into holding arrays
                ncid = netcdf.open(tempo_files_scan.Filename(k), 'NOWRITE');
                product_id = netcdf.inqNcid(ncid, 'product');
                geolocation_id = netcdf.inqNcid(ncid, 'geolocation');
                support_id = netcdf.inqNcid(ncid, 'support_data');
                tempo_step_id = netcdf.inqVarID(ncid, 'mirror_step');
                
                no2_varid = netcdf.inqVarID(product_id, 'vertical_column_troposphere');
                no2_u_varid = netcdf.inqVarID(product_id, 'vertical_column_troposphere_uncertainty');
                qa_varid = netcdf.inqVarID(product_id, 'main_data_quality_flag');
                lat_varid = netcdf.inqVarID(geolocation_id, 'latitude');
                lon_varid = netcdf.inqVarID(geolocation_id, 'longitude');
                lat_corner_varid = netcdf.inqVarID(geolocation_id, 'latitude_bounds');
                lon_corner_varid = netcdf.inqVarID(geolocation_id, 'longitude_bounds');
                time_varid = netcdf.inqVarID(geolocation_id, 'time');
                sza_varid = netcdf.inqVarID(geolocation_id, 'solar_zenith_angle');
                cld_frac_varid = netcdf.inqVarID(support_id, 'eff_cloud_fraction');

                tempo_step = netcdf.getVar(ncid, tempo_step_id)+1;
                
                tempo_no2(:,tempo_step,j) = netcdf.getVar(product_id, no2_varid) ./ conversion_factor('trop-tempo');
                tempo_no2_u(:,tempo_step,j) = netcdf.getVar(product_id, no2_u_varid) ./ conversion_factor('trop-tempo');
                tempo_qa(:,tempo_step,j) = netcdf.getVar(product_id, qa_varid);
                tempo_lat(:,tempo_step,j) = netcdf.getVar(geolocation_id, lat_varid);
                tempo_lon(:,tempo_step,j) = netcdf.getVar(geolocation_id, lon_varid);
                tempo_lat_corners(:,:,tempo_step,j) = netcdf.getVar(geolocation_id, lat_corner_varid);
                tempo_lon_corners(:,:,tempo_step,j) = netcdf.getVar(geolocation_id, lon_corner_varid);
                tempo_cld(:,tempo_step,j) = netcdf.getVar(support_id, cld_frac_varid);
                tempo_sza(:,tempo_step,j) = netcdf.getVar(geolocation_id, sza_varid);
                tempo_time(tempo_step,j) = datetime(netcdf.getVar(geolocation_id, time_varid), 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06', 'TimeZone', 'UTC');

                netcdf.close(ncid);
            end
        end
    end
    clear tempo_data_temp trop_data_temp temp_lat

    % Filter for tempo qa, cloud fraction, and solar zenith angle
    tempo_qa_filter = tempo_qa==0 & tempo_cld<tempo_cld_filter & tempo_sza<tempo_sza_filter;

    % create subset areas and loop over them
    num_lat_subsets = length(lat_is) - 1;
    num_lon_subsets = length(lon_is) - 1;
    total_subsets = num_lat_subsets * num_lon_subsets;

    % Create a single index for the subsets
    [lat_indices, lon_indices] = ndgrid(1:num_lat_subsets, 1:num_lon_subsets);
    lat_minus_loop = lat_minus(lat_indices(:));
    lat_plus_loop = lat_plus(lat_indices(:));

    lon_minus_loop = lon_minus(lon_indices(:));   
    lon_plus_loop = lon_plus(lon_indices(:));   

    tempo_n_max_subset =  ceil(n_scans*(d_lat/tempo_lat_width) * (d_lon/tempo_lon_width));
    tropomi_n_max_subset =  ceil(n_scans*(d_lat/tropomi_lat_width) * (d_lon/tropomi_lon_width));

    tempo_proc_dim = [tempo_n_max_subset, total_subsets];
    tropomi_proc_dim = [tropomi_n_max_subset, total_subsets];

    a_no2_temp = NaN(tempo_proc_dim);
    a_no2_u_temp = NaN(tempo_proc_dim);
    a_idx_temp = NaN(tempo_proc_dim);

    % trop_id = NaN(tropomi_proc_dim);
    trop_no2_proc = NaN(tropomi_proc_dim);
    trop_no2_u_proc = NaN(tropomi_proc_dim);
    trop_lat_proc = NaN(tropomi_proc_dim);
    trop_lon_proc = NaN(tropomi_proc_dim);
    trop_lat_corners_proc = NaN(4,tropomi_proc_dim(1), tropomi_proc_dim(2));
    trop_lon_corners_proc = NaN(4,tropomi_proc_dim(1), tropomi_proc_dim(2));
    trop_time_proc = NaT(tropomi_proc_dim, 'TimeZone', 'UTC');

    tempo_id = NaN(tempo_proc_dim);
    tempo_row = NaN(tempo_proc_dim);
    tempo_col = NaN(tempo_proc_dim);
    tempo_no2_proc = NaN(tempo_proc_dim);
    tempo_no2_u_proc = NaN(tempo_proc_dim);
    tempo_lat_proc = NaN(tempo_proc_dim);
    tempo_lon_proc = NaN(tempo_proc_dim);
    tempo_lat_corners_proc = NaN(4,tempo_proc_dim(1), tempo_proc_dim(2));
    tempo_lon_corners_proc = NaN(4,tempo_proc_dim(1), tempo_proc_dim(2));
    tempo_time_proc = NaT(tempo_proc_dim, 'TimeZone', 'UTC');

    for idx = 1:total_subsets
        % This filter finds all pixels in the current subset
        trop_spatial_filter = trop_lat >= lat_minus_loop(idx) & trop_lat <= lat_plus_loop(idx) & ...
                              trop_lon >= lon_minus_loop(idx) & trop_lon <= lon_plus_loop(idx);

        % Find valid Tropomi indices based on filters
        valid_ind_trop = trop_spatial_filter & trop_qa_filter;
        n_valid_trop = numel(find(valid_ind_trop));

        [~, valid_col_trop, valid_page_trop] = ind2sub(size(valid_ind_trop), find(valid_ind_trop));
        trop_time_ind = sub2ind(size(trop_time), valid_col_trop, valid_page_trop);
        
        % Filter all Tropomi data for the day using valid indices
        % trop_id(1:n_valid_trop,idx) = find(valid_ind_trop); 
        trop_no2_proc(1:n_valid_trop,idx) = trop_no2(valid_ind_trop);
        trop_no2_u_proc(1:n_valid_trop,idx) = trop_no2_u(valid_ind_trop);
        trop_lat_proc(1:n_valid_trop,idx) = trop_lat(valid_ind_trop);
        trop_lon_proc(1:n_valid_trop,idx) = trop_lon(valid_ind_trop);
        trop_lat_corners_proc(:,1:n_valid_trop,idx) = trop_lat_corners(:,valid_ind_trop);
        trop_lon_corners_proc(:,1:n_valid_trop,idx) = trop_lon_corners(:,valid_ind_trop);
        trop_time_proc(1:length(trop_time_ind),idx) = trop_time(trop_time_ind);

        % Filter TEMPO data to current subset
        tempo_spatial_filter = tempo_lat >= lat_minus_loop(idx) & tempo_lat <= lat_plus_loop(idx) & ...
                               tempo_lon >= lon_minus_loop(idx) & tempo_lon <= lon_plus_loop(idx);
        
        % Finding valid indices based on filters
        valid_ind_tempo = tempo_spatial_filter & tempo_qa_filter;
        n_valid_tempo = numel(find(valid_ind_tempo));

        [valid_row_tempo, valid_col_tempo, valid_page_tempo] = ind2sub(size(valid_ind_tempo), find(valid_ind_tempo));
        tempo_time_ind = sub2ind(size(tempo_time), valid_col_tempo, valid_page_tempo);

        tempo_id(1:n_valid_tempo,idx) = find(valid_ind_tempo); 
        tempo_row(1:n_valid_tempo,idx) = valid_row_tempo; 
        tempo_col(1:n_valid_tempo,idx) = valid_col_tempo; 
        tempo_no2_proc(1:n_valid_tempo,idx) = tempo_no2(valid_ind_tempo);
        tempo_no2_u_proc(1:n_valid_tempo,idx) = tempo_no2_u(valid_ind_tempo);
        tempo_lat_proc(1:n_valid_tempo,idx) = tempo_lat(valid_ind_tempo);
        tempo_lon_proc(1:n_valid_tempo,idx) = tempo_lon(valid_ind_tempo);
        tempo_lat_corners_proc(:,1:n_valid_tempo,idx) = tempo_lat_corners(:,valid_ind_tempo);
        tempo_lon_corners_proc(:,1:n_valid_tempo,idx) = tempo_lon_corners(:,valid_ind_tempo);
        tempo_time_proc(1:length(tempo_time_ind),idx) = tempo_time(tempo_time_ind);
    end

    clear trop_no2 trop_no2_u trop_lat trop_lon trop_lat_corners trop_lon_corners trop_qa trop_time trop_spatial_filter trop_qa_filter
    clear tempo_no2_u tempo_lat_corners tempo_lon_corners tempo_qa tempo_cld tempo_sza valid_ind_tempo valid_row_tempo valid_col_tempo valid_page_tempo tempo_spatial_filter tempo_qa_filter scanline
    % clear tempo_no2 tempo_lat tempo_lon tempo_time

    parfor idx = 1:total_subsets
        trop_no2_merge = trop_no2_proc(:,idx);
        trop_no2_u_merge = trop_no2_u_proc(:,idx);
        trop_lat_merge = trop_lat_proc(:,idx);
        trop_lon_merge = trop_lon_proc(:,idx);
        trop_lat_corners_merge = trop_lat_corners_proc(:,:,idx);
        trop_lon_corners_merge = trop_lon_corners_proc(:,:,idx);
        trop_time_merge = trop_time_proc(:,idx);

        trop_not_nan = ~isnan(trop_no2_merge);
        trop_no2_merge = trop_no2_merge(trop_not_nan);
        trop_no2_u_merge = trop_no2_u_merge(trop_not_nan);
        trop_lat_merge = trop_lat_merge(trop_not_nan);
        trop_lon_merge = trop_lon_merge(trop_not_nan);
        trop_lat_corners_merge = trop_lat_corners_merge(:,trop_not_nan);
        trop_lon_corners_merge = trop_lon_corners_merge(:,trop_not_nan);
        trop_time_merge = trop_time_merge(trop_not_nan);

        tempo_id_merge = tempo_id(:,idx);
        tempo_row_merge = tempo_row(:,idx);
        tempo_col_merge = tempo_col(:,idx);

        tempo_no2_merge = tempo_no2_proc(:,idx);
        tempo_no2_u_merge = tempo_no2_u_proc(:,idx);
        tempo_lat_merge = tempo_lat_proc(:,idx);
        tempo_lon_merge = tempo_lon_proc(:,idx);
        tempo_lat_corners_merge = tempo_lat_corners_proc(:,:,idx);
        tempo_lon_corners_merge = tempo_lon_corners_proc(:,:,idx);
        tempo_time_merge = tempo_time_proc(:,idx);

        tempo_not_nan = ~isnan(tempo_no2_merge);
        tempo_id_merge = tempo_id_merge(tempo_not_nan);
        tempo_row_merge = tempo_row_merge(tempo_not_nan);
        tempo_col_merge = tempo_col_merge(tempo_not_nan);
        tempo_no2_merge = tempo_no2_merge(tempo_not_nan);
        tempo_no2_u_merge = tempo_no2_u_merge(tempo_not_nan);
        tempo_lat_merge = tempo_lat_merge(tempo_not_nan);
        tempo_lon_merge = tempo_lon_merge(tempo_not_nan);
        tempo_lat_corners_merge = tempo_lat_corners_merge(:,tempo_not_nan);
        tempo_lon_corners_merge = tempo_lon_corners_merge(:,tempo_not_nan);
        tempo_time_merge = tempo_time_merge(tempo_not_nan);

        %% Beginning Kalman Filter Process
        % Number of Tempo and Tropomi measurements to merge
        n = numel(tempo_lat_merge);
        m = numel(trop_lat_merge);

        % Observation (Tropomi) error covariance matrix
        R = sparse(1:m,1:m,trop_no2_u_merge(:));
        
        % Background (Tempo) error covariance matrix
        D = sparse(1:n,1:n,tempo_no2_u_merge(:));

        % Correlation Matrix
        C = zeros(n,n);
        for current_ind = 1:n
            rows = zeros(1,n);

            current_lat = tempo_lat_merge(current_ind);
            current_lon = tempo_lon_merge(current_ind);
            
            sub_ind = find(tempo_row_merge>=tempo_row_merge(current_ind)-corr_area & tempo_row_merge<=tempo_row_merge(current_ind)+corr_area...
                         & tempo_col_merge>=tempo_col_merge(current_ind)-corr_area & tempo_col_merge<=tempo_col_merge(current_ind)+corr_area);

            sub_lat = tempo_lat_merge(sub_ind);
            sub_lon = tempo_lon_merge(sub_ind);
            
            rows(sub_ind) = gaspari_cohn(deg2km(distance(current_lat,current_lon, sub_lat, sub_lon))./deg2km(L));
            C(current_ind,:) = rows;
        end

        % Background (Tempo) error covariance function
        Pb = sqrt(D)' * C * sqrt(D);

        % TODO: either remove the struct or define it at the beginning so
        % data isn't repeated

        % Observation transformation matrix
        interpolation_struct = struct;
        interpolation_struct.tempo_lat = tempo_lat_merge;
        interpolation_struct.tempo_lon = tempo_lon_merge;
        interpolation_struct.tempo_lat_corners = tempo_lat_corners_merge;
        interpolation_struct.tempo_lon_corners = tempo_lon_corners_merge;
        interpolation_struct.tempo_time = tempo_time_merge;

        interpolation_struct.trop_lat = trop_lat_merge;
        interpolation_struct.trop_lon = trop_lon_merge;
        interpolation_struct.trop_lat_corners = trop_lat_corners_merge;
        interpolation_struct.trop_lon_corners = trop_lon_corners_merge;
        interpolation_struct.trop_time = trop_time_merge;

        interpolation_struct.time_window = minutes(30);
        
        % calculate this based on pixel sizes
        interpolation_struct.search_area = 0.1;

        % TODO: look into reusing observation matrix
        % TODO: look at the efficiency of this function
        % Look into regridding observations to lower resolution and see how it affects time and performance
        H = interpolation_operator(interpolation_struct, 'mean');

        % TODO: finish function to test interpolation and try it here
        
        if use_gpu
            Pb = gpuArray(Pb);
            R = gpuArray(R);
            H = gpuArray(H);
        end

        % Kalman Gain
        K = Pb * H' / (H * Pb * H' + R);

        % Analysis update
        Xa = tempo_no2_merge + K * (trop_no2_merge - H * tempo_no2_merge);

        % Analysis Error Covariance
        Pa = (eye(length(Xa)) - K * H) * Pb;

        if use_gpu
            Xa = gather(Xa);
            Pa = gather(Pa);
        end

        xa_fll = NaN(tempo_n_max_subset,1);
        xa_u_fll = NaN(tempo_n_max_subset,1);
        id_fll = NaN(tempo_n_max_subset,1);

        xa_fll(1:length(Xa)) = Xa;
        xa_u_fll(1:length(Xa)) = diag(Pa);
        id_fll(1:length(Xa)) = tempo_id_merge;

        a_no2_temp(:,idx) = xa_fll;
        a_no2_u_temp(:,idx) = xa_u_fll;
        a_idx_temp(:,idx) = id_fll;
    end

    ids = unique(a_idx_temp(~isnan(a_idx_temp)));
    n_points = length(ids);
    
    a_avg = NaN(n_points,1);
    a_u_avg = NaN(n_points,1);

    for i = 1:n_points
        a_avg(i) = mean(a_no2_temp(a_idx_temp==ids(i)), 'omitnan');
        a_u_avg(i) = mean(a_no2_u_temp(a_idx_temp==ids(i)), 'omitnan');
    end

    % Matrices to save analysis
    analysis_no2 = NaN(tempo_3d_dim);
    analysis_no2_u = NaN(tempo_3d_dim);

    analysis_no2(ids) = a_avg;
    analysis_no2_u(ids) = a_u_avg;

    % Prepare data for saving
    % Loop over each scan in processed data
    for j = 1:n_scans
        scan = scans(j);

        if ~all(isnan(analysis_no2(:,:,j)), 'all')
            
            savename = ['TEMPO_TROPOMI_merged_', char(datetime(run_day, 'Format', 'uuuuMMdd')), '_S', num2str(scan), suffix, '.nc'];

            save_path = fullfile(data_save_path, savename);
            if exist(save_path, 'file')
                delete(save_path)
            end
           
            nccreate(save_path, 'product/vertical_column_troposphere', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');
            nccreate(save_path, 'product/vertical_column_troposphere_uncertainty', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');
            nccreate(save_path, 'geolocation/latitude', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');
            nccreate(save_path, 'geolocation/longitude', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');
            nccreate(save_path, 'geolocation/time', 'Dimensions', {"cols", tempo_dim(2)}, 'Format','netcdf4');

            nccreate(save_path, 'scan');

            nccreate(save_path, 'product/vertical_column_troposphere_update', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');


            ncwrite(save_path, 'product/vertical_column_troposphere', analysis_no2(:,:,j));
            ncwrite(save_path, 'product/vertical_column_troposphere_uncertainty', analysis_no2_u(:,:,j));
            ncwrite(save_path, 'geolocation/latitude', double(tempo_lat(:,:,j)));
            ncwrite(save_path, 'geolocation/longitude', double(tempo_lon(:,:,j)));
            ncwrite(save_path, 'geolocation/time', posixtime(tempo_time(:,j)));

            ncwrite(save_path, 'scan', scan)

            ncwrite(save_path, 'product/vertical_column_troposphere_update', analysis_no2(:,:,j) - tempo_no2(:,:,j));
        end
    end
    fprintf('\n')


    