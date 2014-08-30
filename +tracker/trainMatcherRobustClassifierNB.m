function trainMatcherRobustClassifierNB(dataFile, modelFile)

	load(dataFile);

	fprintf('Training robust classifier.\n')

	x = X(:, 1:end-1);
	t = X(:, end);


	% Eliminate cols with insignificant data variation for each class
	x0 = x(t==0, :);
	x1 = x(t==1, :);
	idx0 = std(x0) < 0.005;
	idx1 = std(x1) < 0.005;
	
	idx = ~(idx0 | idx1);
	x = x(:, idx);

	[x minimum maximum] = tracker.normalizeRange(x);

	% NB = fitNaiveBayes(x,t);  % Matlab 2014 only
	NB = NaiveBayes.fit(x, t);
	save(modelFile, 'NB', 'idx', 'minimum', 'maximum');

	Y = tracker.testMatcherRobustClassifierNB(X(:, 1:end-1), NB, idx, minimum, maximum);

	fprintf('\tConfusion matrix for robust classifier NB:\n\n');
	cMat1 = confusionmat(t, double(Y>0.9));
	disp(cMat1)
end

