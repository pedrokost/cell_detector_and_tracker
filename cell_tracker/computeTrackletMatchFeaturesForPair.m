function features = computeTrackletMatchFeaturesForPair(trackletA, trackletB, I, featParams, numFeatures)
	% COMPUTETRACKLETMATCHFEATURESFORPAIR Compute a spatio-temporal feature vector for two possibly interacting tracklets.
	% Inputs:
	% 	trackletA/trackletB = the row of the tracklets matrix concerning these two descriptors
	%	I = a vector of the form [trackletA, frameA, cellIdxA, trackletB, frameB, cellindexB]
	%		trackletA/trackletB = the index of the tracklet
	%		frameA/frameB = the frame number where trackletA ends and trackletB starts
	%		cellIdxA/cellindexB = the indices of the cells within the corresponding frames
	% 	featParams = a structure with parameters for building the feature vector. See setFeatures()
	% 	numFeatures = the number of features in the final descriptor
	% 	DSOUT = a Global datastore for data in outFolder
	% Outputs:
	% 	features = a feature vector of the two intracting tracklets

	global DSOUT;

	frameA   = I(2);
	frameB   = I(5);
	cellIdxA = I(3);
	cellIdxB = I(6);

	[dotsA, desA] = DSOUT.get(frameA, cellIdxA);
	[dotsB, desB] = DSOUT.get(frameB, cellIdxB);

	features = zeros(1, numFeatures);
	idx = 1;

	if featParams.addCellDescriptors
		features(idx:(idx+featParams.descriptorSize-1)) = euclideanDistance(desA, desB);
		idx = idx + featParams.descriptorSize;
	end

	if featParams.addGapSize
		features(idx:idx) = frameB - frameA;  % is always positive
		idx = idx + 1;
	end

	if featParams.addDirectionTheta
		% TODO

	end

	if featParams.addDirectionVariances
		
	end

	if featParams.addPosDistance
		features(idx:(idx+1)) = euclideanDistance(dotsA, dotsB);
		idx = idx + 2;
	end
end