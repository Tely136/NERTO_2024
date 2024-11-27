clc; clearvars; 

lat_bounds = [38.5 45.1];
lon_bounds = [-82 -71];

lat_bounds_ny = [40.49 41.16];
lon_bounds_ny = [-74.45 -73.36];

lat_bounds_bt = [39.12 39.42];
lon_bounds_bt = [-76.8 -76.41];

tempo_path = "C:\NERTO_drive\TEMPO_data";
tropomi_path = "C:\NERTO_drive\TROPOMI_data";
fig_path = "C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\figs2";
merged_path = "C:\NERTO_drive\merged_md_ny";

% tempo_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TEMPO_data";
% tropomi_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TROPOMI_data";
% merged_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\merged_data";
% fig_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\figs2";


% plot_results_avg('20230801','20230831', lat_bounds, lon_bounds, merged_path, fullfile(fig_path,'avg','202308'))
% plot_results_avg('20240801','20240831', lat_bounds, lon_bounds, merged_path, fullfile(fig_path,'avg','202408'), overwrite_on=true);

% load('C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\figs2\avg\202308\average_data.mat')


% correlation_plot2('C:\NERTO_drive\time_series_data\time_series_data.mat', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat', 'C:\NERTO_drive\correlations', 'C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\correlations', overwrite_on=false)
% correlation_plot('C:\NERTO_drive\time_series_data\time_series_data.mat', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat', 'C:\NERTO_drive\correlations', 'C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\correlations', overwrite_on=false)

% uncertainties('20230801', '20240831', tempo_path, tropomi_path, 'C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\uncertainties')

% Copy_of_no2_bias(lat_bounds, lon_bounds, '20230801', '20240831', tempo_path, tropomi_path, 'C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\bias', overwrite=true)
% Copy_of_no2_bias(lat_bounds_ny, lon_bounds_ny, '20230801', '20240831', tempo_path, tropomi_path, 'C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\bias_nyc', overwrite=true)
% Copy_of_no2_bias(lat_bounds_bt, lon_bounds_bt, '20230801', '20240831', tempo_path, tropomi_path, 'C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\bias_bt', overwrite=true)

%%
close all
ny = load('C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\bias_nyc\bias.mat');
no2_diff = ny.no2_diff * 10^6;
sza_diff = ny.sza_diff;
vza_diff = ny.vza_diff;
ttext = 'NYC';
filename = 'C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\bias_nyc\bias_nyc.png';
y_lim = [-500 800];

% bt = load('C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\bias_bt\bias.mat');
% no2_diff = bt.no2_diff * 10^6;
% sza_diff = bt.sza_diff;
% vza_diff = bt.vza_diff;
% ttext = 'Baltimore';
% filename = 'C:\Users\Thomas\OneDrive - The City College of New York\NERTO Data\bias_bt\bias_bt.png';
% y_lim = [-150 250];

angle_bins = -90:5:90;
no2_diff_sza_plt = NaN(1, length(angle_bins)-1);
no2_diff_vza_plt = NaN(1, length(angle_bins)-1);
angle_plt = NaN(1, length(angle_bins)-1);

for i = 1:length(angle_bins)-1
    angle1 = angle_bins(i);
    angle2 = angle_bins(i+1);

    sza_ind = sza_diff >= angle1 & sza_diff < angle2;
    vza_ind = vza_diff >= angle1 & vza_diff < angle2;

    no2_diff_sza_plt(i) = mean(no2_diff(sza_ind));
    no2_diff_vza_plt(i) = mean(no2_diff(vza_ind));
    angle_plt(i) = (angle1+angle2)/2;

    a=find(sza_ind);
    b=find(vza_ind);

end


%%
close all;

sz = 24;
lw = 1.3;

figure('Position', [0 0 2000 800]);
hold on
scatter(sza_diff, no2_diff, sz, "LineWidth", lw)
scatter(vza_diff, no2_diff, sz, "LineWidth", lw)
hold off
legend('Solar Zenith Angle', 'Viewing Zenith Angle')
xlabel('Angle difference (TEMPO - TROPOMI) [degrees]')
ylabel(['Retreived NO_{2} column difference', newline, '(TEMPO - TROPOMI) [\mumol/m^2]'])
title(ttext)
xlim([-20 50])
ylim(y_lim)
fontsize(18, 'points')

ax = gca;
exportgraphics(ax, filename, "Resolution", 600)