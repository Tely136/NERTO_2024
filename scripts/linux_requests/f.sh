#!/bin/bash

# Define variables that don't change
OBSERVATION_START="2024-03-25 00:00:00"
OBSERVATION_END="2024-03-25 23:23:59"
LAT_MIN=39
LAT_MAX=44
LON_MIN=-77
LON_MAX=-70

# TEMPO NO2
DATA_PATH="/mnt/disks/data-disk/data/tempo_data/L2"
SHORT_NAME="TEMPO_NO2_L2"
VERSION="V03"

#python3 earthdata_request_executable.py --data_path "$DATA_PATH" --short_name "$SHORT_NAME" --version "$VERSION" --observation_start "$OBSERVATION_START" --observation_end "$OBSERVATION_END" --lat_min "$LAT_MIN" --lat_max "$LAT_MAX" --lon_min "$LON_MIN" --lon_max "$LON_MAX"


# TEMPO Radiance
DATA_PATH="/mnt/disks/data-disk/data/tempo_data/L1"
SHORT_NAME="TEMPO_RAD_L1"
VERSION="V02"

#python3 earthdata_request_executable.py --data_path "$DATA_PATH" --short_name "$SHORT_NAME" --version "$VERSION" --observation_start "$OBSERVATION_START" --observation_end "$OBSERVATION_END" --lat_min "$LAT_MIN" --lat_max "$LAT_MAX" --lon_min "$LON_MIN" --lon_max "$LON_MAX"


# TEMPO Irradiance
DATA_PATH="/mnt/disks/data-disk/data/tempo_data/L1"
SHORT_NAME="TEMPO_IRR_L1"
VERSION="V03"

#python3 earthdata_request_executable.py --data_path "$DATA_PATH" --short_name "$SHORT_NAME" --version "$VERSION" --observation_start "$OBSERVATION_START" --observation_end "$OBSERVATION_END"


# TROPOMI NO2
DATA_PATH="/mnt/disks/data-disk/data/tropomi_data/L2"
SHORT_NAME="S5P_L2__NO2____HiR"
VERSION="2"

#python3 earthdata_request_executable.py --data_path "$DATA_PATH" --short_name "$SHORT_NAME" --version "$VERSION" --observation_start "$OBSERVATION_START" --observation_end "$OBSERVATION_END" --lat_min "$LAT_MIN" --lat_max "$LAT_MAX" --lon_min "$LON_MIN" --lon_max "$LON_MAX"


# TROPOMI Radiance
DATA_PATH="/mnt/disks/data-disk/data/tropomi_data/L1"
SHORT_NAME="S5P_L1B_RA_BD4_HiR"
VERSION="2"

#python3 earthdata_request_executable.py --data_path "$DATA_PATH" --short_name "$SHORT_NAME" --version "$VERSION" --observation_start "$OBSERVATION_START" --observation_end "$OBSERVATION_END" --lat_min "$LAT_MIN" --lat_max "$LAT_MAX" --lon_min "$LON_MIN" --lon_max "$LON_MAX"


# TROPOMI Irradiance
DATA_PATH="/mnt/disks/data-disk/data/tropomi_data/L1"
SHORT_NAME="S5P_L1B_IR_UVN"
VERSION="2"
OBSERVATION_START="2024-03-15 00:00:00"
OBSERVATION_END="2024-03-30 23:23:59"

python3 earthdata_request_executable.py --data_path "$DATA_PATH" --short_name "$SHORT_NAME" --version "$VERSION" --observation_start "$OBSERVATION_START" --observation_end "$OBSERVATION_END"
