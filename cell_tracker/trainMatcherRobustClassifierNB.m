function trainMatcherRobustClassifierNB(dataFile, modelFile)

	load(dataFile);

	x = X(:, 1:end-1);
	t = X(:, end);

	% Eliminate cols with insignificant data variation
	idx = std(x) > 0.005;
	x = x(:, idx);

	[x minimum maximum] = normalizeRange(x);

	% NB = fitNaiveBayes(x,t);  % Matlab 2014 only
	NB = NaiveBayes.fit(x, t);
	save(modelFile, 'NB', 'idx', 'minimum', 'maximum');

	Y = testMatcherRobustClassifierNB(X(:, 1:end-1), NB, idx, minimum, maximum);
	cMat1 = confusionmat(t, double(Y>0.9))
end

