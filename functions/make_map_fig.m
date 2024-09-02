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

    NY_counties = readgeotable('C:\Users\tely1\MATLAB Drive\NERTO\repo\misc\shapefiles\cb_2023_36_cousub_500k\cb_2023_36_cousub_500k.shp');
    MD_counties = readgeotable('C:\Users\tely1\MATLAB Drive\NERTO\repo\misc\shapefiles\cb_2023_24_cousub_500k\cb_2023_24_cousub_500k.shp');
    DC_counties = readgeotable('C:\Users\tely1\MATLAB Drive\NERTO\repo\misc\shapefiles\cb_2023_11_cousub_500k\cb_2023_11_cousub_500k.shp');

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

    geoshow(NY_counties, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
    geoshow(MD_counties, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
    geoshow(DC_counties, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);

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

    ax = gca;
    exportgraphics(ax, fullpath, "Resolution", resolution)

    close(fig);
end