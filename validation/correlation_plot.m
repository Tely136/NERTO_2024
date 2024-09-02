function correlation_plot(satellite_data_input_path, pandora_data_input_path, data_output_path, fig_path)
    robust_setting = 'off';

    satellite_data = load(satellite_data_input_path);
    pandora_data = load(pandora_data_input_path);
    pandora_data = renamevars(pandora_data, {'Date', 'NO2'}, {'time','PANDORA_NO2'});

    save_path = fullfile(data_output_path, 'correlation.mat');

    varnames = {'Site', 'time', 'PANDORA_NO2', 'TEMPO_NO2', 'Merged_NO2', 'TROPOMI_NO2' };
    vartypes = {'string', 'datetime', 'double', 'double', 'double', 'double'};

    start_day = datetime(2023,8,1, "TimeZone", "UTC");
    end_day = datetime(2024,8,1,"TimeZone","UTC");

    t = timerange(start_day, end_day);

    if exist(save_path, "file")
        comparison_table = load(save_path);
    else
        pandora_data = table2timetable(pandora_data(:,{'time', 'Site','PANDORA_NO2'}));
        merged_data = table2timetable(satellite_data.merged_data_table(:, {'time', 'Site', 'TEMPO_NO2', 'Merged_NO2'}));
        tropomi_data = table2timetable(satellite_data.tropomi_data_table(:, {'time', 'Site', 'TROPOMI_NO2'}));

        pandora_data = pandora_data(t,:);
        merged_data = merged_data(t,:);
        tropomi_data = tropomi_data(t,:);

        pandora_data = groupsummary(pandora_data, {'Site', 'time'}, 'mean', 'PANDORA_NO2');
        merged_data = groupsummary(merged_data, {'Site', 'time'}, 'mean', {'TEMPO_NO2', 'Merged_NO2'});
        tropomi_data = groupsummary(tropomi_data, {'Site', 'time'}, 'mean', 'TROPOMI_NO2');

        pandora_data = table2timetable(pandora_data);
        merged_data = table2timetable(merged_data);
        tropomi_data = table2timetable(tropomi_data);

        comparison_table = table('Size', [size(merged_data,1), length(varnames)], 'VariableNames', varnames, 'VariableTypes', vartypes);
        comparison_table.time.TimeZone = 'UTC';

        time_threshold = minutes(30);
        % time_threshold = minutes(60);

        sites = unique(merged_data.Site);

        disp('Creating comparison table')
        counter = 1;
        for i = 1:length(sites)
            site = sites(i);

            if strcmp(site,'greenbelt32')
                continue
            end

            pandora_site = pandora_data(pandora_data.Site==site, {'mean_PANDORA_NO2'});
            merged_site = merged_data(merged_data.Site==site, {'mean_TEMPO_NO2', 'mean_Merged_NO2'});
            tropomi_site = tropomi_data(tropomi_data.Site==site, {'mean_TROPOMI_NO2'});

            synchronized_timetable = synchronize(pandora_site, merged_site, tropomi_site, 'regular', 'mean', 'TimeStep', time_threshold);

            len_table = size(synchronized_timetable,1);
            synchronized_timetable = [table(repmat(site, len_table, 1), 'VariableNames', {'Site'}) timetable2table(synchronized_timetable)];

            comparison_table(counter:counter+len_table-1,:) = synchronized_timetable;

            counter = counter+len_table;
            % break;
        end

        % comparison_table(isnan(comparison_table.TROPOMI_NO2),:) = [];
        comparison_table(counter+1:end,:) = [];
        % save(save_path, "comparison_table");
    end


    comparison_table = table2timetable(comparison_table);
    comparison_table(comparison_table.TEMPO_NO2<0 | comparison_table.Merged_NO2<0 | comparison_table.TROPOMI_NO2<0 | comparison_table.PANDORA_NO2<0,:) = [];
    comparison_table.TEMPO_NO2 = comparison_table.TEMPO_NO2.*10^6;
    comparison_table.Merged_NO2 = comparison_table.Merged_NO2.*10^6;
    comparison_table.TROPOMI_NO2 = comparison_table.TROPOMI_NO2.*10^6;
    comparison_table.PANDORA_NO2 = comparison_table.PANDORA_NO2.*10^6;

    sites = unique(comparison_table.Site);
    fits = NaN(length(sites), 3, 2);

    % Initialize a results table
    results_varnames = {'Site', 'Dataset', 'Slope', 'Intercept', 'CorrelationCoefficient'};
    results_vartypes = {'string', 'string', 'double', 'double', 'double'};
    results_table = table('Size', [0, length(results_varnames)], 'VariableNames', results_varnames, 'VariableTypes', results_vartypes);

    for i = 1:length(sites)
        site = sites(i);
        site_table = comparison_table(comparison_table.Site==site,:);

        tempo_comp = rmmissing(site_table(:, {'TEMPO_NO2', 'PANDORA_NO2'}));
        merged_comp = rmmissing(site_table(:, {'Merged_NO2', 'PANDORA_NO2'}));
        tropomi_comp = rmmissing(site_table(:, {'TROPOMI_NO2', 'PANDORA_NO2'}));

        maxval = max([tempo_comp.TEMPO_NO2; tropomi_comp.TROPOMI_NO2; merged_comp.Merged_NO2; tempo_comp.PANDORA_NO2; tropomi_comp.PANDORA_NO2; merged_comp.PANDORA_NO2]);
        x_data = tempo_comp.PANDORA_NO2;
        x_data(end+1) = maxval;
        
        [tempo_p, tempo_gof] = fit(tempo_comp.PANDORA_NO2, tempo_comp.TEMPO_NO2, 'poly1', 'Robust', robust_setting);
        tempo_fit = feval(tempo_p, x_data);
        tempo_cor = corrcoef(tempo_comp.PANDORA_NO2, tempo_comp.TEMPO_NO2);

        [merged_p, merged_gof] = fit(merged_comp.PANDORA_NO2, merged_comp.Merged_NO2, 'poly1', 'Robust', robust_setting);
        merged_fit = feval(merged_p, x_data);
        merged_cor = corrcoef(merged_comp.PANDORA_NO2, merged_comp.Merged_NO2);

        [tropomi_p, tropomi_gof] = fit(tropomi_comp.PANDORA_NO2, tropomi_comp.TROPOMI_NO2, 'poly1', 'Robust', robust_setting);
        tropomi_fit = feval(tropomi_p, x_data);
        tropomi_cor = corrcoef(tropomi_comp.PANDORA_NO2, tropomi_comp.TROPOMI_NO2);

        % Store results in the table
        results_table = [results_table; 
                        {site, 'TEMPO', tempo_p.p1, tempo_p.p2, tempo_cor(1, 2)};
                        {site, 'Merged', merged_p.p1, merged_p.p2, merged_cor(1, 2)};
                        {site, 'TROPOMI', tropomi_p.p1, tropomi_p.p2, tropomi_cor(1, 2)}];

        input = struct;
        input.tempo_comp = tempo_comp;
        input.tempo_fit = tempo_fit;

        input.merged_comp = merged_comp;
        input.merged_fit = merged_fit;

        input.tropomi_comp = tropomi_comp;
        input.tropomi_fit = tropomi_fit;

        input.x_data = x_data;

        filename = strjoin([site, '_correlation.png'],'');
        create_and_save_fig_scatter_lines(input, fig_path, filename, site, {'TEMPO', 'TROPOMI', 'Merged'}, 'PANDORA tropospheric NO2 (umol/m^2)', 'Satellite tropospheric NO2 (umol/m^2)', [], []);
        % break
    end

    md_sites = [1;1;0;1;1;0;0];
    ny_sites = [0;0;1;0;0;1;1];
    all_sites = [1;1;1;1;1;1;1];
    site_variations = logical(horzcat(md_sites, ny_sites, all_sites));

    cases = {'MD', 'NYC', 'All'};

    %do this for MD sites, NY sites and all sites
    for i = 1:3
        current_case = cases(i);
        current_sites = sites(site_variations(:,i));
        site_table = comparison_table(ismember(comparison_table.Site, current_sites),:);

        tempo_comp = rmmissing(site_table(:, {'TEMPO_NO2', 'PANDORA_NO2'}));
        merged_comp = rmmissing(site_table(:, {'Merged_NO2', 'PANDORA_NO2'}));
        tropomi_comp = rmmissing(site_table(:, {'TROPOMI_NO2', 'PANDORA_NO2'}));

        maxval = max([tempo_comp.TEMPO_NO2; tropomi_comp.TROPOMI_NO2; merged_comp.Merged_NO2; tempo_comp.PANDORA_NO2; tropomi_comp.PANDORA_NO2; merged_comp.PANDORA_NO2]);
        x_data = tempo_comp.PANDORA_NO2;
        x_data(end+1) = maxval;
        
        [tempo_p, tempo_gof] = fit(tempo_comp.PANDORA_NO2, tempo_comp.TEMPO_NO2, 'poly1', 'Robust', robust_setting);
        tempo_fit = feval(tempo_p, x_data);
        tempo_cor = corrcoef(tempo_comp.PANDORA_NO2, tempo_comp.TEMPO_NO2);

        [merged_p, merged_gof] = fit(merged_comp.PANDORA_NO2, merged_comp.Merged_NO2, 'poly1', 'Robust', robust_setting);
        merged_fit = feval(merged_p, x_data);
        merged_cor = corrcoef(merged_comp.PANDORA_NO2, merged_comp.Merged_NO2);

        [tropomi_p, tropomi_gof] = fit(tropomi_comp.PANDORA_NO2, tropomi_comp.TROPOMI_NO2, 'poly1', 'Robust', robust_setting);
        tropomi_fit = feval(tropomi_p, x_data);
        tropomi_cor = corrcoef(tropomi_comp.PANDORA_NO2, tropomi_comp.TROPOMI_NO2);

        % Store results in the table
        results_table = [results_table; 
                        {current_case, 'TEMPO', tempo_p.p1, tempo_p.p2, tempo_cor(1, 2)};
                        {current_case, 'Merged', merged_p.p1, merged_p.p2, merged_cor(1, 2)};
                        {current_case, 'TROPOMI', tropomi_p.p1, tropomi_p.p2, tropomi_cor(1, 2)}];


        input = struct;
        input.tempo_comp = tempo_comp;
        input.tempo_fit = tempo_fit;

        input.merged_comp = merged_comp;
        input.merged_fit = merged_fit;

        input.tropomi_comp = tropomi_comp;
        input.tropomi_fit = tropomi_fit;

        input.x_data = x_data;

        filename = strjoin([current_case, '_correlation.png'],'');
        create_and_save_fig_scatter_lines(input, fig_path, filename, current_case, {'TEMPO', 'TROPOMI', 'Merged'}, 'PANDORA tropospheric NO2 (umol/m^2)', 'Satellite tropospheric NO2 (umol/m^2)', [], []);
        % break
    end

    writetable(results_table, 'correlations.xlsx', 'Sheet',1)
