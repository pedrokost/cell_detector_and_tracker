function features = computeTrackletMatchFeaturesForPair(trackletA, trackletB, I, featParams, numFeatures, dataParams)
	% COMPUTETRACKLETMATCHFEATURESFORPAIR Compute a spatio-temporal feature vector for two possibly interacting tracklets.
	% Inputs:
	% 	trackletA/trackletB = the row of the tracklets matrix concerning these two descriptors, BUT with POSITION information instead of indices
	%	I = a vector of the form [trackletA, frameA, fileA, cellIndexA, trackletB, frameB, fileB, cellIndexB]
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
	fileA    = I(3);
	frameB   = I(6);
	fileB    = I(7);
	cellIdxA = I(4);
	cellIdxB = I(8);

	dotsA = DSOUT.getDots(fileA, cellIdxA);
	dotsB = DSOUT.getDots(fileB, cellIdxB);
	dotsA = single(dotsA);
	dotsB = single(dotsB);

	% Tells you the ration of movement in the X and Y direction
	trackletA2D = single(permute(trackletA, [2 3 1]));
	trackletB2D = single(permute(trackletB, [2 3 1]));

	% I am not sure why I allow rows with zero values, instead of cropping. 
	% So I will crop here and see if its all still fine
	trackletA2DTrimmed = tracker.trimZeros(trackletA2D);
	trackletB2DTrimmed = tracker.trimZeros(trackletB2D);

	lenTrackletA = size(trackletA2D, 1);
	lenTrackletB = size(trackletB2D, 1);

	features = zeros(1, numFeatures);
	idx = 1;

	if featParams.addCellDescriptors
		desA = DSOUT.getDescriptors(fileA, cellIdxA);
		desB = DSOUT.getDescriptors(fileB, cellIdxB);
		% size(desA)
		dst = tracker.euclideanDistance(desA, desB);
		features(idx:(idx+featParams.descriptorSize-1)) = dst;
		idx = idx + featParams.descriptorSize;
		% features(idx:idx) = sum(dst);  % FIXME: Don't do this... disable features in detector instead
		% idx = idx + 1;
	end

	%------------------------Features that compare tracklets position in space
	if featParams.addGapSize
		features(idx:idx) = frameB - frameA;  % is always positive
		idx = idx + 1;
	end

	%---------------------Features that look at the tail and head of tracklets

	if featParams.addPosDistance
		features(idx:(idx+featParams.posDimensions-1)) = tracker.euclideanDistance(dotsA, dotsB);

		idx = idx + featParams.posDimensions;
	end

	if featParams.addPosDistanceSquared
		features(idx:(idx+featParams.posDimensions-1)) = (dotsA - dotsB).^2;

		idx = idx + featParams.posDimensions;
	end

	if featParams.addEuclidianDistance
		features(idx) = tracker.pointsDistance(dotsA, dotsB);

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

		[trackA nonzeroIdxA] = tracker.eliminateZeroRows(trackA);
		[trackB nonzeroIdxB] = tracker.eliminateZeroRows(trackB);

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

		trackA = tracker.getTail(trackletA2D, featParams.numCellsForDirectionVariances);
		trackB = tracker.getHead(trackletB2D, featParams.numCellsForDirectionVariances);

		trackA = tracker.eliminateZeroRows(trackA);
		trackB = tracker.eliminateZeroRows(trackB);

		cA = diag(cov(trackA));
		cB = diag(cov(trackB));

		if numel(cA) < 2 || isempty(find(cA))
			% FIXME: set to mean value, not 0 0 
			cA = [0;0];
		else
			cA = cA / norm(cA);
		end
		if numel(cB) < 2 || isempty(find(cB))
			% FIXME: set to mean value, not 0 0 
			cB = [0;0];
		else
			cB = cB / norm(cB);
		end

		if any(isnan(abs(cA - cB)))
			% TODO: can safely removes this at the end
			warning('A direction variance is NaN, why dont you fixe it?')
			keyboard
		end

		features(idx:(idx + featParams.posDimensions-1)) = abs(cA - cB)';
		idx = idx + featParams.posDimensions;
	end

	if featParams.addMeanDisplacement || featParams.addStdDisplacement

		% Linearly Interpolate the value where there are gaps
		trackA = tracker.interpolateTracklet(trackletA2D);
		trackB = tracker.interpolateTracklet(trackletB2D);

		trackA = tracker.getTail(trackA, featParams.numCellsForMeanAndStdDisplacement);
		trackB = tracker.getHead(trackB, featParams.numCellsForMeanAndStdDisplacement);

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

			if isnan(stdDiff)
				warning('Nan values in std diff, check it out')
				keyboard
			end

			features(idx:(idx + featParams.posDimensions-1)) = stdDiff;
			idx = idx + featParams.posDimensions;
		end
	end

	%----------------------------------Features that extrapolate the tracklets

	if featParams.addGaussianBroadeningEstimate
		trackA = tracker.interpolateTracklet(trackletA2D);
		trackB = tracker.interpolateTracklet(trackletB2D);

		trackA = tracker.getTail(trackA, featParams.numCellsForGaussianBroadeningVelocityEstimation);
		trackB = tracker.getHead(trackB, featParams.numCellsForGaussianBroadeningVelocityEstimation);

		gapSize = frameB - frameA;
		% TODO: redefine the 10, use the actual max gap between frames
		% TODO: the model generation could be performed before, so it is not recomputed several times

		% Use the actual gap between frames, but first make sure that it is better

		model = tracker.gaussianBroadeningModel(trackA, featParams.maxClosingGap);
		val = tracker.evaluateGaussianBroadeningModel(model, trackB);

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
	end


	if any(isnan(features))
		fprintf('There are NaN feature, why dont you fix it?\n');
		keyboard
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