clearvars; close all; clc;

load('/mnt/disks/data-disk/NERTO_2024/validation/tempo_time_series_data.mat');
load('/mnt/disks/data-disk/data/pandora_data/pandora_data.mat');
save_path = '/mnt/disks/data-disk/figures/validation/tempo_pandora_comparison';

comparison_table = table2timetable([data_table table(NaN(size(data_table,1),1), 'VariableNames', {'Pandora_NO2'})]);
comparison_table.TEMPO_NO2 = comparison_table.TEMPO_NO2 .* 10^6;

pandora_data = pandora_data(pandora_data.qa==0 |pandora_data.qa==1 |pandora_data.qa==10 | pandora_data.qa==11,:);
pandora_data = table2timetable(pandora_data);

time_threshold = minutes(30);

start_day = datetime(2024,6,1,'TimeZone', 'UTC');
end_day = datetime(2024,6,30,23,59,59, 'TimeZone', 'UTC');

period = timerange(start_day, end_day);

comparison_table = comparison_table(period,:);
comparison_table = comparison_table(strcmp(comparison_table.Site, 'ccny'),:);

comparison_table.TEMPO_NO2 = comparison_table.TEMPO_NO2 ./ conversion_factor('trop-tempo');
comparison_table.Uncertainty = comparison_table.Uncertainty ./ conversion_factor('trop-tempo');

disp('Creating table')
for i = 1:size(comparison_table,1)
    sat_time = comparison_table.time(i);
    site = comparison_table.Site(i);

    time_window = timerange(sat_time-time_threshold, sat_time+time_threshold);

    pandora_temp = pandora_data(time_window,:);
    pandora_temp = pandora_temp(strcmp(pandora_temp.Site, site),:);

    comparison_table.Pandora_NO2(i) = mean(pandora_temp.NO2, 'omitmissing') .* 10^6;
end

comparison_table = rmmissing(comparison_table);

error = comparison_table.Pandora_NO2 - comparison_table.TEMPO_NO2;
comparison_table = [comparison_table table(error, 'VariableNames', {'Error'})];

filter = comparison_table.QA==0 & comparison_table.Cld_frac<0.2 & comparison_table.SZA<70;
filtered_comparison_table = comparison_table(filter,:);


%%
disp ('Making plots')

dim = [0, 0, 1200, 900];
resolution = 300;

xlim = [0 1000];
ylim = [0 1000];

create_and_save_fig_scatter(filtered_comparison_table.Pandora_NO2, filtered_comparison_table.TEMPO_NO2, save_path, 'test.png', 'TEMPO Pandora Correlation', '','PANDORA tropNO2 [umol/m^2]', 'TEMPO tropNO2 [umol/m^2]', xlim, ylim);

% create_and_save_fig_scatter(comparison_table.Dist2Site, comparison_table.Error, save_path, 'dist.png', '', '','', 'tropNO2 Error (Pandora - TEMPO) [umol/m^2]', [], []);

% create_and_save_fig_scatter(comparison_table.Uncertainty, comparison_table.Error, save_path, 'uncertainty.png', '', '','', 'tropNO2 Error (Pandora - TEMPO) [umol/m^2]', [], []);

create_and_save_fig_scatter(comparison_table.VZA, comparison_table.Error, save_path, 'VZA.png', 'Viewing Zenith Angle Error Correlation', '','Viewing angle [degrees]', 'tropNO2 Error (Pandora - TEMPO) [umol/m^2]', [], []);

create_and_save_fig_scatter(comparison_table.SZA, comparison_table.Error, save_path, 'SZA.png', 'Solar Zenith Angle Error Correlation', '','Solar Zenith angle [degrees]', 'tropNO2 Error (Pandora - TEMPO) [umol/m^2]', [], []);

create_and_save_fig_scatter(comparison_table.Cld_frac, comparison_table.Error, save_path, 'cld.png', 'Cloud Fraction Error Correlation', '','Cloud fraction', 'tropNO2 Error (Pandora - TEMPO) [umol/m^2]', [], []);

fig = figure('Visible', 'off', 'Position', dim);
histogram(error)
title('TEMPO error histogram')
xlabel('tropNO2 error (Pandora - TEMPO)')
exportgraphics(gca, fullfile(save_path, 'histogram.png'), "Resolution", resolution)
close(fig);