function M = buildTrainMatrixForFramePair(descriptorsA, descriptorsB, links)
	% Creates a matrix containing the euclidean distance between descriptors of annotation dots and dots from detections. 
	% Inputs:
	% 	descriptorsA = row matrix of cell descriptors for a frame
	% 	descriptorsB = row matrix of cell descriptors for next frame
	% 	links        = a vector containing indices of the corresponding cells between frames
	% Outputs:
	% 	M = matrix containing euclidean pairwise euclidean distances between descriptors, and an obective column indicating if the there is a link between those descriptors

	nDotsA  = size(descriptorsA, 1);
	nDotsB  = size(descriptorsB, 1);
	nFeatures = size(descriptorsA, 2);

	% Build a matrix containing for each GT dot and each Det dot a vector with the euclidean distance between the corresponding feature vectors (provided theres is a detection for the annotation), and an objective value of 1 if the cells are linked, 0 if not.
	eucFnc = @(XI,XJ)(sqrt(bsxfun(@minus,XI,XJ).^2));

	M = zeros(nDotsA * nDotsB, nFeatures + 1);

	cur_idx = 0;
	for iA=1:nDotsA
		
		% annotated dot descriptor
		detA = descriptorsA(iA, :);

		for iB=(1:nDotsB)
			cur_idx = cur_idx + 1;

			% detected dot descriptor
			detB = descriptorsB(iB, :);

			M(cur_idx, 1:end-1) = eucFnc(detA, detB);

			% If there is a link between the cells, mark it in the objective column
			if links(iA) == iB
				M(cur_idx, end) = 1;
			end

		end
	end
end