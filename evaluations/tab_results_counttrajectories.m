% Summarizes the number of annotaed trajectories as well as their length
clear all;
datasets = 1:5;
cd('..')
addpath('evaluations')


lengths = cell(numel(datasets), 1);
cnt = zeros(numel(datasets), 1);

for i=1:numel(datasets)
	dataset = datasets(i);
	clear DSIN DSOUT;
	global DSIN DSOUT;
	params = dataFolders(dataset);

	DSIN = tracker.DataStore(params.linkFolder, false);

	tracklets = tracker.generateTracklets('in', struct('withAnnotations', true));
	lens = trackletsLengths(tracklets, true);
	[lens, I] = sort(lens, 'descend');

	lens = lens(1:(params.numAnnotatedTrajectories));

	lengths{i} = lens';
	cnt(i) = numel(lens);
end

datasets
cnt
celldisp(lengths)

cd('evaluations')