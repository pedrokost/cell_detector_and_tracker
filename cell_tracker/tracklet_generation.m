figure(1); clf;
rng(1234)

test = false;

folder = fullfile('..', 'cell_detector', 'kidney', 'outKidneyGreen');


matfiles = dir(fullfile(folder, 'im*.mat'));
if test
	nFrames = 4;
	nTracklets = 5; % estimate
else
	nFrames = length(matfiles);
	nTracklets = 100; % estimate
end
	
% create the big matrix of tracklets
tracklets = zeros(nTracklets, nFrames, 2);

%------------------------------------------------------Insert first frame data
matfileB = matfiles(1);

if test
	dotsB = [1 1; 3 3]; nCellsB = 2; XB = dotsB;
else
	load(fullfile(folder, matfileB.name));
	XB = X; dotsB = dots; nCellsB = size(dotsB, 1);
end

tracklets(1:nCellsB, 1, :) = dotsB;
nextID = nCellsB + 1;
Tprev = [1:nCellsB; 1:nCellsB]';  % previous projection table

Tcurr = []; % current projection table

for f=1:nFrames-1
	%----------------------------------------------------------------Load data
	matfileA = matfileB;
	XA = XB; dotsA = dotsB; nCellsA = nCellsB;

	matfileB = matfiles(f+1);

	if test
		if f == 1
			dotsB = [2 2; 1 1; 3 3]; nCellsB = 3; XB = dotsB;
		elseif f==2
			dotsB = [3 3; 1 1]; nCellsB = 2; XB = dotsB;
		elseif f==3
			dotsB = [3 3; 2 2; 1 1]; nCellsB = 3; XB = dotsB;
		end
	else	
		load(fullfile(folder, matfileB.name));
		XB = X; dotsB = dots; nCellsB = size(dotsB, 1);
	end
	fprintf('Processing frame %d (%s)\n', f, matfileB.name);
	%-----------------------------------------------------Find matches A <-> B
	% if test
	% 	if f==1
	% 		symm = [2; 3];
	% 		selectedLeft = [0;1;1];
	% 	elseif f==2
	% 		symm = [0;2;1];
	% 		selectedLeft = [1;1];
	% 	elseif f==3
	% 		symm = [1;3];
	% 		selectedLeft = [1;0;1];
	% 	end
	% else
	% 	[symm right left selectedRight selectedLeft] = match(XA, XB, dotsA, dotsB);
	% end
	
	[symm right left selectedRight selectedLeft] = match(XA, XB, dotsA, dotsB);

		
	%---------------------------------------------------Update existing tracks
	Tcurr = zeros(nCellsA, 2);
	Tcurr(:, 2) = symm;
	Icurr = 1:nCellsA;

	for i=Icurr
		if ~symm(i); continue; end
		% find match in Tprev(:, 2)
		matchIndex = find(i == Tprev(:, 2));  % should return only 1 index
		% take the corresponding index in Tprev(:, 1)
		if matchIndex
			Tcurr(i, 1) = Tprev(matchIndex, 1);
		end
	end

	% Place the data into tracklets
	for i=1:size(Tcurr, 1)
		if any(Tcurr(i, :)==0); continue; end
		% fprintf('Take [%d, %d] and update tracklet %d\n', dotsB(Tcurr(i, 2), :), Tcurr(i, 1))
		tracklets(Tcurr(i, 1), f+1, :) = dotsB(Tcurr(i, 2), :);
	end
	%-----------------------------------------------------------Add new tracks
	% dotsA
	% dotsB
	newCells = dotsB(~selectedLeft, :);
	numNewCells = size(newCells, 1);
	tracklets(nextID:(nextID+numNewCells-1), f+1, :) = newCells;
	nextID = nextID+numNewCells;
	%------------------------------------------Use current data for next frame
	Tprev = Tcurr;
end
% tracklets
% save the detection into the tracklets matrix

% display tracklets matrix

trackletViewer(tracklets, struct('animate', false, 'animationSpeed', 5))