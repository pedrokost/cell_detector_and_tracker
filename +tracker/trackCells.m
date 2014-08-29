function trackCells(dataset, dataParams)
	% Evaluates a trained tracker model on a new dataset

	%--------------------------------------------------------------Load params
	global DSIN DSOUT;
	DSIN = tracker.DataStore(dataParams.linkFolder, false);
	DSOUT = tracker.DataStore(dataParams.outFolder, false);
	%----------------------------------------------------Generate trajectories
	tracklets = tracker.generateTrajectories('out', dataParams);
	%------------------------------------------------Save final result to disk

	% Unfortunately I cannot save as links in previous parts of the algorithm, because the trajectories can skip frame, which might need to be interpolated. I don't want to generate some interpolations and save them to disk because they will be mixed with actual dot detections. I have to save the entire tracklet matrix
	finalTrackletsFile = [dataParams.trajectoriesOutputFile '_final.mat'];
	save(finalTrackletsFile, 'tracklets');
end