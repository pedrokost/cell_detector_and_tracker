function [descriptors, nFeatures] = combineDescriptorsWithDots(descriptors, dots)
	% Expand the descriptors with the dot position (x, y)
	descriptors = horzcat(descriptors, dotsDet);
	nFeatures = size(descriptors, 2);
end