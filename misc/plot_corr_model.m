clearvars; clc; close all;

% L = 10; % correlation length in km
% dij = 0:.1:50;
% C = exp((-dij.^2)./(2*L^2));

% Define distances and localization radius
distances = linspace(0, 3, 100); % Example distances
localization_radius = 1.0; % Example localization radius

% Normalize distances
normalized_distances = distances / localization_radius;

% Compute Gaspari-Cohn correlation values
correlation_values = gaspari_cohn(normalized_distances);



lw = 2;
font_size = 20;
resolution = 300;

fig = figure('Visible', 'off', 'Position', [0 0 1200 900]);

plot(distances, correlation_values, 'LineWidth', lw);

xlabel('')
ylabel('')
title('Correlation function')

fontsize(font_size, 'points')

path = '/mnt/disks/data-disk/figures/correlation';
name = 'correlation_function';
save_path = fullfile(path, name);
print(fig, save_path, '-dpng', ['-r' num2str(resolution)])

close(fig);
