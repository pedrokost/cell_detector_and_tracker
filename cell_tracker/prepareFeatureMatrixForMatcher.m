%{
	This script prepares a matrix containing pairs of cell descriptors and a third objective column indicating if they are the same (that is if the cells are linked)

	The descriptors are obtained from the cell_detector as a by-product of detecting cells. Additionally a cell location is concatenated to that vector.

	The objective column is obtained from the user annotations of links in the dataset. It is important for the purpose of learning a good matcher that the annotations are as complete possible. 
%}

clear all

MATCHING_DOT_DISTANCE = 10; % Permissible distance disparity between dot positions 

% Folder with user annotation of links
folderIN = fullfile('..', 'data', 'series30green');

% Folder with cell descriptors
folderOUT = fullfile('..', 'data', 'series30greenOUT');

matAnnotations = dir(fullfile(folderIN, 'im*.mat'));

numFrames = numel(matAnnotations);

% First, associate each annotation with the corresponding feature vector
% Drop any detected cells that don't have annotation, or annotations with missing detections

for i=1:(numFrames-1)

	% Load annotations and detections
	filenameA = matAnnotations(i).name;
	filenameA = matAnnotations(i+1).name;

	data = load(fullfile(folderIN, filenameA));
	dotsGtA = data.dots; links = data.links;

	data = load(fullfile(folderIN, filenameB));
	dotsGtB = data.dots;

	data = load(fullfile(folderOUT, filenameA));
	dotsDetA = data.dots; descriptorsA = data.descriptors;

	data = load(fullfile(folderOUT, filenameA));
	dotsDetB = data.dots; descriptorsB = data.descriptors;

	[descriptors, ~] = combineDescriptorsWithDots(descriptors, dots);

	M = buildTrainMatrixForFrame(dotsGt, dotsDet, links, descriptors);
end
