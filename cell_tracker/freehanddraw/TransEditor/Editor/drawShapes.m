function im = drawShapes(im, shapes, col)
if nargin<3
    col = 0;
end
eps = 0.0001;
[m,n] = size(im);
for sNum=1:length(shapes)
    shape = shapes(sNum);
    points = shape.points;
    if col>0
        color = col;
    else
        color = shape.color;
    end
    
    if length(color) == 1
        for i=1:shape.pNum
            w = max(points(i,3), eps);
            y = min(max(round(points(i,2)/w) , 1), m);
            x = min(max(round(points(i,1)/w) , 1), n);
            im(y,x) = color;
        end
    else
        for i=1:shape.pNum
            w = max(points(i,3), eps);
            y = min(max(round(points(i,2)/w) , 1), m);
            x = min(max(round(points(i,1)/w) , 1), n);
            im(y,x) = color(i);
        end
    end
end