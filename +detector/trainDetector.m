function trainDetector(dataset, overrides)
	% Trains the cell detector on the given dataset

	%--------------------------------------------------------Load dependencies
	addpath(fullfile('dependencies'));
	addpath(fullfile('dependencies', 'matlab'));
	addpath(fullfile('dependencies', 'catstruct'));

	ctrlParams = detector.ctrlParams(overrides);
	%-------------------------------------------------------Check dependencies
	if exist('vl_setup','file') == 0
	    error('vl_feat required');
	end
	if exist('pylonSetup','file') == 0
	    error('Pylon Inference code required');
	end
	%-------------------------------------------------------Load data and cofig

	%-Features and control parameters-%
	dataParams = detector.loadDatasetInfo(dataset, ctrlParams);

	featureParms = detector.setFeatures(dataParams.features); %Modify to select features and other parameters

	if ctrlParams.runPar %start parallel workers
	    if isempty(gcp('nocreate'))        
	        pool = parpool('local')
	    end
	end

	%-------------------------------------------------------Train
	w = detector.trainCellDetect(dataset,ctrlParams,featureParms);

	%--------------------------------------------------------------------Finish
	if ctrlParams.runPar
	    parpool close
	end
end