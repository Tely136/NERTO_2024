clc; clearvars;

tempo_path = "C:\NERTO_drive\TEMPO_data";
tropomi_path = "C:\NERTO_drive\TROPOMI_data";
merged_path = "C:\NERTO_drive\merged_data_full";

lat_bounds = [14 52];
lon_bounds = [-130 -55];

merge_no2('20240801', '20240831', lat_bounds, lon_bounds, tempo_path, tropomi_path, merged_path, overwrite_on=true)
