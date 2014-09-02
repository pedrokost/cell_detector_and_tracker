function [endTrackA, startTrackB] = kalmanExtrapolatedMidpoints(trackA, trackB, frameA, frameB)
	% KALMANEXTRAPOLATEDMIDPOINTS extrapolated the tracklets to their midpoint
	% and returns that midpoint for each tracklet

	MIN_NUM_OBSERVATIONS = 3;
	doPlot = true;
	numFramesA = size(trackA, 1);
	numFramesB = size(trackB, 1);

	% if both tracklts at least 5 frames long, extrapolated both equally
	framediff = (frameB - frameA);
	if numFramesA >= MIN_NUM_OBSERVATIONS && numFramesB >= MIN_NUM_OBSERVATIONS
		extrapolateA = floor(framediff / 2);
		extrapolateB = ceil(framediff / 2);
	elseif numFramesA >= MIN_NUM_OBSERVATIONS
		extrapolateA = frameB - frameA;
		extrapolateB = 0;
	elseif numFramesB >= MIN_NUM_OBSERVATIONS
		extrapolateB = frameB - frameA;
		extrapolateA = 0;
	else
		extrapolateA = 0;
		extrapolateB = 0;
	end

	InitialLocationA = trackA(1, :);
	InitialLocationB = trackB(end, :);

	if doPlot
		figure(1); clf; hold on; grid on; view([90, 30, 30]);
		scatter3(InitialLocationA(1), InitialLocationA(2), frameA-numFramesA+2, 'rx');
		% scatter3(InitialLocationB(1), InitialLocationB(2), frameB + numFramesB, 'bx');
	end
	
	InitialEstimateError = [1 1];
	MotionNoise = [1 1];
	MeasurementNoise = 1;


	StateTransitionModel = [  1     1     0     0;
     0     1     0     0;
     0     0     1     1;
     0     0     0     1];

    MeasurementModel = [1     0     0     0;
     0     0     1     0]
    ControlModel = [];
    State = [10; 0; 10; 0];
    StateCovariance = [     1     0     0     0;
     0     1     0     0;
     0     0     1     0;
     0     0     0     1];
    ProcessNoise = [   1     0     0     0;
     0     1     0     0;
     0     0     1     0;
     0     0     0     1
	];

	MeasurementNoise2 = [1 0; 0 1];

	I3 = eye(3);
	A = [I3 1*I3; 0*I3 I3]

	return

	%   KALMAN_PARAMS - structure with Kalman Filter parameters

	kalmanParams = struct('process_noise_var2', ProcessNoise, 'measurement_noise_var2', MeasurementNoise2, 'estimate_error_var2', InitialEstimateError);
	%       process_noise_var2 (Q)
	%       measurement_noise_var2 (R) 
	%       estimate_error_var2 (P)


	
	if extrapolateA > 0
		kalmanFilterA = configureKalmanFilter('ConstantVelocity',InitialLocationA,InitialEstimateError,MotionNoise, MeasurementNoise);
		kalmanFilterA.StateTransitionModel
		kalmanFilterA.MeasurementModel
		kalmanFilterA.ControlModel 
		kalmanFilterA.State
		kalmanFilterA.StateCovariance
		kalmanFilterA.ProcessNoise
		kalmanFilterA.MeasurementNoise
		for i=1:numFramesA
			[State, kalmanParams] = tracker.KalmanFilter(State, trackA(i, :), kalmanParams, 'predict')
			[z_pred, x_pred, P_pred] = predict(kalmanFilterA);
			if ~all(trackA(i, :) == [0 0])
				if doPlot
					scatter3(trackA(i, 1), trackA(i, 2), frameA+i-framediff, 'r+');
				end
				correct(kalmanFilterA, trackA(i, :));
			end
		end
		for i=(frameA+1):(frameA+extrapolateA)
			[endTrackA] = predict(kalmanFilterA);
			if doPlot
				scatter3(endTrackA(1), endTrackA(2), i+1, 'ro');
			end
		end
	else
		endTrackA = InitialLocationA;
	end

	% if extrapolateB > 0
	% 	kalmanFilterB = configureKalmanFilter('ConstantVelocity',InitialLocationB,InitialEstimateError,MotionNoise, MeasurementNoise);

	% 	for i=numFramesB:-1:1
	% 		[z_pred, x_pred, P_pred] = predict(kalmanFilterB);
	% 		if ~all(trackB(i, :) == [0 0])
	% 			if doPlot
	% 				scatter3(trackB(i, 1), trackB(i, 2), frameB+i, 'b+');
	% 			end
	% 			correct(kalmanFilterB, trackB(i, :));
	% 		end
	% 	end
	% 	for i=(frameB+extrapolateB-1):-1:(frameB)
	% 		[startTrackB] = predict(kalmanFilterB);
	% 		if doPlot
	% 			scatter3(startTrackB(1), startTrackB(2), i-1, 'bo'); hold on;
	% 		end
	% 	end
	% else
	% 	startTrackB = InitialLocationB;
	% end
end