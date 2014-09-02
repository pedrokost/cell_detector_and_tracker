function I = getGlobalOpimalAssociation(H, P)
	% GETGLOBALOPIMALASSOCIATION Given a hypothesis matrix and probability vector
	% computes the optimal tracklet association. 
	numVars = size(H, 2);
	numRows = size(H, 1);

	% Convert any -Inf to very low values
	% infidx = (P == -Inf);
	% P(infidx) = -1000;
	P = max(P, -1000);

	% For matlab >= 2014a
	options = optimoptions('intlinprog', 'Display', 'off');
	I = intlinprog(-P, 1:numVars, [],[], H', ones(numVars, 1), zeros(numRows,1), ones(numRows, 1), options);
	
	% For matlab less than 2014a
	% options = optimoptions('bintprog', 'Display', 'off');
	% I = bintprog(-P, [],[], H', ones(numVars, 1), zeros(numRows,1), options);
end