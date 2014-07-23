% TODO: shape of sigma should depend on velocity and the direction of the trackAlets


% first of all, the flame should be on the exented tracklet to the past/future

% TODO: Spreading rate should depend of the variance of the velocitie and the tracklet length

% Note: the results of the model evaluation are not normalized, so it is not possible to compare directly model genreated with a different number of extruded tracks.

addpath('lightspeed')

clear all 
prof = false;
if ~prof
	clf;
end
if prof

	profile on
end
% clear all;

track5 = [
	54    324;
	53    324;
];
track6 = [
	252    293
];
track8 = [
	60    333;
	61    331;
	64    337;
	71    335;
];
track9 = [
	258    301;
	258    302;
	258    305;
	262    307;
];

% 5 -> 8 (9)
% 6 -> 9 (8)
trackA = track5;
trackB = track8;
trackC = track9;
% trackA = [
% 	% 10 10;
% 	% 10.1 11;
% 	% 10.05 12;
% 	10.2 12.5;
% 	10.5 14;
% 	10.8 14.2;
% 	11 15;
% 	11.5 16;
% 	0 0;
% 	11.2 16.9
% ];

% trackletA2D = [
%   95   410
%     99   403
%    102   400
%     98   399
%    100   399
%    103   397
%    103   395
%    104   392
%    119   385
%    122   392

% ];


% trackA = trackletA2D;
% 
numObs = size(trackA, 1);
% If there are any zero rows, interpolate the value
[~, nonzeroIdx] = eliminateZeroRows(trackA);

if any(nonzeroIdx == 0)
	trackA = interp1(find(nonzeroIdx), trackA(nonzeroIdx, :), (1:numObs)');
end

% TODO: how to handle zero rows in trackA

trackA = getTail(trackA, 50);
model = gaussianBroadeningModel(trackA, 10);  % TODO: 3 fails

minx = 7;
maxx = 15;
miny = 290;
maxy = 340;

% minx = 245;
% maxx = 260;
% miny = 285;
% maxy = 305;


% minx = 80;
% maxx = 160;
% miny = 360;
% maxy = 410;


minx = 10;
maxx = 300;
miny = 290;
maxy = 410;


resolution = 150;
[X1,X2] = meshgrid(linspace(minx, maxx,resolution)',...
				   linspace(miny, maxy,resolution)');

X = [X1(:) X2(:)];

% for i=1:100
	[val, pointsVals] = evaluateGaussianBroadeningModel(model, X);
% end
% subplot(1,2,1);
% surf(X1,X2,reshape(pointsVals, resolution, resolution)); axis equal; axis tight; 
% view(0, -90);
% xlabel('x')
% ylabel('y')
% shading interp
% % plot(muHist(:, 1), muHist(:, 2), 'gx-');  axis equal; axis tight; 

% plot the contour
% subplot(1,2,2);

if ~prof
	contour(X1, X2, reshape(pointsVals,resolution, resolution)); axis equal; axis tight;

	hold on;
	plot(trackA(:, 1), trackA(:, 2), 'ro-');  axis equal; axis tight; 
	xlabel('x');
	ylabel('y');

	plot(model.mus(:, 1), model.mus(:, 2), 'rx--');  axis equal; axis tight;
end 
%---------------------------------------------

% trackB = [
% 	11 18;
% 	11.1 19;
% 	11.05 20;
% 	11.2 20.5;
% 	11.5 22;
% 	11.8 22.2;
% 	12 23;
% 	12.5 24;
% 	12 24.7
% ];

% trackletB2D = [
%  131   395
% ];

% trackB = trackletB2D;

numObs = size(trackB, 1);
% If there are any zero rows, interpolate the value
[~, nonzeroIdx] = eliminateZeroRows(trackB);

if any(nonzeroIdx == 0)
	trackB = interp1(find(nonzeroIdx), trackB(nonzeroIdx, :), (1:numObs)');
end

trackB = getHead(trackB, 50);
% for i=1:100
	[val, pointsVals] = evaluateGaussianBroadeningModel(model, trackB);
% end
val

if ~prof
	hold on;
	plot(trackB(:, 1), trackB(:, 2), 'bo-');  axis equal; axis tight;
end

[val, pointsVals] = evaluateGaussianBroadeningModel(model, trackC);
val

% if ~prof
% 	hold on;
% 	plot(trackC(:, 1), trackC(:, 2), 'go-');  axis equal; axis tight;

% 	% legend('model values', 'intial tracklet', 'estimated tracklet path', 'candidate tracklet A', 'candidate tracklet B')
% 	title('Gaussian Broadening')
% end


if prof
	profile off
	profile viewer
end


% % valuateGaussianBroadeningModel2013.525 s0.223
% smvnpdf2010 3.302 s 3.055
% scholcov2010 0.247 s 0.247
% sgaussianBroadeningModel 1 0.002 s 0.002
% sinterp 110.001 s0.001 s

% % evaluateGaussianBroadeningModel2013.090 s0.508
% smvnormpdf2010 2.582 s0.977
% smvnormpdfln2010 1.606 s0.768
% ssolve_tril (MEX-file)2010 0.617 s 0.617
% scol_sum2010 0.220 s0.220
% sgaussianBroadeningModel 1 0.002 s 0.002 s