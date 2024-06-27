clearvars; clc; close all;
% addpath('functions/')

tempo_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat';
tropomi_rad_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tempo_rad_table_path);
load(tropomi_rad_table_path);

baltimore_lat = 39.3; baltimore_lon = -76.6;

plot_timezone = 'America/New_York';

conversion_factor = 6.022 .* 10.^19; % convert from mol/m^2 to particle/cm^2

start_day = 13; start_month = 5; start_year = 2024;
end_day = 1; end_month = 6; end_year = 2024;

start_date = datetime(start_year, start_month, start_day, 'TimeZone', plot_timezone);
start_date_utc = datetime(start_year, start_month, start_day, 'TimeZone', 'UTC');

end_date = datetime(end_year, end_month, end_day, 'TimeZone', plot_timezone);
end_date_utc = datetime(end_year, end_month, end_day, 23, 59, 59, 'TimeZone', 'UTC');

tropomi_no2_files = tropomi_files_table(strcmp(tropomi_files_table.Product,'NO2') & tropomi_files_table.Date>=start_date_utc & ...
    tropomi_files_table.Date<=end_date_utc,:);


tempo_times = NaT(0, 'TimeZone', plot_timezone);
tropomi_times = NaT(0, 'TimeZone', plot_timezone);

tempo_sza = NaN(0);
tropomi_sza = NaN(0);

tempo_vza = NaN(0);
tropomi_vza = NaN(0);
for i = 1:size(tropomi_no2_files,1)
    disp(['Starting TROPOMI file: ', num2str(i), ' out of ', num2str(size(tropomi_no2_files,1))])
    temp_trop_filename = tropomi_no2_files.Filename(i);

    temp_trop_data = read_tropomi_netcdf(temp_trop_filename, baltimore_lat,  baltimore_lon);
    if isempty(temp_trop_data)
        disp('skipping file')
        continue
    end
    temp_trop_sza = temp_trop_data.sza;
    temp_trop_vza = temp_trop_data.vza;
    temp_trop_time = temp_trop_data.time;

    day_start = dateshift(temp_trop_time, 'start', 'day');

    temp_tempo_no2_files = tempo_files_table(strcmp(tempo_files_table.Product,'NO2') & tempo_files_table.Date>=day_start & ...
        tempo_files_table.Date<=(day_start+hours(24)),:);

    n_tempo_files = size(temp_tempo_no2_files,1);
    temp_tempo_time = NaT(1, n_tempo_files, 'TimeZone', 'UTC');
    temp_tempo_sza = NaN(1, n_tempo_files);
    temp_tempo_vza = NaN(1, n_tempo_files);
    for j = 1:n_tempo_files
        temp_tempo_filename = temp_tempo_no2_files.Filename(j);
        temp_tempo_data = read_tempo_netcdf(temp_tempo_filename, baltimore_lat, baltimore_lon);
        temp_tempo_sza(j) = temp_tempo_data.sza;
        temp_tempo_vza(j) = temp_tempo_data.vza;
        temp_tempo_time(j) = temp_tempo_data.time;
    end

    time_diff = abs(temp_trop_time - temp_tempo_time);
    [~, min_index] = min(time_diff);

    if time_diff(min_index) <= minutes(30)

        tempo_times(end+1) = temp_tempo_time(min_index);
        tropomi_times(end+1) = temp_trop_time;

        tempo_sza(end+1) = temp_tempo_sza(min_index);
        tropomi_sza(end+1) = temp_trop_sza;

        tempo_vza(end+1) = temp_tempo_vza(min_index);
        tropomi_vza(end+1) = temp_trop_vza;
    end

    % break
end

%%

lw = 2;
font_size = 20;
resolution = 300;
dim = [0, 0, 1200, 900];
save_path = '/mnt/disks/data-disk/figures/angles';

fig = figure('Visible','off', 'Position', dim);

hold on;

plot(tropomi_times, tropomi_sza, 'LineWidth', lw, 'Marker', 'o')
plot(tropomi_times, tropomi_vza, 'LineWidth', lw, 'Marker', 'o')

plot(tempo_times, tempo_sza, 'LineWidth', lw, 'Marker', 'o')
plot(tempo_times, tempo_vza, 'LineWidth', lw, 'Marker', 'o')

hold off;

xlabel('Date')
ylabel('')

plot_start = datetime(2024, 5 ,13, 'TimeZone', plot_timezone);
plot_end = datetime(2024, 5, 29, 'TimeZone', plot_timezone);
% xlim([plot_start, plot_end])

legend('tropomi sza', 'tropomi vza', 'tempo sza', 'tempo vza', 'Location', 'southwest')

fontsize(font_size, 'points')

file_path = fullfile(save_path, 'overtime');
print(fig, file_path, '-dpng', ['-r' num2str(resolution)])

close(fig);