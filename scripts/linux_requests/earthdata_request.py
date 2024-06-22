import earthaccess
import os
from pathlib import Path


data_path = Path('/mnt/disks/data-disk/data/tempo_data/L2')

auth = earthaccess.login(strategy='environment')

# NASA Earthdata search parameters
short_name = 'TEMPO_NO2_L2'
version = 'V03'
observation_start = '2024-05-13 00:00:00'  # `YYYY-MM-DD HH:MM:SS'
observation_end = '2024-05-13 23:23:59'  # `YYYY-MM-DD HH:MM:SS'

lat_min = 39
lat_max = 44

lon_min = -77
lon_max = -70
bbox = (lon_min, lat_min, lon_max, lat_max)

# Search NASA Earthdata for TEMPO NO2 granules files
results = earthaccess.search_data(short_name=short_name, version=version, temporal=(observation_start, observation_end))

#print(results)
# Download granules files from NASA Earthdata
earthaccess.download(results, local_path=data_path)
