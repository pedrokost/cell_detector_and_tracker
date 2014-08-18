% -------------------------------------------------------------------Configure

% dataset 2, 4 failsex
datasets = [6];  %Identifier of the training/testing data as set in loadDatasetInfo
train = 0;%---->Do train
test = 1;%----->Do test

% ---------------------------------------------------No need to touch the rest

opts = ctrlParams();

if train
	for dataset=datasets
		fprintf('Training dataset %d\n', dataset);
		trainCellDetector(dataset, opts);
	end
end

if test
	for dataset=datasets
		fprintf('Testing dataset %d\n', dataset);
		detectCells(dataset, opts);
	end
end


