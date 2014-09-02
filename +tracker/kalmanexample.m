frameA = 43

frameB = 44

trackA =[

   248   469;
   249   469;
   247   466;
   246   466;
   245   464;
   249   460;
   244   461;
   247   464;
   242   468;
   248   464;
   246   460;
   246   465;
   249   463;
   248   460;

]

trackB =[
   248   460;
   245   460;
   248   460;
   242   454;
   241   454;
   245   451;
]
addpath(fullfile('dependencies', 'matlab'))
tracker.kalmanExtrapolatedMidpoints(trackA, trackB, frameA, frameB);

% frameA =

%     43


% frameB =

%     52


% trackA =

%    248   469
%    249   469
%    247   466
%    246   466
%    245   464
%    249   460
%    244   461
%    247   464
%    242   468
%    248   464
%    246   460
%    246   465
%    249   463
%    248   460


% trackB =

%    240   451
%    236   450
%    239   449
%    240   442
%    236   433
