function trainTracker(dataset, dataParams)
	% Trains the cell tracker classifiers (robust and linker) on the given dataset

	%------------------------------------------------------------Configuration
	doTrainRobustTrackerModel = 1;
	doTrainLinkerTrackerModel = 1;
	
	%----------------------------------Load parameters and generate data store
	% addpath('somelightspeed');

	%-Features and control parameters-%
	
	global DSIN DSOUT;
	DSIN = tracker.DataStore(dataParams.linkFolder, false);
	DSOUT = tracker.DataStore(dataParams.outFolder, false);

	%---------------------------------------------------------Train the models

	if doTrainRobustTrackerModel
		tracker.trainRobustTrackerModel(dataParams);
	end

	if doTrainLinkerTrackerModel
		tracker.trainLinkerTrackerModel(dataParams);
	end
end