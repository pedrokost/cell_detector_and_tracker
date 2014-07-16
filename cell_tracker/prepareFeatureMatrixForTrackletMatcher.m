%{
	This script prepares a matrix containing pairs of cell descriptors and a third objective column indicating if they are the same (that is if the cells are DIRECTLY or UNDIRECTLY (through several links) linked)

	The descriptors are obtained from the cell_detector as a by-product of detecting cells. Additionally a cell location is concatenated to that vector.

	The objective column is obtained from the user annotations of links in the dataset. It is important for the purpose of learning a good matcher that the annotations are as complete possible. 
%}
rng(1234)
clear all

doProfile = true;

if doProfile
	profile on % -memory 
end

global DSIN DSOUT;
MIN_TRACKLET_LENGTH = 5;
MAX_GAP = 5;

% Folder with user annotation of links
folderIN = fullfile('..', 'data', 'series30green');
% Folder with cell descriptors
folderOUT = fullfile('..', 'data', 'series30greenOUT');
saveToFile = fullfile(folderOUT, 'matcherTrainTrackletJoinerMatrix.mat');
% Data stores
DSIN = DataStore(folderIN, false);
DSOUT = DataStore(folderOUT, false);

tracklets = generateTracklets(folderIN, struct('withAnnotations', true));

% Only bother working with tracklets of length > N
cnt = sum(min(tracklets, 1), 2);
tracklets = tracklets(cnt > MIN_TRACKLET_LENGTH, :);

[numTracklets, numFrames] = size(tracklets);
% subplot(1,2,1); trackletViewer(tracklets, folderIN)

% For each tracklets, find the corresponding dots in the OUT folder
tracklets = convertAnnotationToDetectionIdx(tracklets);
% subplot(1,2,2); trackletViewer(tracklets, folderOUT)

Y = zeros(0, 1, 'uint8'); %[match/no-match]
I = zeros(0, 6, 'uint16'); % [trackletA, frameA, cellindexA, trackletB, frameB, cellindexB]

% First append all positive examples:
% cells in same tracklets with max distance of MAX_GAP
for t=1:numTracklets
	idx = find(tracklets(t, :));
	vals = tracklets(t, idx);

	C = combnk(idx, 2);
	D = C(:, 2) - C(:, 1);
	C = C(D < MAX_GAP, :);

	% TODO: random sample just a portion of the cases
	n = size(C, 1);
	tVec = repmat(t, n, 1);

	new = [tVec C(:, 1) tracklets(t, C(:, 1))' tVec C(:, 2) tracklets(t, C(:, 2))'];
	I = [I; new];

	Y = [Y; ones(size(C, 1), 1)];
end

% findall possible tracklets combinations
trackletCombos = combnk(1:numTracklets, 2);

for i=1:size(trackletCombos, 1)
	trackletA = tracklets(trackletCombos(1), :);
	trackletB = tracklets(trackletCombos(2), :);
	idxA = find(trackletA);
	idxB = find(trackletB);
	% For each cell in each tracklet
	% take all other cells in opposite tracklet
	C = combvec(idxA, idxB);
	n = size(C, 2);
	tVecA = repmat(trackletCombos(1), 1, n);
	tVecB = repmat(trackletCombos(2), 1, n);

	% TODO random sample
	new = [tVecA; C(1, :); trackletA(C(1, :)); tVecB; C(2, :); trackletB(C(2, :))]';

	I = [I; new];
	Y = [Y; zeros(size(C, 2), 1)];
	% and set it a negative example
end

clear new C D cnt i idx idxA idxB t trackletA trackletB vals;

n = numel(Y);
perm = randperm(n);
I = I(perm, :);
Y = Y(perm);

fprintf('There are %d positive and %d negative examples.\nThe ratio of positive to negative examples is 1:%.1f.\n', sum(Y==1), sum(Y==0), sum(Y==0)/sum(Y==1))

% Using the matrix, create a new matrix containing the difference of histograms
% with the objective function

% Check the side of descriptors
descriptorSize = numel(DSOUT.getDescriptors(1, 1));

X = zeros(n, descriptorSize + 2, 'single');

for i=1:n
	% [trackletA, frameA, cellindexA, trackletB, frameB, cellindexB]
	[dotsA, desA] = DSOUT.get(I(i, 2), I(i, 3));
	[dotsB, desB] = DSOUT.get(I(i, 5), I(i, 6));
	trackletA = tracklets(I(i, 1), :);
	trackletB = tracklets(I(i, 4), :);
	features = computeTrackletMatchFeatures(trackletA, dotsA, desA, trackletB, dotsB, desB);

	X(i, :) = features;
end

save(saveToFile, 'X', 'Y')

if doProfile
	profile off
	profile viewer
end