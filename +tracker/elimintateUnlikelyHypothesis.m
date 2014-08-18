function Iunlikely = elimintateUnlikelyHypothesis(hypTypes, Liks, options)
	% ELIMINTATEUNLIKELYHYPOTHESIS This function elimintates hypothesis that are very unlikely
	% Why? Due to the imbalanace definition of the 4 different likelihoods,
	% pLink is usually higher that it should be (0.5 means: could be connected
	% or not by the ANN). Elimintating such unlikely hypothesis improved the 
	% tracking as they are not selected.

	% Inputs:
	% 	M = the hypothesis matrix
	% 	hypTypes = for each hypothesis indicate what type it is
	% 	Liks = the corresponding likelihoods
	% 	options = struct containing
	% 		minPlink
	% 		minPinit
	% 		minPterm
	% 		minPfp
	% Outputs:
	% 	Iunlikely = Indices of unlikely hypothesis

	% IDEA: Another options would be to map the pLink into someting that pushes
	% the values close to 0.5 more towards the extremes.


	% This should mirror the types in generateHypothesisMatrix() and
	% computeLikelihoods()
	TYPE_INIT = 1;
	TYPE_TERM = 2;
	TYPE_FP = 3;
	TYPE_LINK = 4;

	minLiks = ones(size(hypTypes)) * -9999;

	minLiks(hypTypes == TYPE_LINK) = options.minPlink;

	Iunlikely = Liks < minLiks;
end