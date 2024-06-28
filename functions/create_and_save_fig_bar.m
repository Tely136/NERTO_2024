function create_and_save_fig_bar(data, path, name, ttext, leg, xtext, ytext, xbound, ybound, dim)
    arguments
        data
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


    font_size = 20;
    resolution = 300;

    if isempty(dim)
        dim = [0, 0, 1200, 900];
    end

    fig = figure('Visible', 'off', 'Position', dim);

    hold on;
    for i = 1:size(data,2)
        temp_data = data(:,i);

        bar(temp_data)
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
