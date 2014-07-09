rng(1234);
nTracklets = 7;
nFrames = 10;
tracklets = zeros(nTracklets, nFrames, 2);

% tracklets(1, 2:4, 1) = round(rand(1, 3)*100);
% tracklets(2, 5:7, 1) = round(rand(1, 3)*100);
% tracklets(3, 2:4, 1) = round(rand(1, 3)*100);
% tracklets(4, 2:9, 1) = round(rand(1, 8)*100);
% tracklets(5, 1:5, 1) = round(rand(1, 5)*100);
% tracklets(6, 6:10, 1) = round(rand(1, 5)*100);
% tracklets(:, :, 2) = tracklets(:, :, 1);


tracklets(:, :, 1) = [
1 2 3 4 5 0 0 0 0 0;
0 0 0 0 0 6 7 0 0 0;
0 0 0 0 0 6 7 8 9 10;
1 2 3 4 0 0 0 0 0 0;
0 0 0 0 5 6 7 0 0 0;
0 0 0 0 5 6 7 8 9 10;
0 0 0 0 0 0 0 8 9 10;
];

tracklets(:, :, 2) = [
10 9 8 7 7 0 0 0 0 0;
0 0 0 0 0 7 8 0 0 0;
0 0 0 0 0 7 7 7 8 8;
4 4 4 4 0 0 0 0 0 0;
0 0 0 0 4 5 5 0 0 0;
0 0 0 0 3 3 2 2 2 2;
0 0 0 0 0 0 0 5 5 5;
];

[M, P] = generateHypothesisMatrix(tracklets, struct('maxGap', 0));

P = [
0.7
0.3
0.2
0.9
0.2
0.15
0.2

0.1
0.3
0.6
0.1
0.2
0.9
0.8

0.1
0.7
0.2
0.15
0.2
0.05
0.25

0.5
0.5
0.6
0.65
0.1
0.5
];

% Then try to compute something with it
Iopt = getGlobalOpimalAssociation(M, P);

% % Pretty dispaly results
hypothesisPrint(M, P, Iopt, 'table')
hypothesisPrint(M, P, Iopt, 'short')

figure(1); clf;
f1 = subplot(1,2,1);
trackletViewer(tracklets, struct('animate', false))
ax = axis(f1);
f2 = subplot(1,2,2);
Mopt = M(find(Iopt), :);
tracks = updateTracklets(tracklets, Mopt);
trackletViewer(tracks, struct('animate', false))
axis(f2, ax)