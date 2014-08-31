function avgMetrics = combineMetrics(avgMetricsAnn, avgMetricsDet, avgMetricsMax)

	avgMetrics = avgMetricsAnn;

	flds = fieldnames(avgMetricsAnn);

	dontMergeFields = {'Dataset' 'SampleSize' 'Time' 'Kinit' 'Kterm' 'Kfp' 'Klink' 'MaxGaps' 'Tracklet' 'TimeStd' 'MaxGapsStd'};

	for i=1:numel(flds)
		if ~ismember(flds{i}, dontMergeFields)
			avgMetrics.(flds{i}) = [avgMetricsAnn.(flds{i}) avgMetricsDet.(flds{i}) avgMetricsMax.(flds{i})];
		end
	end
end