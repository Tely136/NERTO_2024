clearvars; clc; close all;

results_path = '/mnt/disks/data-disk/data/merged_data';

scan = 9;

files = dir(fullfile(results_path,'*.mat'));


% lat_bounds = [40 42]; % new york
% lon_bounds = [-75, -72];

lat_bounds = [39 40];
lon_bounds = [-77 -76];

day = 20;
month = 5;
year = 2024;

plot_timezone = 'America/New_York';
day_tz = datetime(year, month, day, 'TimeZone', plot_timezone);
day_utc = datetime(year, month, day, 'TimeZone', 'UTC');


font_size = 20;
resolution = 300;
dim = [0, 0, 1200, 900];

no2_max = 0;
no2_u_max = 0;

clim = [0 3*10^16];
lw = 2;
% clim = [min([xb(:); xo(:); xa(:)]), max([xb(:); xo(:); xa(:)])];

states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');
save_path = '/mnt/disks/data-disk/figures/results';


% TEMPO NO2 Column
fig1_savename = 'tempo';
fig1 = figure('Visible','off', 'Position', dim);
usamap(lat_bounds, lon_bounds);
ax1 = gca;
hold(ax1, 'on');
for i = 1:size(files,1)
    temp_data = load(fullfile(files(i).folder, files(i).name)).save_data;
    temp_data.tempo_scan;
    temp_data.tempo_granule;
    if temp_data.tempo_scan == scan && temp_data.tempo_time >= day_tz && temp_data.tempo_time < day_tz+days(1)
        surfm(temp_data.bg_lat, temp_data.bg_lon, temp_data.bg_no2);
        no2_max = max([temp_data.bg_no2(:); no2_max]);
    end
