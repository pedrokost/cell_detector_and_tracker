function P = testMatcherRobustClassifierNB(x, classifier, idx, minimum, maximum)

	% data = load(modelFile);
	% x = x(:, data.idx);
	x = x(:, idx);
	
	% x = normalizeRange(x, data.minimum, data.maximum);
	x = tracker.normalizeRange(x, minimum, maximum);
	% Y = data.NB.predict(x);

	% P = posterior(data.NB, x);
	P = posterior(classifier, x);
	P = P(:, 2);
end