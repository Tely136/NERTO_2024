clearvars; close all; clc;

varnames = {'time', 'Site', 'Tempo_NO2', 'Tropomi_NO2', 'Merged_NO2'};
vartypes = {'datetime', 'string', 'double', 'double', 'double'};

merged_data_table = table('Size', [0 length(varnames)] ,'VariableNames', varnames, 'VariableTypes', vartypes); % make table to hold satellite, pandora no2, and other info
merged_data_table.time.TimeZone = 'UTC';

site_names = {'ccny', 'nybg', 'queens', 'beltsville', 'essex', 'greenbelt2', 'greenbelt32', 'DC'};
all_coords = [[40.8153 -73.9505]; 
              [40.8679 -73.8781]; 
              [40.7361 -73.8215]; 
              [39.0553 -76.8783]; 
              [39.3109 -76.4745]; 
              [38.9926 -76.8396]; 
              [38.9926 -76.8396];
              [38.9218 -77.0124];];

distance_threshold = km2deg(5, 'earth'); 

% files = dir('/mnt/disks/data-disk/data/merged_data/*MARYLAND*.mat');
% files = dir('/mnt/disks/data-disk/data/merged_data/*NYC*.mat');
files = dir('/mnt/disks/data-disk/data/merged_data/*.mat');

for i = 1:length(files)
    filename = fullfile(files(i).folder, files(i).name);

    load(filename)

    tempo_no2 = save_data.bg_no2;
    tempo_lat = save_data.bg_lat;
    tempo_lon = save_data.bg_lon;
    tempo_time = save_data.bg_time;

    trop_no2 = save_data.obs_no2;
    trop_lat = save_data.obs_lat;
    trop_lon = save_data.obs_lon;

    merge_no2 = save_data.analysis_no2;

    for j = 1:size(all_coords,1)
        coords = all_coords(j,:);
        site = site_names(j);
        % disp(site)


        tempo_ind = distance(tempo_lat, tempo_lon, coords(1), coords(2)) <= distance_threshold & ~isnan(tempo_no2);
        trop_ind = distance(trop_lat, trop_lon, coords(1), coords(2)) <= distance_threshold & ~isnan(trop_no2);
        merge_ind = tempo_ind & ~isnan(merge_no2);

        if ~isempty(find(tempo_ind,1)) & ~isempty(find(trop_ind,1)) & ~isempty(find(merge_ind,1))
            tempo_time = resize(tempo_time, [length(tempo_time), numel(tempo_no2)/length(tempo_time)], 'Pattern', 'circular');

            temp_table = table(mean(tempo_time(tempo_ind)), site, mean(tempo_no2(tempo_ind)), mean(trop_no2(trop_ind)), mean(merge_no2(merge_ind)), 'VariableNames', varnames);

            merged_data_table = [merged_data_table; temp_table];
        end
    end
end


save_path = '/mnt/disks/data-disk/NERTO_2024/validation/';

save(fullfile(save_path, 'merged_data_timeseries.mat'), "merged_data_table");