function [nonzeroIdx] = findNonZeroIdx(matrix2D)
	nonzeroIdx = all(matrix2D ~= 0, 2);
end