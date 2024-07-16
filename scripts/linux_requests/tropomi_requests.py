import earthaccess
import os
from pathlib import Path
from datetime import datetime, timedelta

# Define the start and end dates for the range
start_date = '2024-05-13'
end_date = '2024-07-01'

# Convert to datetime objects
start_date = datetime.strptime(start_date, '%Y-%m-%d')
end_date = datetime.strptime(end_date, '%Y-%m-%d')

# Path to store the data
data_path = Path('/mnt/disks/data-disk/data/tropomi_data/')

# Login using environment variables
auth = earthaccess.login(strategy='environment')

# NASA Earthdata search parameters for TROPOMI
products = {
    'NO2': 'S5P_L2__NO2____HiR',
    #'Radiance': 'S5P_L1B_RA_BD4_HiR',
    #'Irradiance': 'S5P_L1B_IR_UVN'
}
version = '2'

# Define the bounding box for the area of interest
lat_min = 37
lat_max = 44
lon_min = -78
lon_max = -70
bbox = (lon_min, lat_min, lon_max, lat_max)

# Define the temporal range for the full period
observation_start = start_date.strftime('%Y-%m-%dT00:00:00')
observation_end = (end_date + timedelta(days=1)).strftime('%Y-%m-%dT00:00:00')  # End date inclusive

for product, short_name in products.items():
    # Search NASA Earthdata for TROPOMI granules files within the time range
    if product == 'Irradiance':
        # Search for irradiance data only by date range
        results = earthaccess.search_data(
            short_name=short_name,
            version=version,
            temporal=(observation_start, observation_end)
        )
    else:
        # Search for NO2 and Radiance data within the specific time range and bounding box
        results = earthaccess.search_data(
            short_name=short_name,
            version=version,
            temporal=(observation_start, observation_end),
            bounding_box=bbox
        )

    # Download granules files from NASA Earthdata
    if results:
        earthaccess.download(results, local_path=data_path)
