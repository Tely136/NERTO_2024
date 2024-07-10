function H = interpolation_operator(bg_lat, bg_lon, bg_lat_corners, bg_lon_corners, obs_lat, obs_lon, obs_lat_corners, obs_lon_corners, method)
    arguments
        bg_lat
        bg_lon
        bg_lat_corners
        bg_lon_corners
        obs_lat
        obs_lon
        obs_lat_corners
        obs_lon_corners
        method
    end

    switch method
        case 'bilinear'

        case 'mean'
            n = numel(bg_lat);
            m = numel(obs_lat);

            valid_pixel = find(~isnan(bg_lat) & ~isnan(bg_lon));

            margin = .5;

            H = zeros(m,n);

            for i = 1:m
                temp_obs_lat_corners = obs_lat_corners(:,i);
                temp_obs_lon_corners = obs_lon_corners(:,i);

                temp_obs_poly_lats = [temp_obs_lat_corners(1) temp_obs_lat_corners(2) temp_obs_lat_corners(3) temp_obs_lat_corners(4) temp_obs_lat_corners(1)];
                temp_obs_poly_lons = [temp_obs_lon_corners(1) temp_obs_lon_corners(2) temp_obs_lon_corners(3) temp_obs_lon_corners(4) temp_obs_lon_corners(1)];


                k = get_indices_vec(bg_lat, bg_lon, [temp_obs_lat_corners(1)-margin temp_obs_lat_corners(3)], [temp_obs_lon_corners(1)-margin temp_obs_lon_corners(3)+margin]);
                if ~isempty(k)
                    intersections = nan(1,n);
                    for j = 1:length(k)
                        pix = k(j);
                        if ismember(pix, valid_pixel)
                            temp_bg_lat_corners = flip(bg_lat_corners(:,pix));
                            temp_bg_lon_corners = flip(bg_lon_corners(:,pix));
                
                            temp_bg_poly_lats = [temp_bg_lat_corners(1) temp_bg_lat_corners(2) temp_bg_lat_corners(3) temp_bg_lat_corners(4) temp_bg_lat_corners(1)];
                            temp_bg_poly_lons = [temp_bg_lon_corners(1) temp_bg_lon_corners(2) temp_bg_lon_corners(3) temp_bg_lon_corners(4) temp_bg_lon_corners(1)];
                
                            temp_bg_poly_lats(isnan(temp_bg_poly_lats)) = [];
                            temp_bg_poly_lons(isnan(temp_bg_poly_lons)) = [];
                
                            if check_intersection(temp_bg_poly_lats, temp_bg_poly_lons, temp_obs_poly_lats, temp_obs_poly_lons) || any(inpolygon(temp_bg_poly_lats, temp_bg_poly_lons, temp_obs_poly_lats, temp_obs_poly_lons)) || any(inpolygon(temp_obs_poly_lats, temp_obs_poly_lons, temp_bg_poly_lats, temp_bg_poly_lons))
                                intersections(pix) = 1;
                            end
                        end
                        
                        H(i, intersections==1) = 1 ./ numel(intersections(intersections==1));
                    end
                end

                disp(num2str(100 * i/m))
            end
    end