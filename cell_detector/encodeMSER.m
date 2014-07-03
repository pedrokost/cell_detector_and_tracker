function [x, descriptor] = encodeMSER(img, colorImg, edgeImg, gradImg, orientGrad, sel, ell, parms)
%Encodes a single MSER with the selected features.
%OUTPUT:
%   x =  feature vector
%INPUT:
%   im = image (UINT8)
%   sel = linear indexes of the MSER pixels in im
%   ell = Vector with the information of the ellipse fitted to the MSER
%   (VL_feat)
%   parms = structure indicating the different features and parameters

mask = logical(false(size(img,1), size(img,2)));
mask(sel) = 1;
x = zeros(1,parms.nFeatures);
descriptor = zeros(1, parms.nDescriptor);
pos = 1;
dPos = 1;

%get ROI
if parms.addDiffHist && parms.addPos
    st = fastregionprops(logical(mask), 'BoundingBox', 'Centroid');
elseif parms.addDiffHist || parms.addShape || parms.addOrientation
    st = fastregionprops(logical(mask), 'BoundingBox');
elseif parms.addPos
    st = fastregionprops(logical(mask), 'Centroid');
end

%--feature computation

descriptor(dPos) = numel(sel);  % area
dPos = dPos + 1;

if parms.addArea
    numPixels = size(img,1)*size(img,2);
    x(pos:pos+parms.nBinsArea-1) = [(numel(sel)/numPixels) zeros(1,parms.nBinsArea - 1)];
    pos = pos+parms.nBinsArea;
end

if parms.addPos
    centroid = round(st.Centroid);
    x(pos:pos+numel(centroid)-1) = centroid;
    pos = pos+numel(centroid);
end


intHist = fasthist(img(mask == 1), 0:255/parms.nBinsIntHist:255-255/parms.nBinsIntHist);
intHist = intHist/norm(intHist,2);
descriptor(dPos:dPos+parms.nBinsIntHist-1) = intHist;
dPos = dPos+parms.nBinsIntHist;

if parms.addIntHist
    x(pos:pos+parms.nBinsIntHist-1) = intHist;
    pos = pos+parms.nBinsIntHist;

    descriptor(dPos:dPos+parms.nBinsIntHist-1) = intHist;
    dPos = dPos+parms.nBinsIntHist;
end
    
if ~isempty(colorImg)
    for layer = 1:size(colorImg,3)
        color = colorImg(:,:,layer);
        intHist = fasthist(color(mask == 1),0:255/parms.nBinsIntHist:255-255/parms.nBinsIntHist);
        intHist = intHist/norm(intHist,2);

        descriptor(dPos:dPos+parms.nBinsIntHist-1) = intHist;
        dPos = dPos+parms.nBinsIntHist;

        if parms.addIntHist
            x(pos:pos+parms.nBinsIntHist-1) = intHist;
            pos = pos+parms.nBinsIntHist;
        end
    end
end

if parms.addDiffHist || parms.addShape || parms.addOrientation
    x1 = round(max([1 st(1).BoundingBox(1)-(parms.nDilationScales*parms.nDilations+2)]));
    y1 = round(max([1 st(1).BoundingBox(2)-(parms.nDilationScales*parms.nDilations+2)]));
    x2 = round(min([size(mask,2) st(1).BoundingBox(1)+st(1).BoundingBox(3)+...
        parms.nDilationScales*parms.nDilations+2]));
    y2 = round(min([size(mask,1) st(1).BoundingBox(2)+st(1).BoundingBox(4)+...
        parms.nDilationScales*parms.nDilations+2]));

    maskROI = mask(y1:y2,x1:x2);
end

if parms.addDiffHist
    imgROI = img(y1:y2,x1:x2);

    boundary = fastbwmorph(maskROI, 'remove');
    for i = 1:parms.nDilationScales
        border = boundary;
        dilatedMask = fastbwmorph(maskROI, 'dilate', i*parms.nDilations);
        borderBig = fastbwmorph(dilatedMask, 'remove');
        
        %Discard the regions that did not grow (against image borders)
        constrained = border == borderBig;
        border(border == constrained) = 0;
        borderBig(borderBig == constrained) = 0;
        clear constrained
        
        [~,distanceTransf] = bwdist(borderBig);
        % subplot(1,2,i); imagesc(distanceTransf);
        
        borderPixels = border == 1;
        intensitiesIn = imgROI(borderPixels);
        intensitiesOut = imgROI(distanceTransf(borderPixels));
        differences =  abs(double(intensitiesIn) - double(intensitiesOut));
        diffHist = fasthist(differences,0:255/parms.nBinsDiffHist:255-255/parms.nBinsDiffHist);
        diffHist = diffHist/norm(diffHist,2);
        % To check, [a(:,1),a(:,2)]=ind2sub(size(im),distanceTransf(borderPixels))
        x(pos:pos+parms.nBinsDiffHist-1) = diffHist;
        pos = pos+parms.nBinsDiffHist;


        descriptor(dPos:dPos+parms.nBinsDiffHist-1) = diffHist;
        dPos = dPos+parms.nBinsDiffHist;

        
    end
end
if parms.addShape || parms.addOrientation
    [bins,angle] = fastcpdh(maskROI, parms.nAngBins, parms.nRadBins);
    if parms.addShape
        x(pos:pos+length(bins)-1) = bins';
        pos = pos+length(bins);

        descriptor(dPos:dPos+length(bins)-1) = bins';
        dPos = dPos+length(bins);
    end
    if parms.addOrientation
        orientHist = histc(angle,-90:180/parms.nBinsOrient:90-180/parms.nBinsOrient);
        x(pos:pos+parms.nBinsOrient-1) = orientHist;
        pos = pos+parms.nBinsOrient;

        descriptor(dPos:dPos+parms.nBinsOrient-1) = orientHist;
        dPos = dPos+parms.nBinsOrient;
    end
end

if parms.addEdges
    nEdges = numel(find(edgeImg(sel) == 1));
    numPixels = size(img,1)*size(img,2);
    nEdges = 100*nEdges/numPixels;
    x(pos) = nEdges;
    pos = pos + 1;

    descriptor(dPos) = nEdges;
    dPos = dPos + 1;
end

if parms.addOrientGrad
    binsOrientGrad = linspace(0,180,parms.nBinsOrientGrad);
    qOrientGrad = vl_binsearch(binsOrientGrad,orientGrad);

    depthMap = 1.0./sqrt(ones(size(img)));

    wGrad = gradImg.*sqrt(depthMap);
    sumOrientGrad = vl_binsum(zeros(1,parms.nBinsOrientGrad), wGrad(sel), qOrientGrad(sel));
    sumOrientGrad = sumOrientGrad/(numel(sel)*10);
    x(pos:pos+parms.nBinsOrientGrad-1) = sumOrientGrad;
    pos = pos+parms.nBinsOrientGrad;

    descriptor(dPos:dPos+parms.nBinsOrientGrad-1) = sumOrientGrad;
    dPos = dPos+parms.nBinsOrientGrad;
end

if parms.addBias
    %leave the space, added outside
    x(pos) = parms.bias;
    pos = pos + 1;
end

x = x';
end