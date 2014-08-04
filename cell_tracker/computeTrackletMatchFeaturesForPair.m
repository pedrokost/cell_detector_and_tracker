function features = computeTrackletMatchFeaturesForPair(trackletA, trackletB, I, featParams, numFeatures, dataParams)
	% COMPUTETRACKLETMATCHFEATURESFORPAIR Compute a spatio-temporal feature vector for two possibly interacting tracklets.
	% Inputs:
	% 	trackletA/trackletB = the row of the tracklets matrix concerning these two descriptors, BUT with POSITION information instead of indices
	%	I = a vector of the form [trackletA, frameA, cellIdxA, trackletB, frameB, cellindexB]
	%		trackletA/trackletB = the index of the tracklet
	%		frameA/frameB = the frame number where trackletA ends and trackletB starts
	%		cellIdxA/cellindexB = the indices of the cells within the corresponding frames
	% 	featParams = a structure with parameters for building the feature vector. See setFeatures()
	% 	numFeatures = the number of features in the final descriptor
	% 	dataParams = a struct containing
	%		imageDimensions = a 2d vector contining the height and width of the source images
	% 	DSOUT = a Global datastore for data in outFolder
	% Outputs:
	% 	features = a feature vector of the two intracting tracklets

	% Compting with uint16 or other returns wrong answers to many math problems
	trackletA = single(trackletA);
	trackletB = single(trackletB);

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

	lenTrackletA = size(trackletA2D, 1);
	lenTrackletB = size(trackletB2D, 1);

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
		features(idx:(idx+featParams.posDimensions-1)) = (dotsA - dotsB).^2;

		idx = idx + featParams.posDimensions;
	end

	if featParams.addEuclidianDistance
		features(idx) = pointsDistance(dotsA, dotsB);

		idx = idx + 1;
	end

	if featParams.addDistanceFromEdge
		% For each tracklet, the distance to the closest image edge
		min_xyA = min(min(dotsA, abs(fliplr(dataParams.imageDimensions)-dotsA)));
		min_xyB = min(min(dotsB, abs(fliplr(dataParams.imageDimensions)-dotsB)));
		
		features(idx:idx) = min_xyA;
		idx = idx + 1;
		features(idx:idx) = min_xyB;
		idx = idx + 1;
	end

	%---------------------------------------Features that look at past history
	if featParams.addDirectionTheta

		trackA = getTail(trackletA2D, featParams.numCellsToEstimateDirectionTheta);
		trackB = getHead(trackletB2D, featParams.numCellsToEstimateDirectionTheta);

		[trackA nonzeroIdxA] = eliminateZeroRows(trackA);
		[trackB nonzeroIdxB] = eliminateZeroRows(trackB);

		% REVIEW: Define what to say about the angle when an item has length of 1. Should it be assumed perfect match? angleDiff = 0? NaN?;

		% Compute the differences of movement between successive frames
		trackA = computeBetweenFrameDistances(trackA);
		trackB = computeBetweenFrameDistances(trackB);

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

			% FIXME: set to mean value, not 0 0 
			cA = [0;0];
		else
			cA = cA / norm(cA);
		end
		if numel(cB) < 2
			% FIXME: set to mean value, not 0 0 
			cB = [0;0];
		else
			cB = cB / norm(cB);
		end

		features(idx:(idx + featParams.posDimensions-1)) = abs(cA - cB)';
		idx = idx + featParams.posDimensions;
	end

	if featParams.addMeanDisplacement || featParams.addStdDisplacement

		% Linearly Interpolate the value where there are gaps
		if lenTrackletA > 1
			[trackA, nonzeroIdx] = eliminateZeroRows(trackletA2D);

			if any(nonzeroIdx == 0)
				trackA = interp1(find(nonzeroIdx), trackA, (1:lenTrackletA)');
			else
				trackA = trackletA2D;
			end
		else
			trackA = trackletA2D;
		end

		if lenTrackletB > 1
			[trackB, nonzeroIdx] = eliminateZeroRows(trackletB2D);

			if any(nonzeroIdx == 0)
				trackB = interp1(find(nonzeroIdx), trackB, (1:lenTrackletB)');
			else
				trackB = trackletB2D;
			end
		else
			trackB = trackletB2D;
		end

		trackA = getTail(trackA, featParams.numCellsForMeanAndStdDisplacement);
		trackB = getHead(trackB, featParams.numCellsForMeanAndStdDisplacement);

		% Compute successive distances
		trackA = computeBetweenFrameDistances(trackA);
		trackB = computeBetweenFrameDistances(trackB);

		if lenTrackletA == 1 
			trackA = zeros(1, featParams.posDimensions);
		end

		if lenTrackletB == 1
			trackB = zeros(1, featParams.posDimensions);
		end

		if featParams.addMeanDisplacement
			if lenTrackletA > 1
				meanDiff = mean(trackA, 1) - mean(trackB, 1);
			else
				% FIXME: Instead, mark it as special, and set it to the mean value
				meanDiff = zeros(1, featParams.posDimensions);
			end

			if isnan(meanDiff)
				warning('Nan values in mean diff, check it out')
				keyboard
			end

			features(idx:(idx + featParams.posDimensions-1)) = meanDiff;
			idx = idx + featParams.posDimensions;
		end

		if featParams.addStdDisplacement
			if lenTrackletA > 1
				stdDiff = std(trackA, 1) - std(trackB, 1);
			else
				% FIXME: instead set it to the mean value
				stdDiff = zeros(1, featParams.posDimensions);
			end
			features(idx:(idx + featParams.posDimensions-1)) = stdDiff;
			idx = idx + featParams.posDimensions;
		end
	end

	%----------------------------------Features that extrapolate the tracklets

	if featParams.addGaussianBroadeningEstimate
		trackA = trackletA2D;
		if lenTrackletA > 1
			[trackA, nonzeroIdx] = eliminateZeroRows(trackletA2D);

			if any(nonzeroIdx == 0)
				trackA = interp1(find(nonzeroIdx), trackA, (1:lenTrackletA)');
			end
		end

		trackB = trackletB2D;
		if lenTrackletB > 1
			[trackB, nonzeroIdx] = eliminateZeroRows(trackletB2D);

			if any(nonzeroIdx == 0)
				trackB = interp1(find(nonzeroIdx), trackB, (1:lenTrackletB)');
			end
		end

		trackA = getTail(trackA, featParams.numCellsForGaussianBroadeningVelocityEstimation);
		trackB = getHead(trackB, featParams.numCellsForGaussianBroadeningVelocityEstimation);

		gapSize = frameB - frameA;
		% TODO: redefine the 10, use the actual max gap between frames
		% TODO: the model generation could be performed before, so it is not recomputed several times
		model = gaussianBroadeningModel(trackA, featParams.maxClosingGap);
		val = evaluateGaussianBroadeningModel(model, trackB);

		features(idx:idx) = val;
		idx = idx + 1;

		if isfield(dataParams, 'showGaussianBroadening')
			% minx = min(trackA(:, 1)) - 50;
			% maxx = max(trackA(:, 1)) + 50;
			% miny = min(trackA(:, 2)) - 50;
			% maxy = max(trackA(:, 2)) + 50;

			% resolution = 150;
			% [X1,X2] = meshgrid(linspace(minx, maxx,resolution)',...
			% 				   linspace(miny, maxy,resolution)');
			% X = [X1(:) X2(:)];

			% [val, pointsVals] = evaluateGaussianBroadeningModel(model, X);
			% clf;
			% contour(X1, X2, reshape(pointsVals,resolution, resolution)); axis equal; axis tight;
			% hold on;
			% plot(trackA(:, 1), trackA(:, 2), 'ro-');  axis equal; axis tight; 
			% hold on;
			% plot(model.mus(:, 1), model.mus(:, 2), 'rx--');  axis equal; axis tight;
			% hold on;
			% plot(trackB(:, 1), trackB(:, 2), 'bo-');  axis equal; axis tight;
	 
			% xlabel('x');
			% ylabel('y');

			% pause
		end


		if any(isnan(features))
			fprintf('There are NaN feature, why dont you fix it?\n');
			keyboard
		end

	end

	function dists = computeBetweenFrameDistances(tracklet2D)
		% Compute the differences of movement between successive frames
		% Inputs:
		% 	tracklet2D = a row matrix of cell positions
		% Outputs:
		% 	dists = a row matrix of distances containing N - 1 rows

		dists = tracklet2D(2:end, :) - tracklet2D(1:end-1, :);
	end



end