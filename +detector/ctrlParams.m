function params = ctrlParams(overrides)
	% Sets control parameters for testing/training
	%OUTPUT
	%   ctrlParms = structure with some control parameters

	%-------------------------------------------------------------------Control
	%-Parallel computing-%
	params.runPar = 0; %Set to activate parallel computing  
	params.workers = 4;

	%-Some Control Parameters-%
	params.c = 1; %C in the optimization objective
	params.o = 2; %Slack rescaling = 1, Margin rescaling = 2.
	params.bias = 0.5; %Offset in the output of the classifier's score
	params.alpha = 0;%Controls the precision/recall from within the optimization
	%(penalization cost of regions with no dot inside is 1-alpha)
	params.ssvm = 1;
	params.maxOuterIter = 2;

	%-------------------------------------------------------Intermediate saves
	params.saveMasks = 0;  % Save binary images with detected cells
	params.saveCellDescriptors = 1;  % Store features to be used in the tracker for matching

	%----------------------------------------------------------------Detection
	params.testAll = true;  % Test on complete dataset, or only fraction
	%----------------------------------------------------------------Overrides
	if nargin > 0
		params = catstruct(params, overrides);
	end