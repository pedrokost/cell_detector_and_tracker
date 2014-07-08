rng(1234);
nTracklets = 6;
nFrames = 10;
tracklets = zeros(nTracklets, nFrames, 2);

tracklets(1, 2:4, 1) = round(rand(1, 3)*100);
tracklets(2, 5:7, 1) = round(rand(1, 3)*100);
tracklets(3, 2:4, 1) = round(rand(1, 3)*100);
tracklets(4, 2:9, 1) = round(rand(1, 8)*100);
tracklets(5, 1:5, 1) = round(rand(1, 5)*100);
tracklets(6, 6:10, 1) = round(rand(1, 5)*100);

tracklets(:, :, 2) = tracklets(:, :, 1);

[H, P] = generateHypothesisMatrix(tracklets, struct('maxGap', 0));


	% Then try to compute something with it
numVars = size(M, 2);
numRows = size(M, 1);
options = optimoptions('intlinprog', 'Display', 'off');
xsol = intlinprog(-P, 1:numVars, [],[], M', ones(numVars, 1), zeros(numRows,1), ones(numRows, 1), options);

% Pretty dispaly results
hypothesisPrint(H, P, xsol, 'table')