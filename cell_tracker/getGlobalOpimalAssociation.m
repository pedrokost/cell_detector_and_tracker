function I = getGlobalOpimalAssociation(H, P)
	% GETGLOBALOPIMALASSOCIATION Given a hypothesis matrix and probability vector
	% computes the optimal tracklet association. 
	numVars = size(H, 2);
	numRows = size(H, 1);
	options = optimoptions('intlinprog', 'Display', 'off');
	I = intlinprog(-P, 1:numVars, [],[], H', ones(numVars, 1), zeros(numRows,1), ones(numRows, 1), options);

end