clearvars; close all; clc;

%% Make a function that scans TEMPO folder and creates table of all datafile
%% do the same for tropomi

varnames = {'time', 'Site', 'Dist2Site', 'NO2', 'QA', 'Uncertainty', 'VZA', 'SZA', 'Cld_frac'};
vartypes = {'datetime', 'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};

all_coords = [[40.8153 -73.9505]; 
              [40.8679 -73.8781]; 
              [40.7361 -73.8215]; 
              [39.0553 -76.8783]; 
              [39.3109 -76.4745]; 
              [38.9926 -76.8396]; 
              [38.9926 -76.8396];
              [38.9218 -77.0124];];


distance_threshold = km2deg(5, 'earth'); 

site_names = {'ccny', 'nybg', 'queens', 'beltsville', 'essex', 'greenbelt2', 'greenbelt32', 'DC'};

files_table = tempo_table('/mnt/disks/data-disk/data/tempo_data');
files_table = files_table(contains(files_table.Filename, 'TEMPO') & strcmp(files_table.Product, 'NO2'), :);


data_table = table('Size', [0 length(varnames)] ,'VariableNames', varnames, 'VariableTypes', vartypes); % make table to hold satellite, pandora no2, and other info
data_table.time.TimeZone = 'UTC';

for i = 1:size(files_table,1) % check file for tempo or tropomi and load data accordingly
    percent = i./size(files_table,1) * 100;
    disp([num2str(percent), '%'])

    temp_table = files_table(i,:);
    filename = temp_table.Filename;

    lat_full = ncread(filename, '/geolocation/latitude');
    lon_full = ncread(filename, '/geolocation/longitude');

    for j = 1:size(all_coords,1)
        coords = all_coords(j,:);
        site = site_names(j);
        % disp(site)

        lat_bounds = [coords(1)-distance_threshold, coords(1)+distance_threshold];
        lon_bounds = [coords(2)-distance_threshold, coords(2)+distance_threshold];

        [rows, cols] = get_indices2(lat_full, lon_full, lat_bounds, lon_bounds);

        if ~isempty(rows) & ~isempty(cols)
            sat_data = read_tempo_netcdf(temp_table, rows, cols);

            sat_no2 = sat_data.no2(:);
            sat_no2_u = sat_data.no2_u(:);
            sat_qa = sat_data.qa(:);
            sat_cld = sat_data.cld(:);

            sat_lat = sat_data.lat(:);
            sat_lon = sat_data.lon(:);
            sat_sza = sat_data.sza(:);
            sat_vza = sat_data.vza(:);
            sat_time = sat_data.time;
            sat_time = resize(sat_time, [length(sat_time), numel(sat_no2)/length(sat_time)], 'Pattern', 'circular');
            sat_time = sat_time(:);

            % change this code to save all pixels in range to table with their coordinates so that they can be filtered later and not waste time

            dist = distance(sat_lat, sat_lon, coords(1), coords(2));
            % [row, col] = ind2sub(size(sat_no2), ind);
            site = resize(site, size(sat_time), 'Pattern', 'circular');

            temp_data_table = table(sat_time, site, dist, sat_no2, sat_qa, sat_no2_u, sat_vza, sat_sza, sat_cld, 'VariableNames', varnames);
            data_table = [data_table; temp_data_table];

            
        else
            continue
        end
    end
end

data_table = unique(data_table);
data_table = rmmissing(data_table);

save_path = fullfile('/mnt/disks/data-disk/NERTO_2024/validation', 'tempo_time_series_data.mat');
save(save_path, 'data_table');