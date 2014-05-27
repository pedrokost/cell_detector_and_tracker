imgpath = fullfile('phasecontrast', 'trainPhasecontrast', 'im01.pgm')
I = imread(imgpath);
figure(1);
imshow(I)

annotationpath = fullfile('phasecontrast', 'trainPhasecontrast', 'im01.mat')
load(annotationpath)
hold on;
plot(gt(:, 1), gt(:, 2), '+');
load(annotationpath)

