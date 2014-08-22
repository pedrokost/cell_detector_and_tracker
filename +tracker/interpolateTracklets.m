function tracklets2D = interpolateTracklets(tracklets2D)
	% Wrapper for interpolateTracklet to compute interpolations for several tracklets
	% at once

	numTracklets = size(tracklets2D, 1);

	for i=1:numTracklets
        tracklet = permute(tracklets2D(i, :, :), [2 3 1]);
		interpTracklet = tracker.interpolateTracklet(double(tracklet));
        tracklets2D(i, :, :) = permute(interpTracklet, [3 1 2]);
	end
end