clear all;
rng(1234)

doProfile = false;

if doProfile
	profile -memory on
end


folderData = fullfile('..', 'data', 'series30greenOUT');
matcher = 'ANN';
maxGaps = [1 3 6 10];
numGaps = numel(maxGaps)+1;

figure(1); clf;
f1 = subplot(1,numGaps,1);
tracklets = generateTracklets(folderData, struct('withAnnotations', false));

% tracklets 52x66x2            54912
trackletViewer(tracklets, folderData, struct('animate', false, 'showLabel', false));
descriptors = getTrackletHeadTailDescriptors(tracklets, folderData);
ax = axis(f1);


for i=1:numel(maxGaps)
	[M, hypTypes] = generateHypothesisMatrix(tracklets, struct('maxGap', maxGaps(i)));
	
	Liks = computeLikelihoods(tracklets, descriptors, M, hypTypes, struct('matcher', matcher));

	Iopt = getGlobalOpimalAssociation(M, Liks);

	hypothesisPrint(M, Liks, Iopt, 'shortextra');

	Mopt = M(find(Iopt), :);
	tracks = updateTracklets(tracklets, Mopt);
	tracklets = tracks;

	f2 = subplot(1, numGaps,i+1);
	trackletViewer(tracklets, folderData, struct('animate', false));
	axis(f2, ax)
	title(sprintf('Tracks. Min gap: %d', maxGaps(i)))
	drawnow update;
	pause(1)
end

if doProfile
	profile off
	profile viewer
end