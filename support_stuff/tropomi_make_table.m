clearvars; clc; close all;

data_path = '/mnt/disks/data-disk/data/tropomi_data/';
save_path = '/mnt/disks/data-disk/data/';
fullpath = fullfile(save_path, 'satellite_files_table.mat');

L1_files = dir(fullfile(data_path, '*L1*.nc'));
L2_files = dir(fullfile(data_path, '*L2*.nc'));

files = [L1_files; L2_files];

if exist(fullpath, "file")
    load(fullpath);
else
    varnames = {'Filename', 'Product', 'Level', 'Date', 'Version', 'Scan', 'Granule'};
    vartypes = {'string', 'string', 'double', 'datetime', 'double', 'double', 'double'};
    files_table = table('Size', [0, length(vartypes)], 'VariableTypes', vartypes, 'VariableNames', varnames);
    files_table.Date.TimeZone = 'UTC';
end

for i = 1:length(files)
    temp_name = files(i).name;
    temp_name_split = strsplit(temp_name, '_');

    temp_path = string(fullfile(files(i).folder, temp_name));

    temp_level = char(temp_name_split(3)); temp_level = str2double(temp_level(2));
    temp_product = temp_name_split(4);
    temp_date = datetime(temp_name_split(6), 'InputFormat', 'uuuuMMdd''T''HHmmss', 'TimeZone', 'UTC');

    if temp_level == 2
        temp_granule = double(string(temp_name_split(7)));

    elseif temp_level == 1 & strcmp(temp_product,'RA') % need to finish adding granule to tropomi radiance and no2 to load it
        temp_granule = double(string(temp_name_split(8)));

    else
        temp_granule = NaN;

    end

    temp_version = {'NA'};

    temp_id = NaN;
    temp_scan = NaN;

    temp_table = table(temp_path, temp_product, temp_level, temp_date,...
                       temp_version, temp_scan, temp_granule, 'VariableNames', varnames);

    files_table = [files_table; temp_table];

end

save(fullpath, "files_table");