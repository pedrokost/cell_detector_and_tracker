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