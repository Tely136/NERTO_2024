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

@REM Baltimore August 1 2023 to August 31 2024
@REM [38.82458203580504, -77.20583614427045], [39.34503591999901, -76.45867800794616]
matlab -batch "merge_no2('20230801','20230831', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20230901','20230930', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20231001','20231031', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20231101','20231130', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20231201','20231231', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20240101','20240131', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20240201','20240229', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20240301','20240331', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20240401','20240430', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20240501','20240531', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20240601','20240630', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20240701','20240731', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"
matlab -batch "merge_no2('20240801','20240831', [38.82 39.45], [-77.2 -76.45], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\baltimore', suffix='_baltimore');"


@REM NYC August 1 2023 to August 31 2024
@REM [40.496643415216845, -74.26594742186386], [40.952648352024184, -73.61226286796501]
matlab -batch "merge_no2('20230801','20230831', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20230901','20230930', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20231001','20231031', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20231101','20231130', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20231201','20231231', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20240101','20240131', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20240201','20240229', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20240301','20240331', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20240401','20240430', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20240501','20240531', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20240601','20240630', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20240701','20240731', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
matlab -batch "merge_no2('20240801','20240831', [40.5 40.95], [-74.26 -73.6], 'C:\NERTO_drive\TEMPO_data', 'C:\NERTO_drive\TROPOMI_data', 'C:\NERTO_drive\merged_data\nyc', suffix='_nyc');"
