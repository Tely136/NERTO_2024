clearvars; close all; clc;

load('/mnt/disks/data-disk/NERTO_2024/validation/tempo_pandora_comparison.mat');

comparison_table.TempoNO2 = comparison_table.TempoNO2.*10^6./conversion_factor('trop-tempo');
comparison_table(comparison_table.TempoNO2<0,:) = [];
comparison_table.PandoraNO2 = comparison_table.PandoraNO2.*10^6;

bounds = 500;

site = 'ccny';
temp_comparison_table = comparison_table(strcmp(comparison_table.Site,site),:);
create_and_save_fig_scatter(temp_comparison_table.PandoraNO2, temp_comparison_table.TempoNO2, '/mnt/disks/data-disk/figures/validation', 'ccny_correlation', string(site), 'TEMPO', 'PANDORA', 'TEMPO', [0 bounds], [0 bounds])

site = 'nybg';
temp_comparison_table = comparison_table(strcmp(comparison_table.Site,site),:);
create_and_save_fig_scatter(temp_comparison_table.PandoraNO2, temp_comparison_table.TempoNO2, '/mnt/disks/data-disk/figures/validation', 'nybg_correlation', string(site), 'TEMPO', 'PANDORA', 'TEMPO', [0 bounds], [0 bounds])

site = 'queens';
temp_comparison_table = comparison_table(strcmp(comparison_table.Site,site),:);
create_and_save_fig_scatter(temp_comparison_table.PandoraNO2, temp_comparison_table.TempoNO2, '/mnt/disks/data-disk/figures/validation', 'queens_correlation', string(site), 'TEMPO', 'PANDORA', 'TEMPO', [0 bounds], [0 bounds])

site = 'essex';
temp_comparison_table = comparison_table(strcmp(comparison_table.Site,site),:);
create_and_save_fig_scatter(temp_comparison_table.PandoraNO2, temp_comparison_table.TempoNO2, '/mnt/disks/data-disk/figures/validation', 'essex_correlation', string(site), 'TEMPO', 'PANDORA', 'TEMPO', [0 bounds], [0 bounds])

site = 'greenbelt2';
temp_comparison_table = comparison_table(strcmp(comparison_table.Site,site),:);
create_and_save_fig_scatter(temp_comparison_table.PandoraNO2, temp_comparison_table.TempoNO2, '/mnt/disks/data-disk/figures/validation', 'greenbelt2_correlation', string(site), 'TEMPO', 'PANDORA', 'TEMPO', [0 bounds], [0 bounds])

site = 'greenbelt32';
temp_comparison_table = comparison_table(strcmp(comparison_table.Site,site),:);
create_and_save_fig_scatter(temp_comparison_table.PandoraNO2, temp_comparison_table.TempoNO2, '/mnt/disks/data-disk/figures/validation', 'greenbelt32_correlation', string(site), 'TEMPO', 'PANDORA', 'TEMPO', [0 bounds], [0 bounds])

site = 'beltsville';
temp_comparison_table = comparison_table(strcmp(comparison_table.Site,site),:);
create_and_save_fig_scatter(temp_comparison_table.PandoraNO2, temp_comparison_table.TempoNO2, '/mnt/disks/data-disk/figures/validation', 'beltsville_correlation', string(site), 'TEMPO', 'PANDORA', 'TEMPO', [0 bounds], [0 bounds])
