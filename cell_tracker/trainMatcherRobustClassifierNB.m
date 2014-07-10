load(fullfile('..', 'data', 'series30greenOUT', 'matcherTrainMatrix.mat'))
x = X(:, 1:end-1);
t = X(:, end);
idx = std(x) > 0.005;
x = x(:, idx);

[x minimum maximum] = normalizeRange(x);

NB = fitNaiveBayes(x,t);

save('match_predictor_nb.mat', 'NB', 'idx', 'minimum', 'maximum');

cMat1 = confusionmat(t,Y) 
