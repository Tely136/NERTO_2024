clearvars; clc; close all;


% Define distances and localization radius
distances = linspace(0, 100, 100); % Example distances
localization_radius = 50; % Example localization radius

% Normalize distances
normalized_distances = distances / localization_radius;

% Compute Gaspari-Cohn correlation values
spatial_correlation_values = gaspari_cohn(normalized_distances);


% Define time differences
time_differences = linspace(hours(0), hours(24), 100);
tau = hours(8);

% Normalize time differences
normalized_times = abs(time_differences ./ tau);

temporal_correlation_values = temporal_correlation(normalized_times);




lw = 2;
font_size = 20;
resolution = 300;

%% Spatial Correlation
fig = figure('Visible', 'off', 'Position', [0 0 1200 900]);

plot(distances, spatial_correlation_values, 'LineWidth', lw);

xlabel('Distance between measurements [km]')
ylabel('Correlation')
title('Spatial Correlation function - Gaspari Cohn Function')

fontsize(font_size, 'points')

path = '/mnt/disks/data-disk/figures/correlation';
name = 'spatial_correlation_function';
save_path = fullfile(path, name);
print(fig, save_path, '-dpng', ['-r' num2str(resolution)])

close(fig);


%% Temporal Correlation
fig = figure('Visible', 'off', 'Position', [0 0 1200 900]);

plot(time_differences, temporal_correlation_values, 'LineWidth', lw);

xlabel('Time difference between measurements [hours]')
ylabel('Correlation')
title('Temporal Correlation function - Exponential decay')

fontsize(font_size, 'points')

path = '/mnt/disks/data-disk/figures/correlation';
name = 'temporal_correlation_function';
save_path = fullfile(path, name);
print(fig, save_path, '-dpng', ['-r' num2str(resolution)])

close(fig);
