clear

rng(1234);

testing = false;

figure(1); clf;

if testing
	nTracklets = 7;
	nFrames = 10;	
	tracklets = zeros(nTracklets, nFrames, 2);
	tracklets(:, :, 1) = [
	1 2 3 4 5 0 0 0 0 0;
	0 0 0 0 0 6 7 0 0 0;
	0 0 0 0 0 6 7 8 9 10;
	1 2 3 4 0 0 0 0 0 0;
	0 0 0 0 5 6 7 0 0 0;
	0 0 0 0 5 6 7 8 9 10;
	0 0 0 0 0 0 0 8 9 10;
	];

	tracklets(:, :, 2) = [
	10 9 8 7 7 0 0 0 0 0;
	0 0 0 0 0 7 8 0 0 0;
	0 0 0 0 0 7 7 7 8 8;
	4 4 4 4 0 0 0 0 0 0;
	0 0 0 0 4 5 5 0 0 0;
	0 0 0 0 3 3 2 2 2 2;
	0 0 0 0 0 0 0 5 5 5;
	];

else
	load nbmatch_tracklets.mat
	size(tracklets)
end

f1 = subplot(1,2,1);
trackletViewer(tracklets, struct('animate', false, 'showLabels', true));
title('Tracklets')
ax = axis(f1);

[M, P] = generateHypothesisMatrix(tracklets, struct('maxGap', 0));


% if testing
% 	P = [
% 	0.7
% 	0.3
% 	0.2
% 	0.9
% 	0.2
% 	0.15
% 	0.2

% 	0.1
% 	0.3
% 	0.6
% 	0.1
% 	0.2
% 	0.9
% 	0.8

% 	0.1
% 	0.7
% 	0.2
% 	0.15
% 	0.2
% 	0.05
% 	0.25

% 	0.5
% 	0.5
% 	0.6
% 	0.65
% 	0.1
% 	0.5
% 	];
% end

size(M)
size(P)

% Then try to compute something with it
Iopt = getGlobalOpimalAssociation(M, P);

% % Pretty dispaly results
hypothesisPrint(M, P, Iopt, 'table');
hypothesisPrint(M, P, Iopt, 'short');

f2 = subplot(1,2,2);
Mopt = M(find(Iopt), :);
tracks = updateTracklets(tracklets, Mopt);
trackletViewer(tracks, struct('animate', false));
title('Tracks')
axis(f2, ax)