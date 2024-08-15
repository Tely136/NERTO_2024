#!/bin/bash

# NYC June 2024
matlab -nodisplay -nosplash -r "plot_results_avg('20240601','20240630', [40.4 41.3], [-74.5 -73.3], save_path='/mnt/disks/data-disk/figures/results/averages/NYC'); exit"

# NYC July 2024
matlab -nodisplay -nosplash -r "plot_results_avg('20240601','20240630', [40.4 41.3], [-74.5 -73.3], save_path='/mnt/disks/data-disk/figures/results/averages/NYC'); exit"

# Baltimore June 2024
matlab -nodisplay -nosplash -r "plot_results_avg('20240701','20240731', [38.75 39.75], [-77.5 -76], save_path='/mnt/disks/data-disk/figures/results/averages/Baltimore'); exit"

# Baltimore July 2024
matlab -nodisplay -nosplash -r "plot_results_avg('20240701','20240731', [38.75 39.75], [-77.5 -76], save_path='/mnt/disks/data-disk/figures/results/averages/Baltimore'); exit"
