function cellAnnotator
    %cellAnnotator GUI tool for cell and cell sequence annotation
    
    addpath('relativepath');
    % =====================================================================
    % ------------FUNCTION GLOBALS-----------------------------------------
    % =====================================================================
    usrMatfileNames = '';
    detMatfileNames = '';
    imgfileNames = '';
    imgFolderName = '';
    detMatFolderName = '';
    images = cell(1,1); % cache of images
    usrAnnotations = cell(1,1); % cache of annotation
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
    
    testing = 1;
    
    % =====================================================================
    % ------------SETUP COMPONENTS-----------------------------------------
    % =====================================================================
    %  Create and then hide the GUI as it is being constructed.
    f = figure('Visible','off','Position',[0,0,figWidth,figHeight]);
    
    % Hide toolbar
    set(f, 'Menu','none', 'Toolbar','none')
    
    halfWidth = figWidth/2 - padding*1.5;
    hbrowse = uicontrol('Style','pushbutton',...
           'String','Choose image folder',...
           'Position', [padding figHeight-30 halfWidth 25],...
           'Callback',{@hbrowse_callback});
    hbrowsedet = uicontrol('Style','pushbutton',...
           'String','Choose detections folder',...
           'Position', [halfWidth + 2*padding figHeight-30 halfWidth 25],...
           'Callback', {@hbrowsemat_callback});
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
        'Position', [padding 425 figWidth-2*padding 25]);
    
    % FIMX: use relative units here
    hfiltercontrast = uicontrol('Style','checkbox',...
        'String','Contrast',...
        'pos',[2 2 200 20],...
        'Parent',hfilters, ...
        'HandleVisibility','off',...
        'Callback', @requestRedraw);
    hfilterdenoise = uicontrol('Style','checkbox',...
        'String','Remove Noise',...
        'pos',[200+padding 2 200 20],...
        'Parent',hfilters, ...
        'HandleVisibility','off',...
        'Callback', @requestRedraw);
    hfilterhisteq = uicontrol('Style','checkbox',...
        'String','Histgram equalization',...
        'pos',[400+2*padding 2 200 20],...
        'Parent',hfilters, ...
        'HandleVisibility','off',...
        'Callback', @requestRedraw);
    
    hfilteradapthisteq = uicontrol('Style','checkbox',...
        'String','Adaptive Histgram equalization',...
        'pos',[600+3*padding 2 200 20],...
        'Parent',hfilters, ...
        'HandleVisibility','off',...
        'Callback', @requestRedraw);
    
    hfilterdecorrstretch = uicontrol('Style','checkbox',...
        'String','Decorrelation stretch',...
        'pos',[800+4*padding 2 200 20],...
        'Parent',hfilters, ...
        'HandleVisibility','off',...
        'Callback', @requestRedraw);

    hfilterwiener = uicontrol('Style','checkbox',...
        'String','Wiener filter',...
        'pos',[1000+4*padding 2 200 20],...
        'Parent',hfilters, ...
        'HandleVisibility','off',...
        'Callback', @requestRedraw);

    
    
    
    hsliderListener = addlistener(hslider,'Value','PostSet',@hslider_callback);
%     inspect(hslider)

%     inspect(hfilters)
    % =====================================================================
    % ------------INTITIALIZE THE GUI--------------------------------------
    % =====================================================================
    % Initialize the GUI.
    % Change units to normalized so components resize automatically.
    set([f,hbrowse,hviewer, hslider, hbrowsedet, hfilters, hfiltercontrast],...
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
        usrAnnotations = cell(numImages, 1);
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
    end

    function requestRedraw(source, eventdata)
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

    % =====================================================================
    % -----------OTHER FUNCTIONS-------------------------------------------
    % =====================================================================
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
        if isempty(usrAnnotations{index})
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
            usrAnnotations{index} = dots;
        else
            dots = usrAnnotations{index};
        end
    end

    function displayImage(index, numImages)
        % Loads and displays the current image
        if isempty(imgFolderName)
            return
        end
        
        % Check filters to apply
        applyConstrast = get(hfiltercontrast, 'Value');
        applyMedianFilter = get(hfiltermedian, 'Value');
        applyAdaptiveFilter = get(hfilterwiener, 'Value');
        applyHisteq = get(hfilterhisteq, 'Value');
        applyadapthisteq = get(hfilteradapthisteq, 'Value');  
        applydecorrstretch = get(hfilterdecorrstretch, 'Value');
        
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
        I = cat(2, I0, gap, I1,gap, I2);
        
        
        % Apply filters
        if applyConstrast
           I = imadjust(I);
        end
        
        if applyHisteq
           I = histeq(I); 
        end
        if applyMedianFilter
            I = medfilt2(I,[3 3]);
        end

        if applyMedianFilter
            I = medfilt2(I,[3 3]);
        end

        if applyAdaptiveFilter
            I = wiener2(I, [5 5]);
        end
        
        if applyadapthisteq
           I = adapthisteq(I);
        end
        
        if applydecorrstretch
           I = decorrstretch(I); % ,'Tol',0.01
        end
        
        imshow(I, 'Parent', hviewer);
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
    end

    function hideUIElements
      set(hviewer, 'Visible', 'off');
      set(hslider, 'Visible', 'off');
      set(hfilters, 'Visible', 'off');
    end

    function base = basename(filename)
        [~, base, ~] = fileparts(filename);
    end
end


