function trackletViewer(tracklets, options)
	% TRACKLETVIEWER takes an object representing tracklets and creates a spatio temporal plot.

	%-----------------------------------------------------------------Defaults
	animate = true;
	animationSpeed = 100; % pause is 1/animationSpeed
	%------------------------------------------------------------------Options
	if nargin < 2; options = struct; end

	if isfield(options, 'animate'); animate = options.animate; end;
	if isfield(options, 'animationSpeed');
		animationSpeed = options.animationSpeed;
	end;


	timeDim = 2;
	trackletDim = 1;
	framesDim = 2;
	xDim = 1;
	yDim = 2;
	nTracklets = size(tracklets, trackletDim);
	nFrames = size(tracklets, framesDim);

	colors = hsv(nTracklets);

	for t=1:nTracklets
		time = 1:size(tracklets, timeDim);
		x = tracklets(t, :, xDim);
		y = tracklets(t, :, yDim);
		z = time;

		% remove zeros (no particle detected)
		zs = find(x ~= 0);
		z = z(zs);
		x = x(zs);
		y = y(zs);

		plot3(x,y,z,'-', 'Color', colors(t, :));
		hold on;
		xlabel('x')
		ylabel('y')
		zlabel('time')

		% color=1:length(x);

		% surface([x;x],[y;y],[z;z],[color;color], 'facecol','no','edgecol','interp');
	end
	axis tight;
	view(-72,8)

	if animate
		h = 0;
		hs = [];

		while true
			for f=1:nFrames
				for h2=hs
					delete(h2);
				end
				hs = [];
				for d=1:nTracklets
					x = tracklets(d, f, xDim);
					y = tracklets(d, f, yDim);
					z = f;

					zs = find(x ~= 0);
					z = z(zs);
					x = x(zs);
					y = y(zs);

					h = plot3(x,y,z,'o', 'MarkerFaceColor', colors(d, :), 'MarkerEdgeColor', 'none');
					if h; hs = [hs; h]; end
				end
				drawnow
				pause(1/animationSpeed);
			end
		end
	end
end