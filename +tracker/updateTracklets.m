function tracks = updateTracklets(tracklets, Hopt, hypTypes)
	% UPDATETRACKLETS Given the tracklets matrix and the optimal hypothesis, creates new matrix of tracks.
	% Inputs:
		% tracklets = row matrix of tracklets
		% Hopt = matrix of optimal hypothesis
		% hypTypes = corresponding type of each hypothesis
	% Outputs:
	% 	tracks = tracklets updated wrt the chosen hypothesis

	% This should mirror the types in generateHypothesisMatrix() and
	% eliminateUnlikelyHypothesis()
	TYPE_INIT = 1;
	TYPE_TERM = 2;
	TYPE_FP = 3;
	TYPE_LINK = 4;

	[numTracklets, numFrames] = size(tracklets);

	%------------------------------Create map index vector for initializations
	HinitIdx = find(hypTypes == TYPE_INIT);
	% For each tracklet index in the original tracklets matrix,
	% indicates the position index in the new tracks matrix.
	mapIdx = zeros(numTracklets, 1); 
	[~, J] = find(Hopt(HinitIdx, :));
	J = J - numTracklets;
	mapIdx(J) = 1:numel(J);

	%-----------------------------------------Update map index for transitions

	% Find the matrix of linking hypothesis
	HLinksIdx = find(hypTypes == TYPE_LINK);
	lhs = Hopt(HLinksIdx, 1:numTracklets);
	rhs = Hopt(HLinksIdx, (numTracklets+1):end);

	% Update the map indices, which indicate for each tracklet to which track
	% it should be copied over


	[A, B] = getHypothesisFromQueue();
	% Store hypothesis that could not be matched yet
	[remA, remB] = prepareRems();

	while anyTrackletsInQueue()
		for i=1:numel(A)
			if isAmapped()
				% fprintf('A (%d) is mapped\n', A(i))
				addBtoAsLocation()
			else
				% fprintf('A (%d) is NOT mapped\n', A(i))
				enqueueHypothesis()
			end
		end
		A = remA;
		B = remB;
		[remA, remB] = prepareRems();
	end


	% while anyTrackletsInQueue()
	% 	[Ilhs, Jlhs] = find(lhs);
	% 	Jlhs(Ilhs) = Jlhs; 
	% 	[Irhs, Jrhs] = find(rhs);
	% 	Jrhs(Irhs) = Jrhs; 
	% 	for i=1:numel(Jlhs) % loop by index over links
	% 		if mapIdx(Jlhs(i)) == 0
	% 			% 	if the LHS of links is NOT in mapIdx
	% 			% 		place it at the remLinks
	% 			% TODO: this branch is not testesd
	% 			remLhs = vertcat(remLhs, lhs(i, :));
	% 			remRhs = vertcat(remRhs, rhs(i, :));
	% 		else
	% 			% take the tracklet in RHS
	% 			% place it into mapIdx(LHS)
	% 			% set mapIdx(RHS) = mapIdx(LHS)
	% 			mapIdx(Jrhs(i)) = mapIdx(Jlhs(i));
	% 		end
	% 	end
	% 	lhs = remLhs;
	% 	rhs = remRhs;
	% end


	%-------------------------------------------------Create the tracks matrix
	% [(1:numel(mapIdx))' mapIdx]

	% Used the mapping indices matrix to create the tracks matrix
	tracks = zeros(numel(HinitIdx), numFrames);
	[I, J] = find(tracklets);
	for i=1:numTracklets
		if mapIdx(i)
			idx = J(I==i);
			tracks(mapIdx(i), idx, :) = tracklets(i, idx, :);
		end
	end


	function bool = anyTrackletsInQueue()
		bool = ~isempty(A);
	end

	function [A, B, Ilhs, Irhs] = getHypothesisFromQueue()
		[Ilhs, A_orig] = find(lhs);
		A(Ilhs) = A_orig; 
		[Irhs, B_orig] = find(rhs);
		B(Irhs) = B_orig; 
	end

	function bool = isAmapped()
		bool = mapIdx(A(i)) ~= 0;
	end

	function addBtoAsLocation()
		% fprintf('Add B (%d) to As (%d) locations\n', B(i), A(i))
		mapIdx(B(i)) = mapIdx(A(i));
	end

	function enqueueHypothesis()
		remA = horzcat(remA, A(i));
		remB = horzcat(remB, B(i));
	end

	function [remA, remB] = prepareRems()
		remA = zeros(1, 0);	
		remB = zeros(1, 0);
	end
end