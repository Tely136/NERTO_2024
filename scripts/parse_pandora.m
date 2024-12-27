function parse_pandora(data_input_path, data_save_path)

    varnames = {'Date', 'NO2', 'qa'};
    vartypes = {'datetime', 'double', 'double'};
    % Initialize or load the existing data table
    if ~exist(data_save_path, "file")
        pandora_data = table('Size', [0, length(varnames)], 'VariableNames', varnames, 'VariableTypes', vartypes);
        pandora_data.Date.TimeZone = 'UTC';
    else
        load(data_save_path) %#ok<LOAD>
    end

    % Find the number of existing entries for the table and determine lines to skip
    skip_lines = size(pandora_data, 1);

    % Initialize arrays to store new data
    dates = NaT(0,1, 'TimeZone', 'UTC');
    no2_trop = zeros(0,1);
    qa_values = zeros(0,1);

    % Open the file
    fid = fopen(data_input_path, "rt");
    if fid == -1
        error('Failed to open file: %s', data_input_path);
    end

    disp(['Parsing Pandora data in ', data_input_path])

    % Find the second occurrence of the line of dashes
    dash_counter = 0;
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line) && strcmp(line, '---------------------------------------------------------------------------------------')
            dash_counter = dash_counter + 1;
            if dash_counter == 2
                break;
            end
        end
    end

    % Skip the lines corresponding to existing entries
    for i = 1:skip_lines
        fgetl(fid);
    end

    % Read the remaining lines
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            split_line = strsplit(line);

            % Convert the date from the file format to datetime
            date = datetime(double(string(split_line(2))) * 24 * 60 * 60, 'ConvertFrom', 'epochtime', 'Epoch', '2000-01-01', 'TimeZone', 'UTC');
            no2 = str2double(split_line{62});
            qa = str2double(split_line{53});

            dates(end+1, 1) = date;
            no2_trop(end+1, 1) = no2;
            qa_values(end+1, 1) = qa;
        end
    end

    fclose(fid);


    % Create a new table with the new data
    temp_table = table(dates, no2_trop, qa_values, 'VariableNames', varnames);
    temp_table.Date.TimeZone = 'UTC';

    % Append the new data to the existing data table
    pandora_data = [pandora_data; temp_table];
    % pandora_data = unique(pandora_data);

    % Save the updated table back to the file
    save(data_save_path, "pandora_data");

    disp('Done')
end