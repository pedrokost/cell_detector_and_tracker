function trainCellDetector(dataset, ctrlParams)
	% Trains the detector on the provided dataset

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
	%-------------------------------------------------------Load data and cofig

	%-Features and control parameters-%
	dataParams = loadDatasetInfo(dataset, ctrlParams);

	featureParms = setFeatures(dataParams.features); %Modify to select features and other parameters

	if ctrlParams.runPar %start parallel workers
	    if isempty(gcp('nocreate'))        
	        pool = parpool('local')
	    end
	end

	%-------------------------------------------------------Train
	w = trainCellDetect(dataset,ctrlParams,featureParms);

	%--------------------------------------------------------------------Finish
	if ctrlParams.runPar
	    parpool close
	end

end