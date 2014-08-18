clear all; clf;
rng(1234);

profile on;

addpath('somelightspeed');
dataset = 4;

params = loadDatasetInfo(dataset);
global DSIN DSOUT;
DSIN = DataStore(params.dataFolder, false);
DSOUT = DataStore(params.outFolder, false);

trackletsAnnot = generateTracklets('in', struct('withAnnotations', true));
% Load an annotated dataset, and generate the tracklets
% trackletsDet = generateTrajectories('out', params);

% trackletViewer(trackletsAnnot, 'in'); hold on;
% trackletsDet = generateTracklets('out', struct('withAnnotations', false, 'modelFile', params.robustClassifierParams.outputFileModel));
trackletViewer(trackletsDet, 'out');
% Select the tracklets that are longer than 30 observations
% Convert the tracklets to contain the IDS of the detection responses

% Load the detections
% Run the software to generate the detections tracklets


% For each annoatted traclets, find the detection tracklets that belong to it
% This is what I need to do :d

%-----------------------------------------Plot progression

% finalTrackletsFile = [params.trajectoryGenerationToFilePrefix '_final.mat'];
% tracklets = trackletsDet;
% save(finalTrackletsFile, 'tracklets');
% f = figure(1); clf;

% files = dir([params.trajectoryGenerationToFilePrefix '*.mat']);

% [~,files] = cellfun(@fileparts, {files.name}, 'UniformOutput',false);
% [~, finalTrackletsFile] = fileparts(finalTrackletsFile);
% files = setdiff(files, finalTrackletsFile);
% numFiles = numel(files);
% for i=1:numFiles
% 	load(fullfile(params.outFolder, files{i}));
% 	subplot(1,numFiles, iteration+1);
% 	trackletViewer(tracklets, 'out', struct('animate', false, 'showLabels',true, 'minLength', 0));
% 	title(sprintf('tracklets. Min gap: %d', closedGaps));
% end

profile off;
profile viewer;