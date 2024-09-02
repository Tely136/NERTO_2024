@echo off

@REM NYC August 2023
@REM matlab -nodisplay -nosplash -r "plot_results_avg('20230801','20230831', [40.4 41.3], [-74.5 -73.3], '/mnt/disks/data-disk/figures/results/averages/NYC/202308', update_clim=[-50 50], merged_clim=[0 200], tempo_clim=[0 200], tropomi_clim=[0 200]); exit"

@REM NYC December 2023
@REM matlab -nodisplay -nosplash -r "plot_results_avg('20231201','20231231', [40.4 41.3], [-74.5 -73.3], '/mnt/disks/data-disk/figures/results/averages/NYC/202312', update_clim=[-200 200], merged_clim=[0 500], tempo_clim=[0 500], tropomi_clim=[0 500]); exit"

@REM NYC June 2024
@REM matlab -nodisplay -nosplash -r "plot_results_avg('20240601','20240630', [40.4 41.3], [-74.5 -73.3], '/mnt/disks/data-disk/figures/results/averages/NYC/202406', update_clim=[-50 50], merged_clim=[0 250], tempo_clim=[0 250], tropomi_clim=[0 250]); exit"

@REM NYC July 2024
@REM matlab -nodisplay -nosplash -r "plot_results_avg('20240701','20240731', [40.4 41.3], [-74.5 -73.3], '/mnt/disks/data-disk/figures/results/averages/NYC/202407', update_clim=[-50 50], merged_clim=[0 250], tempo_clim=[0 250], tropomi_clim=[0 250]); exit"



@REM Baltimore August 2023
@REM matlab -nodisplay -nosplash -r "plot_results_avg('20230801','20230831', [38.75 39.75], [-77.5 -76], '/mnt/disks/data-disk/figures/results/averages/Baltimore/202308', update_clim=[-50 50], merged_clim=[0 100], tempo_clim=[0 100], tropomi_clim=[0 100]); exit"

@REM Baltimore December 2023
@REM matlab -nodisplay -nosplash -r "plot_results_avg('20231201','20231231', [38.75 39.75], [-77.5 -76], '/mnt/disks/data-disk/figures/results/averages/Baltimore/202312'); exit"

@REM Baltimore June 2024
@REM matlab -nodisplay -nosplash -r "plot_results_avg('20240601','20240630', [38.75 39.75], [-77.5 -76], '/mnt/disks/data-disk/figures/results/averages/Baltimore/202406', update_clim=[-50 50], merged_clim=[0 100], tempo_clim=[0 100], tropomi_clim=[0 100]); exit"

@REM Baltimore July 2024
@REM matlab -nodisplay -nosplash -r "plot_results_avg('20240701','20240731', [38.75 39.75], [-77.5 -76], '/mnt/disks/data-disk/figures/results/averages/Baltimore/202407', update_clim=[-50 50], merged_clim=[0 100], tempo_clim=[0 100], tropomi_clim=[0 100]); exit"


@REM TEST NYC May 2024
matlab -batch "plot_results_avg('20240501','20240531', [40.4 41.3], [-74.5 -73.3], 'D:\data\merged_data', 'D:\figures\results\averages\NYC\202405', update_clim=[-50 50], merged_clim=[0 250], tempo_clim=[0 250], tropomi_clim=[0 250]); exit"

@REM TEST Baltimore May 2024
matlab -batch "plot_results_avg('20240501','20240531', [38.75 39.75], [-77.5 -76], 'D:\data\merged_data', 'D:\figures\results\averages\Baltimore\202405', update_clim=[-50 50], merged_clim=[0 100], tempo_clim=[0 100], tropomi_clim=[0 100]);"
