% -------------------------------------------------------------------Configure

% dataset 2, 4 failsex
datasets = [3];  %Identifier of the training/testing data as set in loadDatasetInfo
train = 1;%---->Do train
test = 1;%----->Do test

% ---------------------------------------------------No need to touch the rest

opts = ctrlParams();

if train
	for dataset=datasets
		trainCellDetector(dataset, opts);
	end
end

if test
	for dataset=datasets
		detectCells(dataset, opts);
	end
end


