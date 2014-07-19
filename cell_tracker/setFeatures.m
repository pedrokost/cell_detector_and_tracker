function [params, numFeatures] = setFeatures()
%To set the features training/testing for the linker
%	Inputs: /
% 	Outputs:
%   	params = strucutre with learning params

CELL_DESCRIPTOR_SIZE = 100;
%------------------------------------------------------------------Features
params.addCellDescriptors = 1;
params.addGapSize         = 1;
params.addPosDistance     = 1;   % euclidean x-y distance between tail of tracklet A and head of tracklet B
params.addPosDistanceSquared = 1;   % square euclidean x-y distance between tail of tracklet A and head of tracklet B
params.addDirectionTheta  = 1;   % angle between the direction of 2 tracklets
params.addDirectionVariances = 1;  % variance of direction over last N frames
params.addMeanDisplacement = 0;  % mean displacement between frames
params.addStdDisplacement = 0;  % mean displacement between frames
params.addDistanceFromEdge = 1; % Distance from the closest image edge for each tracklet

params.descriptorSize = CELL_DESCRIPTOR_SIZE;
params.posDimensions = 2;   % x y
params.numCellsToEstimateDirectionTheta = 10;  % 0 means all
params.numCellsForDirectionVariances = 3;  % 0 means all
params.numCellsForMeanDisplacement = 5;  % 0 means all
 
if nargout > 1
	numFeatures = params.addCellDescriptors * params.descriptorSize...
			+ params.addGapSize...
			+ params.addPosDistance * params.posDimensions...
			+ params.addPosDistanceSquared * params.posDimensions...
			+ params.addDirectionTheta...
			+ params.addDirectionVariances * params.posDimensions...
			+ params.addMeanDisplacement * params.posDimensions...;
			+ params.addStdDisplacement * params.posDimensions...
			+ params.addDistanceFromEdge * 2;
end

end