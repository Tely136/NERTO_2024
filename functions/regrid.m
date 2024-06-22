function interp_data = regrid(lat, lon, data, latq, lonq)

    lat_vec = lat(:);
    lon_vec = lon(:);
    data_vec = data(:);


    interp_data = griddata(lat_vec, lon_vec, data_vec, latq, lonq, "nearest");

end