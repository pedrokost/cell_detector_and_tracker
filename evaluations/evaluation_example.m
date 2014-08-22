%{
Before this script can be run, you need to:

- Train the tracker on the dataset,
- Test the tracker on the dataset,

because the script is dependent on certain side effects of these actions
(they store files with annotations, detections, robust tracklets, trajectories, etc)
%}

%----------------------------------------------------------Cleanup/Initizalize
clear all;
rng(1234);
cd('..')
addpath('evaluations')
addpath('dependencies/distinguishable_colors');

%--------------------------------------------------------------------Configure
doProf = true;
doPlot = true;
dataset = [1];
numLongestTracklets = 3;

if doPlot; figure(1); clf; end
if doProf
	profile on;
end

%--------------------------------------------------------------Load parameters
params = tracker.loadDatasetInfo(dataset);
global DSIN DSOUT;
DSIN = tracker.DataStore(params.linkFolder, false);
DSOUT = tracker.DataStore(params.outFolder, false);
if doPlot
	colors = distinguishable_colors(3, [1 1 1]);
end

%-------------------------------------------------------------Load annotations
% Load the annotations tracklets
filename = sprintf('%s_annotations.mat', params.trajectoriesOutputFile);
load(filename);

% Chose a few long tracklet of the annotations
trackletsAnn = tracklets;
lengths = trackletsLengths(tracklets);
[lengths, sortIdx] = sort(lengths, 'descend');
trackletsAnn = trackletsAnn(sortIdx, :);
trackletsAnn = trackletsAnn(1:numLongestTracklets, :);

if doPlot
	handleAnn = tracker.trackletViewer(trackletsAnn, 'in', struct('preferredColor', colors(1, :), 'lineWidth', 2));
end

%-------------------------------------------------------Find mapped detections

% Map it onto the detections, which can only return 1 tracklet
trackletsDet = tracker.convertAnnotationToDetectionIdx(trackletsAnn);

if doPlot
	hold on;
	handleDet = tracker.trackletViewer(trackletsDet, 'out', struct('preferredColor', colors(2, :), 'lineStyle', '.:', 'lineWidth', 2));
end

%------------------------------------------------------------Subsection header
filename = sprintf('%s_final.mat', params.trajectoriesOutputFile);
load(filename);

trackletsGen = tracklets;

trackletsGenMulti = findTrajectoriesOverlappingMappedDetections(trackletsDet, trackletsGen);

if doPlot
	for t = 1:numLongestTracklets
		h = tracker.trackletViewer(trackletsGenMulti{t}, 'out', struct('preferredColor', colors(3, :), 'lineStyle', '.-.', 'lineWidth', 2));
		if t == 1; handleGen = h; end;
	end
	legend([handleAnn, handleDet, handleGen], {'annotated trajectory...', '...mapped to detections', 'generated trajectories'})
end

cd('evaluations'); return
%--------------------------------------------------------------Compute metrics

metrics = computeAccuracyMetrics(trackletsAnn, trackletsDet, trackletsGen)

%--------------------------------------------------------------------Terminate

if doProf
	profile off;
	profile viewer;
end

cd('evaluations')