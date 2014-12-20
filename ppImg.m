function charData = ppImg(img, noiseFlag, figFlag)
    % Flag for showing figures
    SHOW_FIGS = figFlag;

    % The size of each character to output
    DATA_DIM = [50, 35];

    % Initialize an empty figure handle to hold the display images
    if (SHOW_FIGS)
        figure;
    end

    % Read the Image
    imgData = imread(img);

    if (SHOW_FIGS)
        subplot(5, 2, 1); imshow(imgData); %#ok<*UNRCH>
        title('Original Image');
    end

    % Threshold the Image
    [x, y] = size(imgData);
    binImg = adaptivethreshold(imgData, round(0.01 * x * y), graythresh(imgData) / 1.75);

    if (SHOW_FIGS)
        subplot(5, 2, 2); imshow(binImg);
        title('Thresholded Image');
    end

    % Convert to a Binary Mask
    binMask = imcomplement(binImg);

    if (SHOW_FIGS)
        subplot(5, 2, 3); imshow(binMask);
        title('Inverted Image');
    end

    % Remove spurs and artifacts
    binMaskSpur = bwmorph(binMask, 'spur');

    if (SHOW_FIGS)
        subplot(5, 2, 4); imshow(binMaskSpur);
        title('Spur Removal');
    end

    if (noiseFlag)
        % Remove Noise
        binMaskClean = bwareaopen(bwmorph(binMaskSpur, 'clean'), 26);

        if (SHOW_FIGS)
            subplot(5, 2, 5); imshow(binMaskClean);
            title('Noise Removal');
        end

        % Detect the edge, fill in holes to "smooth" out the edge, then add the smooth edge
        % to the original image as a sort of stroke to fill out jagged edges
        edgeMask = bwmorph(edge(binMaskClean, 'canny', [0.1, 0.2], 2.5), 'diag');

        if (SHOW_FIGS)
            subplot(5, 2, 6); imshow(edgeMask);
            title('Edge Detection');
        end

        % Join disconnected but proximal lines to create a closed contour
        binMaskClosedEdge = bwmorph(edgeMask, 'bridge');

        if (SHOW_FIGS)
            subplot(5, 2, 7); imshow(edgeMask);
            title('Edge Bridging');
        end

        % Fill the area enclosed by two contours
        [comps, labels, numObjs, adj] = bwboundaries(binMaskClosedEdge, 8, 'holes');
        [r, ~] = find(adj(:, numObjs+1:end));
        [rr, ~] = find(adj(:, r));
        idx = setdiff(1:numel(comps), [r(:); rr(:)]);
        binMaskFill = ismember(labels, idx);

        if (SHOW_FIGS)
            subplot(5, 2, 8); imshow(binMaskFill);
            title('Filling Holes');
        end

        % Thin out the image so the letter forms are more pronounced
        binMaskThin = bwmorph(binMaskFill, 'erode');

        if (SHOW_FIGS)
            subplot(5, 2, 9); imshow(binMaskThin);
            title('Thinning Letterforms');
        end
    else
        binMaskThin = binMaskSpur;
    end

    % Extract Connected Pixels
    [Ilabel, ~] = bwlabel(binMaskThin);
    Iprops = regionprops(Ilabel, 'Area', 'BoundingBox');

    filteredIprops = [];

    for k = 1:length(Iprops)
        if (Iprops(k).Area > 10)
            filteredIprops = [filteredIprops Iprops(k)]; %#ok<AGROW>
        end
    end

    Ibox = [filteredIprops.BoundingBox];
    Ibox = reshape(Ibox, [4, length(Ibox)/4]);

    if (SHOW_FIGS)
        subplot(5, 2, 10); vislabels(Ilabel);
        title('Segmentation Results');
    end

    if (SHOW_FIGS)
        figure;
    end

    charData = cell(1, length(Ibox));

    % Crop and Draw
    for count = 1:length(Ibox)
        out = ceil(Ibox(1:2, count));

        OCRStartCol = out(1, 1);
        OCRStartRow = out(2, 1);

        OCREndCol = OCRStartCol + ceil(Ibox(3, count)) - 1;
        OCREndRow = OCRStartRow + ceil(Ibox(4, count)) - 1;

        % Extract the single largest entity in the current image
        croppedChar = bwareafilt(binMaskThin(OCRStartRow:OCREndRow, OCRStartCol:OCREndCol), 1, 'largest');

        % Crop the original image
        charData{count} = imresize(croppedChar, DATA_DIM, 'lanczos3', 'antialiasing', false);

        if (SHOW_FIGS)
            subplot(1, length(Ibox), count);
            imshow(charData{count});
        end
    end
end