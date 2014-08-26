%{
	Creates combined datasets for training and testing detector and tracker
%}
clear all

%----------------------------------------------------------------Configuration

doDetectionOrTracking = 'det';  % one of{'det' 'track'}

doTrainingOrTestingDataset = 'train';  % one of {'test', 'train'} % creates a large dataset combined of several smaller ones
% on the combined model is trained, us this to generate several small datasets such that the combined model can be tested on each original dataset separately.

datasets = 1:5; % Datasets to combine

fileInitNum = 1;
filePrefix = 'im';
numDigits = 3;
combinedDatasetBaseName = 'combineddataset';
singledDatasetBaseName = 'singleddatasets';

%----------------------------------------------------------------Train dataset
if numel(datasets) < 2
	error('Theres no point in combining only one dataset')
end

cd('..')
addpath('evaluations')

% Joins smaller datasets into a larger one
if strcmp(doTrainingOrTestingDataset, 'train')
	folders = createCombinedFolderNames(doDetectionOrTracking, doTrainingOrTestingDataset, datasets, combinedDatasetBaseName, singledDatasetBaseName);
elseif strcmp(doTrainingOrTestingDataset, 'test')
	folders = createCombinedFolderNames(doDetectionOrTracking, doTrainingOrTestingDataset, datasets, combinedDatasetBaseName, singledDatasetBaseName);
end

createCombinedDatasetFolders(doDetectionOrTracking, doTrainingOrTestingDataset, folders);


matfilenames = sprintf('%s*.mat', filePrefix);
pgmfilenames = sprintf('%s*.pgm', filePrefix);


if strcmp(doDetectionOrTracking , 'det')

	if strcmp(doTrainingOrTestingDataset, 'train')
		startNum = fileInitNum;
		for i=1:numel(datasets)
			fprintf('Copying files from dataset %d\n', datasets(i));
			fldr = dataFolders(datasets(i));

			matfiles = dir(fullfile(fldr.dotFolder, matfilenames));
			matfiles = matfiles(1:fldr.numAnnotatedFrames);

			endNum = startNum + fldr.numAnnotatedFrames;
			destinationNames = prepareFileNames(filePrefix, numDigits, 'mat', folders.dotFolder, startNum, endNum);

			for i=1:fldr.numAnnotatedFrames
				sourceFile = fullfile(fldr.dotFolder, matfiles(i).name);
				destFile = destinationNames{i};
				copyfile(sourceFile, destFile);
			end

			pgmfiles = dir(fullfile(fldr.dotFolder, pgmfilenames));
			pgmfiles = pgmfiles(1:fldr.numAnnotatedFrames);

			destinationNames = prepareFileNames(filePrefix, numDigits, 'pgm', folders.dotFolder, startNum, endNum);

			for i=1:fldr.numAnnotatedFrames
				sourceFile = fullfile(fldr.dotFolder, pgmfiles(i).name);
				destFile = destinationNames{i};
				copyfile(sourceFile, destFile);
			end

			startNum = endNum;
		end

		fprintf('Num images in combined folder: %d\n', endNum-1);

	elseif strcmp(doTrainingOrTestingDataset, 'test')

		error('Not yet implemented')

		if ~exist(folders.outFolder, 'dir')
			error('You must first run the detector on the combined folder!')
		end

		requiredFiles = {...
			'wBinary.mat'...
			'wHistory.mat'...
			'wStruct_alpha_0.mat'...
		};

		for i=1:numel(requiredFiles)
			if ~exist(fullfile(folders.outFolder, requiredFiles{i}))
				error('You must first run the detector on the combined folder!')
			end
		end

		% For each of dhe datasets
			% create a new temporary outfolder
			% inside put all the annotated images
			% inside copy all the detector mat files from the combined folder
	end

else
	error('Not yet implemented')

	% requiredFiles = {...
	% 	'robustClassifierModel.mat'...
	% 	'testLinkerClassifierANN.m'...
	% };


	% for i=1:numel(requiredFiles)
	% 	if ~exist(fullfile(folders.outFolder, requiredFiles{i}))
	% 		error('You must first run the tracker on the combined folder!')
	% 	end
	% end
end

fprintf('Total numAnnotatedFrames in new folder: %d\n', folders.numAnnotatedFrames)
fprintf('Total numAnnotatedTrajectories in new folder: %d\n', folders.numAnnotatedTrajectories)


% All combos:

% training dataset for Detector 
% training dataset for Tracker

% testing datasets for Detector
% training datasets for Tracker


cd('evaluations')