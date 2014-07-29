function P = testMatcherRobustClassifierNB(modelFile, x)
	data = load(modelFile);


	x = x(:, data.idx);
	
	x = normalizeRange(x, data.minimum, data.maximum);
	% Y = data.NB.predict(x);

	P = posterior(data.NB, x);
	P = P(:, 2);
end