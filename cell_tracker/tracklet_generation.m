figure(1); clf;

folder = fullfile('..', 'cell_detector', 'kidney', 'outKidneyRed');


matfiles = dir(fullfile(folder, 'im4*.mat'));
matfiles = matfiles(1:3);
nFrames = length(matfiles);
nTracklets = 3; % estimate

% create the big matrix of tracklets
tracklets = zeros(nTracklets, nFrames, 2);

%------------------------------------------------------Insert first frame data
matfileB = matfiles(1);
% load(fullfile(folder, matfileB.name));
% XB = X; dotsB = dots; nCellsB = nCells;

dotsB = [1 1; 2 2; 3 3]; nCellsB = 3;

tracklets(1:nCellsB, 1, :) = dotsB;
nextID = nCellsB + 1;
Tprev = [1:nCellsB; 1:nCellsB]';  % previous projection table

Tcurr = []; % current projection table
nFrames = 3;

for f=1:nFrames-1
	%----------------------------------------------------------------Load data
	matfileA = matfileB;
	% XA = XB; 
	dotsA = dotsB; nCellsA = nCellsB;

	matfileB = matfiles(f+1);
	if f == 1
		dotsB = [2 2; 1 1; 3 3]; nCellsB = 3;
	elseif f==2
		dotsB = [3 3; 1 1; 2 2]; nCellsB = 3;
	end
		
	% load(fullfile(folder, matfileB.name));
	% XB = X; dotsB = dots; nCellsB = nCells;

	fprintf('Processing frame %d (%s)\n', f, matfileB.name);
	%-----------------------------------------------------Find matches A <-> B
	% [symm right left selected] = match(XA, XB, dotsA, dotsB);
	if f==1
		symm = [2;1;3];
	elseif f==2
		symm = [3;2;1];
	end
		
	%---------------------------------------------------Update existing tracks
	Tcurr = zeros(nCellsA, 2);
	Tcurr(:, 2) = symm;
	Icurr = 1:nCellsA;

	for i=Icurr
		% find match in Tprev(:, 2)
		matchIndex = find(i == Tprev(:, 2));  % should return only 1 index
		% take the corresponding index in Tprev(:, 1)
		if matchIndex
			Tcurr(i, 1) = Tprev(matchIndex, 1);
		end
	end

	Tcurr
	dotsA
	dotsB

	% Place the data into tracklets
	for i=1:size(Tcurr, 1)
		
		
		fprintf('Take [%d, %d] and update tracklet %d\n', dotsB(Tcurr(i, 2), :), Tcurr(i, 1))
		tracklets(Tcurr(i, 1), f+1, :) = dotsB(Tcurr(i, 2), :);
	end


	% for cellA=1:nCellsA
	% 	cellB = perm(cellA);
	% 	if ~cellB; continue; end
	% 	tracklets(cellA, f+1, :) = dotsB(cellB, :);
	% end
	%-----------------------------------------------------------Add new tracks
	% newCells = dotsB(~selected, :)
	% numNewCells = size(newCells, 1) - 1;
	% tracklets(nextID:(nextID+numNewCells), f+1, :) = newCells;
	% nextID = nextID+numNewCells+1;

	Tprev = Tcurr;
end
tracklets
% save the detection into the tracklets matrix

% display tracklets matrix

trackletViewer(tracklets, struct('animate', false))