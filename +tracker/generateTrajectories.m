function tracklets = generateTrajectories(storeID, params)
	% Given a set of cell detections returns a matrix of long trajectories

	if params.saveTrajectoryGenerationInterimResults
		fprintf('Deleting any old interim tracklet files\n')
		delete(sprintf('%s*.mat', params.trajectoryGenerationToFilePrefix))
	end

	maxGaps = params.maxGaps;
	numGaps = numel(maxGaps)+2;  % FIXME, why + 2 ? It was becase 1 is for original, 1 for final or so...
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


	options = struct('matcher', classifierParams.algorithm,...
					 'imageDimensions', params.imageDimensions,...
	    			 'Kfp', params.Kfp,...
	    			 'Klink', params.Klink,...
	    			 'Kinit', params.Kinit,...
	    			 'Kterm', params.Kterm,...
	    			 'minPlink', params.minPlink);
	
	for i=1:numel(maxGaps)
		if params.verbose; fprintf('Closing gaps of size: %d\n', maxGaps(i)); end

		if params.verbose; fprintf('	Generating hypothesis matrix...\n'); end
		[M, hypTypes] = generateHypothesisMatrix(tracklets, struct('maxGap', maxGaps(i)));

		if params.verbose; fprintf('	There are %d hypothesis between %d tracklets\n', size(M, 1), size(tracklets, 1)); end

		% tracklets([5 6 8 9], :)
		% tr = trackletsToPosition(tracklets([5 6 8 9], :), 'out')
		% permute(tr(:, find(sum(sum(tr, 3), 1)), :), [2 3 1])
		
		if params.verbose; fprintf('	Computing hypothesis likelihoods...\n'); end
		Liks = computeLikelihoods(tracklets, M, hypTypes, options);

		Iunlikely = elimintateUnlikelyHypothesis(hypTypes, Liks, options);
		preDims = numel(Liks);
		M = M(~Iunlikely, :);
		Liks = Liks(~Iunlikely);
		if params.verbose
			postDims = numel(Liks);
			fprintf('	%.1f%s (%d) of hypothesis were elimintated because they were unlikely\n', 100*(preDims - postDims)/preDims, '%', preDims - postDims);
		end

		if params.verbose; fprintf('	Computing optimal association...\n'); end
		Iopt = getGlobalOpimalAssociation(M, Liks);

		if params.verbose
			hypothesisPrint(M, Liks, Iopt, 'table');
		end

		if params.verbose; fprintf('	Updating tracklets...\n'); end
		Mopt = M(find(Iopt), :);
		tracklets = updateTracklets(tracklets, Mopt);
		if params.saveTrajectoryGenerationInterimResults
			if params.verbose; fprintf('	Saving tracklets for iteration %d to disk\n', i); end
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