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
	dotsA = single(dotsA);
	dotsB = single(dotsB);


	% Tells you the ration of movement in the X and Y direction
	trackletA2D = single(permute(trackletA, [2 3 1]));
	trackletB2D = single(permute(trackletB, [2 3 1]));

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

		% FIXME: This below should results in the same values
		% [trackletA2D(end, :) trackletB2D(1, :)]
		% [dotsA, dotsB]
		% '-------------------'
		idx = idx + featParams.posDimensions;
	end

	if featParams.addPosDistanceSquared
		features(idx:(idx+featParams.posDimensions-1)) = (dotsA - dotsB).^2;

		idx = idx + featParams.posDimensions;
	end



	%---------------------------------------Features that look at past history

	if featParams.addDirectionTheta
		lA = size(trackletA2D, 1);
		lB = size(trackletB2D, 1);
		iA = min(lA, featParams.numCellsToEstimateDirectionTheta)-1;
		iB = min(lB, featParams.numCellsToEstimateDirectionTheta);

		trackletA2D2 = trackletA2D((lA-iA):lA, :);
		trackletB2D2 = trackletB2D(1:iB, :);

		% FIXME: Define what to say about the angle when an item has length of 1. Should it be assumed perfect match? angleDiff = 0? NaN?;

		% Remove zero rowsa
		trackletA2D2 = trackletA2D2(all(trackletA2D2 ~= 0, 2), :);
		trackletB2D2 = trackletB2D2(all(trackletB2D2 ~= 0, 2), :);

		trackletA2D2 = trackletA2D2(2:end, :) - trackletA2D2(1:end-1, :);
		trackletB2D2 = trackletB2D2(2:end, :) - trackletB2D2(1:end-1, :);

		trackletA2D2 = atan2(trackletA2D2(:, 1), trackletA2D2(:, 2));
		trackletB2D2 = atan2(trackletB2D2(:, 1), trackletB2D2(:, 2));

		angA = mean(trackletA2D2);
		angB = mean(trackletB2D2);

		features(idx:idx) = angB - angA;
		idx = idx + 1;
	end

	if featParams.addDirectionVariances
		lA = size(trackletA2D, 1);
		lB = size(trackletB2D, 1);
		iA = min(lA, featParams.numCellsForDirectionVariances)-1;
		iB = min(lB, featParams.numCellsForDirectionVariances);

		trackletA2D2 = trackletA2D((lA-iA):lA, :);
		trackletB2D2 = trackletB2D(1:iB, :);

		% Remove zero rowsa
		trackletA2D2 = trackletA2D2(all(trackletA2D2 ~= 0, 2), :);
		trackletB2D2 = trackletB2D2(all(trackletB2D2 ~= 0, 2), :);

		cA = diag(cov(trackletA2D2));
		cB = diag(cov(trackletB2D2));

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