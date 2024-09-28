clc; clearvars;

tempo_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TEMPO_data";
tropomi_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\TROPOMI_data";
merged_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\merged_data";
fig_path = "C:\Users\tely1\OneDrive - The City College of New York\NERTO Data\figs";

merge_no2('20240525', '20240525', [38.75 41.3], [-77.5 -73.3], tempo_path, tropomi_path, merged_path, overwrite_on=true)


plot_results('20240525', '20240525', [38.75 41.3], [-77.5 -73.3], merged_path, fig_path)