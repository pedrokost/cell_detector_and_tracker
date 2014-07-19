function matrix2 = getTail(matrix, n)
	% getTail return the bottom n rows of a matrix along the provided dimension
	% Inputs:
	% 	matrix = the matrix we want to crop
	% 	n = the maximum number of rows we want to returns
	% Ouptuts:
	% 	matrix2 = the last n rows of matrix

	[numRows] = size(matrix, 1);
	n = min(n, numRows);
	matrix2 = matrix((numRows-n+1):numRows, :);
end