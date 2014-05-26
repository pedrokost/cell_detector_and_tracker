function detectionViewer
    %FUNCTION DETECTIONVIEWER Displays the cell detection results
    
    %  Create and then hide the GUI as it is being constructed.
    f = figure('Visible','off','Position',[0,0,825,500]);

    % =====================================================================
    % ------------FUNCTION GLOBALS-----------------------------------------
    % =====================================================================
    matfiles = '';
    imgfiles = '';
    curIdx = 1;
    folderName = '';
    numImages = 0;
    % =====================================================================
    % ------------SETUP COMPONENTS-----------------------------------------
    % =====================================================================
    hbrowse = uicontrol('Style','pushbutton',...
           'String','Choose image',...
           'Position', [25 425 175 50],...
           'Callback',{@hbrowse_callback});
    hfilepath = uicontrol('Style','text', ...
           'String','Browse for directory with detection results',...
           'Position', [200,425,600,50], ...
           'HorizontalAlignment', 'left');
    hcurimg = uicontrol('Style','text', ...
           'String',' 0/0',...
           'Position', [625,45,75,12], ...
           'HorizontalAlignment', 'center',...
           'Visible','off');
    hviewerraw = axes('Units','Pixels',...
            'Position', [25, 100, 375,300],...
            'Visible','off'); 
    hviewerdetection = axes('Units','Pixels', ...
            'Position', [425,100,375,300],...
            'Visible','off');
    hnext = uicontrol('Style','pushbutton',...
            'String','Next image',...
            'Position', [700,25,100,50], ...
            'Callback', {@hnext_callback},...
            'Visible','off');
    hprev = uicontrol('Style','pushbutton',...
            'String','Previous image',...
            'Position', [525,25,100,50], ...
            'Callback', {@hprev_callback},...
            'Visible','off');
    hslider = uicontrol('Style', 'slider', ...
                        'Min', 1,...
                        'Max', 2,...
                        'SliderStep', [1 1],...
                        'Value', 1,...
                        'Position', [25,25,475,50],...
                        'Callback', @hslider_callback,...
                        'Visible','off');
    hsliderListener = addlistener(hslider,'Value','PostSet',@hslider_callback);
%     inspect(hslider)

    % =====================================================================
    % ------------INTITIALIZE THE GUI--------------------------------------
    % =====================================================================
    % Initialize the GUI.
    % Change units to normalized so components resize automatically.
    set([f,hbrowse,hfilepath,hviewerraw,hviewerdetection,hnext, hprev, hcurimg, hslider],...
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
    % ========================================================
    function hbrowse_callback(source, eventdata)
       [fileName,folderName,~] = uigetfile({'*.*'}, 'Select an image');
       if folderName == 0
          warning('Select the folder with images and annotation mat files')
          hideUIElements()
          return
       end
% TODO: call the GUI, do not shortcut here
%        fileName='im01.pgm';
%        folderName = '/home/pedro/Dropbox/Imperial/project/detection_viewer/kidney/trainKidneyRed/';
       imgformat = strsplit(fileName, '.');
       imgformat = imgformat{end};
       imgfiles = dir(fullfile(folderName, strcat('*.', imgformat)));
       numImages = numel(imgfiles);
       
       matfiles = cell(numImages);
%      load only corresponding mat files
       for i=1:numImages
           img = imgfiles(i);
           base = basename(img.name);
           matfiles{i} = strcat(base, '.mat');
           if ~exist(fullfile(folderName, matfiles{i}), 'file') 
              error('The file %s does not exist', matfiles{i}) 
           end
       end
       matfiles = struct('name', matfiles);
       
       
       set(hfilepath, 'String', folderName);
       set(hslider, 'Max', numImages);
       set(hslider, 'SliderStep', [1 5] / (numImages - 1));
       
       displayImage(curIdx, numImages);
       displayUIElements()
    end

    function hnext_callback(source, eventdata)
        curIdx = curIdx + 1;
        curIdx = min(curIdx, numImages);
        displayImage(curIdx, numImages);
    end
    function hprev_callback(source, eventdata)
        curIdx = curIdx - 1;
        curIdx = max(curIdx, 1);
        displayImage(curIdx, numImages);
    end
    function hslider_callback(source, eventdata)
        value = round(get(hslider, 'Value'));
        if value == curIdx; return; end
        
        curIdx = value;
        displayImage(curIdx, numImages);
    end

    function displayImage(index, numImages)
        %% DISPLAYIMAGE Displays the current image in the sequence
        
        I = imread(fullfile(folderName, imgfiles(index).name));
        data = load(fullfile(folderName, matfiles(index).name), 'gl');
        gl = data.gl;

        imshow(I, 'Parent', hviewerraw);
        imshow(I, 'Parent', hviewerdetection);
        hold(hviewerdetection, 'on');
        plot(gl(:, 1), gl(:, 2), 'r+', 'Parent', hviewerdetection);
        drawnow;
        
        progress = sprintf('%2d/%d', index, numImages);
        set(hcurimg, 'String', progress);
        set(hslider, 'Value', index);
    end

    function displayUIElements
      set(hcurimg, 'Visible', 'on');
      set(hviewerraw, 'Visible', 'on');
      set(hviewerdetection, 'Visible', 'on');
      set(hnext, 'Visible', 'on');
      set(hprev, 'Visible', 'on');
      set(hslider, 'Visible', 'on');
    end

    function hideUIElements
      set(hcurimg, 'Visible', 'off');
      set(hviewerraw, 'Visible', 'off');
      set(hviewerdetection, 'Visible', 'off');
      set(hnext, 'Visible', 'off');
      set(hprev, 'Visible', 'off');
      set(hslider, 'Visible', 'off');
    end

    function base = basename(filename)
        [~, base, ~] = fileparts(filename);
    end
end

