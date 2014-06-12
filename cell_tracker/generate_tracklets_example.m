rng(1234)
figure(1); clf;

folderOUT = fullfile('..', 'data', 'kidneygreenOUT');

tracklets = generateTracklets(folderOUT);

% display tracklets matrix
trackletViewer(tracklets, struct('animate', false, 'animationSpeed', 5));
