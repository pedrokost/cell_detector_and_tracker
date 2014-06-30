function tracklets = generateTracklets(folderOUT)
% GENERATETRACKLETS generates robust tracklets based on data found in the provided folder
% Inputs:
% 	- folderOUT = folder containing im*.mat files which contain a 
%		feature vector and location of each cell. One file per image.
% Output:
% 	- tracklets = a matrix of tracklets. Each row belongs to one 
%		tracklet

	test = true;

	if exist(folderOUT, 'dir') ~= 7
		error('The folder "%s" does not exist.', folderOUT);
	end

	matfiles = dir(fullfile(folderOUT, 'im*.mat'));

	if numel(matfiles) == 0
		error('There is no im*.mat file in folder: "%s"\n', folderOUT);
	end

	if test
		nFrames = 5;
		nTracklets = 5; % estimate
		firstFrame = 1;
	else
		nFrames = length(matfiles);
		nTracklets = 100; % estimate
		% TODO: automatically grow trakclets size in batches to make it faster
	
		% nTracklets = 12; % estimate
		% nFrames = firstFrame+4;
	end
		
	% create the big matrix of tracklets
	tracklets = zeros(nTracklets, nFrames, 2);

	%--------------------------------------------------Insert first frame data
	matfileB = matfiles(firstFrame);

	if test
		dotsB = [1 1; 3 3]; nCellsB = 2; XB = dotsB;
	else
		load(fullfile(folderOUT, matfileB.name));
		XB = descriptors; dotsB = dots; nCellsB = size(dotsB, 1);
	end

	tracklets(1:nCellsB, firstFrame, :) = dotsB;
	nextID = nCellsB + 1;
	Tprev = [1:nCellsB; 1:nCellsB]';  % previous projection table

	Tcurr = []; % current projection table

	globalPremutation = (1:nCellsB)';
	currNumTracklets = nCellsB;

	for f=firstFrame+1:nFrames
		%------------------------------------------------------------Load data
		matfileA = matfileB;
		XA = XB; dotsA = dotsB; nCellsA = nCellsB;

		matfileB = matfiles(f);

		if test
			if f == 2
				dotsB = [2 2; 1 1; 3 3]; nCellsB = 3; XB = dotsB;
			elseif f==3
				dotsB = [3 3; 1 1; 2 2]; nCellsB = 3; XB = dotsB;
			elseif f==4
				dotsB = [3 3; 1 1; 2.5 2.5]; nCellsB = 3; XB = dotsB;
			elseif f==5
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

		[globalPremutation, currNumTracklets] = updateGlobalPermutation(globalPremutation, currNumTracklets, permutation, selectedLeft, selectedRight)

		% if f == 2
		% 	currNumTracklets = 3;
		% 	globalPremutation = [2 3 1]';
		% elseif f==3
		% 	currNumTracklets = 3;
		% 	globalPremutation = [2 1 3]';
		% elseif f==4
		% 	currNumTracklets = 4;
		% 	globalPremutation = [2 1 0 3]';
		% end

		gFrameCells = getCellTrackletsFrame(dotsB, globalPremutation, currNumTracklets);

		tracklets(1:currNumTracklets, f, :) = gFrameCells;
		dotsB(:, 1)
		tracklets(:, :, 1)
		% Tcurr = zeros(nCellsA, 2);

		% if ~(any(size(permutation) == 0)) % if no cells

		% 	Tcurr(:, 2) = permutation;
		% 	Icurr = 1:nCellsA;
		% 	%-----------------------------------------------Update existing tracks

		% 	for i=Icurr
		% 		if ~permutation(i); continue; end
		% 		% find match in Tprev(:, 2)
		% 		matchIndex = find(i == Tprev(:, 2));  % should return only 1 index
		% 		% take the corresponding index in Tprev(:, 1)
		% 		if matchIndex
		% 			Tcurr(i, 1) = Tprev(matchIndex, 1);
		% 		end
		% 	end

		% 	% Place the data into tracklets
		% 	for i=1:size(Tcurr, 1)
		% 		if any(Tcurr(i, :)==0); continue; end
		% 		% fprintf('Take [%d, %d] and update tracklet %d\n', dotsB(Tcurr(i, 2), :), Tcurr(i, 1))
		% 		tracklets(Tcurr(i, 1), f, :) = dotsB(Tcurr(i, 2), :);
		% 	end
		% 	% -------------------------------------------------------Add new tracks
		% 	newCells = dotsB(~selectedLeft, :);
		% 	numNewCells = size(newCells, 1);
		% 	tracklets(nextID:(nextID+numNewCells-1), f, :) = newCells;
		% 	nextID = nextID+numNewCells;
		% 	% Should att the new tracklet to Tcurr, so I can update in next steps
		% 	% I need to add 0 indx where indx is the index of the new cell in dotsB
		% 	% [I, J] = find(~selectedLeft);
		% 	% Tnew = horzcat(zeros(sum(~selectedLeft), 1), J)
		% 	% Tcurr = vertcat(Tcurr, Tnew);
		% end
		%--------------------------------------Use current data for next frame
		% Tprev = Tcurr;
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


	% [(1:numel(globalPremutation))' globalPremutation]
	% permutation

	% selectedLeft
	% selectedRight
	% globalPremutation = globalPremutation(permutation', :)
	% See if u can update globalPremutation
	% Else add new tracks
	perm = zeros(size(permutation));
	for i=1:numel(perm)
		if globalPremutation(i)
			perm(i) = permutation(globalPremutation(i));
		end
	end
	% perm = permutation(globalPremutation(1:numel(permutation)));
	globalPremutation = perm'; % zeros(size(globalPremutation));

	%---------------------------------------------------------Update tracklets

	permutation
	% for each existing cell
	% find where it is saved in the dotsB
	% and return its index

	%--------------------------------------------------------Add new tracklets

	% Add all tracklets as new
	% newTracklets = numel(selectedLeft);
	% globalPremutation = vertcat(globalPremutation, (1:newTracklets)');
	% currNumTracklets = currNumTracklets + newTracklets;


	% Only add new tracklets as new
	[~, J] = find(~selectedLeft);
	newTracklets = sum(~selectedLeft);
	currNumTracklets = currNumTracklets + newTracklets;
	globalPremutation = vertcat(globalPremutation, J);
end