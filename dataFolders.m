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
        numAnnotatedTrajectories = 1;  % since 1 is fully undedetect

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
        numAnnotatedTrajectories = 14;
    case 3 %LungGreen
        dotFolder = fullfile(rootDotFolder, 'series13greencropped');
        outFolder = fullfile(rootOutFolder, 'series13greencropped');
        linkFolder = fullfile(rootLinkFolder, 'series13greencropped_fortrajectories');
        imageDims = [251 251];
        numAnnotatedFrames = 58;
        numAnnotatedTrajectories = 7;
    case 4 %LungGreen
        dotFolder = fullfile(rootDotFolder, 'series14croppedcleaned');
        outFolder = fullfile(rootOutFolder, 'series14croppedcleaned');
        linkFolder = fullfile(rootLinkFolder, 'series14croppedcleaned_fortrajectories');
        imageDims = [199 199];
        numAnnotatedFrames = 53;
        numAnnotatedTrajectories = 5;
        minPlink = log(0.70);
    case 5 %KidneyRed
        dotFolder = fullfile(rootDotFolder, 'seriesm170_13cropped');
        outFolder = fullfile(rootOutFolder, 'seriesm170_13cropped');
        linkFolder = fullfile(rootDotFolder, 'seriesm170_13cropped_fortrajectories');
        imageDims = [277 277];
        numAnnotatedFrames = 67;
        numAnnotatedTrajectories = 7;
        maxGaps = [9 20];
        Kinit = 3;
        Kterm = 3;
        Kfp   = 1;
        Klink = 1;
    case 7 %KidneyRed
        dotFolder = fullfile(rootDotFolder, 'dumy');
        outFolder = fullfile(rootOutFolder, 'dumy');
        linkFolder = dotFolder;
        numAnnotatedFrames = 17;
        numAnnotatedTrajectories = 2;
    case 9 % combined datasets 1 2 3 4 5
        dotFolder = fullfile(rootDotFolder, 'combineddataset');
        outFolder = fullfile(rootOutFolder, 'combineddataset');
        linkFolder = fullfile(rootDotFolder, 'combineddataset');
        numAnnotatedFrames = 186;
        numAnnotatedTrajectories = 14;
    case 10 %LungRed
        dotFolder = fullfile(rootDotFolder, 'singleddatasets-1');
        linkFolder = fullfile(rootLinkFolder, 'singleddatasets-1');
        outFolder = fullfile(rootOutFolder, 'singleddatasets-1');
        numAnnotatedFrames = 66;
        numAnnotatedTrajectories = 2;
    case 11 %KidneyGreen
        dotFolder = fullfile(rootDotFolder, 'singleddatasets-2');
        linkFolder = fullfile(rootLinkFolder, 'singleddatasets-2');
        outFolder = fullfile(rootOutFolder, 'singleddatasets-2');
        numAnnotatedFrames = 66;
        numAnnotatedTrajectories = 8;
    case 12 %LungGreen
        dotFolder = fullfile(rootDotFolder, 'singleddatasets-3');
        linkFolder = fullfile(rootLinkFolder, 'singleddatasets-3');
        outFolder = fullfile(rootOutFolder, 'singleddatasets-3');
        imageDims = [251 251];
        numAnnotatedFrames = 58;
        numAnnotatedTrajectories = 2;
    case 13 %LungGreen
        dotFolder = fullfile(rootDotFolder, 'singleddatasets-4');
        linkFolder = fullfile(rootLinkFolder, 'singleddatasets-4');
        outFolder = fullfile(rootOutFolder, 'singleddatasets-4');
        imageDims = [199 199];
        numAnnotatedFrames = 53;
        numAnnotatedTrajectories = 2;
    case 14 %KidneyRed
        dotFolder = fullfile(rootDotFolder, 'singleddatasets-5');
        linkFolder = fullfile(rootLinkFolder, 'singleddatasets-5');
        outFolder = fullfile(rootOutFolder, 'singleddatasets-5');
        imageDims = [277 277];
        numAnnotatedFrames = 67;
        numAnnotatedTrajectories = 2;
    case 15
        dotFolder = fullfile(rootDotFolder, 'combineddataset_1_2_3_4_5_fortrajectories');
        outFolder = fullfile(rootOutFolder, 'combineddataset_1_2_3_4_5_fortrajectories');
        linkFolder = fullfile(rootDotFolder, 'combineddataset_1_2_3_4_5_fortrajectories');
        numAnnotatedFrames = 310;
        numAnnotatedTrajectories = 34;
    case 16
        dotFolder = fullfile(rootDotFolder, 'combineddataset_1_2_3_fortrajectories');
        outFolder = fullfile(rootOutFolder, 'combineddataset_1_2_3_fortrajectories');
        linkFolder = fullfile(rootDotFolder, 'combineddataset_1_2_3_fortrajectories');
        numAnnotatedFrames = 190;
        numAnnotatedTrajectories = 22;
    case 17
        dotFolder = fullfile(rootDotFolder, 'combineddataset_1_2_3_5_fortrajectories');
        outFolder = fullfile(rootOutFolder, 'combineddataset_1_2_3_5_fortrajectories');
        linkFolder = fullfile(rootDotFolder, 'combineddataset_1_2_3_5_fortrajectories');
        numAnnotatedFrames = 257;
        numAnnotatedTrajectories = 29;
    case 18
        dotFolder = fullfile(rootDotFolder, 'combineddataset_1_2_fortrajectories');
        outFolder = fullfile(rootOutFolder, 'combineddataset_1_2_fortrajectories');
        linkFolder = fullfile(rootDotFolder, 'combineddataset_1_2_fortrajectories');
        numAnnotatedFrames = 132;
        numAnnotatedTrajectories = 9;


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
if exist('Kinit', 'var')
    folders.Kinit = Kinit;
end
if exist('Kterm', 'var')
    folders.Kterm = Kterm;
end
if exist('Kfp', 'var')
    folders.Kfp   = Kfp;
end
if exist('Klink', 'var')
    folders.Klink = Klink;
end
if exist('maxGaps', 'var')
    folders.maxGaps = maxGaps;
end
if exist('minPlink', 'var')
    folders.minPlink = minPlink;
end

end
