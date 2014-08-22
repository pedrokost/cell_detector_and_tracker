function trackletsGenMulti = findTrajectoriesOverlappingMappedDetections(trackletsDet, trackletsGen);
	% FINDTRAJECTORIESOVERLAPPINGMAPPEDDETECTIONS converts the
	% annotation-mapped-to-detections tracklet into a set of generated trajectory
	% tracklets. Said differently, it finds the overlapping set of generated trajectories
	% and the given annotation-mapped-to-detections tracklet.
	% Inputs:
	% 	trackletsDet = a set annotation-mapped-to-detections tracklet
	% 	trackletsGen = all the genreated trajectories
	% Output:
	% 	trackletsGenMulti = a cell of subset of generated trajectories overlapping with each trackletsDet


	[numTracklets, numFrames] = size(trackletsDet);
	trackletsGenMulti = cell(numTracklets, 1);


	for t=1:numTracklets
		mapping = zeros(numFrames, 1);

		for f=1:numFrames
			if trackletsDet(t, f) == 0
				continue; % I don't care
			end

			match = find(bsxfun(@eq, trackletsDet(t, f), trackletsGen(:, f)));

			if ~isempty(match)
				mapping(f) = find(bsxfun(@eq, trackletsDet(t, f), trackletsGen(:, f)));
			end
			% if numel(matches) > 1
			% 	trackletsDet(f)
			% 	trackletsGen(:, f)
			% 	keyboard
			% end
			% 1 2 3 1 2 3 1 1 2 1 2 3

			% 1 2 3 2 3 4 3 4 6 4 3 2
			% 0 0 0 3 2 3 1 1 2 3 2 0
			% 0 0 1 1 3 2 5 6 7 8 9 0
		end

		mapping = unique(mapping);
		mapping = mapping(mapping ~= 0);

		trackletsGenMulti{t} = trackletsGen(mapping, :);
	end
end