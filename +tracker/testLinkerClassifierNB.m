function P = testLinkerClassifierNB(x)
	data = load('match_tracklet_predictor_nb.mat');


	x = x(:, data.idx);
	
	x = normalizeRange(x, data.minimum, data.maximum);
	% P = data.NB.predict(x);

	P = posterior(data.NB, x);
	P = P(:, 2);
end