function [avgMetricsAnn, avgMetricsDet, avgMetricsMax, metricsAnn, metricsDet, metricsMax] = evaluateDataset(dataset, doPlot)

	%------------------------------------------------------------Configuration

	doPlotAnnotations = true;
	doPlotMappedDetections = true;
	doPlotTrajectories = true;

	%--------------------------------------------------------------Load parameters
	params = tracker.loadDatasetInfo(dataset);
	numLongestTracklets = params.numAnnotatedTrajectories;

	global DSIN DSOUT;
	DSIN = tracker.DataStore(params.linkFolder, false);
	DSOUT = tracker.DataStore(params.outFolder, false);

	if doPlot
		colors = distinguishable_colors(3, [1 1 1]);
	end

	%---------------------------------------------------------Load annotations
	% Load the annotations tracklets
	filename = sprintf('%s_annotations.mat', params.trajectoriesOutputFile);
	load(filename);

	% Chose a few long tracklet of the annotations
	trackletsAnn = tracklets;
	lengths = trackletsLengths(tracklets);
	[~, sortIdx] = sort(lengths, 'descend');
	trackletsAnn = trackletsAnn(sortIdx, :);
	trackletsAnn = trackletsAnn(1:numLongestTracklets, :);

	if doPlot && doPlotAnnotations
		handleAnn = tracker.trackletViewer(trackletsAnn, 'in', struct('preferredColor', colors(1, :), 'lineWidth', 2, 'showLabels', true));
	end

	%---------------------------------------------------Find mapped detections

	% Map it onto the detections, which can only return 1 tracklet
	trackletsDet = tracker.convertAnnotationToDetectionIdx(trackletsAnn);

	if doPlot && doPlotMappedDetections
		hold on;
		handleDet = tracker.trackletViewer(trackletsDet, 'out', struct('preferredColor', colors(2, :), 'lineStyle', '.-', 'lineWidth', 4));
	end

	%--------------------------------------------------------Plot trajectories
	filename = sprintf('%s_final.mat', params.trajectoriesOutputFile);
	load(filename);

	trackletsGen = tracklets;
	trackletsGenMulti = findTrajectoriesOverlappingMappedDetections(trackletsDet, trackletsGen);

	if doPlot && doPlotTrajectories
		hold on;
		for t = 1:numLongestTracklets
			h = tracker.trackletViewer(trackletsGenMulti{t}, 'out', struct('preferredColor', colors(3, :), 'lineStyle', '.-', 'lineWidth', 2));
			if t == 1; handleGen = h; end;
		end
		legend([handleAnn, handleDet, handleGen], {'annotated trajectory...', '...mapped to detections', 'generated trajectories'}, 'Location', 'NorthEast');
	end

	%-----------------------------------------------------Prepare trajectories
	% Converts them to x-y position matrices and interpolates any missing values

	% tracklets convert the tracklets to 2D position stuff.
	trackletsAnn2D = tracker.trackletsToPosition(trackletsAnn, 'in', true);
	trackletsDet2D = tracker.trackletsToPosition(trackletsDet, 'out', true);

	for t=1:numLongestTracklets
		trackletsGenMulti{t} = tracker.trackletsToPosition(trackletsGenMulti{t}, 'out', true);
	end

	metricsAnn = computeAccuracyMetrics(trackletsAnn2D, trackletsGenMulti);
	metricsDet = computeAccuracyMetrics(trackletsDet2D, trackletsGenMulti);

	% This will be some kind of theoretical maximum possle to achieve for the
	% tracker, independent of the cell detector:
	trackletsGenMulti = cell(size(trackletsDet2D, 1), 1);
	for i=1:size(trackletsDet2D, 1)
		trackletsGenMulti{i} = trackletsDet2D(i, :, :);
	end
	metricsMax = computeAccuracyMetrics(trackletsAnn2D, trackletsGenMulti);

	%------------------------------------------------------Average the metrics
	avgMetricsAnn = averageMetrics(metricsAnn);
	avgMetricsDet = averageMetrics(metricsDet);
	avgMetricsMax = averageMetrics(metricsMax);
	avgMetricsAnn.Dataset = sprintf('Dataset %d', dataset);
	avgMetricsDet.Dataset = sprintf('Dataset %d', dataset);
	avgMetricsMax.Dataset = sprintf('Dataset %d', dataset);
end