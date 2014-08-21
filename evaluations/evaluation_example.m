%{
Before this script can be run, you need to:

- Train the tracker on the dataset,
- Test the tracker on the dataset,

because the script is dependent on certain side effects of these actions
(they store files with annotations, detections, robust tracklets, trajectories, etc)
%}

%----------------------------------------------------------Cleanup/Initizalize
clear all; cla;
rng(1234);
cd('..')
addpath('evaluations')
addpath('dependencies/distinguishable_colors');

%--------------------------------------------------------------------Configure
doProf = false;
dataset = [1];

figure(1); clf;
if doProf
	profile on;
end

%--------------------------------------------------------------Load parameters
params = tracker.loadDatasetInfo(dataset);
global DSIN DSOUT;
DSIN = tracker.DataStore(params.linkFolder, false);
DSOUT = tracker.DataStore(params.outFolder, false);
colors = distinguishable_colors(3, [1 1 1]);

%-------------------------------------------------------------Load annotations
% Load the annotations tracklets
filename = sprintf('%s_annotations.mat', params.trajectoriesOutputFile);
load(filename);

% Chose a random long tracklet (maybe the longest) of the annotations
trackletsAnn = tracklets;
lengths = trackletsLengths(tracklets);
[maxLength, maxLengthIdx] = max(lengths);

trackletsAnn = tracklets(maxLengthIdx, :);

tracker.trackletViewer(trackletsAnn, 'in', struct('preferredColor', colors(1, :), 'lineWidth', 2));

%-------------------------------------------------------Find mapped detections

% Map it onto the detections, which can only return 1 tracklet
trackletsDet = tracker.convertAnnotationToDetectionIdx(trackletsAnn);

hold on; tracker.trackletViewer(trackletsDet, 'out', struct('preferredColor', colors(2, :), 'lineStyle', '.:', 'lineWidth', 2));

%------------------------------------------------------------Subsection header
filename = sprintf('%s_final.mat', params.trajectoriesOutputFile);
load(filename);

trackletsGen = tracklets;

% figure(2);
% tracker.trackletViewer(trackletsGen, 'out', struct('preferredColor', colors(3, :)));

trackletsGen = findTrajectoriesOverlappingMappedDetections(trackletsDet, trackletsGen);

tracker.trackletViewer(trackletsGen, 'out', struct('preferredColor', colors(3, :),'lineStyle', '.-.', 'lineWidth', 2));

legend({'annotated tracklet...', '...mapped to detections', 'generated trajectories'})

%--------------------------------------------------------------Compute metrics

metrics = computeAccuracyMetrics(trackletsAnn, trackletsDet, trackletsGen)


%--------------------------------------------------------------------Terminate

if doProf
	profile off;
	profile viewer;
end

cd('evaluations')