clc; clearvars; close all;
% Maybe change plot area to larger than US to better show context


timezone = 'America/New_York';

% Start and end time for processing
year = 2024;
month = 5;
day = 25;
date = datetime(year, month, day, 'TimeZone', timezone);

t = timerange(date, date+days(1), "openright");

save_folder = '/mnt/disks/data-disk/figures/maps';

% Load Tempo and Tropomi Files
tempo_files = table2timetable(tempo_table('/mnt/disks/data-disk/data/tempo_data'));
tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);
tempo_files = tempo_files(t,:);

tropomi_files = table2timetable(tropomi_table('/mnt/disks/data-disk/data/tropomi_data/'));
tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);
tropomi_files = tropomi_files(t,:);

states = readgeotable('/mnt/disks/data-disk/NERTO_2024/misc/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');

clim = [0 100];

dim = [0, 0, 2000, 2000];
lw = 1.5;
font_size = 24;
resolution = 300;
cb_str = '$\mu mol/m^2$';

title_str = 'TEMPO';
fullpath = fullfile(save_folder, 'TEMPO.png');
fig = figure("Visible", "off", "Position", dim);
usamap('Conus');

no2 = NaN(2048, 132*size(tempo_files,1));

count = 1;
for i = 1:size(tempo_files,1)
    tempo_data = read_tempo_netcdf(tempo_files(i,:));

    temp_no2 = 10^6 .* tempo_data.no2 ./ conversion_factor('trop-tempo');
    temp_lat = tempo_data.lat;
    temp_lon = tempo_data.lon;

    temp_dim = size(temp_no2);

    no2(:, count:count+temp_dim(2)-1) = temp_no2;
    lat(:, count:count+temp_dim(2)-1) = temp_lat;
    lon(:, count:count+temp_dim(2)-1) = temp_lon;

    count = count + temp_dim(2);
end
hold on;

surfm(lat, lon, no2)
geoshow(states, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);

ax = gca;
setm(ax, 'Grid', 'off', 'MLabelParallel', 'south')
cb = colorbar;
cb.Label.String = cb_str;
cb.Label.Interpreter = 'latex';
colormap('jet')
ax.CLim = clim;
hold off;
title(title_str);
fontsize(font_size, 'points')
ax = gca;
exportgraphics(ax, fullpath, "Resolution", resolution)
close(fig);


title_str = 'TROPOMI';
fullpath = fullfile(save_folder, 'TROPOMI.png');
fig = figure("Visible", "off", "Position", dim);
usamap('Conus');

hold on;
for i = 1:size(tropomi_files,1)
    tropomi_data = read_tropomi_netcdf(tropomi_files(i,:));

    no2 = 10^6 .* tropomi_data.no2;
    lat = tropomi_data.lat;
    lon = tropomi_data.lon;

    surfm(lat, lon, no2)
end

geoshow(states, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);

ax = gca;
setm(ax, 'Grid', 'off', 'MLabelParallel', 'south')
cb = colorbar;
cb.Label.String = cb_str;
cb.Label.Interpreter = 'latex';
colormap('jet')
ax.CLim = clim;
hold off;
title(title_str);
fontsize(font_size, 'points')
ax = gca;
exportgraphics(ax, fullpath, "Resolution", resolution)
close(fig);