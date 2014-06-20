clc;
disp(' ')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('===================================================================');
disp('-----------------------Feature selection for-----------------------');
disp('--Learning to Detect Cells Using Non-overlapping Extremal Regions--');
disp('===================================================================');
disp(' ')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------------------------Check

if exist('vl_setup','file') == 0
    error('Vl_feat required');
end
if exist('pylonSetup','file') == 0
    error('Pylon Inference code required');
end

%---------------------------------------------------------------------Setup
%Choose parameters for the training/testing
% done: 3:4, 9:10
dataset = 1;%Identifier of the training/testing data as set in loadDatasetInfo
numFeatures = 7; % number of all possible features
runPar = 1; % Run with additonal parallel workers
profilerOn = 0;
inspectResults = 0;
skipFeatureSetsShorterThan = 4;  % 0 for no skip

if runPar %start parallel workers
    if ~(matlabpool('size') > 0)
        matlabpool open
    end
end

% Compute cross product of all possible features
x = dec2bin(0:2^numFeatures-1);  % string vector
X = zeros(2^numFeatures, numFeatures);
for i=1:numFeatures
	X(:, i) = str2num(x(:, i));
end
X = X(2:end, :);  % Elimintate 000 and only bias 0001
%------------------------------------------------------------------------Run


if profilerOn
	profile on
end

fprintf('Loading dataset info\n');
dataParams = loadDatasetInfo(datasetTest);
trainFiles = dataParams.trainFiles;
testFiles  = dataParams.testFiles;
imExt      = dataParams.imExt;
dataFolder = dataParams.dataFolder;
outFolder  = dataParams.outFolder;
tol        = dataParams.tol;

resultsFile = fullfile(outFolder, 'batchResults.mat');

fprintf('Initializing iteration loop\n');
if exist(resultsFile, 'file')
	load(resultsFile, 'results', 'iter');
	fprintf('Continuing from iteration #%d\n\n', iter);
else
	results = [X, zeros(size(X, 1),3)];
	iter = 1;  % FIXME, start from 1
end


startIter = iter;
for iter=startIter:size(X, 1);

	features = X(iter, :);

    if sum(features(1:(numFeatures-1))) < skipFeatureSetsShorterThan
        iter = iter + 1;
        fprintf('Skipping feature-set %s\n', num2str(features));
        continue
    end

	fprintf('=================================================================\n');
	fprintf('Running training set %2d/%d with feature-set %s\n', iter,...
													size(X, 1), num2str(features));
	fprintf('=================================================================\n');

	% %-Features and control parameters-%
	[parameters,ctrl] = setFeatures(features); %Modify to select features and other parameters


	%---------------------------------------------------------------------Train
	w = trainCellDetect(dataset,ctrl,parameters);

	% %----------------------------------------------------------------------Test
    t = cputime;
    for imNum = 1:numel(testFiles)

        disp(['		Testing on Image ' num2str(imNum) '/' num2str(numel(testFiles))]);
        [centers, mask, dots, prediction, img, sizeMSER, r, gt, nFeatures] =...
            testCellDetect(w,datasetTest,imNum,parameters,ctrl,inspectResults);
        imwrite(mask, [outFolder '/mask_' testFiles{imNum} '.tif'],'tif');
        save([outFolder '/' testFiles{imNum} '.mat'],'dots');      
        
        if ~isempty(gt)
            if imNum == 1
                prec = zeros(numel(testFiles),1);
                rec = zeros(numel(testFiles),1);
            end
            [prec(imNum), rec(imNum)] = evalDetect(dots(:,2),dots(:,1),...
                gt(:,2), gt(:,1), ones(size(img)),tol);
            % disp('Matching result: '); 
            disp(['		Precision: ' num2str(prec(imNum)) ' Recall: ' num2str(rec(imNum))]);
            % disp(' ');
        end
        
        if inspectResults > 0
            disp('Press any key to continue');
            pause;
        end
    end

 	elapsedTime = cputime-t;

 	% prec = mean(rand(1, 27));
 	% rec = mean(rand(1, 27));
 	prec = mean(prec);
 	rec = mean(rec);

 	% Save evaluation results

 	results(iter, (numFeatures+1):end) = [prec, rec, elapsedTime];
 	fprintf('Completed in %2.3f CPU time units with precision %3.2f and recall %3.2f\n', ...
 		elapsedTime, prec, rec);
 	save(resultsFile, 'results', 'iter');

	
 	disp(' ');
	iter = iter + 1;
end
% for each:
% train the model
% test the model (time it)
% store the accuracy and time in a file

if profilerOn
	p = profile('info');
	profsave(p, 'profile_results')
end


%--------------------------------------------------------------------Finish
if runPar
    matlabpool close
end
clear;
