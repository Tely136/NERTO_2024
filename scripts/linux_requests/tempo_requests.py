import earthaccess
import os
from pathlib import Path
from datetime import datetime, timedelta

# Define the start and end dates for the range
start_date = '2023-08-01'
end_date = '2023-09-01'

# Convert to datetime objects
start_date = datetime.strptime(start_date, '%Y-%m-%d')
end_date = datetime.strptime(end_date, '%Y-%m-%d')

# Path to store the data
data_path = Path('/mnt/disks/data-disk/data/tempo_data/')

# Login using environment variables
auth = earthaccess.login(strategy='environment')

# NASA Earthdata search parameters
products = {
    'NO2': 'TEMPO_NO2_L2',
    #'Radiance': 'TEMPO_RAD_L1',
    #'Irradiance': 'TEMPO_IRR_L1'
}
version = 'V03'

# Define the bounding box for the area of interest
lat_min = 39
lat_max = 44
lon_min = -77
lon_max = -70
bbox = (lon_min, lat_min, lon_max, lat_max)

# Function to create UTC time range for TROPOMI overpass window with margin
def create_temporal_range_for_tropomi(date):
    # Define the time window in UTC
    start_time_utc = datetime.strptime(f"{date} 0:00:00", '%Y-%m-%d %H:%M:%S')
    end_time_utc = datetime.strptime(f"{date} 23:00:00", '%Y-%m-%d %H:%M:%S')
    
    return start_time_utc.strftime('%Y-%m-%dT%H:%M:%S'), end_time_utc.strftime('%Y-%m-%dT%H:%M:%S')

# Loop over each day in the range
current_date = start_date
while current_date <= end_date:
    # Create temporal range for the current day in UTC
    observation_start, observation_end = create_temporal_range_for_tropomi(current_date.strftime('%Y-%m-%d'))

    for product, short_name in products.items():
        if product == 'Irradiance':
            # Search for irradiance data only by date range
            results = earthaccess.search_data(
                short_name=short_name,
                version=version,
                temporal=(current_date.strftime('%Y-%m-%dT00:00:00'), current_date.strftime('%Y-%m-%dT23:59:59'))
            )
        else:
            # Search for NO2 and Radiance data within the specific time range and bounding box
            results = earthaccess.search_data(
                short_name=short_name,
                version=version,
                temporal=(observation_start, observation_end),
                bounding_box=bbox,
                granule_name='*G02*'
            )

        # Download granules files from NASA Earthdata
        if results:
            earthaccess.download(results, local_path=data_path)
    
    # Move to the next day
    current_date += timedelta(days=1)
