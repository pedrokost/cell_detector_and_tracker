function tracklet2D = trimZeros(tracklet2D)
	% Removes 0-rows in the head or tail of the 2D tracklet

	if isempty(tracklet2D); return; end;

	nonzero = findNonZeroIdx(tracklet2D);

	% find zeros in the head
	idxendzeroshead = 1;
	while nonzero(idxendzeroshead) == 0
		idxendzeroshead = idxendzeroshead + 1;
	end

	% find zeros in the tail
	idxstartzerostail = numel(nonzero);
	while nonzero(idxstartzerostail) == 0
		idxstartzerostail = idxstartzerostail - 1;
	end

	% crop the tracklet
	tracklet2D = tracklet2D(idxendzeroshead:idxstartzerostail, :);

end