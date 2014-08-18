function D = logisticLossDistance(XI, XJ)
	n = bsxfun(@minus,XI,XJ);
	D = 1 ./ (1 + exp(-n));
	% D = euclideanDistance(XI, XJ);
end