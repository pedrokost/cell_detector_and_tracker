function b = padarray(varargin)
%PADARRAY Pad array.
%   B = PADARRAY(A,PADSIZE) pads array A with PADSIZE(k) number of zeros
%   along the k-th dimension of A.  PADSIZE should be a vector of
%   nonnegative integers.
%
%   B = PADARRAY(A,PADSIZE,PADVAL) pads array A with PADVAL (a scalar)
%   instead of with zeros.
%
%   B = PADARRAY(A,PADSIZE,PADVAL,DIRECTION) pads A in the direction
%   specified by the string DIRECTION.  DIRECTION can be one of the
%   following strings.
%
%       String values for DIRECTION
%       'pre'         Pads before the first array element along each
%                     dimension .
%       'post'        Pads after the last array element along each
%                     dimension.
%       'both'        Pads before the first array element and after the
%                     last array element along each dimension.
%
%   By default, DIRECTION is 'both'.
%
%   B = PADARRAY(A,PADSIZE,METHOD,DIRECTION) pads array A using the
%   specified METHOD.  METHOD can be one of these strings:
%
%       String values for METHOD
%       'circular'    Pads with circular repetition of elements.
%       'replicate'   Repeats border elements of A.
%       'symmetric'   Pads array with mirror reflections of itself.
%
%   Class Support
%   -------------
%   When padding with a constant value, A can be numeric or logical.
%   When padding using the 'circular', 'replicate', or 'symmetric'
%   methods, A can be of any class.  B is of the same class as A.
%
%   Example
%   -------
%   Add three elements of padding to the beginning of a vector.  The
%   padding elements contain mirror copies of the array.
%
%       b = padarray([1 2 3 4],3,'symmetric','pre')
%
%   Add three elements of padding to the end of the first dimension of
%   the array and two elements of padding to the end of the second
%   dimension.  Use the value of the last array element as the padding
%   value.
%
%       B = padarray([1 2; 3 4],[3 2],'replicate','post')
%
%   Add three elements of padding to each dimension of a
%   three-dimensional array.  Each pad element contains the value 0.
%
%       A = [1 2; 3 4];
%       B = [5 6; 7 8];
%       C = cat(3,A,B)
%       D = padarray(C,[3 3],0,'both')
%
%   See also CIRCSHIFT, IMFILTER.

%   Copyright 1993-2010 The MathWorks, Inc.

[a, method, padSize, padVal, direction] = ParseInputs(varargin{:});

if isempty(a)
    
    % treat empty matrix similar for any method
    if strcmp(direction,'both')
        sizeB = size(a) + 2*padSize;
    else
        sizeB = size(a) + padSize;
    end
    
    b = mkconstarray(class(a), padVal, sizeB);
    
elseif strcmpi(method,'constant')
    
    % constant value padding with padVal
    b = ConstantPad(a, padSize, padVal, direction);
else
    
    % compute indices then index into input image
    aSize = size(a);
    aIdx = getPaddingIndices(aSize,padSize,method,direction);
    b = a(aIdx{:});
end

if islogical(a)
    b = logical(b);
end


%%%
%%% ConstantPad
%%%
function b = ConstantPad(a, padSize, padVal, direction)

numDims = numel(padSize);

% Form index vectors to subsasgn input array into output array.
% Also compute the size of the output array.
idx   = cell(1,numDims);
sizeB = zeros(1,numDims);
for k = 1:numDims
    M = size(a,k);
    switch direction
        case 'pre'
            idx{k}   = (1:M) + padSize(k);
            sizeB(k) = M + padSize(k);
            
        case 'post'
            idx{k}   = 1:M;
            sizeB(k) = M + padSize(k);
            
        case 'both'
            idx{k}   = (1:M) + padSize(k);
            sizeB(k) = M + 2*padSize(k);
    end
end

% Initialize output array with the padding value.  Make sure the
% output array is the same type as the input.
b         = mkconstarray(class(a), padVal, sizeB);
b(idx{:}) = a;


%%%
%%% ParseInputs
%%%
function [a, method, padSize, padVal, direction] = ParseInputs(a, padSize, varargin)

% % narginchk(2,4);

% % fixed syntax args
% a         = varargin{1};
% padSize   = varargin{2};

% default values
method    = 'constant';
padVal    = varargin{1};
direction = 'both';

% validateattributes(padSize, {'double'}, {'real' 'vector' 'nonnan' 'nonnegative' ...
%     'integer'}, mfilename, 'PADSIZE', 2);

% Preprocess the padding size
% if (numel(padSize) < ndims(a))
%     padSize           = padSize(:);
%     padSize(ndims(a)) = 0;
% end

% if nargin > 2
    
%     firstStringToProcess = 1;
    
%     % if ~ischar(varargin{1})
%     % Third input must be pad value.
%     padVal = varargin{1};
%     % validateattributes(padVal, {'numeric' 'logical'}, {'scalar'}, ...
%     %     mfilename, 'PADVAL', 3);
    
%     firstStringToProcess = 2;
        
%     % end
    
%     direction = varargin{firstStringToProcess};
%     % for k = firstStringToProcess:(nargin - 2)
%     %     % validStrings = {'circular' 'replicate' 'symmetric' 'pre' ...
%     %     %     'post' 'both'};
%     %     % string = validatestring(varargin{k}, validStrings, mfilename, ...
%     %     %     'METHOD or DIRECTION', k)
%     %     string = varargin{k};
%     %     switch string
%     %         case {'circular' 'replicate' 'symmetric'}
%     %             method = string;
                
%     %         case {'pre' 'post' 'both'}
%     %             direction = string;
                
%     %         otherwise
%     %             error(message('images:padarray:unexpectedError'))
%     %     end
%     % end
% end

% % Check the input array type
% if strcmp(method,'constant') && ~(isnumeric(a) || islogical(a))
%     error(message('images:padarray:badTypeForConstantPadding'))
% end
