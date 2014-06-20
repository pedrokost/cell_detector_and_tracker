%                   CellDetect v1.0 - Demo
%
%Learning to Detect Cells Using Non-overlapping Extremal Regions
%
%
addpath(fullfile('dependencies'));
addpath(fullfile('dependencies', 'matlab'));

clc;
disp(' ')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('===================================================================');
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
dataset = 2;  %Identifier of the training/testing data as set in loadDatasetInfo
train = 0;%---->Do train
test = 1;%----->Do test
detectOnAll = 1;  % ----> Perform detections on all the images, not just test set

inspectResults = 0; %1: Shows detected cells. 
%2:A view on the results: MSERs found and selected

isSequence = 0; % The testing images are a video sequences

%-Features and control parameters-%
dataParams = loadDatasetInfo(dataset, struct('testAll', detectOnAll));
feats = dataParams.features;

[parameters, ctrl] = setFeatures(feats); %Modify to select features and other parameters

if ctrl.runPar %start parallel workers
    if ~(matlabpool('size') > 0)
        matlabpool open
    end
end

%---------------------------------------------------------------------Train
if train
    w = trainCellDetect(dataset,ctrl,parameters);
else
    dataParams = loadDatasetInfo(dataset, struct('testAll', detectOnAll));
    outFolder = dataParams.outFolder;
    model = load([outFolder '/wStruct_alpha_' num2str(ctrl.alpha) '.mat']);
    w = model.w;
    disp('Model Loaded');
end

%----------------------------------------------------------------------Test
t = cputime;

if test
    dataParams = loadDatasetInfo(dataset, struct('testAll', detectOnAll));
    trainFiles = dataParams.trainFiles;
    testFiles  = dataParams.testFiles;
    imExt      = dataParams.imExt;
    dataFolder = dataParams.dataFolder;
    outFolder  = dataParams.outFolder;
    tol        = dataParams.tol;

    for imNum = 1:numel(testFiles)
        disp(sprintf('Testing on image %d/%d (%s)', imNum, numel(testFiles), testFiles{imNum}))
        [mask, dots, prediction, img, sizeMSER, r, gt, nFeatures, descriptors] =...
            testCellDetect(w,dataset,imNum,parameters,ctrl,inspectResults, struct('testAll', detectOnAll));

        %----------------------------------------------------------------Save masks
        if ctrl.saveMasks
            % centers = logical image with centroids of the regions selected
            centers = zeros(size(mask), 'uint8');
            centers(dots(:, 2), dots(:, 1)) = 255;
            imwrite(mask, [outFolder '/mask_' testFiles{imNum} '.tif'],'tif');
        end
        %-----------------------------------------------------Save cell descriptors
        if ctrl.saveCellDescriptors
            save([outFolder '/' testFiles{imNum} '.mat'],'descriptors', 'dots');
        else
            save([outFolder '/' testFiles{imNum} '.mat'],'dots');
        end

        %--------------------------------------------------------Save masks to file
        
        if ~isempty(gt)
            if imNum == 1
                prec = zeros(numel(testFiles),1);
                rec = zeros(numel(testFiles),1);
            end
            [prec(imNum), rec(imNum)] = evalDetect(dots(:,2),dots(:,1),...
                gt(:,2), gt(:,1), ones(size(img)),tol);
            disp('Matching result: '); 
            disp(['Precision: ' num2str(prec(imNum)) ' Recall: ' num2str(rec(imNum))]);
            disp(' ');
        end
        
        if inspectResults > 0
            disp('Press any key to continue');
            pause;
        end
    end
end

elapsedTime = cputime-t;

if test && isSequence
    plotDotsSequence(outFolder);
end

%Print simple evaluation results if available
if exist('prec','var')
    disp('--Evaluation results (Matching)--');
    disp(['Mean Precision: ' num2str(mean(prec)) ]);
    disp(['Mean Recall: ' num2str(mean(rec)) ]);
    disp(' ');

    fprintf('Completed in %2.3f CPU time units\n', elapsedTime);
end

%--------------------------------------------------------------------Finish
if ctrl.runPar
    matlabpool close
end
clear;
