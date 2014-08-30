function [avgMetrics, metricValues] = averageMetricsFiltered(metrics)
	% AVERAGEMETRICS computes average for each metric in the cell array metrics 
	% Inputs:
	% 	metrics = a cell array of struct containing a set of metrics
	% Outputs:
	% 	avgMetrics = a struct containing the average values of the metrics

	avgMetrics = struct;

	metricFields = fieldnames(metrics{1});

	dontAverageFields = {'Dataset' 'Kinit' 'Kterm' 'Kfp' 'Klink' 'Tracklet'};

	metricValues = zeros(numel(metricFields), 1);

	for i=1:numel(metricFields)
		if ~ismember(metricFields{i}, dontAverageFields)
			metricValues(i) = mean(cellfun(@(x) x.(metricFields{i}), metrics));
			avgMetrics.(metricFields{i}) = metricValues(i);
		end
	end

	avgMetrics.SampleSize = numel(metrics);

	for i=1:numel(dontAverageFields)
		if ismember(dontAverageFields{i}, metricFields)
			avgMetrics.(dontAverageFields{i}) = metrics{1}.(dontAverageFields{i});
		end
	end

end


% TODO: look for a package that creates a graphic representation of the structs/cells