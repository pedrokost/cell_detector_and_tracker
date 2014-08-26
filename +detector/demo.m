% -------------------------------------------------------------------Configure

% dataset 2, 4 failsex
datasets = [5];  %Identifier of the training/testing data as set in loadDatasetInfo
train = 1;%---->Do train
test = 1;%----->Do test

rng(1234);
% ---------------------------------------------------No need to touch the rest

overrides = struct(); %('testAll', true, 'trainSplit', 0.7, 'features', [1 0 1 1 1 1 0]);

if train
	for dataset=datasets
		fprintf('Training dataset %d\n', dataset);
		detector.trainDetector(dataset, overrides);
	end
end

if test
	for dataset=datasets
		fprintf('Testing dataset %d\n', dataset);
		metrics = detector.detectCells(dataset, overrides);
	end
end