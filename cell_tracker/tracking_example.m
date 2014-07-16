clear all;
rng(1234)

doProfile = false;

if doProfile
	profile -memory on
end


run prepareFeatureMatrixForTrackletMatcher;
run trainMatcherTrackletJoinerANN;

params = loadDatasetInfo(2);
classifierParams = params.joinerClassifierParams;
maxGaps = params.maxGaps;
numGaps = numel(maxGaps)+2;


global DSIN DSOUT;
% Data storescl
DSOUT = DataStore(params.outFolder, false);


figure(1); clf;
f1 = subplot(1,numGaps,1);
tracklets = generateTracklets(params.dataFolder, struct('withAnnotations', true));
trackletViewer(tracklets, params.dataFolder, struct('animate', false, 'showLabel', false));
title('Ground truth')
ax = axis(f1);

f1 = subplot(1,numGaps,2);
tracklets = generateTracklets(params.outFolder, struct('withAnnotations', false));
trackletViewer(tracklets, params.outFolder, struct('animate', false, 'showLabel', false));
title('Robust tracklets')
axis(f1, ax)
% tracklets 52x66x2            54912


for i=1:numel(maxGaps)
	[M, hypTypes] = generateHypothesisMatrix(tracklets, struct('maxGap', maxGaps(i)));
	
	Liks = computeLikelihoods(tracklets, M, hypTypes, struct('matcher', classifierParams.algorithm));

	Iopt = getGlobalOpimalAssociation(M, Liks);

	hypothesisPrint(M, Liks, Iopt, 'shortextra');

	Mopt = M(find(Iopt), :);
	tracks = updateTracklets(tracklets, Mopt);
	tracklets = tracks;

	f2 = subplot(1, numGaps,i+2);
	trackletViewer(tracklets, params.outFolder, struct('animate', false));
	axis(f2, ax)
	title(sprintf('Tracks. Min gap: %d', maxGaps(i)))
	drawnow update;
	pause(1)
end

if doProfile
	profile off
	profile viewer
end