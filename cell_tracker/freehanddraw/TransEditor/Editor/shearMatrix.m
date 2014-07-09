function T = shearMatrix(sx,yRef,sy,xRef)
T = eye(3,3);
T(1,2) = sx;
T(1,3) = -sx*yRef;
T(2,1) = sy;
T(2,3) = -sy*xRef;
