function tracklet2D = interpolateTracklet(tracklet2D)
	% given 2D matrix containing a tracklet coordinates it interpolates any missing values

	lenTracklet = size(tracklet2D, 1);

	actualTrackletLen = numel(any(find(tracklet2D), 2));

	if lenTracklet > 1 && actualTrackletLen > 1
		[tracklet2D, nonzeroIdx] = tracker.eliminateZeroRows(tracklet2D);

		if any(nonzeroIdx == 0)
			tracklet2D = interp1(find(nonzeroIdx), tracklet2D, (1:lenTracklet)');
		end
	end
end