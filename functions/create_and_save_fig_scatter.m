function create_and_save_fig_scatter(x_data, y_data, path, name, ttext, leg, xtext, ytext, xbound, ybound, dim)
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
        dim = []
    end


    lw = 2;
    font_size = 20;
    resolution = 300;

    if isempty(dim)
        dim = [0, 0, 1200, 900];
    end

    fig = figure('Visible', 'off', 'Position', dim);

    hold on;
    for i = 1:size(x_data,2)
        temp_x = x_data(:,i);
        temp_y = y_data(:,i);

        scatter(temp_x, temp_y, 'LineWidth', lw)
    end
    hold off;

    if ~isempty(xbound)
        xlim(xbound)
    end

    if ~isempty(ybound)
        ylim(ybound)
    end

    if ~isempty(leg)
        legend(leg, 'Location', 'best')
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
