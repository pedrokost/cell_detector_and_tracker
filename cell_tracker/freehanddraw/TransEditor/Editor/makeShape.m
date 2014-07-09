function shape = makeShape(X,Y, shapeType, color)

X = round(X);
Y = round(Y);
count = 0;
if strcmp(shapeType,'rectangle')
    xVec = min(X(1),X(2)):max(X(1),X(2));
    yVec = min(Y(1),Y(2)):max(Y(1),Y(2));
    pNum = 2*length(xVec) + 2*length(yVec);
    points = zeros(pNum,3);
    for x = xVec
        count = count + 1;
        points(count,:) = [x, Y(1), 1];
        count = count + 1;
        points(count,:) = [x, Y(2), 1];
    end
    for y = yVec
        count = count + 1;
        points(count,:) = [X(1), y , 1];
        count = count + 1;
        points(count,:) = [X(2), y , 1];
    end
end

if strcmp(shapeType,'ellipse')
    cx = (X(1)+X(2))/2;
    cy = (Y(1)+Y(2))/2;
    radx = abs(X(1)-X(2))/2;
    rady = abs(Y(1)-Y(2))/2;
    pNum = round(max(radx,rady)*2*pi);
    points = zeros(pNum,3);
    for i=1:pNum
        x = cx + cos(i/pNum*2*pi)*radx;
        y = cy + sin(i/pNum*2*pi)*rady;
        points(i,:) = [x ,y ,1];
    end
end

if strcmp(shapeType,'line')
    deg = atan2(Y(2)-Y(1),X(2)-X(1));
    rad = round(((Y(2)-Y(1))^2+(X(2)-X(1)).^2).^0.5);
    pNum = rad;
    points = zeros(pNum,3);
    for i=1:pNum;
        x = X(1) + cos(deg)*i;
        y = Y(1) + sin(deg)*i;
        points(i,:) = [x ,y ,1];
    end
end

if strcmp(shapeType,'flower1')
    cx = (X(1)+X(2))/2;
    cy = (Y(1)+Y(2))/2;
    radx = abs(X(1)-X(2))/2;
    rady = abs(Y(1)-Y(2))/2;
    pNum = round(max(radx,rady)*5*2*pi);
    points = zeros(pNum,3);
    for i=1:pNum
        x = cx + sin(i/pNum*2*pi*5)*cos(i/pNum*2*pi)*radx;
        y = cy - sin(i/pNum*2*pi*5)*sin(i/pNum*2*pi)*rady;
        points(i,:) = [x ,y ,1];
    end
end

if strcmp(shapeType,'flower2')
    cx = (X(1)+X(2))/2;
    cy = (Y(1)+Y(2))/2;
    radx = abs(X(1)-X(2))/2;
    rady = abs(Y(1)-Y(2))/2;
    radNums = linspace(round(min(radx,rady)*0.3),round(min(radx,rady)),5);
    col = color;   
    
    pNum = 0;
    for rad = radNums
        pNum = pNum + round(rad*4*pi)+1;
    end
    
    points = zeros(pNum,3);
    color = zeros(pNum);
    count = 0;
    radN = 0;
    for rad = radNums
        radN = radN + 1;
        iterNum = round(rad*4*pi);
        for i=0:iterNum
            count = count + 1;      
            deg = i/iterNum*2*pi;
            x = cx + rad*cos(deg)*(cos(deg*6)*0.2+0.8);
            y = cy - rad*sin(deg)*(cos(deg*6)*0.2+0.8);
            points(count,:) = [x ,y ,1];
            color(count) = max(col+radN*5,0);
        end
    end
    
end

if strcmp(shapeType,'leaf')
    
    cx = (X(1)+X(2))/2;
    cy = (Y(1)+Y(2))/2;
    radx = abs(X(1)-X(2))/2;
    rady = abs(Y(1)-Y(2))/2;
    pNum = round(max(radx,rady)*5*8*pi);
    points = zeros(pNum,3);    
    for i=1:pNum
        deg =i/pNum*2*pi;
        x = cx + 2*radx*cos(deg)*(sin(deg)+1)*(9/10*cos(8*deg)+1)*(1/10*cos(24*deg)+1)*(1/10*cos(100*deg)+1/10);
        y = cy + rady/1.5 - 2.5*rady*sin(deg)*(sin(deg)+1)*(9/10*cos(8*deg)+1)*(1/10*cos(24*deg)+1)*(1/10*cos(100*deg)+1/10);
        points(i,:) = [x ,y ,1];
    end;
end

shape = struct('type', shapeType,'pNum',pNum,'points',points,'color',color);