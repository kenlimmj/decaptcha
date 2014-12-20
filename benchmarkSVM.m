function lDist = benchmarkSVM(svmClassifier, filePath)
    BASE_PATH = filePath;

    images = dir(fullfile(BASE_PATH, '*.jpg'));

    lDist = [];

    parfor i = 1:numel(images)
        currImgPath = fullfile(BASE_PATH, images(i).name);
        [~, answer, ~] = fileparts(currImgPath);

        result = recSvmCaptcha(currImgPath, true, svmClassifier);

        if (~strcmp(result, ''))
            measure = 1 - levenshtein(result, upper(answer)) / length(answer);
            lDist = [lDist, measure];

            fprintf('Result: %s | Answer: %s | Score: %d\n', result, upper(answer), measure);
        end
    end
end