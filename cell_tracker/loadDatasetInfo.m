function dataParams = loadDatasetInfo(dataset)
%This is used to setup (and load) the parameters of the dataset; use as
%template for new datasets.
%
% INPUT
%   dataSet = identifier of the data set as set in the switch-case
% OUTPUT
%   dataParams = a struct containing
%         imExts      =  image extension
%         imPrefix   =  image prefix
%         imDigits   =  number of digits in image name
%         dataFolder =  folder that contains the data (if training data, it must contain the both the images and the annotations)
%         outFolder  = folder to save results and intermediary data
%         maxGaps = gaps to try to close
%         linkerClassifierParams = a struct with parameters for the join tracklets classifier
    
%Defaults
imPrefix = 'im';
imExts = {'pgm', 'png', 'jpg'};
imDigits = 3;
maxGaps = [9]; % for the linker
rootFolder = fullfile('..', 'data');
imageDims = [512 512];  % TODO [height width]


Kinit = 2;
Kterm = 2;
Kfp = 1;
Klink = 0.7;

rootInFolder = fullfile('..','..', 'data');
rootOutFolder = fullfile('..','..', 'dataout');

switch dataset
    case 1 %LungGreen
        dataFolder = fullfile(rootInFolder, 'series13greencropped');
        outFolder = fullfile(rootOutFolder, 'series13greencropped');
        numAnnotatedFrames = 55;
    case 2 %LungGreen
        dataFolder = fullfile(rootInFolder, 'series14croppedcleaned');
        outFolder = fullfile(rootOutFolder, 'series14croppedcleaned');
        numAnnotatedFrames = 50;
    case 3 %LungRed
        dataFolder = fullfile(rootInFolder, 'series30green');
        outFolder = fullfile(rootOutFolder, 'series30green');
        numAnnotatedFrames = 60;
    case 4 %KidneyGreen
        dataFolder = fullfile(rootInFolder, 'series30red');
        outFolder = fullfile(rootOutFolder, 'series30red');
        numAnnotatedFrames = 60;
    case 5 %KidneyRed
        dataFolder = fullfile(rootInFolder, 'seriesm170_13cropped');
        outFolder = fullfile(rootOutFolder, 'seriesm170_13cropped');
        numAnnotatedFrames = 67;
    case 6 %KidneyRed
        dataFolder = fullfile(rootInFolder, 'series13redcropped');
        outFolder = fullfile(rootOutFolder, 'series13redcropped');
        numAnnotatedFrames = 32;
    case 7 %KidneyRed
        dataFolder = fullfile(rootInFolder, 'dumy');
        outFolder = fullfile(rootOutFolder, 'dumy');
        numAnnotatedFrames = 30;
end

% Parameters for training the classifier for joining tracklets
linkerClassifierParams = struct(...
    'MIN_TRACKLET_LENGTH', 10,...
    'MIN_TRACKLET_SEPARATION', 20,... %  min distance between head tail of 2 tracklets to be considered as negative examples
    'MAX_TRAINING_DISPLACEMENT', 30, ... % Positive examples: only add 2 tracklets if their displacement is less than this
    'MAX_GAP', max(horzcat(5, maxGaps)),...
    'outputFileMatrix', fullfile(outFolder, 'linkerClassifierModelMatrix.mat'),...
    'outputFileModel', fullfile(outFolder, 'linkerClassifierModel.m'),...
    'algorithm', 'ANN'...  %  'ANN'
);

% Parameters for training the classifier for creating robust tracklets
robustClassifierParams = struct(...
    'outputFileMatrix', fullfile(outFolder, 'robustClassifierModelMatrix.mat'),...
    'outputFileModel', fullfile(outFolder, 'robustClassifierModel.mat'),...
    'algorithm', 'NB'...  % 'ANN', 'NB'
);

saveTrajectoryGenerationInterimResults = true;
trajectoryGenerationToFilePrefix = fullfile(outFolder, 'tracklets');
verbose = true;

if exist(dataFolder,'dir') ~= 7
    error('Data folder not found')
end

if exist(outFolder,'dir') ~= 7
    error('Data OUT folder not found')
end

dataParams.imExts      =      imExts;
dataParams.imPrefix   =   imPrefix;
dataParams.imDigits   =   imDigits;
dataParams.dataFolder = dataFolder;
dataParams.outFolder  =  outFolder;
dataParams.maxGaps  =  maxGaps;
dataParams.linkerClassifierParams = linkerClassifierParams;
dataParams.robustClassifierParams = robustClassifierParams;
dataParams.imageDimensions = imageDims;
dataParams.Kinit = Kinit;
dataParams.Kterm = Kterm;
dataParams.Kfp = Kfp;
dataParams.Klink = Klink;
dataParams.saveTrajectoryGenerationInterimResults = saveTrajectoryGenerationInterimResults;
dataParams.trajectoryGenerationToFilePrefix = trajectoryGenerationToFilePrefix;
dataParams.verbose = verbose;
dataParams.numAnnotatedFrames = numAnnotatedFrames;

end
