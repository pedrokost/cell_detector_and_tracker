function tracklets2 = convertInToOutIdx(tracklets, options)
	% convertInToOutIdx Given a tracklet matrix generated by means of links in folderIn,
	% converts the indices to match the most likely (or none) index in folderOUT
	% Inputs:
	% 	tracklets = a tracklet matrix with indices corresponding to data in folerIN
	% 	DSIN = global variable containing a data store with the data used to create tracklets
	% 	DSOUT = global variable containing a data store with data of detections ... into which we want to convert the indices
	%	options = a struct containing options
	%		thresholdDinstace = a value from indicating the threshold for a match
	% Outputs:
	% 	tracklets2 = a matrix the same size as tracklets, but with indices corresponding to those in folderOUT
	global DSIN DSOUT;

	if nargin < 2; options = struct; end

	thresholdDinstace = 20;
	if isfield(options, 'thresholdDinstace')
		thresholdDinstace = options.thresholdDinstace;
	end

	[numTracklets, numFrames] = size(tracklets);

	tracklets2 = zeros(numTracklets, numFrames, class(tracklets));

	matPrefix = 'im';  % TODO load from outside

	for i=1:numFrames
		dotsGt = DSIN.getDots(i);
		% Permute this dots with the tracklets matrix
		dotsGt = getCellTrackletsFrame(dotsGt, tracklets(:, i));

		dotsDet = DSOUT.getDots(i); 
		% This computes for each GT dot, the closest Det dot.
		[D, perm] = pdist2(single(dotsDet), single(dotsGt), 'euclidean', 'Smallest', 1);

		perm(D > thresholdDinstace) = 0;
		if ~isempty(perm)
			tracklets2(:, i) = perm;
		end

		tracklets(:, i);
		perm;
	end
end