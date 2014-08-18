% This receives all the feature vectors of all cells in a image
% and computes the feature Plink probablisties
% addpath('export_fig')

% set(gcf,'renderer','painters')
% set(gcf,'renderer','zbuffer')
% set(gcf,'renderer','opengl')

figure(1); clf;

folderFeatures = fullfile('..', 'data');
featuresfileA = fullfile(folderFeatures, 'lunggreenOUT' ,'im07.mat');
featuresfileB = fullfile(folderFeatures, 'lunggreenOUT' ,'im06.mat');
imfileA = fullfile(folderFeatures, 'lunggreenIN', 'im07.pgm');
imfileB = fullfile(folderFeatures, 'lunggreenIN', 'im06.pgm');
IA = imread(imfileA);
IB = imread(imfileB);

% Show the images side by side
[~, w] = size(IA);
I = horzcat(IA, IB);
imagesc(I); axis equal; axis tight; hold on; colormap gray;

% Show the cell centroids side by side
load(featuresfileA);
XA = descriptors; dotsA = dots;
load(featuresfileB);
XB = descriptors; dotsB = dots;


[symm right left selected] = match(XA, XB, dotsA, dotsB);

plot(dotsA(:, 1), dotsA(:, 2), 'r+');
dotsBdisp = [dotsB(:, 1) + w, dotsB(:, 2)];
plot(dotsBdisp(:, 1), dotsBdisp(:, 2), 'b+');

nCellsA = size(dotsA, 1);
nCellsB = size(dotsB, 1);

for i=1:nCellsA
	if ~isnan(right(i))
		cellA = dotsA(i, :);
		cellB = dotsBdisp(right(i), :);
		line([cellB(1), cellA(1)], [cellB(2), cellA(2)], 'Color', 'r');
	end
end
 
for i=1:nCellsB
	if ~isnan(left(i))
		cellB = dotsBdisp(i, :);
		cellA = dotsA(left(i), :);
		line([cellB(1), cellA(1)], [cellB(2), cellA(2)], 'Color', 'b');
	end
end

for i=1:nCellsA
	if ~symm(i); continue; end
	cellA = dotsA(i, :);
	cellB = dotsBdisp(symm(i), :);
	line([cellB(1), cellA(1)], [cellB(2), cellA(2)], 'Color', 'w');
end

% fprintf('Press any key to save the figure\n')
% pause
% export_fig matches.png -painters

