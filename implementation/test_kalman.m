clearvars; clc; close all;

tempo_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
tropomi_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tempo_rad_table_path);
load(tropomi_rad_table_path);

load('USA.mat');

plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');

lat_bounds = [40 40.5];
lon_bounds = [-76.5, -76];

tropomi_filename = "/mnt/disks/data-disk/data/tropomi_data/S5P_OFFL_L2__NO2____20240513T163121_20240513T181252_34111_03_020600_20240515T094133.nc";
tempo_filename = "/mnt/disks/data-disk/data/tempo_data/TEMPO_NO2_L2_V03_20240513T171448Z_S009G03.nc";

% Get file objects
tropomi_temp = tropomi_files_table(strcmp(tropomi_files_table.Filename,tropomi_filename),:);
tempo_temp = tempo_files_table(strcmp(tempo_files_table.Filename, tempo_filename),:);

% Load Tropomi data in lat and lon bounds
disp('Loading TROPOMI Data')
[rows_trop, cols_trop] = get_indices(tropomi_temp, lat_bounds, lon_bounds);
trop_dim = [rows_trop(end)-rows_trop(1)+1, cols_trop(end)-cols_trop(1)+1];
tropomi_temp_data = read_tropomi_netcdf(tropomi_temp, rows_trop, cols_trop);
trop_no2 = tropomi_temp_data.no2(:);
trop_lat = tropomi_temp_data.lat(:);
trop_lon = tropomi_temp_data.lon(:);
trop_no2_u = tropomi_temp_data.no2_u(:);
trop_qa = tropomi_temp_data.qa(:);
trop_time = tropomi_temp_data.time;
trop_time_avg = mean(trop_time);

% Load Tempo data in lat and lon bounds
disp('Loading TEMPO data')
[rows_tempo, cols_tempo] = get_indices(tempo_temp, lat_bounds, lon_bounds);
tempo_dim = [rows_tempo(end)-rows_tempo(1)+1, cols_tempo(end)-cols_tempo(1)+1];
tempo_temp_data = read_tempo_netcdf(tempo_temp, rows_tempo, cols_tempo);
tempo_no2 = tempo_temp_data.no2(:);
tempo_lat = tempo_temp_data.lat(:);
tempo_lon = tempo_temp_data.lon(:);
tempo_no2_u = tempo_temp_data.no2_u(:);
tempo_qa = tempo_temp_data.qa(:);
tempo_time = tempo_temp_data.time;
tempo_time_avg = mean(tempo_time);

% Number of Tropomi and Tempo values
n_tropomi = length(trop_no2);
n_tempo = length(tempo_no2);

% Create Observation transformation matrx
disp('Constructing H matrix')
H = observation_operator(tempo_lat, tempo_lon, trop_lat, trop_lon);

% Observation (Tropomi) error covariance matrix
disp('Constructing R matrix')
R = diag(trop_no2_u);

% Background (Tempo) diagonal variance matrix
disp('Constructing D matrix')
D = diag(tempo_no2_u);

% Create matrix containing distances between each point in Tempo data
disp('Constructing C matrix')
[tempo_lat1, tempo_lat2] = meshgrid(tempo_lat, tempo_lat);
[tempo_lon1, tempo_lon2] = meshgrid(tempo_lon, tempo_lon);

dij = distance(tempo_lat1, tempo_lon1, tempo_lat2, tempo_lon2);
dij = deg2km(dij);

% Correlation length
L = 30;

% Create Correlation matrix 
C = gaspari_cohn(dij./L);

% Background (Tempo) error covariance function
disp('Calculating background covariance matrix')
Pb = sqrt(D)' * C * sqrt(D);

% Calculate the innovation covariance
disp('Calculating S matrix')
S = H*Pb*H' + R;

% Kalman Gain
disp('Calculating Kalman gain')
K = Pb * H' / (S) ;

% Analysis update
disp('Calculating analysis')
innovation = trop_no2 - H*tempo_no2;
Xa = tempo_no2 + K * innovation;

% Analysis Error Covariance
Pa = (eye(length(Xa)) - K*H) * Pb;

% Compare background and analysis variances
diag_Pb = diag(Pb);
diag_Pa = diag(Pa);

u_reduction = diag_Pb - diag_Pa;

tempo_no2_interp = H * tempo_no2;
tempo_no2_interp_plt = reshape(tempo_no2_interp, trop_dim);

tempo_no2_plt = reshape(tempo_no2, tempo_dim);
tempo_lat_plt = reshape(tempo_lat, tempo_dim);
tempo_lon_plt = reshape(tempo_lon, tempo_dim);

