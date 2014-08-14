function prepareFeatureMatrixForLinkerMatcher(outputFile, params)
	%{
		This script prepares a matrix containing pairs of cell descriptors and a third objective column indicating if they are the same (that is if the cells are DIRECTLY or UNDIRECTLY (through several links) linked)

		The descriptors are obtained from the cell_detector as a by-product of detecting cells. Additionally a cell location is concatenated to that vector.

		The objective column is obtained from the user annotations of links in the dataset. It is important for the purpose of learning a good matcher that the annotations are as complete possible. 
	%}
	doProfile = false;

	if doProfile
		profile on % -memory 
	end
	classifierParams = params.linkerClassifierParams;

	global DSIN DSOUT;

	fprintf('Identifying all tracklets pairs for the feature matrix to train Linker\n')

	tracklets = generateTracklets('in', struct('withAnnotations', true));

	% Only use the correctly annoated frames for training: trim the matrix
	tracklets = tracklets(:, 1:params.numAnnotatedFrames);


	tracklets = filterTrackletsByLength(tracklets, classifierParams.MIN_TRACKLET_LENGTH);
	
	clf;
	% trackletViewer(tracklets, 'in'); fprintf('Press any key to continue\n');pause;
	[numTracklets, numFrames] = size(tracklets);

	% For each tracklets, find the corresponding dots in the OUT folder
	tracklets = convertAnnotationToDetectionIdx(tracklets);

	hold on; trackletViewer(tracklets, 'out'); fprintf('Press any key to continue\n'); pause;


	Y = zeros(0, 1, 'uint8'); %[match/no-match]
	I = zeros(0, 4, 'uint16'); % [trackletA, frameA, trackletB, frameB]
	% Note: the frameA and frameB are as put in the matrix tracklets, they have to be 
	% mapped tot the correct filenames before their values can be read from disk, 
	% because some frames can be skipped

	% First append all positive examples:
	% cells in same tracklets with max distance of MAX_GAP
	fprintf('Positive examples include tracklets pairs less than %d frames apart\n\n', classifierParams.MAX_GAP);

	for t=1:numTracklets
		idx = find(tracklets(t, :));
		vals = tracklets(t, idx);

		% Do not try to split tracklets with only 1 element, don't add those
		if numel(idx) < 2
			continue
		end

		% only keep frames that are not to far apart
		C = combnk(idx, 2); D = C(:, 2) - C(:, 1);
		keepIdx = D <= classifierParams.MAX_GAP;

		C = C(keepIdx, :);

		% TODO: random sample just a portion of the cases

		n = size(C, 1);
		tVec = repmat(t, n, 1);

		new = [tVec C(:, 1) tVec C(:, 2)];
		I = [I; new];
		Y = [Y; ones(size(C, 1), 1)];
	end

	% findall possible tracklets combinations
	trackletCombos = combnk(1:numTracklets, 2);

	if classifierParams.notNegativeIfPossibleContinuation
		trackletCombos = eliminateAmbiguousRows(tracklets, trackletCombos, classifierParams);
	end

	pause


	% TODO: train also on parallel tracklets, on the segments that make sense.

	% I = [I; [1 18 5 28]];
	% Y = [Y; 0];

	for i=1:size(trackletCombos, 1)
		trackletA = tracklets(trackletCombos(i, 1), :);
		trackletB = tracklets(trackletCombos(i, 2), :);

		clf;
		subplot(1,2,1);trackletViewer([trackletA;trackletB], 'out');
		
		[trackletA, trackletB] = getUsefulTrackletsPair(trackletA, trackletB);

		% TODO check length ok
		% TODO check not too close here

		subplot(1,2,2);trackletViewer([trackletA;trackletB], 'out');


		% only take the non overlapping instances

		idxA = find(trackletA);
		idxB = find(trackletB);
		% For each cell in each tracklet
		% take all other cells in opposite tracklet
		C = combvec(idxA, idxB);
		n = size(C, 2);
		tVecA = repmat(trackletCombos(i, 1), 1, n);
		tVecB = repmat(trackletCombos(i, 2), 1, n);

		% TODO random sample, to prevent overfitting

		new = [tVecA; C(1, :); tVecB; C(2, :)]'

		pauseIt();

		I = [I; new];
		Y = [Y; zeros(size(C, 2), 1)];
		% and set it a negative example
	end

	clear new C D cnt i idx idxA idxB t trackletA trackletB vals;

	% % FIXME: remove this
	% I = I(1:100, :);
	% Y = Y(1:100, :);

	n = numel(Y);
	perm = randperm(n);
	I = I(perm, :);
	Y = Y(perm);

	fprintf('There are %d positive and %d negative examples.\nThe ratio of positive to negative examples is 1:%.1f.\n', sum(Y==1), sum(Y==0), sum(Y==0)/sum(Y==1))

	if sum(Y==1)==0
		error('The training data is bad. There are not positive examples');
	end

	if sum(Y==0)==0
		error('The training data is bad. There are not negative examples');
	end

	% Using the matrix, create a new matrix containing the difference of histograms
	% with the objective function

	[featParams, numFeatures] = setFeatures();

	X = zeros(n, numFeatures, 'single');

	tracklets2 = trackletsToPosition(tracklets, 'out');


	fprintf('Preparing large matrix with training data for linker\n')

	I = convertIToContainTheCellIndices(tracklets, I);
	I = addActualFileIndices(I);

	for i=1:n
		% [trackletA, frameA, fileA, cellIndexA, trackletB, frameB, fileB cellIndexB]

		trackletAPos = tracklets(I(i, 1),  :);
		trackletBPos = tracklets(I(i, 5), :);

		trackletAIdx = find(trackletAPos);
		trackletBIdx = find(trackletBPos);
		
		trackletA = tracklets2(I(i, 1), trackletAIdx(1):I(i, 2), :);
		trackletB = tracklets2(I(i, 5), I(i, 6):trackletBIdx(end), :);

		features = computeTrackletMatchFeaturesForPair(trackletA, trackletB, I(i, :), featParams, numFeatures, params);

		X(i, :) = features;
	end

	save(outputFile, 'X', 'Y')

	if doProfile
		profile off
		profile viewer
	end
