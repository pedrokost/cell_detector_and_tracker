rng(1234)
figure(1); clf;

folderOUT = fullfile('..', 'data', 'series30green');

tracklets = generateTracklets(folderOUT, true);
% tracklets(:, :, 1)

% display tracklets matrix
trackletViewer(tracklets, struct('animate', false, 'animationSpeed', 5));
