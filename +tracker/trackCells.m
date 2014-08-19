function trackCells(dataset)
	% Evaluates a trained tracker model on a new dataset

	%--------------------------------------------------------------Load params
	params = tracker.loadDatasetInfo(dataset);  % This is the only use input

	global DSIN DSOUT;
	DSIN = tracker.DataStore(params.linkFolder, false);
	DSOUT = tracker.DataStore(params.outFolder, false);
	%----------------------------------------------------Generate trajectories
	tracklets = tracker.generateTrajectories('out', params);
	%------------------------------------------------Save final result to disk

	% Unfortunately I cannot save as links in previous parts of the algorithm, because the trajectories can skip frame, which might need to be interpolated. I don't want to generate some interpolations and save them to disk because they will be mixed with actual dot detections. I have to save the entire tracklet matrix
	finalTrackletsFile = [params.trajectoryGenerationToFilePrefix '_final.mat']
	save(finalTrackletsFile, 'tracklets');
end