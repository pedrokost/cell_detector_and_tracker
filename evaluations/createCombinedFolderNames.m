function folders = createCombinedFolderNames(doDetectionOrTracking, doTrainingOrTestingDataset, datasets, baseNameCombined, baseNameSingled)

	folders = dataFolders(datasets(1));

	for i=2:numel(datasets)
		fldr = dataFolders(datasets(i));
		folders.numAnnotatedFrames = folders.numAnnotatedFrames + fldr.numAnnotatedFrames;
		folders.numAnnotatedTrajectories = folders.numAnnotatedTrajectories + fldr.numAnnotatedTrajectories;
		folders.imageDimensions = [folders.imageDimensions; fldr.imageDimensions];
	end

	if strcmp(doDetectionOrTracking , 'det')

		% Create the combined dot folder
		folderName = sprintf('%s', baseNameCombined);
		fullDotFolderName = fullfile(folders.rootDotFolder, folderName);
		fullOutFolderName = fullfile(folders.rootOutFolder, folderName);

		folders.dotFolder = fullDotFolderName;
		folders.outFolder = fullOutFolderName;
		
		if strcmp(doTrainingOrTestingDataset, 'test')
			% Create the single dot folders
			
			folders.dotFolders = cell(numel(datasets), 1);
			folders.outFolders = cell(numel(datasets), 1);
			for i=1:numel(datasets)
				folderName = sprintf('%s-%d', baseNameSingled, datasets(i));
				fullDotFolderName = fullfile(folders.rootDotFolder, folderName);
				fullOutFolderName = fullfile(folders.rootOutFolder, folderName);
				folders.dotFolders{i} = fullDotFolderName;
				folders.outFolders{i} = fullOutFolderName;
			end
		end

	else
		error('Not yet implemented')
	end
end
