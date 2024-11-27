function Copy_of_no2_bias(lat_bounds, lon_bounds, start_date, end_date, tempo_path, tropomi_path, save_data_path, options)
    arguments
        lat_bounds
        lon_bounds
        start_date
        end_date
        tempo_path
        tropomi_path
        save_data_path
        options.overwrite logical = false
    end

    save_folder = save_data_path;
    if ~exist(save_folder, "dir")
        mkdir(save_folder)
    end

    time_threshold = minutes(30);

    % Set up dimensions for Tempo and Tropomi data

    % Get information for all tempo files I have
    tempo_files = table2timetable(tempo_table(tempo_path));
    tempo_files = tempo_files(strcmp(tempo_files.Product, 'NO2'),:);

    % Get information on all tropomi files I have
    tropomi_files = table2timetable(tropomi_table(tropomi_path));
    tropomi_files = tropomi_files(strcmp(tropomi_files.Product, 'NO2'),:);

    % Date and time information for filtering
    plot_timezone = 'America/New_York';

    % lat_bounds = [14 52];
    % lon_bounds = [-130 -55];
    start_day = datetime(start_date, "InputFormat", 'uuuuMMdd', "TimeZone", plot_timezone);
    end_day = datetime(end_date, "InputFormat", 'uuuuMMdd', "TimeZone", plot_timezone);

    % Filter Tempo and tropomi data by time range
    time_period = timerange(start_day, end_day);
    run_days = start_day:end_day;

    tempo_files = tempo_files(time_period,:);
    tropomi_files = tropomi_files(time_period,:);

    n_tempo = size(tempo_files,1);
    n_tropomi = size(tropomi_files,1);

    % Regular grid
    grid_lat = lat_bounds(1):0.05:lat_bounds(2);
    grid_lon = lon_bounds(1):0.05:lon_bounds(2);

    % Create meshgrid for the regular grid
    [lon_grid, lat_grid] = meshgrid(grid_lon, grid_lat);
    grid_sz = size(lat_grid);

    % Initialize arrays to hold all tempo and tropomi data for each parameter

    % compare_size = 1000000;
    % no2_diff = NaN(compare_size,1);
    % sza_diff = NaN(compare_size,1);
    % vza_diff = NaN(compare_size,1);

    no2_diff = NaN(0);
    sza_diff = NaN(0);
    vza_diff = NaN(0);

    tempo_cld_filter = 0.15;
    tempo_sza_filter = 70;

    % TODO: single out NYC and Baltimore 
    % for general area, pick points at random after filtering

    counter = 1;
    switch options.overwrite
        case true
            for i = 1:length(run_days)
                current_day = run_days(i); 
                day_period = timerange(current_day, current_day+days(1));

                disp(strjoin(['Processing data for', string(current_day)]))
                tempo_files_day = tempo_files(day_period,:); % all tempo files for this day
                trop_files_day = tropomi_files(day_period,:); % all tropomi files for this day

                if isempty(tempo_files_day) | isempty(trop_files_day)
                    continue
                end

                % Initialize arrays to hold full day of Tropomi data
                trop_no2 = NaN(grid_sz(1),grid_sz(2),size(trop_files_day,1));
                trop_sza = NaN(grid_sz(1),grid_sz(2),size(trop_files_day,1));
                trop_vza = NaN(grid_sz(1),grid_sz(2),size(trop_files_day,1));
                trop_time = NaN(grid_sz(1),grid_sz(2), size(trop_files_day,1));

                for j = 1:size(trop_files_day,1)
                    trop_data_temp = read_tropomi_netcdf(trop_files_day(j,:));

                    trop_ind = trop_data_temp.qa>=0.75 & trop_data_temp.lat >= lat_bounds(1) & trop_data_temp.lat <= lat_bounds(2) ...
                        & trop_data_temp.lon >= lon_bounds(1) & trop_data_temp.lon <= lon_bounds(2);

                    if isempty(find(trop_ind, 1))
                        continue
                    end
            
                    [~, trop_cols] = ind2sub(size(trop_ind), find(trop_ind));
        
                    trop_F_no2 = scatteredInterpolant(trop_data_temp.lon(trop_ind), trop_data_temp.lat(trop_ind), trop_data_temp.no2(trop_ind), 'linear', 'none');
                    trop_F_sza = scatteredInterpolant(trop_data_temp.lon(trop_ind), trop_data_temp.lat(trop_ind), trop_data_temp.sza(trop_ind), 'linear', 'none');
                    trop_F_vza = scatteredInterpolant(trop_data_temp.lon(trop_ind), trop_data_temp.lat(trop_ind), trop_data_temp.vza(trop_ind), 'linear', 'none');
                    trop_F_time = scatteredInterpolant(trop_data_temp.lon(trop_ind), trop_data_temp.lat(trop_ind), posixtime(trop_data_temp.time(trop_cols)), 'linear', 'none');
             
                    try
                        trop_no2(:,:,j) = trop_F_no2(lon_grid, lat_grid);
                        trop_sza(:,:,j) = trop_F_sza(lon_grid, lat_grid);
                        trop_vza(:,:,j) = trop_F_vza(lon_grid, lat_grid);
                        trop_time(:,:,j) = trop_F_time(lon_grid, lat_grid);
                    catch
                        continue
                    end
                end          

                trop_time = datetime(trop_time, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');

                % check if any point is inside NYC or baltimore region
                % define the regions using lat-lon bounds

                % n_scans = length(scans);

                % Initialize arrays to hold all Tempo data for the current day
                tempo_no2 = NaN(grid_sz(1), grid_sz(2), size(tempo_files_day,1));
                tempo_sza = NaN(grid_sz(1), grid_sz(2), size(tempo_files_day,1));
                tempo_vza = NaN(grid_sz(1), grid_sz(2), size(tempo_files_day,1));
                tempo_time = NaN(grid_sz(1), grid_sz(2), size(tempo_files_day,1));
        
                % Loop over Tempo scans for current day
                for j = 1:size(tempo_files_day,1)
                    % Get all Tempo granules for current scan
       
                    tempo_data_temp = read_tempo_netcdf(tempo_files_day(j,:));        

                    tempo_qa_filter = tempo_data_temp.qa==0 & tempo_data_temp.f_cld<tempo_cld_filter & tempo_data_temp.sza<tempo_sza_filter;
                    tempo_spatial_filter = tempo_data_temp.lat >= lat_bounds(1) & tempo_data_temp.lat <= lat_bounds(2) ...
                                        & tempo_data_temp.lon >= lon_bounds(1) & tempo_data_temp.lon <= lon_bounds(2);
                    tempo_ind = tempo_spatial_filter & tempo_qa_filter;

                    if isempty(find(tempo_ind, 1))
                        continue
                    end
    
                    [~, tempo_cols] = ind2sub(size(tempo_ind), find(tempo_ind));

                    tempo_F_no2 = scatteredInterpolant(tempo_data_temp.lon(tempo_ind), tempo_data_temp.lat(tempo_ind), tempo_data_temp.no2(tempo_ind)./conversion_factor('trop-tempo'), 'linear', 'none');
                    tempo_F_sza = scatteredInterpolant(tempo_data_temp.lon(tempo_ind), tempo_data_temp.lat(tempo_ind), tempo_data_temp.sza(tempo_ind), 'linear', 'none');
                    tempo_F_vza = scatteredInterpolant(tempo_data_temp.lon(tempo_ind), tempo_data_temp.lat(tempo_ind), tempo_data_temp.vza(tempo_ind), 'linear', 'none');
                    tempo_F_time = scatteredInterpolant(tempo_data_temp.lon(tempo_ind), tempo_data_temp.lat(tempo_ind), posixtime(tempo_data_temp.time(tempo_cols)), 'linear', 'none');

                    try
                        tempo_no2(:,:,j) = tempo_F_no2(lon_grid, lat_grid);
                        tempo_sza(:,:,j) = tempo_F_sza(lon_grid, lat_grid);
                        tempo_vza(:,:,j) = tempo_F_vza(lon_grid, lat_grid);
                        tempo_time(:,:,j) = tempo_F_time(lon_grid, lat_grid);

                    catch
                        continue
                    end

                end

                tempo_time = datetime(tempo_time, 'ConvertFrom', 'posixtime', 'TimeZone','UTC');


                for j = 1:size(trop_no2,3)
                    for k = 1:size(tempo_no2,3)
                        trop_no2_page = trop_no2(:,:,j);
                        trop_sza_page = trop_sza(:,:,j);
                        trop_vza_page = trop_vza(:,:,j);
                        trop_time_page = trop_time(:,:,j);

                        tempo_no2_page = tempo_no2(:,:,k);
                        tempo_sza_page = tempo_sza(:,:,k);
                        tempo_vza_page = tempo_vza(:,:,k);
                        tempo_time_page = tempo_time(:,:,k);

                        close_ind = abs(trop_time_page - tempo_time_page) <= time_threshold;

                        n_close = length(find(close_ind));

                        no2_diff(counter:counter+n_close-1) = tempo_no2_page(close_ind) - trop_no2_page(close_ind);
                        sza_diff(counter:counter+n_close-1) = tempo_sza_page(close_ind) - trop_sza_page(close_ind);
                        vza_diff(counter:counter+n_close-1) = tempo_vza_page(close_ind) - trop_vza_page(close_ind);
                        % no2_diff(end+1:end+n_close+1) = tempo_no2_page(close_ind) - trop_no2_page(close_ind);
                        % sza_diff(end+1:end+n_close+1) = tempo_sza_page(close_ind) - trop_sza_page(close_ind);
                        % vza_diff(end+1:end+n_close+1) = tempo_vza_page(close_ind) - trop_vza_page(close_ind);

                        counter = counter+n_close;
                    end
                end


                % break
            end
            
            nans = isnan(no2_diff);

            no2_diff(nans) = [];
            sza_diff(nans) = [];
            vza_diff(nans) = [];

            save(fullfile(save_folder, 'bias.mat'), "no2_diff", "sza_diff", "vza_diff");

            case false
                load(fullfile(save_folder, 'bias.mat')) %#ok<LOAD>
    end