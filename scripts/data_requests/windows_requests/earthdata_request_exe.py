import earthaccess
import sys

auth = earthaccess.login(strategy='environment')

# NASA Earthdata search parameters
short_name = sys.argv[1]
version = sys.argv[2]
observation_start = sys.argv[3]  # `YYYY-MM-DD HH:MM:SS'
observation_end = sys.argv[4]  # `YYYY-MM-DD HH:MM:SS'

lat_min = float(sys.argv[5])
lat_max = float(sys.argv[6])

lon_min = float(sys.argv[7])
lon_max = float(sys.argv[8])
bbox = (lon_min, lat_min, lon_max, lat_max)

data_path = sys.argv[8]

# Search NASA Earthdata for TEMPO NO2 granules files
results = earthaccess.search_data(short_name=short_name,
                                  version=version,
                                  temporal=(observation_start, observation_end),
                                  bounding_box=bbox)

# Download granules files from NASA Earthdata
earthaccess.download(results, local_path=data_path)


