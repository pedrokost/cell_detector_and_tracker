function T = rotationOnPointMatrix(x,y,deg)
T = translationMatrix(x,y)*rotationMatrix(deg)*translationMatrix(-x,-y);

