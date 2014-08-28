% This basic script simply retrieves and displays the performance metrics for each dataset

clear all;
datasets = 1:5;
cd('/home/pedro/Dropbox/Imperial/project/cell_tracker');

totals = zeros(numel(datasets), 1);
means = zeros(numel(datasets), 1);
stds  = zeros(numel(datasets), 1);

for d=1:numel(datasets)
	params = dataFolders(datasets(d));
	load([params.outFolder '/detectorPerfMetrics.mat'])

	detectorPerfMetrics.ratioAnnotationToCandidate = [detectorPerfMetrics.ratioAnnotationToCandidate, 1];
	detectorPerfMetrics.ratioAnnotationToCandidate = detectorPerfMetrics.ratioAnnotationToCandidate / min(detectorPerfMetrics.ratioAnnotationToCandidate);

	detectorPerfMetrics
	%		dataset
	% 		avgPrecision
	% 		avgRecall
	% 		stdPrecision
	% 		stdRecall
	% 		avgTimePerFrame
	% 		avgTimePerAnnotatedCell
	% 		avgTimePerCandidateRegion

end

cd('evaluations');