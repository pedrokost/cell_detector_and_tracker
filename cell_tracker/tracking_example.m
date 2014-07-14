clear all;
rng(1234)

doProfile = false;

if doProfile
	profile -memory on
end


folderData = fullfile('..', 'data', 'series30green');
matcher = 'ANN';
maxGaps = [1 10];

figure(1); clf;
f1 = subplot(1,2,1);
tracklets = generateTracklets(folderData, struct('withAnnotations', true));

% tracklets 52x66x2            54912
whos
trackletViewer(tracklets, folderData, struct('animate', false, 'showLabel', false));
% descriptors = getTrackletHeadTailDescriptors(tracklets, folderData);
ax = axis(f1);

tracks = tracklets;
for i=1:numel(maxGaps)
	[M, hypTypes] = generateHypothesisMatrix(tracklets, struct('maxGap', maxGaps(i)));
	
% 	Liks = computeLikelihoods(tracklets, descriptors, M, hypTypes, struct('matcher', matcher));

% 	Iopt = getGlobalOpimalAssociation(M, Liks);

% 	hypothesisPrint(M, Liks, Iopt, 'short');

% 	Mopt = M(find(Iopt), :);
% 	tracks = updateTracklets(tracklets, Mopt);
% 	tracklets = tracks;
end	


f2 = subplot(1,2,2);
trackletViewer(tracks, folderData, struct('animate', false));
title('Tracks')
axis(f2, ax)

if doProfile
	profile off
	profile viewer
end