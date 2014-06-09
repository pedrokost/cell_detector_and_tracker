% This receives all the feature vectors of all cells in a image
% and computes the feature Plink probablisties

folderFeatures = fullfile('..', 'cell_detector', 'kidney', 'outKidneyRed');
features = fullfile(folderFeatures, 'im40_cells.mat');
load(features)  % X contains a matrix of nrow cells and ncol features

dists = ones(nCells, nCells);

for i=1:nCells
	for j=1:nCells
		if i==j;
			% dists(i, j) = 20;
			continue;
		end
		% get the corresponding feature vectors
		vectI = X(i, :);
		vectJ = X(j, :);
		dist = sum((vectI - vectJ) .^ 2);
		dists(i, j) = dist;
	end
end

imagesc(dists);