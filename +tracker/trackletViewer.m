function trackletViewer(tracklets, folderData, options)
	% TRACKLETVIEWER takes an object representing tracklets and creates a spatio temporal plot.
	% Inputs:
	% 	tracklets = matrix containing tracklets as generated by generateTracklets()
	% 	folderData = folder containing the dot annotations for each frame
	% 	options = a struct containing optional parameters
	% 		animate = [true] annimated the visualization
	% 		animationSpeed = [100] speed of animation
	% 		showLabels = [true] whether to show the index label of each tracklet
	% 		minLength = [1] only display tracklet of length N or longer
	% Outputs: /

	%-----------------------------------------------------------------Defaults
	animate = false;
	animationSpeed = 100; % pause is 1/animationSpeed
	showLabels = false;
	minLength = 1;
	preferredColor = -1;  % an rgb triplet [r g b]
	lineStyle = '.-';
	lineWidth = 1;
	%------------------------------------------------------------------Options
	if nargin < 3; options = struct; end

	if isfield(options, 'animate'); animate = options.animate; end
	if isfield(options, 'showLabels'); showLabels = options.showLabels; end
	if isfield(options, 'animationSpeed');
		animationSpeed = options.animationSpeed;
	end
	if isfield(options, 'minLength')
		minLength = options.minLength;
	end
	if isfield(options, 'preferredColor')
		preferredColor = options.preferredColor;
	end
	if isfield(options, 'lineStyle')
		lineStyle = options.lineStyle;
	end
	if isfield(options, 'lineWidth')
		lineWidth = options.lineWidth;
	end
	%-----------------------------------------------------------Initialization

	trackletDim = 1;
	framesDim = 2;

	numTracklets = size(tracklets, trackletDim);
	trackletIDs = 1:numTracklets;
	[tracklets, idx] = tracker.filterTrackletsByLength(tracklets, minLength);
	trackletIDs = trackletIDs(idx);

	numFrames = size(tracklets, framesDim);
	numTracklets = size(tracklets, trackletDim);

	if preferredColor ~= -1
		colors = repmat(preferredColor, numTracklets, 1);
	else
		% colors = distinguishable_colors(nTracklets, [0 0 0]);
		colors = hsv(numTracklets);
		colors = colors(randperm(numTracklets), :);
	end

	tracklets2 = tracker.trackletsToPosition(tracklets, folderData);

	for t=1:numTracklets
		z = 1:numFrames;
		x = tracklets2(t, :, 1);
		y = tracklets2(t, :, 2);

		% remove zeros (no particle detected)
		zs = find(x ~= 0);
		z = z(zs);
		x = x(zs);
		y = y(zs);

		plot3(x,y,z,lineStyle, 'Color', colors(t, :), 'LineWidth', lineWidth);
		grid on;
		hold on;
		
		xlabel('x [px]')
		ylabel('y [px]')
		zlabel('time [frame]')


		if showLabels

			text(double(x(1)), double(y(1)), double(z(1)), num2str(trackletIDs(t)));
		end
		% color=1:length(x);
		% surface([x;x],[y;y],[z;z],[color;color], 'facecol','no','edgecol','interp');
	end
	axis tight;
	% view(-72,8)
	view([150,30,30])

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