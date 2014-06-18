function cellAnnotator
    %cellAnnotator GUI tool for cell and cell sequence annotation
    
    set(0,'DefaultFigureCloseRequestFcn',@close_callback)
    
    addpath('relativepath');
    addpath('ginput2');
    % =====================================================================
    % ------------FUNCTION GLOBALS-----------------------------------------
    % =====================================================================
    usrMatfileNames = '';
    detMatfileNames = '';
    imgfileNames = '';
    imgFolderName = '';
    detMatFolderName = '';
    images = cell(1,1); % cache of images
    usrAnnotations = struct('dots', zeros(0, 2), 'links', zeros(0, 1)); % cache of annotation
    detAnnotations = struct('dots', zeros(0, 2), 'links', zeros(0, 1));
    curIdx = 1;
    numImages = 0;

    nDisplays = 3;

    SNAP_PERCENTAGE = 0.10;  % percentage of image width that you can miss
    % an annotation and still select it (for hdel)

    annotationHandles = []; % Holds a list of annotation handlers
    
    imgFormat = 'pgm';
    imgPrefix = 'im';
    imgGap = 25;
    imgWidth = 0;
    
    figWidth = 1025;
    figHeight = 500;
    padding = 10;
    topFigOffset = 0;
    actionsPanelHeight = 130;
    
    colormaps = 'gray|jet|hsv|hot|cool';
    disableFilters = false;
    
    testing = 1;

    ACTION_OFF = 1;
    ACTION_ADD = 2;
    ACTION_DEL = 3;
    ACTION_ADDLINK = 4;
    ACTION_DELLINK = 5;
    ACTION_STOP = 6; % stop the loop

    action = ACTION_OFF;
    
    BG_COLOR = [236, 240, 241] / 255;
    BG_COLOR2 = BG_COLOR / 2;
    FG_COLOR = [44, 62, 80] / 255;

    % =====================================================================
    % ------------SETUP COMPONENTS-----------------------------------------
    % =====================================================================
    %  Create and then hide the GUI as it is being constructed.
    f = figure('Visible','off','Position',[0,0,figWidth,figHeight]);
    
    set(f,'Color', BG_COLOR2);

    % Hide toolbar
    set(f, 'Menu','none', 'Toolbar','none')
    
    % Get the factor to convert pixels to characters
    olduns = get(gcf, 'units');
    set(gcf, 'units', 'pixels');
    size_pixels=get(gcf,'Position');
    set(gcf,'Units','characters');
    size_characters=get(gcf,'Position');
    set(gcf,'Units', olduns);
    pix2chars=size_pixels(3:4)./size_characters(3:4);
    clear olduns;
    
    hpactions = uipanel('Tag', 'Actions',...
        'Units', 'pixels',...
        'Position', [padding figHeight-actionsPanelHeight-padding-topFigOffset figWidth-2*padding actionsPanelHeight],...
        'ShadowColor', BG_COLOR2, ...
        'HighlightColor', BG_COLOR2 ,...
        'Background', BG_COLOR2);

    hpviewer = uipanel('Tag', 'Viewer', ...
        'Visible', 'off', ...
        'Units', 'pixels',...
        'Background', BG_COLOR,...
        'ShadowColor', BG_COLOR, ...
        'HighlightColor', BG_COLOR,...
        'Position', [padding, padding, figWidth-2*padding, figHeight-actionsPanelHeight-padding * 3-topFigOffset]);

    hpactions1 = uipanel('Tag', 'Data',...
        'Units', 'norm',...
        'Position', [0 0.71 1 .29],...
        'parent', hpactions,...
        'ShadowColor', BG_COLOR, ...
        'HighlightColor', BG_COLOR,...
        'Background', BG_COLOR);
    hfilters = uipanel('Tag', 'Filters',...
        'Visible','off',...
        'Units', 'norm',...
        'Position', [0 0.31 1 0.38],...
        'parent', hpactions,...
        'ShadowColor', BG_COLOR, ...
        'HighlightColor', BG_COLOR,...
        'Background', BG_COLOR);
    hpactions3 = uipanel('Tag', 'Actions',...
        'Visible', 'off',...
        'Units', 'norm',...
        'Position', [0 0 1 0.29],...
        'parent', hpactions,...
        'ShadowColor', BG_COLOR, ...
        'HighlightColor', BG_COLOR,...
        'Background', BG_COLOR);

    hcurImg = uicontrol('Style', 'text',...
        'String', '3/30',...
        'Parent', hpactions3,...
        'BackgroundColor', BG_COLOR,...
        'ForegroundColor', FG_COLOR,...
        'HorizontalAlignment', 'right', ...
        'Units', 'norm',...
        'Position', [0.89 0.25 0.1 0.5]);
    % hndisplays = uicontrol('')

    hnumDisps = uicontrol('Style', 'text', ...
        'String', '# displays:',...
        'Parent', hpactions3,...
        'BackgroundColor', BG_COLOR,...
        'ForegroundColor', FG_COLOR,...
        'HorizontalAlignment', 'center', ...
        'Units', 'norm',...
        'Position', [0.58 .25 0.08 0.5]);

    jModel = javax.swing.SpinnerNumberModel(nDisplays,1,10,1);
    jSpinner = com.mathworks.mwswing.MJSpinner(jModel);
    [jhSpinner, jhContainer] = javacomponent(jSpinner, ...
        [0.5 0 0.1 1], ...
        hpactions3);
    set(jhContainer, 'Units','norm',...
        'Position', [0.66 .15 0.05 .7]);
    set(jhSpinner,'StateChangedCallback', @jhspinner_callback)


    hshowDots = uicontrol('Style', 'checkbox', ...
        'String', 'Show cells', ...
        'Units', 'norm',...
        'Parent', hpactions3,...
        'Background', BG_COLOR,...
        'ForegroundColor', FG_COLOR, ...
        'Value', 1, ...
        'Position', [0.4 0 0.09 1],...
        'Callback', {@requestRedraw});
    hshowLinks = uicontrol('Style', 'checkbox', ...
        'String', 'Show links', ...
        'Units', 'norm',...
        'Parent', hpactions3,...
        'Value', 1, ...
        'Background', BG_COLOR,...
        'ForegroundColor', FG_COLOR, ...
        'Position', [0.49 0 0.09 1],...
        'Callback', {@requestRedraw});

    hfiltertoggler = uicontrol('Style', 'checkbox', ...
        'String', 'Apply filters (t)', ...
        'Units', 'norm', ...
        'Parent', hpactions3, ...
        'Value', ~disableFilters, ...
        'Background', BG_COLOR, ...
        'ForegroundColor', FG_COLOR, ...
        'Position', [0.72 0 0.14 1], ...
        'Callback', {@hfiltertoggler_callback});

    hbrowse = uicontrol('Style','pushbutton',...
           'String','Choose image folder',...
           'Units', 'norm',...
           'Position', [0 0 0.5 1],...
           'parent', hpactions1,...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Callback',{@hbrowse_callback});
    hbrowsedet = uicontrol('Style','pushbutton',...
           'String','Choose detections folder',...
           'Units', 'norm',...
           'Position', [0.5 0 0.25 1],...
           'parent', hpactions1,...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Callback', {@hbrowsemat_callback});
    hsave = uicontrol('Style','pushbutton',...
           'String','Save',...
           'Units', 'norm',...
           'Position', [0.75 0 0.25 1],...
           'parent', hpactions1,...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Callback', {@save_callback},...
           'Enable', 'off');

    hactions = uibuttongroup(...
            'Units', 'norm',...
            'parent', hpactions3,...
            'Position', [0 0 0.4 1],...
            'BackgroundColor', BG_COLOR, ...
            'ForegroundColor', FG_COLOR, ...
            'ShadowColor', BG_COLOR, ...
            'HighlightColor', BG_COLOR, ...
            'SelectionChangeFcn', {@changedAction_callback});
    hoff = uicontrol('Style','togglebutton',...
           'String','off (1)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [0 0 0.2 1],...
           'Parent', hactions);
    hadd = uicontrol('Style','togglebutton',...
           'String','+ (2)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [0.2 0 0.2 1],...
           'Parent', hactions);
    hdel = uicontrol('Style','togglebutton',...
           'String','- (3)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [0.4 0 0.2 1],...
           'Parent', hactions);
    haddlink = uicontrol('Style','togglebutton',...
           'String','+ link (4)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [0.6 0 0.2 1],...
           'Parent', hactions);
    hdellink = uicontrol('Style','togglebutton',...
           'String','- link (5)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [0.8 0 0.2 1],...
           'Parent', hactions);

    % Add uibuttongroup with togglebutton

    hviewer = axes('Units','Pixels',...
        'parent', hpviewer,...
        'Units', 'norm',...
        'Position', [0 0.08 1 0.92],...
        'Visible','off'); 
    hslider = uicontrol('Style', 'slider', ...
        'Min', 1,...
        'Max', 2,...
        'SliderStep', [1 1],...
        'Value', 1,...
        'parent', hpviewer,...
        'BackgroundColor', BG_COLOR, ...
        'ForegroundColor', FG_COLOR, ...
        'Units', 'norm',...
        'Position', [0 0 1 0.07],...
        'Callback', @hslider_callback);
    
    filterNames = { 'Col' 'Contrast' 'Histeq'...
        'Adaptive Histeq' 'Median Filter' 'M' 'Wiener filter' 'W'...
        'Sharpen' 'S' 'Decorrelation stretch' 'Dec' 'Edge' 'Me' 'Th' 'Average' 'A'...
        'Disk' 'D' 'Laplacian' 'L' 'Log' 'L' 'Prewitt' 'Sobel'...
        'Unsharp'};
    
    % Filter checkboxes
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

    % Filter parameters
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
    olduns = get(hfilters, 'units');
    set(hfilters, 'units', 'pixels');
    charsPerLine = get(hfilters, 'Position');
    charsPerLine = charsPerLine(3) / pix2chars(1);
    set(hfilters, 'units', olduns);
    clear olduns;
    
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
            'BackgroundColor', BG_COLOR, ...
            'ForegroundColor', FG_COLOR, ...
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
    set(f, 'WindowScrollWheelFcn', @wheel_callback);

    % =====================================================================
    % ------------INTITIALIZE THE GUI--------------------------------------
    % =====================================================================
    % Initialize the GUI.
    % Change units to normalized so components resize automatically.
    % set([f,hbrowse,hviewer, hslider, hbrowsedet, hfilters, hsave, hactions, hadd, hdel, haddlink, hdellink, hoff],...
    %     'Units','normalized');

    set([hpactions, hpviewer], 'Units', 'normalized')

    % Assign the GUI a name to appear in the window title.
    set(f,'Name','Cell Annotator')

    % Move the GUI to the center of the screen.
    movegui(f,'center')

    % Make the GUI visible.
    set(f,'Visible','on');

    % =====================================================================
    % -----------CALLBACKS-------------------------------------------------
    % =====================================================================

    function hfiltertoggler_callback(~, ~)
        disableFilters = ~get(hfiltertoggler, 'Value');
        requestRedraw();
    end

    function jhspinner_callback(~, ~)
        nDisplays = get(jhSpinner, 'Value');
        requestRedraw();
    end

    function discard = discardChangesPrompt()
        discard = true;
        if isfield(usrAnnotations, 'dirty')
            I = getDirtyIndices();
            if sum(I) > 0
                % If there are dirty changes, ask the user to save first
                selection = questdlg('Discard unsaved changes?',...
                    'Discard changes?',...
                    'Yes','No','Yes'); 
                if strcmp(selection, 'No'); discard = false; end
            end
        end
    end

    function close_callback(~,~)
        % User-defined close request function 
        % to display a question dialog box

        % Determine if there are dirty changes
        discard = discardChangesPrompt();

        if ~discard
            return;
        end

        % If still closing, remove the listeners
        try
            delete(hsliderListener);
        end
        action = ACTION_STOP;  % Stops the main loop
        try
            resetDirtiness();  % So I don't get asked again after new window opens
        end
        delete(gcf)
    end

    function hbrowse_callback(source, eventdata) %#ok<INUSD>
        
        discard = discardChangesPrompt();

        if ~discard
            return;
        end


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
        usrAnnotations.links = cell(numImages, 1);
        resetDirtiness()


        usrMatfileNames = cell(numImages, 1);
        for i=1:numImages
            img = imgfileNames(i);
            base = basename(img.name);
            usrMatfileNames{i} = strcat(base, '.mat');
        end
        usrMatfileNames = struct('name', usrMatfileNames); 

        set(hslider, 'Max', numImages);
        set(hslider, 'SliderStep', [1 5] / (numImages - 1));

        requestRedraw();
        displayUIElements();
        performAction();

    end

    function hbrowsemat_callback(source, eventdata) %#ok<INUSD>
        if testing
            foldn = '/home/pedro/Dropbox/Imperial/project/data/kidneygreenOUT'
        else
            foldn = uigetdir(imgFolderName, 'Select folder with annotations');
        end

        if foldn == 0
            warning('Select the folder with annotations')
            return
        else
            detMatFolderName = foldn;
        end

        updateFolderPaths()

        detAnnotations.dots = cell(numImages, 1);
        detAnnotations.dirty = cell(numImages, 1);
        detAnnotations.links = cell(numImages, 1);

        detMatfileNames = cell(numImages, 1);
        for i=1:numImages
            img = imgfileNames(i);
            base = basename(img.name);
            detMatfileNames{i} = strcat(base, '.mat');
        end
        detMatfileNames = struct('name', detMatfileNames);

        % requestRedraw()
    end

    function wheel_callback(~, eventdata)
        switch eventdata.VerticalScrollCount
            case 1
                nextImage();
            case -1
                prevImage();
        end
    end

    function hslider_callback(source, eventdata) %#ok<INUSD>
        value = round(get(hslider, 'Value'));
        if value == curIdx; return; end
        
        curIdx = value;
        displayImage(curIdx, numImages);
        displayAnnotations(curIdx, numImages);
    end

    function save_callback(~, ~)
        % Overwrite old mat files with new ones
        % Assumes the mat files contain only `dots`.
        
        % Find dirty annotations
        I = getDirtyIndices();
        oldColor = get(hsave, 'Background');
        set(hsave, 'Background', 'y');
        set(hsave, 'String', 'Saving');
        
        for i=1:numel(I)
            % Find corresponding filenames
            [dots, links] = getAnnotations(I(i)); %#ok<ASGLU,NASGU>
            filename = fullfile(imgFolderName, usrMatfileNames(I(i)).name);
            % Save the new dots
            save(filename, 'dots', 'links');
            fprintf('Saved annotations for image %d to file %s\n', I(i), filename);
        end

        usrAnnotations.dirty = cell(numImages, 1);
        resetDirtiness();

        set(hsave, 'Background', 'g');
        set(hsave, 'String', 'Saved');
        pause(2);
        if ishandle(hsave)
            set(hsave, 'Background', oldColor);
            set(hsave, 'String', 'Save');
        end
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
    % -----------LISTENERS-------------------------------------------------
    % =====================================================================

    function keyUpListener(~, eventdata)
        switch eventdata.Key
            case {'space' 'rightarrow'}
                nextImage();
            case 'leftarrow'
                prevImage();
            case 't'
                disableFilters = ~disableFilters;
                set(hfiltertoggler, 'Value', ~disableFilters);
                displayImage(curIdx, numImages);
                displayAnnotations(curIdx, numImages);
            case {'1' 'escape' }
                action = ACTION_OFF;
                set(hactions, 'SelectedObject', hoff);
            case '2'
                action = ACTION_ADD;
                set(hactions, 'SelectedObject', hadd);
            case '3'
                action = ACTION_DEL;
                set(hactions, 'SelectedObject', hdel);
            case '4'
                action = ACTION_ADDLINK;
                set(hactions, 'SelectedObject', haddlink);
            case '5'
                action = ACTION_DELLINK;
                set(hactions, 'SelectedObject', hdellink);
        end
    end

    % =====================================================================
    % -----------OTHER FUNCTIONS-------------------------------------------
    % =====================================================================

    function nextImage()
        curIdx = min(curIdx + 1, numImages);
        displayImage(curIdx, numImages);
        displayAnnotations(curIdx, numImages);
    end

    function prevImage()
        curIdx = max(1, curIdx - 1);
        displayImage(curIdx, numImages);
        displayAnnotations(curIdx, numImages);
    end

    function requestRedraw(source, eventdata) %#ok<INUSD>
        displayImage(curIdx, numImages);        
        displayAnnotations(curIdx, numImages);
    end

    function performAction()
        while true
            switch action
                case ACTION_ADD
                    performActionAdd()
                case ACTION_DEL
                    performActionDell()
                case ACTION_ADDLINK
                    performActionAddlink()
                case ACTION_DELLINK
                    performActionDellink()
                case ACTION_OFF
                    % 'Do nothings'
                case ACTION_STOP
                    break
            end
            pause(0.1)
        end
    end

    function performActionAdd()
        [P, clickedImg] = doClick(numImages, imgWidth, imgGap, nDisplays);

        % clickeImd == [] when I switch the tool

        if ~isempty(P) && ~isempty(clickedImg)
            [dots, links] = getAnnotations(clickedImg);
            setAnnotations(clickedImg, [dots; P], [links; 0]);
            displayAnnotations(curIdx, numImages);
        end
    end

    function performActionDell()
        SNAP_DISTANCE = SNAP_PERCENTAGE * imgWidth;

        [P, clickedImg] = doClick(numImages, imgWidth, imgGap, nDisplays);

        if ~isempty(P) && ~isempty(clickedImg)
            [dots, links] = getAnnotations(clickedImg);
            D = pdist2(double(dots), double(P));
            [D, I] = min(D, [], 1);
            if D < SNAP_DISTANCE
                fprintf('Deleted point %d %d from image %d.\n', dots(I, :), clickedImg );

                dots(I, :) = [];

                if clickedImg > 1
                    % Check if there is a link on the left side
                    % If there is, also delete it
                    [dots0, links0] = getAnnotations(clickedImg-1);
                    links0(links0 == I) = 0;

                    % I also need to correct the points of the other annotations
                    J = find(links0 > I);
                    links0(J) = links0(J) - 1;

                    setAnnotations(clickedImg - 1, dots0, links0);
                end

                links(I) = [];

                setAnnotations(clickedImg, dots, links);

                displayImage(curIdx, numImages);
                displayAnnotations(curIdx, numImages);
            end
        end
    end

    function performActionAddlink()
        SNAP_DISTANCE = SNAP_PERCENTAGE * imgWidth;
        [P, clickedImgs] = doClick(numImages, imgWidth, imgGap, nDisplays, 'N', 2);
        
        if ~isempty(P) && ~isempty(clickedImgs) && numel(clickedImgs) == 2
            % Compute minimum distances to points
            % store the connection in the lefty image
            [dots1, links1] = getAnnotations(clickedImgs(1));
            [dots2, ~] = getAnnotations(clickedImgs(2));

            D1 = pdist2(double(dots1), double(P(1, :)));
            D2 = pdist2(double(dots2), double(P(2, :)));

            [D1, I1] = min(D1, [], 1);
            [D2, I2] = min(D2, [], 1);

            if all([D1 D2] < SNAP_DISTANCE)

                fprintf('Added links from %d %d (image %d) to %d %d (image %d).\n', dots1(I1,:), clickedImgs(1), dots2(I2, :), clickedImgs(2));

                links1(I1) = I2;

                setAnnotations(clickedImgs(1), dots1, links1);
                displayAnnotations(curIdx, numImages);
            end
        end
    end

    function performActionDellink()
        SNAP_DISTANCE = SNAP_PERCENTAGE * imgWidth;
        [P, clickedImg, relClickedImg] = doClick(numImages, imgWidth, imgGap, nDisplays);

        if ~isempty(P) && ~isempty(clickedImg)

            dists = [];

            thereIsPrevImage = relClickedImg > -floor(nDisplays/2);
            thereIsNextImage = relClickedImg < floor(nDisplays/2);

            if thereIsPrevImage
                [dots0, links0] = getAnnotations(clickedImg-1);
                dots0(:, 1) = dots0(:, 1) - (imgWidth + imgGap);
                [dots1, ~] = getAnnotations(clickedImg);
                I = find(links0 ~= 0);
                dsts = distancePointEdge(P, ...
                    double([dots0(I, :), dots1(links0(I), :)]));
                dists = [dists dsts];
                nPrev = numel(I);
            else
                nPrev = 0;
            end
                
            if thereIsNextImage
                [dots0, links0] = getAnnotations(clickedImg);
                [dots1, ~] = getAnnotations(clickedImg+1);
                dots1(:, 1) = dots1(:, 1) + (imgWidth + imgGap);
                I = find(links0 ~= 0);
                dsts = distancePointEdge(P, ...
                    double([dots0(I, :), dots1(links0(I), :)]));
                dists = [dists dsts];
            end

            [D, I] = min(dists);

            if D <= SNAP_DISTANCE
                if I <= nPrev     % Link to left image
                    [dots0, links0] = getAnnotations(clickedImg-1);
                    Iorig = find(links0 ~= 0);
                    links0(Iorig(I)) = 0;
                    setAnnotations(clickedImg-1, dots0, links0);
                    fprintf('Removed link between images %d and %d.\n', ...
                        clickedImg-1, clickedImg);
                else              % Link to right image
                    [dots0, links0] = getAnnotations(clickedImg);
                    Iorig = find(links0 ~= 0);
                    links0(Iorig(I-nPrev)) = 0;
                    setAnnotations(clickedImg, dots0, links0);
                    fprintf('Removed link between images %d and %d.\n', ...
                        clickedImg, clickedImg+1);
                end
                displayAnnotations(curIdx, numImages);
            end
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

    function resetDirtiness()
        [usrAnnotations.dirty{:}] = deal(0);
    end

    function I = getDirtyIndices()
        I = find([usrAnnotations.dirty{:}]==1);
    end

    function setAnnotations(index, dots, links)
        usrAnnotations.dots{index} = dots;
        usrAnnotations.links{index} = links;
        usrAnnotations.dirty{index} = 1;
    end

    function [dots, links] = getAnnotations(index)
        % Returns the requested image annotations

        % Only reload from disk if not dirty. I may be empty otherwise if we
        % had delete all the annotations

        noDots = isempty(usrAnnotations.dots{index}) && ~usrAnnotations.dirty{index};
        noLinks = isempty(usrAnnotations.links{index}) && ~usrAnnotations.dirty{index};
        if noDots || noLinks
            filename = fullfile(imgFolderName, usrMatfileNames(index).name);
            if exist(filename, 'file')==2
                data = load(filename);
            end
            
            if isfield(data, 'dots')
                dots = data.dots;
            elseif isfield(data, 'gl')
                dots = data.gl;
            else
                dots = zeros(0, 2);
                usrAnnotations.dirty{index} = 1;
            end

            if isfield(data, 'links')
                links = data.links;

                % TODO: check that the links format is OK
            else
                numDots = size(dots, 1);
                links = zeros(numDots, 1);
                usrAnnotations.dirty{index} = 1;
            end

            usrAnnotations.dots{index} = dots;
            usrAnnotations.links{index} = links;
            fprintf('Loaded annotations for image %d from disk\n', index);
        else
            dots = usrAnnotations.dots{index};
            links = usrAnnotations.links{index};
        end
    end



    function displayImage(index, numImages)
        % Loads and displays the current image
        if isempty(imgFolderName)
            return
        end
        


        ind = private_correctIndex(index, numImages, nDisplays);
        
        Is = cell(nDisplays, 1);
            
        tmp_i = 1;
        for i=-ceil(nDisplays/2)+1:1:floor(nDisplays/2)
            Is{tmp_i} = getImage(ind + i); 
            tmp_i = tmp_i + 1;
        end

        gap = zeros(size(Is{1}, 1), imgGap);
        imgWidth = size(Is{1}, 2);
        
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
                for i=1:nDisplays
                    Is{i} = imadjust(Is{i});
                end
            end
            if applyHisteq;
                for i=1:nDisplays
                    Is{i} = histeq(Is{i});
                end
            end
            if applyMedianFilter;
                v = str2num(getCurrentPopupString(hfiltermediansz));
                sz = [v v];

                for i=1:nDisplays
                    Is{i} = medfilt2(Is{i}, sz);
                end
            end
            if applySharpen;
                v = str2num(getCurrentPopupString(hfilterapplysharpensz));
                for i=1:nDisplays
                    Is{i} = imsharpen(Is{i}, 'Amount', v);
                end
            end
            if applyAdaptiveFilter;
                v = str2num(getCurrentPopupString(hfilterwienersz));
                sz = [v v];
                for i=1:nDisplays
                    Is{i} = wiener2(Is{i}, sz);
                end
            end
            if applyadapthisteq; 
                for i=1:nDisplays
                    Is{i} = adapthisteq(Is{i});
                end
            end
            if applyDecorrstretch; 
                v = str2num(getCurrentPopupString(hfilterdecorrstretchsz));
                for i=1:nDisplays
                    Is{i} = decorrstretch(Is{i}, 'Tol',v);
                end
            end
            if applyEdge; 
                method = strtrim(getCurrentPopupString(hfilteredgemeth));
                thr = getCurrentPopupString(hfilteredgethr);
                if thr == 'auto'
                    thr = [];
                else
                    thr = str2double(thr);
                end
                for i=1:nDisplays
                    Is{i} = edge(Is{i}, method, thr);
                end
            end

            if applyAverage;
                v = str2num(getCurrentPopupString(hfilteraveragesz));
                h = fspecial('average', v);
                for i=1:nDisplays
                    Is{i} = imfilter(Is{i}, h);
                end
            end
            if applyDisk;
                v = str2num(getCurrentPopupString(hfilterdisksz));
                h = fspecial('disk', v);
                for i=1:nDisplays
                    Is{i} = imfilter(Is{i}, h);
                end
            end
            if applyLaplacian;
                v = str2double(getCurrentPopupString(hfilterlaplaciansz));
                h = fspecial('laplacian', v);

                for i=1:nDisplays
                    Is{i} = imfilter(Is{i}, h);
                end
            end
            if applyLog;
                v = str2num(getCurrentPopupString(hfilterlogsz));
                h = fspecial('log', v);
                for i=1:nDisplays
                    Is{i} = imfilter(Is{i}, h);
                end
            end
            if applyPrewitt;
                h = fspecial('prewitt');
                for i=1:nDisplays
                    Is{i} = imfilter(Is{i}, h);
                end
            end
            if applySobel;
                h = fspecial('sobel');
                for i=1:nDisplays
                    Is{i} = imfilter(Is{i}, h);
                end
            end
            if applyUnsharp;
                h = fspecial('unsharp');
                for i=1:nDisplays
                    Is{i} = imfilter(Is{i}, h);
                end
            end 
            colormap(colorMaps{colorMap});
        else
            colormap gray;
        end

        I = [];
        for i=1:nDisplays
            if i == nDisplays
                I = horzcat(I, Is{i});
            else
                I = horzcat(I, Is{i}, gap);
            end
        end
        
        imagesc(I, 'Parent', hviewer); axis equal; axis tight;
        
        set(hviewer,'XTick',[],'YTIck',[], 'xcolor', BG_COLOR,'ycolor',BG_COLOR);
        tit = sprintf('%2d/%d', index, numImages);
        set(hcurImg, 'String', tit);
        % title(tit, 'Parent', hviewer)
        set(hslider, 'Value', index);
    end

    function displayAnnotations(index, numImages)
        % Loads and displays the current annotations
        if isempty(imgFolderName)
            return
        end
        
        % clear any previous annotation
        if any(ishandle(annotationHandles))
            annotationHandles = annotationHandles(ishandle(annotationHandles));
            
            for i=1:numel(annotationHandles)
                delete(annotationHandles(i));
            end
            annotationHandles = [];
        end

        % Then draw new ones
        % This is for the fact that the first image and last images don't
        % result in the viewer change.
        ind = private_correctIndex(index, numImages, nDisplays);

        hold(hviewer, 'on');
        
        dotsCell = cell(nDisplays, 1);
        linksCell = cell(nDisplays, 1);
        
        dots = [];
        tmp_i = 1;
        for i=-ceil(nDisplays/2)+1:1:floor(nDisplays/2)
            [d, l] = getAnnotations(ind+i);
            d(:, 1) = d(:, 1) + (tmp_i-1)*(imgWidth + imgGap);
            dotsCell{tmp_i} = d;
            linksCell{tmp_i} = l;
            tmp_i = tmp_i + 1;
            dots = vertcat(dots, d);
        end



        if get(hshowDots, 'Value')
            h = plot(dots(:, 1), dots(:, 2), 'r+', 'Parent', hviewer);
            annotationHandles = [annotationHandles; h];
        end

        hold(hviewer, 'on');
       
        if get(hshowLinks, 'Value')
            % Plot links
            % Select nonzeros
            tmp_i = 1;
            for i=-ceil(nDisplays/2)+1:1:floor(nDisplays/2)-1
                links = linksCell{tmp_i};
                dots0 = dotsCell{tmp_i};
                dots1 = dotsCell{tmp_i+1};
                I = find(links ~= 0);
                c0 = dots0(I, :);
                c1 = dots1(links(I), :);

                for l=1:numel(I)
                    X = [c0(l, 1) c1(l, 1)];
                    Y = [c0(l, 2) c1(l, 2)];
                    h = line(X, Y, 'Parent', hviewer, 'Color', [1 1 1], 'LineStyle', '--');
                    annotationHandles = [annotationHandles; h]; %#ok<AGROW>
                end

                tmp_i = tmp_i + 1;
            end
        end
    end

    function displayUIElements
        set(hpviewer, 'Visible', 'on');
        set(hpactions, 'Visible', 'on');
        set(hpactions1, 'Visible', 'on');
        set(hpactions3, 'Visible', 'on');
        set(hfilters, 'Visible', 'on');
        set(hsave, 'Enable', 'on');

        set(hpactions, 'ShadowColor', BG_COLOR)
        set(hpactions, 'HighlightColor', BG_COLOR)
        set(hpactions, 'Background', BG_COLOR)
    end

    function hideUIElements
        set(hpviewer, 'Visible', 'off');
        set(hpactions, 'Visible', 'off');
        set(hpactions1, 'Visible', 'off');
        set(hpactions3, 'Visible', 'off');
        set(hfilters, 'Visible', 'off');
        set(hsave, 'Enable', 'off');
    end
end