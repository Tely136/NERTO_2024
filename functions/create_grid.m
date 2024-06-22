function [lat_grid, lon_grid] = create_grid(lat_range, lon_range, lat_degree, lon_degree)

    lats = lat_range(1):lat_degree:lat_range(2);
    lons = lon_range(1):lon_degree:lon_range(2);

    [lat_grid, lon_grid] = meshgrid(lats, lons);

end