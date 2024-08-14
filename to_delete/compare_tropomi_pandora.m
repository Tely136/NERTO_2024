clearvars; close all; clc;

varnames = {'SatelliteInstrument', 'PandoraInstrument', 'time', 'SatelliteNO2', 'SatelliteQA', 'SatelliteUncertainty', 'SatelliteVZA', 'SatelliteSZA', 'PandoraNO2', 'PandoraQA'};
vartypes = {'string', 'string', 'datetime', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};

comparison_table = table('Size', [0 length(varnames)] ,'VariableNames', varnames, 'VariableTypes', vartypes); % make table to hold satellite, pandora no2, and other info
comparison_table.time.TimeZone = 'UTC';

all_coords = [[40.8153 -73.9505]; 
              [40.8679 -73.8781]; 
              [40.7361 -73.8215]; 
              [39.0553 -76.8783]; 
              [39.3109 -76.4745]; 
              [38.9926 -76.8396]; 
              [38.9926 -76.8396];];

all_sites = {'ccny', 'nybg', 'queens', 'beltsville', 'essex', 'greenbelt2', 'greenbelt32'};

% tropomi_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
% load(tropomi_table_path);

pandora_table_path = '/mnt/disks/data-disk/data/pandora_data/pandora_data.mat';
load(pandora_table_path);

load('/mnt/disks/data-disk/data/satellite_files_table.mat');
satellite_data_table = files_table(strcmp(files_table.Product, 'NO2'), :);


distance_threshold = km2deg(30, 'earth'); 
time_threshold = minutes(60);
conversion_factor = 6.02214 * 10^19;

% load in tropomi file and geolocation info
% for i = 1:size(satellite_data_table,1) % check file for tempo or tropomi and load data accordingly
for i = 1:size(satellite_data_table,1) % check file for tempo or tropomi and load data accordingly
    percent = i./size(satellite_data_table,1) * 100;
    disp([num2str(percent), '%'])

    temp_no2_table = satellite_data_table(i,:);
    filename = temp_no2_table.Filename;

    if contains(filename, 'S5P')
        lat_full = ncread(filename, '/PRODUCT/latitude');
        lon_full = ncread(filename, '/PRODUCT/longitude');
        satellite = 'TROPOMI';

    elseif contains(filename, 'TEMPO')
        lat_full = ncread(filename, '/geolocation/latitude');
        lon_full = ncread(filename, '/geolocation/longitude'); % change this
        satellite = 'TEMPO';

    else
        warning(['error loading', filename])
        continue
    end

    % loop over pandora coords and look for collocated data in trop file
    for j = 1:size(all_coords,1)
        coords = all_coords(j,:);
        site = all_sites(j);
        % disp(site)

        lat_bounds = [coords(1)-distance_threshold, coords(1)+distance_threshold];
        lon_bounds = [coords(2)-distance_threshold, coords(2)+distance_threshold];

        [rows, cols] = get_indices2(lat_full, lon_full, lat_bounds, lon_bounds);

        if ~isempty(rows) & ~isempty(cols)
            % Load Tropomi data
            % disp(['Comparing', site])
            if strcmp(satellite, 'TROPOMI')
                sat_data = read_tropomi_netcdf(temp_no2_table, rows, cols);

            elseif strcmp(satellite, 'TEMPO')
                sat_data = read_tempo_netcdf(temp_no2_table, rows, cols);

            end

            sat_no2 = sat_data.no2;
            sat_no2_u = sat_data.no2_u;
            sat_qa = sat_data.qa;

            sat_lat = sat_data.lat;
            sat_lon = sat_data.lon;
            sat_sza = sat_data.sza;
            sat_vza = sat_data.vza;
            sat_time = sat_data.time;

            if strcmp(satellite, 'TROPOMI')
                high_qa_ind = find(sat_qa >= 0.75);
            elseif strcmp(satellite, 'TEMPO')
                high_qa_ind = find(sat_qa == 0);
            end

            if isempty(high_qa_ind)
                % disp('No high qa satellite pixels in range')
                continue
            end

            % Loop over tropomi data and compare with pandora
            % OR find closest pixel with high QA and compare that with pandora
            % ind = high_qa_ind(1); % for now just load first one
            [~, ind] = min(distance(sat_lat(:), sat_lon(:), coords(1), coords(2)));
            [row, col] = ind2sub(size(sat_no2), ind);

            % Load Pandora Data
            site_table = pandora_data(strcmp(pandora_data.Site, site),:);
            site_table = site_table(site_table.qa == 1 | site_table.qa == 0 | site_table.qa == 10 | site_table.qa == 11,:); % check this
            
            if strcmp(satellite, 'TROPOMI')
                site_table = site_table(abs(site_table.Date - sat_time(row)) <= time_threshold,:);
                time = sat_time(row);
            elseif strcmp(satellite, 'TEMPO')
                site_table = site_table(abs(site_table.Date - sat_time(col)) <= time_threshold,:);
                time = sat_time(col);
            end

            if isempty(site_table)
                % disp('No high qa pandora measurements in time window')
                continue
            end

            pandora_no2 = mean(site_table.NO2) .* conversion_factor;
            pandora_qa = NaN;
            % pandora_qa = site_table.qa;

            pandora_site = site_table.Site(1);

            
            temp_table = table({satellite}, pandora_site, time, sat_no2(ind), sat_qa(ind), sat_no2_u(ind), sat_vza(ind), sat_sza(ind), pandora_no2, pandora_qa, 'VariableNames', varnames);
            comparison_table = [comparison_table; temp_table];

        else
            % check next pandora location
            % disp('Skipping pandora location')
            continue
        end
    end
end

comparison_table = unique(comparison_table);

save_path = fullfile('/mnt/disks/data-disk/NERTO_2024/validation', 'pandora_comparison.mat');
save(save_path, 'comparison_table');