end

function [trackletA, trackletB, discard] = getUsefulTrackletsPair(trackletA, trackletB)
	% Only select the tracklet portions that do not overlap, that is if:
	% 1. |
	% 2. |
	% 3. |
	% 4. |
	% 5. | |
	% 6. | | 
	% 7. | |
	% 8. | |
	% 9. | |
	% 10.  |
	% Select for the first tracklets the longer first part until the beginning of the second tracklet
	% and for the second tracklet all of it
	%

	idxA = find(trackletA ~= 0);
	idxB = find(trackletB ~= 0);

	% Cases:

	% 1) One tracklet after the other
	% -----
	%         -----
	% Resolution: take both tracklets as they are

	if noOverlap(idxA, idxB)
		return;
	end

	% 2) One tracklet partially cover the head/tail of the other
	%  ------
	%     ------
	% Resolution: take the shortest tracklet as it is, trim the longer one

	if partialOverlap(idxA, idxB)
		[min_len, selected] = min([numel(idxA), numel(idxB)]);
		% 'partialOverlap'

		if selected == 1  % shortest is trackletA
			if idxA(1) < idxB(1) % A is before B
				trackletB(idxB(1):idxA(end)) = 0;
			else % B is before A
				trackletB(idxA(1):idxB(end)) = 0;
			end
		else % shortest is trackletB
			if idxA(1) < idxB(1) % A is before B
				trackletA(idxB(1):idxA(end)) = 0;
			else % B is before A
				trackletA(idxA(1):idxB(end)) = 0;
			end
		end
			
		return;
	end


	% 3) One tracklet covers all of the other tracklet
	% -----------------------
	%     ----------
	% Resolution: keep the shorter tracklet as it is, from the longer one only take the longest part that is not covered

	if fullOverlap(idxA, idxB)
		[min_len, selected] = min([numel(idxA), numel(idxB)]);

		if selected == 1  % shortest is trackletA
			bottomPart = numel(trackletB(idxB(1):idxA(1)))
			topPart = numel(trackletB(idxA(end):idxB(end)))

			if bottomPart >= topPart
				trackletB(idxA(1):idxB(end)) = 0;
			else
				trackletB(idxB(1):idxA(end)) = 0;
			end
		else % shortest is trackletB
			bottomPart = numel(trackletA(idxA(1):idxB(1)))
			topPart = numel(trackletA(idxB(end):idxA(end)))

			if bottomPart >= topPart
				trackletA(idxB(1):idxA(end)) = 0;
			else
				trackletA(idxA(1):idxB(end)) = 0;
			end
		end
		
		return;
	end

	function yesno = noOverlap(idxA, idxB)
		yesno = (idxA(end) < idxB(1)) || (idxB(end) < idxA(1));
	end

	function yesno = partialOverlap(idxA, idxB)
		yesno = ((idxA(1)<idxB(1)) && (idxA(end) < idxB(end))) || ...
				((idxB(1)<idxA(1)) && (idxB(end) < idxA(end)));
	end

	function yesno = fullOverlap(idxA, idxB)
		yesno = ((idxA(1)<=idxB(1)) && (idxA(end) >= idxB(end))) || ...
				((idxB(1)<=idxA(1)) && (idxB(end) >= idxA(end)));
	end

	

