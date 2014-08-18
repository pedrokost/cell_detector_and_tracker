function varargout = normalizeRangeMulti(varargin)
	% Given a sequences of matrixes nObsxnFeats, and an optional cell array containing indices with data of equal metrics, normalizes the data
	% normalizeRangeMulti(A, B, {1:2, [3 6 7]})
	if nargin < 1 && class(varargin{1} ~= 'cell')
		error('At least one matrix must be provided')
	end

	nFeats = size(varargin{1}, 2);
	mins = zeros(1, nFeats);
	maxs = zeros(1, nFeats);
	remainingFeats = 1:nFeats;

	if class(varargin{end}) == 'cell'; nins = nargin - 1;
	else nins = nargin; end;

	data = vertcat(varargin{1:nins});

	minimum = min(data, [], 1);
	maximum = max(data, [], 1);

	for idx=varargin{end}
		if ~isempty(minimum)
			minimum(idx{1}) = min(minimum(:, idx{1}));
		end
		if ~isempty(maximum)
			maximum(idx{1}) = max(maximum(:, idx{1}));
		end
	end

	for i=1:nins
		varargout{i} = normalizeRange(varargin{i}, minimum, maximum);
	end
end