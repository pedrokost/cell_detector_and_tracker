function detectionViewer
    %FUNCTION DETECTIONVIEWER Displays the cell detection results
    
    addpath('relativepath');

    
    %  Create and then hide the GUI as it is being constructed.
    f = figure('Visible','off','Position',[0,0,825,500]);

    % =====================================================================
    % ------------FUNCTION GLOBALS-----------------------------------------
    % =====================================================================
    matfileNames = '';
    imgfileNames = '';
    curIdx = 1;
    imgFolderName = '';
    images = cell(1,1); % cache of images
    annotations = cell(1,1); % cache of annotation
    matFolderName = '';
    numImages = 0;
    % =====================================================================
    % ------------SETUP COMPONENTS-----------------------------------------
    % =====================================================================
    hbrowse = uicontrol('Style','pushbutton',...
           'String','Choose image folder',...
           'Position', [25 450 175 25],...
           'Callback',{@hbrowse_callback});
    hbrowsemat = uicontrol('Style','pushbutton',...
           'String','Choose annotation folder',...
           'Position', [25 425 175 25],...
           'Enable', 'off',...
           'Callback', {@hbrowsemat_callback});
    hchecksame = uicontrol('Style', 'checkbox', ...
                           'String', 'Includes annotations', ...
                           'Position', [200 450 175 25],...
                           'Value', 1,...
                           'Callback', {@hchecksame_callback});
    hfilepath = uicontrol('Style','text', ...
           'String','Browse for directory with detection results',...
           'Position', [400,450,400,25], ...
           'HorizontalAlignment', 'right',...
           'Visible', 'off');
    hfilepathmat = uicontrol('Style','text', ...
           'String','Browse for directory with annotation results',...
           'Position', [400,425,400,25], ...
           'HorizontalAlignment', 'right', ...
           'Visible', 'off');
    hviewerraw = axes('Units','Pixels',...
            'Position', [25, 100, 375,300],...
            'Visible','off'); 
    hviewerdetection = axes('Units','Pixels', ...
            'Position', [425,100,375,300],...
            'Visible','off');
    hslider = uicontrol('Style', 'slider', ...
                        'Min', 1,...
                        'Max', 2,...
                        'SliderStep', [1 1],...
                        'Value', 1,...
                        'Position', [25,25,775,50],...
                        'Callback', @hslider_callback,...
                        'Visible','off');
                    
    hsliderListener = addlistener(hslider,'Value','PostSet',@hslider_callback);
