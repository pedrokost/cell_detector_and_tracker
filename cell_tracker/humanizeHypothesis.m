function M = humanizeHypothesis(H)
	% HUMANIZEHYPOTHESIS given the hypothesis matrix it returns for each row a
	% human readable name of what the hypothesis represents
	
	numRows = size(H, 1);
	widthNumber = length(num2str(numRows));
	numTracklets = size(H, 2) / 2;
	
	fmtInit = ['init  %' num2str(widthNumber) 'd']; % init   400
	lenInit = 6 + widthNumber;
	fmtTerm = ['term  %' num2str(widthNumber) 'd']; % term   400
	lenTerm = 6 + widthNumber;
	fmtFP = ['FP    %' num2str(widthNumber) 'd'];   % FP     400
	lenFP = 6 + widthNumber;
	fmtTrans = ['%' num2str(widthNumber) 'd -> %' num2str(widthNumber) 'd']; % 400 -> 500
	lenTrans = widthNumber * 2 + 4;

	M = zeros(numRows,max([lenInit, lenTerm, lenFP, lenTrans]));

	numOnes = sum(H, 2);

	for i=1:numRows
		row = H(i, :);
		[~, J] = find(row);
		if numOnes(i) == 1
			if J <= numTracklets
				M(i, 1:lenTerm) = sprintf(fmtTerm, J);
			else
				% if only 1 on right part: init
				M(i, 1:lenInit) = sprintf(fmtInit, J-numTracklets);
			end 
		else
			if J(1) == (J(2)-numTracklets)
				% if 2 ones at i and i+numTracklets: FP
				M(i, 1:lenFP) = sprintf(fmtFP, J(1));
			else
				% if 2 ones at different positions: transition
				M(i, 1:lenTrans) = sprintf(fmtTrans, J(1), J(2)-numTracklets);
			end
		end
	end
end