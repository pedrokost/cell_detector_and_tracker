function detectorPerfMetrics = detectCells(dataset, ctrlParams, dataParams)
	% Evaluates a trained model on a new dataset
	% Inputs:
	% 	dataset = the id of the dataset, as set in dataFolders.m
	% Output:
	% 	detectorPerfMetrics = a struct containing performance detectorPerfMetrics:
	%		dataset
	% 		avgPrecision
	% 		avgRecall
	% 		stdPrecision
	% 		stdRecall
	% 		avgTimePerFrame
	% 		avgTimePerAnnotatedCell
	% 		avgTimePerCandidateRegion
	% 		ratioAnnotationToCandidate

	detectorPerfMetrics = struct('dataset', dataset);

	%--------------------------------------------------------Load dependencies
	addpath(fullfile('dependencies'));
	addpath(fullfile('dependencies', 'matlab'));

	%-------------------------------------------------------Check dependencies
	if exist('vl_setup','file') == 0
		error('vl_feat required');
	end
	if exist('pylonSetup','file') == 0
		error('Pylon Inference code required');
	end
	%-------------------------------------------------------Load data and model

	inspectResults = 2; %1: Shows detected cells. 
	isSequence = 0;
	%2:A view on the results: MSERs found and selected

	%-Features and control parameters-%
	featureParms = detector.setFeatures(dataParams.features); %Modify to select features and other parameters


	outFolder = dataParams.outFolder;
	model = load([outFolder '/wStruct_alpha_' num2str(ctrlParams.alpha) '.mat']);
	w = model.w;
	disp('Model Loaded');

	if ctrlParams.runPar %start parallel workers
		if isempty(gcp('nocreate'))        
			pool = parpool('local')
		end
	end

	%-------------------------------------------------------Test

	testFiles  = dataParams.testFiles;
	outFolder  = dataParams.outFolder;
	tol        = dataParams.tol;

	t = tic;

	prec = [];
	rec = [];
	numGt = [];
	numCand = [];

	for imNum = 1:numel(testFiles)
		tim = tic;
		
		disp(sprintf('Testing on image %d/%d (%s)', imNum, numel(testFiles), testFiles{imNum}))
		
		[mask, dots, prediction, img, sizeMSER, r, gt, nFeatures, descriptors] =...
			detector.testCellDetect(w,dataset,imNum,featureParms,ctrlParams,inspectResults, dataParams);

		%----------------------------------------------------------------Save masks
		if ctrlParams.saveMasks
			% centers = logical image with centroids of the regions selected
			centers = zeros(size(mask), 'uint8');
			centers(dots(:, 2), dots(:, 1)) = 255;
			imwrite(mask, [outFolder '/mask_' testFiles{imNum} '.tif'],'tif');
		end
		%-----------------------------------------------------Save cell descriptors
		if ctrlParams.saveCellDescriptors
			save([outFolder '/' testFiles{imNum} '.mat'],'descriptors', 'dots');
		else
			save([outFolder '/' testFiles{imNum} '.mat'],'dots');
		end

		%--------------------------------------------------------Save masks to file
		
		if imNum <= dataParams.numAnnotatedFrames
			numGt(imNum) = size(gt, 1);
			numCand(imNum) = numel(prediction);

			[prec(imNum), rec(imNum)] = detector.evalDetect(dots(:,2),dots(:,1),...
				gt(:,2), gt(:,1), ones(size(img)),tol);

			disp(['Precision: ' num2str(prec(imNum)) ' Recall: ' num2str(rec(imNum))]);
		end

		toc(tim)
		disp(' ');

		if inspectResults > 0
			disp('Press any key to continue');
			pause;
		end
	end

	%--------------------------------------------------------------------Finish
	prec(isnan(prec)) = 0;
	rec(isnan(rec)) = 0;

	detectorPerfMetrics.avgPrecision = mean(prec);
	detectorPerfMetrics.stdPrecision = std(prec);

	detectorPerfMetrics.avgRecall = mean(rec);
	detectorPerfMetrics.stdRecall = std(rec);

	%Print simple evaluation results if available
	if exist('prec','var')
	    disp('--Evaluation results (Matching)--');
	    disp(['Mean Precision: ' num2str(detectorPerfMetrics.avgPrecision) ]);
	    disp(['Mean Recall: ' num2str(detectorPerfMetrics.avgRecall) ]);
	    disp(' ');
	end

	elapsedTime = toc(t);

	detectorPerfMetrics.avgTimePerFrame = elapsedTime / numel(testFiles);
	detectorPerfMetrics.avgTimePerAnnotatedCell = elapsedTime / sum(numGt);
	detectorPerfMetrics.avgTimePerCandidateRegion = elapsedTime / sum(numCand);
	detectorPerfMetrics.ratioAnnotationToCandidate = sum(numGt) / sum(numCand);

	fprintf('Completed in %2.3f seconds (~%2.3f seconds per frame, ~%2.3f seconds per annotated cell)\n', elapsedTime, detectorPerfMetrics.avgTimePerFrame, detectorPerfMetrics.avgTimePerAnnotatedCell);

	save([outFolder '/detectorPerfMetrics.mat'],'detectorPerfMetrics');

	if isSequence
	    detector.plotDotsSequence(outFolder);
	end


	if ctrlParams.runPar
		parpool close
	end
end