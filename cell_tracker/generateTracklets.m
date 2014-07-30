function tracklets = generateTracklets(folderData, options)
% GENERATETRACKLETS generates robust tracklets based on data found in the provided folder.

% Inputs:
% 	- folderData = folder containing im*.mat files which contain a 
%		feature vector and location of each cell. One file per image.
% 		If false, it will use the match function to find matches
% 	- options = a struct containing options
%	 	withAnnotations = [false] boolean saying if the metadata files have links annotations.
%		numericFormat = [single] Use uint16 if more than 255 cells per image
%		modelFile = string string to the path to the model data files for a NB classifier
% Output:
% 	- tracklets = a matrix of tracklets. Each row belongs to one 
%		tracklet

	%-----------------------------------------------------------------Defaults
	withAnnotations = false;
	numericFormat = 'single';

	if strcmp(folderData, 'in');
		global DSIN;
		store = DSIN;
	elseif strcmp(folderData, 'out')
		global DSOUT;
		store = DSOUT;
	end

	if nargin < 2; options = struct; end;
	%----------------------------------------------------------------Overrides
	if isfield(options, 'withAnnotations')
		withAnnotations = options.withAnnotations;
	end
	if isfield(options, 'numericFormat')
		numericFormat = options.numericFormat;
	end
	%-----------------------------------------------------------Initialization

	frameNumbers = store.getMatfileIndices();

	if numel(frameNumbers) == 0
		error('There is no im*.mat file in folder: "%s"\n', folderData);
	end

	firstFrame = frameNumbers(1);
	numFrames = numel(frameNumbers);
	numTracklets = 100; % estimate
	% TODO: automatically grow trakclets size in batches to make it faster
		
	% create the big matrix of tracklets
	tracklets = zeros(numTracklets, numFrames, numericFormat);

	%--------------------------------------------------Insert first frame data

	if withAnnotations
		[dots, links] = store.getDotsAndLinks(frameNumbers(firstFrame));
		linksB = links;
	else
		[dots, descriptors] = store.get(frameNumbers(firstFrame));
		XB = descriptors;
	end
	dotsB = dots; nCellsB = size(dotsB, 1);

	currNumTracklets = nCellsB;
	globalPremutation = (1:nCellsB)';
	tracklets(globalPremutation, firstFrame) = globalPremutation;

	for f=firstFrame+1:numFrames
		%------------------------------------------------------------Load data
		dotsA = dotsB; nCellsA = nCellsB;
		if withAnnotations
			linksA = linksB;
		else
			XA = XB;
		end

		if withAnnotations
			[dots, links] = store.getDotsAndLinks(frameNumbers(f));
			linksB = links;
		else
			[dots, descriptors] = store.get(frameNumbers(f));
			XB = descriptors;
		end
		dotsB = dots; nCellsB = size(dotsB, 1);

		if withAnnotations
			permutation = linksA;
			selectedLeft = zeros(nCellsB, 1);
			selectedLeft(linksA(linksA~=0)) = 1;
		else
			[permutation right left selectedRight selectedLeft] = match(XA, XB, dotsA, dotsB, struct('modelFile', options.modelFile));
		end

		[globalPremutation, currNumTracklets] = updateGlobalPermutation(globalPremutation, currNumTracklets, permutation, selectedLeft);

		tracklets(1:currNumTracklets, f) = globalPremutation;
	end
	
	tracklets = tracklets(1:currNumTracklets, :);
end

function [globalPremutation, currNumTracklets] = updateGlobalPermutation(globalPremutation, currNumTracklets, permutation, selectedLeft)
	% UPDATEGLOBALPERMUTATION Updates the previous globalPremutation to be used for inserting the cells
	% in the correct tracklet. a globalPremutation is some kind of an index which indicates
	% to which location (tracklet) in the tracklets matrix should the cells be
	% stored

	%---------------------------------------------------------Update tracklets

	if ~isempty(permutation)
		gPerm = zeros(size(globalPremutation));
		gPermIdx = find(globalPremutation);
		gPerm(gPermIdx) = permutation(globalPremutation(gPermIdx));
		globalPremutation = gPerm;
	else
		globalPremutation = zeros(size(globalPremutation));
	end

	%--------------------------------------------------------Add new tracklets

	% Only add new tracklets as new
	[I, J] = find(~selectedLeft);
	newTracklets = sum(~selectedLeft);
	currNumTracklets = currNumTracklets + newTracklets;
	globalPremutation = vertcat(globalPremutation, I);
end