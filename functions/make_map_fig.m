function make_map_fig(lat, lon, param, lat_bounds, lon_bounds, fullpath,  title_str, markers)

    arguments
        lat
        lon 
        param
        lat_bounds
        lon_bounds
        fullpath
        title_str
        markers = []
    end
    % lw = 2;
    font_size = 20;
    resolution = 300;
    dim = [0, 0, 1200, 900];

    % lat_bounds = [min(lat(:)), max(lat(:))];
    % lon_bounds = [min(lon(:)), max(lon(:))];

    states_low_res = readgeotable("usastatehi.shp");
    % tracts = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_24_tract_500k/cb_2023_24_tract_500k.shp');


    fig = figure('Visible','off', 'Position', dim);

    usamap(lat_bounds, lon_bounds);
    % usamap('MD');

    hold on;

    surfm(lat, lon, param)
    geoshow(states_low_res, "DisplayType", "polygon", 'FaceAlpha', 0);

    if ~isempty(markers)
        scatterm(markers.lat, markers.lon) 
    end
    hold off;

    ax = gca;
    % setm(ax, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off')
    colorbar
    % ax.CLim = color_lim;

    title(title_str)
    fontsize(font_size, 'points')

    print(fig, fullpath, '-dpng', ['-r' num2str(resolution)])

    close(fig);
end