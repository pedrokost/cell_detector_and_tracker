function lengths = trackletsLengths(tracklets)
	% TRACKLETSLENGTHS: returns a vector containing for each tracklets its
	% total lengths

	numTracklets = size(tracklets, 1);
	lengths = zeros(numTracklets, 1);

	for i=1:numTracklets
		lengths(i) = numel(find(tracklets(i, :)));
	end
end