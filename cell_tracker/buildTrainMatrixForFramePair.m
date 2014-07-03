function M = buildTrainMatrixForFramePair(dotsGtA, dotsDetA, dotsGtB, links, descriptorsA, descriptorsB)
	% Creates a matrix containing the euclidean distance between descriptors of annotation dots and dots from detections. Given that annotation descriptors are not available, this method uses the descirptionr from detection that most likely corresponds to that annoated cell.
	% Inputs:
	% 	dotsGtA      = a row matrix contining centroids of annotated cells in a frame
	% 	dotsDetA     = a row matrix containing centroid of detected cells in a frame
	% 	dotsGtB      = a row matrix containing centroids of annotated cells in next frame
	% 	links        = a vector containing indices of the corresponding cells between frames
	% 	descriptorsA = row matrix of cell descriptors for a frame
	% 	descriptorsB = row matrix of cell descriptors for next frame
	% Outputs:
	% 	M = matrix for training on

	nDotsGtA  = size(dotsGtA, 1);
	nDotsDetA = size(dotsDetA, 1);
	nDotsGtB  = size(dotsGtB, 1);

	[descriptorsDet, nFeatures] = combineDescriptorsWithDots(descriptors, dotsDet);

	% Find corresponding detections
	% This computes for each GT dot, the closest Det dot.
	[D, I] = pdist2(dotsDet, dotsGt, 'euclidean', 'Smallest', 1);

	% Create the corresponding annotation descriptors (match the corresponding
	% detection descriptor but with the correct position)
	
	[descriptorsGt, ~] = combineDescriptorsWithDots(descriptors, dotsGt);

	% % Build a matrix containing for each GT dot and each Det dot a vector with the euclidean distance between the corresponding feature vectors (provided theres is a detection for the annotation), and an objective value of 1 if the cells are linked, 0 if not.
	% eucFnc = @(XI,XJ)(sqrt(bsxfun(@minus,XI,XJ).^2));

	% M = zeros(nDotsGt * nDotsDet, nFeatures + 1);
	% falseNegatives = zeros(nDotsGt * nDotsDet, 1); % annotated dots, that were not detected by the cell_detector

	% cur_idx = 0;
	% for i=1:nDotsGt
		
	% 	% annotated dot descriptor
	% 	detA = descriptors(I(i), :);

	% 	% If the distance between the detected and annotation dot match is
	% 	% too large, don't mark is as equal
	% 	if D(i) <= MATCHING_DOT_DISTANCE
	% 		falseNegatives(cur_idx+1:(cur_idx + nDotsDet)) = 1;
	% 		cur_idx = cur_idx + nDotsDet;
	% 		continue
	% 	end

	% 	for j=(1:nDotsDet)
	% 		cur_idx = cur_idx + 1;

	% 		% TODO: next is i==j
	% 		if I(i) == j
	% 			falseNegatives(cur_idx) = 1;
	% 			continue
	% 		end

	% 		% detected dot descriptor
	% 		detB = descriptorsDet(j, :);

	% 		M(cur_idx, 1:end-1) = eucFnc(detA, detB);

	% 		% If there is a link between the cells, mark it in the objective column
	% 		if links(i) == j
	% 			M(cur_idx, end) = 1;
	% 		end

	% 	end
	% end

	% M(falseNegatives==1, :) = [];
end