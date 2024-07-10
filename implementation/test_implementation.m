clearvars; clc; close all;

day = 20;
month = 5;
year = 2024;

plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');

tempo_files = tempo_table('/mnt/disks/data-disk/data/tempo_data');
tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2') & tempo_files.Date >= day_tz & tempo_files.Date < day_tz + days(1), :);
tropomi_files = tropomi_table('/mnt/disks/data-disk/data/tropomi_data/');
tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2') & tropomi_files.Date >= day_tz & tropomi_files.Date < day_tz + days(1), :);

data_save_path = '/mnt/disks/data-disk/data/merged_data';

% lat_bounds = [40 42]; % new york
% lon_bounds = [-75, -72];

lat_bounds = [39 40]; % maryland
lon_bounds = [-77 -76];


time_window = minutes(60);
L = 30; % correlation length in km


% Loop over tropomi files
for i = 1:size(tropomi_files,1)
    % Make sure tropomi has pixels at the desired location, otherwise skip loop
    tropomi_temp = tropomi_files(i,:);
    [rows_trop, cols_trop] = get_indices(tropomi_temp, lat_bounds, lon_bounds);

    if ~isempty(rows_trop) && ~isempty(cols_trop)
        disp(strjoin(['******** Loading TROPOMI File:', tropomi_temp.Filename, '********']))
        tropomi_temp_data = read_tropomi_netcdf(tropomi_temp, rows_trop, cols_trop);

        % Load tropomi data
        trop_no2 = tropomi_temp_data.no2;
        trop_dim = size(trop_no2);
        trop_no2 = trop_no2(:);
        trop_lat = tropomi_temp_data.lat(:);
        trop_lon = tropomi_temp_data.lon(:);
        trop_lat_corners = reshape(tropomi_temp_data.lat_corners, 4, []);
        trop_lon_corners = reshape(tropomi_temp_data.lon_corners, 4, []);
        trop_qa = tropomi_temp_data.qa(:);
        trop_no2_u = tropomi_temp_data.no2_u(:);
        trop_time = tropomi_temp_data.time;

        % Filter out low QA pixels
        % valid_trop = trop_qa >= 0.75;
        % trop_no2 = trop_no2(valid_trop);
        % trop_lat = trop_lat(valid_trop);
        % trop_lon = trop_lon(valid_trop);
        % trop_no2_u = trop_no2_u(valid_trop);

        % Ensure there are valid observations left after filtering
        if isempty(trop_no2)
            disp('No valid observations in range for this TROPOMI file')
            continue;
        end



        % Observation (Tropomi) error covariance matrix
        disp('Creating observation error covariance matrix')
        R = diag(trop_no2_u);

        % Average time of pixels at the location
        trop_time_avg = mean(trop_time);

        % Loop over tempo files 
        for j = 1:size(tempo_files,1)
            tempo_temp = tempo_files(j,:);
            [rows_tempo, cols_tempo] = get_indices(tempo_temp, lat_bounds, lon_bounds);

            % Make sure tempo files has pixels at the desired location
            if ~isempty(rows_tempo) && ~isempty(cols_tempo)

                tempo_temp_data = read_tempo_netcdf(tempo_temp, rows_tempo, cols_tempo);
                tempo_time = tempo_temp_data.time;

                % Average time of tempo pixels
                tempo_time_avg = mean(tempo_time);

                % Check if tempo file is within time window of tropomi, otherwise skip tempo file
                if abs(tempo_time_avg - trop_time_avg) <= time_window
                    disp(strjoin(['+++ Loading TEMPO file:', tempo_temp.Filename, '+++']))

                    tempo_no2 = tempo_temp_data.no2;
                    tempo_dim = size(tempo_no2);
                    tempo_no2 = tempo_no2(:);
                    tempo_lat = tempo_temp_data.lat(:);
                    tempo_lon = tempo_temp_data.lon(:);
                    tempo_lat_corners = reshape(tempo_temp_data.lat_corners, 4, []);
                    tempo_lon_corners = reshape(tempo_temp_data.lon_corners, 4, []);
                    tempo_qa = tempo_temp_data.qa(:);
                    tempo_no2_u = tempo_temp_data.no2_u(:);

                    % Filter out low QA pixels
                    % valid_tempo = tempo_qa == 0;
                    % tempo_no2 = tempo_no2(valid_tempo);
                    % tempo_lat = tempo_lat(valid_tempo);
                    % tempo_lon = tempo_lon(valid_tempo);
                    % tempo_no2_u = tempo_no2_u(valid_tempo);

                    % Ensure there are valid observations left after filtering
                    if isempty(tempo_no2)
                        disp('No valid observations in range for this TEMPO file')
                        continue;
                    end

                    % Regrid TEMPO data
                    % H_regrid = interpolation_operator(tempo_lat, tempo_lon, tempo_lat_corners, tempo_lon_corners, lat_grid_center, lon_grid_center, lat_grid_corners, lon_grid_corners, 'mean');

                    % Background (Tempo) diagonal variance matrix
                    disp('Creating background error covariance matrix')
                    D = diag(tempo_no2_u);

                    % Create matrix containing distances between each point in Tempo data
                    [tempo_lat1, tempo_lat2] = meshgrid(tempo_lat, tempo_lat);
                    [tempo_lon1, tempo_lon2] = meshgrid(tempo_lon, tempo_lon);

                    dij = distance(tempo_lat1, tempo_lon1, tempo_lat2, tempo_lon2);
                    dij = deg2km(dij);

                    % Correlation matrix 
                    C = gaspari_cohn(dij ./ L);

                    % Background (Tempo) error covariance function
                    Pb = sqrt(D)' * C * sqrt(D);

                    % Observation transformation matrix
                    disp('Calculating observation matrix')
                    H = interpolation_operator(tempo_lat, tempo_lon, tempo_lat_corners, tempo_lon_corners, trop_lat, trop_lon, trop_lat_corners, trop_lon_corners, 'mean');

                    % Kalman Gain
                    disp('Calculating Kalman Gain matrix')
                    K = Pb * H' / (H * Pb * H' + R);

                    % Analysis update
                    disp('Calculating analysis update')
                    Xa = tempo_no2 + K * (trop_no2 - H * tempo_no2);

                    % Analysis Error Covariance
                    Pa = (eye(length(Xa)) - K * H) * Pb;

                    % Prepare data for saving
                    disp('Saving data')
                    save_data = struct;
                    save_data.bg_lat = reshape(tempo_lat, tempo_dim);
                    save_data.bg_lon = reshape(tempo_lon, tempo_dim);
                    save_data.obs_lat = reshape(trop_lat, trop_dim);
                    save_data.obs_lon = reshape(trop_lon, trop_dim);

                    save_data.bg_no2 = reshape(tempo_no2, tempo_dim);
                    save_data.obs_no2 = reshape(trop_no2, trop_dim);

                    save_data.bg_no2_u = reshape(tempo_no2_u, tempo_dim);
                    save_data.obs_no2_u = reshape(trop_no2_u, trop_dim);
                    save_data.analysis_no2_u = Pa;

                    save_data.analysis_no2 = reshape(Xa, tempo_dim);

                    save_data.bg_time = tempo_time;
                    save_data.obs_time = trop_time;

                    save_data.tempo_time = tempo_temp.Date;
                    save_data.tempo_scan = tempo_temp.Scan;
                    save_data.tempo_granule = tempo_temp.Granule;

                    savename = ['TEMPO_TROPOMI_merged_', char(datetime(tempo_temp.Date, 'Format', 'uuuuMMdd''T''HHmmss')), '_S', num2str(tempo_temp.Scan), 'G', num2str(tempo_temp.Granule), '.mat'];
                    save(fullfile(data_save_path, savename), "save_data", '-mat');
                    disp([savename, ' saved']);

                else
                    disp('Tempo files outside of time range');
                    continue;
                end
            else
                disp('Tempo files have no pixels in bounds');
                continue;
            end
        end
    else
        disp('Tropomi file has no pixels in bounds');
        continue;
    end
end
