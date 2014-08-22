function [avgMetrics, metrics] = evaluateDataset(dataset, doPlot)

	%--------------------------------------------------------------Load parameters
	params = tracker.loadDatasetInfo(dataset);
	numLongestTracklets = params.numAnnotatedTrajectories;

	global DSIN DSOUT;
	DSIN = tracker.DataStore(params.linkFolder, false);
	DSOUT = tracker.DataStore(params.outFolder, false);

	if doPlot
		colors = distinguishable_colors(3, [1 1 1]);
	end

	%-------------------------------------------------------------Load annotations
	% Load the annotations tracklets
	filename = sprintf('%s_annotations.mat', params.trajectoriesOutputFile);
	load(filename);

	% Chose a few long tracklet of the annotations
	trackletsAnn = tracklets;
	lengths = trackletsLengths(tracklets);
	[lengths, sortIdx] = sort(lengths, 'descend');
	trackletsAnn = trackletsAnn(sortIdx, :);
	trackletsAnn = trackletsAnn(1:numLongestTracklets, :);

	if doPlot
		handleAnn = tracker.trackletViewer(trackletsAnn, 'in', struct('preferredColor', colors(1, :), 'lineWidth', 2, 'showLabels', true));
	end

	%-------------------------------------------------------Find mapped detections

	% Map it onto the detections, which can only return 1 tracklet
	trackletsDet = tracker.convertAnnotationToDetectionIdx(trackletsAnn);

	if doPlot
		hold on;
		handleDet = tracker.trackletViewer(trackletsDet, 'out', struct('preferredColor', colors(2, :), 'lineStyle', '.:', 'lineWidth', 2));
	end

	%------------------------------------------------------------Subsection header
	filename = sprintf('%s_final.mat', params.trajectoriesOutputFile);
	load(filename);

	trackletsGen = tracklets;
	trackletsGenMulti = findTrajectoriesOverlappingMappedDetections(trackletsDet, trackletsGen);

	if doPlot
		for t = 1:numLongestTracklets
			h = tracker.trackletViewer(trackletsGenMulti{t}, 'out', struct('preferredColor', colors(3, :), 'lineStyle', '.-.', 'lineWidth', 2));
			if t == 1; handleGen = h; end;
		end
		legend([handleAnn, handleDet, handleGen], {'annotated trajectory...', '...mapped to detections', 'generated trajectories'}, 'Location', 'NorthEast');
	end

	%--------------------------------------------------------------Compute metrics

	metrics = computeAccuracyMetrics(trackletsAnn, trackletsDet, trackletsGenMulti);
	
	%----------------------------------------------------------Average the metrics

	avgMetrics = averageMetrics(metrics);
	avgMetrics.Dataset = sprintf('Dataset %d', dataset);
end