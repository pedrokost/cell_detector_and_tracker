% This receives all the feature vectors of all cells in a image
% and computes the feature Plink probablisties
addpath('export_fig')

% set(gcf,'renderer','painters')
% set(gcf,'renderer','zbuffer')
% set(gcf,'renderer','opengl')

figure(1); clf;

folderFeatures = fullfile('..', 'cell_detector', 'kidney');
featuresfileA = fullfile(folderFeatures, 'outKidneyRed' ,'im40.mat');
featuresfileB = fullfile(folderFeatures, 'outKidneyRed' ,'im41.mat');
imfileA = fullfile(folderFeatures, 'testKidneyRed', 'im40.pgm');
imfileB = fullfile(folderFeatures, 'testKidneyRed', 'im41.pgm');
IA = imread(imfileA);
IB = imread(imfileB);

% Show the images side by side
[~, w] = size(IA);
I = cat(2, IA, IB);
imshow(I); hold on;

% Show the cell centroids side by side
load(featuresfileA);
XA = X; dotsA = dots;
load(featuresfileB);
XB = X; dotsB = dots;


[symm right left selected] = match(XA, XB, dotsA, dotsB);
figure(1);
plot(dotsA(:, 1), dotsA(:, 2), 'r+');
dotsBdisp = [dotsB(:, 1) + w, dotsB(:, 2)];
plot(dotsBdisp(:, 1), dotsBdisp(:, 2), 'b+');

nCellsA = size(dotsA, 1);
nCellsB = size(dotsB, 1);

for i=1:nCellsA
	cellA = dotsA(i, :);
	cellB = dotsBdisp(right(i), :);
	line([cellB(1), cellA(1)], [cellB(2), cellA(2)], 'Color', 'r');
end
 
for i=1:nCellsB
	cellB = dotsBdisp(i, :);
	cellA = dotsA(left(i), :);
	line([cellB(1), cellA(1)], [cellB(2), cellA(2)], 'Color', 'b');
end

for i=1:nCellsA
	if ~symm(i); continue; end
	cellA = dotsA(i, :);
	cellB = dotsBdisp(symm(i), :);
	line([cellB(1), cellA(1)], [cellB(2), cellA(2)], 'Color', 'w');
end


% export_fig matches.png -painters

