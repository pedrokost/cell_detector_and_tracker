function trainRobustTrackerModel(storeID, options)
	% Generates a training matrix and trains the robust tracklet model for
	% generating robust tracklets
	% Input:
	% 	storeID = a string indicating from which dataset to load the data
	% 	options = a struct containing parameters such as
	% 		algorithm = which algorithm to use to train the model
	% 		outputFileMatrix = where to store the intermediate matrix
	% 		outputFileModel = where to store the learned model
	% Output: /


	options = options.robustClassifierParams;
	
	prepareFeatureMatrixForRobustMatcher(options.outputFileMatrix)
	dataFile = options.outputFileMatrix;
	modelFile = options.outputFileModel;

	switch options.algorithm
		case 'ANN'
			trainMatcherRobustClassifierANN(dataFile)
		case 'NB'
			trainMatcherRobustClassifierNB(dataFile, modelFile)
		otherwise
			error('Please specify a robust trackler training algorithm in the configuration file')
	end
end