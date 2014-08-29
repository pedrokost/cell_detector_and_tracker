function metricsMulti = computeAccuracyMetrics(target, trajectories);
	% COMPUTEACCURACYMETRICS Compute accuracy metrics for a set tracklets
	% Inputs:
	% 	target = a trackltes matrix with annotated tracklets....
	% 	trajectories = a cell array with corresponding generated trajectories (can be several)
	% Outputs:
	% 	metricsMulti = a cell array of structs containing a set of different accuracy metrics for each tracklet

	numTracklets = size(target, 1);
	metricsMulti = cell(numTracklets, 1);

	OUTLIER_DISTANCE = 20; % bring from parameters.

	% Number of trajectories overlapping with the annotated tracklet
	for t = 1:numTracklets
		metrics = struct;

		curTarget = target(t, :, :);
		curTarget2D = permute(curTarget, [2 3 1]);
		targetMap = max(curTarget, [], 3) > 0;
		targetMapIdx = find(targetMap);
		trajectorySegments = trajectories{t};
		trajectoriesMap = max(max(trajectorySegments, [], 1), [], 3) > 0;
		trajectoriesMapIdx = find(trajectoriesMap);


		% A lot of metrics in 
		% ClearEval_Protocol_v5

		%------------------------------------------------Interpolate tracklets
		% TODO:
		% FIXME: This should be done optionally in the end of tracking, not here

		%--------------------Fraction of Ground Truth Instances Missed (FGTIM)

		% FIXME: What is the difference between Fragmentation and ID switches?
		%-------------------------------------------------Fragmentation (FRMT)
		% The number of times a trajectory is interrupted
		metrics.Fragmentation = size(trajectorySegments, 1) - 1;

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
		% select the track with the most observations from the ground truth
		obsCount = observationsCount(trajectorySegments);
		[~, maxObsCountIdx] = max(obsCount);
		bestSegment2D = permute(trajectorySegments(maxObsCountIdx, :, :), [2 3 1]);

		% count number of correctly assigned ground observations
		cntCorrectlyAssigned = 0;
		for i=1:numel(targetMapIdx)
			isCorrectlyAssigned = abs(tracker.pointsDistance(curTarget2D(i, :), bestSegment2D(i, :))) < OUTLIER_DISTANCE;
			cntCorrectlyAssigned = cntCorrectlyAssigned + isCorrectlyAssigned;
		end
		% divide it by totaal number of frames of ground truth
		metrics.TargetEffectiveness = cntCorrectlyAssigned / numel(targetMapIdx);

		%---------------------------------------------------------Track purity
		% Similarly, we define track purity
		% as how well tracks are followed by targets.


		% check page 124 of the thesis of autoamatic tracking.

		%---------------------------------Early termination of trajectory (ET)
		% Then number of frames the trajectory finished early

		metrics.EarlyTermination = max(targetMapIdx(end) - trajectoriesMapIdx(end), 0);

		%------------------------------Early initialization of trajectory (EI)

		metrics.EarlyInitialization = max(trajectoriesMapIdx(1) - targetMapIdx(1), 0);

		%----------------------------------Late termination of trajectory (LT)
		
		metrics.LateTermination = max(trajectoriesMapIdx(end) - targetMapIdx(end), 0);

		%-------------------------------Late initialization of trajectory (LI)

		metrics.LateInitialization = max(targetMapIdx(1) - trajectoriesMapIdx(1), 0);

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

	function cnt = observationsCount(tracklets)
		[numTracklets, numFrames] = size(tracklets);
		trackletsMap = max(tracklets, [], 3) > 0;
		cnt = zeros(numTracklets, 1);
		for i=1:numTracklets
			cnt(i) = numel(find(trackletsMap(i, :)));
		end
	end
end