function [RowMatrix2D2 nonzeroIdx] = eliminateZeroRows(RowMatrix2D);
	% eliminateZeroRows eliminates the rows with all 0 values. 
	% Inputs:
	% 	RowMatrix2D = A 2D row matrix
	% Outputs:
	% 	RowMatrix2D2 = RowMatrix2D without the zero rows
	% 	nonzeroIdx = a logical vector with the non-zero indices of the original matrix
	nonzeroIdx = findNonZeroIdx(RowMatrix2D);
	RowMatrix2D2 = RowMatrix2D(nonzeroIdx, :);
end