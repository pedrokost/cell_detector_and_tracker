function metrics = computeAccuracyMetrics(trackletsAnn, trackletsDet, trackletsGen);
	% COMPUTEACCURACYMETRICS Compute accuracy metrics for a single tracklets (FIXME)
	% Inputs:
	% 	trackletsAnn = a single (FIXME) annotated tracklet....
	% 	trackletsDet = ... mapped into detections
	% 	trackletsGen = corresponding generated trajectories (can be several)
	% Outputs:
	% 	metrics = a struct containing a set of different accuracy metrics

	metrics = struct;


	% Number of trajectories overlapping with the annotated tracklet
	metrics.numSplits = size(trackletsGen, 1);

end