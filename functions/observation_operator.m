function H = observation_operator(bg_lat, bg_lon, obs_lat, obs_lon)

    n_obs = length(obs_lat);
    n_bg = length(bg_lat);

    H = zeros(n_obs, n_bg);

    for i = 1:n_obs
        % find nearest tempo pixel and assign it weight of 1

        lat = obs_lat(i);
        lon = obs_lon(i);

        [distances, ~] = distance(lat, lon, bg_lat, bg_lon);
        [~, min_j] = min(distances);

        H(i,min_j) = 1;

    end
end