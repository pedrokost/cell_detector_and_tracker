function T = scalingMatrix(x,y)
T = eye(3,3);
T(1,1) = x;
T(2,2) = y;