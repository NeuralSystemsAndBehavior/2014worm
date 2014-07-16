%script to extract Ca traces

%load copped and re-sized stacks 
[greenRegisteredFN, Path] = uigetfile('*.tif', 'choose green registered stack');
[redCroppedFN, Path] = uigetfile('*.tif', 'choose red cropped stack');

%subtract background in both red and green channel?? maybe not?

%select ROIs in red channel (roipoly - separately for each ROI?)

%blur ROIs

%apply ROIs to green channel

%get average value??

%divide by red (average???) ROI value - not useful if red and green marker
%are not co-localized; red should be in nucleus, green in rest of cell

%plot Ca chn traces