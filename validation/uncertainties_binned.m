clearvars; clc; close all;

% This script looks at tempo and tropomi uncertainties as functions of other parameters 
% such as viewing geometry, albedo, cloud fraction, cloud height, surface type
save_folder = '/mnt/disks/data-disk/figures/validation/uncertainty';

% Get information for all tempo files I have
tempo_files = table2timetable(tempo_table('/mnt/disks/data-disk/data/tempo_data'));
tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);

% Get information on all tropomi files I have
tropomi_files = table2timetable(tropomi_table('/mnt/disks/data-disk/data/tropomi_data/'));
tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);

% Date and time information for filtering
plot_timezone = 'America/New_York';
% start_day = datetime(2024,6,1,"TimeZone", plot_timezone);
% end_day = datetime(2024,6,1,23,59,59, "TimeZone", plot_timezone);
lat_bounds = [24.5 49];
lon_bounds = [-125 -66.9];
start_day = datetime(2024,6,1,"TimeZone", plot_timezone);
end_day = datetime(2024,6,30, "TimeZone", plot_timezone);
% lat_bounds = [40 42];
% lon_bounds = [-77 -76];

% Filter Tempo and tropomi data by time range
time_period = timerange(start_day, end_day);

tempo_files = tempo_files(time_period,:);
tropomi_files = tropomi_files(time_period,:);

n_tempo = size(tempo_files,1);
n_tropomi = size(tropomi_files,1);

tempo_dim = [132 2048];
tropomi_dim = [450 4173];

% Assume maximum this many pixels will be collected from each file, find a better way to do this
n_pixels = 1000;
tempo_length = n_tempo * n_pixels;
tropomi_length = n_tropomi * n_pixels;

% Initialize arrays to hold all tempo and tropomi data for each parameter
disp('Initializing arrays')
tempo_u = NaN(tempo_length,1);
tempo_sza = NaN(tempo_length,1);
tempo_vza = NaN(tempo_length,1);
tempo_albedo = NaN(tempo_length,1);
tempo_f_cld = NaN(tempo_length,1);
tempo_amf_trop = NaN(tempo_length,1);
tempo_surf_type = NaN(tempo_length,1);

tropomi_u = NaN(tropomi_length,1);
tropomi_sza = NaN(tropomi_length,1);
tropomi_vza = NaN(tropomi_length,1);
tropomi_albedo = NaN(tropomi_length,1);
tropomi_f_cld = NaN(tropomi_length,1);
tropomi_amf_trop = NaN(tropomi_length,1);
tropomi_surf_type = NaN(tropomi_length,1);


% TEMPO Data
counter = 1;

% Loop over Tempo files
disp('Acquiring TEMPO data')
for i = 1:n_tempo
    tempo_data = read_tempo_netcdf(tempo_files(i,:));

    % Acuire data in temporary arrays
    lat_temp = tempo_data.lat;
    lon_temp = tempo_data.lon;
    u_temp = tempo_data.no2_u ./ conversion_factor('trop-tempo') .* 10^6;
    sza_temp = tempo_data.sza;
    vza_temp = tempo_data.vza;
    albedo_temp = tempo_data.albedo;
    f_cld_temp = tempo_data.f_cld;
    amf_trop_temp = tempo_data.amf_trop;
    surf_type_temp = tempo_data.surf_type;

    qa_temp = tempo_data.qa;

    % Filter data based on lat-lon bounds and qa 
    lat_filter = lat_temp>lat_bounds(1) & lat_temp<lat_bounds(2);
    lon_filter = lon_temp>lon_bounds(1) & lon_temp<lon_bounds(2);
    qa_filter = qa_temp==0 | qa_temp==1;
    filter = ~isnan(u_temp) & lat_filter & lon_filter & qa_filter;

    u_temp = u_temp(filter);
    sza_temp = sza_temp(filter);
    vza_temp = vza_temp(filter);
    albedo_temp = albedo_temp(filter);
    f_cld_temp = f_cld_temp(filter);
    amf_trop_temp = amf_trop_temp(filter);
    surf_type_temp = surf_type_temp(filter);

    n_elem = numel(u_temp);
    
    skip = ceil(n_elem/n_pixels);
    ind = i:skip:n_elem;

    n_values = length(ind);

    % Add data to arrays for analysis
    tempo_u(counter:counter+n_values-1) = u_temp(ind);
    tempo_sza(counter:counter+n_values-1) = sza_temp(ind);
    tempo_vza(counter:counter+n_values-1) = vza_temp(ind);
    tempo_albedo(counter:counter+n_values-1) = albedo_temp(ind);
    tempo_f_cld(counter:counter+n_values-1) = f_cld_temp(ind);
    tempo_amf_trop(counter:counter+n_values-1) = amf_trop_temp(ind);
    tempo_surf_type(counter:counter+n_values-1) = surf_type_temp(ind);

    % Increment counter for arrays
    counter = counter + n_values;

    disp([num2str(100*i/n_tempo), '%'])
