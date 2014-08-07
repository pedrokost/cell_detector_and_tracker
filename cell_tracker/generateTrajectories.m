function tracklets = generateTrajectories(storeID, params)
	% Given a set of cell detections returns a matrix of long trajectories

	if params.saveTrajectoryGenerationInterimResults
		fprintf('Deleting any old interim tracklet files\n')
		delete(sprintf('%s*.mat', params.trajectoryGenerationToFilePrefix))
	end

	maxGaps = params.maxGaps;
	numGaps = numel(maxGaps)+2;  % FIXME, why + 2 ?
	classifierParams = params.linkerClassifierParams;
	robustClassifierParams = params.robustClassifierParams;


	fprintf('Generating robust tracklets\n')
	tracklets = generateTracklets(storeID, struct('withAnnotations', false, 'modelFile', robustClassifierParams.outputFileModel));

	if params.saveTrajectoryGenerationInterimResults
		file = sprintf('%s0.mat', params.trajectoryGenerationToFilePrefix);
		iteration = 0;
		closedGaps = 0;
		save(file, 'tracklets', 'iteration', 'closedGaps');
	end

	options = struct('matcher', classifierParams.algorithm, 'imageDimensions', params.imageDimensions, 'Kfp', params.Kfp, 'Klink', params.Klink, 'Kinit', params.Kinit, 'Kterm', params.Kterm);
	
	for i=1:numel(maxGaps)
		fprintf('Closing gaps of size: %d\n', maxGaps(i));
		[M, hypTypes] = generateHypothesisMatrix(tracklets, struct('maxGap', maxGaps(i)));

		% tracklets([5 6 8 9], :)
		% tr = trackletsToPosition(tracklets([5 6 8 9], :), 'out')
		% permute(tr(:, find(sum(sum(tr, 3), 1)), :), [2 3 1])
		
		Liks = computeLikelihoods(tracklets, M, hypTypes, options);

		Iopt = getGlobalOpimalAssociation(M, Liks);

		if params.verbose
			hypothesisPrint(M, Liks, Iopt, 'table');
		end

		Mopt = M(find(Iopt), :);
		tracklets = updateTracklets(tracklets, Mopt);

		if params.saveTrajectoryGenerationInterimResults
			fprintf('Saving tracklet for iteration %d to disk\n', i)
			file = sprintf('%s%d.mat', params.trajectoryGenerationToFilePrefix, i);
			iteration = i;
			closedGaps = maxGaps(i);
			save(file, 'tracklets', 'iteration', 'closedGaps');
		end

		% f2 = subplot(1, numGaps,i+2);
		% trackletViewer(tracklets, storeID, struct('animate', false, 'showLabels',true));
		% axis(f2, ax)
		% title(sprintf('tracklets. Min gap: %d', maxGaps(i)))
		% drawnow update;
		% pause(1)
	end


end