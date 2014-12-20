function result = recKnnCaptcha(chars, knn)
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

    knnResult = predict(knn, hogData);

    idx = cell(1, numel(knnResult));

    for k = 1:numel(knnResult)
        idx{k} = num2str(lookupIdx(knnResult(k)));
    end

    result = strjoin(idx, '');
end