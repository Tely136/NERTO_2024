clearvars; clc; close all;

% This script looks at tempo and tropomi uncertainties as functions of other parameters 
% such as viewing geometry, albedo, cloud fraction, cloud height, surface type

% Get information for all tempo files I have
tempo_files = table2timetable(tempo_table('/mnt/disks/data-disk/data/tempo_data'));
tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);

% Get information on all tropomi files I have
tropomi_files = table2timetable(tropomi_table('/mnt/disks/data-disk/data/tropomi_data/'));
tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);

% Date and time information for filtering
plot_timezone = 'America/New_York';
start_day = datetime(2024,6,1,"TimeZone", plot_timezone);
end_day = datetime(2024,6,1,23,59,59, "TimeZone", plot_timezone);
lat_bounds = [24.5 49];
lon_bounds = [-125 -66.9];
time_period = timerange(start_day, end_day);

tempo_files = tempo_files(time_period,:);
tropomi_files = tropomi_files(time_period,:);

n_tempo = size(tempo_files,1);
n_tropomi = size(tropomi_files,1);

tempo_dim = [132 2048];
tropomi_dim = [450 4173];

% Initialize arrays to hold all tempo and tropomi data for each parameter
tempo_u = NaN(1, n_tempo*tempo_dim(1)*tempo_dim(2));
tempo_sza = NaN(1, n_tempo*tempo_dim(1)*tempo_dim(2));
tempo_vza = NaN(1, n_tempo*tempo_dim(1)*tempo_dim(2));
tempo_albedo = NaN(1, n_tempo*tempo_dim(1)*tempo_dim(2));
tempo_f_cld = NaN(1, n_tempo*tempo_dim(1)*tempo_dim(2));
tempo_amf_trop = NaN(1, n_tempo*tempo_dim(1)*tempo_dim(2));
tempo_surf_type = NaN(1, n_tempo*tempo_dim(1)*tempo_dim(2));

tropomi_u = NaN(1, n_tropomi*tropomi_dim(1)*tropomi_dim(2));
tropomi_sza = NaN(1, n_tropomi*tropomi_dim(1)*tropomi_dim(2));
tropomi_vza = NaN(1, n_tropomi*tropomi_dim(1)*tropomi_dim(2));
tropomi_albedo = NaN(1, n_tropomi*tropomi_dim(1)*tropomi_dim(2));
tropomi_f_cld = NaN(1, n_tropomi*tropomi_dim(1)*tropomi_dim(2));
tropomi_amf_trop = NaN(1, n_tropomi*tropomi_dim(1)*tropomi_dim(2));
tropomi_surf_type = NaN(1, n_tropomi*tropomi_dim(1)*tropomi_dim(2));


% TEMPO Data
counter = 1;
for i = 1:n_tempo
    tempo_data = read_tempo_netcdf(tempo_files(i,:));

    lat_temp = tempo_data.lat;
    lon_temp = tempo_data.lon;
    u_temp = tempo_data.no2_u;
    sza_temp = tempo_data.sza;
    vza_temp = tempo_data.vza;
    albedo_temp = tempo_data.albedo;
    f_cld_temp = tempo_data.f_cld;
    amf_trop_temp = tempo_data.amf_trop;
    surf_type_temp = tempo_data.surf_type;

    qa_temp = tempo_data.qa;

    lat_filter = lat_temp>lat_bounds(1) & lat_temp<lat_bounds(2);
    lon_filter = lon_temp>lon_bounds(1) & lon_temp<lon_bounds(2);

    filter = ~isnan(u_temp) & lat_filter & lon_filter; % add qa value

    n_values = numel(find(filter));

    tempo_u(counter:counter+n_values-1) = u_temp(filter);
    tempo_sza(counter:counter+n_values-1) = sza_temp(filter);
    tempo_vza(counter:counter+n_values-1) = vza_temp(filter);
    tempo_albedo(counter:counter+n_values-1) = albedo_temp(filter);
    tempo_f_cld(counter:counter+n_values-1) = f_cld_temp(filter);
    tempo_amf_trop(counter:counter+n_values-1) = amf_trop_temp(filter);
    tempo_surf_type(counter:counter+n_values-1) = surf_type_temp(filter);

    counter = counter + n_values;
end


