clearvars; clc; close all;

table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
load(table_path);

states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');
states_low_res = readgeotable("usastatehi.shp");
tracts = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_24_tract_500k/cb_2023_24_tract_500k.shp');

% plot_timezone = 'UTC';
plot_timezone = 'America/New_York';

day = datetime(2024, 5, 13, 'TimeZone', plot_timezone);
day_table = tempo_files_table(tempo_files_table.Level==2 & tempo_files_table.Date>=day & ...
    tempo_files_table.Date<day+days(1),:);

bounds_lat = [24 50];
bounds_lon = [-125 -66];

color_lim = [0 90];
dim = [0, 0, 1200, 300];

% scans = sort(unique(day_table.Scan));
scans = 9;

for i = scans'
    scan_table = day_table(day_table.Scan==i, :);

    disp(['Plotting scan ', num2str(i)])

    fig = figure('Visible', 'off', 'Position', dim);
    t = tiledlayout(1, 2);
    
    % Plot SZA
    ax1 = nexttile;
    usamap(bounds_lat, bounds_lon);
    hold(ax1, 'on');
    for j = min(scan_table.Granule):max(scan_table.Granule)
        temp_file = scan_table(scan_table.Granule==j,:).Filename;
        temp_lat = ncread(temp_file, '/geolocation/latitude');
        temp_lon = ncread(temp_file, '/geolocation/longitude');
        temp_sza = ncread(temp_file, '/geolocation/solar_zenith_angle');
        surfm(temp_lat, temp_lon, temp_sza);
    end
    geoshow(ax1, states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
    setm(ax1, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off')
    title(ax1, 'Solar Zenith Angle')
    ax1.CLim = color_lim;

    hold(ax1, 'off')

    % Plot VZA
    ax2 = nexttile;
    usamap(bounds_lat, bounds_lon);
    hold(ax2, 'on');
    for j = min(scan_table.Granule):max(scan_table.Granule)
        temp_file = scan_table(scan_table.Granule==j,:).Filename;
        temp_lat = ncread(temp_file, '/geolocation/latitude');
        temp_lon = ncread(temp_file, '/geolocation/longitude');
        temp_vza = ncread(temp_file, '/geolocation/viewing_zenith_angle');
        surfm(temp_lat, temp_lon, temp_vza);
    end
    geoshow(ax2, states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);
    setm(ax2, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off')
    title(ax2, 'Viewing Zenith Angle')
    ax2.CLim = [color_lim];

    hold(ax2, 'off')

    cb = colorbar;
    cb.Layout.Tile = 'east';
    cb.Label.String = 'degrees';

    dt_est = datetime(scan_table.Date(1,:), "TimeZone", plot_timezone);

    title_string = strjoin(['TEMPO', string(dt_est), 'EST']);

    sgtitle(title_string)

    savename = strjoin(['TEMPO_VZA_SZA_', string(datetime(dt_est, 'Format', 'yyyy-MM-dd''T''HHmmss'))], '');
    save_path = '/mnt/disks/data-disk/figures/maps';

    resolution = 300;
    print(fig, fullfile(save_path, savename), '-dpng', ['-r' num2str(resolution)])

    close(fig);
end
