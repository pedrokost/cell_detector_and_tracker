function P = testMatcherClassifierNB(x)
	data = load('match_predictor_nb.mat');


	x = x(:, data.idx);
	
	x = normalizeRange(x, data.minimum, data.maximum);
	% Y = data.NB.predict(x);

	P = posterior(data.NB, x);
	P = P(:, 2);
end