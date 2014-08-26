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
        linkFolder = fullfile(rootLinkFolder, 'series30green_fortrajectories');
        outFolder = fullfile(rootOutFolder, 'series30green');
        numAnnotatedFrames = 66;
        numAnnotatedTrajectories = 2;

        % THE problem with this dataset is the sudden change of contrast when it
        % switches from frame 17 to 18. At that point all the background starts
        % looking like all the positive examples in the previous frames, which means
        % that a lot of negative examples are generated which cancel out all
        % learned in the first 17 frames

    case 2 %KidneyGreen
        dotFolder = fullfile(rootDotFolder, 'series30red');
        outFolder = fullfile(rootOutFolder, 'series30red');
        linkFolder = fullfile(rootDotFolder, 'series30red_fortrajectories');
        numAnnotatedFrames = 66;
        numAnnotatedTrajectories = 8;
    case 3 %LungGreen
        dotFolder = fullfile(rootDotFolder, 'series13greencropped');
        outFolder = fullfile(rootOutFolder, 'series13greencropped');
        linkFolder = fullfile(rootLinkFolder, 'series13greencropped_fortrajectories');
        imageDims = [251 251];
        numAnnotatedFrames = 58;
        numAnnotatedTrajectories = 2;
    case 4 %LungGreen
        dotFolder = fullfile(rootDotFolder, 'series14croppedcleaned');
        outFolder = fullfile(rootOutFolder, 'series14croppedcleaned');
        linkFolder = fullfile(rootLinkFolder, 'series14croppedcleaned_fortrajectories');
        imageDims = [199 199];
        numAnnotatedFrames = 53;
        numAnnotatedTrajectories = 2;
    case 5 %KidneyRed
        dotFolder = fullfile(rootDotFolder, 'seriesm170_13cropped');
        outFolder = fullfile(rootOutFolder, 'seriesm170_13cropped');
        linkFolder = fullfile(rootDotFolder, 'seriesm170_13cropped_fortrajectories');
        imageDims = [277 277];
        numAnnotatedFrames = 67;
        numAnnotatedTrajectories = 2;
    case 7 %KidneyRed
        dotFolder = fullfile(rootDotFolder, 'dumy');
        outFolder = fullfile(rootOutFolder, 'dumy');
        linkFolder = dotFolder;
        numAnnotatedFrames = 30;
        numAnnotatedTrajectories = 2;
    case 8 % combined datasets 1 2
        dotFolder = fullfile(rootDotFolder, 'combineddataset_1_2');
        outFolder = fullfile(rootOutFolder, 'combineddataset_1_2');
        linkFolder = fullfile(rootDotFolder, 'combineddataset_1_2_fortrajectories');
        numAnnotatedFrames = 120;
        numAnnotatedTrajectories = 10;
    case 9 % combined datasets 1 2 3 4 5
        dotFolder = fullfile(rootDotFolder, 'combineddataset_1_2_3_4_5');
        outFolder = fullfile(rootOutFolder, 'combineddataset_1_2_3_4_5');
        linkFolder = fullfile(rootDotFolder, 'combineddataset_1_2_3_4_5_fortrajectories');
        numAnnotatedFrames = 310;
        numAnnotatedTrajectories = 16;
end

if exist(dotFolder,'dir') ~= 7
    error('Detection folder not found (%s)', dotFolder)
end

if exist(linkFolder,'dir') ~= 7
    error('Link folder not found (%s)', linkFolder)
end

if exist(outFolder,'dir') ~= 7
    % TODO: Prompt to create one
    % If use confirms: create it
    % Else throw error
    error('Out folder not found (%s)', outFolder)
end

folders.imExt      =      imExt;
folders.imPrefix   =   imPrefix;
folders.imDigits   =   imDigits;
folders.dotFolder  = dotFolder;
folders.linkFolder = linkFolder;
folders.rootOutFolder = rootOutFolder;
folders.rootDotFolder = rootDotFolder;
folders.rootLinkFolder = rootLinkFolder;
folders.outFolder  =  outFolder;
folders.imageDimensions = imageDims;
folders.numAnnotatedFrames = numAnnotatedFrames;
folders.numAnnotatedTrajectories = numAnnotatedTrajectories;

end
