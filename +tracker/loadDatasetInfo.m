function params = loadDatasetInfo(dataset)
%This is used to setup (and load) the parameters of the dataset; use as
%template for new datasets.
%
% INPUT
%   dataSet = identifier of the data set as set in the switch-case
% OUTPUT
%   params = a struct containing
%         imExts      =  image extension
%         imPrefix   =  image prefix
%         imDigits   =  number of digits in image name
%         dataFolder =  folder that contains the data (if training data, it must contain the both the images and the annotations)
%         outFolder  = folder to save results and intermediary data
%         maxGaps = gaps to try to close
%         linkerClassifierParams = a struct with parameters for the join tracklets classifier
    
%Defaults
maxGaps = [9]; % for the linker

Kinit = 1;
Kterm = 1;
Kfp = 1;
Klink = 1;
% Elimate hypothesis that are below thes log-likelihoods
minPlink = log(0.51);
% minPinit = log(0.1);
% minPterm = log(0.1);
% minPfp = log(0.1);

params = dataFolders(dataset);
disp(params)

% Parameters for training the classifier for joining tracklets
linkerClassifierParams = struct(...
    'MIN_TRACKLET_LENGTH', 10,...
    'MIN_TRACKLET_SEPARATION', 20,... %  min distance between head tail of 2 tracklets to be considered as negative examples
    'MAX_TRAINING_DISPLACEMENT', 30, ... % Positive examples: only add 2 tracklets if their displacement is less than this
    'MAX_GAP', max(horzcat(5, maxGaps)),...
    'outputFileMatrix', fullfile(params.outFolder, 'linkerClassifierModelMatrix.mat'),...
    'outputFileModel', fullfile(params.outFolder, 'linkerClassifierModel.m'),...
    'algorithm', 'ANN'...  %  'ANN'
);

% Parameters for training the classifier for creating robust tracklets
robustClassifierParams = struct(...
    'outputFileMatrix', fullfile(params.outFolder, 'robustClassifierModelMatrix.mat'),...
    'outputFileModel', fullfile(params.outFolder, 'robustClassifierModel.mat'),...
    'algorithm', 'NB'...  % 'ANN', 'NB'
);

saveTrajectoryGenerationInterimResults = true;
trajectoryGenerationToFilePrefix = fullfile(params.outFolder, 'tracklets');
verbose = true;

params.maxGaps  =  maxGaps;
params.linkerClassifierParams = linkerClassifierParams;
params.robustClassifierParams = robustClassifierParams;
params.Kinit = Kinit;
params.Kterm = Kterm;
params.Kfp = Kfp;
params.Klink = Klink;
params.saveTrajectoryGenerationInterimResults = saveTrajectoryGenerationInterimResults;
params.trajectoryGenerationToFilePrefix = trajectoryGenerationToFilePrefix;
params.verbose = verbose;
params.minPlink = minPlink;
% params.minPinit = minPinit;
% params.minPterm = minPterm;
% params.minPfp   = minPfp;

end
