function createCombinedDatasetFolders(doDetectionOrTracking, doTrainingOrTestingDataset, folders)

	if strcmp(doDetectionOrTracking , 'det')
		if strcmp(doTrainingOrTestingDataset, 'train')
			if exist(folders.dotFolder, 'dir')
				rmdir(folders.dotFolder, 's');
				fprintf('Deleted old folder %s.\n', folders.dotFolder)
			end
			if exist(folders.outFolder, 'dir')
				rmdir(folders.outFolder, 's');
				fprintf('Deleted old folder %s.\n', folders.outFolder)
			end
			mkdir(folders.dotFolder);
			fprintf('Created new folder %s.\n', folders.dotFolder)
			mkdir(folders.outFolder);
			fprintf('Created new folder %s.\n', folders.outFolder)
		elseif strcmp(doTrainingOrTestingDataset, 'test')

			for i=1:numel(folders.dotFolders)
				if exist(folders.dotFolders{i}, 'dir')
					rmdir(folders.dotFolders{i}, 's');
					fprintf('Deleted old folder %s.\n', folders.dotFolders{i})
				end
				if exist(folders.outFolders{i}, 'dir')
					rmdir(folders.outFolders{i}, 's');
					fprintf('Deleted old folder %s.\n', folders.outFolders{i})
				end
				mkdir(folders.dotFolders{i});
				fprintf('Created new folder %s.\n', folders.dotFolders{i})
				mkdir(folders.outFolders{i});
				fprintf('Created new folder %s.\n', folders.outFolders{i})
			end
		end
	else
		if exist(folders.dotFolder, 'dir')
			rmdir(folders.dotFolder, 's');
			fprintf('Deleted old folder %s.\n', folders.dotFolder)
		end
		if exist(folders.outFolder, 'dir')
			rmdir(folders.outFolder, 's');
			fprintf('Deleted old folder %s.\n', folders.outFolder)
		end
		mkdir(folders.dotFolder);
		fprintf('Created new folder %s.\n', folders.dotFolder)
		mkdir(folders.outFolder);
		fprintf('Created new folder %s.\n', folders.outFolder)
	end



end
