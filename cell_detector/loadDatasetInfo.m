function [files, imExt, dataFolder, outFolder, mserParms, tol] = loadDatasetInfo(dataset)
%This is used to setup (and load) the parameters of the dataset; use as
%template for new datasets.
%
%INPUT
%   dataSet = identifier of the data set as set in the switch-case
%OUTPUT
%   files = file names (must be the same for the images and annotations)
%   imExt = image extension
%   dataFolder = folder that contains the data (if training data, it must
%       contain the both the images and the annotations)
%   outFolder = folder to save results and intermediary data 
%
%minPixels, maxPixels, BoD(bright on dark) and DoB(dark on bright) are
%parameters of VL_feat's MSER detector. The default should cover
%all cases, but simple changes (spcially choosing BoD or DoB) can
%considerably speed up the code for a specific dataset.


%Defaults
BoD = 1;
DoB = 1;
minPixels = 10;
maxPixels = [];
Delta = 1;
MaxVariation = 1;
MinDiversity = 0.1;

switch dataset
    case 1 %PhaseContrast
        %-TRAINING DATA SET-%
        dataFolder = 'phasecontrast/trainPhasecontrast';
        outFolder = 'phasecontrast/outPhasecontrast';
        imExt = 'pgm';
        minPixels =  10;
        maxPixels = 10000;
        BoD = 0;
        DoB = 1;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 2 %PhaseContrast
        %-TESTING DATA SET-%
        dataFolder = 'phasecontrast/testPhasecontrast';
        outFolder = 'phasecontrast/outPhasecontrast';
        imExt = 'pgm';
        minPixels =  10;
        maxPixels = 10000;
        BoD = 0;
        DoB = 1;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 3 %LungGreen
        %-TRAINING DATA SET-%
        dataFolder = 'lung/trainLungGreen';
        outFolder = 'lung/outLungGreen';
        imExt = 'pgm';
        minPixels = 10;
        maxPixels = 100;
        Delta = 2;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 4 %LungGreen
        %-TESTING DATA SET-%
        dataFolder = 'lung/testLungGreen';
        outFolder = 'lung/outLungGreen';
        imExt = 'pgm';
        minPixels = 10;
        maxPixels = 100;
        Delta = 2;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 5 %LungRed
        %-TRAINING DATA SET-%
        dataFolder = 'lung/trainLungRed';
        outFolder = 'lung/outLungRed';
        imExt = 'pgm';
        minPixels = 10;
        maxPixels = 100;
        Delta = 2;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 6 %LungRed
        %-TESTING DATA SET-%
        dataFolder = 'lung/testLungRed';
        outFolder = 'lung/outLungRed';
        imExt = 'pgm';
        minPixels = 10;
        maxPixels = 100;
        Delta = 2;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 7 %KidneyGreen
        %-TRAINING DATA SET-%
        dataFolder = 'kidney/trainKidneyGreen';
        outFolder = 'kidney/outKidneyGreen';
        imExt = 'pgm';
        minPixels = 100;
        maxPixels = 1000;
        Delta = 2;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 8 %KidneyGreen
        %-TESTING DATA SET-%
        dataFolder = 'kidney/testKidneyGreen';
        outFolder = 'kidney/outKidneyGreen';
        imExt = 'pgm';
        minPixels = 100;
        maxPixels = 1000;
        Delta = 2;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 9 %KidneyRed
        %-TRAINING DATA SET-%
        dataFolder = 'kidney/trainKidneyRed';
        outFolder = 'kidney/outKidneyRed';
        imExt = 'pgm';
        minPixels = 100;
        maxPixels = 500;
        Delta = 5;
        MaxVariation = 0.5;
        tol = 8; %Tolerance (pixels) for evaluation only
    case 10 %KidneyRed
        %-TESTING DATA SET-%
        dataFolder = 'kidney/testKidneyRed';
        outFolder = 'kidney/outKidneyRed';
        imExt = 'pgm';
        minPixels = 100;
        maxPixels = 500;
        Delta = 5;
        MaxVariation = 0.5;
        tol = 8; %Tolerance (pixels) for evaluation only
end

if exist(dataFolder,'dir') ~= 7
    error('Data folder not found')
end

if exist(outFolder,'dir') ~= 7
    error('Output folder not found')
end

files = dir(fullfile(dataFolder,['*.' imExt]));
[~,files] = cellfun(@fileparts, {files.name}, 'UniformOutput',false);
mserParms.bod = BoD;
mserParms.dob = DoB;
mserParms.minPix = minPixels;
mserParms.maxPix = maxPixels;
mserParms.minDiv = MinDiversity;
mserParms.delta = Delta;
mserParms.maxVar = MaxVariation;


end
