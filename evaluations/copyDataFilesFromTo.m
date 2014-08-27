function copyDataFilesFromTo(sourceFldr, destFldr, sourceFiles, destFilesNames)

	for i=1:numel(sourceFiles)
		src = fullfile(sourceFldr, sourceFiles(i).name);
		dst = fullfile(destFldr, destFilesNames{i});
		copyfile(src, dst);
	end
end