trop_no2_plt = reshape(trop_no2, trop_dim);
trop_lat_plt = reshape(trop_lat, trop_dim);
trop_lon_plt = reshape(trop_lon, trop_dim);

analysis_no2_plt = reshape(Xa, tempo_dim);


%% Plots
disp('Producing figures')

save_path = '/mnt/disks/data-disk/figures/testing';

test_lengths = unique(dij(:));
test_c = gaspari_cohn(test_lengths./L);

clim_no2 = [0 10^16];
clim_no2_u = [0 10^16];

matrix_image(C, 'Correlation Matrix', fullfile(save_path, 'C'), 'hot') % models correlation between locations in background data
matrix_image(D, 'Background Variance Matrix', fullfile(save_path, 'D'), 'hot', clim_no2_u) % Diagonal matrix of background data variances
matrix_image(R, 'Observation Covariance Matrix', fullfile(save_path, 'R'), 'hot', clim_no2_u) % Diagonal matrix of observation data variances
matrix_image(Pb, 'Background Covariance Matrix', fullfile(save_path, 'Pb'), 'hot', clim_no2_u) % Background covariance data with correlation model incorporated
matrix_image(H, 'Observation Transformation Matrix', fullfile(save_path, 'H'), 'gray') % Observation transformation operator
matrix_image(S, 'Innovation Covariance Matrix', fullfile(save_path, 'S'), 'hot', clim_no2_u) % Innovation covariance matrix
matrix_image(K, 'Kalman Gain Matrix', fullfile(save_path, 'K'), USA, [-.5 .5]) % Determines weight of the innovation
matrix_image(Pa, 'Analysis Error Covariance', fullfile(save_path, 'Pa'), 'hot') % Analysis error covariance
create_and_save_fig_bar([diag_Pb diag_Pa], save_path, 'uncertainty_before_after', 'Variance', {'Background', 'Analysis'})
create_and_save_fig(test_lengths, gaspari_cohn(test_lengths./L), save_path, 'correlation_function', 'Correlation Function', '', 'Distance (km)')

make_map_fig(trop_lat_plt, trop_lon_plt, trop_no2_plt, lat_bounds, lon_bounds, fullfile(save_path, 'tropno2_orig'), 'TROPOMI NO2', clim_no2_u)
make_map_fig(tempo_lat_plt, tempo_lon_plt, tempo_no2_plt, lat_bounds, lon_bounds, fullfile(save_path, 'tempono2_orig'), 'TEMPO NO2', clim_no2_u)
make_map_fig(trop_lat_plt, trop_lon_plt, tempo_no2_interp_plt, lat_bounds, lon_bounds, fullfile(save_path, 'tempono2_interp'), 'Interpolated TEMPO NO2', clim_no2_u)

comparison_figure(tempo_lat_plt, tempo_lon_plt, tempo_no2_plt, trop_lat_plt, trop_lon_plt, trop_no2_plt, analysis_no2_plt, lat_bounds, lon_bounds, tempo_time_avg, trop_time_avg)


%% Functions 


function comparison_figure(bg_lat, bg_lon, xb, obs_lat, obs_lon, xo, xa, lat_bounds, lon_bounds, bg_time, obs_time)

    font_size = 16;
    resolution = 300;
    dim = [0, 0, 1200, 300];
    % clim = [0 10^16];
    clim = [min([xb(:); xo(:); xa(:)]), max([xb(:); xo(:); xa(:)])];

    states_low_res = readgeotable("usastatehi.shp");
    save_path = '/mnt/disks/data-disk/figures/testing';

    fig1_savename = 'comparison_result';
    fig1 = figure('Visible','off', 'Position', dim);
    tiledlayout(1,3, "TileSpacing", "none", "Padding", "compact");


    % First tile for TEMPO data
    ax1 = nexttile;
    usamap(lat_bounds, lon_bounds);
    surfm(bg_lat, bg_lon, xb);
    geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
    fontsize(font_size, 'points');
    title(['TEMPO ', string(bg_time)]);
    ax1.CLim = clim;
    setm(ax1, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');

    % Second tile for TROPOMI data
    ax2 = nexttile;
    usamap(lat_bounds, lon_bounds);
    surfm(obs_lat, obs_lon, xo);
    geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
    fontsize(font_size, 'points');
    title(['TROPOMI ', string(obs_time)]);
    ax2.CLim = clim;
    setm(ax2, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');

    % Third tile for Merged data
    ax3 = nexttile;
    usamap(lat_bounds, lon_bounds);
    surfm(bg_lat, bg_lon, xa);
    geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
    fontsize(font_size, 'points');
    title('Preliminary Merged Result');
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



