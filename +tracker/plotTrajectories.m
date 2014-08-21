function plotTrajectories(dataset)
	% Plots the final generated trajectories

	%----------------------------------Load parameters and generate data store
	params = tracker.loadDatasetInfo(dataset);
	
	global DSIN DSOUT;
	DSIN = tracker.DataStore(params.linkFolder, false);
	DSOUT = tracker.DataStore(params.outFolder, false);

	%--------------------------------------------------------Plot trajectories

	f = figure(dataset); clf;

	if params.plotProgress
		f1 = subplot(1,4,1); % Original annotations
		trackletFile = sprintf('%s_annotations.mat', params.trajectoriesOutputFile);
		load(trackletFile)
		tracker.trackletViewer(tracklets, 'in', struct('showLabels',false, 'minLength', 0));
		ax = axis(f1);
		title(sprintf('Annotations', dataset));	
		f2 = subplot(1,4,2); % Mapped into detections
		trackletFile = sprintf('%s_mappeddetections.mat', params.trajectoriesOutputFile);
		load(trackletFile);
		tracker.trackletViewer(tracklets, 'out', struct('showLabels',false, 'minLength', 0));
		axis(f2, ax);
		title(sprintf('Annotations mapped to detections', dataset));	
		f3 = subplot(1,4,3); % Robust tracklets
		trackletFile = sprintf('%s0.mat', params.trajectoriesOutputFile);
		load(trackletFile);
		tracker.trackletViewer(tracklets, 'out', struct('showLabels',false, 'minLength', 0));
		title(sprintf('Robust tracklets', dataset));	
		axis(f3, ax);
		f4 = subplot(1,4,4); % Trajectories
		axis(f4, ax);
	end
	
	trackletFile = sprintf('%s_final.mat', params.trajectoriesOutputFile);
	load(trackletFile);
	tracker.trackletViewer(tracklets, 'out', struct('showLabels',false, 'minLength', 0));
	if exist('ax', 'var')
		axis(f4, ax)
	end
	title(sprintf('Generated trajectories', dataset));	


	% files = dir([params.trajectoriesOutputFile '*.mat']);

	% [~,files] = cellfun(@fileparts, {files.name}, 'UniformOutput',false);
	% [~, finalTrackletsFile] = fileparts(finalTrackletsFile);
	% files = setdiff(files, finalTrackletsFile);
	% numFiles = numel(files);
	% for i=1:numFiles
	% 	load(fullfile(params.outFolder, files{i}));
	% 	subplot(1,numFiles, iteration+1);
	% 	trackletViewer(tracklets, 'out', struct('animate', false, 'showLabels',false, 'minLength', 2));
	% 	title(sprintf('tracklets. Min gap: %d', closedGaps));
	% end

end
