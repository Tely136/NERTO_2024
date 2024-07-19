clearvars; clc; close all;

plot_timezone = 'America/New_York';

start_day = datetime(2024,5,20,"TimeZone", plot_timezone);
end_day = datetime(2024,6,8, "TimeZone", plot_timezone);


tempo_files = table2timetable(tempo_table('/mnt/disks/data-disk/data/tempo_data'));
tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);

tropomi_files = table2timetable(tropomi_table('/mnt/disks/data-disk/data/tropomi_data/'));
tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);

data_save_path = '/mnt/disks/data-disk/data/merged_data';


% lat_bounds = [39 40]; % baltimore
% lon_bounds = [-77 -76];
% suffix = '_TEST';

% lat_bounds = [38 40]; % maryland
% lon_bounds = [-78 -75.8];
% suffix = '_MARYLAND';

% lat_bounds = [40.4 41.3]; % new york city
% lon_bounds = [-74.6 -72.7];
% suffix = '_NYC';

% lat_bounds = [[38 40];...
%               [40.4 41.3]];

% lon_bounds = [[-78 -75.8];...
%               [-74.6 -72.7]];
% suffix = '';

lat_bounds = [38 41.3]; % new york city
lon_bounds = [-78 -72.7];
suffix = '_TEST_big';


time_window = minutes(30);
L = 30; % correlation length in km

tempo_dim = [2100, 500];
trop_dim = [500 4200];

