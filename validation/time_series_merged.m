clearvars; close all; clc;

data_path = '/mnt/disks/data-disk/data/merged_data/';
save_path = fullfile('/mnt/disks/data-disk/data/time_series', 'merged_time_series_data.mat');


varnames = {'time', 'Site', 'Dist2Site', 'TEMPO_NO2', 'Merged_NO2', 'TEMPO_Uncertainty', 'Merged_Uncertainty', 'filename', 'row', 'col'};
vartypes = {'datetime', 'string', 'double', 'double', 'double', 'double', 'double', 'string', 'double', 'double'};

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

if exist(save_path, "file")
    load(save_path);
else
    merged_data_table = table('Size', [0 length(varnames)] ,'VariableNames', varnames, 'VariableTypes', vartypes); % make table to hold satellite, pandora no2, and other info
    merged_data_table.time.TimeZone = 'UTC';
end

all_files = dir(fullfile(data_path, '*.nc'));

all_filenames = fullfile({all_files.folder}, {all_files.name});
files = all_files(~ismember(all_filenames, merged_data_table.filename));


for i = 1:size(files,1) % check file for tempo or tropomi and load data accordingly
    percent = i./size(files,1) * 100;
    disp([num2str(percent), '%'])

    filepath = fullfile(files(i).folder, files(i).name);

    tempo_no2 = ncread(filepath, '/tempo/tempo_no2');
    tempo_no2_u = ncread(filepath, '/tempo/tempo_no2_u');

    merged_no2 = ncread(filepath, '/analysis/analysis_no2');
    merged_no2_u = ncread(filepath, '/analysis/analysis_no2_u');

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
            [row, col] = ind2sub(size(merged_no2), find(ind));

            temp_merged_data_table = table(time(col)', repmat(site, length(find(ind)), 1), dist2site(ind), tempo_no2(ind), merged_no2(ind), tempo_no2_u(ind), merged_no2_u(ind), repmat(filepath,length(find(ind)),1), row, col,  'VariableNames', varnames);
            merged_data_table = [merged_data_table; temp_merged_data_table];

        else
            continue
        end
    end

    % if i == 10
    %     break
    % end
end

merged_data_table = unique(merged_data_table);
merged_data_table = rmmissing(merged_data_table);

save(save_path, 'merged_data_table');