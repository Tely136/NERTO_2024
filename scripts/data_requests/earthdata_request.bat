@echo off

python earthdata_request.py --data_path "D:\data\TEMPO_data" --short_name "TEMPO_NO2_L2" --version "V03" --observation_start "2023-08-01 00:00:00" --observation_end "2024-08-30 00:00:00" --lat_min 38.0 --lat_max 42.0 --lon_min -80.0 --lon_max -70.0

python earthdata_request.py --data_path "D:\data\TROPOMI_data" --short_name "S5P_L2__NO2____HiR" --version "2" --observation_start "2023-08-01 00:00:00" --observation_end "2024-08-30 00:00:00" --lat_min 38.0 --lat_max 42.0 --lon_min -80.0 --lon_max -70.0
