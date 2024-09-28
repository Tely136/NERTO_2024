trop_val = 130;
tempo_val = 133;

n = numel(find(tempo_ind));
m = numel(find(trop_ind));

tempo_lat_corners_crop2 = (tempo_lat_corners(:,tempo_ind));
tempo_lon_corners_crop2 = (tempo_lon_corners(:,tempo_ind));

trop_lat_corners_crop2 = (trop_lat_corners(:,trop_ind));
trop_lon_corners_crop2 = (trop_lon_corners(:,trop_ind));


tempo_poly = repmat(polyshape, 1, n);
for i = 1:n
    tempo_poly(1,i) = polyshape(tempo_lon_corners_crop2(:,i), tempo_lat_corners_crop2(:,i), 'Simplify', false, 'keepcollinearpoints', true);
end

trop_poly = repmat(polyshape, 1, m);
for i = trop_val
% for i = 1:m
    temp_trop_poly = polyshape(trop_lon_corners_crop2(:,i), trop_lat_corners_crop2(:,i), 'Simplify', false, 'keepcollinearpoints', true);
    TF = overlaps(temp_trop_poly, tempo_poly);

    trop_poly(1,i) = temp_trop_poly;
end

close all;

figure('WindowStyle', 'docked');

hold on;
plot(tempo_poly(TF));
plot(trop_poly);

hold off;