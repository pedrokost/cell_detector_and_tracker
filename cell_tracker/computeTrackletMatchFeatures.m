function X = computeTrackletMatchFeatures(tracklets, trackletPairs)
	% COMPUTETRACKLETMATCHFEATURES Compute the matrix containing for each tracklet pair a feature vector

	[featParams, numFeatures] = setFeatures();
	numPairs = size(trackletPairs, 1);

	X = zeros(numPairs, numFeatures);

	for i=1:numPairs
		% Create vector of shape [trackletA, frameA, cellindexA, trackletB, frameB, cellindexB]
		trackletA = tracklets(trackletPairs(i, 1),  :);
		trackletB = tracklets(trackletPairs(i, 2), :);

		idxA = find(trackletA);
		idxB = find(trackletB);

		I = zeros(1, 6);
		I(1) = trackletPairs(i, 1);
		I(2) = idxA(end); % last frame of tracklet A 
		I(3) = tracklets(trackletPairs(i, 1), idxA(end));
		I(4) = trackletPairs(i, 2);
		I(5) = idxB(1); % first frame of tracklet B
		I(6) = tracklets(trackletPairs(i, 2), idxB(1));

		trackletA = trackletA(idxA(1):idxA(end));
		trackletB = trackletB(idxB(1):idxB(end));
		features = computeTrackletMatchFeaturesForPair(trackletA, trackletB, I, featParams, numFeatures);

		X(i, :) = features;
	end
end