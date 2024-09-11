function rho = gaspari_cohn2(r)
    % Gaspari-Cohn correlation function
    % r: normalized distance (distance divided by the localization radius)
    % rho: correlation value

    % Initialize rho with zeros
    rho = zeros(size(r));

    % For 0 <= r <= 1
    mask1 = (r >= 0 & r <= 1);
    r1 = r(mask1);
    rho(mask1) = 1 - 5/3*r1.^2 + 5/8*r1.^3 + 1/2*r1.^4 - 1/4*r1.^5;

    % For 1 < r <= 2
    mask2 = (r > 1 & r <= 2);
    r2 = r(mask2);
    rho(mask2) = -2/3*r2.^(-1) + 4 - 5*r2 + 5/3*r2.^2 + 5/8*r2.^3 - 1/2*r2.^4 + 1/12*r2.^5;

    % For r > 2, rho is already 0 (initialized as zeros)
end