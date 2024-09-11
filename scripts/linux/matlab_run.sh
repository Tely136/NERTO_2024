#!/bin/bash

# Check if the path to the MATLAB script is provided
#if [ -z "$1" ]; then
#  echo "Usage: $0 path_to_matlab_script"
#  exit 1
#fi

# Store the path to the MATLAB script
matlab_script_path="$1"

# Run the MATLAB script using the provided path
matlab -nodisplay -nosplash -r "run('$matlab_script_path'); exit"