% TROPOMI Data
counter = 1;
for i = 1:n_tropomi
    tropomi_data = read_tropomi_netcdf(tropomi_files(i,:));

    lat_temp = tropomi_data.lat;
    lon_temp = tropomi_data.lon;
    u_temp = tropomi_data.no2_u;
    sza_temp = tropomi_data.sza;
    vza_temp = tropomi_data.vza;
    albedo_temp = tropomi_data.albedo;
    f_cld_temp = tropomi_data.f_cld;
    amf_trop_temp = tropomi_data.amf_trop;
    surf_type_temp = tropomi_data.surf_type;

    qa_temp = tropomi_data.qa;

    lat_filter = lat_temp>lat_bounds(1) & lat_temp<lat_bounds(2);
    lon_filter = lon_temp>lon_bounds(1) & lon_temp<lon_bounds(2);

    filter = ~isnan(u_temp) & lat_filter & lon_filter; % add qa value

    n_values = numel(find(filter));

    tropomi_u(counter:counter+n_values-1) = u_temp(filter);
    tropomi_sza(counter:counter+n_values-1) = sza_temp(filter);
    tropomi_vza(counter:counter+n_values-1) = vza_temp(filter);
    tropomi_albedo(counter:counter+n_values-1) = albedo_temp(filter);
    tropomi_f_cld(counter:counter+n_values-1) = f_cld_temp(filter);
    tropomi_amf_trop(counter:counter+n_values-1) = amf_trop_temp(filter);
    tropomi_surf_type(counter:counter+n_values-1) = surf_type_temp(filter);

    counter = counter + n_values;
end



removal = isnan(tempo_u) | isnan(tempo_sza) |isnan(tempo_vza) |isnan(tempo_albedo) |isnan(tempo_f_cld) |isnan(tempo_amf_trop) |isnan(tempo_surf_type);
tempo_u(removal) = [];
tempo_sza(removal) = [];
tempo_vza(removal) = [];
tempo_albedo(removal) = [];
tempo_f_cld(removal) = [];
tempo_amf_trop(removal) = [];
tempo_surf_type(removal) = [];

tempo_s = secd(tempo_vza) + secd(tempo_sza);


% removal = isnan(tropomi_u) | isnan(tropomi_sza) |isnan(tropomi_vza) |isnan(tropomi_albedo) |isnan(tropomi_f_cld) |isnan(tropomi_amf_trop) |isnan(tropomi_surf_type);
% tropomi_u(removal) = [];
% tropomi_sza(removal) = [];
% tropomi_vza(removal) = [];
% tropomi_albedo(removal) = [];
% tropomi_f_cld(removal) = [];
% tropomi_amf_trop(removal) = [];
% tropomi_surf_type(removal) = [];

tropomi_s = secd(tropomi_sza) + secd(tropomi_vza);


save_folder = '/mnt/disks/data-disk/figures/validation/uncertainty';

disp('plotting...')
% scatter_plot(tempo_sza, tempo_u, save_folder, 'tempo_sza.png', '', '', 'SZA', 'Uncertainty')
% scatter_plot(tempo_vza, tempo_u, save_folder, 'tempo_vza.png', '', '', 'VZA', 'Uncertainty')
scatter_plot(tempo_s, tempo_u, save_folder, 'tempo_s.png', '', '', 'sec(VZA) + sec(SZA)', 'Uncertainty')
scatter_plot(tempo_f_cld, tempo_u, save_folder, 'tempo_f_cld.png', '', '', 'cloud fraction', 'Uncertainty')
scatter_plot(tempo_albedo, tempo_u, save_folder, 'tempo_albedo.png', '', '', 'albedo', 'Uncertainty')

scatter_plot(tropomi_s, tropomi_u, save_folder, 'tropomi_s.png', '', '', 'sec(VZA) + sec(SZA)', 'Uncertainty')
scatter_plot(tropomi_f_cld, tropomi_u, save_folder, 'tropomi_f_cld.png', '', '', 'cloud fraction', 'Uncertainty')
scatter_plot(tropomi_albedo, tropomi_u, save_folder, 'tropomi_albedo.png', '', '', 'albedo', 'Uncertainty')

%% Functions


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


    lw = 2;
    font_size = 20;
    resolution = 300;

    if isempty(dim)
        dim = [0, 0, 1200, 900];
    end

    fig = figure('Visible', 'off', 'Position', dim);

    hold on;
    for i = 1:size(x_data,1)
        temp_x = x_data(i,:);
        temp_y = y_data(i,:);

        scatter(temp_x, temp_y, 50, "magenta", "filled");
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



