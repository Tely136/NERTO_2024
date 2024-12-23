function time_series(data_input_folder, data_save_path, variable_names, distance_threshold, location_coords, location_name)
    arguments
        data_input_folder string
        data_save_path string
        variable_names string = [];
        distance_threshold double = NaN
        location_coords double = [NaN NaN]
        location_name string = []
    end
        
    all_files = dir(fullfile(data_input_folder, '*.nc'));

    if exist(data_save_path, "file")
        input_data = load(data_save_path);
        data_table = input_data.data_table;
        variable_names = input_data.variable_names;
        processed_files = input_data.processed_files;
        distance_threshold = input_data.distance_threshold;
        location_coords = input_data.location_coords;

        all_filenames = fullfile({all_files.folder}, {all_files.name});
        files = all_files(~ismember(all_filenames, processed_files));
        new_processed_files = strings;

    else
        if isempty(variable_names) | isempty(distance_threshold) | isempty(location_coords)
            % error
        end

        files = dir(fullfile(data_input_folder, '*.nc'));
        new_processed_files = strings;

        processed_files = strings(0);

    end

    n_vars = length(variable_names);
    n_files = size(files,1);

    variable_names_table = strings(1, n_vars);
    for i = 1:n_vars
        temp_name = split(variable_names(i), '/');
        variable_names_table(i) = temp_name(end);
    end

    distance_threshold_deg = km2deg(distance_threshold, 'earth'); 

    if ~exist('data_table', 'var')
            data_table = table('Size', [0 n_vars] ,'VariableNames', variable_names_table, 'VariableTypes', repmat("double", [1, n_vars]));
    end
    temp_data_table = table('Size', [size(files,1)*10 n_vars] ,'VariableNames', variable_names_table, 'VariableTypes', repmat("double", [1, n_vars]));

    f_name = split(data_save_path,'\');
    f_name = f_name(end);
    f = waitbar(0, char(strjoin(["Creating",f_name])));

    counter = 1;
    for i = 1:size(files,1)
        % percent = i./n_files * 100;
        % disp([num2str(percent), '%'])
    
        filepath = fullfile(files(i).folder, files(i).name);
    
        new_processed_files(i) = filepath;

        % lat, then lon
        % atleast one more variable after that
        lat = ncread(filepath, variable_names(1));
        lon = ncread(filepath, variable_names(2));
    
        dist2site = distance(location_coords(1), location_coords(2), lat, lon);
        ind = dist2site <= distance_threshold_deg;
        [row, col] = ind2sub(size(lat), find(ind));

        n_pixels = length(find(ind));

        % need to handle time or other variables with different size than
        % lat and lon
        if n_pixels > 0
            temp_data = NaN(n_pixels,n_vars);
            temp_data(:,1) = lat(ind);
            temp_data(:,2) = lon(ind);
    
            for j = 3:n_vars
                var = ncread(filepath, variable_names(j));

                if isscalar(var)
                    temp_ind = 1;

                elseif isvector(var)
                    if length(var) == size(ind,1)
                        temp_ind = row;
            
                    elseif length(var) == size(ind,2)
                        temp_ind = col;
                    end
                else 
                    temp_ind = ind;
                end

                temp_data(:,j) = var(temp_ind);
            end
    
            
            temp_data_table(counter:counter+n_pixels-1,:) = array2table(temp_data);
    
            counter = counter + n_pixels;
        end

        waitbar(i/n_files, f, char(strjoin(["Creating",f_name])))
    end
    
    data_table = [data_table; temp_data_table(1:counter-1,:)];
    data_table = unique(data_table);

    processed_files = [processed_files new_processed_files];
    save(data_save_path, 'data_table', 'variable_names', 'processed_files', 'distance_threshold', 'location_coords');

    delete(f)
end