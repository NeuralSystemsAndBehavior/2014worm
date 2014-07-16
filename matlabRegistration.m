%script to read snapshot from Ca imaging data and get how it is transformed

%load snapshot, adjust contrast
[snapFN, snapPath] = uigetfile('*.tif', 'Brightfield snapshot for overlay');
snap = imread(snapFN);
snapAdjusted = imadjust(snap);
figure; imshow(snapAdjusted); 

%crop green channel out (on the left)
[snapGreen,rectGreen] = imcrop(snapAdjusted); 
%crop red channel out (on the right)
[snapRed,rectRed] = imcrop(snapAdjusted);

%save cropped green chn
greenSnapFN = strcat(snapFN(1:end-4),'_greenCropped.tif');
imwrite(snapGreen,greenSnapFN)
%save cropped red pic
redSnapFN = strcat(snapFN(1:end-4),'_redCropped.tif');
imwrite(snapRed,redSnapFN)

%choose 3 corresponding points in each
[greenPoints redPoints] = cpselect(snapGreen,snapRed,'wait',true);
%figure out function for transformation
t_concord = fitgeotrans(greenPoints, redPoints,'affine'); %no idea whether projective is the right type

%this needs to be done for each image separately?
resizedRed = imref2d(size(snapRed));
greenRegistered = imwarp(snapGreen,t_concord,'OutputView',resizedRed);
figure, imshowpair(greenRegistered,snapRed,'blend')     

transformationsFN = strcat(snapFN(1:end-4),'_transformations.mat');
save(transformationsFN,'rectGreen','rectRed','greenPoints','redPoints','t_concord')

%bla