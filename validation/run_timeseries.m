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

distance_threshold = 5; % km

% CCNY
ccny_coords = [40.8153, -73.9505];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_ccny.mat', tempo_vars, distance_threshold, ccny_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_ccny.mat', tropomi_vars, distance_threshold, ccny_coords)
% time_series('F:\testing_data\TEMPO_data', 'F:\testing_data\time_series\tempo_ccny.mat', tempo_vars, distance_threshold, ccny_coords)
% time_series('F:\testing_data\TROPOMI_data', 'F:\testing_data\time_series\tropomi_ccny.mat', tropomi_vars, distance_threshold, ccny_coords)

% NYBG
nybg_coords = [40.8679, -73.8781];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_nybg.mat', tempo_vars, distance_threshold, nybg_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_nybg.mat', tropomi_vars, distance_threshold, nybg_coords)

% Queens College
queens_coords = [40.7361, -73.8215];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_queens.mat', tempo_vars, distance_threshold, queens_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_queens.mat', tropomi_vars, distance_threshold, queens_coords)

% Beltsville 
beltsville_coords = [39.0553, -76.8783];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_beltsville.mat', tempo_vars, distance_threshold, beltsville_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_beltsville.mat', tropomi_vars, distance_threshold, beltsville_coords)

% Essex
essex_coords = [39.3109, -76.4745];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_essex.mat', tempo_vars, distance_threshold, essex_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_essex.mat', tropomi_vars, distance_threshold, essex_coords)

% Greenbelt
greenbelt_coords = [38.9926, -76.8396];
time_series(tempo_input_folder, 'C:\NERTO_drive\time_series_data\tempo_greenbelt.mat', tempo_vars, distance_threshold, greenbelt_coords)
time_series(tropomi_input_folder, 'C:\NERTO_drive\time_series_data\tropomi_greenbelt.mat', tropomi_vars, distance_threshold, greenbelt_coords)