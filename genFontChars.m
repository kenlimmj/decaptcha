function images = genFontChars(dataList)
    FILE_NAMES = dataList.ALLnames;
    DATA_DIM = [50, 35];

    images = cell(1, length(FILE_NAMES));

    % Read all images into memory
    parfor i = 1:numel(FILE_NAMES)
        fprintf('Processing image %d of %d\n', i, numel(FILE_NAMES));

        currFile = strcat(FILE_NAMES(i, :), '.png');
        currFilePath = fullfile('.', 'English', 'Fnt', currFile);

        currImg = imread(currFilePath);
        images{i} = cropAndClean(currImg, DATA_DIM);
    end
end