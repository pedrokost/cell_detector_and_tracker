function tracks = updateTracklets(tracklets, Hopt)
	% UPDATETRACKLETS Given the tracklets matrix and the optimal hypothesis, creates new matrix of tracks.
	% Inputs:
		% tracklets = row matrix of tracklets
		% Hopt = matrix of optimal hypothesis
	% Outputs:
	% 	tracks = tracklets updated wrt the chosen hypothesis

	char(humanizeHypothesis(Hopt))
	tracklets
	[numTracklets, numFrames] = size(tracklets);

	HinitAndTermIdx = find(sum(Hopt, 2) == 1);
	[I, J] = find(Hopt(HinitAndTermIdx, :));
	HinitLocalIdx = I(J > numTracklets);
	HinitIdx = HinitAndTermIdx(HinitLocalIdx);
	
	% For each tracklet index in the original tracklets matrix,
	% indicates the position index in the new tracks matrix.
	mapIdx = zeros(numTracklets, 1); 
	%------------------------------------------------------Copy over the inits
	[~, J] = find(Hopt(HinitIdx, :));
	J = J - numTracklets;
	tracks = tracklets(J, :, :);
	mapIdx(J) = 1:numel(J);

	%-------------------------------------------Copy over each linked tracklet

	% Find the matrix of linking hypothesis
	HfpAndLinkIdx = find(sum(Hopt, 2) == 2);
	lhs = (Hopt(HfpAndLinkIdx, 1:numTracklets));
	rhs = (Hopt(HfpAndLinkIdx, (numTracklets+1):end));
	difference = bsxfun(@minus, lhs, rhs);
	linksLocalIdx = any(difference ~= 0, 2);
	HLinksIdx = HfpAndLinkIdx(linksLocalIdx);
	
	lhs = lhs(linksLocalIdx, :);
	rhs = rhs(linksLocalIdx, :);
	% full(lhs)
	% full(rhs)

	% TODO in this loop I could just update the indices, 
	% and then all at once move the data

	remLhs = zeros(0, numTracklets);
	remRhs = zeros(0, numTracklets);
	while ~isempty(lhs)
		[~, Jlhs] = find(lhs);
		[~, Jrhs] = find(rhs);
		for i=1:size(lhs, 1) % loop by index over links
			if mapIdx(Jlhs(i)) == 0
				% 	if the LHS of links is NOT in mapIdx
				% 		place it at the remLinks
				remLhs = vertcat(remLhs, lhs(i, :));
				remRhs = vertcat(remRhs, rhs(i, :));
			else
				% take the tracklet in RHS
				% place it into mapIdx(LHS)
				% set mapIdx(RHS) = mapIdx(LHS)
				t = tracklets(Jrhs(i), :, :);
				tIdx = find(max(t(:, :, 1), t(:, :, 2))); % in case there are coordinates equal to 0;
				tracks(mapIdx(Jlhs(i)), tIdx, :) = t(:, tIdx, :);
				mapIdx(Jrhs(i)) = mapIdx(Jrhs(i));
			end
		end
		lhs = remLhs;
		rhs = remLhs;
	end

	tracks

end