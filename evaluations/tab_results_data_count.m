% This basic script simply computes the average number of cell detections in each dataset
clear all;
datasets = 1:5;
cd('/home/pedro/Dropbox/Imperial/project/cell_tracker');

totals = zeros(numel(datasets), 1);
means = zeros(numel(datasets), 1);
stds  = zeros(numel(datasets), 1);
annotsFrames = zeros(numel(datasets), 1);

for d=1:numel(datasets)
	params = dataFolders(datasets(d));
	store = tracker.DataStore(params.dotFolder, false);
	frames = store.getMatfileIndices();

	dotsCount = zeros(params.numAnnotatedFrames, 1);
	for f=1:params.numAnnotatedFrames
		dots = store.getDots(frames(f));
		dotsCount(f) = size(dots, 1);
	end

	annotsFrames(d) = params.numAnnotatedFrames;
	totals(d) = sum(dotsCount);
	means(d) = mean(dotsCount);
	stds(d) = std(dotsCount);
end

num2str([(1:5)' totals means stds annotsFrames], '%2d  %4d  %2.2f  %2.2f  %3d')

cd('evaluations');