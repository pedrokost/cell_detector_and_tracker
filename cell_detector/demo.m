% -------------------------------------------------------------------Configure

% dataset 2, 4 failsex
datasets = [4];  %Identifier of the training/testing data as set in loadDatasetInfo
train = 1;%---->Do train
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
		detectCells(dataset, opts);
	end
end


