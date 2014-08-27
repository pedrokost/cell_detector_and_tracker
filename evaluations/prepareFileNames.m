function destinationFileNames = prepareFileNames(filePrefix, numDigits, fileFormat, startNum, endNum)

	nameRange = startNum:endNum;
	destinationFileNames = cell(numel(nameRange), 1);
	for i=1:numel(nameRange)
		name = sprintf('%s%0*d.%s', filePrefix, numDigits, nameRange(i), fileFormat);
		destinationFileNames{i} = name;
	end

end