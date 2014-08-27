%{
	Creates combined datasets for training and testing detector and tracker
%}
clear all

%----------------------------------------------------------------Configuration

doDetectionOrTracking = 'det';  % one of{'det' 'track'}

doTrainingOrTestingDataset = 'test';  % one of {'test', 'train'} % creates a large dataset combined of several smaller ones
% on the combined model is trained, us this to generate several small datasets such that the combined model can be tested on each original dataset separately.

allDatasets = 1:5;  % Only the original ones. Don't touch

datasets = [2,4,5]; % Datasets to combine

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
	folders = createCombinedFolderNames(doDetectionOrTracking, doTrainingOrTestingDataset, allDatasets, combinedDatasetBaseName, singledDatasetBaseName);
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

			sourceFiles = dir(fullfile(fldr.dotFolder, matfilenames));
			sourceFiles = sourceFiles(1:fldr.numAnnotatedFrames);
			endNum = startNum + fldr.numAnnotatedFrames;
			destFiles = prepareFileNames(filePrefix, numDigits, 'mat', startNum, endNum);
			copyDataFilesFromTo(fldr.dotFolder, folders.dotFolder, sourceFiles, destFiles);

			sourceFiles = dir(fullfile(fldr.dotFolder, pgmfilenames));
			sourceFiles = sourceFiles(1:fldr.numAnnotatedFrames);
			destFiles = prepareFileNames(filePrefix, numDigits, 'pgm', startNum, endNum);
			copyDataFilesFromTo(fldr.dotFolder, folders.dotFolder, sourceFiles, destFiles);

			startNum = endNum;
		end

		fprintf('Num images in combined folder: %d\n', endNum-1);

	elseif strcmp(doTrainingOrTestingDataset, 'test')

		if ~exist(folders.outFolder, 'dir')
			error('You must first run the detector on the combined folder!')
		end

		requiredFiles = {'wStruct_alpha_0.mat'};
		for i=1:numel(requiredFiles)
			if ~exist(fullfile(folders.outFolder, requiredFiles{i}))
				error('You must first run the detector on the combined folder!')
			end
		end
		for i= 1:numel(allDatasets)
			fprintf('Copying files over for dataset %d\n', allDatasets(i));
			fldr = dataFolders(allDatasets(i));
			%--------------------------------------Copy images and annotations

			sourceFiles = dir(fullfile(fldr.dotFolder, matfilenames));
			sourceFiles = sourceFiles(1:fldr.numAnnotatedFrames);
			destFiles = prepareFileNames(filePrefix, numDigits, 'mat', 1, fldr.numAnnotatedFrames);
			copyDataFilesFromTo(fldr.dotFolder, folders.dotFolders{i}, sourceFiles, destFiles);

			sourceFiles = dir(fullfile(fldr.dotFolder, pgmfilenames));
			sourceFiles = sourceFiles(1:fldr.numAnnotatedFrames);
			destFiles = prepareFileNames(filePrefix, numDigits, 'pgm', 1, fldr.numAnnotatedFrames);
			copyDataFilesFromTo(fldr.dotFolder, folders.dotFolders{i}, sourceFiles, destFiles);
			
			%----------------------------------------------Copy required files

			for j=1:numel(requiredFiles)
				src = fullfile(folders.outFolder, requiredFiles{j});
				dst = fullfile(folders.outFolders{i}, requiredFiles{j});
				copyfile(src, dst);
			end
		end
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