run_days = start_day:end_day;
scans = [8,9,10,11];

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
    trop_no2 = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
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
    
    trop_lat = trop_lat(valid_ind_trop);
    trop_lon = trop_lon(valid_ind_trop);
    trop_lat_corners = trop_lat_corners(:,valid_ind_trop);
    trop_lon_corners = trop_lon_corners(:,valid_ind_trop);
    trop_no2 = trop_no2(valid_ind_trop);
    trop_no2_u = trop_no2_u(valid_ind_trop);
    trop_time = trop_time(valid_ind_trop);


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

    tempo_lat = tempo_lat(valid_ind_tempo);
    tempo_lon = tempo_lon(valid_ind_tempo);
    tempo_lat_corners = tempo_lat_corners(:,valid_ind_tempo);
    tempo_lon_corners = tempo_lon_corners(:,valid_ind_tempo);
    tempo_no2 = tempo_no2(valid_ind_tempo);
    tempo_no2_u = tempo_no2_u(valid_ind_tempo);
    tempo_time = tempo_time(valid_ind_tempo);

    n = numel(tempo_lat);
    m = numel(trop_lat);

    % Observation (Tropomi) error covariance matrix
    disp('Creating observation error covariance matrix')
    R = sparse(1:m,1:m,trop_no2_u);
    
    % Background (Tempo) error covariance matrix
    disp('Creating background error covariance matrix')
    D = sparse(1:n,1:n,tempo_no2_u);

    % Create matrix containing distances between each point in Tempo data
    [tempo_lat1, tempo_lat2] = meshgrid(tempo_lat, tempo_lat);
    [tempo_lon1, tempo_lon2] = meshgrid(tempo_lon, tempo_lon);

    dij = distance(tempo_lat1, tempo_lon1, tempo_lat2, tempo_lon2);
    dij = deg2km(dij);

    % Spatial correlation matrix 
    C_s = gaspari_cohn(dij ./ L);

    % Temporal correlation matrix
    [time1, time2] = meshgrid(tempo_time, tempo_time);

    tau = hours(1.5);
    C_t = temporal_correlation(time1, time2, tau);

    % Total Correlation matrix
    C = C_s .* C_t;

    % Background (Tempo) error covariance function
    Pb = sqrt(D)' * C * sqrt(D);

    % Clear data no longer needed
    clear dij tempo_lat1 tempo_lat2 tempo_lon1 tempo_lon2 time1 time2

    % Observation transformation matrix
    disp('Calculating observation matrix')
    H = interpolation_operator(tempo_lat, tempo_lon, tempo_lat_corners, tempo_lon_corners, tempo_time, trop_lat, trop_lon, trop_lat_corners, trop_lon_corners, trop_time, 'mean');

    % Kalman Gain
    disp('Calculating Kalman Gain matrix')
    K = Pb * H' / (H * Pb * H' + R);

    singular = false;
    if isnan(cond(K))
        singular = true;
    end

    % Analysis update
    disp('Calculating analysis update')
    Xa = tempo_no2 + K * (trop_no2 - H * tempo_no2);

    % Analysis Error Covariance
    Pa = (eye(length(Xa)) - K * H) * Pb;

    % Prepare data for saving
    disp('Saving data')

    bg_no2 = NaN(tempo_dim(1), tempo_dim(2), n_scans);
    bg_no2(valid_ind_tempo) = tempo_no2;

    bg_no2_u = NaN(tempo_dim(1), tempo_dim(2), n_scans);
    bg_no2_u(valid_ind_tempo) = tempo_no2_u;

    bg_lat = NaN(tempo_dim(1), tempo_dim(2), n_scans);
    bg_lat(valid_ind_tempo) = tempo_lat;

    bg_lon = NaN(tempo_dim(1), tempo_dim(2), n_scans);
    bg_lon(valid_ind_tempo) = tempo_lon;

    analysis_no2 = NaN(tempo_dim(1), tempo_dim(2), n_scans);
    analysis_no2(valid_ind_tempo) = Xa;

    analysis_no2_u = NaN(tempo_dim(1), tempo_dim(2), n_scans);
    analysis_no2_u(valid_ind_tempo) = diag(Pa);

    for j = 1:n_scans
        if ~all(isnan(bg_no2(:,:,j)), 'all')
            save_data = struct;

            save_data.bg_no2 = bg_no2(:,:,j);
            save_data.bg_no2_u = bg_no2_u(:,:,j);
            save_data.bg_lat = bg_lat(:,:,j);
            save_data.bg_lon = bg_lon(:,:,j);
            save_data.bg_no2 = bg_no2(:,:,j);

            save_data.bg_qa = tempo_qa(:,:,j);
            save_data.bg_cld = tempo_cld(:,:,j);

            save_data.obs_no2 = NaN([trop_dim(1),trop_dim(2),size(trop_files_day,1)]);
            save_data.obs_no2(valid_ind_trop) = trop_no2;
        
            save_data.obs_no2_u = NaN([trop_dim(1),trop_dim(2),size(trop_files_day,1)]);
            save_data.obs_no2_u(valid_ind_trop) = trop_no2_u;
        
            save_data.obs_lat = NaN([trop_dim(1),trop_dim(2),size(trop_files_day,1)]);
            save_data.obs_lat(valid_ind_trop) = trop_lat;
        
            save_data.obs_lon = NaN([trop_dim(1),trop_dim(2),size(trop_files_day,1)]);
            save_data.obs_lon(valid_ind_trop) = trop_lon;
        
            save_data.obs_qa = trop_qa;

            save_data.analysis_no2 = analysis_no2(:,:,j);
            save_data.analysis_no2_u = analysis_no2_u(:,:,j);

            save_data.bg_time = tempo_time;
            save_data.obs_time = trop_time;

            % save_data.tempo_time = tempo_temp.Date;

            scan = scans(j);
            save_data.tempo_scan = scan;

            % maybe list the present granules
            % save_data.tempo_granule = tempo_temp.Granule;

            % Saved for testing:
            save_data.obs_var = R;
            save_data.bg_var = D;
            save_data.bg_cor = C;
            save_data.bg_cov = Pb;
            save_data.obs_operator = H;
            save_data.kalman_gain = K;
            save_data.ana_cov = Pa;

            save_data.singular = singular;

            savename = ['TEMPO_TROPOMI_merged_', char(datetime(current_day, 'Format', 'uuuuMMdd')), '_S', num2str(scan), suffix, '.mat'];
            
            save(fullfile(data_save_path, savename), "save_data", '-mat');
            disp([savename, ' saved']);
        end
    end
    fprintf('\n')

end

processing_time = toc./60;
disp(['Total time: ', num2str(processing_time), ' minutes'])