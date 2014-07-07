function [symm right left selectedRight selectedLeft] = match(XA, XB, dotsA, dotsB, options)
% MATCH find the best matches between detected cells
% INPUTS:
% 	- XA: matrix nCellsAxnFeatures containing feature of cells
% 		detected in image A
% 	- XB: matrix nCellsAxnFeatures containing feature of cells
% 		detected in image B
% 	- dotsA: coordinates of cells in image A
% 	- dotsB: coordinates of cells in image B
%	- options: an optinal struct containing these options
%		- match_thresh = match threshold
% OUTPUTS:
% 	- symm: a vector containing the corresponding robust matches.
% 		symm(i) = 0 when that cell does not have a best match
% 	- right: a vector containing the best matches for cells
% 		in A to cells in B 
% 	- left: a vector containing the best matches for cells
% 		in B to cells in A
%	- selectedRight: a logical vectors containing 1 for cells in the first
%		image that have a symmetric pair
%	- selectedLeft: a logical vectors containing 1 for cells in the second
%		image that have a symmetric pair 

% ## Some ideas for faster matching
% Only compute distances between nearby cells (not all)
% Use a quadtree to only get nearby cells

% ## Some ideas for more robust matching
% Use a sigmoid error function instread of euclidean

%---------------------------------------------------Options

% TODO: replace with limits for each feature
MIN_P_LINK = 0.9;

testing = false;

nObsA = size(dotsA, 1);
nObsB = size(dotsB, 1);
nFeats = size(XA, 2);

locPos = [nFeats+1; nFeats+2];
featsPos = setdiff(1:nFeats+2, locPos);

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

XA2 = zeros(nObsA, nFeats+2);
XA2(:, locPos) = dotsA;
XA2(:, featsPos) = XA;
XB2 = zeros(nObsB, nFeats+2);
XB2(:, locPos) = dotsB;
XB2(:, featsPos) = XB;

XA = XA2; clear XA2;
XB = XB2; clear XB2;

%----------------------------------------Normalize features
% Normalizes the ranges of each column to 0-1
% This is done automatically by the neural net algorithm

% if normalizeFeatures
% 	[XA, XB] = normalizeRangeMulti(XA, XB, {locPos});
% end

%-----------------------------------------Compute distances
nCellsA = size(dotsA, 1);
nCellsB = size(dotsB, 1);

if nCellsA == 0 || nCellsB == 0
	symm = zeros(nCellsA, 0);
	right = []; left = [];
	selectedRight = zeros(nCellsA, 1);
	selectedLeft = zeros(nCellsB, 1);
	return
end

dists = pdist2(XA, XB, @classifierDistance);
% sigma = std(dists')'; % Not sure the original authors meant this
% dists = exp(-bsxfun(@rdivide, dists, sigma));

if testing
	figure(2)
	imagesc(dists)
	xlabel('Right image')
	ylabel('Left image')
	figure(1)
end

%------------------------------------Find symmetric matches
[vright, right] = max(dists, [], 2);  % A --> B
[vleft, left] = max(dists, [], 1);   % A <-- B
left = left';

ok = vright >= MIN_P_LINK;
right(~ok) = NaN;

ok = vleft >= MIN_P_LINK;
left(~ok) = NaN;

% Find symmetric matches
% Use idxA to index into idxB

idxRight = zeros(size(right));
for i=1:nCellsA
	if ~isnan(right(i))
		idxRight(i) = left(right(i));
	end
end
idxLeft = zeros(size(left));
for i=1:nCellsB
	if ~isnan(left(i))
		idxLeft(i) = right(left(i));
	end
end
% Then select only the matches where that indexed version == 1:nCells
selectedRight = idxRight == (1:nCellsA)';
% SelectedLeft indicates the cells in B that have a symmetric match in A
selectedLeft = idxLeft == (1:nCellsB)';
%----------------------------------------Set bad matches to 0
symm = right;
symm(~selectedRight) = 0;

end

function Y = classifierDistance(featsA, featsB, distPos)
	% Given 2 feature vectors, returns the similarity given by the trained classifier. The similarity is a metric between 0 and 1.
	if nargin < 3
		nFeats = size(featsA, 2);
		distPos =  nFeats+1:nFeats+2;
	end

	% This distance function must be the same as the one used in the classifier
	D = euclideanDistance(featsA, featsB)';
	Y = testMatcherClassifierNB(D');


	MAX_DIST_PERC = 0.05;  % maximum displacement in percentage/100


end