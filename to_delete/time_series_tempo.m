clearvars; close all; clc;

varnames = {'time', 'Site', 'Dist2Site', 'TEMPO_NO2', 'Uncertainty', 'filename', 'row', 'col'};
vartypes = {'datetime', 'string', 'double', 'double', 'double', 'string', 'double', 'double'};

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


tempo_data_table = table('Size', [0 length(varnames)] ,'VariableNames', varnames, 'VariableTypes', vartypes); % make table to hold satellite, pandora no2, and other info
tempo_data_table.time.TimeZone = 'UTC';

for i = 1:size(files_table,1) % check file for tempo or tropomi and load data accordingly
    percent = i./size(files_table,1) * 100;
    disp([num2str(percent), '%'])

    filepath = fullfile(files(i).folder, files(i).name);

    no2 = ncread(filepath, '/tempo/analysis_no2');
    no2_u = ncread(filepath, '/tempo/analysis_no2_u');

    lat = ncread(filepath, '/tempo/tempo_lat');
    lon = ncread(filepath, '/tempo/tempo_lon');
    time = ncread(filepath, '/tempo/tempo_time');
    time = datetime(time, "ConvertFrom", "posixtime", 'TimeZone', 'UTC');


    for j = 1:length(site_names)
        coords = all_coords(j,:);
        site = site_names(j);

        dist2site = distance(coords(1), coords(2), lat, lon);
        ind = dist2site < distance_threshold;

        if ~isempty(ind)

            [row, col] = ind2sub(size(no2), ind);

            temp_tempo_data_table = table(time(ind), repmat(site, length(find(ind)), 1), dist2site(ind), no2(ind), qa(ind), no2_u(ind), vza(ind), sza(ind), f_cld(ind), repmat(filename,length(find(ind)),1), row(ind), col(ind),  'VariableNames', varnames);
            tempo_data_table = [tempo_data_table; temp_tempo_data_table];
        else
            continue
        end
    end
end

tempo_data_table = unique(tempo_data_table);
tempo_data_table = rmmissing(tempo_data_table);

save_path = fullfile('/mnt/disks/data-disk/NERTO_2024/validation', 'tempo_time_series_data.mat');
save(save_path, 'tempo_data_table');