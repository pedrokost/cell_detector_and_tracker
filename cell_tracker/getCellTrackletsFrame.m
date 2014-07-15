function gFrameCell = getCellTrackletsFrame(dots, globalPremutation, currNumTracklets)
	% GETCELLTRACKLETSFRAME returns a vector with the data from dots but reordered
	% based on the indices in globalPremutation
	% TODO: rename this function to make more sense

	% gFrameCells = getCellTrackletsFrame(dots, globalPremutation, currNumTracklets);
	% tracklets(1:currNumTracklets, f, :) = gFrameCells;
	if nargin < 3
		currNumTracklets = numel(globalPremutation);
	end

	gFrameCell = zeros(currNumTracklets, 2, 'uint16');
	gPermIdx = find(globalPremutation);

	% globalPremutation(gPermIdx)
	% dots
	% dots(globalPremutation(gPermIdx), :)
	gFrameCell(gPermIdx, :) = dots(globalPremutation(gPermIdx), :);
end
