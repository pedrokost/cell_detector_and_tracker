function [trainFiles, testFiles, imExt, dataFolder, outFolder, mserParms, tol] = loadDatasetInfo(dataset, options)
%This is used to setup (and load) the parameters of the dataset; use as
%template for new datasets.
%
%INPUT
%   dataSet = identifier of the data set as set in the switch-case
%   options = a struct with options to override defaults
%OUTPUT
%   trainFiles = file names used for training (must be the same for the images
%        and annotations)
%   testFiles = file names used for testing (must be the same for the images
%        and annotations)
%   imExt = image extension
%   dataFolder = folder that contains the data (if training data, it must
%       contain the both the images and the annotations)
%   outFolder = folder to save results and intermediary data
%
%minPixels, maxPixels, BoD(bright on dark) and DoB(dark on bright) are
%parameters of VL_feat's MSER detector. The default should cover
%all cases, but simple changes (spcially choosing BoD or DoB) can
%considerably speed up the code for a specific dataset.

% NOTE: It is recommended to use rng to always load the same datasets


%Defaults
BoD = 1;
DoB = 1;
minPixels = 10;
maxPixels = [];
Delta = 1;
MaxVariation = 1;
MinDiversity = 0.1;
imExt = 'pgm';
trainsplit = 0.7;  % percentage of data to be used for training 

rootFolder = fullfile('..', 'data');

switch dataset
    case 1 %PhaseContrast
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'phasecontrastIN');
        outFolder = fullfile(rootFolder, 'phasecontrastOUT');
        minPixels =  10;
        maxPixels = 10000;
        BoD = 0;
        DoB = 1;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 2 %LungGreen
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'lunggreenIN');
        outFolder = fullfile(rootFolder, 'lunggreenOUT');
        minPixels = 10;
        maxPixels = 100;
        Delta = 2;
        tol = 8; %Tolerance (pixels) for evaluation only
        %      features: [1 0 1 1 1 1 0]
        %  timePerImage: 1.6950
        % meanPrecision: 0.8907
        %    meanRecall: 0.9082
    case 3 %LungRed
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'lungredIN');
        outFolder = fullfile(rootFolder, 'lungredOUT');
        minPixels = 10;
        maxPixels = 100;
        Delta = 2;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 4 %KidneyGreen
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'kidneygreenIN');
        outFolder = fullfile(rootFolder, 'kidneygreenOUT');
        minPixels = 100;
        maxPixels = 1000;
        Delta = 2;
        tol = 8; %Tolerance (pixels) for evaluation only
        %      features: [1 1 0 0 0 0 0]
        %  timePerImage: 0.5353
        % meanPrecision: 0.6833
        %    meanRecall: 0.9600
    case 5 %KidneyRed
        %-TRAINING DATA SET-%
        dataFolder = fullfile(rootFolder, 'kidneyredIN');
        outFolder = fullfile(rootFolder, 'kidneyredOUT');
        minPixels = 100;
        maxPixels = 500;
        Delta = 5;
        MaxVariation = 0.5;
        tol = 8; %Tolerance (pixels) for evaluation only
        %      features: [1 0 0 1 1 0 1]
        %  timePerImage: 0.8688
        % meanPrecision: 0.6920
        %    meanRecall: 0.9577
end

if exist(dataFolder,'dir') ~= 7
    error('Data folder not found')
end

if exist(outFolder,'dir') ~= 7
    error('Output folder not found')
end



files = dir(fullfile(dataFolder,['*.' imExt]));
[~,files] = cellfun(@fileparts, {files.name}, 'UniformOutput',false);


trainFiles = datasample(files, ...
    round(trainsplit * numel(files)),...
    'Replace', false);
trainFiles = sort(trainFiles);
testFiles = setdiff(files, trainFiles);


mserParms.bod = BoD;
mserParms.dob = DoB;
mserParms.minPix = minPixels;
mserParms.maxPix = maxPixels;
mserParms.minDiv = MinDiversity;
mserParms.delta = Delta;
mserParms.maxVar = MaxVariation;


end
