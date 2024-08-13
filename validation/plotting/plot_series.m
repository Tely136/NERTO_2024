clearvars; clc; close all;

save_path = '/mnt/disks/data-disk/figures/results';
states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');

plot_timezone = 'America/New_York';
day = datetime(2024,5,20, 'Format', 'uuuuMMdd', "TimeZone", plot_timezone);

save_path = fullfile(save_path, string(day));
tempo_figs = dir(fullfile(save_path, '*tempo*'));
tropomi_figs = dir(fullfile(save_path, '*tropomi*'));
analysis_figs = dir(fullfile(save_path, '*analysis*'));
update_figs = dir(fullfile(save_path, '*update*'));

dim = [1024, 1024];

n_scans = size(tempo_figs,1);
n_tropomi_scans = size(tropomi_figs,1);
tempo_scans = uint8(NaN(1,n_scans));
tropomi_scans = uint8(NaN(1,n_tropomi_scans));
analysis_scans = uint8(NaN(1,n_scans));
update_scans = uint8(NaN(1,n_scans));

tempo_imgs = uint8(NaN(dim(1), dim(2), 3, n_scans));
tropomi_imgs = uint8(NaN(dim(1), dim(2), 3, n_tropomi_scans));
analysis_imgs = uint8(NaN(dim(1), dim(2), 3, n_scans));
update_imgs = uint8(NaN(dim(1), dim(2), 3, n_scans));

for i =1:n_tropomi_scans
    tropomi_figs_name = tropomi_figs(i).name;
    tropomi_figs_name = strsplit(tropomi_figs_name, "_");

    tropomi_scan = tropomi_figs_name(2);
    tropomi_scan = str2double(replace(tropomi_scan, 'S', ''));
    tropomi_scans(i) = tropomi_scan;

    tropomi_img = imread(fullfile(tropomi_figs(1).folder, tropomi_figs(i).name));
    tropomi_img = imresize(tropomi_img, dim);
    tropomi_imgs(:,:,:,i) = tropomi_img;
end

for i = 1:n_scans
    tempo_figs_name = tempo_figs(i).name;
    tempo_figs_name = strsplit(tempo_figs_name, "_");

    tempo_scan = tempo_figs_name(2);
    tempo_scan = str2double(replace(tempo_scan, 'S', ''));
    tempo_scans(i) = tempo_scan;

    tempo_img = imread(fullfile(tempo_figs(1).folder, tempo_figs(i).name));
    tempo_img = imresize(tempo_img, dim);
    tempo_imgs(:,:,:,i) = tempo_img;

    analysis_figs_name = analysis_figs(i).name;
    analysis_figs_name = strsplit(analysis_figs_name, "_");

    analysis_scan = analysis_figs_name(2);
    analysis_scan = str2double(replace(analysis_scan, 'S', ''));
    analysis_scans(i) = analysis_scan;

    analysis_img = imread(fullfile(analysis_figs(1).folder, analysis_figs(i).name));
    analysis_img = imresize(analysis_img, dim);
    analysis_imgs(:,:,:,i) = analysis_img;

    update_figs_name = update_figs(i).name;
    update_figs_name = strsplit(update_figs_name, "_");

    update_scan = update_figs_name(2);
    update_scan = str2double(replace(update_scan, 'S', ''));
    update_scans(i) = update_scan;

    update_img = imread(fullfile(update_figs(1).folder, update_figs(i).name));
    update_img = imresize(update_img, dim);
    update_imgs(:,:,:,i) = update_img;
end

[tempo_scans,I] = sort(tempo_scans);
tempo_imgs = tempo_imgs(:,:,:,I);

[analysis_scans,I] = sort(analysis_scans);
analysis_imgs = analysis_imgs(:,:,:,I);

[update_scans,I] = sort(update_scans);
update_imgs = update_imgs(:,:,:,I);

fig = figure("Visible", "off");
t = tiledlayout(n_scans, 4, "TileSpacing", "none");

for i = 1:n_scans
    if i <=n_tropomi_scans
        nexttile(t, (i-1)*4 + 1)
        imshow(tropomi_imgs(:,:,:,i));
    end

    nexttile(t, (i-1)*4 + 2)
    imshow(tempo_imgs(:,:,:,i));

    nexttile(t, (i-1)*4 + 3)
    imshow(analysis_imgs(:,:,:,i));

    nexttile(t, (i-1)*4 + 4)
    imshow(update_imgs(:,:,:,i));
end

exportgraphics(fig, fullfile(save_path,'composite.png'), 'Resolution', 600)
close(fig)