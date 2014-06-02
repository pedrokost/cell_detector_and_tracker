function [count,angle] = fastcpdh(object, angBins, radBins)
%Rotationally Invariant Contour Points Distribution Histogram
%function count = cpdh(object, angBins, radBins)
%
%OUTPUT
%   out = Contour Points Distribution Histogram
%
%INPUT
%   object = Binary image (logical type) containing the silloute or the contour of interest
%   angBins = number of angular bins
%   radBins = number of radial bins

%Detect number of objects in the image, select the biggest one only for
%computation

% TODO: remove all but largest component
% CC = bwconncomp(BW);

%       numPixels = cellfun(@numel,CC.PixelIdxList);
%       [biggest,idx] = max(numPixels);
%       BW(CC.PixelIdxList{idx}) = 0;

showit = 0;
if showit;
    subplot(1,2,1); imshow(object); axis tight; axis equal;
end

% object = imdilate(object,strel('square',3)); %# dilation
object = fastimfill(object,'holes');             %# fill inside silhouette
% object = imerode(object,strel('square',3));  %# erode

%Get the object perimeter only
object = fastbwmorph(object,'perim8');

stats = fastregionprops(object, 'Area','Orientation','PixelIdxList', 'BoundingBox');

% keyboard
if numel(stats) > 1
    [~, maxIndx] = max([stats.Area]);
    stats = stats(maxIndx);
end

angle = stats.Orientation;

% It is not necessary to crop: the descriptor first substrct the centroid from each pixel.
% But it may affect the performance of rotation and sursuquent regionprops
object = object(ceil(stats.BoundingBox(2)):floor(stats.BoundingBox(2)+stats.BoundingBox(4)), ...
                ceil(stats.BoundingBox(1)):floor(stats.BoundingBox(1)+stats.BoundingBox(3)));

% imrotate cannot use logical for hardware acceleration
object = imrotate(uint8(object),-stats.Orientation);
object = logical(object);
stats = fastregionprops(object, 'Area', 'PixelIdxList','Centroid','PixelList', 'Orientation');
if numel(stats) > 1
    [~, maxIndx] = max([stats.Area]);
    stats = stats(maxIndx);
end

if showit
    subplot(1,2,2); imshow(logical(object)); axis tight; axis equal;
    pause
end

if ~isempty(stats) && numel(stats.PixelList) > 2
    %Translate into polar coordinates
    centroid = stats.Centroid;
    cartesian = stats.PixelList;
    polar = zeros(size(cartesian));
    
    polar(:,1) = sqrt( (cartesian(:,1) - centroid(1)).^2 + (cartesian(:,2) - centroid(2)).^2 );
    polar(:,2) = atan2( cartesian(:,2) - centroid(2) , cartesian(:,1) - centroid(1) );
    
    %Spatial Partitions
    maxRo = max(polar(:,1));
    radii = maxRo/radBins;
    angles = 2*pi/angBins;
    
    count = hist3(polar,{0+radii/2:radii:maxRo-radii/2  -pi+angles/2:angles:pi-angles/2});
    
    %%%%PLOT HISTOGRAM%%%%
    %figure, bar3(count); xlabel('angles'); ylabel('radii');
    %%%%%%%%%%%%%%%%%%%%%%
    
    count = reshape(count, radBins*angBins,1);
    count = count/norm(count,2); %normalization
else
    count = zeros(radBins*angBins, 1);
end
