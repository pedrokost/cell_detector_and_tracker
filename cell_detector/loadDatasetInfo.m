function dataParams = loadDatasetInfo(dataset, options)
%This is used to setup (and load) the parameters of the dataset; use as
%template for new datasets.
%
%INPUT
%   dataSet = identifier of the data set as set in the switch-case
%   options = a struct with options to override defaults
%       testAll = 1 if the ML algorithm should be tested on the complete dataset
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

if nargin < 2; options = struct; end
if ~isfield(options, 'testAll'); options.testAll = false; end

%Defaults
BoD = 1;
DoB = 1;
minPixels = 30;
maxPixels = 200;
Delta = 4;
MaxVariation = 1;
MinDiversity = 0.1;
imPrefix = 'im';
imExt = 'pgm';
tol = 8;  %Tolerance (pixels) for evaluation only
trainsplit = 0.9;  % percentage of data to be used for training 
features = [1 1 1 1 1 1 1]; % Use default from setFeatures
rootInFolder = fullfile('..','..', 'data');
rootOutFolder = fullfile('..','..', 'dataout');


switch dataset
    case 1 %LungGreen
        dataFolder = fullfile(rootInFolder, 'series13greencropped');
        outFolder = fullfile(rootOutFolder, 'series13greencropped');
        annotatedFrames = 55;
    case 2 %LungGreen
        dataFolder = fullfile(rootInFolder, 'series14croppedcleaned');
        outFolder = fullfile(rootOutFolder, 'series14croppedcleaned');
        annotatedFrames = 54;
    case 3 %LungRed
        dataFolder = fullfile(rootInFolder, 'series30green');
        outFolder = fullfile(rootOutFolder, 'series30green');
        annotatedFrames = 60;
    case 4 %KidneyGreen
        dataFolder = fullfile(rootInFolder, 'series30red');
        outFolder = fullfile(rootOutFolder, 'series30red');
        annotatedFrames = 60;
    case 5 %KidneyRed
        dataFolder = fullfile(rootInFolder, 'seriesm170_13cropped');
        outFolder = fullfile(rootOutFolder, 'seriesm170_13cropped');
        annotatedFrames = 67;
    case 6 %KidneyRed
        dataFolder = fullfile(rootInFolder, 'series13redcropped');
        outFolder = fullfile(rootOutFolder, 'series13redcropped');
        annotatedFrames = 12;
end

if exist(dataFolder,'dir') ~= 7
    error('Data folder not found')
end

if exist(outFolder,'dir') ~= 7
    mkdir(outFolder);
    fprintf('Created folder "%s"', outFolder);
end

files = dir(fullfile(dataFolder,[imPrefix, '*.' imExt]));
% files = files(1:7)
[~,files] = cellfun(@fileparts, {files.name}, 'UniformOutput',false);

trainImgs = round(trainsplit * annotatedFrames);

trainFiles = datasample(files(1:annotatedFrames), ...
    trainImgs,...
    'Replace', false);
trainFiles = sort(trainFiles);

if options.testAll
    testFiles = files;
else
    testFiles = setdiff(files, trainFiles);
end


mserParms.bod = BoD;
mserParms.dob = DoB;
mserParms.minPix = minPixels;
mserParms.maxPix = maxPixels;
mserParms.minDiv = MinDiversity;
mserParms.delta = Delta;
mserParms.maxVar = MaxVariation;


dataParams.trainFiles = trainFiles;
dataParams.testFiles  =  testFiles;
dataParams.imExt      =      imExt;
dataParams.dataFolder = dataFolder;
dataParams.outFolder  =  outFolder;
dataParams.mserParms  =  mserParms;
dataParams.tol        =        tol;
dataParams.features   =   features;


end
