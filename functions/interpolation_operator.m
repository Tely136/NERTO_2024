function H = interpolation_operator(interpolation_struct, method)
    arguments
        interpolation_struct
        method
    end

    bg_lat = interpolation_struct.tempo_lat;
    bg_lon = interpolation_struct.tempo_lon;
    bg_lat_corners = interpolation_struct.tempo_lat_corners;
    bg_lon_corners = interpolation_struct.tempo_lon_corners;
    bg_time = interpolation_struct.tempo_time;
    obs_lat = interpolation_struct.trop_lat;
    obs_lat_corners = interpolation_struct.trop_lat_corners;
    obs_lon_corners = interpolation_struct.trop_lon_corners;
    obs_time = interpolation_struct.trop_time;

    time_window = interpolation_struct.time_window;

    switch method
        case 'bilinear'
            % Implement bilinear interpolation method here
            error('Bilinear interpolation not yet implemented.');

        case 'mean'
            n = numel(bg_lat);
            m = numel(obs_lat);

            valid_pixel = find(~isnan(bg_lat) & ~isnan(bg_lon));

            margin = 0.5;

            % Preallocate space for indices and values
            max_nonzeros = m * n;
            rows = zeros(max_nonzeros, 1);
            cols = zeros(max_nonzeros, 1);
            vals = zeros(max_nonzeros, 1);
            nz_count = 0;  % Counter for the number of non-zero entries

            for i = 1:m
                temp_obs_poly_lats = [obs_lat_corners(:,i); obs_lat_corners(1,i)];
                temp_obs_poly_lons = [obs_lon_corners(:,i); obs_lon_corners(1,i)];
                temp_obs_time = obs_time(i);

                % Spatial and temporal filters
                space_filter = (bg_lat >= min(temp_obs_poly_lats) - margin & bg_lat <= max(temp_obs_poly_lats) + margin) & ...
                               (bg_lon >= min(temp_obs_poly_lons) - margin & bg_lon <= max(temp_obs_poly_lons) + margin);
                time_filter = abs(temp_obs_time - bg_time) <= time_window;

                k = find(space_filter & time_filter);

                if ~isempty(k)
                    intersections = false(1, n);
                    for j = 1:numel(k)
                        pix = k(j);
                        if ismember(pix, valid_pixel)
                            temp_bg_poly_lats = [bg_lat_corners(:,pix); bg_lat_corners(1,pix)];
                            temp_bg_poly_lons = [bg_lon_corners(:,pix); bg_lon_corners(1,pix)];

                            if check_intersection(temp_bg_poly_lats, temp_bg_poly_lons, temp_obs_poly_lats, temp_obs_poly_lons)
                                intersections(pix) = true;
                            end
                        end
                    end
                    if any(intersections)
                        nnz_intersections = nnz(intersections);
                        nz_count = nz_count + nnz_intersections;
                        rows(nz_count-nnz_intersections+1:nz_count) = i;
                        cols(nz_count-nnz_intersections+1:nz_count) = find(intersections);
                        vals(nz_count-nnz_intersections+1:nz_count) = 1 / nnz_intersections;
                    end
                end
            end

            % Trim the preallocated vectors to the actual number of non-zeros
            rows = rows(1:nz_count);
            cols = cols(1:nz_count);
            vals = vals(1:nz_count);

            % Create the sparse matrix
            H = sparse(rows, cols, vals, m, n);
    end

    function is_intersecting = check_intersection(bg_poly_lats, bg_poly_lons, obs_poly_lats, obs_poly_lons)
        % Check if polygons intersect
        [xi, yi] = polyxpoly(bg_poly_lats, bg_poly_lons, obs_poly_lats, obs_poly_lons);
        is_intersecting = ~isempty(xi) && ~isempty(yi);
        if ~is_intersecting
            is_intersecting = any(inpolygon(bg_poly_lats, bg_poly_lons, obs_poly_lats, obs_poly_lons)) || ...
                              any(inpolygon(obs_poly_lats, obs_poly_lons, bg_poly_lats, bg_poly_lons));
        end
    end
end
