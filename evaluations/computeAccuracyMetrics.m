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

	% OUTLIER_DISTANCE = 20; % bring from parameters.

	% Number of trajectories overlapping with the annotated tracklet
	for t = 1:numTracklets
		matrics = struct;

		% A lot of metrics in 
		% ClearEval_Protocol_v5

		%------------------------------------------------Interpolate tracklets
		% TODO:
		% FIXME: This should be done optionally in the end of tracking, not here

		%--------------------Fraction of Ground Truth Instances Missed (FGTIM)

		% FIXME: What is the difference between Fragmentation and ID switches?
		%-------------------------------------------------Fragmentation (FRMT)
		% The number of times a trajectory is interrupted
		metrics.Fragmentation = size(trackletsGenMulti{t}, 1) - 1;

		%----------------------------------------------------ID switches (IDS)
		% The number of times two trajectories switch their ID
		metrics.IDSwitches = size(trackletsGenMulti{t}, 1) - 1;

		%---------------------------------------------------------False alarms
		% check the mota definition

		% only compute it on the longest trajectory
		% number of points in the trajectory that are not in the target

		%----------------------------------------------------Missed detections
		% check the mota definition

		% number of points in the target that are not present in the trajectory
		
		%-----------------------------------------False Alarm Per Frame (FAPF)

		% divide the number of false alarms with the number of frames

		%-----------------------------Multiple Object Tracking Accuracy (MOTA)
		% calculated from the number of false alarms, missed detections, and identity switches;
		% 1687-5281-2008-246309.pdf

		%-------------------------------------------------Target effectiveness
		% To compute target effectiveness, we first assign each tar-
		% get (human annotated) to a track (computer-generated) that
		% contains the most observations from that ground-truth. Then
		% target effectiveness is computed as the number of the assigned
		% track observations over the total number of frames of the tar-
		% get. It indicates how many frames of targets are followed by
		% computer-generated tracks.

		% check page 124 of the thesis of autoamatic tracking.
		%---------------------------------------------------------Track purity
		% Similarly, we define track purity
		% as how well tracks are followed by targets.


		% check page 124 of the thesis of autoamatic tracking.

		%---------------------------------Early termination of trajectory (ET)

		%------------------------------Early initialization of trajectory (EI)

		%----------------------------------Late termination of trajectory (LT)

		%-------------------------------Late initialization of trajectory (LI)

		%----------------------------------------Root mean square error (RMSE)
		% ... of the tracked cell center
		% positions in microns. The RMSE is computed over all the
		% frames in a tracking video sequence. Manually determined
		% cell positions are used to compute the position error.

		%-----------------------------------------Percentage of frames tracked
		% If a computed cell center
		% is within one cell radius of the manually observed cell
		% center, then we consider that frame as “tracked.” The per-
		% centage is computed as the ratio of number of frames
		% tracked to the total number of frames in the sequence.

		metricsMulti{t} = metrics;
	end

end