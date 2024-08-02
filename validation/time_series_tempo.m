clearvars; close all; clc;

varnames = {'time', 'Site', 'Dist2Site', 'TEMPO_NO2', 'QA', 'Uncertainty', 'VZA', 'SZA', 'Cld_frac', 'filename', 'row', 'col'};
vartypes = {'datetime', 'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'string', 'double', 'double'};

all_coords = [[40.8153 -73.9505]; 
              [40.8679 -73.8781]; 
              [40.7361 -73.8215]; 
              [39.0553 -76.8783]; 
              [39.3109 -76.4745]; 
              [38.9926 -76.8396]; 
              [38.9926 -76.8396];
              [38.9218 -77.0124];];

site_names = {'ccny', 'nybg', 'queens', 'beltsville', 'essex', 'greenbelt2', 'greenbelt32', 'DC'};


distance_threshold = km2deg(5, 'earth'); 

files_table = tempo_table('/mnt/disks/data-disk/data/tempo_data');
files_table = files_table(contains(files_table.Filename, 'TEMPO') & strcmp(files_table.Product, 'NO2'), :);


data_table = table('Size', [0 length(varnames)] ,'VariableNames', varnames, 'VariableTypes', vartypes); % make table to hold satellite, pandora no2, and other info
data_table.time.TimeZone = 'UTC';

for i = 1:size(files_table,1) % check file for tempo or tropomi and load data accordingly
    percent = i./size(files_table,1) * 100;
    disp([num2str(percent), '%'])

    temp_table = files_table(i,:);
    filename = temp_table.Filename;

    tempo_data = read_tempo_netcdf(temp_table);
    no2 = tempo_data.no2;
    no2_u = tempo_data.no2_u;
    qa = tempo_data.qa;
    f_cld = tempo_data.f_cld;

    lat = tempo_data.lat;
    lon = tempo_data.lon;
    sza = tempo_data.sza;
    vza = tempo_data.vza;
    time = tempo_data.time;
    time = resize(time, [length(time), numel(no2)/length(time)], 'Pattern', 'circular');


    for j = 1:length(site_names)
        coords = all_coords(j,:);
        site = site_names(j);

        dist2site = distance(coords(1), coords(2), lat, lon);
        ind = dist2site < distance_threshold;

        if ~isempty(ind)

            [row, col] = ind2sub(size(no2), ind);


            
            temp_data_table = table(time(ind), repmat(site, length(find(ind)), 1), dist2site(ind), no2(ind), qa(ind), no2_u(ind), vza(ind), sza(ind), f_cld(ind), repmat(filename,length(find(ind)),1), row(ind), col(ind),  'VariableNames', varnames);
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