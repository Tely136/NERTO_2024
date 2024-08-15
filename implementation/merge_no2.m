function merge_no2(start_date, end_date, lat_bounds, lon_bounds, options)
    arguments
        start_date string
        end_date string
        lat_bounds double
        lon_bounds double
        options.data_save_path char = '/mnt/disks/data-disk/data/merged_data/'
        options.suffix char = ''
    end

    data_save_path = options.data_save_path;
    suffix = options.suffix;

    timezone = 'America/New_York';

    % Start and end time for processing
    start_date = datetime(start_date, "InputFormat", 'uuuuMMdd', 'TimeZone', timezone);
    end_date = datetime(end_date, "InputFormat", 'uuuuMMdd', 'TimeZone', timezone);
    run_days = start_date:end_date;

    % Tempo scans to be processed
    scans = 1:12;

    % Load Tempo and Tropomi Files
    tempo_files = table2timetable(tempo_table('/mnt/disks/data-disk/data/tempo_data'));
    tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);

    tropomi_files = table2timetable(tropomi_table('/mnt/disks/data-disk/data/tropomi_data/'));
    tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);

    if ~exist(data_save_path, 'dir')
        mkdir(data_save_path)
    end


    % time_window = minutes(30);

    % Correlation length in km
    L = 30; 

    % Temporal correlation period
    tau = hours(8);

    % Set up dimensions for Tempo and Tropomi data
    tempo_dim = [2100, 500];
    trop_dim = [500 4200];

    tic;
    % Loop over each day in period
    for i = 1:length(run_days)
        current_day = run_days(i);
        day_period = timerange(current_day, current_day+days(1));

        disp(strjoin(['Processing data for', string(current_day)]))

        tempo_files_day = tempo_files(day_period,:); % all tempo files for this day
        trop_files_day = tropomi_files(day_period,:); % all tropomi files for this day

        if isempty(tempo_files_day) | isempty(trop_files_day)
            continue
        end

        % Initialize arrays to hold full day of Tropomi data
        trop_lat = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_lon = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_lat_corners = single(NaN(4,trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_lon_corners = single(NaN(4,trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_no2 = NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1));
        trop_no2_u = NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1));
        trop_qa = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_time = NaT(trop_dim(1),trop_dim(2),size(trop_files_day,1), 'TimeZone', 'UTC');

        % Loop over all Tropomi files on this day
        disp('Loading all Tropomi data')
        for j = 1:size(trop_files_day,1)
            % Read the file and add contents to holding arrays
            trop_data_temp = read_tropomi_netcdf(trop_files_day(j,:));
            temp_lat = trop_data_temp.lat;
            row = size(temp_lat,1);
            col = size(temp_lat,2);

            trop_lat(1:row,1:col,j) = trop_data_temp.lat;
            trop_lon(1:row,1:col,j) = trop_data_temp.lon;
            trop_lat_corners(:,1:row,1:col,j) = trop_data_temp.lat_corners;
            trop_lon_corners(:,1:row,1:col,j) = trop_data_temp.lon_corners;
            trop_no2(1:row,1:col,j) = trop_data_temp.no2;
            trop_no2_u(1:row,1:col,j) = trop_data_temp.no2_u;
            trop_qa(1:row,1:col,j) = trop_data_temp.qa;
            trop_time(1:row,1:col,j) = resize(trop_data_temp.time', [row,col], 'Pattern', 'circular');
        end

        % Filters for lat-lon bounds and Tropomi QA value
        qa_filter = trop_qa>=0.75;
        spatial_filter = false(trop_dim);
        for j = 1:size(lat_bounds,1)
            spatial_filter = spatial_filter | (trop_lat>=lat_bounds(j,1) & trop_lat<=lat_bounds(j,2) & trop_lon>=lon_bounds(j,1) & trop_lon<=lon_bounds(j,2));
        end

        % Find valid Tropomi indices based on filters
        valid_ind_trop = spatial_filter & qa_filter;
        
        % Filter all Tropomi data for the day using valid indices
        trop_lat_merge = trop_lat(valid_ind_trop);
        trop_lon_merge = trop_lon(valid_ind_trop);
        trop_lat_corners_merge = trop_lat_corners(:,valid_ind_trop);
        trop_lon_corners_merge = trop_lon_corners(:,valid_ind_trop);
        trop_no2_merge = trop_no2(valid_ind_trop);
        trop_no2_u_merge = trop_no2_u(valid_ind_trop);
        trop_time_merge = trop_time(valid_ind_trop);

        % Number of Tempo scans to process 
        n_scans = length(scans);

        % Initialize arrays to hold all Tempo data for the current day
        tempo_lat = single(NaN(tempo_dim(1), tempo_dim(2), n_scans));
        tempo_lon = single(NaN(tempo_dim(1), tempo_dim(2), n_scans));
        tempo_lat_corners = single(NaN(4,tempo_dim(1),tempo_dim(2), n_scans));
        tempo_lon_corners = single(NaN(4,tempo_dim(1),tempo_dim(2), n_scans));
        tempo_no2 = NaN(tempo_dim(1), tempo_dim(2), n_scans);
        tempo_no2_u = NaN(tempo_dim(1), tempo_dim(2), n_scans);
        tempo_qa = NaN(tempo_dim(1), tempo_dim(2), n_scans);
        tempo_cld = NaN(tempo_dim(1), tempo_dim(2), n_scans);
        tempo_sza = NaN(tempo_dim(1), tempo_dim(2), n_scans);
        tempo_time = NaT(tempo_dim(1), tempo_dim(2), n_scans, 'TimeZone', 'UTC');

        % Loop over Tempo scans for current day
        disp('Loading all Tempo data')
        for j = 1:n_scans
            scan = scans(j);

            % Counter to keep track of along-scan index
            col_counter = 1;

            % Get all Tempo granules for current scan
            tempo_files_scan = tempo_files_day(tempo_files_day.Scan==scan,:);

            % Loop over Tempo granules in current scan
            if ~isempty(tempo_files_scan)
                for k = 1:size(tempo_files_scan,1)
                    tempo_data_temp = read_tempo_netcdf(tempo_files_scan(k,:));

                    temp_lat = tempo_data_temp.lat;

                    row = size(temp_lat,1);
                    col = size(temp_lat,2);

                    % Add Tempo data to holding arrays for current granule
                    tempo_lat(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.lat;
                    tempo_lon(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.lon;
                    tempo_lat_corners(:,1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.lat_corners;
                    tempo_lon_corners(:,1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.lon_corners;
                    tempo_no2(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.no2 ./ conversion_factor('trop-tempo');
                    tempo_no2_u(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.no2_u ./ conversion_factor('trop-tempo');
                    tempo_qa(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.qa;
                    tempo_cld(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.f_cld;
                    tempo_sza(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.sza;
                    tempo_time(1:row,col_counter:col_counter+col-1,j) = resize(tempo_data_temp.time', [row,col], 'Pattern', 'circular');

                    col_counter = col_counter+col;
                end
            end
        end
        clear tempo_data_temp trop_data_temp temp_lat

        % Filter for lat-lon bounds, qa, clouds, and SZA for Tempo data
        qa_filter = tempo_qa==0 & tempo_cld<0.2 & tempo_sza<70;
        spatial_filter = false(tempo_dim);
        for k = 1:size(lat_bounds,1)
            spatial_filter = spatial_filter | (tempo_lat>=lat_bounds(k,1) & tempo_lat<=lat_bounds(k,2) & tempo_lon>=lon_bounds(k,1) & tempo_lon<=lon_bounds(k,2));
        end

        % Finding valid indices based on filters
        valid_ind_tempo = spatial_filter & qa_filter;

        % Filtering Tempo data for the current scan with valid indices
        tempo_lat_merge = tempo_lat(valid_ind_tempo);
        tempo_lon_merge = tempo_lon(valid_ind_tempo);
        tempo_lat_corners_merge = tempo_lat_corners(:,valid_ind_tempo);
        tempo_lon_corners_merge = tempo_lon_corners(:,valid_ind_tempo);
        tempo_no2_merge = tempo_no2(valid_ind_tempo);
        tempo_no2_u_merge = tempo_no2_u(valid_ind_tempo);
        tempo_time_merge = tempo_time(valid_ind_tempo);

        %% Beginning Kalman Filter Process
        % Number of Tempo and Tropomi measurements to merge
        n = numel(tempo_lat_merge);
        m = numel(trop_lat_merge);

        % Observation (Tropomi) error covariance matrix
        disp('Creating observation error covariance matrix')
        R = sparse(1:m,1:m,trop_no2_u_merge);
        
        % Background (Tempo) error covariance matrix
        disp('Creating background error covariance matrix')
        D = sparse(1:n,1:n,tempo_no2_u_merge);

        % Correlation Matrix
        disp('Creating correlation matrix')
        C = sparse(n,n);

        % Number of chunks to split correlation matrix into
        chunk_size = 1000;
        num_chunks = ceil((n)/chunk_size);

        % Loop over each chunk and calculate correlation matrix for that chunk
        for chunk_i = 1:num_chunks
            for chunk_j = 1:num_chunks
                idx_i = (chunk_i-1)*chunk_size+1 : min(chunk_i*chunk_size, n);
                idx_j = (chunk_j-1)*chunk_size+1 : min(chunk_j*chunk_size, n);
        
                % Spatial correlation chunk
                [tempo_lat1, tempo_lat2] = meshgrid(tempo_lat_merge(idx_i), tempo_lat_merge(idx_j));
                [tempo_lon1, tempo_lon2] = meshgrid(tempo_lon_merge(idx_i), tempo_lon_merge(idx_j));
                C_s_chunk = gaspari_cohn(deg2km(distance(tempo_lat1, tempo_lon1, tempo_lat2, tempo_lon2)) / L);
        
                % Temporal correlation chunk
                [time1, time2] = meshgrid(tempo_time_merge(idx_i), tempo_time_merge(idx_j));

                C_t_chunk = temporal_correlation((time1-time2)./tau);
                C_t_chunk(abs(time1-time2)>hours(24)) = 0;
        
                % Combine spatial and temporal correlations
                C(idx_j, idx_i) = C_s_chunk .* C_t_chunk;

            end
        end

        % Background (Tempo) error covariance function
        Pb = sqrt(D)' * C * sqrt(D);

        % Clear data no longer needed
        clear D C C_s_chunk C_t_chunk tempo_lat1 tempo_lat2 tempo_lon1 tempo_lon2 time1 time2

        % Observation transformation matrix
        disp('Calculating observation matrix')

        % TODO: change interpolation operator function to take structs for better readability
        H = interpolation_operator(tempo_lat_merge, tempo_lon_merge, tempo_lat_corners_merge, tempo_lon_corners_merge, tempo_time_merge, trop_lat_merge, trop_lon_merge, trop_lat_corners_merge, trop_lon_corners_merge, trop_time_merge, 'mean');

        clear tempo_lat_merge tempo_lon_merge tempo_lat_corners_merge tempo_lon_corners_merge tempo_time_merge trop_lat_merge trop_lon_merge trop_lat_corners_merg trop_lon_corners_merge trop_time_merge

        % Kalman Gain
        disp('Calculating Kalman Gain matrix')
        K = Pb * H' / (H * Pb * H' + R);

        % Analysis update
        disp('Calculating analysis update')
        Xa = tempo_no2_merge + K * (trop_no2_merge - H * tempo_no2_merge);

        % Analysis Error Covariance
        Pa = (eye(length(Xa)) - K * H) * Pb;

        % Prepare data for saving
        disp('Saving data')


        % Matrices to save analysis
        analysis_no2 = NaN([tempo_dim(1), tempo_dim(2), n_scans]);
        analysis_no2_u = NaN([tempo_dim(1), tempo_dim(2), n_scans]);
        analysis_no2(valid_ind_tempo) = Xa;
        analysis_no2_u(valid_ind_tempo) = diag(Pa);

        % Loop over each scan in processed data
        for j = 1:n_scans
            scan = scans(j);

            if ~all(isnan(analysis_no2(:,:,j)), 'all')
                
                savename = ['TEMPO_TROPOMI_merged_', char(datetime(current_day, 'Format', 'uuuuMMdd')), '_S', num2str(scan), suffix, '.nc'];

                save_path = fullfile(data_save_path, savename);
                if exist(save_path, 'file')
                    delete(save_path)
                end
                n_trop_scans = size(trop_files_day,1);

                nccreate(save_path, '/tempo/tempo_no2', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');
                nccreate(save_path, '/tempo/tempo_no2_u', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');
                nccreate(save_path, '/tempo/tempo_lat', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');
                nccreate(save_path, '/tempo/tempo_lon', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');
                nccreate(save_path, '/tempo/tempo_time', 'Dimensions', {"1", 1, "cols", tempo_dim(2)}, 'Format','netcdf4');
                nccreate(save_path, '/tempo/tempo_valid_ind', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');

                nccreate(save_path, '/tropomi/tropomi_no2', 'Dimensions', {"rows", trop_dim(1), "cols", trop_dim(2), "scans", n_trop_scans}, 'Format','netcdf4');
                nccreate(save_path, '/tropomi/tropomi_no2_u', 'Dimensions', {"rows", trop_dim(1), "cols", trop_dim(2), "scans", n_trop_scans}, 'Format','netcdf4');
                nccreate(save_path, '/tropomi/tropomi_lat', 'Dimensions', {"rows", trop_dim(1), "cols", trop_dim(2), "scans", n_trop_scans}, 'Format','netcdf4');
                nccreate(save_path, '/tropomi/tropomi_lon', 'Dimensions', {"rows", trop_dim(1), "cols", trop_dim(2), "scans", n_trop_scans}, 'Format','netcdf4');
                nccreate(save_path, '/tropomi/tropomi_time', 'Dimensions', {"1", 1, "cols", trop_dim(2), "scans", n_trop_scans}, 'Format','netcdf4');
                nccreate(save_path, '/tropomi/tropomi_valid_ind', 'Dimensions', {"rows", trop_dim(1), "cols", trop_dim(2), "scans", n_trop_scans}, 'Format','netcdf4');

                nccreate(save_path, 'analysis/analysis_no2', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');
                nccreate(save_path, 'analysis/analysis_no2_u', 'Dimensions', {"rows", tempo_dim(1), "cols", tempo_dim(2)}, 'Format','netcdf4');

                nccreate(save_path, 'scan');

                ncwrite(save_path, '/tempo/tempo_no2', tempo_no2(:,:,j))
                ncwrite(save_path, '/tempo/tempo_no2_u', tempo_no2_u(:,:,j))
                ncwrite(save_path, '/tempo/tempo_lat', double(tempo_lat(:,:,j)))
                ncwrite(save_path, '/tempo/tempo_lon', double(tempo_lon(:,:,j)))
                ncwrite(save_path, '/tempo/tempo_time', posixtime(tempo_time(1,:,j)))
                ncwrite(save_path, '/tempo/tempo_valid_ind', single(valid_ind_tempo(:,:,j)))

                ncwrite(save_path, '/tropomi/tropomi_no2', trop_no2)
                ncwrite(save_path, '/tropomi/tropomi_no2_u', trop_no2_u)
                ncwrite(save_path, '/tropomi/tropomi_lat', double(trop_lat))
                ncwrite(save_path, '/tropomi/tropomi_lon', double(trop_lon))
                ncwrite(save_path, '/tropomi/tropomi_time', posixtime(trop_time(1,:,:)))
                ncwrite(save_path, '/tropomi/tropomi_valid_ind', single(valid_ind_trop))

                ncwrite(save_path, '/analysis/analysis_no2', analysis_no2(:,:,j))
                ncwrite(save_path, '/analysis/analysis_no2_u', analysis_no2_u(:,:,j))

                ncwrite(save_path, 'scan', scan)

                disp([savename, ' saved']);
            end
        end
        fprintf('\n')
    end