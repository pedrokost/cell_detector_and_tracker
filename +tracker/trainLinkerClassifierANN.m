function trainLinkerClassifierANN(dataFile, options)

  % Solve a Pattern Recognition Problem with a Neural Network
  % Script generated by Neural Pattern Recognition app
  % Created Fri Jul 04 15:43:21 BST 2014

  % TODO: load from config
  load(dataFile)

  X = double(X');
  Y = double(Y');
  % Create a Pattern Recognition Network
  hiddenLayerSize = 2;
  net = patternnet(hiddenLayerSize);

  % Choose Input and Output Pre/Post-Processing Functions
  % For a list of all processing functions type: help nnprocess
  net.input.processFcns = {'removeconstantrows','mapminmax'};
  net.output.processFcns = {'removeconstantrows','mapminmax'};


  % Setup Division of Data for Training, Validation, Testing
  % For a list of all data division functions type: help nndivide
  net.divideFcn = 'dividerand';  % Divide data randomly
  net.divideMode = 'sample';  % Divide up every sample
  net.divideParam.trainRatio = 70/100;
  net.divideParam.valRatio = 15/100;
  net.divideParam.testRatio = 15/100;

  % For help on training function 'trainscg' type: help trainscg
  % For a list of all training functions type: help nntrain
  net.trainFcn = 'trainbr';  % Scaled conjugate gradient

  % Choose a Performance Function
  % For a list of all performance functions type: help nnperformance
  net.performFcn = 'mse';  % Cross-entropy

  % Choose Plot Functions
  % For a list of all plot functions type: help nnplot
  net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
    'plotregression', 'plotfit'};

  net.trainParam.epochs = 50;
  % Train the Network
  [net,tr] = train(net,X,Y);
  % weights = getwb(net);

  % Test the Network
  y = net(X);
  e = gsubtract(Y,y);
  tind = vec2ind(Y);
  yind = vec2ind(y);
  percentErrors = sum(tind ~= yind)/numel(tind);
  performance = perform(net,Y,y)

  % Recalculate Training, Validation and Test Performance
  trainTargets = Y .* tr.trainMask{1};
  valTargets = Y  .* tr.valMask{1};
  testTargets = Y  .* tr.testMask{1};
  trainPerformance = perform(net,trainTargets,y)
  % valPerformance = perform(net,valTargets,y)
  testPerformance = perform(net,testTargets,y)

  % View the Network
  % view(net)

  % Plots
  % Uncomment these lines to enable various plots.
  %figure, plotperform(tr)
  %figure, plottrainstate(tr)
  %figure, plotconfusion(t,y)
  %figure, plotroc(t,y)
  %figure, ploterrhist(e)

  % Deployment
  % Change the (false) values to (true) to enable the following code blocks.
  outputFile = fullfile(options.outFolder, 'testLinkerClassifierANN.m');
  if (true)
    % Generate MATLAB function for neural network for application deployment
    % in MATLAB scripts or with MATLAB Compiler and Builder tools, or simply
    % to examine the calculations your trained neural network performs.
    genFunction(net, outputFile);
    addpath(options.outFolder)
    y = testLinkerClassifierANN(X);
    rmpath(options.outFolder)
  end
  if (false)
    % Generate a matrix-only MATLAB function for neural network code
    % generation with MATLAB Coder tools.
    genFunction(net,outputFile,'MatrixOnly','yes');
    addpath(options.outFolder)
    y = testLinkerClassifierANN(X);
    rmpath(options.outFolder)
  end
  if (false)
    % Generate a Simulink diagram for simulation or deployment with.
    % Simulink Coder tools.
    gensim(net);
  end
end