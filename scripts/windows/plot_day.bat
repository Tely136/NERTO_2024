@echo off

@REM NYC June 2024
@REM matlab -batch "plot_results('20240601','20240601', [40.4 41.3], [-74.5 -73.3], save_path='/mnt/disks/data-disk/figures/results/NYC');"

@REM Baltimore June 2024
@REM matlab -batch "plot_results('20240601','20240601', [38.75 39.75], [-77.5 -76], save_path='/mnt/disks/data-disk/figures/results/Baltimore');"

@REM TEST May 25, 2024
@REM matlab -batch "plot_results('20240525','20240525', [38.75 39.75], [-77.5 -76], 'D:\data\merged_data', 'D:\figures\results\Baltimore');"

@REM TEST May 25, 2024
matlab -batch "plot_results('20230802','20230809', [38.75 39.75], [-77.5 -76], 'C:\NERTO_drive\merged_data\baltimore', 'C:\NERTO_drive\figures\results\Baltimore');"
