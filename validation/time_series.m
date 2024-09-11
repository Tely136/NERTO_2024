function time_series(data_input_path, data_save_path)
        
    save_path = fullfile(data_save_path, 'time_series_data.mat');

    merged_varnames = {'time', 'Site', 'Dist2Site', 'TEMPO_NO2', 'Merged_NO2', 'TEMPO_Uncertainty', 'Merged_Uncertainty', 'filename', 'row', 'col'};
    merged_vartypes = {'datetime', 'string', 'double', 'double', 'double', 'double', 'double', 'string', 'double', 'double'};

    tropomi_varnames = {'time', 'Site', 'Dist2Site', 'TROPOMI_NO2', 'TROPOMI_Uncertainty', 'filename', 'row', 'col'};
    tropomi_vartypes = {'datetime', 'string', 'double', 'double', 'double', 'string', 'double', 'double'};

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

    all_files = dir(fullfile(data_input_path, '*.nc'));

    if exist(save_path, "file")
        input_data = load(save_path);
        merged_data_table = input_data.merged_data_table;
        tropomi_data_table = input_data.tropomi_data_table;

        processed_files = input_data.processed_files;
        all_filenames = fullfile({all_files.folder}, {all_files.name});
        files = all_files(~ismember(all_filenames, processed_files));

    else
        merged_data_table = table('Size', [0 length(merged_varnames)] ,'VariableNames', merged_varnames, 'VariableTypes', merged_vartypes);
        merged_data_table.time.TimeZone = 'UTC';

        tropomi_data_table = table('Size', [0 length(tropomi_varnames)] ,'VariableNames', tropomi_varnames, 'VariableTypes', tropomi_vartypes);
        tropomi_data_table.time.TimeZone = 'UTC';

        files = dir(fullfile(data_input_path, '*.nc'));
        processed_files = strings;
    end


    for i = 1:size(files,1)
        percent = i./size(files,1) * 100;
        disp([num2str(percent), '%'])

        filepath = fullfile(files(i).folder, files(i).name);

        processed_files(end+1) = filepath; %#ok<SAGROW>

        tempo_no2 = ncread(filepath, '/tempo/tempo_no2');
        tempo_no2_u = ncread(filepath, '/tempo/tempo_no2_u');
        tempo_valid_ind = ncread(filepath, '/tempo/tempo_valid_ind');

        tropomi_no2 = ncread(filepath, '/tropomi/tropomi_no2');
        tropomi_no2_u = ncread(filepath, '/tropomi/tropomi_no2_u');
        tropomi_valid_ind = logical(ncread(filepath, '/tropomi/tropomi_valid_ind'));

        merged_no2 = ncread(filepath, '/analysis/analysis_no2');
        merged_no2_u = ncread(filepath, '/analysis/analysis_no2_u');

        tempo_lat = ncread(filepath, '/tempo/tempo_lat');
        tempo_lon = ncread(filepath, '/tempo/tempo_lon');
        tempo_time = ncread(filepath, '/tempo/tempo_time');
        tempo_time = datetime(tempo_time, "ConvertFrom", "posixtime", 'TimeZone', 'UTC');

        tropomi_lat = ncread(filepath, '/tropomi/tropomi_lat');
        tropomi_lon = ncread(filepath, '/tropomi/tropomi_lon');
        tropomi_time = ncread(filepath, '/tropomi/tropomi_time');
        tropomi_time = datetime(tropomi_time, "ConvertFrom", "posixtime", 'TimeZone', 'UTC');

        for j = 1:length(site_names)
            coords = all_coords(j,:);
            site = site_names(j);

            dist2site = distance(coords(1), coords(2), tempo_lat, tempo_lon);
            ind = tempo_valid_ind & dist2site < distance_threshold;
            if ~isempty(find(ind, 1))
                [row, col] = ind2sub(size(merged_no2), find(ind));

                temp_merged_data_table = table(tempo_time(col)', repmat(site, length(find(ind)), 1), dist2site(ind), tempo_no2(ind), merged_no2(ind), tempo_no2_u(ind), merged_no2_u(ind), repmat(string(filepath),length(find(ind)),1), row, col,  'VariableNames', merged_varnames);
                merged_data_table = [merged_data_table; temp_merged_data_table]; %#ok<*AGROW>
            end

            for k = 1:size(tropomi_no2,3)
                trop_no2_page = tropomi_no2(:,:,k);
                trop_no2_u_page = tropomi_no2_u(:,:,k);
                trop_valid_ind_page = tropomi_valid_ind(:,:,k);
                trop_lat_page = tropomi_lat(:,:,k);
                trop_lon_page = tropomi_lon(:,:,k);
                trop_time_page = tropomi_time(:,:,k);

                dist2site = distance(coords(1), coords(2), trop_lat_page, trop_lon_page);
                ind = trop_valid_ind_page & dist2site < distance_threshold;
                if ~isempty(find(ind, 1))
                    [row, col] = ind2sub(size(trop_no2_page), find(ind));

                    temp_tropomi_data_table = table(trop_time_page(col)', repmat(site, length(find(ind)), 1), dist2site(ind), trop_no2_page(ind), trop_no2_u_page(ind), repmat(string(filepath),length(find(ind)),1), row, col,  'VariableNames', tropomi_varnames);
                    tropomi_data_table = [tropomi_data_table; temp_tropomi_data_table];
                end
            end
        end
    end

    merged_data_table = rmmissing(merged_data_table);
    merged_data_table = unique(merged_data_table);

    tropomi_data_table = rmmissing(tropomi_data_table);
    [~, unique_ind] = unique(tropomi_data_table(:, {'time', 'Site', 'Dist2Site', 'TROPOMI_NO2', 'TROPOMI_Uncertainty', 'row', 'col'}));
    tropomi_data_table = tropomi_data_table(unique_ind,:);

    save(save_path, 'merged_data_table', 'tropomi_data_table', 'processed_files');

end