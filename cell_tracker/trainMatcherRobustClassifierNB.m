function trainMatcherRobustClassifierNB(dataFile, modelFile)

	load(dataFile);

	x = X(:, 1:end-1);
	t = X(:, end);

	% Eliminate cols with insignificant data variation
	idx = std(x) > 0.005;
	x = x(:, idx);

	[x minimum maximum] = normalizeRange(x);

	NB = fitNaiveBayes(x,t);

	save(modelFile, 'NB', 'idx', 'minimum', 'maximum');

	Y = testMatcherRobustClassifierNB(modelFile, X(:, 1:end-1));
	cMat1 = confusionmat(t, double(Y>0.9))
end

