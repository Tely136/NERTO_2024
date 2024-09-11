import earthaccess
import os
from pathlib import Path
import argparse

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Search and download TEMPO NO2 data from NASA Earthdata.')
parser.add_argument('--data_path', type=str, required=True, help='Path to store the downloaded data')
parser.add_argument('--short_name', type=str, required=True, help='Short name of the dataset')
parser.add_argument('--version', type=str, help='Version of the dataset')
parser.add_argument('--observation_start', type=str, required=True, help='Observation start time in `YYYY-MM-DD HH:MM:SS` format')
parser.add_argument('--observation_end', type=str, required=True, help='Observation end time in `YYYY-MM-DD HH:MM:SS` format')
parser.add_argument('--lat_min', type=float, help='Minimum latitude')
parser.add_argument('--lat_max', type=float, help='Maximum latitude')
parser.add_argument('--lon_min', type=float, help='Minimum longitude')
parser.add_argument('--lon_max', type=float, help='Maximum longitude')

args = parser.parse_args()

data_path = Path(args.data_path)

auth = earthaccess.login(strategy='environment')

# NASA Earthdata search parameters
search_params = {
    'short_name': args.short_name,
    'temporal': (args.observation_start, args.observation_end)
}

if args.version:
    search_params['version'] = args.version

if args.lat_min is not None and args.lat_max is not None and args.lon_min is not None and args.lon_max is not None:
    search_params['bounding_box'] = (args.lon_min, args.lat_min, args.lon_max, args.lat_max)

# Search NASA Earthdata for TEMPO NO2 granules files
results = earthaccess.search_data(**search_params)

# Calculate the number of granules and total download size
num_granules = len(results)
total_size_gb = sum(granule['size'] for granule in results) / (1024 ** 3)  # Size in GB

# Display the information
print(f'Number of granules: {num_granules}')
print(f'Total download size: {total_size_gb:.2f} GB')


earthaccess.download(results, local_path=data_path)
print('Download completed.')
