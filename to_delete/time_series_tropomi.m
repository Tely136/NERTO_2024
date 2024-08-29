clearvars; close all; clc;

data_path = '/mnt/disks/results-disk/merged_data/';
save_path = fullfile('/mnt/disks/data-disk/data/time_series', 'tropomi_time_series_data.mat');

varnames = {'time', 'Site', 'Dist2Site', 'TROPOMI_NO2', 'TROPOMI_Uncertainty', 'filename', 'row', 'col'};
vartypes = {'datetime', 'string', 'double', 'double', 'double', 'string', 'double', 'double'};

all_coords = [[40.8153 -73.9505]; 
              [40.8679 -73.8781]; 
              [40.7361 -73.8215]; 
              [39.0553 -76.8783]; 
              [39.3109 -76.4745]; 
              [38.9926 -76.8396]; 
              [38.9926 -76.8396];];

site_names = {'ccny', 'nybg', 'queens', 'beltsville', 'essex', 'greenbelt2', 'greenbelt32'};


distance_threshold = km2deg(5, 'earth'); 

if exist(save_path, "file")
    load(save_path);
else
    tropomi_data_table = table('Size', [0 length(varnames)] ,'VariableNames', varnames, 'VariableTypes', vartypes);
    tropomi_data_table.time.TimeZone = 'UTC';
end

all_files = dir(fullfile(data_path, '*.nc'));

all_filenames = fullfile({all_files.folder}, {all_files.name});
files = all_files(~ismember(all_filenames, tropomi_data_table.filename));

counter = 1;
for i = 1:size(files,1) % check file for tempo or tropomi and load data accordingly
    percent = i./size(files,1) * 100;
    disp([num2str(percent), '%'])

    filepath = fullfile(files(i).folder, files(i).name);

    tropomi_no2 = ncread(filepath, '/tropomi/tropomi_no2');
    tropomi_no2_u = ncread(filepath, '/tropomi/tropomi_no2_u');
    tropomi_valid_ind = logical(ncread(filepath, '/tropomi/tropomi_valid_ind'));

    lat = ncread(filepath, '/tropomi/tropomi_lat');
    lon = ncread(filepath, '/tropomi/tropomi_lon');
    time = ncread(filepath, '/tropomi/tropomi_time');
    time = datetime(time, "ConvertFrom", "posixtime", 'TimeZone', 'UTC');

    for j = 1:length(site_names)
        coords = all_coords(j,:);
        site = site_names(j);

        dist2site = distance(coords(1), coords(2), lat, lon);
        ind = tropomi_valid_ind & dist2site < distance_threshold;

        if ~isempty(find(ind, 1))
            [row, col] = ind2sub(size(tropomi_no2), find(ind));

            temp_tropomi_data_table = table(time(col), repmat(site, length(find(ind)), 1), dist2site(ind), tropomi_no2(ind), tropomi_no2_u(ind), repmat(string(filepath),length(find(ind)),1), row, col,  'VariableNames', varnames);
            tropomi_data_table = [tropomi_data_table; temp_tropomi_data_table];

        else
            continue
        end
    end
end


data_table = unique(data_table);
data_table = rmmissing(data_table);

save(save_path, 'tropomi_data_table');
