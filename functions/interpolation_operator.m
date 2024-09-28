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
    obs_lon = interpolation_struct.trop_lon;
    obs_lat_corners = interpolation_struct.trop_lat_corners;
    obs_lon_corners = interpolation_struct.trop_lon_corners;
    obs_time = interpolation_struct.trop_time;

    time_window = interpolation_struct.time_window;
    margin = interpolation_struct.search_area;

    switch method
        case 'bilinear'
            % Implement bilinear interpolation method here
            error('Bilinear interpolation not yet implemented.');

        case 'mean'
            % Number of observations and background points
            n = numel(bg_lat);
            m = numel(obs_lat);

            % Preallocate space for indices and values
            max_nonzeros = m * n;
            rows = zeros(max_nonzeros, 1);
            cols = zeros(max_nonzeros, 1);
            vals = zeros(max_nonzeros, 1);

            % Create TEMPO and TROPOMI polygons
            tempo_poly = repmat(polyshape, 1, n);
            trop_poly = repmat(polyshape, 1, m);

            for i = 1:n
                tempo_poly(1,i) = polyshape(bg_lon_corners(:,i), bg_lat_corners(:,i), 'Simplify', false, 'keepcollinearpoints', true);
            end
            for i = 1:m
                trop_poly(1,i) = polyshape(obs_lon_corners(:,i), obs_lat_corners(:,i), 'Simplify', false, 'keepcollinearpoints', true);
            end
            counter = 1;
            % Loop over all observations
            for i = 1:m
                temp_obs_time = obs_time(i);

                distances = distance(obs_lat(i), obs_lon(i), bg_lat, bg_lon);

                k = find(distances <= margin & abs(temp_obs_time - bg_time) <= time_window);

                if ~isempty(k)
                    TF = overlaps(trop_poly(i), tempo_poly(k));

                    overlap_ind = k(TF);
                    num_overlaps = numel(overlap_ind);

                    rows(counter:counter+num_overlaps-1) = i;
                    cols(counter:counter+num_overlaps-1) = overlap_ind;
                    vals(counter:counter+num_overlaps-1) = 1/num_overlaps;

                    counter = counter + num_overlaps;
                end
            end

            rows(counter:end) = [];
            cols(counter:end) = [];
            vals(counter:end) = [];

            % Create the sparse matrix
            H = sparse(rows, cols, vals, m, n);
    end
end
