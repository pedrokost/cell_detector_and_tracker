function tracklets2 = trackletsToPosition(tracklets, store)
	% trackletsToPosition converts the tracklets matrix to contain x-y positions
	% instread of global indices
	% Inputs:
	% 	tracklets = a tracklet matrix containing global mappings
	% 	store = {'in', 'out'} to indicate which store to use
	% 	DSIN or DSOUT are global store of data
	% Outputs:
	% 	tracklets2 = a matrix similar to tracklets but with x-y positions instead of indices

	if strcmp(store, 'in');
		global DSIN;
		store = DSIN;
	elseif strcmp(store, 'out')
		global DSOUT;
		store = DSOUT;
	end

	idx = store.getMatfileIndices();

	[numTracklets, numFrames] = size(tracklets);
	tracklets2 = zeros(numTracklets, numFrames, 2, 'uint16');

	for i=1:numFrames
		dots = store.getDots(idx(i));
		tracklets2(:, i, :) = tracker.getCellTrackletsFrame(dots, tracklets(:, i)); 
	end
end