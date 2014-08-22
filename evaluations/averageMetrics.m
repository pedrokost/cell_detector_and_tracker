function [avgMetrics, metricValues] = averageMetrics(metrics)
	% AVERAGEMETRICS computes average for each metric in the cell array metrics 
	% Inputs:
	% 	metrics = a cell array of struct containing a set of metrics
	% Outputs:
	% 	avgMetrics = a struct containing the average values of the metrics

	avgMetrics = struct;

	metricFields = fieldnames(metrics{1});
	metricValues = zeros(numel(metricFields), 1);

	for i=1:numel(metricFields)
		metricValues(i) = mean(cellfun(@(x) x.(metricFields{i}), metrics));
		avgMetrics.(metricFields{i}) = metricValues(i);
	end
	avgMetrics.SampleSize = numel(metrics);
end


% TODO: look for a package that creates a graphic representation of the structs/cells