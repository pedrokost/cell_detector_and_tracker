function [symm right left selected] = match(XA, XB, dotsA, dotsB, options)
% MATCH find the best matches between detected cells
% INPUTS:
% 	- XA: matrix nCellsAxnFeatures containing feature of cells
% 		detected in image A
% 	- XB: matrix nCellsAxnFeatures containing feature of cells
% 		detected in image B
% 	- dotsA: coordinates of cells in image A
% 	- dotsB: coordinates of cells in image B
%	- options: an optinal struct containing these options
%		- normalizeFeatures[true]
%		- compareLocations[true]
% OUTPUTS:
% 	- symm: a vector containing the corresponding robust matches.
% 		symm(i) = 0 when that cell does not have a best match
% 	- right: a vector containing the best matches for cells
% 		in A to cells in B 
% 	- left: a vector containing the best matches for cells
% 		in B to cells in A
%	- selected: a logical vectors containing 1 for cells 
%		that have a symmetric pair in the first image

% ## Some ideas for faster matching
% Only compute distances between nearby cells (not all)
% Use a quadtree to only get nearby cells

% ## Some ideas for more robust matching
% Use a sigmoid error function instread of euclidean

%---------------------------------------------------Options

% Defaults
normalizeFeatures = 1;
compareLocations = 1;

if nargin < 5
	options = struct;
end

if isfield(options, 'normalizeFeatures')
	normalizeFeatures = options.normalizeFeatures;
end

if isfield(options, 'compareLocations')
	compareLocations = options.compareLocations;
end

%----------------------------Add location to feature vector
if compareLocations
	XA = cat(2, XA, dotsA);
	XB = cat(2, XB, dotsB);
end
%----------------------------------------Normalize features
% Normalizes the ranges of each column to 0-1
if normalizeFeatures
	XA = normalizeRange(XA);
	XB = normalizeRange(XB);
end

%-----------------------------------------Compute distances
nCellsA = size(dotsA, 1);
nCellsB = size(dotsB, 1);

dists = zeros(nCellsA, nCellsB);

% TODO: cuold I use direct multiplication or something?
for i=1:nCellsA  % rows
	for j=1:nCellsB  % cols
		% get the corresponding feature vectors
		vectI = XA(i, :);
		vectJ = XB(j, :);
		dist = sum((vectI - vectJ) .^ 2);
		dists(i, j) = dist;
	end
end

%------------------------------------Find symmetric matches
[~, right] = min(dists, [], 2);  % A --> B
[~, left] = min(dists, [], 1);   % A <-- B

% Find symmetric matches
% Use idxA to index into idxB
idx = left(right);
% Then select only the matches where that indexed version == 1:nCells
selected = idx == 1:nCellsA;

%----------------------------------------Set bad matches to 0
symm = right;
symm(~selected) = 0;

end

function X = normalizeRange(X)
	nFeatures = size(X, 2);
	diffs = max(X, [], 1) - min(X, [], 1);
	for i=1:nFeatures
		if diffs(i) == 0
			X(:, i) = 1;
		else
			X(:, i) = X(:, i) / diffs(i);
		end
	end
end