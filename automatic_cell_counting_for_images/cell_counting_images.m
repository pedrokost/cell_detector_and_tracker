% addpath('extrema/');
addpath('imoverlay/');
%% Parameters
 
% Each cell must be larger than 1/100 of the width of the image
MIN_CELL_SIZE_RATIO = 1/100;

%% plot options
wp = 3;
hp = 3;
figure(1); clf;

%% Step 0: Read image and convert to BW
A = imread('cells.jpg');
I = rgb2gray(A);
[h, w] = size(I);
subplot(wp,hp,1); imshow(A);
subplot(wp,hp,2); imshow(I);

%% Step 0.5: Improve contrast (adaptive)
I = adapthisteq(I);

%% Step 0.6: Remove objects on the borders
I = imclearborder(I);

%% Step 1: Apply a 3x3 spatial adaptive filter
I = wiener2(I, [5 5]);
subplot(wp,hp,3); imshow(I);

%% Step 1.5: Display a thresolded image
bw = im2bw(I, graythresh(I));  % this step removes faint cells
bw2 = imfill(bw,'holes');
bw3 = imopen(bw2, strel('disk',2));
bw4 = bwareaopen(bw3, 10);
bw4_perim = bwperim(bw4);
overlay1 = imoverlay(I, bw4_perim, [1 .3 .3]);
subplot(wp,hp,4); imshow(overlay1)

%% Step 2: Find local minimums
H = nearestOdd(w * MIN_CELL_SIZE_RATIO);
maxs = imextendedmax(I, H);
subplot(wp,hp,5); imshow(maxs);

maxs = imclose(maxs, strel('disk',3));
maxs = imfill(maxs, 'holes');
maxs = bwareaopen(maxs, 2);
overlay2 = imoverlay(I, bw4_perim | maxs, [1 .3 .3]);
subplot(wp,hp,6); imshow(overlay2)

%% Step 3: Progressive Flooding
% www.ncc.org.in/download.php?f=NCC2003/C-7.pdf
% http://www.mathworks.co.uk/help/images/ref/watershed.html

Jc = imcomplement(I);
% Next: modify the image so that the background
% pixels and the extended maxima pixels are forced to
% be the only local minima in the image.
I_mod = imimposemin(Jc, ~bw4 | maxs);

L = watershed(I_mod);
subplot(wp, hp, 7); imshow(label2rgb(L))

% Step 4: Labeling count
[L, num] = bwlabel(L);
fprintf('Found %d cell\n', num)

% Overlay original and labels
mask = im2bw(L, 1);
subplot(wp, hp, 8); imagesc(mask)
overlay2 = imoverlay(I, mask, [1 .3 .3]);
subplot(wp, hp, 9); imagesc(overlay2)