function [params, numFeatures] = setFeatures()
%To set the features training/testing for the linker
%	Inputs: /
% 	Outputs:
%   	params = strucutre with learning params

CELL_DESCRIPTOR_SIZE = 101;
%------------------------------------------------------------------Features
params.addCellDescriptors = 0;  % descriptor from the detector
params.addGapSize         = 0;  % number of frames between the tail and head of 2 tracklets
params.addPosDistance     = 0;   % euclidean x-y distance between tail of tracklet A and head of tracklet B
params.addPosDistanceSquared = 1;   % square euclidean x-y distance between tail of tracklet A and head of tracklet B
params.addEuclidianDistance = 0; % eclidian distance between head and tail of mergin tracklets 
params.addDirectionTheta  = 0;   % angle between the direction of 2 tracklets
params.addDirectionVariances = 0;  % variance of direction over last N frames
params.addMeanDisplacement = 0;  % mean displacement between frames (same as velocity per frame)
params.addStdDisplacement = 0;  % std of displacement between frames
params.addDistanceFromEdge = 0; % Distance from the closest image edge for each tracklet
params.addGaussianBroadeningEstimate = 1; % How much the tracklet is within the broadened gaussian from the original tracklet 

params.descriptorSize = CELL_DESCRIPTOR_SIZE;
params.posDimensions = 2;   % x y
params.numCellsToEstimateDirectionTheta = 10;  % put al very large number for all (eg 9999)
params.numCellsForDirectionVariances = 3;  % put al very large number for all (eg 9999)
params.numCellsForMeanAndStdDisplacement = 10;  % put al very large number for all (eg 9999)
params.numCellsForGaussianBroadeningVelocityEstimation = 10;  % Indicate thes number of cell of the tracklet are used to estimate the sigma and velocity, as well as the number of cell in the candidate tracklet we evaluate.
params.maxClosingGap = 20;  % affect gaussian broadening idea. Negatively affects performance.

if nargout > 1
	numFeatures = params.addCellDescriptors * params.descriptorSize ...
			+ params.addGapSize ...
			+ params.addPosDistance * params.posDimensions ...
			+ params.addPosDistanceSquared * params.posDimensions ...
			+ params.addEuclidianDistance ...
			+ params.addDirectionTheta ...
			+ params.addDirectionVariances * params.posDimensions ...
			+ params.addMeanDisplacement * params.posDimensions ...
			+ params.addStdDisplacement * params.posDimensions ...
			+ params.addDistanceFromEdge * 2 ...
			+ params.addGaussianBroadeningEstimate;
end

end