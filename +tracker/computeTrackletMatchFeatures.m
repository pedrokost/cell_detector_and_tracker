function X = computeTrackletMatchFeatures(tracklets, trackletPairs, dataParams)
	% COMPUTETRACKLETMATCHFEATURES Compute the matrix containing for each tracklet pair a feature vector

	[featParams, numFeatures] = tracker.setFeatures();
	numPairs = size(trackletPairs, 1);

	tracklets2 = tracker.trackletsToPosition(tracklets, 'out');

	X = zeros(numPairs, numFeatures);

	for i=1:numPairs
		% Create vector of shape [trackletA, frameA, fileA, cellindexA, trackletB, frameB, fileB, cellindexB]
		trackletAPos = tracklets(trackletPairs(i, 1),  :);
		trackletBPos = tracklets(trackletPairs(i, 2), :);

		trackletAIdx = find(trackletAPos);
		trackletBIdx = find(trackletBPos);

		I = zeros(1, 6);
		I(1) = trackletPairs(i, 1);
		I(2) = trackletAIdx(end); % last frame of tracklet A 
		I(3) = trackletAPos(trackletAIdx(end));
		I(4) = trackletPairs(i, 2);
		I(5) = trackletBIdx(1); % first frame of tracklet B
		I(6) = trackletBPos(trackletBIdx(1));

		I = tracker.addActualFileIndices(I);

		trackletA = tracklets2(I(1), trackletAIdx(1):trackletAIdx(end), :);
		trackletB = tracklets2(I(5), trackletBIdx(1):trackletBIdx(end), :);
		features = tracker.computeTrackletMatchFeaturesForPair(trackletA, trackletB, I, featParams, numFeatures, dataParams);

		X(i, :) = features;
	end
end