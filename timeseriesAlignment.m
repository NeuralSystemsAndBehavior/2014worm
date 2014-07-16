%script to align Ca imaging data by use transformations from previous script

%load snapshot, adjust contrast
[timeseriesFN, timeseriesPath] = uigetfile('*.tif', 'choose timeseries');
[transformationsFN, transformationsPath] = uigetfile('*.mat', 'File with transformation for overlay');
load(transformationsFN)
seriesInfo = imfinfo(timeseriesFN);
numImages = numel(seriesInfo);
series = NaN(seriesInfo(1).Height,seriesInfo(1).Width,numImages);

%faster loop to read all the tif files
tic
TifLink = Tiff(timeseriesFN, 'r');
for i=1:numImages
    TifLink.setDirectory(i);
    series(:,:,i)=TifLink.read();
end
TifLink.close();
toc

% older slower code to read and show all the tif files
%figure(22)
tic
for myN = 1:numImages
    series(:,:,myN) = imread(timeseriesFN,myN, 'Info',seriesInfo); %not sure this imadjust is a good idea
    %series(:,:,myN) = imadjust(series(:,:,myN));
    %figure(22); imshow(series(:,:,myN))
end
toc

%crop both red and green out
%brute force approach to get the size of the cropped image, as the heigth
%as specified from the rect is definitly not specifying the height (larger
%than the original pic's height!) - but the cropping using this rect seems
%to work fine, so just do it once to get the size
dummyGreen = imcrop(series(:,:,1),rectGreen);
greenSize = size(dummyGreen);
dummyRed = imcrop(series(:,:,1),rectRed);
redSize = size(dummyRed);
seriesGreen = NaN(greenSize(1),greenSize(2),numImages); %height, width, number of images
seriesRed = NaN(redSize(1),redSize(2),numImages);
for i = 1:numImages
    %crop green channel (on the left)
    seriesGreen(:,:,i) = imcrop(series(:,:,i),rectGreen);
    %crop red channel out (on the right)
    seriesRed(:,:,i) = imcrop(series(:,:,1),rectRed);
end

%save cropped green and red channel
greenSeriesFN = strcat(timeseriesFN(1:end-4),'_greenCropped.tif');
redSeriesFN = strcat(timeseriesFN(1:end-4),'_redCropped.tif');
for i = 1:numImages
    imwrite(seriesGreen(:,:,i), greenSeriesFN,'WriteMode','append');
    imwrite(seriesRed(:,:,i),redSeriesFN,'WriteMode','append')
end

%warp green so that it is in register with red
greenRegistered = NaN(redSize(1),redSize(2),numImages);
for i = 1:numImages
    resizedRed = imref2d(size(seriesRed(:,:,i))); %overwritten in every iteration
    greenRegistered(:,:,i) = imwarp(seriesGreen(:,:,i),t_concord,'OutputView',resizedRed);
    %figure, imshowpair(greenRegistered,snapRed,'blend')
end

%save registered green
greenRegisteredFN = strcat(timeseriesFN(1:end-4),'_greenRegistered.tif');
for i = 1:numImages
    imwrite(greenRegistered(:,:,i),greenRegisteredFN,'WriteMode','append')
end
