function shape = shapeTrans(shape,T)
points = shape.points;
for i=1:shape.pNum
    p = points(i,:)';
    pt = (T*p)';
    shape.points(i,:) = pt;    
end