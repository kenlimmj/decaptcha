function result = decaptcha(file, noiseFlag, method, recognizer)
    chars = ppImg(file, noiseFlag, false);
    
    result = '';
    
    switch method
        case 'svm'
            result = recSvmCaptcha(chars, recognizer);
        case 'nn'
            result = recNeuralCaptcha(chars, recognizer);
        case 'knn'
            result = recKnnCaptcha(chars, recognizer);
    end
    
    
    
    
    