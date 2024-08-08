clearvars; clc; close all;

plot_timezone = 'America/New_York';

% Start and end time for averaging period
start_day = datetime(2024,6,1,"TimeZone", plot_timezone);
end_day = datetime(2024,7,1, "TimeZone", plot_timezone);
run_days = start_day:end_day;

% Tempo scans to be processed
scans = [8,9,10,11];

% Load Tempo and Tropomi Files
tempo_files = table2timetable(tempo_table('/mnt/disks/data-disk/data/tempo_data'));
tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);

tropomi_files = table2timetable(tropomi_table('/mnt/disks/data-disk/data/tropomi_data/'));
tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);

% data_save_path = '/mnt/disks/data-disk/data/merged_data/non_temporal/working';
data_save_path = '/mnt/disks/data-disk/data/merged_data/non_temporal/testing';


% Lat and lon bounds for processing data
% lat_bounds = [39 40]; % baltimore
% lon_bounds = [-77 -76];
% suffix = '_TEST';

% lat_bounds = [38 40]; % maryland
% lon_bounds = [-78 -75.8];
% suffix = '_MARYLAND';

% lat_bounds = [40.4 41.3]; % new york city
% lon_bounds = [-74.6 -72.7];
% suffix = '_NYC';

lat_bounds = [[38 40];...
              [40.4 41.3]];
lon_bounds = [[-78 -75.8];...
              [-74.6 -72.7]];
suffix = '';

% lat_bounds = [38 41.3]; %
% lon_bounds = [-78 -72.7];
% suffix = '_TEST_big';


% Time window for interpolation operator, think about adding as argument to function
time_window = minutes(30);

% Correlation length in km
L = 30; 

% Set up dimensions for Tempo and Tropomi data
tempo_dim = [2100, 500];
trop_dim = [500 4200];

tic; % Start timer

