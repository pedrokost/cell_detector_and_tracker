function T = rotationMatrix(deg)
T = eye(3,3);
T(1,1) = cos(deg);
T(2,2) = T(1,1);
T(2,1) = sin(deg);
T(1,2) = -T(2,1);
