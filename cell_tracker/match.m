% This receives all the feature vectors of all cells in a image
% and computes the feature Plink probablisties

normalizeFeatures = 1;
comparesDistance = 1;
symmetricMatching = 1;


% ## Some ideas for faster matching
% Only compute distances between nearby cells (not all)
% Use a quadtree to only get nearby cells

% ## Some ideas for more robust matching
% Use a sigmoid error function instread of euclidean

figure(1);

folderFeatures = fullfile('..', 'cell_detector', 'kidney', 'outKidneyRed');
featuresfileA = fullfile(folderFeatures, 'im40.mat');
featuresfileB = fullfile(folderFeatures, 'im41.mat');
imfileA = fullfile('..', 'cell_detector', 'kidney', 'testKidneyRed', 'im40.pgm');
imfileB = fullfile('..', 'cell_detector', 'kidney', 'testKidneyRed', 'im41.pgm');
IA = imread(imfileA);
IB = imread(imfileB);

% Show the images side by side
[h w] = size(IA);
I = cat(2, IA, IB);
imshow(I); hold on;

% Show the cell centroids side by side
load(featuresfileA);
XA = X; dotsA = dots;
load(featuresfileB);
XB = X; dotsB = dots;

plot(dotsA(:, 1), dotsA(:, 2), 'r+');
dotsBdisp = [dotsB(:, 1) + w, dotsB(:, 2)];
plot(dotsBdisp(:, 1), dotsBdisp(:, 2), 'b+');


% Add the locations to the feature vector
if comparesDistance
	XA = cat(2, XA, dotsA);
	XB = cat(2, XB, dotsB);
end

% Normalize the ranges of feature vectors
% figure(3); clf;
if normalizeFeatures
	diffs = max(XA, [], 1) - min(XA, [], 1);
	for i=1:nFeatures
		if diffs(i) == 0
			XA(:, i) = 1;
		else
			XA(:, i) = XA(:, i) / diffs(i);
		end
	end
	diffs = max(XB, [], 1) - min(XB, [], 1);
	for i=1:nFeatures
		if diffs(i) == 0
			XB(:, i) = 1;
		else
			XB(:, i) = XB(:, i) / diffs(i);
		end
	end
end
% imagesc(X)


% Compute the feature distances
nCellsA = size(dotsA, 1);
nCellsB = size(dotsB, 1);

dists = zeros(nCellsA, nCellsB);

for i=1:nCellsA  % rows
	for j=1:nCellsB  % cols
		% get the corresponding feature vectors
		vectI = XA(i, :);
		vectJ = XB(j, :);
		dist = sum((vectI - vectJ) .^ 2);
		dists(i, j) = dist;
	end
end

figure(2)
imagesc(dists); colormap jet;

% Matching
figure(1);

% Find the best matches
[~, idxA] = min(dists, [], 2);  % find closest cell imag cols (IB)
% A -> B
for i=1:nCellsA
	cellA = dotsA(i, :);
	cellB = dotsBdisp(idxA(i), :);
	line([cellB(1), cellA(1)], [cellB(2), cellA(2)], 'Color', 'r');
end

% Display the connections in the plot
if symmetricMatching
	[~, idxB] = min(dists, [], 1);  % find closest cell imag rows (IA)
	% B -> A
	% Display the connections in the plot
	for i=1:nCellsB
		cellB = dotsBdisp(i, :);
		cellA = dotsA(idxB(i), :);
		line([cellB(1), cellA(1)], [cellB(2), cellA(2)], 'Color', 'b');
	end

	% Find symmetric matches
	% Use idxA to index into idxB
	idx = idxB(idxA);
	% The select only the matches where that indexed version == 1:nCells
	selected = idx == 1:nCellsA

	for i=1:nCellsA
		if ~selected(i); continue; end
		cellA = dotsA(i, :);
		cellB = dotsBdisp(idxA(i), :);
		line([cellB(1), cellA(1)], [cellB(2), cellA(2)], 'Color', 'w');
	end

end