end


% TROPOMI Data
counter = 1;

% Loop over Tropomi files
disp('Acquiring TROPOMI data')
for i = 1:n_tropomi
    tropomi_data = read_tropomi_netcdf(tropomi_files(i,:));

    % Add data to temporary arrays
    lat_temp = tropomi_data.lat;
    lon_temp = tropomi_data.lon;
    u_temp = tropomi_data.no2_u .* 10^6;
    sza_temp = tropomi_data.sza;
    vza_temp = tropomi_data.vza;
    albedo_temp = tropomi_data.albedo;
    f_cld_temp = tropomi_data.f_cld;
    amf_trop_temp = tropomi_data.amf_trop;
    surf_type_temp = tropomi_data.surf_type;

    qa_temp = tropomi_data.qa;

    % Filter data based on lat-lon bounds and qa
    lat_filter = lat_temp>lat_bounds(1) & lat_temp<lat_bounds(2);
    lon_filter = lon_temp>lon_bounds(1) & lon_temp<lon_bounds(2);
    qa_filter = qa_temp~=0;
    filter = ~isnan(u_temp) & lat_filter & lon_filter & qa_filter;

    u_temp = u_temp(filter);
    sza_temp = sza_temp(filter);
    vza_temp = vza_temp(filter);
    albedo_temp = albedo_temp(filter);
    f_cld_temp = f_cld_temp(filter);
    amf_trop_temp = amf_trop_temp(filter);
    surf_type_temp = surf_type_temp(filter);

    n_elem = numel(u_temp);
    
    skip = ceil(n_elem/n_pixels);
    ind = i:skip:n_elem;

    n_values = length(ind);

    % Add data to arrays for analysis
    tropomi_u(counter:counter+n_values-1) = u_temp(ind);
    tropomi_sza(counter:counter+n_values-1) = sza_temp(ind);
    tropomi_vza(counter:counter+n_values-1) = vza_temp(ind);
    tropomi_albedo(counter:counter+n_values-1) = albedo_temp(ind);
    tropomi_f_cld(counter:counter+n_values-1) = f_cld_temp(ind);
    tropomi_amf_trop(counter:counter+n_values-1) = amf_trop_temp(ind);
    tropomi_surf_type(counter:counter+n_values-1) = surf_type_temp(ind);

    % Increment counter for arrays
    counter = counter + n_values;

    disp([num2str(100*i/n_tropomi), '%'])
end


disp('Binning data')
tempo_s = secd(tempo_vza) + secd(tempo_sza);
tropomi_s = secd(tropomi_sza) + secd(tropomi_vza);

n_bins = 100;
[tempo_albedo_binned, tempo_u_binned_albedo] = bin_data(tempo_albedo, tempo_u, n_bins);
[tempo_f_cld_binned, tempo_u_binned_f_cld] = bin_data(tempo_f_cld, tempo_u, n_bins);
[tempo_sza_binned, tempo_u_binned_sza] = bin_data(tempo_sza, tempo_u, n_bins);
[tempo_vza_binned, tempo_u_binned_vza] = bin_data(tempo_vza, tempo_u, n_bins);
[tempo_s_binned, tempo_u_binned_s] = bin_data(tempo_s, tempo_u, n_bins);

[tropomi_albedo_binned, tropomi_u_binned_albedo] = bin_data(tropomi_albedo, tropomi_u, n_bins);
[tropomi_f_cld_binned, tropomi_u_binned_f_cld] = bin_data(tropomi_f_cld, tropomi_u, n_bins);
[tropomi_sza_binned, tropomi_u_binned_sza] = bin_data(tropomi_sza, tropomi_u, n_bins);
[tropomi_vza_binned, tropomi_u_binned_vza] = bin_data(tropomi_vza, tropomi_u, n_bins);
[tropomi_s_binned, tropomi_u_binned_s] = bin_data(tropomi_s, tropomi_u, n_bins);


