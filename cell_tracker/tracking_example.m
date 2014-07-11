clear all;
rng(1234)

profile -memory on


folderOUT = fullfile('..', 'data', 'series30greenOUT');
matcher = 'ANN';
maxGaps = [1 10];

figure(1);
f1 = subplot(1,2,1);
tracklets = generateTracklets(folderOUT, false);
descriptors = getTrackletHeadTailDescriptors(tracklets, folderOUT);
trackletViewer(tracklets, struct('animate', false, 'showLabel', false));
ax = axis(f1);


for i=1:numel(maxGaps)
	[M, hypTypes] = generateHypothesisMatrix(tracklets, struct('maxGap', maxGaps(i)));
	
	Liks = computeLikelihoods(tracklets, descriptors, M, hypTypes, struct('matcher', matcher));

	Iopt = getGlobalOpimalAssociation(M, Liks);

	hypothesisPrint(M, Liks, Iopt, 'short');

	Mopt = M(find(Iopt), :);
	tracks = updateTracklets(tracklets, Mopt);
	tracklets = tracks;
end	
f2 = subplot(1,2,2);
trackletViewer(tracks, struct('animate', false));
title('Tracks')
axis(f2, ax)

profile off
profile viewer