function model = gaussianBroadeningModel(track, extrudeLength)
	% GAUSSIANBROADENINGMODEL generates a model similar to the gaussian broadening that occurs in translational waves. Imagine a speaker moving at constant velocity, and at each timestep it emits a sound. The model models the way these soundwaves broaden.
	% IMPORTANT: Make sure the track does not have zero rows (if necessary interpolate before)
	% Inputs:
	% 	track = the track (row matrix nx2) use to estimate the model. The bottom frames are the most recent, the top the most old.
	% 	extrudeLength = the number of frames in which we want to evaluate the model
	% Outputs:
	% 	model = a model on which to evaluate a new track
	% See also: EVALUATEGAUSSIANBROADENINGMODEL
	VEL_SIGMA_WEIGHT = 1; % How many times more to take into account velocity vs covariance when compting the sigma of the gaussians

	[numObs, numDims] = size(track);

	if numObs > 1
		% Compute velocity (speed and direction)
		dist = track(2:end, :) - track(1:end-1, :);

		displacement = sum(dist, 1);
		vel = displacement / (numObs-1);
		
		weights = logspace(0, 1, numObs-1)';
		displacement = sum(dist .* [weights weights], 1);
		weightedVel = displacement / sum(weights);
		weightedVel = weightedVel / norm(weightedVel);
	else
		vel = [0 0];
		weightedVel = vel;
	end

	if numObs < 2
		sigma = eye(2)/2;
	else

		% Idea: Don't use just this tracklet covariance, but add some covariance from the average tracklet, with more of it if the current tracklet is very short;

		cellSpeed = 2;
		C = eye(2) * cellSpeed;
		Capport = (0.5 ^ numObs);

		sigma = C * Capport + abs(cov(track, 1)) + VEL_SIGMA_WEIGHT*diag(abs(weightedVel));
		% sigma = sigma / norm(sigma)  % This makes it worse if the distances are not unit-scale

		% If its not positive definete, add a small number to make it be.
		eqls = rowsEql(track);
		if any(eqls)
			sigma = sigma + diag(eqls * 1e-3);
		end
	end
	
	velVec = repmat(vel, extrudeLength, 1);
	velVecCum = cumsum(velVec, 1);
	muHist = bsxfun(@plus, velVecCum, track(end, :));


	sigVec = repmat(sigma, 1, 1, extrudeLength);
	sigmaHist = cumsum(sigVec, 3);

	model = struct('mus', muHist, 'sigmas', sigmaHist, 'normalize', true);

	function eqls = rowsEql(track)
		% Check if all the items in the cols are the same

		% eqls = all(bsxfun(@eq, track(1, :), track(2:end, :)), 1);

		eqls = [1 1]; %ones(1, nDims);
		first = track(1, 1);
		for i=2:numObs
			if (first ~= track(i, 1))
				eqls(1) = 0;
				break;
			end
		end
		first = track(1, 2);
		for i=2:numObs
			if (first ~= track(i, 2))
				eqls(2) = 0;
				break;
			end
		end
	end
end