end


function create_and_save_fig_scatter_lines(input, path, name, ttext, leg, xtext, ytext, xbound, ybound, dim)
    arguments
        input
        path
        name
        ttext = []
        leg = []
        xtext = []
        ytext = []
        xbound = []
        ybound = []
        dim = []
    end

    colors = [[0 0.4470 0.7410];...
            [0.8500 0.3250 0.0980];...
            [0.9290 0.6940 0.1250]];


    lw = 2;
    font_size = 20;

    if isempty(dim)
        dim = [0, 0, 1200, 900];
    end

    fig = figure('Visible', 'off', 'Position', dim);

    maxval = max([input.tempo_comp.TEMPO_NO2; input.tropomi_comp.TROPOMI_NO2; input.merged_comp.Merged_NO2; input.tempo_comp.PANDORA_NO2; input.tropomi_comp.PANDORA_NO2; input.merged_comp.PANDORA_NO2]);
    xlim([0 maxval]);
    ylim([0 maxval]);


    hold on;
    % Scatter plots
    scatter(input.tempo_comp.PANDORA_NO2, input.tempo_comp.TEMPO_NO2, 50, colors(1,:),  'LineWidth', lw);
    scatter(input.tropomi_comp.PANDORA_NO2, input.tropomi_comp.TROPOMI_NO2, 50, colors(2,:),  'LineWidth', lw);
    scatter(input.merged_comp.PANDORA_NO2, input.merged_comp.Merged_NO2, 50, colors(3,:),  'LineWidth', lw);

    % Linear fit lines
    plot(input.x_data, input.tempo_fit, 'Color', colors(1,:), 'LineWidth', lw);
    plot(input.x_data, input.tropomi_fit, 'Color', colors(2,:), 'LineWidth', lw);
    plot(input.x_data, input.merged_fit, 'Color', colors(3,:), 'LineWidth', lw);

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
    exportgraphics(fig, save_path, "Resolution", 300)

    close(fig);
end