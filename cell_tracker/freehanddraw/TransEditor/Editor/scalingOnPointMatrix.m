function T = scalingOnPointMatrix(x,y,a,b)
T = translationMatrix(x,y)*scalingMatrix(a,b)*translationMatrix(-x,-y);

