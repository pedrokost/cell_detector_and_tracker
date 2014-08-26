function params = loadDatasetInfo(dataset, options)
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
if ~isfield(options, 'trainSplit');
	trainSplit = 1;
else
	trainSplit = options.trainSplit;
end
if ~isfield(options, 'features');
	features = [1 1 0 1 1 1 0]; % Use default from setFeatures
else
	features = options.features;
end

%Defaults
BoD = 1;
DoB = 0;
minPixels = 20;
maxPixels = 200;
Delta = 4;
MaxVariation = 1;
MinDiversity = 0.4;
tol = 20;  %Tolerance (pixels) for evaluation only
params = dataFolders(dataset);

files = dir(fullfile(params.dotFolder, [params.imPrefix, '*.' params.imExt]));

[~,files] = cellfun(@fileparts, {files.name}, 'UniformOutput',false);

numTrainImgs = round(trainSplit * params.numAnnotatedFrames);

trainFiles = datasample(files(1:params.numAnnotatedFrames), ...
    numTrainImgs, 'Replace', false);
trainFiles = sort(trainFiles);

if options.testAll
    testFiles = files;
else
	files = files(1:params.numAnnotatedFrames);
    testFiles = setdiff(files, trainFiles);
end

% fprintf('Training on %d/%d of the files. ', numel(trainFiles), numel(files));
% fprintf('Testing on %d/%d of the files.\n', numel(testFiles), numel(files));

% randomize the order of train files
% trainFiles = {trainFiles{randperm(numel(trainFiles))}};

mserParms.bod = BoD;
mserParms.dob = DoB;
mserParms.minPix = minPixels;
mserParms.maxPix = maxPixels;
mserParms.minDiv = MinDiversity;
mserParms.delta = Delta;
mserParms.maxVar = MaxVariation;


params.trainFiles = trainFiles;
params.testFiles  =  testFiles;
params.mserParms  =  mserParms;
params.tol        =        tol;
params.features   =   features;


end
