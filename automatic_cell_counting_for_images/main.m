image = imread('images/7.jpg');

options.plot = f;
options.plotName = 'count_cells_7';
options.darkCells = false;
options.minCellArea = 3;
options.openingKernelSize = 2;
options.minCellSizeRatio = 1/100;
options.clearBorders = false;
options.fillHoles = false;
[count] = countCells(image, options);