function H = observation_operator(bg_lat, bg_lon, obs_lat, obs_lon)
    n_obs = length(obs_lat);
    n_bg = length(bg_lat);

    H = zeros(n_obs, n_bg);

    for i = 1:n_bg
        v = zeros(n_bg,1);
        v(i) = 1;

        F = scatteredInterpolant(bg_lat, bg_lon, v, 'nearest', 'nearest');

        H(:,i) = F(obs_lat, obs_lon);
    end
end