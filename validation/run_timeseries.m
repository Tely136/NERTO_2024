clc; clearvars;

tempo_input_folder = 'C:\NERTO_drive\TEMPO_data';
tempo_vars = ["/geolocation/latitude", "/geolocation/longitude", "/geolocation/time", "/product/vertical_column_troposphere", ...
              "/product/vertical_column_troposphere_uncertainty", "/product/main_data_quality_flag", "/geolocation/solar_zenith_angle", ...
              "/geolocation/viewing_zenith_angle", "/support_data/albedo", "/support_data/eff_cloud_fraction", ];

tropomi_input_folder = 'C:\NERTO_drive\TROPOMI_data';
tropomi_vars = ["/PRODUCT/latitude", "/PRODUCT/longitude", "/PRODUCT/time", "/PRODUCT/delta_time", "/PRODUCT/nitrogendioxide_tropospheric_column", ...
                "/PRODUCT/nitrogendioxide_tropospheric_column_precision", "/PRODUCT/qa_value", "/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/solar_zenith_angle", ...
                "/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/viewing_zenith_angle", "/PRODUCT/SUPPORT_DATA/INPUT_DATA/surface_albedo_nitrogendioxide_window", ...
                "/PRODUCT/SUPPORT_DATA/INPUT_DATA/cloud_fraction_crb"];

merged_input_folder = 'C:\NERTO_drive\merged_data_ams';
merged_vars = ["geolocation/latitude", "geolocation/longitude", "geolocation/time", "product/vertical_column_troposphere", "product/vertical_column_troposphere_uncertainty"];

distance_threshold = 5; % km

% CCNY
ccny_coords = [40.8153, -73.9505];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_ccny.mat', tempo_vars, distance_threshold, ccny_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_ccny.mat', tropomi_vars, distance_threshold, ccny_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_ccny.mat', merged_vars, distance_threshold, ccny_coords)

% NYBG
nybg_coords = [40.8679, -73.8781];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_nybg.mat', tempo_vars, distance_threshold, nybg_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_nybg.mat', tropomi_vars, distance_threshold, nybg_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_nybg.mat', merged_vars, distance_threshold, nybg_coords)

% Queens College
queens_coords = [40.7361, -73.8215];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_queens.mat', tempo_vars, distance_threshold, queens_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_queens.mat', tropomi_vars, distance_threshold, queens_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_queens.mat', merged_vars, distance_threshold, queens_coords)

% Beltsville 
beltsville_coords = [39.0553, -76.8783];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_beltsville.mat', tempo_vars, distance_threshold, beltsville_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_beltsville.mat', tropomi_vars, distance_threshold, beltsville_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_beltsville.mat', merged_vars, distance_threshold, beltsville_coords)

% Essex
essex_coords = [39.3109, -76.4745];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_essex.mat', tempo_vars, distance_threshold, essex_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_essex.mat', tropomi_vars, distance_threshold, essex_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_essex.mat', merged_vars, distance_threshold, essex_coords)

% Greenbelt
greenbelt_coords = [38.9926, -76.8396];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_greenbelt.mat', tempo_vars, distance_threshold, greenbelt_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_greenbelt.mat', tropomi_vars, distance_threshold, greenbelt_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_greenbelt.mat', merged_vars, distance_threshold, greenbelt_coords)

copyfile('C:\NERTO_drive\time_series_data\tempo_greenbelt.mat', 'C:\NERTO_drive\time_series_data\tempo_greenbelt2.mat')
copyfile('C:\NERTO_drive\time_series_data\tempo_greenbelt.mat', 'C:\NERTO_drive\time_series_data\tempo_greenbelt32.mat')
copyfile('C:\NERTO_drive\time_series_data\tropomi_greenbelt.mat', 'C:\NERTO_drive\time_series_data\tropomi_greenbelt2.mat')
copyfile('C:\NERTO_drive\time_series_data\tropomi_greenbelt.mat', 'C:\NERTO_drive\time_series_data\tropomi_greenbelt32.mat')
copyfile('C:\NERTO_drive\time_series_data\merged_greenbelt.mat', 'C:\NERTO_drive\time_series_data\merged_greenbelt2.mat')
copyfile('C:\NERTO_drive\time_series_data\merged_greenbelt.mat', 'C:\NERTO_drive\time_series_data\merged_greenbelt32.mat')

% DC
DC_coords = [38.9218, -77.0124];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_DC.mat', tempo_vars, distance_threshold, DC_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_DC.mat', tropomi_vars, distance_threshold, DC_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_DC.mat', merged_vars, distance_threshold, DC_coords)

% New Brunswick
new_brunsick_coords = [40.4622, -74.4294];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_new_brunsick.mat', tempo_vars, distance_threshold, new_brunsick_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_new_brunsick.mat', tropomi_vars, distance_threshold, new_brunsick_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_new_brunsick.mat', merged_vars, distance_threshold, new_brunsick_coords)

% New Haven
new_haven_coords = [41.3014, -72.9029];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_new_haven.mat', tempo_vars, distance_threshold, new_haven_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_new_haven.mat', tropomi_vars, distance_threshold, new_haven_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_new_haven.mat', merged_vars, distance_threshold, new_haven_coords)

% Cornwall
cornwall_coords = [41.8213, -73.2973];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_cornwall.mat', tempo_vars, distance_threshold, cornwall_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_cornwall.mat', tropomi_vars, distance_threshold, cornwall_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_cornwall.mat', merged_vars, distance_threshold, cornwall_coords)

% Madison
madison_coords = [41.2568, -72.5533];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_madison.mat', tempo_vars, distance_threshold, madison_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_madison.mat', tropomi_vars, distance_threshold, madison_coords)
time_series(merged_input_folder, 'C:\NERTO_drive\time_series_data\merged_madison.mat', merged_vars, distance_threshold, madison_coords)

