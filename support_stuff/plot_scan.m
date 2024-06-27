clearvars; clc;
set(0, 'DefaultFigureWindowStyle', 'docked')

data_path = '/mnt/disks/data-disk/data/tempo_data/L2';
files = dir(fullfile(data_path, '*.nc'));


date = datetime(2024, 3, 25, 'TimeZone', 'UTC');
scan = 3;

count = 1;
files_to_plot = strings(1,9);
for i = 1:length(files)
    temp_name = files(i).name;
    temp_name_split = strsplit(temp_name, '_');

    temp_date = datetime(temp_name_split(5), 'InputFormat', 'uuuuMMdd''T''HHmmssZ', 'TimeZone', 'UTC');
    temp_scan = char(temp_name_split(6));
    temp_scan = str2double(temp_scan(2:4));

    if temp_scan == scan && temp_date >= date && temp_date <= date + hours(24)
        files_to_plot(count) = temp_name;

        count = count + 1;
    end
end

%%
close all;

states = readgeotable("usastatehi.shp");

% fig = figure('Visible', 'off');
fig = figure;
usamap('conus');

hold on;

for i = 1:length(files_to_plot)
    if files_to_plot(i) == ""
        continue;
    end

    f = fullfile(data_path, files_to_plot(i));

    lat = ncread(f, '/geolocation/latitude');
    lon = ncread(f, '/geolocation/longitude');
    sza = ncread(f, '/geolocation/solar_zenith_angle');
    vza = ncread(f, '/geolocation/viewing_zenith_angle');
    no2 = ncread(f, '/product/vertical_column_troposphere');

    qa = ncread(f, '/product/main_data_quality_flag');

    no2(isnan(qa)) = NaN;
    no2(no2<0) = NaN;

    %surfacem(lat, lon, no2)
    surfm(lat, lon, no2)

    % surfacem(lat, lon, vza)

   
end

geoshow(states, 'FaceColor', [1 1 1], 'FaceAlpha', 0)

colormap('jet')
colorbar;
ax = gca;
% ax.CLim = [0 1*10^17];

hold off

% saveas(fig, 'my_plot', 'fig')
