%                _                        _   _       
%     /\        | |                      | | (_)      
%    /  \  _   _| |_ ___  _ __ ___   __ _| |_ _  ___  
%   / /\ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ __| 
%  / ____ \ |_| | || (_) | | | | | | (_| | |_| | (__  
% /_/    \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___|   
%           _ _       _      _            _              
%          | | |     | |    | |          | |             
%   ___ ___| | |   __| | ___| |_ ___  ___| |_ ___  _ __  
%  / __/ _ \ | |  / _` |/ _ \ __/ _ \/ __| __/ _ \| '__| 
% | (_|  __/ | | | (_| |  __/ ||  __/ (__| || (_) | |    
%  \___\___|_|_|  \__,_|\___|\__\___|\___|\__\___/|_|    

% Authors: Arteta et al, with modifications, perf. improvements, added utilities, etc by Pedro Damian Kostelec

% -------------------------------------------------------------------Configure

datasets = 4:5;  %Identifier of the training/testing data as set in loadDatasetInfo
train = 1;%---->Do train
test = 1;%----->Do test

rng(1234);
% ---------------------------------------------------No need to touch the rest

overrides = struct('testAll', true, 'trainSplit', 1, 'features', [1 1 0 1 1 1 0]);
ctrlParams = detector.ctrlParams(overrides);


for dataset=datasets
	dataParams = detector.loadDatasetInfo(dataset, ctrlParams);
	if train
		fprintf('Training dataset %d\n', dataset);
		detector.trainDetector(dataset, ctrlParams, dataParams);
	end
	if test
		fprintf('Testing dataset %d\n', dataset);
		metrics = detector.detectCells(dataset, ctrlParams, dataParams);
	end
end
