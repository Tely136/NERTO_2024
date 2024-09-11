@echo off

@REM Time-series Baltimore
matlab -batch "time_series('C:\NERTO_drive\merged_data\baltimore', 'C:\NERTO_drive\time_series_data')"

@REM Time-series NYC
matlab -batch "time_series('C:\NERTO_drive\merged_data\nyc', 'C:\NERTO_drive\time_series_data')"