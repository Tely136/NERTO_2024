@echo off

@REM NYC and Baltimore June
@REM matlab -batch "merge_no2('20240601','20240630', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]]);"

@REM NYC and Baltimore July
@REM matlab -batch "merge_no2('20240701','20240731', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]]);"

@REM NYC and Baltimore August
@REM matlab -batch "merge_no2('20230801','20230831', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]]);"

@REM NYC and Baltimore December
@REM matlab -batch "merge_no2('20231227','20231231', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]]);"

@REM NYC and Baltimore TEST May 2024
@REM matlab -batch "merge_no2('20240501','20240531', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"

@REM NYC and Baltimore TEST August 1 2023 to August 31 2024
matlab -batch "merge_no2('20230801','20230831', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data');"
@REM matlab -batch "merge_no2('20230901','20230930', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20231001','20231031', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20231101','20231130', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20231201','20231231', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20240101','20240131', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20240201','20240229', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20240301','20240331', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20240401','20240430', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20240501','20240531', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20240601','20240630', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20240701','20240731', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
@REM matlab -batch "merge_no2('20240801','20240831', [[38.75 39.75];[40.4 41.3]], [[-77.5 -76];[-74.5 -73.3]], 'D:\data\TEMPO_data', 'D:\data\TROPOMI_data', 'D:\data\merged_data');"
