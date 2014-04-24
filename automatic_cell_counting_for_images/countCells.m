function [ count ] = countCells( image, options )
%COUNTCELLS Counts number of cells in microscopy image
%   Image: a color image
%   Options: a struct
%      - plot [boolean]: plots and save the results
%      - plot_name [string]: the name of the plotted image
%   Author: Pedro Damian Kostelec (pedro.si)


%% Parameters
 
% Each cell must be larger than 1/100 of the width of the image
DEBUG_PLOT = 0;

%% Extract options
if nargin == 1
   options.plot = true;
   options.plotName = 'count_cells';
   options.darkCells = false;
   options.minCellArea = 100;
   options.openingKernelSize = 2;
   options.minCellSizeRatio = 4/100;
   options.clearBorders = true;
   options.fillHoles = true;
end
options.plotName = strcat(options.plotName, '.png');
%% Load dependencies
if DEBUG_PLOT || options.plot
    addpath('imoverlay/');
    addpath('export_fig/');
end

%% plot options
wp = 3;
hp = 3;
if DEBUG_PLOT
    figure(2); clf;
end

%% Step 0: Read image and convert to BW

I = rgb2gray(image);
if options.darkCells
   I = imcomplement(I); 
end

[h, w] = size(I);
if DEBUG_PLOT
    subplot(wp,hp,1); imshow(image);
    subplot(wp,hp,2); imshow(I);
end
%% Step 0.5: Improve contrast (adaptive)
I = adapthisteq(I);




%% Step 0.6: Remove objects on the borders
if options.clearBorders
    I = imclearborder(I);
end


%% Step 1: Apply a 3x3 spatial adaptive filter
I = wiener2(I, [5 5]);
if DEBUG_PLOT
    subplot(wp,hp,3); imshow(I);
end


%% Step 1.5: Morphological ops and display a thresolded image
thr = graythresh(I);
thr = 0.6;
bw = im2bw(I, thr);  % this step removes faint cells
if options.fillHoles
   bw = imfill(bw,'holes'); 
end
bw = imopen(bw, strel('disk', options.openingKernelSize));
bw = bwareaopen(bw, options.minCellArea);

if DEBUG_PLOT
    bw_perim = bwperim(bw);
    overlay1 = imoverlay(I, bw_perim, [1 .3 .3]);
    subplot(wp,hp,4); imshow(overlay1)
    subplot(wp,hp,4); imshow(bw)
end



%% Step 2: Find local minimums
H = nearestOdd(w * options.minCellSizeRatio);
maxs = imextendedmax(I, H);
if DEBUG_PLOT
    subplot(wp,hp,5); imshow(maxs);
end
maxs = imclose(maxs, strel('disk',3));
maxs = imfill(maxs, 'holes');
maxs = bwareaopen(maxs, 2);

if DEBUG_PLOT
    overlay2 = imoverlay(I, bw_perim | maxs, [1 .3 .3]);
    subplot(wp,hp,6); imshow(overlay2)
end


%% Step 3: Progressive Flooding
% www.ncc.org.in/download.php?f=NCC2003/C-7.pdf
% http://www.mathworks.co.uk/help/images/ref/watershed.html

Jc = imcomplement(I);
% Next: modify the image so that the background
% pixels and the extended maxima pixels are forced to
% be the only local minima in the image.
I_mod = imimposemin(Jc, ~bw | maxs);

L = watershed(I_mod);
labeledImage = label2rgb(L);
if DEBUG_PLOT
    subplot(wp, hp, 7); imshow(labeledImage);
end

% Step 4: Labeling count
[L, count] = bwlabel(L);
fprintf('Found %d cell\n', count);

% Overlay original and labels
if DEBUG_PLOT || options.plot
    mask = im2bw(L, 1);
    subplot(wp, hp, 8); imshow(mask)
    overlay3 = imoverlay(I, mask, [1 .3 .3]);
end

if DEBUG_PLOT
   subplot(wp, hp, 9); imshow(overlay3) 
end

if options.plot
    f = figure(1);
    subplot(1,2,1)
    imshow(image);
    subplot(1,2,2);
    imshow(overlay3);
    
    t = strcat('Number of objects detected: ', int2str(count)); 
    text(w/2, 24, t, 'Color', 'w', 'HorizontalAlignment','center', 'BackgroundColor', 'k');
    export_fig(options.plotName, '-transparent');
end

end