end
geoshow(ax1, states, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
fontsize(font_size, 'points');
title(strjoin([string(mean(temp_data.bg_time)), 'UTC TEMPO trop-NO2 [molec/cm^2]']));
colorbar
setm(ax1, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');
colormap('jet')
hold(ax1, 'off');

% TEMPO NO2 Uncertainty
fig4_savename = 'tempo_u';
fig4 = figure('Visible','off', 'Position', dim);
usamap(lat_bounds, lon_bounds);
ax4 = gca;
hold(ax4, 'on');
for i = 1:size(files,1)
    temp_data = load(fullfile(files(i).folder, files(i).name)).save_data;
    temp_data.tempo_scan;
    temp_data.tempo_granule;
    if temp_data.tempo_scan == scan && temp_data.tempo_time >= day_tz && temp_data.tempo_time < day_tz+days(1)
        surfm(temp_data.bg_lat, temp_data.bg_lon, temp_data.bg_no2_u);
        no2_u_max = max([temp_data.bg_no2_u(:); no2_u_max]);
    end
end
geoshow(ax4, states, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
fontsize(font_size, 'points');
title(strjoin([string(mean(temp_data.bg_time)), 'UTC TEMPO trop-NO2 Uncertainty [molec/cm^2]']));
colorbar
setm(ax4, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');
colormap('jet')
hold(ax4, 'off');


% TROPOMI NO2 Column
fig2_savename = 'tropomi';
fig2 = figure('Visible','off', 'Position', dim);
usamap(lat_bounds, lon_bounds);
ax2 = gca;
hold(ax2, 'on');
for i = 1:size(files,1)
    temp_data = load(fullfile(files(i).folder, files(i).name)).save_data;
    temp_data.tempo_scan;
    temp_data.tempo_granule;
    if temp_data.tempo_scan == scan && temp_data.tempo_time >= day_tz && temp_data.tempo_time < day_tz+days(1)
        surfm(temp_data.obs_lat, temp_data.obs_lon, temp_data.obs_no2);
        no2_max = max([temp_data.obs_no2(:); no2_max]);
    end
end
geoshow(states, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
fontsize(font_size, 'points');
title(strjoin([string(mean(temp_data.obs_time)), 'UTC TROPOMI trop-NO2 [molec/cm^2]']));
colorbar
ax2 = gca;
setm(ax2, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');
colormap('jet')
hold(ax2, 'off');


% TROPOMI NO2 Uncertainty
fig5_savename = 'tropomi_u';
fig5 = figure('Visible','off', 'Position', dim);
usamap(lat_bounds, lon_bounds);
ax5 = gca;
hold(ax5, 'on');
for i = 1:size(files,1)
    temp_data = load(fullfile(files(i).folder, files(i).name)).save_data;
    temp_data.tempo_scan;
    temp_data.tempo_granule;
    if temp_data.tempo_scan == scan && temp_data.tempo_time >= day_tz && temp_data.tempo_time < day_tz+days(1)
        surfm(temp_data.obs_lat, temp_data.obs_lon, temp_data.obs_no2_u);
        no2_u_max = max([temp_data.obs_no2_u(:); no2_u_max]);
    end
end
geoshow(states, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
fontsize(font_size, 'points');
title(strjoin([string(mean(temp_data.obs_time)), 'UTC TROPOMI trop-NO2 Uncertainty [molec/cm^2]']));
colorbar
ax5 = gca;
setm(ax5, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');
colormap('jet')
hold(ax5, 'off');



% Merged data NO2
fig3_savename = 'merged';
fig3 = figure('Visible','off', 'Position', dim);
usamap(lat_bounds, lon_bounds);
ax3 = gca;
hold(ax3, 'on');
for i = 1:size(files,1)
    temp_data = load(fullfile(files(i).folder, files(i).name)).save_data;
    temp_data.tempo_scan;
    temp_data.tempo_granule;
    if temp_data.tempo_scan == scan && temp_data.tempo_time >= day_tz && temp_data.tempo_time < day_tz+days(1)
        surfm(temp_data.bg_lat, temp_data.bg_lon, temp_data.analysis_no2);
        no2_max = max([temp_data.analysis_no2(:); no2_max]);
    end
end
geoshow(states, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
fontsize(font_size, 'points');
title('Merged Result trop-NO2 [molec/cm^2]');
colorbar
ax3 = gca;
setm(ax3, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');
colormap('jet')
hold(ax3, 'off');


% Merged data NO2 Uncertainty
fig6_savename = 'merged_u';
fig6 = figure('Visible','off', 'Position', dim);
usamap(lat_bounds, lon_bounds);
ax6 = gca;
hold(ax6, 'on');
for i = 1:size(files,1)
    temp_data = load(fullfile(files(i).folder, files(i).name)).save_data;
    temp_data.tempo_scan;
    temp_data.tempo_granule;
    if temp_data.tempo_scan == scan && temp_data.tempo_time >= day_tz && temp_data.tempo_time < day_tz+days(1)
        surfm(temp_data.bg_lat, temp_data.bg_lon, temp_data.analysis_no2_u);
        no2_u_max = max([temp_data.analysis_no2_u(:); no2_u_max]);
    end
end
geoshow(states, "DisplayType", "polygon", 'FaceAlpha', 0, 'LineWidth', lw);
fontsize(font_size, 'points');
title('Merged Result trop-NO2 Uncertainty [molec/cm^2]');
colorbar
ax6 = gca;
setm(ax6, 'Frame', 'off', 'Grid', 'off', 'ParallelLabel', 'off', 'MeridianLabel', 'off');
colormap('jet')
hold(ax6, 'off');


ax1.CLim = [0 no2_max];
ax2.CLim = [0 no2_max];
ax3.CLim = [0 no2_max];

ax4.CLim = [0 no2_u_max];
ax5.CLim = [0 no2_u_max];
ax6.CLim = [0 2*10^15];


fullpath = fullfile(save_path, fig1_savename);
print(fig1, fullpath, '-dpng', ['-r' num2str(resolution)])
close(fig1);

fullpath = fullfile(save_path, fig2_savename);
print(fig2, fullpath, '-dpng', ['-r' num2str(resolution)])
close(fig2);

fullpath = fullfile(save_path, fig3_savename);
print(fig3, fullpath, '-dpng', ['-r' num2str(resolution)])
close(fig3);

fullpath = fullfile(save_path, fig4_savename);
print(fig4, fullpath, '-dpng', ['-r' num2str(resolution)])
close(fig4);

fullpath = fullfile(save_path, fig5_savename);
print(fig5, fullpath, '-dpng', ['-r' num2str(resolution)])
close(fig5);

fullpath = fullfile(save_path, fig6_savename);
print(fig6, fullpath, '-dpng', ['-r' num2str(resolution)])
close(fig6);