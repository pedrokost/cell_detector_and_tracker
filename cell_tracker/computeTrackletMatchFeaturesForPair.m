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

		idx = idx + featParams.posDimensions;
	end

	if featParams.addPosDistanceSquared
		features(idx:(idx+featParams.posDimensions-1)) = (dotsA - dotsB).^4;

		idx = idx + featParams.posDimensions;
	end

	%---------------------------------------Features that look at past history

	if featParams.addDirectionTheta

		trackA = getTail(trackletA2D, featParams.numCellsToEstimateDirectionTheta);
		trackB = getHead(trackletB2D, featParams.numCellsToEstimateDirectionTheta);

		[trackA nonzeroIdxA] = eliminateZeroRows(trackA);
		[trackB nonzeroIdxB] = eliminateZeroRows(trackB);

		% REVIEW: Define what to say about the angle when an item has length of 1. Should it be assumed perfect match? angleDiff = 0? NaN?;

		% Compute the differences of movement between successive frames
		trackA = trackA(2:end, :) - trackA(1:end-1, :);
		trackB = trackB(2:end, :) - trackB(1:end-1, :);

		% Compute the direction angle between each frames
		trackA = atan2(trackA(:, 1), trackA(:, 2));
		trackB = atan2(trackB(:, 1), trackB(:, 2));

		% Get the mean
		angA = mean(trackA);
		angB = mean(trackB);

		% If one of the tracks has just 1 cell, assume perfect match
		if isnan(angA)
			angA = angB;
		elseif isnan(angB)
			angB == angA;
		end	

		if any([isnan(angA) isnan(angB)])
			features(idx:idx) = 0; % perfect = 0
		else
			features(idx:idx) = angB - angA;
		end

		idx = idx + 1;
	end

	if featParams.addDirectionVariances

		trackA = getTail(trackletA2D, featParams.numCellsForDirectionVariances);
		trackB = getHead(trackletB2D, featParams.numCellsForDirectionVariances);

		trackA = eliminateZeroRows(trackA);
		trackB = eliminateZeroRows(trackB);

		cA = diag(cov(trackA));
		cB = diag(cov(trackB));

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

	if featParams.addMeanDisplacement || featParams.addStdDisplacement

		% Only use the data where there are no gaps. If gap, start a new subgroup
		% and finally average the results


		% I start working on this feature now, but after I need to fix the caused in the above comments 

		% lA = size(trackletA2D, 1);
		% lB = size(trackletB2D, 1);
		% iA = min(lA, featParams.numCellsForDirectionVariances)-1;
		% iB = min(lB, featParams.numCellsForDirectionVariances);

		% trackletA2D2 = trackletA2D((lA-iA):lA, :);
		% trackletB2D2 = trackletB2D(1:iB, :);

		% % Remove zero rowsa
		% trackletA2D2 = trackletA2D2(all(trackletA2D2 ~= 0, 2), :);
		% trackletB2D2 = trackletB2D2(all(trackletB2D2 ~= 0, 2), :);

		% cA = diag(cov(trackletA2D2));
		% cB = diag(cov(trackletB2D2));

		% if numel(cA) < 2
		% 	cA = [0;0];
		% end
		% if numel(cB) < 2
		% 	cB = [0;0];
		% end

		% cA = cA / norm(cA);
		% cB = cB / norm(cB);

		% features(idx:(idx + featParams.posDimensions-1)) = abs(cB - cB)';
		% idx = idx + featParams.posDimensions;
	end


end