function D = pointsDistance(A, B)
	D = sqrt(sum(bsxfun(@minus,A, B).^2, 2));
end