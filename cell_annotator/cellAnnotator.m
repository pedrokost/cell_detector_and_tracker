function cellAnnotator
    %cellAnnotator GUI tool for cell and cell sequence annotation
    
    error(javachk('swing',mfilename)) % ensure that Swing components are available

    addpath('relativepath');
    addpath('vl_feat');
    % =====================================================================
    % ------------FUNCTION GLOBALS-----------------------------------------
    % =====================================================================
    usrMatfileNames = '';
    detMatfileNames = '';
    imgfileNames = '';
    imgFolderName = '';
    detMatFolderName = '';
    images = cell(1,1); % cache of images
    usrAnnotations = struct('dirty', false, 'dots', zeros(0, 2)); % cache of annotation
    detAnnotations = cell(1,1);
    curIdx = 1;
    numImages = 0;
    
    imgFormat = 'pgm';
    imgPrefix = 'im';
    imgGap = 25;
    imgWidth = 0;
    
    figWidth = 1025;
    figHeight = 500;
    padding = 10;
    
    colormaps = 'gray|jet|hsv|hot|cool';
    disableFilters = false;
    
    testing = 1;

    ACTION_OFF = 1;
    ACTION_ADD = 2;
    ACTION_DEL = 3;
    ACTION_ADDLINK = 4;
    ACTION_DELLINK = 5;

    action = ACTION_OFF;
    
    % =====================================================================
    % ------------SETUP COMPONENTS-----------------------------------------
    % =====================================================================
    %  Create and then hide the GUI as it is being constructed.
    f = figure('Visible','off','Position',[0,0,figWidth,figHeight]);
    
    % Hide toolbar
    set(f, 'Menu','none', 'Toolbar','none')
    
    % Get the factor to convert pixels to characters
    size_pixels=get(gcf,'Position');
    set(gcf,'Units','characters');
    size_characters=get(gcf,'Position');
    set(gcf,'Units','pixels');
    pix2chars=size_pixels(3:4)./size_characters(3:4);

    halfWidth = figWidth/2 - padding*1.5;
    quarterWidth = halfWidth / 2 - padding * 1.5;
    buttonWidth = 40;

    hbrowse = uicontrol('Style','pushbutton',...
           'String','Choose image folder',...
           'Position', [padding figHeight-30 halfWidth 25],...
           'Callback',{@hbrowse_callback});
    hbrowsedet = uicontrol('Style','pushbutton',...
           'String','Choose detections folder',...
           'Position', [halfWidth + 2*padding figHeight-30 quarterWidth 25],...
           'Callback', {@hbrowsemat_callback});
    hsave = uicontrol('Style','pushbutton',...
           'String','Save',...
           'Position', [halfWidth + quarterWidth + 3.5*padding figHeight-30 quarterWidth 25],...
           'Callback', {@save_callback},...
           'Visible', 'off');

    hactions = uibuttongroup('Visible','off',...
        'Units', 'Pixels',...
        'Position', [padding figHeight-115 buttonWidth*5+padding*4 + 10 30],...
        'SelectionChangeFcn', {@changedAction_callback});
    hoff = uicontrol('Style','togglebutton',...
           'String','off',...
           'Position', [4 1 buttonWidth 25],...
           'Parent', hactions, ...
           'HandleVisibility','off');
    hadd = uicontrol('Style','togglebutton',...
           'String','+',...
           'Position', [4+padding+buttonWidth 1 buttonWidth 25],...
           'Parent', hactions, ...
           'HandleVisibility','off');
    hdel = uicontrol('Style','togglebutton',...
           'String','-',...
           'Position', [4+2*padding+2*buttonWidth 1 buttonWidth 25],...
           'HandleVisibility','off',...
           'Parent', hactions);
    haddlink = uicontrol('Style','togglebutton',...
           'String','+ link',...
           'Position', [4+3*padding+3*buttonWidth 1 buttonWidth 25],...
           'HandleVisibility','off',...
           'Parent', hactions);
    hdellink = uicontrol('Style','togglebutton',...
           'String','- link',...
           'Position', [4+4*padding+4*buttonWidth 1 buttonWidth 25],...
           'HandleVisibility','off',...
           'Parent', hactions);

    % Add uibuttongroup with togglebutton

    hviewer = axes('Units','Pixels',...
            'Position', [padding 40 figWidth-2*padding 350],...
            'Visible','off'); 
    hslider = uicontrol('Style', 'slider', ...
                        'Min', 1,...
                        'Max', 2,...
                        'SliderStep', [1 1],...
                        'Value', 1,...
                        'Position', [padding,padding,figWidth-2*padding, 25],...
                        'Callback', @hslider_callback,...
                        'Visible','off');
    hfilters = uibuttongroup('Visible','off',...
        'Units', 'Pixels',...
        'Position', [padding 415 figWidth-2*padding 45]);
    
    filterNames = { 'Col' 'Contrast' 'Histeq'...
        'Adaptive Histeq' 'Median Filter' 'M' 'Wiener filter' 'W'...
        'Sharpen' 'S' 'Decorrelation stretch' 'Dec' 'Edge' 'Me' 'Th' 'Average' 'A'...
        'Disk' 'D' 'Laplacian' 'L' 'Log' 'L' 'Prewitt' 'Sobel'...
        'Unsharp'};
    
    hfiltercolor = uicontrol('Style','popupmenu', 'String', '1');
    hfiltercontrast = uicontrol('Style','checkbox');
    hfilterhisteq = uicontrol('Style','checkbox');
    hfilteradapthisteq = uicontrol('Style','checkbox');
    hfiltermedian = uicontrol('Style','checkbox');
    hfilterwiener = uicontrol('Style','checkbox');
    hfilterapplysharpen = uicontrol('Style','checkbox');
    hfilterdecorrstretch = uicontrol('Style','checkbox');
    hfilteredge = uicontrol('Style','checkbox');
    hfilteraverage = uicontrol('Style', 'checkbox');
    hfilterdisk = uicontrol('Style', 'checkbox');
    hfilterlaplacian = uicontrol('Style', 'checkbox');
    hfilterlog = uicontrol('Style', 'checkbox');
    hfilterprewitt = uicontrol('Style', 'checkbox');
    hfiltersobel = uicontrol('Style', 'checkbox');
    hfilterunsharp = uicontrol('Style', 'checkbox');

    hfiltermediansz = uicontrol('Style', 'popupmenu', 'String', '1');
    hfilterapplysharpensz = uicontrol('Style', 'popupmenu', 'String', '1');
    hfilterwienersz = uicontrol('Style', 'popupmenu', 'String', '1');
    hfilterdecorrstretchsz = uicontrol('Style', 'popupmenu', 'String', '1');
    hfilteredgemeth = uicontrol('Style', 'popupmenu', 'String', '1');
    hfilteredgethr = uicontrol('Style', 'popupmenu', 'String', '1');
    hfilteraveragesz = uicontrol('Style', 'popupmenu', 'String', '1');
    hfilterdisksz = uicontrol('Style', 'popupmenu', 'String', '1');
    hfilterlaplaciansz = uicontrol('Style', 'popupmenu', 'String', '1');
    hfilterlogsz = uicontrol('Style', 'popupmenu', 'String', '1');
    
    filters = {hfiltercolor hfiltercontrast hfilterhisteq hfilteradapthisteq ...
        hfiltermedian hfiltermediansz hfilterwiener hfilterwienersz hfilterapplysharpen hfilterapplysharpensz...
        hfilterdecorrstretch hfilterdecorrstretchsz hfilteredge hfilteredgemeth hfilteredgethr hfilteraverage hfilteraveragesz...
        hfilterdisk hfilterdisksz hfilterlaplacian hfilterlaplaciansz hfilterlog hfilterlogsz...
        hfilterprewitt hfiltersobel hfilterunsharp};
    filterStyle = get([hfiltercolor hfiltercontrast hfilterhisteq hfilteradapthisteq ...
        hfiltermedian hfiltermediansz hfilterwiener hfilterwienersz hfilterapplysharpen hfilterapplysharpensz...
        hfilterdecorrstretch hfilterdecorrstretchsz hfilteredge hfilteredgemeth hfilteredgethr hfilteraverage hfilteraveragesz...
        hfilterdisk hfilterdisksz hfilterlaplacian hfilterlaplaciansz hfilterlog hfilterlogsz...
        hfilterprewitt hfiltersobel hfilterunsharp], 'Style');

    filtersPopup = {hfiltercolor hfiltermediansz hfilterapplysharpensz...
      hfilterwienersz hfilterdecorrstretchsz hfilteredgemeth hfilteredgethr...
      hfilteraveragesz hfilterdisksz hfilterlaplaciansz...
      hfilterlogsz};
    
    filterpad = 2;
    filterwidths = cellfun(@(el) length(el) + 5, filterNames);
    filteroffs = cumsum(filterwidths + filterpad);  % If all fit in line
    
    % Determine how many characters fit in hfilters
    charsPerLine = get(hfilters, 'Position');
    charsPerLine = charsPerLine(3) / pix2chars(1);
    
    % Place filter in separate rows, so they don't go overboard
    filterrows = zeros(size(filteroffs));
    for j=1:numel(filteroffs)
        row = floor(mod(charsPerLine, filteroffs(j)) / charsPerLine);
        filterrows(j) = row;
    end
    
    filterhscale = 1.5;
    filterrows = filterrows * filterhscale;
    
    % Recompute the filter offset based on the line
    filteroffs = [];
    for j=unique(filterrows)
        idx = filterrows==j;
        pad = ones(1, sum(idx));
        
        topad = cellfun(@(el) strcmp(el, 'popupmenu'), filterStyle(idx), ...
            'UniformOutput', false);
        pad(cell2mat(topad)) = filterpad;
        ws = cumsum(filterwidths(idx) + pad);
        cs = [0 ws(1:end-1)];
        filteroffs = [filteroffs  cs];
    end
    
    for j=1:numel(filters)
       fi = filters{j};
       set(fi, ...
            'String',filterNames{j},...
            'Units', 'Characters',...
            'Parent',hfilters, ...
            'HandleVisibility','off',...
            'pos', [filteroffs(j) filterhscale-filterrows(j) filterwidths(j) 1], ...
            'Callback', @requestRedraw);
    end

    for j=1:numel(filtersPopup)
       fi = filtersPopup{j};
       pos = get(fi, 'pos');
       set(fi, ...
            'FontSize', 8,...
            'pos', [pos(1) pos(2)+0.3 pos(3) pos(4)]);
    end
    
