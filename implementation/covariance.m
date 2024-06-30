clearvars; clc; close all;

tempo_table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
tropomi_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tempo_table_path);
load(tropomi_table_path);

day = 13;
month = 5;
year = 2024;

plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');

lat_bounds = [38 40]; % maryland
lon_bounds = [-78, -76];

% lat_bounds = [36 42]; % larger area
% lon_bounds = [-79, -75];

time_window = minutes(30);
L = 30; % correlation length in km

tempo_no2_table = tempo_files_table(strcmp(tempo_files_table.Product, 'NO2') & tempo_files_table.Date >= day_tz & tempo_files_table.Date < day_tz + days(1), :);
tropomi_no2_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'NO2') & tropomi_files_table.Date >= day_tz & tropomi_files_table.Date < day_tz + days(1), :);

% Loop over tropomi files
for i = 1:size(tropomi_no2_table,1)
    % make sure tropomi has pixels at the desired location, otherwise skip loop
    tropomi_temp = tropomi_no2_table(i,:);
    [rows_trop, cols_trop] = get_indices(tropomi_temp, lat_bounds, lon_bounds);

    if ~isempty(rows_trop) | ~isempty(cols_trop)
        tropomi_temp_data = read_tropomi_netcdf(tropomi_temp, rows_trop, cols_trop);

        % Load tropomi data
        trop_no2 = tropomi_temp_data.no2;
        trop_dim = size(trop_no2);
        trop_no2 = trop_no2(:);
        trop_lat = tropomi_temp_data.lat(:);
        trop_lon = tropomi_temp_data.lon(:);
        trop_qa = tropomi_temp_data.qa(:);
        trop_no2_u = tropomi_temp_data.no2_u(:);
        trop_time = tropomi_temp_data.time;

        % Observation (Tropomi) error covariance matrix
        R = diag(trop_no2_u);

        % Average time of pixels at the location
        trop_time_avg = mean(trop_time);

        % Loop over tempo files 
        for j = 1:size(tempo_no2_table,1)
            tempo_temp = tempo_no2_table(j,:);
            [rows_tempo, cols_tempo] = get_indices(tempo_temp, lat_bounds, lon_bounds);

            % Make sure tempo files has pixels at the desired location
            if ~isempty(rows_tempo) | ~isempty(cols_tempo)

                tempo_temp_data = read_tempo_netcdf(tempo_temp, rows_tempo, cols_tempo);
                tempo_time = tempo_temp_data.time;

                % Average time of tempo pixels
                tempo_time_avg = mean(tempo_time);

                % Check if tempo file is within time window of tropomi, otherwise skip tempo file
                if abs(tempo_time_avg - trop_time_avg) <= time_window
                    disp(strjoin(['Merging file:', tempo_temp.Filename]))

                    tempo_no2 = tempo_temp_data.no2;
                    tempo_dim = size(tempo_no2);
                    tempo_no2 = tempo_no2(:);
                    tempo_lat = tempo_temp_data.lat(:);
                    tempo_lon = tempo_temp_data.lon(:);
                    tempo_qa = tempo_temp_data.qa(:);
                    tempo_no2_u = tempo_temp_data.no2_u(:);

                    % Background (Tempo) diagonal variance matrix
                    D = diag(tempo_no2_u);

                    % Create matrix containing distances between each point in Tempo data
                    [tempo_lat1, tempo_lat2] = meshgrid(tempo_lat, tempo_lat);
                    [tempo_lon1, tempo_lon2] = meshgrid(tempo_lon, tempo_lon);

                    dij = distance(tempo_lat1, tempo_lon1, tempo_lat2, tempo_lon2);
                    dij = deg2km(dij);

                    % Correlation matrix 
                    C = gaspari_cohn(dij./L);

                    % Background (Tempo) error covariance function
                    Pb = sqrt(D)' * C * sqrt(D);

                    % Observation transformation matrix
                    H = observation_operator(tempo_lat, tempo_lon, trop_lat, trop_lon);

                    % Kalman Gain
                    K = Pb * H' / (H*Pb*H' + R) ;

                    % Analysis update
                    Xa = tempo_no2 + K * (trop_no2 - H*tempo_no2);

                    comparison_figure(tempo_lat, tempo_lon, tempo_no2, trop_lat, trop_lon, trop_no2, Xa, tempo_dim, trop_dim, lat_bounds, lon_bounds, tempo_time_avg)

                else
                    disp('Tempo files outside of time range')
                    continue
                end
            else
                disp('Tempo files has no pixels in bounds')
                continue
            end
        end
    else
        disp('Tropomi file has no pixels in bounds')
        continue
    end
    break
end



%%

function comparison_figure(bg_lat, bg_lon, xb, obs_lat, obs_lon, xo, xa, bg_dim, obs_dim, lat_bounds, lon_bounds, time)
    bg_lat = reshape(bg_lat, bg_dim);
    bg_lon = reshape(bg_lon, bg_dim);
    xb = reshape(xb, bg_dim);

    obs_lat = reshape(obs_lat, obs_dim);
    obs_lon = reshape(obs_lon, obs_dim);
    xo = reshape(xo, obs_dim);

    xa = reshape(xa, bg_dim);

    font_size = 20;
    resolution = 300;
    dim = [0, 0, 1200, 300];
    % clim = [0 10^16];
    clim = [min([xb(:); xo(:); xa(:)]), max([xb(:); xo(:); xa(:)])];

    states_low_res = readgeotable("usastatehi.shp");
    save_path = '/mnt/disks/data-disk/figures';

    fig1_savename = 'comparison_result';
    fig1 = figure('Visible','off', 'Position', dim);
    tiledlayout(1,3, "TileSpacing", "none", "Padding", "compact");
    sgtitle(string(time))


    % First tile for TEMPO data
    ax1 = nexttile;
    usamap(lat_bounds, lon_bounds);
    surfm(bg_lat, bg_lon, xb);
    geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
    fontsize(font_size, 'points');
    title('TEMPO');
    ax1.CLim = clim;
    setm(ax1, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');

    % Second tile for TROPOMI data
    ax2 = nexttile;
    usamap(lat_bounds, lon_bounds);
    surfm(obs_lat, obs_lon, xo);
    geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
    fontsize(font_size, 'points');
    title('TROPOMI');
    ax2.CLim = clim;
    setm(ax2, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');

    % Third tile for Merged data
    ax3 = nexttile;
    usamap(lat_bounds, lon_bounds);
    surfm(bg_lat, bg_lon, xa);
    geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
    fontsize(font_size, 'points');
    title('Merged');
    ax3.CLim = clim;
    setm(ax3, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');

    % Add colorbar
    cb = colorbar;
    cb.Layout.Tile = 'east';

    colormap('jet')

    fullpath = fullfile(save_path, fig1_savename);
    print(fig1, fullpath, '-dpng', ['-r' num2str(resolution)])
    close(fig1);
end