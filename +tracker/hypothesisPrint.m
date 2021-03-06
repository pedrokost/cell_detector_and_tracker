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
		case 'fulltable'
			hypothesisPrintTable(H, P, selected, true);
		case 'short'
			hypothesisPrintShort(H, P, selected);
		case 'shortextra'
			hypothesisPrintShort(H, P, selected, true);
	end
end

function hypothesisPrintShort(H, P, selected, extra)
	% HYPOTHESISPRINTSHORT displays the optimal selection results by marking
	% the rows of the hypothesis matrix that were selected as optimal
	if nargin < 4; extra = false; end

	fprintf('\n')
	fprintf('The following actions are optimal:\n\n');
	numRows = size(H, 1);
	Hselected = H(find(selected), :);
	bar = ones(sum(selected), 1) * ' | ';
	Q = tracker.humanizeHypothesis(Hselected);
	if extra
		disp([char(Q) bar num2str(exp(P(logical(selected))), '%0.2f')])
	else
		disp(char(Q))
	end
	fprintf('\n')

end

function hypothesisPrintTable(H, P, selected, fulltable)
	% HYPOTHESISPRINTTABLE displays the optimal selection results as a short
	% list of human readable actions

	if nargin < 4; fulltable = false; end

	numRows = size(H, 1);
	numTracklets = size(H, 2) / 2;
	bar = ones(numRows, 1) * ' | ';
	space = ones(numRows, 1) * ' ';
	SELECTED_MARKER_LEFT = 62;
	SELECTED_MARKER_RIGHT = 60;

	Q = char(tracker.humanizeHypothesis(H));
	P = num2str(exp(P), '%.2f');

	% Pwdth 
	actionWidth = num2str(size(Q, 2));
	probWidth = num2str(size(num2str(P), 2));
	hWidth = num2str(size(H, 2) + 3);

	H = full(H);
	fprintf('\n')
	if fulltable
		ttlFmt = ['  | %-' actionWidth 's | %' probWidth 's | %-' hWidth, 's |  '];
		ttl = sprintf(ttlFmt, 'Action', 'Prob', 'H');
	else
		ttlFmt = ['  | %-' actionWidth 's | %' probWidth 's |  '];
		ttl = sprintf(ttlFmt, 'Action', 'Prob');
	end
	disp(ttl)
	disp(char(ones(1,length(ttl)) * '-'))

	if fulltable
		disp([selected * SELECTED_MARKER_LEFT bar Q bar P bar H(:, 1:numTracklets)*49 bar H(:, (numTracklets+1):end)*49 bar selected * SELECTED_MARKER_RIGHT])
	else
		disp([selected * SELECTED_MARKER_LEFT bar Q bar P bar selected * SELECTED_MARKER_RIGHT])
	end
	fprintf('\n')
end