function result = cropAndClean(imgData, dataDim)
    % Convert the image to an inverted binary representation
    compImg = imcomplement(im2bw(imgData));

    % Extract connected components
    [Ilabel, ~] = bwlabel(compImg);
    Iprops = regionprops(Ilabel);
    Ibox = [Iprops.BoundingBox];
    Ibox = reshape(Ibox, [4, length(Ibox)/4]);

    out = ceil(Ibox(1:2, 1));

    % Calculate the crop margins
    OCRStartCol = out(1, 1);
    OCRStartRow = out(2, 1);
    OCREndCol = OCRStartCol + ceil(Ibox(3, 1)) - 1;
    OCREndRow = OCRStartRow + ceil(Ibox(4, 1)) - 1;

    % Crop and resize the original image
    croppedChar = compImg(OCRStartRow:OCREndRow, OCRStartCol:OCREndCol);
    result = imresize(croppedChar, dataDim, 'lanczos3', 'antialiasing', false);
end