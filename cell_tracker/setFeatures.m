function parameters = setFeatures(feats)
%To set the features training/testing for the tracklet joiner
%	Inputs:
%		[feats] = a logical vector indicating which features are active
% 	Outputs:
%   	parameters = strucutre with learning parameters
%------------------------------------------------------------------Features

addCellDescriptors = 1;
addTrackletDifference = 1;
addDirectionTheta = 1; % angle between the direction of 2 tracklets
addEuclideanDistance = 1;  % distance between tail of tracklet A and head of tracklet B

%------------------------------------------------------------------Overrides
if nargin > 0
	if numel(feats) < 4; 
		fprintf('Using default set of features.\n');
	else
		addCellDescriptors    = feats(1);
		addTrackletDifference = feats(2);
		addDirectionTheta     = feats(3);
		addEuclideanDistance  = feats(4);
	end
end


parameters.addCellDescriptors    = addCellDescriptors;
parameters.addTrackletDifference = addTrackletDifference;
parameters.addDirectionTheta     = addDirectionTheta;
parameters.addEuclideanDistance  = addEuclideanDistance;

end