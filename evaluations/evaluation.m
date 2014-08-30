%{
Before this script can be run, you need to:

- Train the tracker on all the datasets,
- Test the tracker on all the datasets,

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
doPlot = false;
doProf = false;
datasets = [2];
mutliPlot = true;

%-------------------------------------------------------------Begin evaluation

numDataset = numel(datasets);

if doPlot && mutliPlot; figure(1); clf; end
if doProf
	profile on;
end

metricsOverview = [];

for i=1:numDataset
	if doPlot; setupPlot(i, numDataset, mutliPlot); end	
	[avgMetricsAnn, avgMetricsDet, avgMetricsMax, metricsAnn, metricsDet, ...
		metricsMax] = evaluateDataset(datasets(i), doPlot);

	avgMetrics = combineMetrics(avgMetricsAnn, avgMetricsDet, avgMetricsMax);

	% fprintf('Metrics for tracklets in dataset %d:\n', datasets(i));
	% celldisp(metrics);

	if isempty(metricsOverview)
		metricsOverview = struct2table(avgMetrics);
	else
		tab = struct2table(avgMetrics);
		metricsOverview = union(metricsOverview, tab);
	end
end

metricsOverview.Properties.RowNames = cellstr(metricsOverview.Dataset);
metricsOverview.Dataset = [];

fprintf('Average metrics for each dataset:\n\n')
disp(metricsOverview)

%--------------------------------------------------------------------Terminate

if doProf
	profile off;
	profile viewer;
end

cd('evaluations')