% Loop over each day in period
for i = 1:length(run_days)
    current_day = run_days(i);
    day_period = timerange(current_day, current_day+days(1));

    disp(strjoin(['Processing data for', string(current_day)]))

    % Get all Tempo and Tropomi files on the current day
    tempo_files_day = tempo_files(day_period,:); 
    trop_files_day = tropomi_files(day_period,:);

    % If either is empty, skip this day
    if isempty(tempo_files_day) | isempty(trop_files_day)
        continue
    end

    % Initialize arrays to hold full day of Tropomi data
    trop_lat = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
    trop_lon = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
    trop_lat_corners = single(NaN(4,trop_dim(1),trop_dim(2),size(trop_files_day,1)));
    trop_lon_corners = single(NaN(4,trop_dim(1),trop_dim(2),size(trop_files_day,1)));
    trop_no2 = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
    trop_no2_u = NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1));
    trop_qa = single(NaN(trop_dim(1),trop_dim(2),size(trop_files_day,1)));
    trop_time = NaT(trop_dim(1),trop_dim(2),size(trop_files_day,1), 'TimeZone', 'UTC');

    % Loop over all Tropomi files on this day
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
    trop_lat = trop_lat(valid_ind_trop);
    trop_lon = trop_lon(valid_ind_trop);
    trop_lat_corners = trop_lat_corners(:,valid_ind_trop);
    trop_lon_corners = trop_lon_corners(:,valid_ind_trop);
    trop_no2 = trop_no2(valid_ind_trop);
    trop_no2_u = trop_no2_u(valid_ind_trop);
    trop_time = trop_time(valid_ind_trop);

    % Loop over each Tempo scan
    for j = 1:length(scans)
        scan = scans(j);

        disp(['Scan:', num2str(scan)])

        % Initialize arrays to hold all Tempo data for the current scan
        tempo_lat = single(NaN(tempo_dim));
        tempo_lon = single(NaN(tempo_dim));
        tempo_lat_corners = single(NaN(4,tempo_dim(1),tempo_dim(2)));
        tempo_lon_corners = single(NaN(4,tempo_dim(1),tempo_dim(2)));
        tempo_no2 = NaN(tempo_dim);
        tempo_no2_u = NaN(tempo_dim);
        tempo_qa = NaN(tempo_dim);
        tempo_cld = NaN(tempo_dim);
        tempo_sza = NaN(tempo_dim);
        tempo_time = NaT(tempo_dim, 'TimeZone', 'UTC');

        col_counter = 1;

        % Filter Tempo files pertaining to the current scan
        tempo_files_scan = tempo_files_day(tempo_files_day.Scan==scan,:);

        % If files are present for this scan, loop over them
        if ~isempty(tempo_files_scan)
            for k = 1:size(tempo_files_scan,1)
                tempo_data_temp = read_tempo_netcdf(tempo_files_scan(k,:));
                temp_lat = tempo_data_temp.lat;
                row = size(temp_lat,1);
                col = size(temp_lat,2);

                % Add data to holding arrays for current Tempo scan
                tempo_lat(1:row,col_counter:col_counter+col-1) = tempo_data_temp.lat;
                tempo_lon(1:row,col_counter:col_counter+col-1) = tempo_data_temp.lon;
                tempo_lat_corners(:,1:row,col_counter:col_counter+col-1) = tempo_data_temp.lat_corners;
                tempo_lon_corners(:,1:row,col_counter:col_counter+col-1) = tempo_data_temp.lon_corners;
                tempo_no2(1:row,col_counter:col_counter+col-1) = tempo_data_temp.no2 ./ conversion_factor('trop-tempo');
                tempo_no2_u(1:row,col_counter:col_counter+col-1) = tempo_data_temp.no2_u ./ conversion_factor('trop-tempo');
                tempo_qa(1:row,col_counter:col_counter+col-1) = tempo_data_temp.qa;
                tempo_cld(1:row,col_counter:col_counter+col-1) = tempo_data_temp.f_cld;
                tempo_sza(1:row,col_counter:col_counter+col-1) = tempo_data_temp.sza;
                tempo_time(1:row,col_counter:col_counter+col-1) = resize(tempo_data_temp.time', [row,col], 'Pattern', 'circular');

                col_counter = col_counter+col;
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
            tempo_lat = tempo_lat(valid_ind_tempo);
            tempo_lon = tempo_lon(valid_ind_tempo);
            tempo_lat_corners = tempo_lat_corners(:,valid_ind_tempo);
            tempo_lon_corners = tempo_lon_corners(:,valid_ind_tempo);
            tempo_no2 = tempo_no2(valid_ind_tempo);
            tempo_no2_u = tempo_no2_u(valid_ind_tempo);
            tempo_time = tempo_time(valid_ind_tempo);

            %% Beginning Kalman Filter Process
            % Number of Tempo and Tropomi measurements to merge
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

            % Correlation matrix 
            C = gaspari_cohn(dij ./ L);

            % Background (Tempo) error covariance function
            Pb = sqrt(D)' * C * sqrt(D);

            % Clear data no longer needed
            clear dij tempo_lat1 tempo_lat2 tempo_lon1 tempo_lon2

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
            save_data = struct;

            % Save Tempo data for current scan
            save_data.bg_no2 = NaN(tempo_dim);
            save_data.bg_no2_u = NaN(tempo_dim);
            save_data.bg_lat = NaN(tempo_dim);
            save_data.bg_lon = NaN(tempo_dim);
            save_data.bg_no2(valid_ind_tempo) = tempo_no2;
            save_data.bg_no2_u(valid_ind_tempo) = tempo_no2_u;
            save_data.bg_lat(valid_ind_tempo) = tempo_lat;
            save_data.bg_lon(valid_ind_tempo) = tempo_lon;
            save_data.bg_qa = tempo_qa;
            save_data.bg_cld = tempo_cld;

            % Save all of current day's Tempo data
            save_data.obs_no2 = NaN([trop_dim(1),trop_dim(2),size(trop_files_day,1)]);
            save_data.obs_no2_u = NaN([trop_dim(1),trop_dim(2),size(trop_files_day,1)]);
            save_data.obs_lat = NaN([trop_dim(1),trop_dim(2),size(trop_files_day,1)]);
            save_data.obs_lon = NaN([trop_dim(1),trop_dim(2),size(trop_files_day,1)]);
            save_data.obs_no2(valid_ind_trop) = trop_no2;
            save_data.obs_no2_u(valid_ind_trop) = trop_no2_u;
            save_data.obs_lat(valid_ind_trop) = trop_lat;
            save_data.obs_lon(valid_ind_trop) = trop_lon;
            save_data.obs_qa = trop_qa;

            % Save analyzed data
            save_data.analysis_no2 = NaN(tempo_dim);
            save_data.analysis_no2_u = NaN(tempo_dim);
            save_data.analysis_no2(valid_ind_tempo) = Xa;
            save_data.analysis_no2_u(valid_ind_tempo) = diag(Pa);
            save_data.bg_time = tempo_time;
            save_data.obs_time = trop_time;

            % save_data.tempo_time = tempo_temp.Date;

            save_data.tempo_scan = scan;

            % maybe list the present granules
            % save_data.tempo_granule = tempo_temp.Granule;

            savename = ['TEMPO_TROPOMI_merged_', char(datetime(current_day, 'Format', 'uuuuMMdd')), '_S', num2str(scan), suffix, '.mat'];
            save(fullfile(data_save_path, savename), "save_data", '-mat');
            disp([savename, ' saved']);
            fprintf('\n')
        end
    end
end

% Display processing time in minutes
processing_time = toc./60;
disp(['Total time: ', num2str(processing_time), ' minutes'])