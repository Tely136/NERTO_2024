function is_intersecting = check_intersection(lat1, lon1, lat2, lon2)
    [xi, yi] = polyxpoly(lat1, lon1, lat2, lon2);

    is_intersecting = ~isempty(xi) & ~isempty(yi);
end