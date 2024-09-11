@echo off

@REM add 1:1 dashed line, change title, play with marker size and fill
matlab -batch "correlation_plot('C:\NERTO_drive\time_series_data\time_series_data.mat', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat', 'C:\NERTO_drive\correlations', 'C:\NERTO_drive\figures\correlation', overwrite_on=false)"
@REM matlab -batch "correlation_plot('C:\NERTO_drive\time_series_data\time_series_data.mat', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat', 'C:\NERTO_drive\correlations', 'C:\NERTO_drive\figures\correlation', overwrite_on=true)"