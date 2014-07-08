function hypothesisPrint(H, P, selected, view)
	% HYPOTHESISPRINT prints the results of optimal selected in the selected view
	% Inputs:
	% 	H = The raw hypothesis matrix
	% 	P = The associated probabilities
	% 	selected = the global data association results
	% 	view = which type of display to print:
	% 		- 'table'
	% 		- 'short' (default)
	if nargin < 4; view = 'short'; end

	switch view
		case 'table'
			hypothesisPrintTable(H, P, selected);
		case 'short'
			hypothesisPrintShort(H, P, selected);
	end
end

function hypothesisPrintShort(H, P, selected)
	% HYPOTHESISPRINTSHORT displays the optimal selection results by marking
	% the rows of the hypothesis matrix that were selected as optimal

		
	numRows = size(H, 1);
	Hselected = H(find(selected), :);
	Q = humanizeHypothesis(Hselected);
	char(Q)

end

function hypothesisPrintTable(H, P, selected)
	% HYPOTHESISPRINTTABLE displays the optimal selection results as a short
	% list of human readable actions

	numRows = size(H, 1);
	numTracklets = size(H, 2) / 2;
	bar = ones(numRows, 1) * ' | ';
	space = ones(numRows, 1) * ' ';
	SELECTED_MARKER_LEFT = 62;
	SELECTED_MARKER_RIGHT = 60;

	Q = char(humanizeHypothesis(H));

	H = full(H);
	% TODO add title
	[selected * SELECTED_MARKER_LEFT bar Q bar num2str(P) bar H(:, 1:numTracklets)*49 bar H(:, (numTracklets+1):end)*49 bar selected * SELECTED_MARKER_RIGHT]
end

function M = humanizeHypothesis(H)
	% HUMANIZEHYPOTHESIS given the hypothesis matrix it returns for each row a
	% human readable name of what the hypothesis represents

	numRows = size(H, 1);
	widthNumber = length(num2str(numRows));
	numTracklets = size(H, 2) / 2;
	

	fmtInit = ['init  %0' num2str(widthNumber) 'd']; % init   400
	lenInit = 7 + widthNumber;
	fmtTerm = ['term  %0' num2str(widthNumber) 'd']; % term   400
	lenTerm = 6 + widthNumber;
	fmtFP = ['FP    %0' num2str(widthNumber) 'd'];   % FP     400
	lenFP = 6 + widthNumber;
	fmtTrans = ['%0' num2str(widthNumber) 'd -> %0' num2str(widthNumber) 'd']; % 400 -> 500
	lenTrans = widthNumber * 2 + 4;

	M = zeros(numRows,max([lenInit, lenTerm, lenFP, lenTrans]));

	numOnes = sum(H, 2);

	for i=1:numRows
		row = H(i, :);
		[~, J] = find(row);
		if numOnes(i) == 1
			if J < numTracklets
				M(i, 1:lenTerm) = sprintf(fmtTerm, J);
			else
				% if only 1 on right part: init
				1:lenInit
				sprintf(fmtInit, J)
				M(i, 1:lenInit) = sprintf(fmtInit, J);
			end 
		else
			if J(1) == (J(2)-numTracklets)
				% if 2 ones at i and i+numTracklets: FP
				M(i, 1:lenFP) = sprintf(fmtFP, J(1));
			else
				% if 2 ones at different positions: transition
				M(i, 1:lenTrans) = sprintf(fmtTrans, J(1), J(2));
			end
		end
	end
end