clearvars; clc; close all;

load('/mnt/disks/data-disk/NERTO_2024/validation/pandora_comparison.mat');

tropomi_data = comparison_table(strcmp(comparison_table.SatelliteInstrument, 'TROPOMI'),:);
tempo_data = comparison_table(strcmp(comparison_table.SatelliteInstrument, 'TEMPO'),:);


create_and_save_fig_scatter(tropomi_data.PandoraNO2, tropomi_data.SatelliteNO2, '/mnt/disks/data-disk/figures/validation', 'trop_pandora', 'TROPOMI Pandora Comparison', [], 'Pandora Tropospheric NO2 VCD [molec/cm^2]', 'TROPOMI Tropospheric NO2 VCD [molec/cm^2]')
create_and_save_fig_scatter(tempo_data.PandoraNO2, tempo_data.SatelliteNO2, '/mnt/disks/data-disk/figures/validation', 'tempo_pandora', 'TEMPO Pandora Comparison', [], 'Pandora Tropospheric NO2 VCD [molec/cm^2]', 'TEMPO Tropospheric NO2 VCD [molec/cm^2]')
