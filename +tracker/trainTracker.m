function trainTracker(dataset, dataParams, leaveoneout)
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

	if nargin < 3
		leaveoneout = 0;
	end

	if doTrainRobustTrackerModel
		tracker.trainRobustTrackerModel(dataParams, leaveoneout);
	end

	if doTrainLinkerTrackerModel
		tracker.trainLinkerTrackerModel(dataParams, leaveoneout);
	end
end