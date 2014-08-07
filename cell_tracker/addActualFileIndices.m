function I2 = addActualFileIndices(I)
	% I is of the form [trackletA, frameA, cellIndexA trackletB, frameB, cellIndexB] where frameA and
	% frameB correspond to the indices of frame in the tracklets matrix. However,
	% these indices do not directly map to the index of the files, because some very
	% bad frames could have been deleted. This function corrects this indeces to
	% point to the correct file name
	% Outputs [trackletA, frameA, fileA, cellIndexA, trackletB, frameB, fileB cellIndexB]
	global DSOUT;
	
	numObs = size(I, 1);
	I2 = zeros(numObs, 6);
	I2(:, [1 2 4 5 6 8]) = I;

	matAnnotationsIndices = DSOUT.getMatfileIndices();
	I2(:, 3) = matAnnotationsIndices(I(:, 2))';
	I2(:, 7) = matAnnotationsIndices(I(:, 5))';
end