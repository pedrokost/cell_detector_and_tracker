function trackletViewer(tracklets, folderData, options)
	% TRACKLETVIEWER takes an object representing tracklets and creates a spatio temporal plot.
	% Inputs:
	% 	tracklets = matrix containing tracklets as generated by generateTracklets()
	% 	folderData = folder containing the dot annotations for each frame
	% 	options = a struct containing optional parameters
	% 		animate = [true] annimated the visualization
	% 		animationSpeed = [100] speed of animation
	% 		showLabels = [true] whether to show the index label of each tracklet
	% Outputs: /

	%-----------------------------------------------------------------Defaults
	animate = true;
	animationSpeed = 100; % pause is 1/animationSpeed
	showLabels = true;
	%------------------------------------------------------------------Options
	if nargin < 2; options = struct; end

	if isfield(options, 'animate'); animate = options.animate; end
	if isfield(options, 'showLabels'); showLabels = options.showLabels; end
	if isfield(options, 'animationSpeed');
		animationSpeed = options.animationSpeed;
	end
	%-----------------------------------------------------------Initialization

	trackletDim = 1;
	framesDim = 2;

	numTracklets = size(tracklets, trackletDim);
	numFrames = size(tracklets, framesDim);

	colors = hsv(numTracklets);
	colors = colors(randperm(numTracklets), :);

	tracklets2 = trackletsToPosition(tracklets, folderData);

	for t=1:numTracklets
		z = 1:numFrames;
		x = tracklets2(t, :, 1);
		y = tracklets2(t, :, 2);

		% remove zeros (no particle detected)
		zs = find(x ~= 0);
		z = z(zs);
		x = x(zs);
		y = y(zs);

		plot3(x,y,z,'.-', 'Color', colors(t, :));
		grid on;
		hold on;
		
		xlabel('x')
		ylabel('y')
		zlabel('time')


		if showLabels

			text(double(x(1)), double(y(1)), double(z(1)), num2str(t))
		end
		% color=1:length(x);
		% surface([x;x],[y;y],[z;z],[color;color], 'facecol','no','edgecol','interp');
	end
	axis tight;
	% view(-72,8)
	view(90,0)

	if animate
		h = 0;
		hs = [];

		while true
			for f=1:numFrames
				for h2=hs
					delete(h2);
				end
				hs = [];
				for d=1:numTracklets
					x = tracklets2(d, f, 1);
					y = tracklets2(d, f, 2);
					z = f;

					zs = find(x ~= 0);
					z = z(zs);
					x = x(zs);
					y = y(zs);

					h = plot3(x,y,z,'o', 'MarkerFaceColor', colors(d, :), 'MarkerEdgeColor', 'none');
					hs = [hs; h];
				end
				drawnow update
				pause(1/animationSpeed);
			end
		end
	end
end

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

function gFrameCell = getCellTrackletsFrame(dots, globalPremutation, currNumTracklets)
	% GETCELLTRACKLETSFRAME returns a vector with the data from dots but reordered
	% based on the indices in globalPremutation
	
	% gFrameCells = getCellTrackletsFrame(dots, globalPremutation, currNumTracklets);
	% tracklets(1:currNumTracklets, f, :) = gFrameCells;
	if nargin < 3
		currNumTracklets = numel(globalPremutation);
		% TODO: make smarter
	end

	gFrameCell = zeros(currNumTracklets, 2, 'uint16');
	for i=1:numel(globalPremutation)
		if globalPremutation(i)
			gFrameCell(i, :) = dots(globalPremutation(i), :);
		end
	end
end
