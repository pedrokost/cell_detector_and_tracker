function prepareFeatureMatrixForRobustMatcher(options)
	%{
		This script prepares a matrix containing pairs of cell descriptors and a third objective column indicating if they are the same (that is if the cells are DIRECTLY linked)

		The descriptors are obtained from the cell_detector as a by-product of detecting cells. Additionally a cell location is concatenated to that vector.

		The objective column is obtained from the user annotations of links in the dataset. It is important for the purpose of learning a good matcher that the annotations are as complete possible. 
	%}

	global DSOUT;

	doPlot = false;

	fprintf('Preparing data for training robust classifier.\n')

	tracklets = tracker.generateTracklets('in', struct('withAnnotations', true));

	trackletFile = sprintf('%s_annotations.mat', options.trajectoriesOutputFile);
	save(trackletFile, 'tracklets');

	if doPlot
		clf;
		subplot(1,2,1); tracker.trackletViewer(tracklets, 'in', struct('minLength', 0, 'showLabels', false));
	end

	% Convert these to detection tracklets
	tracklets = tracker.convertAnnotationToDetectionIdx(tracklets);
	annotationIndices = DSOUT.getMatfileIndices();
	trackletFile = sprintf('%s_mappeddetections.mat', options.trajectoriesOutputFile);
	save(trackletFile, 'tracklets');

	% Elimintate tracklets of length 1
	tracklets = tracker.filterTrackletsByLength(tracklets, 2);

	[~, numFrames] = size(tracklets);

	[dotsA, descriptorsA] = DSOUT.get(annotationIndices(1));
	[descriptorsA, ~] = tracker.combineDescriptorsWithDots(descriptorsA, double(dotsA));
	actA = tracklets(:, 1) > 0;

	nFeatures = size(descriptorsA, 2);
	X = [];
	numElimintated = 0; % due to proximity

	for i=2:numFrames
		[dotsB, descriptorsB] = DSOUT.get(annotationIndices(i));

		[descriptorsB, ~] = tracker.combineDescriptorsWithDots(descriptorsB, double(dotsB));

		%----------------------------------------------------Positive examples

		% each item in A that has continuation in B
		hasContinuation = all(tracklets(:, i-1:i) > 0, 2);
		% [tracklets(:, i-1:i) hasContinuation]

		positivePairs = tracklets(hasContinuation, i-1:i);

		dA = descriptorsA(positivePairs(:, 1), :);
		dB = descriptorsB(positivePairs(:, 2), :);

		numPairs = numel(find(hasContinuation));
		M = zeros(numPairs, nFeatures + 1);

		M(:, 1:end-1) = tracker.euclideanDistance(dA, dB);
		M(:, end) = ones(numPairs, 1);

		X = vertcat(X, M);

		%----------------------------------------------------Negative examples

		
		actB = tracklets(:, i) > 0;
		
		negativePairs = combvec(tracklets(actA, i-1)', tracklets(actB, i)')';
		[~, Locb] = ismember(positivePairs, negativePairs, 'rows');

		negativePairs(Locb, :) = [];

		filterNegativePairs();

		dA = descriptorsA(negativePairs(:, 1), :);
		dB = descriptorsB(negativePairs(:, 2), :);

		numPairs = size(negativePairs, 1);
		M = zeros(numPairs, nFeatures + 1);

		M(:, 1:end-1) = tracker.euclideanDistance(dA, dB);
		X = vertcat(X, M);


		descriptorsA = descriptorsB; actA = actB; dotsA = dotsB;
	end

	fprintf('\tElimintated %d negative cell pairs from negative examples due to proximity.\n', numElimintated);

	% TODO: randomize order
	cntNeg = sum(X(:, end) == 0);
	cntPos = size(X, 1) - cntNeg;

	if cntNeg == 0 || cntPos == 0
		error('Please annotate the dataset with links. I cannot learn if you dont teach me properly.');
	end

	% go by each frame pairs
	% and get the data descriptors
	% and create the positive and negative example matrix
	% by traking into account not to add as negative if the tail/head are too close

	if doPlot
		subplot(1,2,2); tracker.trackletViewer(tracklets, 'out', struct('minLength', 0, 'showLabels', false));
	end

	fprintf('Done preparing robust matcher data based on %d links.\n', cntPos);
	% options.outputFileMatrix
	save(options.outputFileMatrix, 'X');

	function filterNegativePairs()
		% Given two consecutive frames A and B, and a pair of negative cell pairs
		% indices, eliminate those that are likely to be continuation of each other
		% in order to prevent learning bad stuff if the annoations are less than
		% complete.

		% TODO: I could speed this up by not passing any arguments, since they
		% share the same workspace with the parent function

		reorderedDotsA = dotsA(negativePairs(:, 1), :);
		reorderedDotsB = dotsB(negativePairs(:, 2), :);

		distances = tracker.pointsDistance(int16(reorderedDotsA), int16(reorderedDotsB));

		lessthan50 = (distances < options.MIN_TRACKLET_SEPARATION); % use parameter
		if any(lessthan50)
			negativePairs(lessthan50, :) = [];
			numElimintated = numElimintated + numel(find(lessthan50));
		end
	end
end