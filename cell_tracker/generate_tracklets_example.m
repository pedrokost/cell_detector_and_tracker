rng(1234)
% figure(1); clf;
clear all;

% save('squarematch_tracklets.mat', 'tracklets')
% subplot(2,2,2)
folderOUT = fullfile('..', 'data', 'series30greenOUT');
tracklets = generateTracklets(folderOUT, false);
descriptors = getTrackletHeadTailDescriptors(tracklets, folderOUT);
save('nbmatch_tracklets.mat', 'tracklets', 'descriptors')
trackletViewer(tracklets, struct('animate', false, 'showLabel', false));
title('Classifier tracklets Naive Bayes')

% % Display new matches algorithm with square loss function
% subplot(2,2,3);
% load squarematch_tracklets.mat
% trackletViewer(tracklets, struct('animate', false, 'showLabel', false));
% title('Classifier tracklets ANN')

% % Display previous matching algorithm
% subplot(2,2,1);
% load oldmatch_tracklets.mat
% trackletViewer(tracklets, struct('animate', false, 'showLabel', false));
% title('Similarity tracklets (position and intensity)')
% % Display ground truth
% subplot(2,2,4);
% folderOUT = fullfile('..', 'data', 'series30green');
% tracklets = generateTracklets(folderOUT, true);
% trackletViewer(tracklets, struct('animate', false, 'showLabel', false));
% title('Ground truth tracklets')