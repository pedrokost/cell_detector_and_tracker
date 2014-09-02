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
plotProgress = true; % Shows a plot of annotation, mapped detection, robust tracklets, and trajectories together

maxGaps = [9]; % for the linker. Size of gaps to learn to close. Can have multivalue [1, 5, 9]

Kinit = 1;
Kterm = 1;
Kfp   = 1;
Klink = 1;
discardSingleTracklets = true; % When creating trajectories, do not take into acount short tracklets... faster... worse
% Elimate hypothesis that are below these log-likelihoods:
minPlink = log(0.51);

params = dataFolders(dataset);
% disp(params)

% Parameters for training the classifier for joining tracklets
linkerClassifierParams = struct(...
    'MIN_TRACKLET_LENGTH', 10,...
    'MIN_TRACKLET_SEPARATION', 20,... %  min distance between head tail of 2 tracklets to be considered as negative examples
    'MAX_TRAINING_DISPLACEMENT', 20, ... % Positive examples: only add 2 tracklets parts if their displacement is less than this
    'MAX_DISPLACEMENT_LINK', 20, ... % do not consider link hypothesis where the tracklets are more than this amount apart. It's just to reduce the number of hypothesis.
    'MAX_GAP', max(horzcat(5, maxGaps)),...
    'outputFileMatrix', fullfile(params.outFolder, 'linkerClassifierModelMatrix.mat'),...
    'outputFileModel', fullfile(params.outFolder, 'linkerClassifierModel.m'),...
    'algorithm', 'ANN'...  %  'ANN'
);

% Parameters for training the classifier for creating robust tracklets
robustClassifierParams = struct(...
    'MIN_TRACKLET_SEPARATION', 20,... %  min distance between head tail of 2 tracklets to be considered as negative examples
    'outputFileMatrix', fullfile(params.outFolder, 'robustClassifierModelMatrix.mat'),...
    'outputFileModel', fullfile(params.outFolder, 'robustClassifierModel.mat'),...
    'algorithm', 'NB'...  % 'ANN', 'NB'
);

saveTrajectoryGenerationInterimResults = true;
trajectoriesOutputFile = fullfile(params.outFolder, 'tracklets');
verbose = true;

params.linkerClassifierParams = linkerClassifierParams;
params.robustClassifierParams = robustClassifierParams;
params.saveTrajectoryGenerationInterimResults = saveTrajectoryGenerationInterimResults;
params.trajectoriesOutputFile = trajectoriesOutputFile;
params.verbose = verbose;
params.discardSingleTracklets = discardSingleTracklets;
params.plotProgress = plotProgress;

if ~isfield(params, 'Kinit')
    params.Kinit = Kinit;
end
if ~isfield(params, 'Kterm')
    params.Kterm = Kterm;
end
if ~isfield(params, 'Kfp')
    params.Kfp   = Kfp;
end
if ~isfield(params, 'Klink')
    params.Klink = Klink;
end
if ~isfield(params, 'maxGaps')
    params.maxGaps = maxGaps;
end
if ~isfield(params, 'minPlink')
    params.minPlink = minPlink;
end

end
