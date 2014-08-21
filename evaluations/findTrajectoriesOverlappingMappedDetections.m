function trackletsGen = findTrajectoriesOverlappingMappedDetections(trackletsDet, trackletsGen);
	% FINDTRAJECTORIESOVERLAPPINGMAPPEDDETECTIONS converts the
	% annotation-mapped-to-detections tracklet into a set of generated trajectory
	% tracklets. Said differently, it finds the overlapping set of generated trajectories
	% and the given annotation-mapped-to-detections tracklet.
	% Inputs:
	% 	trackletsDet = a single annotation-mapped-to-detections tracklet
	% 	trackletsGen = all the genreated trajectories
	% Output:
	% 	trackletsGen = a subset of generated trajectories overlapping with trackletsDet 

	numFrames = size(trackletsDet, 2);
	mapping = zeros(numFrames, 1);


	for f=1:numFrames
		if trackletsDet(f) == 0
			continue; % I don't care
		end

		mapping(f) = find(bsxfun(@eq, trackletsDet(f), trackletsGen(:, f)));

		% if numel(matches) > 1
		% 	trackletsDet(f)
		% 	trackletsGen(:, f)
		% 	keyboard
		% end
		 % mapping(f) =
		% 1 2 3 1 2 3 1 1 2 1 2 3

		% 1 2 3 2 3 4 3 4 6 4 3 2
		% 0 0 0 3 2 3 1 1 2 3 2 0
		% 0 0 1 1 3 2 5 6 7 8 9 0
	end

	mapping = unique(mapping);
	mapping = mapping(mapping ~= 0);

	trackletsGen = trackletsGen(mapping, :);

	% for each frame in the detection tracklets, find which tracklets uses that cell
	% in the generation tracklet
end