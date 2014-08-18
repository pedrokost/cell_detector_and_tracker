function trainTracker(dataset)
	% Trains the cell tracker classifiers (robust and linker) on the given dataset

	%------------------------------------------------------------Configuration
	doTrainRobustTrackerModel = 1;
	doTrainLinkerTrackerModel = 1;
	
	%----------------------------------Load parameters and generate data store
	% addpath('somelightspeed');

	%-Features and control parameters-%
	params = tracker.loadDatasetInfo(dataset);
	
	global DSIN DSOUT;
	DSIN = tracker.DataStore(params.linkFolder, false);
	DSOUT = tracker.DataStore(params.outFolder, false);

	%---------------------------------------------------------Train the models

	% TODO: make sure these models are learned on the correct datasets
	if doTrainRobustTrackerModel
		tracker.trainRobustTrackerModel('in', params);
	end
	if doTrainLinkerTrackerModel
		tracker.trainLinkerTrackerModel('in', params);
	end
end