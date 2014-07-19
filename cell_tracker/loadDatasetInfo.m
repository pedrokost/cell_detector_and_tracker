function dataParams = loadDatasetInfo(dataset)
%This is used to setup (and load) the parameters of the dataset; use as
%template for new datasets.
%
%INPUT
%   dataSet = identifier of the data set as set in the switch-case
% OUTPUT
%   dataParams = a struct containing
%         imExt      =  image extension
%         imPrefix   =  image prefix
%         imDigits   =  number of digits in image name
%         dataFolder =  folder that contains the data (if training data, it must contain the both the images and the annotations)
%         outFolder  = folder to save results and intermediary data
%         maxGaps = gaps to try to close
%         joinerClassifierParams = a struct with parameters for the join tracklets classifier
    
%Defaults
imPrefix = 'im';
imExt = 'pgm';
imDigits = 3;
maxGaps = [1 5 9]; % for the linker
rootFolder = fullfile('..', 'data');

switch dataset
    case 1 %PhaseContrast
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'phasecontrastIN');
        outFolder = fullfile(rootFolder, 'phasecontrastOUT');
        imageDims = [];  % TODO [height width]
    case 2 %LungGreen
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'series30green');
        outFolder = fullfile(rootFolder, 'series30greenOUT');
        imageDims = [512 512];  % TODO [height width]
    case 3 %LungRed
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'lungredIN');
        outFolder = fullfile(rootFolder, 'lungredOUT');
        imageDims = [512 512];  % TODO [height width]
    case 4 %KidneyGreen
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'kidneygreenIN');
        outFolder = fullfile(rootFolder, 'kidneygreenOUT');
        imageDims = [512 512];  % TODO [height width]
    case 5 %KidneyRed
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'kidneyredIN');
        outFolder = fullfile(rootFolder, 'kidneyredOUT');
        imageDims = [512 512];  % TODO [height width]
    case 6 %KidneyRed
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'dumy');
        outFolder = fullfile(rootFolder, 'dumyOUT');
        imageDims = [512 512];  % TODO [height width]
end

% Parameters for training the classifier for joining tracklets
joinerClassifierParams = struct(...
    'MIN_TRACKLET_LENGTH', 0,...
    'MAX_GAP', max(horzcat(5, maxGaps)),...
    'outputFile', fullfile(outFolder, 'matcherTrainTrackletJoinerMatrix.mat'),...
    'algorithm', 'ANN'...
);

if exist(dataFolder,'dir') ~= 7
    error('Data folder not found')
end

if exist(outFolder,'dir') ~= 7
    error('Data OUT folder not found')
end

dataParams.imExt      =      imExt;
dataParams.imPrefix   =   imPrefix;
dataParams.imDigits   =   imDigits;
dataParams.dataFolder = dataFolder;
dataParams.outFolder  =  outFolder;
dataParams.maxGaps  =  maxGaps;
dataParams.joinerClassifierParams = joinerClassifierParams;
dataParams.imageDimensions = imageDims;

end
