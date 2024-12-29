function files_table = merged_table(data_path)

    files = dir(fullfile(data_path,'*.nc'));
    varnames = {'Filename', 'Date', 'Scan', };
    vartypes = {'string', 'datetime', 'double'};

    files_table = table('Size', [0, length(vartypes)], 'VariableTypes',vartypes, 'VariableNames', varnames);
    files_table.Date.TimeZone = 'UTC';

    for i = 1:length(files)
        temp_name = files(i).name;
        temp_name_split = strsplit(temp_name, '_');
        temp_path = string(fullfile(data_path, temp_name));

        temp_date = datetime(temp_name_split(4), 'InputFormat', 'uuuuMMdd', 'TimeZone', 'UTC');

        temp_scan = replace(temp_name_split(5), 'S','');
        temp_scan = str2double(replace(temp_scan, '.nc',''));

        temp_table = table(temp_path, temp_date, temp_scan, 'VariableNames', varnames);

        files_table = [files_table; temp_table];
    end
end

