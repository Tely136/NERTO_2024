clearvars; close all; clc;

ccny_coords = [40.8153 -73.9505];
nybg_coords = [40.8679 -73.8781];
queens_coords = [40.7361 -73.8215];
beltsville_coords = [39.0553 -76.8783];
essex_coords = [39.3109 -76.4745];
greenbelt_2_coords = [38.9926 -76.8396];
greenbelt_32_coords = [38.9926 -76.8396];

varnames = {'SatelliteInstrument', 'PandoraInstrument', 'time', 'SatelliteNO2', 'SatelliteQA', 'SatelliteUncertainty', 'SatelliteVZA', 'SatelliteSZA', 'PandoraNO2', 'PandoraQA'};
vartypes = {'string', 'string', 'datetime', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};

all_coords = 1; % change later

tropomi_table_path = '/mnt/disks/data-disk/NERTO_2024/tropomi_files_table.mat';
load(tropomi_table_path);
tropomi_no2_table = tropomi_files_table(strcmp(tropomi_files_table.Product, 'NO2'), :);

distance_threshold = km2deg(10, 'earth'); 
time_threshold = minutes(600);

% load in tropomi file and geospatial info
for i = 1:size(tropomi_no2_table,1)
    temp_tropomi_no2_table = tropomi_no2_table(i,:);
    trop_filename = temp_tropomi_no2_table.Filename;

    trop_lat = ncread(trop_filename, '/PRODUCT/latitude');
    trop_lon = ncread(trop_filename, '/PRODUCT/longitude');

    % loop over pandora coords and look for collocated data in trop file
    for j = 1:length(all_coords)
        coords = beltsville_coords;

        lat_bounds = [coords(1)-distance_threshold, coords(1)+distance_threshold];
        lon_bounds = [coords(2)-distance_threshold, coords(2)+distance_threshold];

        [rows, cols] = get_indices2(trop_lat, trop_lon, lat_bounds, lon_bounds);
        if ~isempty(rows) & ~isempty(cols)
            % Load Tropomi data
            disp('Comparing')
            trop_data = read_tropomi_netcdf(temp_tropomi_no2_table, rows, cols);

            trop_no2 = trop_data.no2;
            trop_no2_u = trop_data.no2_u;
            trop_qa = trop_data.qa;

            trop_lat = trop_data.lat;
            trop_lon = trop_data.lon;
            trop_sza = trop_data.sza;
            trop_vza = trop_data.vza;
            trop_time = trop_data.time;

            high_qa_ind = find(trop_qa >= 0.75);



            % Loop over tropomi data and compare with pandora
            % OR find closest pixel with high QA and compare that with pandora
            ind = high_qa_ind(1); % for now just load first one
            [row, col] = ind2sub(size(trop_no2), ind);

            % Load Pandora Data
            load('/mnt/disks/data-disk/data/pandora_data/pandora_data.mat')
            site_table = pandora_data(strcmp(pandora_data.Site, 'greenbelt2'),:);
            % site_table = site_table(site_table.qa == 1 | site_table.qa == 0 | site_table.qa == 10 | site_table.qa == 11,:); % check this
            site_table = site_table(abs(site_table.Date - trop_time(row)) <= time_threshold,:);
            site_table = site_table(1,:);

            pandora_no2 = site_table.NO2;
            pandora_qa = site_table.qa;

            satellite = {'temp'};
            pandora_site = site_table.Site;
            comparison_table = table(satellite, pandora_site, trop_time(row), trop_no2(ind), trop_qa(ind), trop_no2_u(ind), trop_vza(ind), trop_sza(ind), pandora_no2, pandora_qa, 'VariableNames', varnames); % make table to hold satellite, pandora no2, and other info


        else
            % check next pandora location
            disp('Skipping pandora location')
            continue
        end
    end
    break; % load only one tropomi file fortesting
end