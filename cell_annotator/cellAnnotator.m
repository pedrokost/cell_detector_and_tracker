function cellAnnotator
    %cellAnnotator GUI tool for cell and cell sequence annotation
    
    set(0,'DefaultFigureCloseRequestFcn',@close_callback)
    
    if exist('relativepath') == 7
        addpath('relativepath');
    end
    if exist('ginput2') == 7
        addpath('ginput2');
    end
    if exist('patchline') == 7
        addpath('patchline');
    end
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
    imgHeight = 0;

    LINK_MASK_POS = 300;
    LINK_MASK_WIDTH = 150;
    
    figWidth = 1025;
    figHeight = 500;
    padding = 5;
    topFigOffset = 0;
    actionsPanelHeight = 130;
    fullsize = false;
    oldpos = [0 0 1 1]; 
    
    colormaps = 'gray|jet|hsv|hot|cool';
    disableFilters = false;
    
    testing = true;
    displayAnnomalies = true; % Mark annotations that might be erroneous
    ERRONEOUS_DISTANCE = 0.03; % Cells less than this far apart are erronous

    ACTION_OFF = 1;
    ACTION_ADD = 2;
    ACTION_DEL = 3;
    ACTION_ADDLINK = 4;
    ACTION_ADDLINKFAST = 7;
    ACTION_DELLINK = 5;
    ACTION_STOP = 6; % stop the loop

    action = ACTION_OFF;
    
    BG_COLOR = [236, 240, 241] / 255;
    BG_COLOR2 = BG_COLOR / 2;
    FG_COLOR = [44, 62, 80] / 255;
    DIRTY_COLOR = [243,156,18]/255;

    % =====================================================================
    % ------------SETUP COMPONENTS-----------------------------------------
    % =====================================================================
    %  Create and then hide the GUI as it is being constructed.
    f = figure('Visible','off','Position',[0,0,figWidth,figHeight],...
        'Renderer', 'OpenGL');
    
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
        'Parent', f, ...
        'ShadowColor', BG_COLOR2, ...
        'HighlightColor', BG_COLOR2 ,...
        'Background', BG_COLOR2);

    hpviewer = uipanel('Tag', 'Viewer', ...
        'Visible', 'off', ...
        'Units', 'pixels',...
        'Parent', f, ...
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

    hshowDetections = uicontrol('Style', 'checkbox', ...
        'String', 'Show detections', ...
        'Enable', 'off', ...
        'Units', 'norm',...
        'Parent', hpactions3,...
        'Value', 0, ...
        'Background', BG_COLOR,...
        'ForegroundColor', FG_COLOR, ...
        'Position', [0.58 0 0.13 1],...
        'Callback', {@requestRedraw});

    hfiltertoggler = uicontrol('Style', 'checkbox', ...
        'String', 'Apply filters (t)', ...
        'Units', 'norm', ...
        'Parent', hpactions3, ...
        'Value', ~disableFilters, ...
        'Background', BG_COLOR, ...
        'ForegroundColor', FG_COLOR, ...
        'Position', [0.71 0 0.14 1], ...
        'Callback', {@hfiltertoggler_callback});

    hnumDisps = uicontrol('Style', 'text', ...
        'String', 'Displays:',...
        'Parent', hpactions3,...
        'BackgroundColor', BG_COLOR,...
        'ForegroundColor', FG_COLOR,...
        'HorizontalAlignment', 'left', ...
        'Units', 'norm',...
        'Position', [0.83 .25 0.06 0.5]);

    jModel = javax.swing.SpinnerNumberModel(nDisplays,1,10,1);
    jSpinner = com.mathworks.mwswing.MJSpinner(jModel);
    [jhSpinner, jhContainer] = javacomponent(jSpinner, ...
        [0.5 0 0.1 1], ...
        hpactions3);
    set(jhContainer, 'Units','norm',...
        'Position', [0.89 .15 0.05 .7]);
    set(jhSpinner,'StateChangedCallback', @jhspinner_callback)



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

    actWidth = 1/6;
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
           'Position', [actWidth*0 0 actWidth 1],...
           'Parent', hactions);
    hadd = uicontrol('Style','togglebutton',...
           'String','+ (2)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [actWidth 0 actWidth 1],...
           'Parent', hactions);
    hdel = uicontrol('Style','togglebutton',...
           'String','- (3)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [actWidth*2 0 actWidth 1],...
           'Parent', hactions);
    haddlink = uicontrol('Style','togglebutton',...
           'String','-- (4)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [actWidth*3 0 actWidth 1],...
           'Parent', hactions);
    haddlinkfast = uicontrol('Style','togglebutton',...
           'String','--- (5)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [actWidth*4 0 actWidth 1],...
           'Parent', hactions);
    hdellink = uicontrol('Style','togglebutton',...
           'String','-x- (6)',...
           'Units', 'norm',...
           'BackgroundColor', BG_COLOR, ...
           'ForegroundColor', FG_COLOR, ...
           'Position', [actWidth*5 0 actWidth 1],...
           'Parent', hactions);

    % Add uibuttongroup with togglebutton

    hviewer = axes('Units','Pixels',...
        'parent', hpviewer,...
        'Units', 'norm',...
        'Position', [0 0.08 1 0.89],...
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
    hmaskslider = uicontrol('Style', 'slider', ...
        'Min', 0,...
        'Max', 500,...
        'SliderStep', [0.5 1]/10,...
        'Value', LINK_MASK_POS,...
        'parent', hpviewer,...
        'BackgroundColor', BG_COLOR, ...
        'ForegroundColor', FG_COLOR, ...
        'Units', 'norm',...
        'Position', [0 0.97 0.2 0.03]);
    hmaskcheck = uicontrol('Style', 'checkbox', ...
        'Value', 0,...
        'Parent', hpviewer, ...
        'Units', 'norm', ...
        'BackgroundColor', BG_COLOR, ...
        'ForegroundColor', FG_COLOR, ...
        'Position', [0.21 0.97 0.03 0.03],...
        'Callback', {@requestRedraw});
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
    hmasksliderListener = addlistener(hmaskslider,'Value','PostSet',@hmaskslider_callback);
    set(f, 'WindowScrollWheelFcn', @wheel_callback);
    set(f, 'WindowKeyReleaseFcn', @keyUpListener);

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
        nDisplays = min(get(jhSpinner, 'Value'), numImages);
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
            delete(hmasksliderListener);
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
        	foldn = '/home/pedro/Dropbox/Imperial/project/data/series30green';
        else
            if ~isempty(imgFolderName) dr = imgFolderName; else; dr = pwd; end;
            foldn = uigetdir(dr, 'Select folder with images');
            if foldn == 0
                warning('Select the folder with images')
                if numImages ==0;
                    hideUIElements();
                end
                return
            end
        end

        if ~strcmp(foldn, imgFolderName)
            curIdx = 1;  % rest the index, but only if we are not just refreshing the same dataset
        end

        imgFolderName = foldn;
        updateFolderPaths()
        imgfileNames = dir(fullfile(imgFolderName, strcat(imgPrefix, '*.', imgFormat)));

        numImages = numel(imgfileNames);
        nDisplays = min(nDisplays, numImages);
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

        I = getImage(1);
        imgWidth = size(I, 2);
        imgHeight = size(I, 1);

        set(hmaskslider, 'Max', imgWidth);
        
        LINK_MASK_POS = min(LINK_MASK_POS, imgWidth);

        requestRedraw();
        displayUIElements();
        performAction();

    end

    function hbrowsemat_callback(source, eventdata) %#ok<INUSD>
        if testing
            foldn = '/home/pedro/Dropbox/Imperial/project/data/kidneyredOUT';
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
        [detAnnotations.dirty{:}] = deal(0);
        detAnnotations.links = cell(numImages, 1);

        detMatfileNames = cell(numImages, 1);
        for i=1:numImages
            img = imgfileNames(i);
            base = basename(img.name);
            detMatfileNames{i} = strcat(base, '.mat');
        end
        detMatfileNames = struct('name', detMatfileNames);


        set(hshowDetections, 'Value', 1, ...
            'Enable', 'on');

        displayAnnotations(curIdx, numImages);
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

    function hmaskslider_callback(~, eventdata)
        value = round(get(hmaskslider, 'Value'));
        LINK_MASK_POS = value;
        displayAnnotations(curIdx, numImages);
    end

    function hslider_callback(~, ~)
        value = round(get(hslider, 'Value'));
        if value == curIdx; return; end
        
        curIdx = value;
        displayImage(curIdx, numImages);
        displayAnnotations(curIdx, numImages);
    end

    function save_callback(~, ~)
        % Overwrite old mat files with new ones
        % Assumes the mat files contain only `dots`.
        saveAnnotations();
    end

    function saveAnnotations()
        % Find dirty annotations
        I = getDirtyIndices();

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
            set(hsave, 'Background', BG_COLOR);
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
            case haddlinkfast
                action = ACTION_ADDLINKFAST;
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
        keycode = double(get(f, 'CurrentCharacter'));

        if(isempty(keycode)); return; end

        switch keycode
            case {32 29} % {'space' 'rightarrow'}
                nextImage();
            case 28 % 'leftarrow'
                prevImage();
            case 116 % 't'
                disableFilters = ~disableFilters;
                set(hfiltertoggler, 'Value', ~disableFilters);
                displayImage(curIdx, numImages);
                displayAnnotations(curIdx, numImages);
            case {49 27}  % {'1' 'escape' }
                action = ACTION_OFF;
                set(hactions, 'SelectedObject', hoff);
            case 50 %'2'
                action = ACTION_ADD;
                set(hactions, 'SelectedObject', hadd);
            case 51 % '3'
                action = ACTION_DEL;
                set(hactions, 'SelectedObject', hdel);
            case 52 % '4'
                action = ACTION_ADDLINK;
                set(hactions, 'SelectedObject', haddlink);
            case 53 % '5'
                action = ACTION_ADDLINKFAST;
                set(hactions, 'SelectedObject', haddlinkfast);
            case 54 % '6'
                action = ACTION_DELLINK;
                set(hactions, 'SelectedObject', hdellink);
            case 19 % ctrl + s
                saveAnnotations();
            case 102  % 'f'
                toggleFullScreen()

        end
    end

    % =====================================================================
    % -----------OTHER FUNCTIONS-------------------------------------------
    % =====================================================================

    function toggleFullScreen()
        fullsize = ~fullsize;

        oldunits = get(hpviewer, 'Units');
        set(hpviewer, 'Units', 'norm')
        pos = get(hpviewer, 'Position');

        if fullsize
            oldpos = pos;
            set(hpactions, 'Visible', 'off');
            set(hpviewer, 'Position', [0, 0, 1 1]);

        else
            set(hpviewer, 'Position', oldpos);
            set(hpactions, 'Visible', 'on');
        end
        set(hpviewer, 'Units', oldunits)
    end

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
            checkForSave()
            switch action
                case ACTION_ADD
                    performActionAdd()
                case ACTION_DEL
                    performActionDell()
                case ACTION_ADDLINK
                    performActionAddlink()
                case ACTION_ADDLINKFAST
                    performActionAddlink(10)
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

    function checkForSave()
        if numel(getDirtyIndices()) > 0
            color = DIRTY_COLOR;        
        else
            color = BG_COLOR;
        end
        
        if ishandle(hsave)
            set(hsave, 'BackgroundColor', color);
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

    function performActionAddlink(points)
        % Similar to addLink but allows for many consecutive click and then
        % creates all the required connection
        if nargin < 1; points = 2; end;
        
        SNAP_DISTANCE = SNAP_PERCENTAGE * imgWidth;
        fprintf('Press Enter to stop selecting points\n')
        [P, clickedImgs] = doClick(numImages, imgWidth, imgGap, nDisplays, 'N', points);
        
        if ~isempty(P) && ~isempty(clickedImgs) && numel(clickedImgs) >= 2

            % For each point, find its closest dot
            for i=1:numel(clickedImgs)-1
                [dots1, links1] = getAnnotations(clickedImgs(i));
                [dots2, ~] = getAnnotations(clickedImgs(i+1));

                D1 = pdist2(double(dots1), double(P(1, :)));
                D2 = pdist2(double(dots2), double(P(2, :)));
    
                [D1, I1] = min(D1, [], 1);
                [D2, I2] = min(D2, [], 1);

                if all([D1 D2] < SNAP_DISTANCE)

                    fprintf('Added links from %d %d (image %d) to %d %d (image %d).\n', dots1(I1,:), clickedImgs(i), dots2(I2, :), clickedImgs(i+1));

                    links1(I1) = I2;

                    setAnnotations(clickedImgs(i), dots1, links1);
                end
            end
            displayAnnotations(curIdx, numImages);
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

    function [dots, links] = getAnnotations(index, annotationType)
        % Returns the requested image annotations

        % Only reload from disk if not dirty. I may be empty otherwise if we
        % had delete all the annotations
        if nargin < 2
            annotationType = 'usr';
        end
        switch annotationType
            case 'usr'
                [dots, links] = private_getAnnotationsUsr(index);
            case 'det'
                [dots, links] = private_getAnnotationsDet(index);
            otherwise
                error('Wrong option %s', annotationType);
        end
        
    end


    function [dots, links] = private_getAnnotationsUsr(index)
        noDots = isempty(usrAnnotations.dots{index}) && ~(usrAnnotations.dirty{index});
        noLinks = isempty(usrAnnotations.links{index}) && ~(usrAnnotations.dirty{index});

        if noDots || noLinks
            filename = fullfile(imgFolderName, usrMatfileNames(index).name);
            if exist(filename, 'file')==2
                data = load(filename);
            else
                data = struct;
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

    function [dots, links] = private_getAnnotationsDet(index)
        noDots = isempty(detAnnotations.dots{index}) && ~(detAnnotations.dirty{index});
        noLinks = isempty(detAnnotations.links{index}) && ~(detAnnotations.dirty{index});

        if noDots || noLinks
            filename = fullfile(detMatFolderName, detMatfileNames(index).name);
            if exist(filename, 'file')==2
                data = load(filename);
            else
                data = struct;
            end
            
            if isfield(data, 'dots')
                dots = data.dots;
            elseif isfield(data, 'gl')
                dots = data.gl;
            else
                dots = zeros(0, 2);
                detAnnotations.dirty{index} = 1;
            end

            if isfield(data, 'links')
                links = data.links;
                % TODO: check that the links format is OK
            else
                numDots = size(dots, 1);
                links = zeros(numDots, 1);
                detAnnotations.dirty{index} = 1;
            end

            detAnnotations.dots{index} = dots;
            detAnnotations.links{index} = links;
            fprintf('Loaded detections for image %d from disk\n', index);
        else
            dots = detAnnotations.dots{index};
            links = detAnnotations.links{index};
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

        
        private_displayAnnotations(ind, numImages, 'usr');

        if ~isempty(detMatFolderName) && get(hshowDetections, 'Value')
            private_displayAnnotations(ind, numImages, 'det');
        end

    end

    function within = withinDisplayBoundaries(dots)
        % for each dot return t/f if it lies within the region marked by the
        % LINK_MARK_POS marker

        within = ones(size(dots, 1), 1);

        out = dots(:, 1) < LINK_MASK_POS - LINK_MASK_WIDTH / 2;
        out = out | dots(:, 1) > LINK_MASK_POS + LINK_MASK_WIDTH / 2;

        within(out) = 0;
        within = logical(within);
    end

    function private_displayAnnotations(ind, numImages, annotationType)
        hold(hviewer, 'on');
        
        dotsCell = cell(nDisplays, 1);
        dotsOrigCell = cell(nDisplays, 1);
        linksCell = cell(nDisplays, 1);


        if get(hmaskcheck, 'Value')
            x = zeros(4, nDisplays*2);
            for i=1:nDisplays
                offset = (i - 1) * (imgWidth + imgGap);

                left = max(0, LINK_MASK_POS + offset - LINK_MASK_WIDTH / 2);
                right = min(offset +imgWidth, LINK_MASK_POS + offset + LINK_MASK_WIDTH / 2);
                fullRight = offset + imgWidth + 1;

                x(:, i) = [offset offset left left];
                x(:, i+nDisplays) = [right right fullRight fullRight];
            end

            y = repmat([0; imgHeight; imgHeight; 0], 1, nDisplays * 2);
            h = fill(x, y, 'black', 'FaceAlpha', 0.8, 'EdgeColor', 'none');
            annotationHandles = [annotationHandles; h];
        end
        
        switch annotationType
            case 'usr'
                styleDots = '+';
                col = [200 0 0] / 255;
                hiddenCol = [50 50 50] / 255;
                colorLinks = [1 1 1];
                hiddenColorLinks = colorLinks / 3;
                lineStyle = '--';
            case 'det'
                styleDots = 'yo';
                col = [200 0 0] / 255;
                hiddenCol = col / 3;
                colorLinks = [0.3 0.3 1];
                hiddenColorLinks = colorLinks / 3;
                lineStyle = '-.';
        end


        dots = [];
        tmp_i = 1;
        orig_dots = [];
        for i=-ceil(nDisplays/2)+1:1:floor(nDisplays/2)
            [d, l] = getAnnotations(ind+i, annotationType);
            orig_dots = vertcat(orig_dots, d);
            dotsOrigCell{tmp_i} = d;
            d(:, 1) = d(:, 1) + (tmp_i-1)*(imgWidth + imgGap);
            dotsCell{tmp_i} = d;
            linksCell{tmp_i} = l;
            tmp_i = tmp_i + 1;
            dots = vertcat(dots, d);
        end
        within = withinDisplayBoundaries(orig_dots);
     
        if strcmp(annotationType, 'usr') && displayAnnomalies
            ERR_DST = ERRONEOUS_DISTANCE * imgWidth;
            D = pdist(double(dots));
            M = squareform(D);
            bad = (M < ERR_DST) - eye(size(dots, 1));
            [I, J] = find(bad);
            ds = double(unique(dots(I, :), 'rows'));
            MARKER_RADIUS = 15;
            plot(ds(:, 1), ds(:, 2), 'y^', 'MarkerSize', MARKER_RADIUS*2)
            text(ds(:, 1)-MARKER_RADIUS, ds(:, 2)-MARKER_RADIUS, '!', 'Color', 'y', 'FontSize', 16);
        end

        if get(hshowDots, 'Value')
            colors = bsxfun(@times, ones(size(orig_dots, 1), 3), col);
            if get(hmaskcheck, 'Value')
                colors(~within, :) = repmat(hiddenCol, sum(~within), 1);
            end
            h = scatter(dots(:, 1), dots(:, 2), figWidth/20, colors, styleDots, 'Parent', hviewer,'LineWidth', 2);
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
                dots0orig = dotsOrigCell{tmp_i};
                dots1 = dotsCell{tmp_i+1};
                I = find(links ~= 0);
                c0 = dots0(I, :);
                c1 = dots1(links(I), :);
                within = withinDisplayBoundaries(dots0orig(I, :));

                for l=1:numel(I)
                    X = [c0(l, 1) c1(l, 1)];
                    Y = [c0(l, 2) c1(l, 2)];
                    
                    if get(hmaskcheck, 'Value')
                        transp = within(l) * 1 + (1-within(l)) * 0.2;
                    else
                        transp = 1;
                    end

                    h = patchline(X, Y, 'Parent', hviewer, 'LineStyle', lineStyle, ...
                        'edgecolor', colorLinks, 'EdgeAlpha', transp);
                    annotationHandles = [annotationHandles; h]; %#ok<AGROW>
                end

                tmp_i = tmp_i + 1;
            end
        end
        drawnow
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
        set(hpactions, 'Visible', 'on');
        set(hpactions1, 'Visible', 'on');
        set(hpactions3, 'Visible', 'off');
        set(hfilters, 'Visible', 'off');
        set(hsave, 'Enable', 'off');
    end
end