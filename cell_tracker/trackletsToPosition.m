function tracklets2 = trackletsToPosition(tracklets, folderData)
	% trackletsToPosition converts the tracklets matrix to contain x-y positions
	% instread of global indices
	% Inputs:
	% 	tracklets = a tracklet matrix containing global mappings
	% 	folderData = the name of the folder containing the mat files with dot annoations
	% Outputs:
	% 	tracklets2 = a matrix similar to tracklets but with x-y positions instead of indices

	% TODO: get matPrefix from outside
	matPrefix = 'im';
	[numTracklets, numFrames] = size(tracklets);
	tracklets2 = zeros(numTracklets, numFrames, 2, 'uint16');

	for i=1:numFrames
		imTitle = [matPrefix sprintf('%03d', i) '.mat'];
		data = load(fullfile(folderData, imTitle));
		tracklets2(:, i, :) = getCellTrackletsFrame(data.dots, tracklets(:, i)); 
	end
end