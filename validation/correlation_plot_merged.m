clearvars; close all; clc;

load('/mnt/disks/data-disk/NERTO_2024/validation/merged_data_timeseries.mat');
load('/mnt/disks/data-disk/data/pandora_data/pandora_data.mat');

comparison_table = table2timetable([merged_data_table table(NaN(size(merged_data_table,1),1), 'VariableNames', {'Pandora_NO2'})]);
comparison_table.Tempo_NO2 = comparison_table.Tempo_NO2 .* 10^6;
comparison_table.Tropomi_NO2 = comparison_table.Tropomi_NO2 .* 10^6;
comparison_table.Merged_NO2 = comparison_table.Merged_NO2 .* 10^6;

pandora_data = pandora_data(pandora_data.qa==0 |pandora_data.qa==0 |pandora_data.qa==10 | pandora_data.qa==11,:);
pandora_data = table2timetable(pandora_data);

time_threshold = minutes(30);

for i = 1:size(comparison_table,1)
    sat_time = comparison_table.time(i);
    site = comparison_table.Site(i);

    time_window = timerange(sat_time-time_threshold, sat_time+time_threshold);

    pandora_temp = pandora_data(time_window,:);
    pandora_temp = pandora_temp(strcmp(pandora_temp.Site, site),:);

    comparison_table.Pandora_NO2(i) = mean(pandora_temp.NO2, 'omitmissing') .* 10^6;
end

comparison_table = rmmissing(comparison_table);

%%
% g = fittype(@(a, x) a.*x);

save_path = '/mnt/disks/data-disk/figures/validation/merged';
bound = 600;


y_data = [comparison_table.Tempo_NO2 comparison_table.Tropomi_NO2 comparison_table.Merged_NO2];
x_data = repmat(comparison_table.Pandora_NO2, [1,size(y_data,2)]);

[tempo_p, tempo_gof] = fit(x_data(:,1), y_data(:,1), 'poly1');
tempo_fit = feval(tempo_p, x_data(:,1));
tempo_cor = corrcoef(comparison_table.Pandora_NO2, comparison_table.Tempo_NO2);
tempo_cor = tempo_cor(1,2);

[trop_p, trop_gof] = fit(x_data(:,2), y_data(:,2), 'poly1');
trop_fit = feval(trop_p, x_data(:,2));
trop_cor = corrcoef(comparison_table.Pandora_NO2, comparison_table.Tropomi_NO2);
trop_cor = trop_cor(1,2);

[merged_p, merged_gof] = fit(x_data(:,3), y_data(:,3), 'poly1');
merged_fit = feval(merged_p, x_data(:,3));
merged_cor = corrcoef(comparison_table.Pandora_NO2, comparison_table.Merged_NO2);
merged_cor = merged_cor(1,2);

% sprintf('\tSlope\tIntercept\tCorrelation')
% sprintf('TEMPO:\t%f2', tempo_fit(1))

create_and_save_fig_scatter_lines(x_data, y_data(:,[1 3]), save_path, 'test', '', {'TEMPO', 'TEMPO-TROPOMI Merged'}, 'PANDORA tropospheric NO2 (umol/m^2)', 'Satellite tropospheric NO2 (umol/m^2)', [0 bound], [0 bound], x_data, [tempo_fit merged_fit])

create_and_save_fig_scatter_lines(x_data, y_data, save_path, 'test2', '', {'TEMPO', 'TROPOMI', 'TEMPO-TROPOMI Merged'}, 'PANDORA tropospheric NO2 (umol/m^2)', 'Satellite tropospheric NO2 (umol/m^2)', [0 bound], [0 bound], x_data, [tempo_fit trop_fit merged_fit])


%% Functions

function create_and_save_fig_scatter_lines(x_data, y_data, path, name, ttext, leg, xtext, ytext, xbound, ybound, x_line, y_line, dim)
    arguments
        x_data
        y_data
        path
        name
        ttext = []
        leg = []
        xtext = []
        ytext = []
        xbound = []
        ybound = []
        x_line = []
        y_line = []
        dim = []
    end

    colors = [[0 0.4470 0.7410];...
              [0.8500 0.3250 0.0980];...
              [0.9290 0.6940 0.1250]];;


    lw = 2;
    font_size = 20;
    resolution = 300;

    if isempty(dim)
        dim = [0, 0, 1200, 900];
    end

    fig = figure('Visible', 'off', 'Position', dim);

    hold on;
    for i = 1:size(y_data,2)
        temp_x = x_data(:,i);
        temp_y = y_data(:,i);

        scatter(temp_x, temp_y, 50, colors(i,:),  'LineWidth', lw)
    end

    if ~isempty(x_line) & ~isempty(y_line)
        for i = 1:size(y_line,2)
            temp_x = x_line(:,i);
            temp_y = y_line(:,i);

            plot(temp_x, temp_y, 'Color', colors(i,:), 'LineWidth', lw)
        end
    end
    hold off;

    if ~isempty(xbound)
        xlim(xbound)
    end

    if ~isempty(ybound)
        ylim(ybound)
    end

    if ~isempty(leg)
        legend(leg, 'Location', 'northwest')
    end
    
    if ~isempty(ttext)
        title(ttext)
    end
    
    if ~isempty(xtext)
        xlabel(xtext)
    end
    
    if ~isempty(ytext)
        ylabel(ytext)
    end

    fontsize(font_size, 'points')

    save_path = fullfile(path, name);
    print(fig, save_path, '-dpng', ['-r' num2str(resolution)])

    close(fig);
end
