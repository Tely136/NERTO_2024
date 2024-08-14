function test_implementation_func(start_date, end_date, lat_bounds, lon_bounds, suffix)
    plot_timezone = 'America/New_York';

    start_day = datetime(start_date, 'InputFormat', 'uuuuMMdd',"TimeZone", plot_timezone);
    end_day = datetime(end_date,  'InputFormat', 'uuuuMMdd', "TimeZone", plot_timezone);

    tempo_files = table2timetable(tempo_table('/mnt/disks/data-disk/data/tempo_data'));
    tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);

    tropomi_files = table2timetable(tropomi_table('/mnt/disks/data-disk/data/tropomi_data/'));
    tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);

    data_save_path = '/mnt/disks/data-disk/data/merged_data';

    L = 30; % correlation length in km
    tau = hours(1.5);

    tempo_dim = [2100, 500];
    trop_dim = [500 4200];


    run_days = start_day:end_day;
    scans = [8,9,10];

    tic;
    for i = 1:length(run_days)
        current_day = run_days(i);
        day_period = timerange(current_day, current_day+days(1));

        disp(strjoin(['Processing data for', string(current_day)]))

        tempo_files_day = tempo_files(day_period,:); % all tempo files for this day
        trop_files_day = tropomi_files(day_period,:); % all tropomi files for this day

        if isempty(tempo_files_day) | isempty(trop_files_day)
            continue
        end

        % load all tropomi data
        trop_lat = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_lon = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_lat_corners = single(NaN(4,trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_lon_corners = single(NaN(4,trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_no2 = NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1));
        trop_no2_u = NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1));
        trop_qa = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
        trop_time = NaT(trop_dim(1),trop_dim(2),size(trop_files_day,1), 'TimeZone', 'UTC');

        for j = 1:size(trop_files_day,1)
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

            % spatial_filter = trop_lat>=lat_bounds(1) & trop_lat<=lat_bounds(2) & trop_lon>=lon_bounds(1) & trop_lon<=lon_bounds(2);
            qa_filter = trop_qa>=0.75;

            spatial_filter = false(trop_dim);
            for j = 1:size(lat_bounds,1)
                spatial_filter = spatial_filter | (trop_lat>=lat_bounds(j,1) & trop_lat<=lat_bounds(j,2) & trop_lon>=lon_bounds(j,1) & trop_lon<=lon_bounds(j,2));
            end

            valid_ind_trop = spatial_filter & qa_filter;
            
            trop_lat_merge = trop_lat(valid_ind_trop);
            trop_lon_merge = trop_lon(valid_ind_trop);
            trop_lat_corners_merge = trop_lat_corners(:,valid_ind_trop);
            trop_lon_corners_merge = trop_lon_corners(:,valid_ind_trop);
            trop_no2_merge = trop_no2(valid_ind_trop);
            trop_no2_u_merge = trop_no2_u(valid_ind_trop);
            trop_time_merge = trop_time(valid_ind_trop);


            n_scans = length(scans);

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

            % load all tempo scans into a single multi-dimensional matrix, then process all data together, save result from each scan seperately
            disp('Loading all tempo data')
            for j = 1:n_scans
                scan = scans(j);

                col_counter = 1;

                tempo_files_scan = tempo_files_day(tempo_files_day.Scan==scan,:);
                if ~isempty(tempo_files_scan)
                    for k = 1:size(tempo_files_scan,1)
                        tempo_data_temp = read_tempo_netcdf(tempo_files_scan(k,:));

                        temp_lat = tempo_data_temp.lat;

                        row = size(temp_lat,1);
                        col = size(temp_lat,2);

                        tempo_lat(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.lat;
                        tempo_lon(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.lon;
                        tempo_lat_corners(:,1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.lat_corners;
                        tempo_lon_corners(:,1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.lon_corners;
                        tempo_no2(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.no2 ./ conversion_factor('trop-tempo');
                        tempo_no2_u(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.no2_u ./ conversion_factor('trop-tempo');
                        tempo_qa(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.qa;
                        tempo_cld(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.cld;
                        tempo_sza(1:row,col_counter:col_counter+col-1,j) = tempo_data_temp.sza;
                        tempo_time(1:row,col_counter:col_counter+col-1,j) = resize(tempo_data_temp.time', [row,col], 'Pattern', 'circular');

                        col_counter = col_counter+col;
                    end
                end
            end

            clear tempo_data_temp trop_data_temp temp_lat

            qa_filter = tempo_qa==0 & tempo_cld<0.2 & tempo_sza<70;

            spatial_filter = false(tempo_dim);
            for k = 1:size(lat_bounds,1)
                spatial_filter = spatial_filter | (tempo_lat>=lat_bounds(k,1) & tempo_lat<=lat_bounds(k,2) & tempo_lon>=lon_bounds(k,1) & tempo_lon<=lon_bounds(k,2));
            end

            valid_ind_tempo = spatial_filter & qa_filter;

            tempo_lat_merge = tempo_lat(valid_ind_tempo);
            tempo_lon_merge = tempo_lon(valid_ind_tempo);
            tempo_lat_corners_merge = tempo_lat_corners(:,valid_ind_tempo);
            tempo_lon_corners_merge = tempo_lon_corners(:,valid_ind_tempo);
            tempo_no2_merge = tempo_no2(valid_ind_tempo);
            tempo_no2_u_merge = tempo_no2_u(valid_ind_tempo);
            tempo_time_merge = tempo_time(valid_ind_tempo);

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

            chunk_size = 1000;
            num_chunks = ceil((n)/chunk_size);

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

                    C_t_chunk = temporal_correlation(time1, time2, tau);
            
                    % Combine spatial and temporal correlations
                    C(idx_j, idx_i) = C_s_chunk .* C_t_chunk;

                end
            end

            % Background (Tempo) error covariance function
            Pb = sqrt(D)' * C * sqrt(D);

            % Clear data no longer needed
            clear C_s_chunk C_t_chunk tempo_lat1 tempo_lat2 tempo_lon1 tempo_lon2 time1 time2

            % Observation transformation matrix
            disp('Calculating observation matrix')
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


            analysis_no2 = NaN([tempo_dim(1), tempo_dim(2), n_scans]);
            analysis_no2(valid_ind_tempo) = Xa;

            analysis_no2_u = NaN([tempo_dim(1), tempo_dim(2), n_scans]);
            analysis_no2_u(valid_ind_tempo) = diag(Pb);

            for j = 1:n_scans
                if ~all(isnan(analysis_no2(:,:,j)), 'all')

                    % For saving to .mat file
                    savename = ['TEMPO_TROPOMI_merged_', char(datetime(current_day, 'Format', 'uuuuMMdd')), '_S', num2str(scan), suffix, '.mat'];
                    save_data = struct;

                    save_data.bg_no2 = tempo_no2(:,:,j);
                    save_data.bg_no2_u = tempo_no2_u(:,:,j);
                    save_data.bg_lat = double(tempo_lat(:,:,j));
                    save_data.bg_lon = double(tempo_lon(:,:,j));
                    save_data.bg_time = tempo_time(1,:,j);
                    save_data.bg_valid_ind = valid_ind_tempo;

                    save_data.obs_no2 = trop_no2;
                    save_data.obs_no2_u = trop_no2_u;
                    save_data.obs_lat = double(trop_lat);
                    save_data.obs_lon = double(trop_lon);
                    save_data.obs_time = trop_time(1,:,:);
                    save_data.obs_valid_ind = valid_ind_trop;

                    save_data.analysis_no2 = analysis_no2(:,:,j);
                    save_data.analysis_no2_u = analysis_no2_u(:,:,j);

                    scan = scans(j);
                    save_data.tempo_scan = scan;

                save(fullfile(data_save_path, savename), "save_data", '-mat', '-v7.3');
                disp([savename, ' saved']);

                end
            end
            fprintf('\n')
    end

    processing_time = toc./60;
    disp(['Total time: ', num2str(processing_time), ' minutes'])