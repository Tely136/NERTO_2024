#!/bin/bash

# Baltimore
#matlab -nodisplay -nosplash -r "merge_no2_func('20240601','20240601', [38.75 39.75], [-77 -76]); exit"

# NYC and Baltimore June
# matlab -nodisplay -nosplash -r "merge_no2_func('20240601','20240630', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]]); exit"

# NYC and Baltimore July
# matlab -nodisplay -nosplash -r "merge_no2_func('20240701','20240731', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]]); exit"

# NYC and Baltimore August
# matlab -nodisplay -nosplash -r "merge_no2('20230801','20230831', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]]); exit"

# NYC and Baltimore December
matlab -nodisplay -nosplash -r "merge_no2('20231201','20231231', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]]); exit"
