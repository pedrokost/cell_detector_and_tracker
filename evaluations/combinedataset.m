

%----------------------------------------------------------------Configuration

detectionOrTracking = 'det'  % one of{'det' 'track'}

trainingDataset = true;  % creates a large dataset combined of several smaller ones
testestingDatasets = false;  % on the combined model is trained, us this to generate several small datasets such that the combined model can be tested on each original dataset separately.

% Datasets to combine
datasets = 1:2;

fileInitNum = 1;
filePrefix = 'im';
numDigits = 3;
%----------------------------------------------------------------Train dataset

% Joins smaller datasets into a larger one





% All combos:

% training dataset for Detector 
% training dataset for Tracker

% testing datasets for Detector
% training datasets for Tracker


