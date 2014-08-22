function metricsMulti = computeAccuracyMetrics(trackletsAnn, trackletsDet, trackletsGenMulti);
	% COMPUTEACCURACYMETRICS Compute accuracy metrics for a set tracklets
	% Inputs:
	% 	trackletsAnn = a trackltes matrix with annotated tracklets....
	% 	trackletsDet = ... mapped into detections
	% 	trackletsGen = a cell array with corresponding generated trajectories (can be several)
	% Outputs:
	% 	metrics = a cell array of structs containing a set of different accuracy metrics for each tracklet

	numTracklets = size(trackletsAnn, 1);
	metricsMulti = cell(numTracklets, 1);

	% Number of trajectories overlapping with the annotated tracklet
	for t = 1:numTracklets
		matrics = struct;
		metrics.NumSplits = size(trackletsGenMulti{t}, 1);
		metrics.Banana = false;

		metricsMulti{t} = metrics;
	end

end