import earthaccess
import os
from pathlib import Path


data_path = Path('/mnt/disks/data-disk/data/tropomi_data/L2')

auth = earthaccess.login(strategy='environment')

# NASA Earthdata search parameters
short_name = 'S5P_L2__NO2____HiR'
version = 'V02'
observation_start = '2024-03-01 00:00:00'  # `YYYY-MM-DD HH:MM:SS'
observation_end = '2024-04-30 23:23:59'  # `YYYY-MM-DD HH:MM:SS'

lat_min = 39
lat_max = 44

lon_min = -77
lon_max = -70
bbox = (lon_min, lat_min, lon_max, lat_max)

# Search NASA Earthdata for TEMPO NO2 granules files
results = earthaccess.search_data(short_name=short_name, temporal=(observation_start, observation_end), bounding_box=bbox)

#print(results)
# Download granules files from NASA Earthdata
earthaccess.download(results, local_path=data_path)
