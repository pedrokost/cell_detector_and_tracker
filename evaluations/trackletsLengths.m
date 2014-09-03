function lengths = trackletsLengths(tracklets, actual)
	% TRACKLETSLENGTHS: returns a vector containing for each tracklets its
	% total lengths

	numTracklets = size(tracklets, 1);
	lengths = zeros(numTracklets, 1);

	for i=1:numTracklets
		if nargin < 1
			idx = find(tracklets(i, :));
			lengths(i) = idx(end) - idx(1);
		else
			lengths(i) = numel(find(tracklets(i, :)));
		end
	end
end