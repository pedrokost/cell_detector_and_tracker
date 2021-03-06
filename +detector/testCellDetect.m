function [mask, dots, prediction, img, sizeMSER, r, gt, nFeatures, cellDescriptors]...
    = testCellDetect(w,dataset,imNum,featureParms,ctrlParms,verbosity, dataParams)
%Detect cells in an image given the W vector
%OUTPUT
%   mask = logical image with the regions selected
%   dots = vector with the centroids of the regions selected
%   prediction = score of each MSER in r obtained as <w,X>
%   img = original image
%   sizeMSER = size (in pixels) of each MSER in r
%   gt = vector with the gt annotations
%   nFeatures = total number of features used
%   cellDescriptors = feature vectors of detected cells to be used in matching
%INPUT
%   w = vector learned with the structural-SVM
%   dataset = dataset identifier
%   featureParms and ctrlParms = structures set in setFeatures
%   verbosity = to show figures of the results. 
%       0 doesn't show anything
%       1 shows the image with the regions boundaries and centroids
%       2 shows all candidate regions 

%--------------------------------------------------------------Encode Image
withGT = 0;
additionalU = 0;


trainFiles = dataParams.trainFiles;
testFiles  = dataParams.testFiles;
imExt      = dataParams.imExt;
dataFolder = dataParams.dotFolder;
outFolder  = dataParams.outFolder;
mserParms  = dataParams.mserParms;


if exist([outFolder '/feats_' testFiles{imNum} '_test.mat'],'file') == 0
    
    [img, gt, X, ~, r, ell, MSERtree, ~, sizeMSER, nFeatures, cellDescriptors] =...
        detector.encodeImage(dataFolder, testFiles{imNum}, imExt, withGT, featureParms, mserParms);
    %save([outFolder '/feats_' testFiles{imNum} '_test.mat']...
    %    ,'img', 'gt', 'X', 'r', 'ell', 'sizeMSER', 'MSERtree', 'nFeatures');

else
    load([outFolder '/feats_' testFiles{imNum} '_test.mat']);
end

%-------------------------------------------------------Evaluate Hypotheses
prediction = w'*X';
biasedPrediction = prediction  + ctrlParms.bias;
%-----------------------------------------------------------------Inference
[mask, labels, dots] = detector.PylonInference(img, biasedPrediction',...
    sizeMSER, r, additionalU, MSERtree);

% num2str([sizeMSER r biasedPrediction'])

mask = logical(mask);

dots = dots(labels, :);
cellDescriptors = cellDescriptors(labels, :);
%------------------------------------------------Post processing the masks?
%mask = fastbwmorph(mask, 'close');
%---------------------------------------------------------------Plot Result

if verbosity > 0
    
    orImg = imread([dataFolder '/' testFiles{imNum} '.' imExt] ,imExt);
    
    if exist([dataFolder '/' testFiles{imNum} '.mat'],'file') == 0
        gt = [];
    else
        gt = load([dataFolder '/' testFiles{imNum} '.mat']);
        inGT = fieldnames(gt);
        gt = gt.(inGT{1});
    end
    
    if size(orImg,3) > 3
        orImg = orImg(:,:,1:3);
    end
    
    screen_size = get(0,'ScreenSize');
    f1 = figure('Name','Detected Cells'); 
    subplot(1,2,1); imshow(orImg);
    title({'Extremal region boundaries = green/red. Centroids = yellow'},'FontSize',12);
    
    set(f1,'Position', [0 0 screen_size(3)/2 screen_size(4)]);
    hold on;

    [B,L,N,A] = bwboundaries(mask);
    
    for i=1:numel(B)
        line(B{i}(:,2),B{i}(:,1),'Color','r','LineWidth',3, 'LineStyle','-');
    end
    for i=1:numel(B)
        line(B{i}(:,2),B{i}(:,1),'Color','g','LineWidth',3, 'LineStyle','--');
    end
    
    hold on;
    plot(dots(:,1), dots(:,2),'xy','LineWidth',5,'MarkerSize',5)
    if ~isempty(gt) && verbosity > 1
        plot(gt(:,1), gt(:,2),'xb','LineWidth',2,'MarkerSize',4)
        title({'Extremal region boundaries = green/red. Centroids = yellow',...
            'Ground truth = blue'},'FontSize',12);
    end
    hold off;
end


if verbosity > 1
%     figure('Name','Result Details')
    subplot(1,2,2); imshow(img); hold on;
    title('All regions (fitted Ellipses). G = selected, B = score > 0, R = score < 0',...
        'FontSize',12);
    for k = 1:size(r,1)
        
        if biasedPrediction(k) > 0
            if labels(k)
                vl_plotframe(ell(:,k),'color','g');
            else
                vl_plotframe(ell(:,k),'color','b');
            end
        else
            vl_plotframe(ell(:,k),'color','r') ;
        end
        
    end
end

%--Good quality export
%     screen_size = get(0,'ScreenSize');
%     f1 = figure(1);
%     set(f1,'Position', [0 0 screen_size(3) screen_size(4)]);
%     imshow(orImg);
%     hold on;
%
%     [B,L,N,A] = bwboundaries(mask);
%
%     for i=1:numel(B)
%         line(B{i}(:,2),B{i}(:,1),'Color','g','LineWidth',4, 'LineStyle','-');
%     end
%     for i=1:numel(B)
%         line(B{i}(:,2),B{i}(:,1),'Color','r','LineWidth',3, 'LineStyle','--');
%     end
%
%     if ~isempty(gt)
%         plot(gt(:,1), gt(:,2),'or','LineWidth',5,'MarkerSize',3)
%     end
%     plot(dots(:,1), dots(:,2),'xb','LineWidth',5,'MarkerSize',5)
%     hold off;
%
%     export_fig([outFolder '/' testFiles{imNum}],'-transparent','-q100','-m1.5','-a2','-png');
end