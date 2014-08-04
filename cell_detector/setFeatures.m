function parameters = setFeatures(varargin)
%To set the features training/testing
%OUTPUT
%   parameters = strucutre with learning parameters
%------------------------------------------------------------------Features

eqHist = 0; %Equalize histogram
addArea = 0; %Adds area descriptor of the MSER
nBinsArea = 15;
areaBinType = 'log';%linear = 'lin', logarithmic = 'log'
minArea = 0.01/100;
maxArea = 2/100;
addIntHist = 1;%Adds intensity information
nBinsIntHist = 15; %Per color channel
addPos = 0; %Adds XY position
addDiffHist = 1; %Adds histogram of difference between MSER and its context
nBinsDiffHist = 8;
nDilations = 2;
nDilationScales = 2;
addShape = 1; %Adds shape descriptor
nAngBins = 12;
nRadBins = 5;
addOrientation = 0;
nBinsOrient = 8;
addEdges = 0;
addOrientGrad = 0;  % not used for cell detection
nBinsOrientGrad = 10;
addBias = 1;
bias = 100;
jitterSize = 3; %Size (in pixels) of the jitter introduced to the annotations


%------------------------------------------------------------------Overrides
if nargin > 0
	feats = varargin{1};
	if numel(feats) < 7; 
		fprintf('Using default set of features.\n');
	else
		addArea        = feats(1);
		addIntHist     = feats(2);
		addPos         = feats(3);
		addDiffHist    = feats(4);
		addShape       = feats(5);
		addOrientation = feats(6);
		addEdges       = feats(7);
	end
end


parameters.addArea = addArea;
parameters.nBinsArea = nBinsArea;
parameters.minArea = minArea;
parameters.maxArea = maxArea;
parameters.addPos = addPos;
parameters.addIntHist = addIntHist;
parameters.nBinsIntHist = nBinsIntHist;
parameters.addDiffHist = addDiffHist;
parameters.nBinsDiffHist = nBinsDiffHist;
parameters.nDilations = nDilations;
parameters.nDilationScales = nDilationScales;
parameters.addShape = addShape;
parameters.nAngBins = nAngBins;
parameters.nRadBins = nRadBins;
parameters.addBias = addBias;
parameters.bias = bias;
parameters.eqHist = eqHist;
parameters.jitter = 1;
parameters.jitterSize = jitterSize;
parameters.areaBinType = areaBinType;
parameters.addOrientation = addOrientation;
parameters.nBinsOrient = nBinsOrient;
parameters.addOrientGrad = addOrientGrad;
parameters.nBinsOrientGrad = nBinsOrientGrad;
parameters.addEdges = addEdges;

end