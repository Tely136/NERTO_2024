clearvars; clc; close all;
% set(0, 'DefaultFigureWindowStyle', 'docked')

table_path = '/mnt/disks/data-disk/NERTO_2024/files_table.mat';
load(table_path);

states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');
states_low_res = readgeotable("usastatehi.shp");
tracts = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_24_tract_500k/cb_2023_24_tract_500k.shp');

day = datetime(2024, 3, 25, 'TimeZone', 'UTC');
day_table = files_table(files_table.Date>=day & files_table.Date<day+days(1),:);


%%
close all;

bounds_lat = [38.5 40];
bounds_lon = [-78 -75];
scans = sort(unique(day_table.Scan));

fig = figure('Visible', 'off');
% t = tiledlayout('flow', 'TileSpacing', 'tight');

for i = scans'
    scan_table = day_table(day_table.Scan==i, :);

    disp(['Plotting scan ', num2str(i), ' of ', num2str(max(day_table.Scan))])

    nexttile;

    hold on;
    % usamap(bounds_lat, bounds_lon)
    usamap([24 50], [-125 -66])

    for j = min(scan_table.Granule):max(scan_table.Granule)

        temp_file = scan_table(scan_table.Granule==j,:).Filename;

        temp_lat = ncread(temp_file, '/geolocation/latitude');
        temp_lon = ncread(temp_file, '/geolocation/longitude');
        temp_sza = ncread(temp_file, '/geolocation/solar_zenith_angle');
        temp_vza = ncread(temp_file, '/geolocation/viewing_zenith_angle');

        temp_no2 = ncread(temp_file, 'product/vertical_column_troposphere');

        surfm(temp_lat, temp_lon, temp_sza)
    end

    %geoshow(states,"DisplayType","polygon", 'FaceAlpha', 0);
    %geoshow(tracts,"DisplayType","polygon", 'FaceAlpha', 0);
    geoshow(states_low_res,"DisplayType","polygon", 'FaceAlpha', 0);

    ax = gca;
    setm(ax, 'ParallelLabel', 'off', 'MeridianLabel', 'off')

    dt_est = datetime(scan_table.Date(1,:), "TimeZone", 'America/New_York');

    title(string(timeofday(dt_est)))
    hold off

    % break;
end

sgtitle(string(datetime(dt_est, 'Format', 'uuuu-MM-dd')))

resolution = 300;
print(fig, '/mnt/disks/data-disk/NERTO_2024/figures/test.png', '-dpng', ['-r' num2str(resolution)])

close(fig);
