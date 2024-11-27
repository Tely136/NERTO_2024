clc; clearvars; 

lat_bounds = [38.5 45.1];
lon_bounds = [-82 -71];

tempo_path = "C:\NERTO_drive\TEMPO_data";
tropomi_path = "C:\NERTO_drive\TROPOMI_data";
merged_path = "C:\NERTO_drive\merged_md_ny";

merge_no2('20240524','20240524', lat_bounds, lon_bounds, tempo_path, tropomi_path, merged_path, suffix='');

