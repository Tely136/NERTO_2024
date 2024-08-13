function fig = make_map_fig(lat, lon, param, lat_bounds, lon_bounds, fullpath,  title_str, cb_str, clim, markers, dim, cmap)
    arguments
        lat
        lon 
        param
        lat_bounds
        lon_bounds
        fullpath
        title_str
        cb_str = []
        clim = []
        markers = []
        dim = []
        cmap = []
    end

    % lw = 2;
    font_size = 30;
    resolution = 300;

    states_low_res = readgeotable("usastatehi.shp");
    % tracts = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_24_tract_500k/cb_2023_24_tract_500k.shp');

    if isempty(dim)
        fig = figure('Visible','off', 'Position', [0, 0, 1200, 900]);
    else
        fig = figure('Visible','off', 'Position', dim);
    end

    usamap(lat_bounds, lon_bounds);

    hold on;

    for i = 1:size(param,3)
        surfm(lat(:,:,i), lon(:,:,i), param(:,:,i))
    end

    geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);

    if ~isempty(markers)
        scatterm(markers.lat, markers.lon) 
    end

    ax = gca;
    setm(ax, 'Grid', 'off', 'MLabelParallel', 'south')
    cb = colorbar;
    cb.Label.String = cb_str;
    

    if isempty(cmap)
        colormap('jet')
    else
        colormap(cmap)
    end

    if ~isempty(clim)
        ax.CLim = clim;
    end

    hold off;

    title(title_str);

    fontsize(font_size, 'points')

    % print(fig, fullpath, '-dpng', ['-r' num2str(resolution)])
    ax = gca;
    exportgraphics(ax, fullpath, "Resolution", resolution)

    close(fig);
end