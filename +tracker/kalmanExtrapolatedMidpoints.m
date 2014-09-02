function [endTrackA, startTrackB] = kalmanExtrapolatedMidpoints(trackA, trackB, frameA, frameB)
	% KALMANEXTRAPOLATEDMIDPOINTS extrapolated the tracklets to their midpoint
	% and returns that midpoint for each tracklet

	MIN_NUM_OBSERVATIONS = 3;

	% frameA
	% frameB
	% trackA
	% trackB

	endTrackA = [0 0];
	startTrackB = [0 0];

	numFramesA = size(trackA, 1);
	numFramesB = size(trackB, 1);
	extrapolateA = 5;
	extrapolateB = 5;
	% start by simple extrapolating each for 5 frames, and plot results

	InitialLocationA = trackA(end, :);
	InitialLocationB = trackA(1, :);

	kalmanFilterA = configureKalmanFilter('ConstantVelocity',InitialLocationA,[6 7],[5 2],10);
	kalmanFilterB = configureKalmanFilter('ConstantVelocity',InitialLocationB,[6 7],[5 2],10);

	% kalmanFilterA.StateTransitionModel
	% kalmanFilterA.MeasurementModel
	% kalmanFilterA.ControlModel 
	% kalmanFilterA.State
	% kalmanFilterA.StateCovariance
	% kalmanFilterA.ProcessNoise
	% kalmanFilterA.MeasurementNoise


	figure(1); clf; hold on;
	for i=1:numFramesA
		[z_pred, x_pred, P_pred] = predict(kalmanFilterA);
		plot(z_pred(1), z_pred(2), 'ro');
		if ~all(trackA(i, :) == [0 0])
			plot(trackA(i, 1), trackA(i, 2), 'r+');
			correct(kalmanFilterA, trackA(i, :));
		end
	end
	for i=1:5
		[endTrackA] = predict(kalmanFilterA);
		plot(endTrackA(1), endTrackA(2), 'ro');
	end

	for i=numFramesB:-1:1
		[z_pred, x_pred, P_pred] = predict(kalmanFilterB);
		plot(z_pred(1), z_pred(2), 'bo');
		if ~all(trackB(i, :) == [0 0])
			plot(trackB(i, 1), trackB(i, 2), 'b+');
			correct(kalmanFilterB, trackB(i, :));
		end
	end
	for i=1:5
		[startTrackB] = predict(kalmanFilterB);
		plot(startTrackB(1), startTrackB(2), 'bo'); hold on;
	end



	% if both tracklts at least 5 frames long, extrapolated both equally

	% If one tracklet less <= than 2 frames, extapolate only the longer

	% If both <= 2 frames, simply compute the basic euclidean distance
end