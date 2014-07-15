%{
	This script prepares a matrix containing pairs of cell descriptors and a third objective column indicating if they are the same (that is if the cells are DIRECTLY or UNDIRECTLY (through several links) linked)

	The descriptors are obtained from the cell_detector as a by-product of detecting cells. Additionally a cell location is concatenated to that vector.

	The objective column is obtained from the user annotations of links in the dataset. It is important for the purpose of learning a good matcher that the annotations are as complete possible. 
%}
rng(1234)
% clear all

doProfile = false;

if doProfile
	profile -memory on
end

global DSIN DSOUT;
MIN_TRACKLET_LENGTH = 5;
MAX_GAP = 3;

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
subplot(1,2,1); trackletViewer(tracklets, folderIN)

% For each tracklets, find the corresponding dots in the OUT folder
tracklets = convertAnnotationToDetectionIdx(tracklets);
subplot(1,2,2); trackletViewer(tracklets, folderOUT)

Y = zeros(0, 1, 'uint8'); %[match/no-match]
I = zeros(0, 4, 'uint16'); % [frameA, cellindexA, frameB, cellindexB]


for t=1:numTracklets
	idx = find(tracklets(t, :));
	vals = tracklets(t, idx);

	C = combnk(idx, 2);
	D = C(:, 2) - C(:, 1);
	C = C(D < MAX_GAP, :);

	% TODO: random sample just a portion of the cases

	new = [C(:, 1) tracklets(t, C(:, 1))' C(:, 2) tracklets(t, C(:, 2))']
	I = [I; new];

	Y = [Y; ones(size(C, 1), 1)];
end

size(I)
size(Y)


% First append all positive examples
% Then find all possible combinations of tracklets, and add all negative examples
% Then load the corresponding descriptors, and store the differences (normalized)




% First, associate each annotation with the corresponding feature vector
% Drop any detected cells that don't have annotation, or annotations with missing detections
% startIdx = 1;

% % Load annotations and detections for first image
% filenameA = matAnnotations(startIdx).name;
% data = load(fullfile(folderIN, filenameA));
% dotsGtA = data.dots; linksA = data.links;
% data = load(fullfile(folderOUT, filenameA));
% dotsDetA = data.dots; descriptorsA = data.descriptors;
% [descriptorsA, permA, IA] = getAnnotationDescriptors(dotsGtA, dotsDetA, descriptorsA);
% [descriptorsA, ~] = combineDescriptorsWithDots(descriptorsA, dotsGtA);
% descriptorsA = descriptorsA(find(IA), :); dotsGtA = dotsGtA(find(IA), :); linksA = linksA(find(IA));


% for i=startIdx:(numFrames-1)
% 	%% Load annotations and detections for next image
% 	filenameB = matAnnotations(i+1).name;
% 	data = load(fullfile(folderIN, filenameB));
% 	dotsGtB = data.dots; linksB = data.links;
% 	data = load(fullfile(folderOUT, filenameB));
% 	dotsDetB = data.dots; descriptorsB = data.descriptors;
% 	[descriptorsB, permB, IB] = getAnnotationDescriptors(dotsGtB, dotsDetB, descriptorsB);
% 	[descriptorsB, ~] = combineDescriptorsWithDots(descriptorsB, dotsGtB);
% 	descriptorsB = descriptorsB(find(IB), :); dotsGtB = dotsGtB(find(IB), :); linksB = linksB(find(IB), :);

% 	%% Clean linksA:
% 	% For each value in linksA that matches a find(IB), I need to elimintate it,
% 	% and all the bigger values decrease by 1.
% 	badVals = find(~IB); % Eliminte this values from linksA
% 	for i=1:numel(badVals)
% 		badVal = badVals(i);
% 		% Elimintae the value from LinksA by placing a 0 in its location
% 		linksA(find(linksA == badVal)) = 0;
% 		% Find all in linksA bigger than badVal and decrease them by 1
% 		biggerIdx = find(linksA > badVal);
% 		linksA(biggerIdx) = linksA(biggerIdx) - 1;
% 		% decrease all values of badVal by 1
% 		badVals = badVals - 1;
% 	end

% 	M = buildTrainMatrixForFramePair(descriptorsA, descriptorsB, linksA);
% 	X = vertcat(X, M);
	
% 	filenameA = filenameB; linksA = linksB; descriptorsA = descriptorsB;
% 	dotsGtA = dotsGtB; dotsDetA = dotsGtB;
% end

% goodX = load(saveToFile);
% if ~(all(all(goodX.X == X)))
% 	save(saveToFile, 'X')
% end
% X = normalizeRange(X, {1:2});
% imagesc(X)


if doProfile
	profile off
	profile viewer
end