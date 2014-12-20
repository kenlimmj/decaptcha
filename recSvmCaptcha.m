function result = recSvmCaptcha(chars, svm)
    % HOG Parameters
    CELL_SIZE = [2, 5];
    BLOCK_SIZE = [2, 2];
    NUM_BINS = 9;

    blocksPerImage = floor((size(chars{1}) ./ CELL_SIZE - BLOCK_SIZE) ./ (BLOCK_SIZE - ceil(BLOCK_SIZE / 2)) + 1);
    hogSize = prod([blocksPerImage, BLOCK_SIZE, NUM_BINS]);

    hogData = zeros([numel(chars), hogSize]);

    parfor i = 1:numel(chars)
        hogData(i, :) = extractHOGFeatures(chars{i}, 'CellSize', CELL_SIZE);
    end

    svmResult = predict(svm, hogData);

    idx = cell(1, numel(svmResult));

    for k = 1:numel(svmResult)
        idx{k} = num2str(lookupIdx(svmResult(k)));
    end

    result = strjoin(idx, '');
end