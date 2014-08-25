% This basic script simply computes the average number of cell detections in each dataset
clear all;
datasets = 1:5;
cd('/home/pedro/Dropbox/Imperial/project/cell_tracker');

means = zeros(numel(datasets), 1);
stds  = zeros(numel(datasets), 1);

for d=1:numel(datasets)
	params = dataFolders(datasets(d));
	store = tracker.DataStore(params.dotFolder, false);
	frames = store.getMatfileIndices();

	dotsCount = zeros(params.numAnnotatedFrames, 1);
	for f=1:params.numAnnotatedFrames
		dots = store.getDots(frames(f));
		dotsCount(f) = size(dots, 1);
	end
	means(d) = mean(dotsCount);
	stds(d) = std(dotsCount);
end

means
stds

cd('evaluations');