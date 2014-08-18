function D = euclideanDistance(XI, XJ)
	D = sqrt(bsxfun(@minus,XI,XJ).^2);
end