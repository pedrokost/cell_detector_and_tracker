function X = computeTrackletMatchFeatures(tracklets, trackletPairs)
	% COMPUTETRACKLETMATCHFEATURES Compute the matrix containing for each tracklet pair a feature vector

	[featParams, numFeatures] = setFeatures();
	numPairs = size(trackletPairs, 1);

	tracklets2 = trackletsToPosition(tracklets, 'out');

	X = zeros(numPairs, numFeatures);

	for i=1:numPairs
		% Create vector of shape [trackletA, frameA, cellindexA, trackletB, frameB, cellindexB]
		trackletAPos = tracklets(trackletPairs(i, 1),  :);
		trackletBPos = tracklets(trackletPairs(i, 2), :);


		idxA = find(trackletAPos);
		idxB = find(trackletBPos);

		I = zeros(1, 6);
		I(1) = trackletPairs(i, 1);
		I(2) = idxA(end); % last frame of tracklet A 
		I(3) = trackletAPos(idxA(end));
		I(4) = trackletPairs(i, 2);
		I(5) = idxB(1); % first frame of tracklet B
		I(6) = trackletBPos(idxB(1));

		trackletA = tracklets2(trackletPairs(i, 1), idxA(1):I(2), :);
		trackletB = tracklets2(trackletPairs(i, 2), I(5):idxB(end), :);
		features = computeTrackletMatchFeaturesForPair(trackletA, trackletB, I, featParams, numFeatures);

		X(i, :) = features;
	end
end