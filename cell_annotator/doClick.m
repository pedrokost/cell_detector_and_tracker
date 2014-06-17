function [P, clickedImgs] = doClick(numImages, imgWidth, imgGap, varargin)
    % DOCLICK: Performs a click, and returns its coordinate together with the
    % image that was clicked on

    %-------------------------------------------------------------Defaults
    P = [];           % don't touch: click coordinate
    clickedImgs = [];  % don't touch: the indeci of the clicked image. Always sorted.
    nDisplays = 3;    % number of images
    ALLOWED_BUTTONS = [3];  % only accepts right clicks as 'click'
    N = 1;            % number of cliks
    % numImages = total number of images
    % imgWidth = the width of a single image in pixels (assumes all images
    %    same width)
    % imgGap = gap width between images


    %-----------------------------------------------------------Overwrites
    for i=1:2:(nargin-3)
        switch varargin{i}
            case 'nDisplays'
                nDisplays = varargin{i+1};
            case 'N'
                N = varargin{i+1};
            otherwise
                warning('Unrecognized option %s', varargin{i});
        end
    end
    %-----------------------------------------------------------Overwrites


    try
        if N > 1
            [X, Y, button] = ginput2(N, 'KeepZoom', 'og');
        else
            [X, Y, button] = ginput2(N, 'KeepZoom');
        end
    catch
        X = []; Y = []; button = [];
    end
    clickedImgs = [];
    P = round([X Y]);
    if ~ismember(button, ALLOWED_BUTTONS); return; end
    % Compute the clicked image
    % assume all images same width

    clickedImgs = zeros(numel(X), 1);

    for p=1:numel(X)

        curDisp = -1;
        while P(p, 1) > imgWidth
            P(p, 1) = P(p, 1)-imgWidth-imgGap;
            curDisp = curDisp + 1;
        end 

        % I need to get the current Image index as late as possible, because
        % otherwise the value is 'cached' and too old if the use scrolls while
        % this function is waiting
        curImageShown = evalin('caller', 'curIdx');
        clickedImgs(p) = curImageShown + curDisp;
        if curImageShown <= floor(nDisplays/2)
            clickedImgs(p) = clickedImgs(p) + 1;
        elseif curImageShown > numImages - floor(nDisplays/2)
            clickedImgs(p) = clickedImgs(p) - 1;
        end
        
        fprintf('Clicked on image %d (%d) at [%d %d]\n', clickedImgs(p), curDisp, P(p, 1), P(p, 2));
    end

    % Discard click on the gap
    if any(P < 0);
        P=[]; clickedImgs = [];
        warning('Clicks invalidated because you cliked on the gap between images')
        return
    end

    % Discard clicks if they are done on same image
    if numel(unique(clickedImgs)) == 1 && numel(clickedImgs) > 1
        P=[]; clickedImgs = [];
        warning('You clicked twice the same image. Cliks invalidated.')
        return;
    end

    % Sort the data in accordance with the index of the clicked image
    [clickedImgs, I] = sort(clickedImgs);
    P = P(I, :);

    % Discard clicks if the images not consecutive
    if N>1 && ~all(diff(clickedImgs)==1)
        P=[]; clickedImgs = [];
        warning('Your clicks must belongs to consecutive images.')
        return;
    end
end