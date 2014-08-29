function trackCells(dataset, dataParams)
	% Evaluates a trained tracker model on a new dataset

	%--------------------------------------------------------------Load params
	global DSIN DSOUT;
	DSIN = tracker.DataStore(dataParams.linkFolder, false);
	DSOUT = tracker.DataStore(dataParams.outFolder, false);
	%----------------------------------------------------Generate trajectories
	t = tic;
	tracklets = tracker.generateTrajectories('out', dataParams);
	time = toc(t);
	%------------------------------------------------Save final result to disk

	% Unfortunately I cannot save as links in previous parts of the algorithm, because the trajectories can skip frame, which might need to be interpolated. I don't want to generate some interpolations and save them to disk because they will be mixed with actual dot detections. I have to save the entire tracklet matrix
	finalTrackletsFile = [dataParams.trajectoriesOutputFile '_final.mat'];

	params = struct(...
		'Kinit', dataParams.Kinit, ...
		'Kterm', dataParams.Kterm, ...
		'Kfp', dataParams.Kfp, ...
		'Klink', dataParams.Klink, ...
		'maxGaps', dataParams.maxGaps...
	);

	save(finalTrackletsFile, 'tracklets', 'time', 'params');
end