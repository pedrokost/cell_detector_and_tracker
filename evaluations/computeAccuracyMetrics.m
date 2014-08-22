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

		%-------------------------------------------------Fragmentation (FRMT)
		% The number of times a trajectory is interrupted
		metrics.Fragmentation = size(trackletsGenMulti{t}, 1);

		%----------------------------------------------------ID switches (IDS)
		% The number of times two trajectories switch their ID

		%----------------------------------Partially tracked trajectories (PT)
		% The number of trajectories that are tracked between 20% and 80%

		%----------------------------------------Mostly lost trajectories (ML)
		% The number of trajectories that are tracked for less than 20%

		%-------------------------------------Mostly tracked trajectories (MT)
		% The number of tracjectories that are successfully tracked for more than 80%

		%-----------------------------------------False Alarm Per Frame (FAPF)

		%--------------------Fraction of Ground Truth Instances Missed (FGTIM)

		%-----------------------------Multiple Object Tracking Accuracy (MOTA)
		% calculated from the number of false alarms, missed detections, and identity switches;

		metricsMulti{t} = metrics;
	end

end