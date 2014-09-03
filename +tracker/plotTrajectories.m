function plotTrajectories(dataset, dataParams)
	% Plots the final generated trajectories

	doPlotAnnotations = false;
	doPlotMappedDetections = false;
	doPlotRobust = true;
	doPlotGeneratedTrajectories = true;

	%----------------------------------Load parameters and generate data store	
	global DSIN DSOUT;
	DSIN = tracker.DataStore(dataParams.linkFolder, false);
	DSOUT = tracker.DataStore(dataParams.outFolder, false);

	%--------------------------------------------------------Plot trajectories

	f = figure(dataset); clf;
	numSubPlots = doPlotAnnotations + doPlotMappedDetections + doPlotRobust + doPlotGeneratedTrajectories;
	curSubPlot = 1;
	if dataParams.plotProgress
		if doPlotAnnotations
			f1 = subplot(1,numSubPlots,curSubPlot); % Original annotations
			curSubPlot = curSubPlot + 1;
			trackletFile = sprintf('%s_annotations.mat', dataParams.trajectoriesOutputFile);
			load(trackletFile)
			tracker.trackletViewer(tracklets, 'in', struct('showLabels',false, 'minLength', 0));
			ax = axis(f1);
			title(sprintf('Annotations', dataset));	
		end
		if doPlotMappedDetections
			f2 = subplot(1,numSubPlots,curSubPlot); % Mapped into detections
			curSubPlot = curSubPlot + 1;
			trackletFile = sprintf('%s_mappeddetections.mat', dataParams.trajectoriesOutputFile);
			load(trackletFile);
			tracker.trackletViewer(tracklets, 'out', struct('showLabels',false, 'minLength', 0));
			if doPlotAnnotations
				axis(f2, ax);
			else
				ax = axis(f2);
			end
			title(sprintf('Annotations mapped to detections', dataset));
		end
		if doPlotRobust
			f3 = subplot(1,numSubPlots,curSubPlot); % Robust tracklets
			curSubPlot = curSubPlot + 1;
			trackletFile = sprintf('%s0.mat', dataParams.trajectoriesOutputFile);
			load(trackletFile);
			tracker.trackletViewer(tracklets, 'out', struct('showLabels',false, 'minLength', 2));
			title(sprintf('Robust tracklets', dataset));
			if doPlotAnnotations || doPlotMappedDetections
				axis(f3, ax);
			else
				ax = axis(f3);
			end
		end
		if doPlotGeneratedTrajectories
			f4 = subplot(1,numSubPlots,curSubPlot); % Trajectories
			curSubPlot = curSubPlot + 1;
		end
		% axis(f4, ax);
	end
	
	if doPlotGeneratedTrajectories
		trackletFile = sprintf('%s_final.mat', dataParams.trajectoriesOutputFile);
		load(trackletFile);
		tracker.trackletViewer(tracklets, 'out', struct('showLabels',false, 'minLength', 0));
		if doPlotAnnotations || doPlotMappedDetections || doPlotRobust
			axis(f4, ax);
		end
		title(sprintf('Generated trajectories', dataset));	
	end

	% files = dir([dataParams.trajectoriesOutputFile '*.mat']);

	% [~,files] = cellfun(@fileparts, {files.name}, 'UniformOutput',false);
	% [~, finalTrackletsFile] = fileparts(finalTrackletsFile);
	% files = setdiff(files, finalTrackletsFile);
	% numFiles = numel(files);
	% for i=1:numFiles
	% 	load(fullfile(dataParams.outFolder, files{i}));
	% 	subplot(1,numFiles, iteration+1);
	% 	trackletViewer(tracklets, 'out', struct('animate', false, 'showLabels',false, 'minLength', 2));
	% 	title(sprintf('tracklets. Min gap: %d', closedGaps));
	% end

end
