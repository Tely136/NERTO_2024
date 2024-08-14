clearvars; clc; close all;

data_path = '/mnt/disks/data-disk/data/merged_data/';
figures_path = '/mnt/disks/data-disk/figures/results/';

states = readgeotable('/mnt/disks/data-disk/NERTO_2024/misc/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');

plot_timezone = 'America/New_York';
start_day = datetime(2024,6,1,"TimeZone", plot_timezone);
end_day = datetime(2024,6,1, "TimeZone", plot_timezone);
plot_days = start_day:end_day;

load('/mnt/disks/data-disk/NERTO_2024/misc/USA.mat');

filetype = 'netcdf';

font_size = 20;
resolution = 300;
dim = [0, 0, 1000, 1000];
lw = 2;

for i = 1:length(plot_days)
    date = datetime(plot_days(i), "Format", "uuuuMMdd");

    save_path = fullfile(figures_path, string(date));
    if ~exist(save_path, "dir")
        mkdir(save_path)
    end

    f = strjoin(['*', string(date),'*.nc'],  '');

    dirobj = dir(fullfile(data_path, f));

    if ~isempty(dirobj)
        disp(strjoin(['Plotting data for', string(date)]));

        for j = 1:size(dirobj,1)
            fileobj = dirobj(j);

            file = fullfile(fileobj.folder, fileobj.name);

            tempo_no2 = ncread(file, '/tempo/tempo_no2') .* 10^6;
            tempo_no2_u = ncread(file, '/tempo/tempo_no2_u') .* 10^6;
            tempo_lat = ncread(file, '/tempo/tempo_lat');
            tempo_lon = ncread(file, '/tempo/tempo_lon');
            tempo_time = ncread(file, '/tempo/tempo_time');
            tempo_time = datetime(tempo_time, "ConvertFrom", "posixtime");
            tempo_valid_ind = ncread(file, '/tempo/tempo_valid_ind');

            tropomi_no2 = ncread(file, '/tropomi/tropomi_no2') .* 10^6;
            tropomi_no2_u = ncread(file, '/tropomi/tropomi_no2_u') .* 10^6;
            tropomi_lat = ncread(file, '/tropomi/tropomi_lat');
            tropomi_lon = ncread(file, '/tropomi/tropomi_lon');
            tropomi_time = ncread(file, '/tropomi/tropomi_time');
            tropomi_time = datetime(tropomi_time, 'ConvertFrom', "posixtime");
            tropomi_valid_ind = ncread(file, '/tropomi/tropomi_valid_ind');

            analysis_no2 = ncread(file, '/analysis/analysis_no2') .* 10^6;
            analysis_no2_u = ncread(file, '/analysis/analysis_no2_u') .* 10^6;

            scan = ncread(file, 'scan');

            tempo_no2(~tempo_valid_ind) = NaN;
            tempo_no2_u(~tempo_valid_ind) = NaN;

            tropomi_no2(~tropomi_valid_ind) = NaN;
            tropomi_no2_u(~tropomi_valid_ind) = NaN;

            disp(['Tempo Scan: ', num2str(scan)])


            update = analysis_no2 - tempo_no2;
            
            lat_bounds = [min(tempo_lat(~isnan(analysis_no2))) max(tempo_lat(~isnan(analysis_no2)))];
            lon_bounds = [min(tempo_lon(~isnan(analysis_no2))) max(tempo_lon(~isnan(analysis_no2)))];

            plot_timezone = 'America/New_York';

            clim_no2 = [0 300];
            clim_no2_u = [0 50];

            cb_str = 'umol/m^2';

            title = strjoin(['TEMPO TropNO2 Column', newline, string(mean(tempo_time, 'omitmissing')), 'UTC']);
            make_map_fig(tempo_lat, tempo_lon, tempo_no2, lat_bounds, lon_bounds, fullfile(save_path, strjoin([string(date), '_S', num2str(scan), '_', 'tempo.png'], '')), title, cb_str, clim_no2, [], dim);

            title = 'Merged TropNO2 Column';
            make_map_fig(tempo_lat, tempo_lon, analysis_no2, lat_bounds, lon_bounds, fullfile(save_path, strjoin([string(date), '_S', num2str(scan), '_', 'analysis.png'], '')), title, cb_str, clim_no2, [], dim);

            title = 'Analysis Minus Background';
            make_map_fig(tempo_lat, tempo_lon, update, lat_bounds, lon_bounds, fullfile(save_path, strjoin([string(date), '_S', num2str(scan), '_', 'update.png'], '')), title, cb_str, [-100 100], [], dim, USA);

            % title = strjoin(['TEMPO TropNO2 Uncertainty', string(mean(tempo_time)), 'UTC']);
            % make_map_fig(tempo_lat, tempo_lon, tempo_no2_u, lat_bounds, lon_bounds, fullfile(save_path, strjoin([string(date), '_S', num2str(scan), '_', 'tempo_u.png'], '')), title, cb_str, clim_no2_u, [], dim);

            % title = strjoin(['TROPOMI TropNO2 Uncertainty', string(mean(tropomi_time)), 'UTC']);
            % make_map_fig(tropomi_lat, tropomi_lon, tropomis_no2_u, lat_bounds, lon_bounds, fullfile(save_path, strjoin([string(date), '_S', num2str(scan), '_', 'tropomi_u.png'], '')), title, cb_str, clim_no2_u, [], dim);

            % title = 'Merged TropNO2 Uncertainty';
            % make_map_fig(tempo_lat, tempo_lon, analysis_no2_u, lat_bounds, lon_bounds, fullfile(save_path, strjoin([string(date), '_S', num2str(scan), '_', 'analysis_u.png'], '')), title, cb_str, [0 10], [], dim);
        end

        for j = 1:size(tropomi_no2,3)
            if ~all(isnan(tropomi_no2(:,:,j)), 'all')
                disp(['Tropomi Scan: ', num2str(j)])

                title = strjoin(['TROPOMI TropNO2 Column', newline, string(mean(tropomi_time(:,:,j), 'omitmissing')), 'UTC']);
                make_map_fig(tropomi_lat(:,:,j), tropomi_lon(:,:,j), tropomi_no2(:,:,j), lat_bounds, lon_bounds, fullfile(save_path, strjoin([string(date), '_G', num2str(j), '_', 'tropomi.png'], '')), title, cb_str, clim_no2, [], dim);
            end
        end

        disp('Creating composite')

        tempo_figs = dir(fullfile(save_path, '*tempo*'));
        tropomi_figs = dir(fullfile(save_path, '*tropomi*'));
        analysis_figs = dir(fullfile(save_path, '*analysis*'));
        update_figs = dir(fullfile(save_path, '*update*'));

        new_dim = [1000, 1000]; % TODO: find way to preserve aspect ratio

        n_scans = size(tempo_figs,1);
        if n_scans>0
            n_tropomi_scans = size(tropomi_figs,1);
            tempo_scans = uint8(NaN(1,n_scans));
            tropomi_scans = uint8(NaN(1,n_tropomi_scans));
            analysis_scans = uint8(NaN(1,n_scans));
            update_scans = uint8(NaN(1,n_scans));

            tempo_imgs = uint8(NaN(new_dim(1), new_dim(2), 3, n_scans));
            tropomi_imgs = uint8(NaN(new_dim(1), new_dim(2), 3, n_tropomi_scans));
            analysis_imgs = uint8(NaN(new_dim(1), new_dim(2), 3, n_scans));
            update_imgs = uint8(NaN(new_dim(1), new_dim(2), 3, n_scans));

            for j =1:n_tropomi_scans
                tropomi_figs_name = tropomi_figs(j).name;
                tropomi_figs_name = strsplit(tropomi_figs_name, "_");

                tropomi_scan = tropomi_figs_name(2);
                tropomi_scan = str2double(replace(tropomi_scan, 'S', ''));
                tropomi_scans(j) = tropomi_scan;

                tropomi_img = imread(fullfile(tropomi_figs(1).folder, tropomi_figs(j).name));
                tropomi_img = imresize(tropomi_img, new_dim);
                tropomi_imgs(:,:,:,j) = tropomi_img;
            end

            for j = 1:n_scans
                tempo_figs_name = tempo_figs(j).name;
                tempo_figs_name = strsplit(tempo_figs_name, "_");

                tempo_scan = tempo_figs_name(2);
                tempo_scan = str2double(replace(tempo_scan, 'S', ''));
                tempo_scans(j) = tempo_scan;

                tempo_img = imread(fullfile(tempo_figs(1).folder, tempo_figs(j).name));
                tempo_img = imresize(tempo_img, new_dim);
                tempo_imgs(:,:,:,j) = tempo_img;

                analysis_figs_name = analysis_figs(j).name;
                analysis_figs_name = strsplit(analysis_figs_name, "_");

                analysis_scan = analysis_figs_name(2);
                analysis_scan = str2double(replace(analysis_scan, 'S', ''));
                analysis_scans(j) = analysis_scan;

                analysis_img = imread(fullfile(analysis_figs(1).folder, analysis_figs(j).name));
                analysis_img = imresize(analysis_img, new_dim);
                analysis_imgs(:,:,:,j) = analysis_img;

                update_figs_name = update_figs(j).name;
                update_figs_name = strsplit(update_figs_name, "_");

                update_scan = update_figs_name(2);
                update_scan = str2double(replace(update_scan, 'S', ''));
                update_scans(j) = update_scan;

                update_img = imread(fullfile(update_figs(1).folder, update_figs(j).name));
                update_img = imresize(update_img, new_dim);
                update_imgs(:,:,:,j) = update_img;
            end

            [tempo_scans,I] = sort(tempo_scans);
            tempo_imgs = tempo_imgs(:,:,:,I);

            [analysis_scans,I] = sort(analysis_scans);
            analysis_imgs = analysis_imgs(:,:,:,I);

            [update_scans,I] = sort(update_scans);
            update_imgs = update_imgs(:,:,:,I);

            fig = figure("Visible", "off");
            t = tiledlayout(n_scans, 4, "TileSpacing", "none", 'Padding', 'compact');

            for j = 1:n_scans
                if j <=n_tropomi_scans
                    nexttile(t, (j-1)*4 + 1)
                    imshow(tropomi_imgs(:,:,:,j), 'Border', 'tight');
                end

                nexttile(t, (j-1)*4 + 2)
                imshow(tempo_imgs(:,:,:,j), 'Border', 'tight');

                nexttile(t, (j-1)*4 + 3)
                imshow(analysis_imgs(:,:,:,j), 'Border', 'tight');

                nexttile(t, (j-1)*4 + 4)
                imshow(update_imgs(:,:,:,j), 'Border', 'tight');
            end

            exportgraphics(fig, fullfile(save_path,'composite.png'), 'Resolution', 600)
            close(fig)
        end
    end
end