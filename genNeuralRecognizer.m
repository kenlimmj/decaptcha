function nn = genNeuralRecognizer(images, labels, classes)
    % HOG Parameters
    CELL_SIZE = [2, 5];
    BLOCK_SIZE = [2, 2];
    NUM_BINS = 9;

    blocksPerImage = floor((size(images{1}) ./ CELL_SIZE - BLOCK_SIZE) ./ (BLOCK_SIZE - ceil(BLOCK_SIZE / 2)) + 1);
    hogSize = prod([blocksPerImage, BLOCK_SIZE, NUM_BINS]);

%     trainingData = zeros([hogSize, numel(images)]);
    trainingData = zeros([numel(images{1}), numel(images)]);
    trainingLabels = zeros([classes, numel(images)]);

    for i = 1:numel(images)
        fprintf('Processing image %d of %d\n', i, numel(images));
        
%         trainingData(:, i) = extractHOGFeatures(images{i}, 'CellSize', CELL_SIZE);
        trainingData(:, i) = images{i}(:);
        trainingLabels(:, i) = ind2vec(labels(i), classes);
    end

    nn = patternnet(classes * 2, 'trainscg');
    nn.trainParam.epochs = 5000;
    nn.trainParam.max_fail = 10;

    % Prevent the training window from showing up
    % nn.trainParam.showWindow = false;
    % nn.trainParam.showCommandLine = false;

    nn = train(nn, trainingData, trainingLabels);
end