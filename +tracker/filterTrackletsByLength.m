function [tracklets, idx] = filterTrackletsByLength(tracklets, minLength)
	% Only bother working with tracklets of length >= N
	cnt = sum(min(tracklets, 1), 2);
	idx = cnt >= minLength;
	tracklets = tracklets(idx, :);
end