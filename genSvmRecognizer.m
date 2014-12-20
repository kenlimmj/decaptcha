function classifier = genSvmRecognizer(images, labels)
    % HOG Parameters
    CELL_SIZE = [2, 5];
    BLOCK_SIZE = [2, 2];
    NUM_BINS = 9;

    blocksPerImage = floor((size(images{1}) ./ CELL_SIZE - BLOCK_SIZE) ./ (BLOCK_SIZE - ceil(BLOCK_SIZE / 2)) + 1);
    hogSize = prod([blocksPerImage, BLOCK_SIZE, NUM_BINS]);

    trainingData = zeros([numel(images), hogSize]);
    trainingLabels = zeros([1, numel(images)]);

    % Setup for OVA classification
    parfor i = 1:numel(images)
        fprintf('Processing image %d of %d\n', i, numel(images));

        trainingData(i, :) = extractHOGFeatures(images{i}, 'CellSize', CELL_SIZE);
        trainingLabels(i) = labels(i);
    end

    svmConfig = templateSVM('Standardize', true);
    classifier = fitcecoc(trainingData, trainingLabels, 'Coding', 'onevsone', 'Learner', svmConfig, 'Verbose', 1);
end