disp('Plotting data')

scatter_plot([tempo_sza_binned tropomi_sza_binned], [tempo_u_binned_sza tropomi_u_binned_sza], save_folder, 'sza.png', 'NO2 Retrieval Uncertainty Against Solar Zenith Angle', {'TEMPO', 'TROPOMI'}, 'Solar Angle [degrees]', 'Uncertainty [umoles/m^2]')
scatter_plot([tempo_vza_binned tropomi_vza_binned], [tempo_u_binned_vza tropomi_u_binned_vza], save_folder, 'vza.png', 'NO2 Retrieval Uncertainty Against Viewing Zenith Angle', {'TEMPO', 'TROPOMI'}, 'Viewing Angle [degrees]', 'Uncertainty [umoles/m^2]')
scatter_plot([tempo_s_binned tropomi_s_binned], [tempo_u_binned_s tropomi_u_binned_s], save_folder, 's.png', 'NO2 Retrieval Uncertainty Against Total Light Path Length', {'TEMPO', 'TROPOMI'}, 'sec(VZA) + sec(SZA)', 'Uncertainty [umoles/m^2]')
scatter_plot([tempo_f_cld_binned tropomi_f_cld_binned], [tempo_u_binned_f_cld tropomi_u_binned_f_cld], save_folder, 'f_cld.png', 'NO2 Retrieval Uncertainty Against Cloud Fraction', {'TEMPO', 'TROPOMI'}, 'Cloud fraction', 'Uncertainty [umoles/m^2]')
scatter_plot([tempo_albedo_binned tropomi_albedo_binned], [tempo_u_binned_albedo tropomi_u_binned_albedo], save_folder, 'albedo.png', 'NO2 Retrieval Uncertainty Against Surface Albedo', {'TEMPO', 'TROPOMI'}, 'Albedo', 'Uncertainty [umoles/m^2]')


%% Functions

function [x_binned, y_binned] = bin_data(x_data, y_data, n_bins)
    minx = min(x_data);
    maxx = max(x_data);

    bins = linspace(minx, maxx, n_bins+1);
    x_binned = NaN(n_bins,1);
    y_binned = NaN(n_bins,1);

    for i = 1:n_bins
        if i == n_bins
            ind = find(x_data>=bins(i) & x_data<=bins(i+1));
        else
            ind = find(x_data>=bins(i) & x_data<bins(i+1));
        end

        x_binned(i) = mean(x_data(ind));
        y_binned(i) = mean(y_data(ind));

    end
end


function scatter_plot(x_data, y_data, path, name, ttext, leg, xtext, ytext, xbound, ybound, dim)
    arguments
        x_data
        y_data
        path
        name
        ttext = []
        leg = []
        xtext = []
        ytext = []
        xbound = []
        ybound = []
        dim = []
    end

    colors = [[0 0.4470 0.7410];...
                [0.8500 0.3250 0.0980];...
                [0.8500 0.3250 0.0980];];


    lw = 2;
    font_size = 20;
    resolution = 300;

    if isempty(dim)
        dim = [0, 0, 1200, 900];
    end

    fig = figure('Visible', 'off', 'Position', dim);

    hold on;
    for i = 1:size(x_data,2)
        temp_x = x_data(:,i);
        temp_y = y_data(:,i);

        scatter(temp_x, temp_y, 50,  colors(i,:), 'LineWidth', lw);
    end
    hold off;

    if ~isempty(xbound)
        xlim(xbound)
    end

    if ~isempty(ybound)
        ylim(ybound)
    end

    if ~isempty(leg)
        legend(leg, 'Location', 'best')
    end
    
    if ~isempty(ttext)
        title(ttext)
    end
    
    if ~isempty(xtext)
        xlabel(xtext)
    end
    
    if ~isempty(ytext)
        ylabel(ytext)
    end

    fontsize(font_size, 'points')
    
    ax = gca;

    save_path = fullfile(path, name);
    exportgraphics(ax, save_path, "Resolution", resolution)

    close(fig);
end