end

function I2 = convertIToContainTheCellIndices(tracklets, I)
	% Explands I=[trackletA, frameA, trackletB, frameB] to be:
	% I=[trackletA, frameA, cellIndexA trackletB, frameB, cellIndexB]

	% Note: must be called with the frameA and frameB ampping to the tracklets matrix, not the files indices

	numObs = size(I, 1);
	I2 = zeros(numObs, 6);
	I2(:, [1 2 4 5]) = I;

	for i=1:numObs
		I2(i, 3) = tracklets(I(i, 1), I(i, 2));
		I2(i, 6) = tracklets(I(i, 3), I(i, 4));
	end
end


function trackletCombos2 = eliminateAmbiguousRows(tracklets, trackletCombos, linkerParams)

	trackletViewer(tracklets, 'out')
	% Elimintate tracklet pairs if they are more than max distance apart
	% Elimintate tracklet pairs if the tracklets are in very close locations
	trackletCombos2 = zeros(0, 2);
	tracklets2 = single(trackletsToPosition(tracklets, 'out'));

	numEliminatedDueToShortness = 0;
	numEliminatedDueToParallelism = 0;
	numEliminatedDueToProximity = 0;

	for i=1:size(trackletCombos, 1)
		trackA = tracklets(trackletCombos(i, 1), :);
		trackB = tracklets(trackletCombos(i, 2), :);
		trackAidx = find(trackA);
		trackBidx = find(trackB);

		if numel(trackAidx) < 2 || numel(trackBidx) < 2
			numEliminatedDueToShortness = numEliminatedDueToShortness + 1;
			continue;
		end

		% % Skip tracklets that can't be linked anyway, because I never evaluate such examples
		% if trackAidx(end) >= trackBidx(1);
		% 	numEliminatedDueToParallelism = numEliminatedDueToParallelism + 1;
		% 	continue;
		% end

		tailA = tracklets2(trackletCombos(i, 1), trackAidx(end), :);
		headB = tracklets2(trackletCombos(i, 2), trackBidx(1), :);
		tailA = permute(tailA, [2 3 1]);
		headB = permute(headB, [2 3 1]);
		dist = pointsDistance(tailA, headB);

		% fprintf('Dist between %d (%d, %d) and %d (%d, %d) is %f\n', trackletCombos(i, 1), tailA, trackletCombos(i, 2), headB, dist);

		if dist > linkerParams.MIN_TRACKLET_SEPARATION
			trackletCombos2 = vertcat(trackletCombos2, trackletCombos(i, :));
		else
			numEliminatedDueToProximity = numEliminatedDueToProximity + 1;
		end
	end

	fprintf('Dicarded %d tracklet combinations as negative results due to their shortness, %d due to them not being follow-up tracklets (are parallel), and %d because their head/tail where too close\n\n', numEliminatedDueToShortness, numEliminatedDueToParallelism, numEliminatedDueToProximity);

	% pause
	% For each tracklet pair get the tail and gea
	% and OK it only if the distance is ok
end