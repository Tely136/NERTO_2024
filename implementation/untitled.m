clc; clearvars;

tempo_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TEMPO_data";
tropomi_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TROPOMI_data";
merged_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\merged_data";
fig_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\figs";

% Copy_of_merge_no2('20240525', '20240525', [38.75 41.3], [-77.5 -73.3], tempo_path, tropomi_path, merged_path, overwrite_on=true)
Copy_of_merge_no2('20230919', '20230919', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], tempo_path, tropomi_path, merged_path)


% plot_results('20240525', '20240525', [40.4 41.3], [-74.5 -73.3], merged_path, fig_path)