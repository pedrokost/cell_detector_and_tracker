function [M, P] = generateHypothesisMatrix(tracklets, options)
	% GENERATEHYPOTHESISMATRIX generates a matrix with probablities that each tracklet might be an initializer, terminator, linker, false positive.
	% For each tracklets it computes the following hypothesis:
	% 	- initialization
	% 	- termination
	% 	- link with each of the following tracklets
	% 	- false positive

	% Inputs:
	% 	tracklets = a tracklets matrix generated by the generateTracklets() function
	% 	options = a struct containing any of:
	% 		maxGap = [20] maximum gap between tracks that may be closed
	% Outputs:
	% 	M = a sparse row matrix containing a row for each tracklet hypotesis. The dimensions of this matrix are numHypothesis x (2*nTracklets)
	% 	P = a column vector of length numHypothesis containing probablities for each hypothesis

	% TODO: remove this:
	% To compute the probablities I will need:
	% 	- to compute Pfp and Ptp I will need:
	% 		- MISS DETECTION rate of cell_detector
	% 		- number of cells in tracklet
	% 	- to compute the Plink I will need:
	% 		A FEATURE VECTOR of first and last tracklet in sequence (CELL DESCRIPTOR)
	% 		including motion feature and distance to following tracklet
	% 		check that the spatial distribution of cells in tracklets is similar
	% 	- to compute init prob I will need
	% 		temporal and spatial distribution of tracks before it,
	% 		and its proximity to a boundary  (IMAGE SIZE)
	% 	- to compute term prob I will need
	% 		temporal and spatial distribution of tracks after it,
	% 		and its proximity to a boundary

	%------------------------------------------------------------------Options
	if nargin < 2; options = struct; end

	% Defaults
	maxGap = 20;

	% Overrides
	if isfield(options, 'maxGap')
		maxGap = options.maxGap;
	end
	%--------------------------------------------------------Preallocate space

	numTracklets = size(tracklets, 1);

	% To know the total number of hypothesis, I need to know the number of link
	% hypothesis for each tracklet. I need to find out the number of tracklets
	% starting in the following maxGap frames after the last cell in the
	% tracklet
	tracklets = max(tracklets(:, :, 1), tracklets(:, :, 2)); % Merge x-y into a single dimension to get a 2D matrix
	tracklets = min(1, tracklets);
	kernel = [1 -1]; % detect starts/ends of tracklets
	Itracklets = conv2(tracklets, kernel);
	[iI, iJ] = find(Itracklets==1); % Initializations
	[tI, tJ] = find(Itracklets==-1); % Terminations

	linkHypothesis = getLinkHypothesis(iI, iJ, tI, tJ, maxGap);
	numLinkHypothesis = full(sum(sum(linkHypothesis)));

	numHypothesis = numLinkHypothesis + 3 * numTracklets; % init, term, fp

	% Probability vector
	P = zeros(numHypothesis, 1);

	% The hypothesis matrix requires:
	% 	- 1 entry for each initialization hypothesis
	% 	- 1 entry for each termination hypothesis
	% 	- 2 entries for each false positive hypothesis
	% 	- 2 entries for each link hypothesis
	I = zeros(numTracklets * 4 + 2 * numLinkHypothesis, 1); 
	J = zeros(numTracklets * 4 + 2 * numLinkHypothesis, 1);
	S = ones(numTracklets * 4 + 2 * numLinkHypothesis, 1);
	%-------------------------------------------------------Compute hypothesis

	hyphCumIdx = 0;
	probCumIdx = 0;
	% Compute initialization hypothesis
	for i=1:numTracklets
		P(i) = 0.1;
		I(i) = i; % 
		J(i) = numTracklets + i; % tracklet idx in second part of matrix
	end
	hyphCumIdx = hyphCumIdx + numTracklets;
	probCumIdx = probCumIdx + numTracklets;

	% Compute termination hypothesis
	for i=1:numTracklets
		P(probCumIdx + i) = 0.2;
		I(hyphCumIdx + i) = hyphCumIdx + i;
		J(hyphCumIdx + i) = i;
	end
	hyphCumIdx = hyphCumIdx + numTracklets;
	probCumIdx = probCumIdx + numTracklets;

	% Compute false positive hypothesis
	for i=1:numTracklets
		P(probCumIdx + i) = 0.2;
		I(hyphCumIdx + i) = i + hyphCumIdx;
		I(hyphCumIdx + numTracklets + i) = i + hyphCumIdx;
		J(hyphCumIdx + i) = i;
		J(hyphCumIdx + numTracklets + i) = i + numTracklets;
	end
	hyphCumIdx = hyphCumIdx + numTracklets*2;
	probCumIdx = probCumIdx + numTracklets;

	% Compute link hypothesis
	[ilink, jlink] = find(linkHypothesis);
	% tracksWithLinks = find(any(linkHypothesis, 2))
	% A = full(linkHypothesis(, :))
	for i=1:numLinkHypothesis
		% I need to know which tracklet links to which
		P(probCumIdx + i) = 0.4;
		I(hyphCumIdx + i) = i + probCumIdx;
		I(hyphCumIdx + numLinkHypothesis + i) = i + probCumIdx;
		J(hyphCumIdx + i) = ilink(i);
		J(hyphCumIdx + numLinkHypothesis + i) = jlink(i) + numTracklets;
	end

	M = sparse(I, J, S);
end

function H = getLinkHypothesis(initializationY, initializationX, terminationY, terminationX, maxGap)
	% GETLINKHYPOTHESIS return a sparse matrix of dimensions nTracklets x nTracklets with 1 indicating tracks that can be linked
	% Inputs:
	% 	initializationY = y coordinates of all tracklets beginnings/heads
	% 	initializationX = x coordinates of all tracklets beginnings/heads
	% 	terminationY = y coordinates of all tracklet ends/tails
	% 	terminationX = x coordinates of all tracklet ends/tails
	% 	maxGap = the maximum number of frames ahead to look for poss possible linking tracklets
	% Outputs:
	% 	H = a sparse row matrix contaitning for each tracklet the indices of possible continuing tracklets.

	numTracklets = numel(initializationX);

	% This is to prevent excessive dynamic reallocation of space
	optimisticEstimateOfLinksPerTracklets = 4;
		
	I = zeros(numTracklets*optimisticEstimateOfLinksPerTracklets, 1);
	J = zeros(numTracklets*optimisticEstimateOfLinksPerTracklets, 1);

	numLinkHypothesis = 1;
	for i=1:numTracklets
		% For each tracklet end, find the number of tracklet starting in the next
		% maxGap frames
		xEndA = terminationX(i);
		yEndA = terminationY(i);
		xStartBInd = (initializationX >= xEndA) & (initializationX <= xEndA + maxGap);

		numLinks = sum(xStartBInd);

		if numLinks > 0
			I(numLinkHypothesis:numLinkHypothesis+numLinks-1) = repmat(yEndA, numLinks, 1);
			J(numLinkHypothesis:numLinkHypothesis+numLinks-1) = initializationY(xStartBInd);
		end

		numLinkHypothesis = numLinkHypothesis + numLinks;

	end

	I = I(1:numLinkHypothesis-1);
	J = J(1:numLinkHypothesis-1);
	S = ones(numLinkHypothesis-1, 1);
	H = sparse(I, J, S, numTracklets, numTracklets);
end