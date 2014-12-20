function [images, labels] = genCaptchaChars(filePath)
    IMAGE_PATH = filePath;
    DATA_DIM = [50, 35];
    NUM_FILES = 89;

    images = cell(1, NUM_FILES);
    labels = zeros([1, NUM_FILES]);

    dirs = dir(IMAGE_PATH);
    dirs = dirs([dirs.isdir]);
    dirs = dirs(arrayfun(@(x)x.name(1), dirs) ~= '.');

    count = 1;

    % Go through all subdirectories
    for i = 1:numel(dirs)
        % Read all JPG files in the current subdirectory
        files = dir(fullfile(IMAGE_PATH, dirs(i).name, '*.jpg'));
        files = files(arrayfun(@(x)x.name(1), files) ~= '.');

        for k = 1:numel(files)
            fprintf('Processing image %d of %d\n', count, NUM_FILES);

            currImg = imread(fullfile(IMAGE_PATH, dirs(i).name, files(k).name));

            images{count} = cropAndClean(currImg, DATA_DIM);
            labels(count) = dirToLabel(dirs(i).name);

            % Increment the counter
            count = count + 1;
        end
    end
end

function label = dirToLabel(dirName)
    if (double(dirName) <= 57)
        label = str2num(dirName);
    else
        label = double(dirName) - 86;
    end
end