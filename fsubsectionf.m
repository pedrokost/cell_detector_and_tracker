function fsubsectionf(varargin)
	% Makes a nices print of a section title
	% Inputs:
	% 	simple format string
	% 	any other required arguments for the format string
	% Example:
		% fsection('Training detector on dataset %d', 5)
		% ===================================== Training detector on dataset 5

	sz = get(0,'CommandWindowSize');
	terminalWidth = sz(1);
	title = sprintf('%s', varargin{1});
	if nargin > 1
		title = sprintf(title, varargin{2:end});
	end

	remainingspace = terminalWidth - length(title) - 1;
	decor = repmat('-', 1, remainingspace);
	fprintf('%s %s\n\n', decor, title);
end