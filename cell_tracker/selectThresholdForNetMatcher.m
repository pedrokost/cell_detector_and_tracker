load(fullfile('..', 'data', 'series30greenOUT', 'matcherTrainRobustJoinerMatrix.mat'))
x = X(:, 1:end-1)';
labels = X(:, end)';

min_recall = 0.98;

scores = matcherClassifier(x);

[Xpr,Ypr,Tpr,AUCpr, OPTROCPT] = perfcurve(labels, scores, 1);

thr = sum((Ypr >= min_recall)) / numel(Xpr)
% X is FPR (1 - specificity)
% Y is TPR (recall)

OPTROCPT
plot(Xpr,Ypr)
xlabel('1-specificity'); ylabel('Recall')
title(['Precision-recall curve (AUC: ' num2str(AUCpr) ')'])	