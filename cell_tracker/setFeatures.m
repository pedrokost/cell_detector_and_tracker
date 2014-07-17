function [params, numFeatures] = setFeatures()
%To set the features training/testing for the tracklet joiner
%	Inputs: /
% 	Outputs:
%   	params = strucutre with learning params

CELL_DESCRIPTOR_SIZE = 100;
%------------------------------------------------------------------Features
params.addCellDescriptors = 1;
params.addGapSize         = 1;
params.addPosDistance     = 1;   % euclidean x-y distance between tail of tracklet A and head of tracklet B
params.addDirectionTheta  = 0;   % angle between the direction of 2 tracklets
params.addDirectionVariances = 0;

params.descriptorSize = CELL_DESCRIPTOR_SIZE;
params.posDimensions = 2;   % x y
params.numCellsToEstimateDirection = 5;  % 0 means all
params.numCellsForDirectionVariances = 5;  % 0 means all
 
if nargout > 1
	numFeatures = params.addCellDescriptors * params.descriptorSize...
			+ params.addGapSize...
			+ params.addPosDistance * params.posDimensions...
			+ params.addDirectionTheta...
			+ params.addDirectionVariances * params.posDimensions;
end

end