frameA = 14

frameB = 18

trackA =[
   10 10;
   11 11;
   12 12;
   13 13;
   14 14;
]

trackB =[
   18 18;
   19 19;
   20 20;
   21 21;
   22 22
]

trackA = trackA + randn(size(trackA, 1), 2);
trackB = trackB + randn(size(trackB, 1), 2);
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
