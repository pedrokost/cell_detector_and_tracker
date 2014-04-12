function [IMIN, XMIN] = minima(I, N)
% MINIMA Locates all pixels that have the lowest grayscale level in a
% neighborhood
% Inputs:
%   I: grayscale image
%   N: neigborhood in which to locate minima. Default [5 5]
% Ouputs:
%   IMIN: indices of local minima
%   XMAX: values of local minima

if nargin < 2
   N = [5 5]; 
end
[h, w] = size(I);
Ncol = N(1); Nrow = N(2);

maxs = [];
for col=1:Ncol:h
    for row=1:Nrow:w
        colEnd = min(col+Ncol-1, h);
        rowEnd = min(row+Nrow-1, w);
        patch = I(col:colEnd, row:rowEnd);
        [r, c] = findMaxs(patch);
        maxs = [maxs; r c];
        break
    end
    break
end

IMIN = 1;
XMIN = 1;

end

function [c, r] = findMaxs(array)
% FINDMAXS locates all potential optima
% Inputs:
%   array: a small array of numbers
% Outputs:
%   col and row coordinates of global optima
array



end