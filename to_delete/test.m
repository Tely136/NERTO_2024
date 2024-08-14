clc;

a = tempo_lat_corners(:,1);
b = tempo_lon_corners(:,1);

a = flip(a); b = flip(b);
geopolyshape(a,b)


a = trop_lat_corners(:,1);
b = trop_lon_corners(:,1);

a = flip(a); b = flip(b);
geopolyshape(a,b)