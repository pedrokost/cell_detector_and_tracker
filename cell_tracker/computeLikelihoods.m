function Liks = computeLikelihoods(tracklets, descriptors, hypothesis, hypTypes, options)
	% COMPUTELIKELIHOODS Computes the likelihood of each hypothesis
	% Inputs:
	% 	tracklets = the tracklets matrix generated by generateTracklets()
	% 	descriptors = descriptors of head and tail of each trackles as computed by getTrackletHeadTailDescriptors()
	% 	hypothesis = the hypothesis matrix generate by generateHypothesisMatrix()
	%	hypTypes = a vector indicating the type of hypothesis, as generateb by generateHypothesisMatrix()
	% 	options = a struct with options
	% Outputs:
	% 	Liks = a column vector of length numHypothesis containing likelihoods for each hypothesis

	%------------------------------------------------------------------Options
	if nargin < 2; options = struct; end

	% This should mirror the types in generateHypothesisMatrix()
	TYPE_INIT = 1;
	TYPE_TERM = 2;
	TYPE_FP = 3;
	TYPE_LINK = 4;

	MISS_DETECTION_RATE = 0.3;  % TODO: load real value from an external param
	% file

	%--------------------------------------------------------Preallocate space
	numHypothesis = size(hypothesis, 1);
	numTracklets = size(tracklets, 1);

	% Likelihood vector
	Liks = zeros(numHypothesis, 1);

	%-------------------------------------------------Precompute probabilities

	linkHypothesisIdx = find(hypTypes == TYPE_LINK);
	numLinkHypothesis = size(linkHypothesisIdx);
	linkHypothesis = hypothesis(linkHypothesisIdx, :);
	pLinks = computePlink();
	[pFPs, pTPs] = computeTruthnessProbs(1:numTracklets);
	pInit = computePinit();
	pTerm = computePterm();

	%------------------------------------------------------Compute likelihoods

	% Although generateHypothesisMatrix orders the hypothesis is an easy to remember order, I do not rely on the order, but on the types given in hypTypes

	% Compute initialization hypothesis
	Liks(hypTypes == TYPE_INIT) = pInit;

	% Compute termination hypothesis
	Liks(hypTypes == TYPE_TERM) = pTerm;

	% Compute false positive hypothesis
	[I, ~] = find(hypothesis(hypTypes == TYPE_FP, 1:numTracklets));
	Liks(hypTypes == TYPE_FP) = pFPs(I);

	% Compute link hypothesis
	for i=1:numel(linkHypothesisIdx)
		[~, J] = find(linkHypothesis(i, :));
		Liks(linkHypothesisIdx(i)) = pLinks(J(1), J(2)-numTracklets);
	end

	function P = computePlink()
		% COMPUTEPLINK for each link hypothesis compute the probability of linking
		% Inputs:
		% 	linkHypothesis= a (sparse) matrix of dimensions numTracklets x numTracklets containing 1 if the tracks could potentially be linked
		% Outputs:
		% 	P = the probability of linking the pairs of tracklets as evaluated by a learned model, in the form a of matrix the same size as linkHypothesis;

		% Algorithm outline:
		% create a matrix of descriptor pairs for each possible tracklet connection
		% TODO: augement the cell descriptor with motion features
		% create a sparse matrix like linkHypothesis
		% for each possible link hypothesis evaluate the model

		%----------------------------------------------------Preallocate space
		numLinkHypothesis = size(linkHypothesis, 1);
		numFeatures = size(descriptors, 2);
		trackletPairs = zeros(numLinkHypothesis, 2);
		descriptorDistMatrix = zeros(numLinkHypothesis, numFeatures);
		P = sparse([],[],[], numTracklets, numTracklets);
		% descriptors contains descriptors of the head and tail of each tracklet
		% descriptorPairs contains pairs of augemented descriptors of possibly intenracting tracklets, use to compute the link probabilities.
		descriptorPairs = zeros(numLinkHypothesis, numFeatures, 2);
		descriptorPairDffs = zeros(numLinkHypothesis, numFeatures);
		%---------------------------------------Get tracklet pairs descriptors

		for i=1:numLinkHypothesis
			[~, J] = find(linkHypothesis(i, :));
			trackletPairs(i, :) = [J(1) J(2)-numTracklets];
		end

		% TODO: convert this to a function so I can reuse to train the model
		% For each link hypothesis place into descriptorPair the tail of
		% the previous and head of next tracklet
		TAIL_POS = 2;
		HEAD_POS = 1;
		for i=1:numLinkHypothesis
			desA = descriptors(trackletPairs(i, 1), :, TAIL_POS); % tail of prev
			desB = descriptors(trackletPairs(i, 2), :, HEAD_POS); % head of next

			descriptorPairs(i, :, 1) = desA;
			descriptorPairs(i, :, 2) = desB;
		end

		% TODO augment descriptorPairs with motion history

		%---------------------------------------------------Evaluate the Plink
		for i=1:numLinkHypothesis
			D = euclideanDistance(descriptorPairs(i, :, 1), ...
								  descriptorPairs(i, :, 2));
			descriptorPairDffs(i, :) = D;
		end

		matcher = 'ANN';
		if strcmp(matcher, 'ANN')
			matchP = testMatcherTrackletJoinerANN(descriptorPairDffs')';
		else
			matchP = testMatcherTrackletJoinerNB(descriptorPairDffs);
		end
		for i=1:numLinkHypothesis
			P(trackletPairs(i, 1), trackletPairs(i, 2)) = matchP(i);
		end
	end

	function [FP, TP] = computeTruthnessProbs(trackletIdx)
		% COMPUTETRUTHNESSPROBS Computes the probability that a tracklet is a false positive or a true positive
		% Inputs:
		% 	trackletIdx = indices of tracklets
		% Outputs:
		% 	FP = corresponding false positive probability
		% 	TP = corresponding true positive probability
		
		len = sum(max(tracklets(trackletIdx, :, :), [], 3) ~= 0, 2);
		FP = MISS_DETECTION_RATE .^ len;
		TP = 1 - FP;
	end

	function pInit = computePinit()
		% COMPUTEPINIT Returns the probability of initialization for each tracklet
		% Pinit = 1 - max(Plink_prev) where Plink_prev are the probabilities of
		% linking any of the previous trackets (up to maxGap in the past) to it.

		% It relies on pLinks, which is a numTrackletsxnumTracklets matrix
		% containing the probabilities of linking each tracklet to another

		pInit = 1 - max(pLinks, [], 1);
	end

	function pTerm = computePterm()
		% COMPUTEPINIT Returns the probability of initialization for each tracklet
		% Pinit  =1 - max(Plink_next) where Plink_next are the probabilities of
		% linking the current track to any of the next (up to maxGap in the future).

		% It relies on pLinks, which is a numTrackletsxnumTracklets matrix
		% containing the probabilities of linking each tracklet to another

		pTerm = 1 - max(pLinks, [], 2);
	end
end