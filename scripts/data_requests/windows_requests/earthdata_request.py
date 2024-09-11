import earthaccess
import os
from pathlib import Path

if not os.path.exists('/content/data_files'):
    Path('/content/data_files').mkdir()

if not os.path.exists('/content/temp_data'):
    Path('/content/temp_data').mkdir()

data_path = Path('/content/data_files')
temp_path = Path('/content/temp_data')

auth = earthaccess.login(strategy='environment')

# NASA Earthdata search parameters
short_name = 'TEMPO_NO2_L2'
observation_start = '2023-08-22 18:33:00'  # `YYYY-MM-DD HH:MM:SS'
observation_end = '2023-08-22 19:34:00'  # `YYYY-MM-DD HH:MM:SS'

lat_min = 39
lat_max = 44

lon_min = -77
lon_max = -70
bbox = (lon_min, lat_min, lon_max, lat_max)

# Search NASA Earthdata for TEMPO NO2 granules files
results = earthaccess.search_data(short_name=short_name,
                                  temporal=(observation_start, observation_end),
                                  bounding_box=bbox)

# Download granules files from NASA Earthdata
earthaccess.download(results, local_path=data_path)
