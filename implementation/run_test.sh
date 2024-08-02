#!/bin/bash

# Maryland and NYC
#matlab -nodisplay -nosplash -r "test_implementation_func('20240601','20240607', [38 41.3], [-78 -72.7], '_TEST2'); exit"

# Maryland
#matlab -nodisplay -nosplash -r "test_implementation_func('20240601','20240607', [38 40], [-78 -75.8], '_TEST'); exit"

# DC, Baltimore, NYC
matlab -nodisplay -nosplash -r "test_implementation_func('20240601','20240607', [[40 41.5];[39 40];[38.5 39.5]], [[-75 -73];[-77 -76];[-78 -76]], '_TEST'); exit"