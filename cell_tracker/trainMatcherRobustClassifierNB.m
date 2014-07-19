clear all;
load(fullfile('..', 'data', 'seriesdumy30greenOUT', 'matcherTrainRobustJoinerMatrix.mat'))

% FIXME: name of data matrix
x = X(:, 1:end-1);
t = X(:, end);
idx = std(x) > 0.005;
x = x(:, idx);

[x minimum maximum] = normalizeRange(x);

NB = fitNaiveBayes(x,t);

save('match_predictor_nb.mat', 'NB', 'idx', 'minimum', 'maximum');

Y = testMatcherRobustClassifierNB(X(:, 1:end-1));

cMat1 = confusionmat(t, double(Y>0.9))
