
function [plateImages nPlates] = getPlates(rawImage)
    [xplateCoords, yplateCoords, nPlates] = getPlateCoords(rawImage);
    if(nPlates == 0)
        plateImages = {};
        return;
    end
    % display(xplateCoords);
    % display(yplateCoords);
    plateXCenters = mean(xplateCoords,2);
    plateYCenters = mean(yplateCoords,2);
    % display(plateXCenters);
    % display(plateYCenters);
    centeredXCoords = zeros(nPlates,4);
    centeredYCoords = zeros(nPlates,4);
    angles = zeros(nPlates,1);
    for i = 1:nPlates
        centeredXCoords(i,:) = xplateCoords(i,:) - plateXCenters(i);
        centeredYCoords(i,:) = yplateCoords(i,:) - plateYCenters(i);
        angles(i) = mean(atan2(centeredXCoords(i,:),centeredYCoords(i,:)))*(180.0/pi);
    end
    % display(centeredXCoords);
    % display(centeredYCoords);
    % display(angles);
    cropXstartLimits = min(xplateCoords,[],2);
    cropYstartLimits = min(yplateCoords,[],2);
    cropXsize = max(xplateCoords,[],2) - cropXstartLimits;
    cropYsize = max(yplateCoords,[],2) - cropYstartLimits;
    for i = 1:nPlates
        cropedImage = imcrop(rawImage,[cropXstartLimits(i),cropYstartLimits(i),cropXsize(i),cropYsize(i)]);
        temp = imrotate(cropedImage,-angles(i),'bilinear','crop');
        plateImages{i} = imcrop(temp, [200,200,cropXsize(i)-400,cropYsize(i)-300]);
    %     figure;imshow(plateImages{i});
    end
end

function [xplateCoords, yplateCoords, nPlates] = getPlateCoords(rawImage)
    crop = 100;
    resizeFact = 8;
    maskSize = 40;
    resizedImage = imresize(rawImage(crop:end-crop,crop:end-crop,:),1/resizeFact,'bicubic');
    [xc,yc,nPlates] = getResizedPlateCoords (resizedImage, maskSize);
    xplateCoords = (xc-1)*resizeFact + crop;
    yplateCoords = (yc-1)*resizeFact + crop;
end

function [xCoords, yCoords, numPlates] = getResizedPlateCoords (resizedImage, maskSize)
    hsvImage = rgb2hsv(resizedImage);

    angleMaskSE = -ones(maskSize);
    angleMaskSE(maskSize/2:maskSize, maskSize/2:maskSize) = 1;
    hueImage = hsvImage(:,:,1);
    convolvedImage = conv2(hueImage, angleMaskSE,'same');
    [maxPoint1X, maxPoint1Y, plateCount(1)] = findMaximaRegion(convolvedImage, maskSize);

    angleMaskNE = -ones(maskSize);
    angleMaskNE(1:maskSize/2, maskSize/2:maskSize) = 1;
    hueImage = hsvImage(:,:,1);
    convolvedImage = conv2(hueImage, angleMaskNE,'same');
    [maxPoint2X, maxPoint2Y, plateCount(2)] = findMaximaRegion(convolvedImage, maskSize);

    angleMaskNW = -ones(maskSize);
    angleMaskNW(1:maskSize/2, 1:maskSize/2) = 1;
    hueImage = hsvImage(:,:,1);
    convolvedImage = conv2(hueImage, angleMaskNW,'same');
    [maxPoint3X, maxPoint3Y, plateCount(3)] = findMaximaRegion(convolvedImage, maskSize);

    angleMaskSW = -ones(maskSize);
    angleMaskSW(maskSize/2:maskSize, 1:maskSize/2) = 1;
    hueImage = hsvImage(:,:,1);
    convolvedImage = conv2(hueImage, angleMaskSW,'same');
    [maxPoint4X, maxPoint4Y, plateCount(4)] = findMaximaRegion(convolvedImage, maskSize);

    if(min(plateCount) ~= max(plateCount))
        fprintf(2,'error finding plates !!!!! \nexiting .... \n');
        numPlates = 0;
        xCoords = [];
        yCoords = [];
        return;
    end
    numPlates = min(plateCount);

    fprintf(1, 'found %d plate(s) in the figure\n',numPlates);    
    xCoords = zeros(numPlates,4);
    yCoords = zeros(numPlates,4);
    xCoords(:,1) = maxPoint1X;
    xCoords(:,2) = maxPoint2X;
    xCoords(:,3) = maxPoint3X;
    xCoords(:,4) = maxPoint4X;
    yCoords(:,1) = maxPoint1Y;
    yCoords(:,2) = maxPoint2Y;
    yCoords(:,3) = maxPoint3Y;
    yCoords(:,4) = maxPoint4Y;
    % figure;imshow(resizedImage),hold on;
    % colors = {'red','yellow'};
    % for i = 1:min(plateCount)
    %     for j = 1:4
    %         plot(xCoords(i,j), yCoords(i,j), 'x', 'LineWidth',2, ...
    %             'Color',colors{mod(i,2)+1});
    %         plot([xCoords(i,j);xCoords(i,mod(j,4)+1)], ...
    %             [yCoords(i,j);yCoords(i,mod(j,4)+1)],'LineWidth',2,...
    %             'Color', 'cyan');
    %     end
    % end
end

function [xCoord, yCoord, maxValCount] = findMaximaRegion(region, resolveSize)
   maxVal = 0;
   index = 0;
   while true
       [maxCols, maxIndxCols] = max(region);
       [maxRegionVal, maxIndxRow] = max(maxCols);
       y = maxIndxCols(maxIndxRow);
       x = maxIndxRow;
       if(maxRegionVal < maxVal * 0.75)
           break;
       end
       index = index+1;
       yC(index) = y;
       xC(index) = x;
       region(max(y-resolveSize,1):y+resolveSize, ...
           max(x-resolveSize,1):x+resolveSize) = 0;
       maxVal = maxRegionVal;
   end
   [yCoord, indx] = sort(yC);
   xCoord = xC(indx);
   maxValCount = index;
end   


function [xplateCoords, yplateCoords, nPlates] = getPlateCoords(rawImage)
    crop = 100;
    resizeFact = 8;
    maskSize = 40;
    resizedImage = imresize(rawImage(crop:end-crop,crop:end-crop,:),1/resizeFact,'bicubic');
    [xc,yc,nPlates] = getResizedPlateCoords (resizedImage, maskSize);
    xplateCoords = (xc-1)*resizeFact + crop;
    yplateCoords = (yc-1)*resizeFact + crop;
    figure;imshow(rawImage),hold on;
    colors = {'red','yellow'};
    for i = 1:nPlates
        for j = 1:4
            plot(xplateCoords(i,j), yplateCoords(i,j), 'x', 'LineWidth',2, ...
                'Color',colors{mod(i,2)+1});
            plot([xplateCoords(i,j);xplateCoords(i,mod(j,4)+1)], ...
                [yplateCoords(i,j);yplateCoords(i,mod(j,4)+1)],'LineWidth',2,...
                'Color', 'cyan');
        end
    end
end
