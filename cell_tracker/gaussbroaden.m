% TODO: shape of sigma should depend on velocity and the direction of the trackAlets


% first of all, the flame should be on the exented tracklet to the past/future

% TODO: Spreading rate should depend of the variance of the velocitie and the tracklet length

clf;
% clear all;

trackA = [
	10 10;
	10.1 11;
	% 10.05 12;
	% 10.2 12.5;
	% 10.5 14;
	% 10.8 14.2;
	% 11 15;
	% 11.5 16;
	% 11 16.7
];

trackB = [
	3     6;
	10    14;
	13    18;
	22    28;
	28    29;
	34    32;
	36    37;
	37    38;
	40    45;
	48    50;
	57    56;
	64    64;
	72    73;
	74    81;
];

numExtrudeFrame = 20;

% Use only last 10 cells
n = min(10, size(trackA, 1));
trackA = trackA(1:n, :);

% Set the first value to 0 0

% trackA = bsxfun(@minus, trackA, trackA(1, :));

% Compute velocity (speed and direction)
dist = trackA(1:end-1, :) - trackA(2:end, :);
displacement = sum(dist, 1);
vel = displacement / n;
% Estimate the dimensions of the distribution in 2D

strt = trackA(1, :);
endt = strt - numExtrudeFrame * vel;

% minx = min(strt(1), endt(1));
% maxx = max(strt(1), endt(1));
% miny = min(strt(2), endt(2));
% maxy = max(strt(2), endt(2));

minx = 5;
maxx = 15;
miny = 0;
maxy = 5;

numStds = 1; % strech by numStds
resolution = 150;

% Depends on the rate of growth of sigma
maxSigma = abs(numExtrudeFrame * vel);

minx = minx - numStds * maxSigma(1);
maxx = maxx + numStds * maxSigma(1);
miny = miny - numStds * maxSigma(2);
maxy = maxy + numStds * maxSigma(2);

[X1,X2] = meshgrid(linspace(minx, maxx,resolution)',...
				   linspace(miny, maxy,resolution)');

X = [X1(:) X2(:)];

muHist = zeros(1, 2, numExtrudeFrame);
sigmaHist = zeros(2,2,numExtrudeFrame);

% generate a gaussian at final place
mu = trackA(1, :); sigma = diag(abs(vel));
sigma = sigma / norm(sigma);
if isnan(sigma)
	sigma = eye(2)/2;
end
sigma_orig = sigma;

% TODO: only evaluate function on specific areas, that is the trackAlet positions
% Thes's no need to normalize the likelihood into he probability, because I normalize before running the neural network.

pAll = zeros(resolution * resolution, 1);


for i=1:numExtrudeFrame
	muHist(:, :, i) = mu;
	sigmaHist(:, :, i) = sigma;

	p = mvnpdf(X, mu, sigma);

	pAll = pAll + p;

	mu = mu + vel; %(rand(1,2)-0.5)*3;
	if vel == zeros(1, 2);
		sigma = sigma + eye(2);  % * 1.2
	else
		sigma = sigma + diag(abs(vel));  % * 1.2
	end
end
muHist = permute(muHist, [3 2 1]);

% add all gaussians together
% subplot(1,2,1);
% imagesc(reshape(pAll,resolution, resolution)); axis equal; axis tight; 
surf(X1,X2,reshape(pAll,resolution, resolution)); axis equal; axis tight; 
view(0, -90);
xlabel('x')
ylabel('y')
shading interp

hold on;
plot(trackA(:, 1), trackA(:, 2), 'ro-');  axis equal; axis tight; 
plot(muHist(:, 1), muHist(:, 2), 'gx-');  axis equal; axis tight; 

% % plot the contour
% subplot(1,2,2);
% contour(reshape(pAll,resolution, resolution)); axis equal; axis tight; 
% xlabel('x')
% ylabel('y')

% hold on;
% plot(trackA(:, 1), trackA(:, 2), 'ro-');  axis equal; axis tight; 
% plot(muHist(:, 1), muHist(:, 2), 'gx-');  axis equal; axis tight; 
% %------------------------------------------