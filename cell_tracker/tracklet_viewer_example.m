rng(213);

figure(1); clf;

% Generate sample tracklets matrix
nTracklets = 20;
nFrames = 100;
scale = 100;
disturbance = 0.1 * scale;

tracklets = zeros(nTracklets, nFrames, 2);

for t=1:nTracklets
	initialFrame = ceil(rand() * nFrames / 2);
	finalFrame = ceil(rand() * nFrames / 2) + initialFrame;
	loc = (rand(1,2)  - 0.5) * scale;

	for f=initialFrame:finalFrame
		tracklets(t, f, :) = loc;
		loc = loc + rand * disturbance - disturbance / 2;
	end
end


tracklet_viewer(tracklets);