%     inspect(hslider)

    % =====================================================================
    % ------------INTITIALIZE THE GUI--------------------------------------
    % =====================================================================
    % Initialize the GUI.
    % Change units to normalized so components resize automatically.
    set([f,hbrowse,hfilepath,hviewerraw,hviewerdetection, ...
        hslider, hchecksame, hbrowsemat, hfilepathmat],...
        'Units','normalized');

    % Generate the data to plot.

    % Assign the GUI a name to appear in the window title.
    set(f,'Name','Cell Annotation Viewer')

    % Move the GUI to the center of the screen.
    movegui(f,'center')

    % Make the GUI visible.
    set(f,'Visible','on');
    % =====================================================================
    % -----------CALLBACKS-------------------------------------------------
    % =====================================================================
    function hbrowse_callback(source, eventdata)
       [filen,foldn,~] = uigetfile({'*.*'}, 'Select an image');
       if foldn == 0
          warning('Select the folder with images')
          if numImages ==0;
              hideUIElements();
          end
          return
       else
           fileName = filen;
           imgFolderName = foldn;
       end
       imgformat = strsplit(fileName, '.');
       imgformat = imgformat{end};
       imgfileNames = dir(fullfile(imgFolderName, strcat('*.', imgformat)));
       numImages = numel(imgfileNames);
       images = cell(numImages, 1);
       
       if get(hchecksame, 'Value')
           matFolderName = imgFolderName;
       end
       loadMatFiles();
       
       set(hfilepath, 'String', imgFolderName);
       set(hslider, 'Max', numImages);
       set(hslider, 'SliderStep', [1 5] / (numImages - 1));
       
       displayImage(curIdx, numImages);
       updateFolderPaths()
       displayUIElements()
    end

    function hbrowsemat_callback(source, eventdata)
      foldn = uigetdir(imgFolderName, 'Select folder with annotations');
       if foldn == 0
          warning('Select the folder with annotations')
          return
       else
           matFolderName = foldn;
       end
       loadMatFiles();
       updateFolderPaths()
       displayAnnotations(curIdx);
    end

    function hslider_callback(source, eventdata)
        value = round(get(hslider, 'Value'));
        if value == curIdx; return; end
        
        curIdx = value;
        displayImage(curIdx, numImages);
    end

    function hchecksame_callback(source, eventdata)
       % Manages toggling the use-same-folder-for-annotations checkbox
       value = get(hchecksame, 'Value');
       if value == 1
            set(hbrowsemat, 'Enable', 'off');
            matFolderName = imgFolderName;
            loadMatFiles()
       else
           set(hbrowsemat, 'Enable', 'on');
           matFolderName = '';
           displayImage(curIdx, numImages)
       end
       updateFolderPaths()
       displayImage(curIdx, numImages);
    end
    % =====================================================================
    % -----------OTHER FUNCTIONS-------------------------------------------
    % =====================================================================
    function updateFolderPaths()
        if ~isempty(imgFolderName)
           set(hfilepath, 'String', relativepath(imgFolderName)); 
        else
            set(hfilepath, 'String', ''); 
        end
        
        if ~isempty(matFolderName)
           set(hfilepathmat, 'String', relativepath(matFolderName)); 
        else
            set(hfilepathmat, 'String', ''); 
        end
    end

    function loadMatFiles
        % Loads annotation files
        if isempty(matFolderName)
            warning('Select a mat folder')
            return
        end
        matfileNames = cell(numImages);
        for i=1:numImages
           img = imgfileNames(i);
           base = basename(img.name);
           matfileNames{i} = strcat(base, '.mat');
           if ~exist(fullfile(matFolderName, matfileNames{i}), 'file') 
              error('The file %s does not exist', matfileNames{i}) 
           end
        end
        matfileNames = struct('name', matfileNames); 
        annotations = cell(numImages, 1);
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
        if isempty(annotations{index})
            data = load(fullfile(matFolderName, matfileNames(index).name));
            if isfield(data, 'dots')
                dots = data.dots;
            else
                dots = data.gl;
            end
            annotations{index} = dots;
        else
            dots = annotations{index};
        end
    end

    function displayImage(index, numImages)
        % Loads and displays the current image
        if isempty(imgFolderName)
            return
        end
        
        I = getImage(index);
        cla(hviewerraw);
        cla(hviewerdetection);
        imshow(I, 'Parent', hviewerraw);
        imshow(I, 'Parent', hviewerdetection);
        tit = sprintf('Original image %2d/%d', index, numImages);
        title(tit, 'Parent', hviewerraw)
        title(tit, 'Parent', hviewerdetection)
        set(hslider, 'Value', index);
        
        displayAnnotations(index);
    end

    function displayAnnotations(index)
        % Loads and displays the current annotations
        if isempty(matFolderName)
            return
        end
        
        dots = getAnnotations(index);

        hold(hviewerdetection, 'on');
        plot(dots(:, 1), dots(:, 2), 'r+', 'Parent', hviewerdetection);
        
        tit = sprintf('Annotated image %2d/%d', index, numImages);
        title(tit, 'Parent', hviewerdetection)
    end

    function displayUIElements
      set(hviewerraw, 'Visible', 'off');
      set(hviewerdetection, 'Visible', 'off');
      set(hslider, 'Visible', 'on');
      set(hfilepath, 'Visible', 'on');
      set(hfilepathmat, 'Visible', 'on');
    end

    function hideUIElements
      set(hviewerraw, 'Visible', 'off');
      set(hviewerdetection, 'Visible', 'off');
      set(hslider, 'Visible', 'off');
      set(hfilepath, 'Visible', 'off');
      set(hfilepathmat, 'Visible', 'off');
    end

    function base = basename(filename)
        [~, base, ~] = fileparts(filename);
    end
end

