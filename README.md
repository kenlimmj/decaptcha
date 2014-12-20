decaptcha
=========

A CAPTCHA Breaker using k-Nearest Neighbor Classifiers, Support Vector Machines, and Neural Networks.

## Dependencies
- MATLAB R2014b
    - Parallel Processing Toolbox
    - Computer Vision Toolbox
    - Image Processing Toolbox
    - Statistics Toolbox
    - Neural Network Toolbox
- [Microsoft Research Chars74k Data Set](http://www.ee.surrey.ac.uk/CVSSP/demos/chars74k/)

## Installation
The following steps assume that you have all the [dependencies](#dependencies). First, load in the Chars74k data set labels into memory. This could take some time because there are approximately 62,000 array elements to be loaded:

```matlab
list_English_Fnt;
```

If this operation fails, it's likely because you're in the wrong folder. When you downloaded Chars74k, you should have also downloaded a MATLAB compatible label set, which unzips itself to the folder ``ListsTXT``. Either add that folder to your MATLAB path, or navigate to that directory. 

Running the command places a struct variable called ``list`` in your workspace, which we'll make extensive use of. Next, create a character training set from the Chars74k images:

```matlab
fontChars = genFontChars(list);
```

``fontChars`` is a cell array of binary image data extracted. The indices of the cell array correspond to the indices in ``list.ALLlabels``. From here, you can use ``fontChars`` to train a classifier. Pick your poison:

```matlab
% k-Nearest Neighbor
knnRecognizer = genKnnRecognizer(fontChars, list.ALLlabels);

% Multi-class SVM
svmRecognizer = genSVMRecognizer(fontChars, list.ALLlabels);

% Pattern Recognition Neural Network
nnRecognizer = genNeuralRecognizer(fontChars, list.ALLlabels, list.NUMclasses);
```

Note that these operations all take a non-negligible amount of time and memory. It's recommended that you perform all training operations in parallel on a workstation or cluster rather than on a consumer machine. Once it's done, you can save out the recognizers and do as you please with them.

## Cracking CAPTCHAs
Disclaimer: Use this for good, for research, and for realizing that CAPTCHAs don't stop well-written algorithms from abusing systems that you create. Don't use this to do things which cause warning flags to be written to real-world server logs, don't be evil, you get the idea.

Let's assume you have an image called ``captcha.jpg``. This image contains a CAPTCHA image to be cracked:

```matlab
% k-Nearest Neighbor
result = decaptcha('./captcha.jpg', true, 'knn', knnRecognizer);

% Multi-class SVM
result = decaptcha('./captcha.jpg', true, 'svm', svmRecognizer);

% Pattern Recognition Neural Network
result = decaptcha('./captcha.jpg', true, 'nn', nnRecognizer);
```

``result`` is a string containing the recognized CAPTCHA. The boolean flag passed in as the second argument determines whether noise removal should be performed after thresholding the image. In many cases this is true, but some odd categories of CAPTCHA which already have salient, cleanly segmented characters deteriorate instead. Experiment, because after all you're not really using this to crack CAPTCHAs in the wild right?

## Benchmarking Performance
This assumes that you have a directory of files containing CAPTCHA test images in JPG format, located at the directory ``./test``.

```matlab
% k-Nearest Neighbor
result = benchmarkKnn(knnRecognizer. './test');

% Multi-class SVM
result = benchmarkSVM(svmRecognizer. './test');

% Pattern Recognition Neural Network
result = benchmarkNN(nnRecognizer. './test');
```

``result`` is a vector of modified Levenshtein distances between the correct answer for the CAPTCHA and the prediction. A value of 1 indicates that the match was exact. Values between 1 and 0 indicate that some or all of the characters were wrong or missing. Values that are negative indicate that, not only was everything grossly wrong, the prediction contained more characters than the answer. That's likely because the image segmentation algorithm failed to do a good job. We're guilty, but not sorry :P.