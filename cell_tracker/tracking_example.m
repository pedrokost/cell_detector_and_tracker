clear all;
rng(1234)

doProfile = false;

if doProfile
	profile -memory on
end

global DSIN DSOUT;
% Data storescl
params = loadDatasetInfo(2);
DSIN = DataStore(params.dataFolder, false);
DSOUT = DataStore(params.outFolder, false);

run prepareFeatureMatrixForTrackletMatcher;
% run trainLinkerClassifierNB;
run trainLinkerClassifierANN;

classifierParams = params.linkerClassifierParams;
maxGaps = params.maxGaps;
numGaps = numel(maxGaps)+2;

figure(1); clf;
f1 = subplot(1,numGaps,1);
tracklets = generateTracklets('in', struct('withAnnotations', true));
trackletViewer(tracklets, 'in', struct('animate', false, 'showLabels',true));
title('Ground truth')
ax = axis(f1);

f1 = subplot(1,numGaps,2);
tracklets = generateTracklets('out', struct('withAnnotations', false));
trackletViewer(tracklets, 'out', struct('animate', false, 'showLabels',true));
title('Robust tracklets')
axis(f1, ax)
% tracklets 52x66x2            54912


options = struct('matcher', classifierParams.algorithm, 'imageDimensions', params.imageDimensions);
for i=1:numel(maxGaps)
	[M, hypTypes] = generateHypothesisMatrix(tracklets, struct('maxGap', maxGaps(i)));
	
	Liks = computeLikelihoods(tracklets, M, hypTypes, options);

	Iopt = getGlobalOpimalAssociation(M, Liks);

	hypothesisPrint(M, Liks, Iopt, 'fulltable');

	Mopt = M(find(Iopt), :);
	tracks = updateTracklets(tracklets, Mopt);
	tracklets = tracks;

	f2 = subplot(1, numGaps,i+2);
	trackletViewer(tracklets, 'out', struct('animate', false, 'showLabels',true));
	axis(f2, ax)
	title(sprintf('Tracks. Min gap: %d', maxGaps(i)))
	drawnow update;
	pause(1)
end

if doProfile
	profile off
	profile viewer
end