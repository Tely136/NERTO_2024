clearvars; clc; close all;

tempo_table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
tropomi_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tempo_table_path);
load(tropomi_table_path);

save_path = '/mnt/disks/data-disk/figures/angles';

baltimore_lat = 39.3;
baltimore_lon = -76.6;

plot_timezone = 'America/New_York';

day = datetime(2024, 5, 13, 'TimeZone', plot_timezone);

granule = 3;

tempo_day_table = tempo_files_table(tempo_files_table.Level==2 & tempo_files_table.Granule == granule & ...
    tempo_files_table.Date>=day & tempo_files_table.Date<day+days(1),:);
    
tropomi_day_table = tropomi_files_table(tropomi_files_table.Level==2 & tropomi_files_table.Date>=day & ...
    tropomi_files_table.Date<day+days(1),:);

%%

tempo_sza_b = NaN(1, size(tempo_day_table, 1));
tempo_vza_b = NaN(1, size(tempo_day_table, 1));
tempo_time_b = NaT(1, size(tempo_day_table, 1), 'TimeZone', plot_timezone);
tempo_sza_n = NaN(1, size(tempo_day_table, 1));
tempo_vza_n = NaN(1, size(tempo_day_table, 1));
tempo_time_n = NaT(1, size(tempo_day_table, 1), 'TimeZone', plot_timezone);

tropomi_sza_b = NaN(1, size(tropomi_day_table, 1));
tropomi_vza_b = NaN(1, size(tropomi_day_table, 1));
tropomi_time_b = NaT(1, size(tropomi_day_table, 1), 'TimeZone', plot_timezone);
tropomi_sza_n = NaN(1, size(tropomi_day_table, 1));
tropomi_vza_n = NaN(1, size(tropomi_day_table, 1));
tropomi_time_n = NaT(1, size(tropomi_day_table, 1), 'TimeZone', plot_timezone);

for i = 1:size(tempo_day_table, 1)
    temp_file = tempo_day_table.Filename(i,:);
    temp_date = tempo_day_table.Date(i,:);

    temp_lat = ncread(temp_file, '/geolocation/latitude');
    temp_lon = ncread(temp_file, '/geolocation/longitude');
    temp_sza = ncread(temp_file, '/geolocation/solar_zenith_angle');
    temp_vza = ncread(temp_file, '/geolocation/viewing_zenith_angle');
    temp_time = ncread(temp_file, '/geolocation/time'); temp_time = datetime(temp_time, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06', 'TimeZone', 'UTC');

    [baltimore_arclen, ~] = distance(temp_lat, temp_lon, baltimore_lat, baltimore_lon);

    [~, baltimore_min_i] = min(baltimore_arclen(:));

    [r_b, c_b] = ind2sub(size(baltimore_arclen), baltimore_min_i);

    if baltimore_lon >= min(temp_lon(r_b,:)) && baltimore_lon <= max(temp_lon(r_b,:)) % only add data if lon bounds include baltimore/NY  
        tempo_sza_b(i) = temp_sza(baltimore_min_i);
        tempo_vza_b(i) = temp_vza(baltimore_min_i);
        tempo_time_b(i) = temp_time(c_b); 
    end

end


for i = 1:size(tropomi_day_table,1)
    temp_file = tropomi_day_table.Filename(i,:);
    temp_date = tropomi_day_table.Date(i,:);

    temp_lat = ncread(temp_file, '/PRODUCT/latitude');
    temp_lon = ncread(temp_file, '/PRODUCT/longitude');
    temp_sza = ncread(temp_file, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/solar_zenith_angle');
    temp_vza = ncread(temp_file, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/viewing_zenith_angle');
    temp_time = ncread(temp_file, '/PRODUCT/time_utc'); temp_time = datetime(temp_time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z''', 'TimeZone', 'UTC');


    [baltimore_arclen, ~] = distance(temp_lat, temp_lon, baltimore_lat, baltimore_lon);

    [~, baltimore_min_i] = min(baltimore_arclen(:));

    [r_b, c_b] = ind2sub(size(baltimore_arclen), baltimore_min_i);

    tropomi_sza_b(i) = temp_sza(baltimore_min_i);
    tropomi_vza_b(i) = temp_vza(baltimore_min_i);
    tropomi_time_b(i) = temp_time(r_b);
end


%% Create Figures
close all;

lw = 2;
font_size = 20;
s = 100;
s2 = 10;
resolution = 300;
dim = [0, 0, 1200, 900];

start_time = day + hours(7);
end_time = day + hours(19);

% Single day plot Plot
fig = figure("Visible", "off", 'Position', dim);
hold on;

plot(tempo_time_b, tempo_vza_b ,"LineWidth", lw, 'Marker', 'o', 'MarkerSize', s2)
plot(tempo_time_b, tempo_sza_b, "LineWidth", lw, 'Marker', 'o', 'MarkerSize', s2)

scatter(tropomi_time_b, tropomi_vza_b, s, "LineWidth", lw)
scatter(tropomi_time_b, tropomi_sza_b, s, "LineWidth", lw)

hold off;

fontsize(font_size, 'points')
legend('TEMPO VZA', 'TEMPO SZA', 'TROPOMI VZA', 'TROPOMI SZA', 'Location', 'southwest')
xlabel('Time (EST)')
ylabel('Angle (degrees)')
title('TEMPO TROPOMI Viewing Geometry Comparison - Baltimore')
xlim([start_time end_time])
ylim([0 90])

savename = 'baltimore_geometry_comparison';
print(fig, fullfile(save_path, savename), '-dpng', ['-r' num2str(resolution)])
close(fig);