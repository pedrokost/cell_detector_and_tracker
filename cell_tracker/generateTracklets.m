function tracklets = generateTracklets(folderOUT)
% GENERATETRACKLETS generates robust tracklets based on data found in the provided folder
% Inputs:
% 	- folderOUT = folder containing im*.mat files which contain a 
%		feature vector and location of each cell. One file per image.
% Output:
% 	- tracklets = a matrix of tracklets. Each row belongs to one 
%		tracklet

	mockData = false;
	mockGlobalPermutation = false;

	if exist(folderOUT, 'dir') ~= 7
		error('The folder "%s" does not exist.', folderOUT);
	end

	matfiles = dir(fullfile(folderOUT, 'im*.mat'));

	if numel(matfiles) == 0
		error('There is no im*.mat file in folder: "%s"\n', folderOUT);
	end

	firstFrame = 1;
	if mockData || mockGlobalPermutation
		nFrames = 7;
		nTracklets = 5; % estimate
	else
		nFrames = length(matfiles);
		nTracklets = 12; % estimate
		% TODO: automatically grow trakclets size in batches to make it faster
	end
		
	% create the big matrix of tracklets
	tracklets = zeros(nTracklets, nFrames, 2);

	%--------------------------------------------------Insert first frame data
	matfileB = matfiles(firstFrame);

	if mockGlobalPermutation || mockData
		dotsB = [1 1; 3 3]; nCellsB = 2; XB = dotsB;
	else
		load(fullfile(folderOUT, matfileB.name));
		XB = descriptors; dotsB = dots; nCellsB = size(dotsB, 1);
	end

	currNumTracklets = nCellsB;
	tracklets(1:currNumTracklets, firstFrame, :) = dotsB;
	nextID = nCellsB + 1;

	globalPremutation = (1:nCellsB)';

	for f=firstFrame+1:nFrames
		%------------------------------------------------------------Load data
		matfileA = matfileB;
		XA = XB; dotsA = dotsB; nCellsA = nCellsB;

		matfileB = matfiles(f);

		if mockData || mockGlobalPermutation
			if f == 2
				dotsB = [2 2; 1 1; 3 3]; nCellsB = 3; XB = dotsB;
			elseif f==3
				dotsB = [3 3; 1 1; 2 2]; nCellsB = 3; XB = dotsB;
			elseif f==4
				dotsB = [3 3; 1 1; 2.5 2.5]; nCellsB = 3; XB = dotsB;
			elseif f==5
				dotsB = [2.5 2.5; 2 2; 3 3]; nCellsB = 3; XB = dotsB;
			elseif f==6
				dotsB = zeros(0, 2); nCellsB = 0; XB = dotsB;
			elseif f==7
				dotsB = [2.5 2.5; 2 2; 3 3]; nCellsB = 3; XB = dotsB;
			end
		else	
			load(fullfile(folderOUT, matfileB.name));
			XB = descriptors; dotsB = dots; nCellsB = size(dotsB, 1);
		end
		fprintf('Processing frame %d (%s)\n', f, matfileB.name);
		%-------------------------------------------------Find matches A <-> B
		% if test
		% 	if f==1
		% 		permutation = [2; 3];
		% 		selectedLeft = [0;1;1];
		% 	elseif f==2
		% 		permutation = [0;2;1];
		% 		selectedLeft = [1;1];
		% 	elseif f==3
		% 		permutation = [1;3];
		% 		selectedLeft = [1;0;1];
		% 	end
		% else
		% 	[permutation right left selectedRight selectedLeft] = match(XA, XB, dotsA, dotsB);
		% end
		
		[permutation right left selectedRight selectedLeft] = match(XA, XB, dotsA, dotsB);

		if mockGlobalPermutation
			if f == 2
				currNumTracklets = 3;
				globalPremutation = [2 3 1]';
			elseif f==3
				currNumTracklets = 3;
				globalPremutation = [2 1 3]';
			elseif f==4
				currNumTracklets = 4;
				globalPremutation = [2 1 0 3]';
			elseif f==5
				currNumTracklets = 5;
				globalPremutation = [0 3 0 1 2]';
			elseif f==6
				currNumTracklets = 5;
				globalPremutation = [0 0 0 0 0]';
			elseif f==7
				currNumTracklets = 8;
				globalPremutation = [0 0 0 0 0 1 2 3]';
			end
		else
			[globalPremutation, currNumTracklets] = updateGlobalPermutation(globalPremutation, currNumTracklets, permutation, selectedLeft, selectedRight);
		end

		gFrameCells = getCellTrackletsFrame(dotsB, globalPremutation, currNumTracklets);

		tracklets(1:currNumTracklets, f, :) = gFrameCells;
	end
end

function gFrameCell = getCellTrackletsFrame(dotsB, globalPremutation, currNumTracklets)
	% GETCELLTRACKLETSFRAME returns a vector with the data from dotsB but reordered
	% based on the indices in globalPremutation
	gFrameCell = zeros(currNumTracklets, 2, 'double');
	for i=1:numel(globalPremutation)
		if globalPremutation(i)
			gFrameCell(i, :) = dotsB(globalPremutation(i), :);
		end
	end
end

function [globalPremutation, currNumTracklets] = updateGlobalPermutation(globalPremutation, currNumTracklets, permutation, selectedLeft,selectedRight)
	% UPDATEGLOBALPERMUTATION Updates the previous globalPremutation to be used for inserting the cells
	% in the correct tracklet. a globalPremutation is some kind of an index which indicates
	% to which location (tracklet) in the tracklets matrix should the cells be
	% stored

	%---------------------------------------------------------Update tracklets
	% globalPremutation
	% permutation

	if ~isempty(permutation)
		perm = zeros(size(globalPremutation'));
		for i=1:numel(globalPremutation)
			if globalPremutation(i)
				perm(i) = permutation(globalPremutation(i));
			end
		end
		globalPremutation = perm';
	else
		globalPremutation = zeros(size(globalPremutation));
	end

	%--------------------------------------------------------Add new tracklets

	% Only add new tracklets as new
	[~, J] = find(~selectedLeft);
	newTracklets = sum(~selectedLeft);
	currNumTracklets = currNumTracklets + newTracklets;
	globalPremutation = vertcat(globalPremutation, J');
end