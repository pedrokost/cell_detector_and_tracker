function [X minimum maximum] = normalizeRange(X, minimum, maximum)
	if nargin < 3
		minimum = min(X, [], 1);
		maximum = max(X, [], 1);
	end
	diffs = maximum - minimum;
	X = bsxfun(@minus, X, minimum);
	X = bsxfun(@rdivide, X, diffs);
	X(:, diffs < 1e-4) = 1;
end