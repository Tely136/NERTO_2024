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

    lw = 1.5;
    font_size = 30;
    resolution = 300;

    US_states = readgeotable('cb_2023_us_state_500k.shp');
    % NY_counties = readgeotable('cb_2023_36_cousub_500k.shp');
    % MD_counties = readgeotable('cb_2023_24_cousub_500k.shp');
    % DC_counties = readgeotable('cb_2023_11_cousub_500k.shp');

    if isempty(dim)
        fig = figure('Visible','off', 'OuterPosition', [0, 0, 1200, 900]);
    else
        fig = figure('Visible','off', 'OuterPosition', dim);
    end

    usamap(lat_bounds, lon_bounds);

    hold on;

    for i = 1:size(param,3)
        surfm(lat(:,:,i), lon(:,:,i), param(:,:,i))
    end

    geoshow(US_states, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
    % geoshow(NY_counties, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
    % geoshow(MD_counties, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
    % geoshow(DC_counties, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);

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

    axis equal;

    ax = gca;
    exportgraphics(ax, strjoin([fullpath, '.png'],''), "Resolution", resolution)

    if exist(strjoin([fullpath, '.fig'],''), "file")
        delete(strjoin([fullpath, '.fig'],''))
    end

    savefig(fig, strjoin([fullpath, '.fig'],''))

    close(fig);
end