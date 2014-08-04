function [descriptors, nFeatures] = combineDescriptorsWithDots(descriptors, dots)
	% Expand the descriptors with the dot position (x, y)

	% size(descriptors)
	% size(dots)

	descriptors = horzcat(descriptors, dots);
	nFeatures = size(descriptors, 2);
end