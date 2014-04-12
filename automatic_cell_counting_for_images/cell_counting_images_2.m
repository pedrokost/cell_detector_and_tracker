% addpath('extrema/');
%% Parameters

% maximum number of cells in image ( * 5 )
MAX_CELLS = 1000; % Actually it's the max number of local optima
% minimum cell intensity (out of 255  or the number of level)
CELL_THRESH = 10; 
% Each cell must be larger than 1/100 of the width of the image
MIN_CELL_SIZE_RATIO = 4/100;
% Thresolding window size
THRESHOLD_WINDOW = 51;

%% plot options
wp = 2;
hp = 3;
figure(1); clf;

%% Step 0: Read image and convert to BW
A = imread('cells.jpg');
I = rgb2gray(A);
[h, w] = size(I);
% subplot(wp,hp,1); imshow(A);
subplot(wp,hp,1); imshow(I);

%% Step 1: Apply a 3x3 spatial adaptive filter
J = wiener2(I, [5 5]);
subplot(wp,hp,2); imshow(J);

%% Step3: Remove noise by erosion
% se = strel('disk', 0);
% J = imdilate(J, se);
% se2 = strel('disk', 5);
% J = imerode(J, se2);
% subplot(wp, hp, 5); imshow(J,[])

%% Step2: Find the local thresold
J=(J>conv2(J,1/(THRESHOLD_WINDOW^2)*ones(THRESHOLD_WINDOW),'same'));
subplot(wp, hp, 3); imshow(J, [])

%% Step 3: Progressive Flooding
% www.ncc.org.in/download.php?f=NCC2003/C-7.pdf
% http://www.mathworks.co.uk/help/images/ref/watershed.html
% Compute the distance transform of the complement of the binary image.
D = bwdist(~J);
subplot(wp, hp, 4); imshow(D,[])
D = -D;
D(J<=0.05) = -inf;
subplot(wp, hp, 5); imagesc(D)
L = watershed(J, 4);
max(max(L))
subplot(wp, hp, 6); imagesc(L)

% subplot(1,3,2); imshow(D,[],'InitialMagnification','fit')
% title('Distance transform of ~bw')
% % Complement the distance transform, and force pixels that don't belong to the objects to be at -Inf.
% D = -D;
% D(~bw) = -Inf;
% 
% L = watershed(D);
% rgb = label2rgb(L,'jet',[.5 .5 .5]);