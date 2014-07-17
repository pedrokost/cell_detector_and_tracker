function features = computeTrackletMatchFeaturesForPair(trackletA, trackletB, I, featParams, numFeatures)
	% COMPUTETRACKLETMATCHFEATURESFORPAIR Compute a spatio-temporal feature vector for two possibly interacting tracklets.
	% Inputs:
	% 	trackletA/trackletB = the row of the tracklets matrix concerning these two descriptors, BUT with POSITION information instead of indices
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

	%------------------------Features that compare tracklets position in space
	if featParams.addGapSize
		features(idx:idx) = frameB - frameA;  % is always positive
		idx = idx + 1;
	end

	%---------------------Features that look at the tail and head of tracklets

	if featParams.addPosDistance
		features(idx:(idx+featParams.posDimensions-1)) = euclideanDistance(dotsA, dotsB);
		idx = idx + featParams.posDimensions;
	end

	%---------------------------------------Features that look at past history

	if featParams.addDirectionTheta
		% TODO
	end

	if featParams.addDirectionVariances
		% Tells you the ration of movement in the X and Y direction
		tA = permute(trackletA, [2 3 1]);
		tB = permute(trackletB, [2 3 1]);

		% TODO: only use first/last N elements

		lA = size(tA, 1);
		lB = size(tB, 1);
		iA = min(lA, featParams.numCellsForDirectionVariances)-1;
		iB = min(lB, featParams.numCellsForDirectionVariances);

		tA = tA((lA-iA):lA, :);
		tB = tB(1:iB, :);

		% Remove zero rowsa
		tA = tA(all(tA ~= 0, 2), :);
		tB = tB(all(tB ~= 0, 2), :);

		cA = diag(cov(double(tA)));
		cB = diag(cov(double(tB)));

		if numel(cA) < 2
			cA = [0;0];
		end
		if numel(cB) < 2
			cB = [0;0];
		end

		cA = cA / norm(cA);
		cB = cB / norm(cB);

		features(idx:(idx + featParams.posDimensions-1)) = abs(cB - cB)';
		idx = idx + featParams.posDimensions;
	end
end