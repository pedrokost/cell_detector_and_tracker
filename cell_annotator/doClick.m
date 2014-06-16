function [P, clickedImg] = doClick(curImageShown, numImages, imgWidth, imgGap, varargin)
    % DOCLICK: Performs a click, and returns its coordinate together with the
    % image that was clicked on

    %-------------------------------------------------------------Defaults
    P = [];           % don't touch: click coordinate
    clickedImg = [];  % don't touch: the index of the clicked image
    nDisplays = 3;    % number of images
    ALLOWED_BUTTONS = [3];  % only accepts right clicks as 'click'
    % curImageShown = index of the currenly displayed image
    % numImages = total number of images
    % imgWidth = the width of a single image in pixels (assumes all images
    %    same width)
    % imgGap = gap width between images

    %-----------------------------------------------------------Overwrites
    for i=5:2:nargin
        switch varargin{i}
            case 'nDisplays'
                nDisplays = varargin{i+1};
            otherwise
                warning('Unrecognized option %s', varargin{i});
        end
    end
    %-----------------------------------------------------------Overwrites


    try
        [X, Y, button] = ginput2(1, 'KeepZoom');
    catch
        X = []; Y = []; button = [];
    end
    P = round([X Y]);
    if ~ismember(button, ALLOWED_BUTTONS); return; end
    % Compute the clicked image
    % assume all images same width

    if numel(P) == 2
        curDisp = -1;
        while P(1) > imgWidth
            P(1) = P(1)-imgWidth-imgGap;
            curDisp = curDisp + 1;
        end

        % Discard click on the gap
        if any(P < 0); return; end

        clickedImg = curImageShown + curDisp;
        if curImageShown <= floor(nDisplays/2)
            clickedImg = clickedImg + 1;
        elseif curImageShown > numImages - floor(nDisplays/2)
            clickedImg = clickedImg - 1;
        end
            
        fprintf('Clicked on image %d (%d) at [%d %d]\n', clickedImg, curDisp, P(1), P(2));
    end
end