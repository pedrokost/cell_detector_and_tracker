function prepareFeatureMatrixForRobustMatcher(outputFile)

	%{
		This script prepares a matrix containing pairs of cell descriptors and a third objective column indicating if they are the same (that is if the cells are DIRECTLY linked)

		The descriptors are obtained from the cell_detector as a by-product of detecting cells. Additionally a cell location is concatenated to that vector.

		The objective column is obtained from the user annotations of links in the dataset. It is important for the purpose of learning a good matcher that the annotations are as complete possible. 
	%}

	global DSIN DSOUT;

	fprintf('Preparing the feature matrix to train Robust linker\n')

	matAnnotationsIndices = DSIN.getMatfileIndices();

	numFrames = numel(matAnnotationsIndices);
	X = [];

	% First, associate each annotation with the corresponding feature vector
	% Drop any detected cells that don't have annotation, or annotations with missing detections
	startIdx = matAnnotationsIndices(1);

	% Load annotations and detections for first image
	[dotsGtA, linksA] = DSIN.getDotsAndLinks(startIdx);
	[dotsDetA, descriptorsA] = DSOUT.get(startIdx);


	% FIXME: I have a bug: I am filtering descriptorsA, but not dotsGtA. This means Some dotsGtA could have no descriptor

	[descriptorsA, permA, IA] = getAnnotationDescriptors(dotsGtA, dotsDetA, descriptorsA);
	[descriptorsA, ~] = combineDescriptorsWithDots(descriptorsA, dotsGtA);

	descriptorsA = descriptorsA(find(IA), :);
	dotsGtA = dotsGtA(find(IA), :);
	linksA = linksA(find(IA));


	for i=1:(numFrames-1)
		matIdx = matAnnotationsIndices(i+1);

		% Load annotations and detections for next image
		[dotsGtB, linksB] = DSIN.getDotsAndLinks(matIdx);
		[dotsDetB, descriptorsB] = DSOUT.get(matIdx);
		
		[~, permB, IB] = getAnnotationDescriptors(dotsGtB, dotsDetB, descriptorsB);

		% if size(descriptorsB, 1) ~= size(dotsGtB, 1)
		% 	fprintf('1\n')
		% 	keyboard
		% end

		dotsGtBwithMatch = dotsGtB(IB, :);

		% TODOif there is a matching descritor for the dot, process, else
		[descriptorsB, ~] = combineDescriptorsWithDots(descriptorsB, dotsGtB);
		descriptorsB = descriptorsB(find(IB), :); dotsGtB = dotsGtB(find(IB), :); linksB = linksB(find(IB), :);

		%% Clean linksA:
		% For each value in linksA that matches a find(IB), I need to elimintate it,
		% and all the bigger values decrease by 1.
		badVals = find(~IB); % Eliminte this values from linksA
		for j=1:numel(badVals)
			badVal = badVals(j);
			% Elimintae the value from LinksA by placing a 0 in its location
			linksA(find(linksA == badVal)) = 0;
			% Find all in linksA bigger than badVal and decrease them by 1
			biggerIdx = find(linksA > badVal);
			linksA(biggerIdx) = linksA(biggerIdx) - 1;
			% decrease all values of badVal by 1
			badVals = badVals - 1;
		end

		if ~any([isempty(descriptorsA), isempty(descriptorsB)])

			M = buildTrainMatrixForFramePair(descriptorsA, descriptorsB, linksA);

			size(X)
			size(M)
			if isempty(M)
				fprintf('2\n')
				keyboard
			end
			X = vertcat(X, M);
		
		end
		linksA = linksB; descriptorsA = descriptorsB;
		dotsGtA = dotsGtB; dotsDetA = dotsGtB;
	end

	save(outputFile, 'X')

	% X = normalizeRange(X, {1:2});
	% imagesc(X)
end