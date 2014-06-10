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
%		- normalizeFeatures[false]
%		- compareLocations[true]
% 		- locationWeight[32]
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
normalizeFeatures = 0;
compareLocations = 1;
locationWeight = 20;  % Add more importance to location

if nargin < 5
	options = struct;
end

if isfield(options, 'normalizeFeatures')
	normalizeFeatures = options.normalizeFeatures;
end

if isfield(options, 'compareLocations')
	compareLocations = options.compareLocations;
end

if isfield(options, 'locationWeight')
	locationWeight = options.locationWeight;
end

%----------------------------Add location to feature vector
if compareLocations
	XA = cat(2, XA, dotsA);
	XB = cat(2, XB, dotsB);
end
%----------------------------------------Normalize features
% Normalizes the ranges of each column to 0-1

if normalizeFeatures
	[XA mini maxi] = normalizeRange(XA);
	XB = normalizeRange(XB);

	% Make displacement for prominent
	XA(:, end-1:end) = XA(:, end-1:end) * locationWeight;
	XB(:, end-1:end) = XB(:, end-1:end) * locationWeight;
end

%-----------------------------------------Compute distances
nCellsA = size(dotsA, 1);

sigma = 2; % FIXME: Is this the std of the data? what data?
dists = pdist2(XA, XB);
dists = exp(-dists/sigma);

%------------------------------------Find symmetric matches
[~, right] = max(dists, [], 2);  % A --> B
[~, left] = max(dists, [], 1);   % A <-- B

% Find symmetric matches
% Use idxA to index into idxB
idx = left(right);
% Then select only the matches where that indexed version == 1:nCells
selected = idx == 1:nCellsA;

%----------------------------------------Set bad matches to 0
symm = right;
symm(~selected) = 0;

end

function [X minimum maximum] = normalizeRange(X, minimum, maximum)
	if nargin < 3
		minimum = min(X, [], 1);
		maximum = max(X, [], 1);
	end
	diffs = maximum - minimum;
	X = bsxfun(@minus, X, minimum);
	X = bsxfun(@rdivide, X, diffs);
	X(:, diffs < 1e-4) = 1;
end