clearvars; close all; clc;

% data_path = '/mnt/disks/data-disk/data/merged_data/temporal_on';
% save_path = fullfile('/mnt/disks/data-disk/data/time_series', 'merged_time_series_data_temporal_on.mat');

data_path = '/mnt/disks/data-disk/data/merged_data/temporal_off';
save_path = fullfile('/mnt/disks/data-disk/data/time_series', 'merged_time_series_data_temporal_off.mat');

% data_path = '/mnt/disks/data-disk/data/merged_data/temporal_strict';
% save_path = fullfile('/mnt/disks/data-disk/data/time_series', 'merged_time_series_data_temporal_strict.mat');


files = dir(fullfile(data_path, '*.nc'));

varnames = {'time', 'Site', 'Dist2Site', 'Merged_NO2', 'Uncertainty', 'filename', 'row', 'col'};
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

merged_data_table = table('Size', [0 length(varnames)] ,'VariableNames', varnames, 'VariableTypes', vartypes); % make table to hold satellite, pandora no2, and other info
merged_data_table.time.TimeZone = 'UTC';

for i = 1:size(files,1) % check file for tempo or tropomi and load data accordingly
    percent = i./size(files,1) * 100;
    disp([num2str(percent), '%'])

    filepath = fullfile(files(i).folder, files(i).name);

    no2 = ncread(filepath, '/analysis/analysis_no2');
    no2_u = ncread(filepath, '/analysis/analysis_no2_u');

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
            [row, col] = ind2sub(size(no2), find(ind));

            temp_merged_data_table = table(time(col)', repmat(site, length(find(ind)), 1), dist2site(ind), no2(ind),  no2_u(ind), repmat(filepath,length(find(ind)),1), row, col,  'VariableNames', varnames);
            merged_data_table = [merged_data_table; temp_merged_data_table];

        else
            continue
        end
    end
end

merged_data_table = unique(merged_data_table);
merged_data_table = rmmissing(merged_data_table);

save(save_path, 'merged_data_table');