clearvars; clc; close all;

day = 20;
month = 5;
year = 2024;


plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');

start_day = datetime(2024,6,1,"TimeZone", plot_timezone);
end_day = datetime(2024,6,2, "TimeZone", plot_timezone);

period = timerange(start_day, end_day, "openright");

tempo_files = table2timetable(tempo_table('/mnt/disks/data-disk/data/tempo_data'));
tempo_files = tempo_files(period,:);
tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);
% tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2') & tempo_files.Date >= day_tz & tempo_files.Date < day_tz + days(1), :);

tropomi_files = table2timetable(tropomi_table('/mnt/disks/data-disk/data/tropomi_data/'));
tropomi_files = tropomi_files(period,:);
tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);
% tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2') & tropomi_files.Date >= day_tz & tropomi_files.Date < day_tz + days(1), :);

data_save_path = '/mnt/disks/data-disk/data/merged_data';

% lat_bounds = [39.5 40]; % 
% lon_bounds = [-77 -76.5];

lat_bounds = [39 40]; % baltimore
lon_bounds = [-77 -76];

% lat_bounds = [38 40]; % maryland
% lon_bounds = [-78 -75.8];

time_window = minutes(60);
L = 30; % correlation length in km


for i = 1:size(tempo_files,1)
    tempo_temp = tempo_files(i,:);
    [rows_tempo, cols_tempo] = get_indices(tempo_temp, lat_bounds, lon_bounds);

    if isempty(rows_tempo) | isempty(cols_tempo)
        % Skip tempo file because it has no pixels in bounds
        continue
    else

        % think more about the matchup criteria for tempo and tropomi pixels
        % maybe just take out tropomi pixels that are too far away in time

        disp(strjoin(['+++ Loading TEMPO file:', tempo_temp.Filename, '+++']))
        tempo_temp_data = read_tempo_netcdf(tempo_temp, rows_tempo, cols_tempo);

        tempo_dim = [rows_tempo(2)-rows_tempo(1)+1 cols_tempo(2)-cols_tempo(1)+1];

        tempo_no2 = tempo_temp_data.no2(:) ./ conversion_factor('trop-tempo');
        tempo_no2_u = tempo_temp_data.no2_u(:) ./ conversion_factor('trop-tempo');
        tempo_lat = tempo_temp_data.lat(:);
        tempo_lon = tempo_temp_data.lon(:);
        tempo_lat_corners = reshape(tempo_temp_data.lat_corners, 4, []);
        tempo_lon_corners = reshape(tempo_temp_data.lon_corners, 4, []);
        tempo_qa = tempo_temp_data.qa(:);
        tempo_cld = tempo_temp_data.cld(:);
        tempo_sza = tempo_temp_data.sza(:);
        tempo_time = tempo_temp_data.time;
        tempo_time_avg = mean(tempo_time);

        tempo_qa_filter = tempo_no2>0 & tempo_qa==0 & tempo_sza<70 & tempo_cld < 0.2;

        % take out all data that has nan in no2 or no2_u for tempo and tropomi


        [y,m,d] = ymd(tempo_time_avg);
        temp_trop_files = tropomi_files(timerange(datetime(y,m,d, "TimeZone", plot_timezone), datetime(y,m,d+1, "TimeZone", plot_timezone), 'openright'),:);


        for j = 1:size(temp_trop_files,1)
            tropomi_temp = temp_trop_files(j,:);
            [rows_trop, cols_trop] = get_indices(tropomi_temp, lat_bounds, lon_bounds);

            if isempty(rows_trop) | isempty(cols_trop)
                disp('trop file not in bounds')
                % skip this tropomi file

            else
                tropomi_temp_data = read_tropomi_netcdf(tropomi_temp, rows_trop, cols_trop);
                trop_time = tropomi_temp_data.time;
                pixels_in_time = find(trop_time>=tempo_time_avg-time_window & trop_time<=tempo_time_avg+time_window);

                if isempty(pixels_in_time)
                    disp('no pixels in time window')

                else
                    trop_dim = [rows_trop(2)-rows_trop(1)+1, cols_trop(2)-cols_trop(1)+1];

                    trop_no2 = tropomi_temp_data.no2(:);
                    trop_no2_u = tropomi_temp_data.no2_u(:);
                    trop_lat = tropomi_temp_data.lat(:);
                    trop_lon = tropomi_temp_data.lon(:);
                    trop_lat_corners = reshape(tropomi_temp_data.lat_corners, 4, []);
                    trop_lon_corners = reshape(tropomi_temp_data.lon_corners, 4, []);
                    trop_qa = tropomi_temp_data.qa(:);

                    trop_qa_filter = trop_qa>=0.75;

                    if isempty(isempty(find(~isnan(tempo_no2), 1)))
                        disp('no valid tempo pixels')

                    elseif isempty(isempty(find(~isnan(trop_no2), 1)))
                        disp('no valid tropomi pixels')

                    else

                        % Observation (Tropomi) error covariance matrix
                        disp('Creating observation error covariance matrix')
                        R = diag(trop_no2_u);
                        
                        % Background (Tempo) error covariance matrix
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
                        save_data.bg_no2 = reshape(tempo_no2, tempo_dim);
                        save_data.bg_no2_u = reshape(tempo_no2_u, tempo_dim);
                        save_data.bg_lat = reshape(tempo_lat, tempo_dim);
                        save_data.bg_lon = reshape(tempo_lon, tempo_dim);
                        save_data.bg_qa = tempo_qa;
                        save_data.bg_cld = tempo_cld;

                        save_data.obs_no2 = reshape(trop_no2, trop_dim);
                        save_data.obs_no2_u = reshape(trop_no2_u, trop_dim);
                        save_data.obs_lat = reshape(trop_lat, trop_dim);
                        save_data.obs_lon = reshape(trop_lon, trop_dim);
                        save_data.obs_qa = trop_qa;


                        save_data.analysis_no2 = reshape(Xa, tempo_dim);
                        save_data.analysis_no2_u = reshape(diag(Pa), tempo_dim);

                        save_data.bg_time = tempo_time;
                        save_data.obs_time = trop_time;

                        save_data.tempo_time = tempo_temp.Date;
                        save_data.tempo_scan = tempo_temp.Scan;
                        save_data.tempo_granule = tempo_temp.Granule;

                        save_data.singular = singular;

                        savename = ['TEMPO_TROPOMI_merged_', char(datetime(tempo_temp.Date, 'Format', 'uuuuMMdd''T''HHmmss')), '_S', num2str(tempo_temp.Scan), 'G', num2str(tempo_temp.Granule), '.mat'];
                        save(fullfile(data_save_path, savename), "save_data", '-mat');
                        disp([savename, ' saved']);

                        break % just do one trop file for now
                    end
                end
            end
        end
    end
end