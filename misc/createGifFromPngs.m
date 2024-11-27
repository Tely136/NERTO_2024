function createGifFromPngs(directory, gifName, delayTime)
    % createGifFromPngs(directory, gifName, delayTime)
    % This function takes all PNG files in the specified directory and
    % creates an animated GIF file. The files are sorted based on the 
    % numeric part at the end of their names (e.g., "-000" to "-0023").
    %
    % directory - The directory containing the PNG files
    % gifName - The name of the output GIF file (including .gif extension)
    % delayTime - Time delay between frames in the GIF (in seconds)
    
    % Get list of all PNG files in the directory
    pngFiles = dir(fullfile(directory, '*.png'));
    
    % Check if any PNG files exist in the directory
    if isempty(pngFiles)
        error('No PNG files found in the directory.');
    end
    
    % Extract the numeric suffix from the file names
    fileNumbers = zeros(length(pngFiles), 1);
    for i = 1:length(pngFiles)
        % Extract the part of the file name that contains the number
        [~, fileName, ~] = fileparts(pngFiles(i).name);
        tokens = regexp(fileName, '-(\d+)$', 'tokens');
        
        if ~isempty(tokens)
            % Convert the extracted string number to a numeric value
            fileNumbers(i) = str2double(tokens{1}{1});
        else
            error('File name format is incorrect. Expected a numeric suffix.');
        end
    end
    
    % Sort the files based on the extracted numbers
    [~, sortedIndices] = sort(fileNumbers);
    sortedFiles = pngFiles(sortedIndices);
    
    % Loop through all PNG files and add them to the GIF in sorted order
    for i = 1:length(sortedFiles)
        % Read the current image
        img = imread(fullfile(directory, sortedFiles(i).name));
        
        % Convert image to indexed image with colormap
        [indexedImg, cmap] = rgb2ind(img, 256);
        
        % Write to the GIF file
        if i == 1
            % First image: create the file and initialize the GIF
            imwrite(indexedImg, cmap, gifName, 'gif', 'Loopcount', inf, 'DelayTime', delayTime);
        else
            % Subsequent images: append to the existing GIF file
            imwrite(indexedImg, cmap, gifName, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
        end
    end
    
    fprintf('GIF created successfully as %s\n', gifName);
end
