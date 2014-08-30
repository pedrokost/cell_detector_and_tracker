function prepareFeatureMatrixForLinkerMatcher(outputFile, params, leaveoneout)
	%{
		This script prepares a matrix containing pairs of cell descriptors and a third objective column indicating if they are the same (that is if the cells are DIRECTLY or UNDIRECTLY (through several links) linked)

		The descriptors are obtained from the cell_detector as a by-product of detecting cells. Additionally a cell location is concatenated to that vector.

		The objective column is obtained from the user annotations of links in the dataset. It is important for the purpose of learning a good matcher that the annotations are as complete possible. 
	%}
	doProfile = false;
	doPlot = false;
	trainWithAllCombos = false;

	if nargin < 3
		leaveoneout = 0;
	end

	if doProfile
		profile on % -memory 
	end
	classifierParams = params.linkerClassifierParams;

	global DSIN DSOUT;


	fprintf('Preparing data for training linker classifier.\n')

	tracklets = tracker.generateTracklets('in', struct('withAnnotations', true));

	% Only use the correctly annoated frames for training: trim the matrix
	% NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO, never do this
	% tracklets = tracklets(:, 1:params.numAnnotatedFrames);
	% size(tracklets)

	annotationIndices = DSOUT.getMatfileIndices();

	tracklets = tracker.filterTrackletsByLength(tracklets, classifierParams.MIN_TRACKLET_LENGTH);

	if leaveoneout > 0
		% Elimintae longest tracklet
		lengths = trackletsLengths(tracklets);
		[~, sortIdx] = sort(lengths, 'descend');
		tracklets = tracklets(sortIdx, :);
		tracklets(leaveoneout, :) = []; 
		fprintf('\tSkipped %d-th longest tracklet.\n', leaveoneout);
	end

	
	if doPlot; clf; end
	% trackletViewer(tracklets, 'in');
	[numTracklets, numFrames] = size(tracklets);

	% For each tracklets, find the corresponding dots in the OUT folder
	tracklets = tracker.convertAnnotationToDetectionIdx(tracklets);

	if doPlot
		hold on; tracker.trackletViewer(tracklets, 'out');
	end

	Y = zeros(0, 1, 'uint8'); %[match/no-match]
	I = zeros(0, 4, 'uint16'); % [trackletA, frameA, trackletB, frameB]
	% Note: the frameA and frameB are as put in the matrix tracklets, they have to be 
	% mapped tot the correct filenames before their values can be read from disk, 
	% because some frames can be skipped

	% First append all positive examples:
	% cells in same tracklets with max distance of MAX_GAP
	fprintf('	Positive examples include tracklets pairs less than %d frames apart.\n', classifierParams.MAX_GAP);

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

		% INFO: This is experimental:
		% Only adds the combination if the max displacement is below a certain threshold
		% This might become uneccessary if I use a kalman filter to predict location, since large displacement would probably return worse results
		news = zeros(0, 4, 'uint16');

		for i=1:size(C, 1)
			tail = DSOUT.getDots(annotationIndices(C(i, 1)), tracklets(t, C(i, 1)));
			head = DSOUT.getDots(annotationIndices(C(i, 2)), tracklets(t, C(i, 2)));

			dist = tracker.pointsDistance(tail, head);
			if dist <= classifierParams.MAX_TRAINING_DISPLACEMENT
				new = [t C(i, 1) t C(i, 2)];
				news = vertcat(news, new);
			% else
			% 	disp([t C(i, 1) t C(i, 2)])
			end
		end
		I = [I; news];
		Y = [Y; ones(size(news, 1), 1)];
	end

	% findall possible tracklets combinations
	trackletCombos = combnk(1:numTracklets, 2);

	% I = [I; [1 18 5 28]];
	% Y = [Y; 0];

	% Elimintate tracklet pairs if they are more than max distance apart
	% Elimintate tracklet pairs if the tracklets are in very close locations
	numEliminatedDueToShortness = 0;
	numEliminatedDueToProximity = 0;

	for i=1:size(trackletCombos, 1)
		trackletA = tracklets(trackletCombos(i, 1), :);
		trackletB = tracklets(trackletCombos(i, 2), :);

		% only take the non overlapping segments of the tracklet pairs
		[trackletA, trackletB] = getUsefulTrackletsPair(trackletA, trackletB);

		idxA = find(trackletA);
		idxB = find(trackletB);

		% FIXME: This is just a temporary hack until getUsefulTrackletsPair is improved
		if any([isempty(idxA) isempty(idxB)])
			continue;
		end

		%  Makus sure that trackletA is before trackletB always
		if idxA(1) > idxB(1)
			tmp = trackletA;
			trackletA = trackletB;
			trackletB = tmp;

			tmp = idxA;
			idxA = idxB;
			idxB = tmp;

			trackletCombos(i, :) = fliplr(trackletCombos(i, :));
		end

		if numel(idxA) < 2 || numel(idxB) < 2
			numEliminatedDueToShortness = numEliminatedDueToShortness + 1;
			continue;
		end

		trackletATail = DSOUT.getDots(annotationIndices(idxA(end)), trackletA(idxA(end)));
		trackletBHead = DSOUT.getDots(annotationIndices(idxB(1)), trackletB(idxB(1)));
		dist = tracker.pointsDistance(trackletATail, trackletBHead);

		if dist < classifierParams.MIN_TRACKLET_SEPARATION
			% 'too close'
			numEliminatedDueToProximity = numEliminatedDueToProximity + 1;
			continue;
		end

		% clf;
		% trackletViewer([trackletA;trackletB], 'out');


		% For each cell in each tracklet
		% take all other cells in opposite tracklet

		% TODO: instead of computing all the combos, try to compute using only the actualy tracklets

		if trainWithAllCombos

			C = combvec(idxA, idxB);
			n = size(C, 2);
			tVecA = repmat(trackletCombos(i, 1), 1, n);
			tVecB = repmat(trackletCombos(i, 2), 1, n);

			% TODO random sample, to prevent overfitting

			% TODO: dont add if distance more than MAX_GAP
			new = [tVecA; C(1, :); tVecB; C(2, :)]';

			I = [I; new];
			Y = [Y; zeros(size(C, 2), 1)];
			% and set it a negative example
		else
			% Train with possibly connecting tracklets,
			% and segments that could connect (instead of all combinations)

			% Add the end of TA and start of TB as negative examples

			% TODO: dont add if distance more than MAX_GAP: Why not, I only 
			% loose an example. Maybe MAX_GAP is not a good training feature

			new = [trackletCombos(i, 1), idxA(end), trackletCombos(i, 2), idxB(1)];
			I = [I; new];
			Y = [Y; 0];

			tail = DSOUT.getDots(annotationIndices(idxA(end)), tracklets(trackletCombos(i, 1), idxA(end)));
			head = DSOUT.getDots(annotationIndices(idxB(1)), tracklets(trackletCombos(i, 2), idxB(1)));

			% if trackletCombos(i, 1)==5
			% 	hold on;
			% 	plot3([tail(1);head(1)],...
			% 		  [tail(2);head(2)],...
			% 		  [idxA(end); idxB(1)],'--');
			% end

		end
	end

	fprintf('	Dicarded %d tracklet combinations as negative results due to their shortness.\n\tDiscarded %d tracklet combinations as negative because their head/tail where too close.\n', numEliminatedDueToShortness, numEliminatedDueToProximity);

	clear new C D cnt i idx idxA idxB t trackletA trackletB vals;

	n = numel(Y);
	perm = randperm(n);
	I = I(perm, :);
	Y = Y(perm);

	fprintf('	There are %d positive and %d negative examples.\n\tThe ratio of positive to negative examples is 1:%.1f.\n', sum(Y==1), sum(Y==0), sum(Y==0)/sum(Y==1))

	if sum(Y==1)==0
		error('The training data is bad. There are no positive examples.');
	end

	if sum(Y==0)==0
		error('The training data is bad. There are no negative examples.');
	end

	% Using the matrix, create a new matrix containing the difference of histograms
	% with the objective function

	[featParams, numFeatures] = tracker.setFeatures();

	X = zeros(n, numFeatures, 'single');

	tracklets2 = tracker.trackletsToPosition(tracklets, 'out');

	fprintf('	Preparing large matrix with training data for linker.\n')

	I = convertIToContainTheCellIndices(tracklets, I);
	I = tracker.addActualFileIndices(I);

	for i=1:n
		% [trackletA, frameA, fileA, cellIndexA, trackletB, frameB, fileB cellIndexB]

		trackletAPos = tracklets(I(i, 1),  :);
		trackletBPos = tracklets(I(i, 5), :);

		trackletAIdx = find(trackletAPos);
		trackletBIdx = find(trackletBPos);
		
		trackletA = tracklets2(I(i, 1), trackletAIdx(1):I(i, 2), :);
		trackletB = tracklets2(I(i, 5), I(i, 6):trackletBIdx(end), :);

		features = tracker.computeTrackletMatchFeaturesForPair(trackletA, trackletB, I(i, :), featParams, numFeatures, params);

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

	if any([isempty(idxA) isempty(idxB)])
		trackletA = [];
		trackletB = [];
		discard = true;
		return
	end

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
			bottomPart = numel(trackletB(idxB(1):idxA(1)));
			topPart = numel(trackletB(idxA(end):idxB(end)));

			if bottomPart >= topPart
				trackletB(idxA(1):idxB(end)) = 0;
			else
				trackletB(idxB(1):idxA(end)) = 0;
			end
		else % shortest is trackletB
			bottomPart = numel(trackletA(idxA(1):idxB(1)));
			topPart = numel(trackletA(idxB(end):idxA(end)));

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