%     set(0,'HideUndocumented','off'); 
%     inspect(hfilteredgemeth)
    
    set(hfiltercolor, 'String', colormaps);
    set(hfiltermediansz, 'String', '3|5|7|9|11|13|15');
    set(hfilterapplysharpensz, 'String', '0.5|1|1.5|2', 'Value', 2);
    set(hfilterwienersz, 'String', '3|5|7|9|11|13|15');
    set(hfilterdecorrstretchsz, 'String', '0.1|0.2|0.3|0.4');
    set(hfilteredgemeth, 'String', 'sobel|prewitt|roberts|log|canny');
    set(hfilteredgethr, 'String', 'auto|0.03|0.06|0.1|0.3|0.6|0.9');
    set(hfilteraveragesz, 'String', '3|5|7|9|11|13|15');
    set(hfilterdisksz, 'String', '3|5|7|9|11|13|15');
    set(hfilterlaplaciansz, 'String', '0.2|0.4|0.6|0.8|1');
    set(hfilterlogsz, 'String', '3|5|7|9|11|13|15');

    hsliderListener = addlistener(hslider,'Value','PostSet',@hslider_callback);
    set(f, 'KeyReleaseFcn', @keyUpListener);
    % =====================================================================
    % ------------INTITIALIZE THE GUI--------------------------------------
    % =====================================================================
    % Initialize the GUI.
    % Change units to normalized so components resize automatically.
    set([f,hbrowse,hviewer, hslider, hbrowsedet, hfilters, hsave, hactions, hadd, hdel, haddlink, hdellink, hoff],...
        'Units','normalized');

    % Assign the GUI a name to appear in the window title.
    set(f,'Name','Cell Annotator')

    % Move the GUI to the center of the screen.
    movegui(f,'center')

    % Make the GUI visible.
    set(f,'Visible','on');
    % =====================================================================
    % -----------CALLBACKS-------------------------------------------------
    % =====================================================================
    function hbrowse_callback(source, eventdata) %#ok<INUSD>
        
        if testing
        	foldn = '/home/pedro/Dropbox/Imperial/project/data/kidneygreenIN';
        else
            foldn = uigetdir(pwd, 'Select folder with images');
            if foldn == 0
                warning('Select the folder with images')
                if numImages ==0;
                    hideUIElements();
                end
                return
            end
        end

        imgFolderName = foldn;
        updateFolderPaths()
        imgfileNames = dir(fullfile(imgFolderName, strcat(imgPrefix, '*.', imgFormat)));

        numImages = numel(imgfileNames);
        images = cell(numImages, 1);
        usrAnnotations.dots = cell(numImages, 1);
        usrAnnotations.dirty = cell(numImages, 1);
        [usrAnnotations.dirty{:}] = deal(0);  % Initialize to false

        usrMatfileNames = cell(numImages, 1);
        for i=1:numImages
            img = imgfileNames(i);
            base = basename(img.name);
            usrMatfileNames{i} = strcat(base, '.mat');
        end
        usrMatfileNames = struct('name', usrMatfileNames); 

        set(hslider, 'Max', numImages);
        set(hslider, 'SliderStep', [1 5] / (numImages - 1));

        displayImage(curIdx, numImages);        
        displayAnnotations(curIdx, numImages);

        displayUIElements()

        performAction()
    end

    function requestRedraw(source, eventdata) %#ok<INUSD>
        displayImage(curIdx, numImages);        
        displayAnnotations(curIdx, numImages);
    end

    function hbrowsemat_callback(source, eventdata) %#ok<INUSD>
       foldn = uigetdir(imgFolderName, 'Select folder with annotations');
       if foldn == 0
          warning('Select the folder with annotations')
          return
       else
           usrMatFolderName = foldn;
       end
       loadMatFiles();
       updateFolderPaths()
       displayAnnotations(curIdx);
    end

    function hslider_callback(source, eventdata) %#ok<INUSD>
        value = round(get(hslider, 'Value'));
        if value == curIdx; return; end
        
        curIdx = value;
        displayImage(curIdx, numImages);
        displayAnnotations(curIdx, numImages);
    end
    
    function nextImage()
        curIdx = min(curIdx + 1, numImages);
        displayImage(curIdx, numImages);
        displayAnnotations(curIdx, numImages);
    end

    function prevImage()
        curIdx = max(0, curIdx - 1);
        displayImage(curIdx, numImages);
        displayAnnotations(curIdx, numImages);
    end

    function keyUpListener(~, eventdata)
        if strcmp(eventdata.Key, 'space') || strcmp(eventdata.Key, 'rightarrow')
            nextImage();
        elseif strcmp(eventdata.Key, 'leftarrow')
            prevImage();
        elseif strcmp(eventdata.Key, 't')
            disableFilters = ~disableFilters;
            displayImage(curIdx, numImages);
            displayAnnotations(curIdx, numImages);
        end
    end

    function save_callback(~, ~)
        % Overwrite old mat files with new ones
        % Assumes the mat files contain only `dots`.
        
        % Find dirty annotations
        I = find([usrAnnotations.dirty{:}]);
        oldColor = get(hsave, 'Background');
        set(hsave, 'Background', 'y');
        set(hsave, 'String', 'Saving');
        
        for i=1:numel(I)
            % Find corresponding filenames
            dots = usrAnnotations.dots{I(i)};
            filename = fullfile(imgFolderName, usrMatfileNames(I(i)).name);
            % Save the new dots
            save(filename, 'dots');
            fprintf('Saved annotations for image %d to file %s\n', I(i), filename);
        end

        set(hsave, 'Background', 'g');
        set(hsave, 'String', 'Saved');
        pause(2);
        set(hsave, 'Background', oldColor);
        set(hsave, 'String', 'Save');
    end

    function changedAction_callback(~, eventdata)
        switch eventdata.NewValue
            case hadd
                action = ACTION_ADD;
            case hdel
                action = ACTION_DEL;
            case haddlink
                action = ACTION_ADDLINK;
            case hdellink
                action = ACTION_DELLINK;
            otherwise
                action = ACTION_OFF;
        end
    end


    % =====================================================================
    % -----------OTHER FUNCTIONS-------------------------------------------
    % =====================================================================

    function performAction()
        while true
            switch action
                case ACTION_ADD
                    'add'
                case ACTION_DEL
                    'dell'
                case ACTION_ADDLINK
                    'addlink'
                case ACTION_DELLINK
                    'dellink'
                otherwise
                    'off'
            end
            pause(1)
        end
    end

    function updateFolderPaths()
        if ~isempty(imgFolderName)
           set(hbrowse, 'String', ['Images: ' relativepath(imgFolderName) ]);
        else
            set(hbrowse, 'String', 'Choose image folder');
        end
        
        if ~isempty(detMatFolderName)
           set(hbrowsedet, 'String', ['Detections: ' relativepath(detMatFolderName) ]);
        else
            set(hbrowsedet, 'String', 'Choose detections folder');
        end
    end

    function I = getImage(index)
        % Returns the requested image of the sequence
        if isempty(images{index})
            I = imread(fullfile(imgFolderName, imgfileNames(index).name));
            images{index} = I;
        else
            I = images{index};
        end
    end

    function dots = getAnnotations(index)
        % Returns the requested image annotations
        if isempty(usrAnnotations.dots{index})
            filename = fullfile(imgFolderName, usrMatfileNames(index).name);
            if exist(filename, 'file')==2
                data = load(filename);
            else
                data = struct('dots', zeros(0,2));
            end
            
            if isfield(data, 'dots')
                dots = data.dots;
            else
                dots = data.gl;
            end
            usrAnnotations.dots{index} = dots;
        else
            dots = usrAnnotations.dots{index};
        end
    end

    function displayImage(index, numImages)
        % Loads and displays the current image
        if isempty(imgFolderName)
            return
        end
        
        ind = index;
        if ind < 2
            ind = ind + 1; 
        elseif ind >= numImages
            ind = ind - 1;
        end
        
        I0 = getImage(ind-1);
        I1 = getImage(ind);
        I2 = getImage(ind+1);
        gap = zeros(size(I0, 1), imgGap);
        imgWidth = size(I0, 2);
        
        cla(hviewer);
        % assume all images same dimensions
        
        if ~disableFilters
            % Check filters to apply
            applyConstrast = get(hfiltercontrast, 'Value');
            applyMedianFilter = get(hfiltermedian, 'Value');
            applyAdaptiveFilter = get(hfilterwiener, 'Value');
            applyHisteq = get(hfilterhisteq, 'Value');
            applyadapthisteq = get(hfilteradapthisteq, 'Value');  
            applyDecorrstretch = get(hfilterdecorrstretch, 'Value');
            applySharpen = get(hfilterapplysharpen, 'Value');
            applyEdge = get(hfilteredge, 'Value');
            colorMap = get(hfiltercolor, 'Value');
            colorMaps = strsplit(colormaps, '|');
            applyAverage = get(hfilteraverage, 'Value');
            applyDisk = get(hfilterdisk, 'Value');
            applyLaplacian = get(hfilterlaplacian, 'Value');
            applyLog = get(hfilterlog, 'Value');
            applyPrewitt = get(hfilterprewitt, 'Value');
            applySobel = get(hfiltersobel, 'Value');
            applyUnsharp = get(hfilterunsharp, 'Value');
        
        
            % Apply filters
            if applyConstrast; 
                I0 = imadjust(I0);
                I1 = imadjust(I1);
                I2 = imadjust(I2);
            end
            if applyHisteq; 
                I0 = histeq(I0);
                I1 = histeq(I1);
                I2 = histeq(I2);
            end
            if applyMedianFilter;
                v = str2num(getCurrentPopupString(hfiltermediansz));
                sz = [v v];
                I0 = medfilt2(I0,sz);
                I1 = medfilt2(I1,sz);
                I2 = medfilt2(I2,sz);
            end
            if applySharpen;
                v = str2num(getCurrentPopupString(hfilterapplysharpensz));
                I0 = imsharpen(I0, 'Amount', v);
                I1 = imsharpen(I1, 'Amount', v);
                I2 = imsharpen(I2, 'Amount', v);
            end
            if applyAdaptiveFilter;
                v = str2num(getCurrentPopupString(hfilterwienersz));
                sz = [v v];
                I0 = wiener2(I0, sz);
                I1 = wiener2(I1, sz);
                I2 = wiener2(I2, sz);
            end
            if applyadapthisteq; 
                I0 = adapthisteq(I0);
                I1 = adapthisteq(I1);
                I2 = adapthisteq(I2);
            end
            if applyDecorrstretch; 
                v = str2num(getCurrentPopupString(hfilterdecorrstretchsz));
                I0 = decorrstretch(I0,'Tol',v);
                I1 = decorrstretch(I1,'Tol',v);
                I2 = decorrstretch(I2,'Tol',v);
            end
            if applyEdge; 
                method = strtrim(getCurrentPopupString(hfilteredgemeth));
                thr = getCurrentPopupString(hfilteredgethr);
                if thr == 'auto'
                    thr = [];
                else
                    thr = str2double(thr);
                end
                I0 = edge(I0, method, thr);
                I1 = edge(I1, method, thr);
                I2 = edge(I2, method, thr);
            end

            if applyAverage;
                v = str2num(getCurrentPopupString(hfilteraveragesz));
                h = fspecial('average', v);
                I0 = imfilter(I0, h);
                I1 = imfilter(I1, h);
                I2 = imfilter(I2, h);
            end
            if applyDisk;
                v = str2num(getCurrentPopupString(hfilterdisksz));
                h = fspecial('disk', v);
                I0 = imfilter(I0, h);
                I1 = imfilter(I1, h);
                I2 = imfilter(I2, h);
            end
            if applyLaplacian;
                v = str2double(getCurrentPopupString(hfilterlaplaciansz));
                h = fspecial('laplacian', v);
                I0 = imfilter(I0, h);
                I1 = imfilter(I1, h);
                I2 = imfilter(I2, h);
            end
            if applyLog;
                v = str2num(getCurrentPopupString(hfilterlogsz));
                h = fspecial('log', v);
                I0 = imfilter(I0, h);
                I1 = imfilter(I1, h);
                I2 = imfilter(I2, h);
            end
            if applyPrewitt;
                h = fspecial('prewitt');
                I0 = imfilter(I0, h);
                I1 = imfilter(I1, h);
                I2 = imfilter(I2, h);
            end
            if applySobel;
                h = fspecial('sobel');
                I0 = imfilter(I0, h);
                I1 = imfilter(I1, h);
                I2 = imfilter(I2, h);
            end
            if applyUnsharp;
                h = fspecial('unsharp');
                I0 = imfilter(I0, h);
                I1 = imfilter(I1, h);
                I2 = imfilter(I2, h);
            end 
            colormap(colorMaps{colorMap});
        else
            colormap gray;
        end

        I = cat(2, I0, gap, I1,gap, I2);
        
        imagesc(I, 'Parent', hviewer); axis equal; axis tight;
        
        set(hviewer,'XTick',[],'YTIck',[]);
        tit = sprintf('%2d/%d', index, numImages);
        title(tit, 'Parent', hviewer)
        set(hslider, 'Value', index);
    end

    function displayAnnotations(index, numImages)
        % Loads and displays the current annotations
        if isempty(imgFolderName)
            return
        end
        
        ind = index;
        if ind < 2
            ind = ind + 1; 
        elseif ind >= numImages
            ind = ind - 1;
        end
        
        dots0 = getAnnotations(ind-1);
        dots1 = getAnnotations(ind);
        dots2 = getAnnotations(ind+1);
        dots1(:, 1) = dots1(:, 1) + imgWidth + imgGap;
        dots2(:, 1) = dots2(:, 1) + 2*imgWidth + 2*imgGap;
    
        dots = cat(1, dots0, dots1, dots2);
        
        hold(hviewer, 'on');
        plot(dots(:, 1), dots(:, 2), 'r+', 'Parent', hviewer);
    end

    function displayUIElements
        set(hviewer, 'Visible', 'on');
        set(hslider, 'Visible', 'on');
        set(hfilters, 'Visible', 'on');
        set(hsave, 'Visible', 'on');
        set(hsave, 'Enable', 'on');
        set(hactions, 'Visible', 'on');
      
    end

    function hideUIElements
        set(hviewer, 'Visible', 'off');
        set(hslider, 'Visible', 'off');
        set(hfilters, 'Visible', 'off');
        set(hsave, 'Enable', 'off');
        set(hactions, 'Visible', 'off');
    end

    function base = basename(filename)
        [~, base, ~] = fileparts(filename);
    end
end