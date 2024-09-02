function check_integrity(path)

    files = dir(fullfile(path, '*.nc'));
    
    for i = 1:size(files,1)
        filepath = fullfile(files(i).folder, files(i).name);
    
        try
            ncinfo(filepath);
        catch
            fprintf('Error reading NetCDF file: %s\n', files(i).name);
            delete(filepath);
        end
    end


end
