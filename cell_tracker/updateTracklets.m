function tracks = updateTracklets(tracklets, Hopt)
	% UPDATETRACKLETS Given the tracklets matrix and the optimal hypothesis, creates new matrix of tracks.
	% Inputs:
		% tracklets = row matrix of tracklets
		% Hopt = matrix of optimal hypothesis
	% Outputs:
	% 	tracks = tracklets updated wrt the chosen hypothesis

	[numTracklets, numFrames] = size(tracklets);

	HinitAndTermIdx = find(sum(Hopt, 2) == 1);
	[I, J] = find(Hopt(HinitAndTermIdx, :));
	HinitLocalIdx = I(J > numTracklets);
	HinitIdx = HinitAndTermIdx(HinitLocalIdx);
	
	% For each tracklet index in the original tracklets matrix,
	% indicates the position index in the new tracks matrix.
	mapIdx = zeros(numTracklets, 1); 
	%------------------------------Create map index vector for initializations
	[~, J] = find(Hopt(HinitIdx, :));
	J = J - numTracklets;
	mapIdx(J) = 1:numel(J);

	%-----------------------------------------Update map index for transitions

	% Find the matrix of linking hypothesis
	HfpAndLinkIdx = find(sum(Hopt, 2) == 2);
	lhs = (Hopt(HfpAndLinkIdx, 1:numTracklets));
	rhs = (Hopt(HfpAndLinkIdx, (numTracklets+1):end));
	difference = bsxfun(@minus, lhs, rhs);
	linksLocalIdx = any(difference ~= 0, 2);
	HLinksIdx = HfpAndLinkIdx(linksLocalIdx);
	
	lhs = lhs(linksLocalIdx, :);
	rhs = rhs(linksLocalIdx, :);

	% Update the map indices, which indicate for each tracklet to which track
	% it should be copied over

	remLhs = zeros(0, numTracklets);
	remRhs = zeros(0, numTracklets);
	while ~isempty(lhs)
		[Ilhs, Jlhs] = find(lhs);
		Jlhs2 = zeros(size(Jlhs));
		Jlhs(Ilhs) = Jlhs; 
		[Irhs, Jrhs] = find(rhs);
		Jrhs(Irhs) = Jrhs; 
		for i=1:numel(Jlhs) % loop by index over links
			if mapIdx(Jlhs(i)) == 0
				% 	if the LHS of links is NOT in mapIdx
				% 		place it at the remLinks
				% TODO: this branch is not testesd
				remLhs = vertcat(remLhs, lhs(i, :));
				remRhs = vertcat(remRhs, rhs(i, :));
			else
				% take the tracklet in RHS
				% place it into mapIdx(LHS)
				% set mapIdx(RHS) = mapIdx(LHS)
				mapIdx(Jrhs(i)) = mapIdx(Jlhs(i));
			end
		end
		lhs = remLhs;
		rhs = remLhs;
	end


	%-------------------------------------------------Create the tracks matrix
	
	% Used the mapping indices matrix to create the tracks matrix
	tracks = zeros(numel(HinitIdx), numFrames);
	[I, J] = find(tracklets);
	for i=1:numTracklets
		if mapIdx(i)
			idx = J(I==i);
			tracks(mapIdx(i), idx, :) = tracklets(i, idx, :);
		end
	end
end