clearvars; clc; close all;

data_path = '/mnt/disks/data-disk/data/tempo_data';
save_path = '/mnt/disks/data-disk/data';
fullpath = fullfile(save_path, 'satellite_files_table.mat');


L1_files = dir(fullfile(data_path, '*L1*.nc'));
L2_files = dir(fullfile(data_path, '*L2*.nc'));
varnames = {'Filename', 'Product', 'Level', 'Date', 'Version', 'Scan', 'Granule'};
vartypes = {'string', 'string', 'double', 'datetime', 'double', 'double', 'double'};

if exist(fullpath, "file")
    load(fullpath);
else
    files_table = table('Size', [0, length(vartypes)], 'VariableTypes',vartypes, 'VariableNames', varnames);
    files_table.Date.TimeZone = 'UTC';
end

for i = 1:length(L1_files)
    temp_name = L1_files(i).name;
    temp_name_split = strsplit(temp_name, '_');
    temp_path = string(fullfile(data_path, temp_name));

    temp_product = temp_name_split(2);
    temp_level = char(temp_name_split(3)); temp_level = str2double(temp_level(end));
    temp_version = char(temp_name_split(4)); temp_version = str2double(temp_version(end));
    temp_date = temp_name_split(5); temp_date = replace(temp_date, '.nc', '');
    temp_date = datetime(temp_date, 'InputFormat', 'uuuuMMdd''T''HHmmssZ', 'TimeZone', 'UTC');

    temp_scan = NaN;
    temp_granule = NaN;
    if strcmp(temp_product, 'RAD')
        temp_id = char(temp_name_split(6));
        temp_scan = str2double(temp_id(2:4));
        temp_granule = str2double(temp_id(6:7));
    end

    temp_table = table(temp_path, temp_product, temp_level, temp_date,...
                       temp_version, temp_scan, temp_granule, 'VariableNames', varnames);

    files_table = [files_table; temp_table];
end

for i = 1:length(L2_files)
    temp_name = L2_files(i).name;
    temp_name_split = strsplit(temp_name, '_');
    temp_path = string(fullfile(data_path, temp_name));

    temp_product = temp_name_split(2);
    temp_level = char(temp_name_split(3)); temp_level = str2double(temp_level(end));
    temp_version = char(temp_name_split(4)); temp_version = str2double(temp_version(end));
    temp_date = datetime(temp_name_split(5), 'InputFormat', 'uuuuMMdd''T''HHmmssZ', 'TimeZone', 'UTC');

    temp_id = char(temp_name_split(6));
    temp_scan = str2double(temp_id(2:4));
    temp_granule = str2double(temp_id(6:7));

    temp_table = table(temp_path, temp_product, temp_level, temp_date,...
                       temp_version, temp_scan, temp_granule, 'VariableNames', varnames);

    files_table = [files_table; temp_table];
end

% save('/mnt/disks/data-disk/NERTO_2024/tempo_files_table.mat', "tempo_files_table");
save(fullpath, "files_table");