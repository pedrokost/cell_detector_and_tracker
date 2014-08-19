function plotTrajectories(dataset)
	% Plots the final generated trajectories

	%----------------------------------Load parameters and generate data store
	params = tracker.loadDatasetInfo(dataset);
	
	global DSIN DSOUT;
	DSIN = tracker.DataStore(params.linkFolder, false);
	DSOUT = tracker.DataStore(params.outFolder, false);

	%--------------------------------------------------------Plot trajectories

	f = figure(dataset); clf;
	trajectoriesFile = [params.trajectoryGenerationToFilePrefix '_final.mat'];

	load(trajectoriesFile);
	tracker.trackletViewer(tracklets, 'out', struct('showLabels',true, 'minLength', 0));
	title(sprintf('Trajectories for dataset %d', dataset));


	% files = dir([params.trajectoryGenerationToFilePrefix '*.mat']);

	% [~,files] = cellfun(@fileparts, {files.name}, 'UniformOutput',false);
	% [~, finalTrackletsFile] = fileparts(finalTrackletsFile);
	% files = setdiff(files, finalTrackletsFile);
	% numFiles = numel(files);
	% for i=1:numFiles
	% 	load(fullfile(params.outFolder, files{i}));
	% 	subplot(1,numFiles, iteration+1);
	% 	trackletViewer(tracklets, 'out', struct('animate', false, 'showLabels',true, 'minLength', 2));
	% 	title(sprintf('tracklets. Min gap: %d', closedGaps));
	% end

end
