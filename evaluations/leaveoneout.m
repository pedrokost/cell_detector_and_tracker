clear all;
rng(1234);
cd('..')
addpath('evaluations')

addpath(fullfile('dependencies', 'distinguishable_colors'))
%{
This script assumes all the detections have already been performed!!
%}


%--------------------------------------------------------------------Configure
datasets = [2];
doPlot = false;
runEvaluations = true; % Trains, Tests, computes metrics
showResults = true; % Only aggregates the results

numDataset = numel(datasets);

metricsOverview = [];

for d=1:numDataset
	clear DSIN DSOUT;
	fsectionf('Leave-one-out testing on dataset %d', datasets(d));
	
	dataParams = tracker.loadDatasetInfo(datasets(d));

	if runEvaluations
		% Delete old results
		resultFilenames = fullfile(dataParams.outFolder, 'test_*_*.mat');
		delete(resultFilenames)
		fprintf('Deleted old result files.\n')

		for t=1:dataParams.numAnnotatedTrajectories
			fsubsectionf('Leave-one-out testing on tracklet %d/%d from dataset %d', t, dataParams.numAnnotatedTrajectories, datasets(d));

			% Train by skipping tracklet i-th longest
			tracker.trainTracker(dataset, dataParams, t);

			% Test on all
			tracker.trackCells(dataset, dataParams);

			% Evaluated only tracklet i, save results to disk
			[metricsAnn, metricsDet, metricsMax] = evaluateDataset(datasets(d), doPlot, t);
			if doPlot
				pauseIt()
			end
				
			filename = fullfile(dataParams.outFolder, sprintf('test_%02d_%02d.mat', t, dataParams.numAnnotatedTrajectories));
			save(filename, 'metricsAnn', 'metricsDet', 'metricsMax', 't');
		end
	end
	if showResults
		resultFilenames = fullfile(dataParams.outFolder, 'test_*_*.mat');
		results = dir(resultFilenames);
		numResults = numel(results);
		metricsAnn = cell(numResults, 1);
		metricsDet = cell(numResults, 1);
		metricsMax = cell(numResults, 1);
		for i=1:numResults
			data = load(fullfile(dataParams.outFolder, results(i).name));
			metricsAnn{i} = data.metricsAnn;
			metricsDet{i} = data.metricsDet;
			metricsMax{i} = data.metricsMax;
		end
		avgMetricsAnn = averageMetricsFiltered(metricsAnn);
		avgMetricsDet = averageMetricsFiltered(metricsDet);
		avgMetricsMax = averageMetricsFiltered(metricsMax);

		avgMetrics = combineMetrics(avgMetricsAnn, avgMetricsDet, avgMetricsMax);
		if isempty(metricsOverview)
			metricsOverview = struct2table(avgMetrics);
		else
			tab = struct2table(avgMetrics);
			metricsOverview = union(metricsOverview, tab);
		end
	end
end

metricsOverview.Properties.RowNames = cellstr(metricsOverview.Dataset);
metricsOverview.Dataset = [];
metricsOverview.Tracklet = [];
metricsOverview.Kinit = [];
metricsOverview.Kterm = [];
metricsOverview.Kfp = [];
metricsOverview.Klink = [];
fprintf('Average metrics for each dataset:\n\n')
disp(metricsOverview)

cd('evaluations')