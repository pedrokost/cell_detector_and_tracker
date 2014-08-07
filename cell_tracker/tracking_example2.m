clear all;
rng(1234)

addpath('somelightspeed')
%------------------------------------------Options
doTrainRobustTrackerModel = 1;
doTrainLinkerTrackerModel = 1;
dataset = 7;   % FIx numero 3
%------------------------------------------Load dataset
params = loadDatasetInfo(dataset);  % This is the only use input
%------------------------------------------Generate the datastores
global DSIN DSOUT;
DSIN = DataStore(params.dataFolder, false);
DSOUT = DataStore(params.outFolder, false);
%------------------------------------------Train the models
if doTrainRobustTrackerModel
	trainRobustTrackerModel('in', params);
end
if doTrainLinkerTrackerModel
	trainLinkerTrackerModel('in', params);
end
%------------------------------------------Generate trajectories
tracklets = generateTrajectories('out', params);
%------------------------------------------Save trajectories to disk

% % Unfortunately I cannot save as links in previous parts of the algorithm, because the trajectories can skip frame, which might need to be interpolated. I don't want to generate some interpolations and save them to disk because they will be mixed with actual dot detections. I have to save the entire tracklet matrix
finalTrackletsFile = [params.trajectoryGenerationToFilePrefix '_final.mat'];
save(finalTrackletsFile, 'tracklets');
%-----------------------------------------Plot progression

f = figure(1); clf;

files = dir([params.trajectoryGenerationToFilePrefix '*.mat']);

[~,files] = cellfun(@fileparts, {files.name}, 'UniformOutput',false);
[~, finalTrackletsFile] = fileparts(finalTrackletsFile);
files = setdiff(files, finalTrackletsFile);
numFiles = numel(files);
for i=1:numFiles
	load(fullfile(params.outFolder, files{i}));
	subplot(1,numFiles, iteration+1);
	trackletViewer(tracklets, 'out', struct('animate', false, 'showLabels',true, 'minLength', 0));
	title(sprintf('tracklets. Min gap: %d', closedGaps));
end

% axis(f2, ax)
% drawnow update;
% pause(1)