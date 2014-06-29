rng(1234)
figure(1); clf;

folderOUT = fullfile('..', 'data', 'series30greenOUT');

tracklets = generateTracklets(folderOUT);
% tracklets(:, 30:end, 1)

% display tracklets matrix
trackletViewer(tracklets, struct('animate', false, 'animationSpeed', 5));
