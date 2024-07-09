clearvars; close all; clc;

varnames = {'time', 'Site', 'NO2', 'QA', 'Uncertainty', 'VZA', 'SZA'};
vartypes = {'datetime', 'string', 'double', 'double', 'double', 'double', 'double'};



all_coords = [[40.8153 -73.9505]; 
              [40.8679 -73.8781]; 
              [40.7361 -73.8215]; 
              [39.0553 -76.8783]; 
              [39.3109 -76.4745]; 
              [38.9926 -76.8396]; 
              [38.9926 -76.8396];];


distance_threshold = km2deg(30, 'earth'); 

site_names = {'ccny', 'nybg', 'queens', 'beltsville', 'essex', 'greenbelt2', 'greenbelt32'};

load('/mnt/disks/data-disk/data/satellite_files_table.mat');
files_table = files_table(contains(files_table.Filename, 'S5P') & strcmp(files_table.Product, 'NO2'), :);


data_table = table('Size', [length(site_names)*size(files_table,1) length(varnames)] ,'VariableNames', varnames, 'VariableTypes', vartypes); % make table to hold satellite, pandora no2, and other info
data_table.time.TimeZone = 'UTC';

counter = 1;
for i = 1:size(files_table,1) % check file for tempo or tropomi and load data accordingly
    percent = i./size(files_table,1) * 100;
    disp([num2str(percent), '%'])

    temp_table = files_table(i,:);
    filename = temp_table.Filename;

    lat_full = ncread(filename, '/PRODUCT/latitude');
    lon_full = ncread(filename, '/PRODUCT/longitude');


    for j = 1:size(all_coords,1)
        coords = all_coords(j,:);
        site = site_names(j);
        % disp(site)

        lat_bounds = [coords(1)-distance_threshold, coords(1)+distance_threshold];
        lon_bounds = [coords(2)-distance_threshold, coords(2)+distance_threshold];

        [rows, cols] = get_indices2(lat_full, lon_full, lat_bounds, lon_bounds);

        if ~isempty(rows) & ~isempty(cols)
            sat_data = read_tropomi_netcdf(temp_table, rows, cols);

            sat_no2 = sat_data.no2;
            sat_no2_u = sat_data.no2_u;
            sat_qa = sat_data.qa;

            sat_lat = sat_data.lat;
            sat_lon = sat_data.lon;
            sat_sza = sat_data.sza;
            sat_vza = sat_data.vza;
            sat_time = sat_data.time;

            [~, ind] = min(distance(sat_lat(:), sat_lon(:), coords(1), coords(2)));
            [row, col] = ind2sub(size(sat_no2), ind);

            time = sat_time(row);

            temp_data_table = table(time, site, sat_no2(ind), sat_qa(ind), sat_no2_u(ind), sat_vza(ind), sat_sza(ind), 'VariableNames', varnames);
            data_table(counter,:) = temp_data_table;

            counter = counter + 1;
        else
            continue
        end
    end
end


data_table = unique(data_table);
data_table = rmmissing(data_table);

save_path = fullfile('/mnt/disks/data-disk/NERTO_2024/validation', 'tropomi_time_series_data.mat');
save(save_path, 'data_table');
