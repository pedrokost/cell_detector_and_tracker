% Plots the detections in a nice view

datasets = 1:5;
cd('..')
addpath('dependencies/export_fig')
for i=1:numel(datasets)
	fprintf('Plotting dataset %d\n', datasets(i));
	params = dataFolders(datasets(i));
	figure(1); clf;
	subplot(1,2,1); detector.plotDotsSequence(params.outFolder); view([120, 15, 15]); axis tight;
	subplot(1,2,2); detector.plotDotsSequence(params.outFolder); view([0, 0, 90]); axis tight; axis equal;

	pauseIt();

	name = sprintf('../writing/thesis/images/fig_results_detector_sequences_%d', datasets(i));
	export_fig(name, '-eps', '-transparent', '-painters')
end
cd('evaluations')