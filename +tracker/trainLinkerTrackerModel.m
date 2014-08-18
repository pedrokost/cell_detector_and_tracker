function trainLinkerTrackerModel(storeID, options)
	% Generates a training matrix and trains the robust tracklet model for
	% generating robust tracklets
	% Input:
	% 	storeID = a string indicating from which dataset to load the data
	% 	options = a struct containing parameters such as
	% 		algorithm = which algorithm to use to train the model
	% 		outputFileMatrix = where to store the intermediate matrix
	% 		outputFileModel = where to store the learned model
	% Output: /

	linkerOptions = options.linkerClassifierParams;

	dataFile = linkerOptions.outputFileMatrix;
	% modelFile = options.outputFileModel;

	tracker.prepareFeatureMatrixForLinkerMatcher(dataFile, options)

	fprintf('Training model for linking tracklets\n')
	
	switch linkerOptions.algorithm
		case 'ANN'
			tracker.trainLinkerClassifierANN(dataFile)
		% case 'NB'
			% trainLinkerClassifierNB(dataFile, modelFile)
		otherwise
			error('Please specify a robust trackler training algorithm in the configuration file\n')
	end
end