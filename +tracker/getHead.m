function matrix2 = getHead(matrix, n)
	% getHead return the top n rows of a matrix along the provided dimension
	% Inputs:
	% 	matrix = the matrix we want to crop
	% 	n = the maximum number of rows we want to returns
	% Ouptuts:
	% 	matrix2 = the first n rows of matrix

	[numRows] = size(matrix, 1);
	n = min(n, numRows);
	matrix2 = matrix(1:n, :);
end