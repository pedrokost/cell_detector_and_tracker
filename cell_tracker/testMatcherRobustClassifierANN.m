function [Y,Xf,Af] = testMatcherRobustClassifierANN(X,~,~)
%TESTMATCHERROBUSTCLASSIFIERANN neural network simulation function.
%
% Generated by Neural Network Toolbox function genFunction, 16-Jul-2014 10:51:36.
% 
% [Y] = testMatcherRobustClassifierANN(X,~,~) takes these arguments:
% 
%   X = 1xTS cell, 1 inputs over TS timsteps
%   Each X{1,ts} = 102xQ matrix, input #1 at timestep ts.
% 
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = 1xQ matrix, output #1 at timestep ts.
% 
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

  % ===== NEURAL NETWORK CONSTANTS =====
  
  % Input 1
  x1_step1_remove = [2 14 15 16 22 23 24 30 31 32 33 38 43 48 53 58 73 78 83 88 100];
  x1_step1_keep = [1 3 4 5 6 7 8 9 10 11 12 13 17 18 19 20 21 25 26 27 28 29 34 35 36 37 39 40 41 42 44 45 46 47 49 50 51 52 54 55 56 57 59 60 61 62 63 64 65 66 67 68 69 70 71 72 74 75 76 77 79 80 81 82 84 85 86 87 89 90 91 92 93 94 95 96 97 98 99 101 102];
  x1_step2_xoffset = [0;0;0;0;0;0;0;0;0;0;0;0;0.00127975103649323;0.000469404902854964;0;0;0;0;8.41405337266288e-05;0;0;0;0;0;0.000706850513312901;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0.000728528943473028;0;0;0;0.000844584218117228;0;0;0;0;2.77555756156289e-17;0;0;0;0;2.77555756156289e-17;0;0;0;0;0;0;0;0;0;0;0;1.11022302462516e-16;0;0;0;5.55111512312578e-17;0;0;0;0;0;0;0;0;0;0];
  x1_step2_gain = [0.02;2.90652529205517;2.06438546710481;2.23946220602676;2.37539523637238;2.73997426714905;4.0920277807005;5.7557715599214;8.92691159878492;21.2014150471142;21.3158942326794;149.211259628756;2.62104820982207;3.57516869660522;3.04179638577687;20.0758561461274;110.326787318402;2.37832058444623;2.62965928182549;2.14761135008694;8.15287604193158;100.697567001393;13.8082101181387;6.90410505906933;5.68787316202093;5.04023175880922;8.95823643358446;6.58280588604383;5.54777232569775;6.26276474268531;12.4365054041184;7.51664818918646;5.34258456896503;6.89347517584563;10.4642247682282;6.5;5.67646212197547;7.44983221287567;14.7648230602334;7.50044962753321;4.73757464964042;6.65732679083729;16.0277537068951;7.02376916856849;5.52648714142548;4.58257569495584;43.3589667773576;13.8082101181387;7.45117440407886;5.67097875150313;5.25991127935317;43.3589667773576;12.0208152801713;7.88986691902975;6.11010092660779;7.03562363973514;10.8397416943394;7.21110255092798;5.93158271200763;9.91071249821234;12.4365054041184;6.65732679083729;5.25873758497744;6.19677335393187;12.3648246606609;6.05530070819498;5.94418483337567;6.89202437604511;11.4891252930761;6.21825270205921;5.74456264653803;4.94973674286517;2;2;2;2;2;2;2;0.00595238095238095;0.00909090909090909];
  x1_step2_ymin = -1;
  
  % Layer 1
  b1 = [-0.53098658617238947421;0.20272149786741794353];
  IW1_1 = [0.19722195025935040924 0.28112005429644792986 -0.12657320893103016224 -0.21210536466268403721 -0.035926682519189463705 -0.39493382442910768271 -0.3020696945220404106 0.01522323230884442373 0.097187277745720265787 0.041697400866244613282 0.10492879761309803488 -0.11909971124202768655 -0.0066244907210747643739 -0.2212948912122371381 0.050999787909517126094 0.24931603180686343069 0.040560352783428767209 -0.21237550895575790788 0.13567523130138112175 0.090882035684369186224 0.32034194409345551069 -0.10774087081796092369 0.11421586967583878536 -0.079514828026999287425 -0.034698652040751044867 0.14984849322971155461 -0.067725685547983083268 -0.036219403860923440885 0.23747820538218897268 0.2039051334011264538 -0.13271150211559606946 0.040117309081922257474 0.16855155369352320394 0.16118539874533741041 0.072950059842294717738 -0.098476269174510688842 -0.013344528504615836562 0.099330208375705969503 0.15748119527187334765 -0.037109769793562188966 -0.053235453441013116938 0.13258856032659360746 0.065285642987211178756 -0.17455559490644631526 0.09105590093273244201 0.29655444543476289221 0.26381740268703002261 -0.29700682112518206335 -0.029465124513592445138 -0.00096917426097811081379 -0.028257201297281212687 0.14232334498950918733 -0.11049449219289088353 -0.1649678432053760524 0.12497179670529973139 0.058500941872880483918 0.03705099180792214425 -0.026529647994704048247 -0.086469259585392838074 0.11679531429077806559 -0.042583750162006182849 0.042582875136656053727 -0.17695857876516901674 0.10463639458009767191 0.019187806899491080537 0.043029603172452572657 0.25808638770859226863 -0.010222232964539121683 0.31487883618181577994 0.081966541305433834874 -0.043563189757099704535 -0.048163097608576573017 0.0550194956648852318 0.038362664776086442819 -0.037798185018390592638 0.028154407996487974819 0.10049047552355377944 0.094933914440882116725 -0.061681481198982583691 -1.1606863037037733477 -1.4913924507144165066;-0.089620506947581668467 -0.10174909023830747135 0.11251718995115973787 0.1071980670657053103 0.063398243195235071124 0.18697241285288948576 0.12668443458736561302 -0.0053044541682079034486 -0.040720020019824922086 -0.022088730808828289931 -0.055581825646518284723 0.045477192162572413481 0.061406119011773695193 0.098289723017997890353 -0.011785274649651126394 -0.11419033587679387753 -0.038992076138062430057 0.11743953402916985918 -0.049619524329711818533 0.0052882157216206917769 -0.12961435976048776841 0.0071816171453810530648 -0.045452891179526375143 0.023968353294928624458 0.0017695085327683601761 -0.081086001121598610952 0.014225670359578815663 0.0016469604671611644004 -0.086146721451123578484 -0.11249837552135942553 0.065130044680870843865 -0.027866740595135539027 -0.069814960816906371233 -0.07999951826038835534 -0.030136143593620712267 0.017932895102573606638 -0.0091223184553486883624 -0.063048751172752576233 -0.08323615867383793443 0.039056606006056024394 0.019988564420708881259 -0.067347968271630462289 -0.029297934621613067746 0.087390071537903860066 -0.038282584597386433434 -0.11813842682455878708 -0.11859767796225306746 0.12019393791109619918 -0.0072040702237843902422 -0.034630405118417674493 0.022956384205761699163 -0.06289400620322975477 0.021834822469209244633 0.05695316099320459069 -0.046810634433643569241 -0.027256769484607795001 -0.004208023269840756482 0.0090794723618569384005 0.054136319799031017153 -0.094935347138445910775 0.0027185294944815155405 -0.017324785828526166609 0.07086443400459566111 -0.046496320115535047512 -0.012422442942564252896 -0.023029262942345165438 -0.1148206758285893192 -0.039291861447340543922 -0.090370292830829229702 -0.033354817639120355743 0.025220253050455179733 0.018661466725849361337 -0.060893880927021318272 -0.040117130826657104725 0.012222107973912682555 -0.03407877534353575405 -0.070810190033806744148 -0.032209412763481611031 0.021587978028656525792 0.55317980830364221756 0.6042296680230525574];
  
  % Layer 2
  b2 = -0.81424057296108198756;
  LW2_1 = [2.9557155473584955097 -1.1599438676399571602];
  
  % Output 1
  y1_step1_ymin = -1;
  y1_step1_gain = 2;
  y1_step1_xoffset = 0;
  
  % ===== SIMULATION ========
  
  % Format Input Arguments
  isCellX = iscell(X);
  if ~isCellX, X = {X}; end;
  
  % Dimensions
  TS = size(X,2); % timesteps
  if ~isempty(X)
    Q = size(X{1},2); % samples/series
  else
    Q = 0;
  end
  
  % Allocate Outputs
  Y = cell(1,TS);
  
  % Time loop
  for ts=1:TS
  
    % Input 1
    temp = removeconstantrows_apply(X{1,ts},x1_step1_keep,x1_step1_remove);
    Xp1 = mapminmax_apply(temp,x1_step2_gain,x1_step2_xoffset,x1_step2_ymin);
    
    % Layer 1
    a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*Xp1);
    
    % Layer 2
    a2 = logsig_apply(repmat(b2,1,Q) + LW2_1*a1);
    
    % Output 1
    Y{1,ts} = mapminmax_reverse(a2,y1_step1_gain,y1_step1_xoffset,y1_step1_ymin);
  end
  
  % Final Delay States
  Xf = cell(1,0);
  Af = cell(2,0);
  
  % Format Output Arguments
  if ~isCellX, Y = cell2mat(Y); end
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings_gain,settings_xoffset,settings_ymin)
  y = bsxfun(@minus,x,settings_xoffset);
  y = bsxfun(@times,y,settings_gain);
  y = bsxfun(@plus,y,settings_ymin);
end

% Remove Constants Input Processing Function
function y = removeconstantrows_apply(x,settings_keep,settings_remove)
  if isempty(settings_remove)
    y = x;
  else
    y = x(settings_keep,:);
  end
end

% Sigmoid Positive Transfer Function
function a = logsig_apply(n)
  a = 1 ./ (1 + exp(-n));
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n)
  a = 2 ./ (1 + exp(-2*n)) - 1;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings_gain,settings_xoffset,settings_ymin)
  x = bsxfun(@minus,y,settings_ymin);
  x = bsxfun(@rdivide,x,settings_gain);
  x = bsxfun(@plus,x,settings_xoffset);
end
