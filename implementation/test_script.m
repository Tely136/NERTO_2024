clc; clearvars;

tempo_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TEMPO_data";
tropomi_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TROPOMI_data";
merged_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\merged_data";
fig_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\figs";


% lat_bounds = [38.75 41.3];
% lon_bounds = [-77.5 -73.3];

lat_bounds = [39 40];
lon_bounds = [-77 -76];
merge_no2('20240525', '20240525', lat_bounds, lon_bounds, tempo_path, tropomi_path, merged_path, overwrite_on=true)


plot_results('20240525', '20240525', lat_bounds, lon_bounds, merged_path, fig_path)