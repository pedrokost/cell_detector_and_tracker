function folders = dataFolders(datasetID)
%This is used to specify the data folders
%
% INPUT
%   dataSet = identifier of the data set as set in the switch-case
% OUTPUT
%   folders = a struct containing
%         imExt      =  [pgm] image extension
%         imPrefix   =  [im] image prefix
%         imDigits   =  [3] number of digits in image name
%         dotFolder  =  folder that contains the images and dot-detections
%         linkFolder =  folder that contains the images and link-detections
%         outFolder  =  folder to save results and intermediary data

%Defaults
imPrefix = 'im';
imExt = 'pgm';
imDigits = 3;
imageDims = [512 512];  % TODO [height width]

rootDotFolder = fullfile('..', 'data');
rootLinkFolder = fullfile('..', 'data');
rootOutFolder = fullfile('..', 'dataout');

switch datasetID
    case 1 %LungRed
        dotFolder = fullfile(rootDotFolder, 'series30green');
        outFolder = fullfile(rootOutFolder, 'series30green');
        linkFolder = fullfile(rootLinkFolder, 'series30green_fortrajectories');
        numAnnotatedFrames = 60;
    case 2 %KidneyGreen
        dotFolder = fullfile(rootDotFolder, 'series30red');
        outFolder = fullfile(rootOutFolder, 'series30red');
        linkFolder = dotFolder;
        numAnnotatedFrames = 60;
    case 3 %LungGreen
        dotFolder = fullfile(rootDotFolder, 'series13greencropped');
        outFolder = fullfile(rootOutFolder, 'series13greencropped');
        linkFolder = fullfile(rootLinkFolder, 'series13greencropped_fortrajectories');
        imageDims = [251 251];
        numAnnotatedFrames = 55;
    case 4 %LungGreen
        dotFolder = fullfile(rootDotFolder, 'series14croppedcleaned');
        outFolder = fullfile(rootOutFolder, 'series14croppedcleaned');
        linkFolder = fullfile(rootLinkFolder, 'series14croppedcleaned_fortrajectories');
        imageDims = [199 199];
        numAnnotatedFrames = 50;
    case 5 %KidneyRed
        dotFolder = fullfile(rootDotFolder, 'seriesm170_13cropped');
        outFolder = fullfile(rootOutFolder, 'seriesm170_13cropped');
        linkFolder = dotFolder;
        imageDims = [277 277];
        numAnnotatedFrames = 67;
    case 6 %KidneyRed
        dotFolder = fullfile(rootDotFolder, 'series13redcropped');
        outFolder = fullfile(rootOutFolder, 'series13redcropped');
        linkFolder = dotFolder;
        numAnnotatedFrames = 32;
    case 7 %KidneyRed
        dotFolder = fullfile(rootDotFolder, 'dumy');
        outFolder = fullfile(rootOutFolder, 'dumy');
        linkFolder = dotFolder;
        numAnnotatedFrames = 30;
end

if exist(dotFolder,'dir') ~= 7
    error('Detection folder not found')
end

if exist(linkFolder,'dir') ~= 7
    error('Link folder not found')
end

if exist(outFolder,'dir') ~= 7
    % TODO: Prompt to create one
    % If use confirms: create it
    % Else throw error
    error('Out folder not found')
end

folders.imExt      =      imExt;
folders.imPrefix   =   imPrefix;
folders.imDigits   =   imDigits;
folders.dotFolder  = dotFolder;
folders.linkFolder = linkFolder;
folders.outFolder  =  outFolder;
folders.imageDimensions = imageDims;
folders.numAnnotatedFrames = numAnnotatedFrames;

end
