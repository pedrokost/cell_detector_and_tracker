function [descriptorsGt, perm, I] = getAnnotationDescriptors(dotsGt, dotsDet, descriptorsDet)
	% Returns detected descriptors corresponding to the annotated dots
	% For each annotated dot, it finds the most likely descriptor from the set of detections.
	% If an annotation does not have a corresponding detection (false negative) it's descriptor will be of the closest dot, but I will contain a 0 at the specified position of I to indicate that the match is of poor quality
	% Inputs: 
	% 	dotsGt = ground truth dot annotation of cell centroids
	% 	dotsDet = detected cell centroid locations
	% 	descriptorsDet = row matrix of descritors matching dotsDet
	% Outputs:
	% 	descriptorsGt = set of descriptors likely to correspond to dotsGt
	% 	perm = permutation indices indicating which descriptor from descriptorsDet corresponds to which dot in dotsGt. 0 if there is no matching descriptor
	%	I = binary indicator of dots in Gt with a match in Det.

	MATCHING_DOT_DISTANCE = 10; % If distance between dots larger than this, there is no correspondence between them.

	% Find corresponding detections
	% This computes for each GT dot, the closest Det dot.
	[D, perm] = pdist2(dotsDet, dotsGt, 'euclidean', 'Smallest', 1);

	descriptorsGt = descriptorsDet(perm, :);

	I = ones(size(perm));
	I(D > MATCHING_DOT_DISTANCE) = 0;
	% I = find(I)

end