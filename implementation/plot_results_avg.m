clearvars; clc; close all;

results_path = '/mnt/disks/data-disk/data/merged_data';
save_path = '/mnt/disks/data-disk/figures/results';
files = dir(fullfile(results_path,'*MARYLAND*.mat'));

states = readgeotable('/mnt/disks/data-disk/NERTO_2024/shapefiles/cb_2023_us_state_500k/cb_2023_us_state_500k.shp');

plot_timezone = 'America/New_York';

start_day = datetime(2024,6,1, 'TimeZone', plot_timezone);
end_day = datetime(2024,7,1, 'TimeZone', plot_timezone);

% need to make sure that the result has set dimensions in order to do this
counter = 0;
for i = 1:length(files)
    name = files(i).name;
    name_splt = strsplit(name, '_');

    date = datetime(string(name_splt(4)), "Format", "uuuuMMdd'T'HHmmss", "TimeZone", "UTC");

    if date>=start_day && date<end_day
        file = load(fullfile(files(i).folder, name));

            if counter==0

                bg_no2 = file.save_data.bg_no2 .* 10^6;
                bg_lat = file.save_data.bg_lat;
                bg_lon = file.save_data.bg_lon;
                bg_qa = file.save_data.bg_qa;
                bg_cld = file.save_data.bg_cld;
                bg_no2(bg_qa~=0 | bg_cld>0.2) = NaN;


                obs_no2 = file.save_data.obs_no2 .* 10^6;
                obs_no2_u = file.save_data.obs_no2_u .* 10^6;
                obs_lat = file.save_data.obs_lat;
                obs_lon = file.save_data.obs_lon;
                obs_qa = file.save_data.obs_qa;
                obs_no2(obs_qa<0.75) = NaN;

                analysis_no2 = file.save_data.analysis_no2 .* 10^6;
                analysis_no2(bg_qa~=0 | bg_cld>0.2) = NaN;

            else
                temp_bg_no2 = file.save_data.bg_no2 .* 10^6;
                bg_qa = file.save_data.bg_qa;
                bg_cld = file.save_data.bg_cld;
                temp_bg_no2(bg_qa~=0 | bg_cld>0.2) = NaN;
    
    
                temp_obs_no2 = file.save_data.obs_no2 .* 10^6;
                obs_qa = file.save_data.obs_qa;
                temp_obs_no2(obs_qa<0.75) = NaN;
    
                temp_analysis_no2 = file.save_data.analysis_no2 .* 10^6;
                temp_analysis_no2(bg_qa~=0 | bg_cld>0.2) = NaN;

                bg_no2 = bg_no2 + temp_bg_no2;
                obs_no2 = obs_no2 + temp_obs_no2;
                analysis_no2 = analysis_no2 + temp_analysis_no2;

            end

        counter = counter + 1;
    end
end

bg_no2 = bg_no2./counter;
obs_no2 = obs_no2./counter;
analysis_no2 = analysis_no2./counter;
update = analysis_no2 - bg_no2;


lat_bounds = [min(bg_lat(:)) max(bg_lat(:))];
lon_bounds = [min(bg_lon(:)) max(bg_lon(:))];





font_size = 20;
resolution = 300;
dim = [0, 0, 900, 1000];
lw = 2;


clim_no2 = [0 300];
clim_no2_u = [0 100];

cb_str = 'umol/m^2';

title = strjoin(['Average TEMPO TropNO2 Column', string(start_day), '-', string(end_day-days(1))]);
make_map_fig(bg_lat, bg_lon, bg_no2, lat_bounds, lon_bounds, fullfile(save_path, 'avg_tempo'), title, cb_str, clim_no2, [], dim);



title = strjoin(['Average TROPOMI TropNO2 Column', string(start_day), '-', string(end_day-days(1))]);
make_map_fig(obs_lat, obs_lon, obs_no2, lat_bounds, lon_bounds, fullfile(save_path, 'avg_tropomi'), title, cb_str, clim_no2, [], dim);



title = 'Average Merged TropNO2 Column';
make_map_fig(bg_lat, bg_lon, analysis_no2, lat_bounds, lon_bounds, fullfile(save_path, 'avg_merged'), title, cb_str, clim_no2, [], dim);



title = 'Merged Minus TEMPO';
make_map_fig(bg_lat, bg_lon, update, lat_bounds, lon_bounds, fullfile(save_path, 'update'), title, cb_str, [-100 100], [], dim);