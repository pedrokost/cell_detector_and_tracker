function feats = bestFeatures(outFolder, thresholds, sortOrder)
% BESTFEATURES Given a mat file containing the results matrix created by featureSelection, it returns the best combination of features given a time constraint
% Input:
% 	- outFolder: the folder containing
% 		- a file named `batchResults.mat` containg the results matrix generated by featureSelection.m file
% 		- mat files including the location of the detected cells
% 	- [thresholds]: an array containing thresold for 'time', 'precision' and ' 'recall'. Default to: [Inf 0 0]
%   - [sortOrder]: a cell array containing the order in which the results should be sorted, before the top is seleted. Default to: {'recall', 'precision', 'time'}
% Output:
% 	- feats: a struct containing:
% 		- the best boolean feature vector, having 1 for each active feature and 0 for each inactive feature
% 		- the time it took to compute
% 		- the mean precision of detection
%       - the mean recall of detection
% Example:
% 	feats = bestFeatures(fullfile('kidney', 'outKidneyRed'))
% 	feats = bestFeatures(fullfile('kidney', 'outKidneyRed'), [2 0.5 0.9])
%   feats = bestFeatures(fullfile('lung', 'outLungGreen'), [2 0.5 0.9], {'precision', 'time', 'recall'})
inspectResults = 1;

if nargin < 2
	thresholds = [Inf 0 0];
end
if nargin < 3
	sortOrder = {'recall', 'precision', 'time'};
end

maxTime      = thresholds(1);
minPrecision = thresholds(2);
minRecall    = thresholds(3);

resultsFile = fullfile(outFolder, 'batchResults.mat');
load(resultsFile, 'results');
numImages = length(dir(fullfile(outFolder, 'im*.mat')));

% result fileds:
% 	- n-th: elapsed detection time for all images in the dataset
% 	- (n-1)-th: recall
% 	- (n-2)-th: precision
%   - 1:(n-3): feature vector
colTime           = size(results, 2);
colRecall         = size(results, 2) - 1;
colPrecision      = size(results, 2) - 2;
colsFeatureVector = 1:(size(results, 2) - 3);


definedSortOrder = [];
for col=sortOrder
	col = lower(col{1});
	switch col
		case 'recall'
			definedSortOrder = [definedSortOrder -colRecall];
		case 'precision'
			definedSortOrder = [definedSortOrder -colPrecision];
		case 'time'
			definedSortOrder = [definedSortOrder colTime];
		otherwise
			error('%s is not a valid entry for sortOder', col);
	end
	
end

results(:, colTime) = results(:, colTime) / numImages; % average time needed to detect cells in one image

if inspectResults
	axisTimeMax = max(maxTime, max(results(:, colTime)));

	clf;
	subplot(2,1,1);
	% Draw the boundaries
	q = patch([0 0 maxTime maxTime], [minPrecision 1 1 minPrecision], [0.9 0.9 0.9], 'EdgeColor', 'none');
	hold on;
	hasbehavior(q,'legend',false);
	scatter(results(:, colTime), results(:, colPrecision), 'g.')
	if maxTime < Inf; line([maxTime maxTime], [0 1],'Color',[1 0 0]); end
	if minPrecision > 0; line([0 axisTimeMax], [minPrecision minPrecision],'Color',[0 1 0]); end
	title('Precision versus Detection Time per Image')
	xlabel('Time [CPU-seconds]')
	ylabel('Precision')
	axis([0 axisTimeMax, 0, 1])


	subplot(2,1,2);
	% Draw the boundaries
	q = patch([0 0 maxTime maxTime], [minRecall 1 1 minRecall], [0.9 0.9 0.9], 'EdgeColor', 'none');
	hold on;
	hasbehavior(q,'legend',false);
	scatter(results(:, colTime), results(:, colRecall), 'b+')
	if maxTime < Inf; line([maxTime maxTime], [0 1],'Color',[1 0 0]); end
	if minRecall > 0; line([0 axisTimeMax], [minRecall minRecall],'Color',[0 0 1]); end
	title('Recall versus Detection Time per Image')
	xlabel('Time [CPU-seconds]')
	ylabel('Recall')
	axis([0 max(maxTime, max(results(:, colTime))), 0, 1])
end

% Select only the results with time below maxTime
okTimes = results(:, colTime) <= maxTime;
okPrecision = results(:, colPrecision) >= minPrecision;
okRecall = results(:, colRecall) >= minRecall;
results = results(okTimes & okPrecision & okRecall, :);

% Sort the remaining results by recall DESC, then precision DESC, then time ASC
results = sortrows(results, definedSortOrder);

% remove entries with NaN precision or recall
precisionNaNs = isnan(results(:, colPrecision));
recallNaNs = isnan(results(:, colRecall));
allNaNs = precisionNaNs | recallNaNs;
allNaNs = precisionNaNs;
results = results(~allNaNs, :);

if size(results, 1) == 0
	error('There are no feature vectors with precision>%2.2f, recall>%2.2f that compute in <%2.2f cpu-seconds per image.\nTry adjusting the thresholds and sortOrder.', minPrecision, minRecall, maxTime);
end

if inspectResults
	% Show the selected stats in the top figure too
	subplot(2,1,1); hold on;
	plot(results(1, colTime), results(1, colPrecision), 'r.', 'MarkerSize', 20)
	
	legs = {'precision'};
	if maxTime < Inf; legs{numel(legs)+1} = 'time thresh'; end
	if minPrecision > 0; legs{numel(legs)+1} ='precision thresh'; end
	legs{numel(legs)+1} = 'selected';
	legend(legs, 'Location', 'SouthEast')

	subplot(2,1,2); hold on;
	plot(results(1, colTime), results(1, colRecall), 'r.', 'MarkerSize', 20)

	legs = {'recall'};
	if maxTime < Inf; legs{numel(legs)+1} = 'time thresh'; end
	if minRecall > 0; legs{numel(legs)+1} ='recall thresh'; end
	legs{numel(legs)+1} = 'selected';
	legend(legs, 'Location', 'SouthEast')
end

if size(results, 1) > 0
	feats = struct('features', results(1, colsFeatureVector), ...
				   'timePerImage', results(1, colTime), ...
				   'meanPrecision', results(1, colPrecision), ...
				   'meanRecall', results(1, colRecall));
end

end