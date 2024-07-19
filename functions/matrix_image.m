function matrix_image(M, title_str, fullpath, cmap, clim)
    arguments
        M
        title_str
        fullpath
        cmap
        clim = []
    end

    font_size = 14;
    resolution = 600;
    dim = [0, 0, 1200, 900];

    % fig = figure('Visible','off', 'Position', dim);
    fig = figure('Visible','off');

    imagesc(M)

    colorbar
    colormap(cmap)
    title(title_str)
    fontsize(font_size, 'points')

    ax = gca;
    ax.XTickLabel = {};
    ax.YTickLabel = {};
    % set(gca, 'ColorScale','log')

    if ~isnan(clim)
        ax.CLim = clim;
    end

    print(fig, fullpath, '-dpng', ['-r' num2str(resolution)])

    close(fig);
end