function varargout = TransEdit2D(varargin)
% TRANSEDIT2D MATLAB code for TransEdit2D.fig
%      TRANSEDIT2D, by itself, creates a new TRANSEDIT2D or raises the existing
%      singleton*.
%
%      H = TRANSEDIT2D returns the handle to a new TRANSEDIT2D or the handle to
%      the existing singleton*.
%
%      TRANSEDIT2D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRANSEDIT2D.M with the given input arguments.
%
%      TRANSEDIT2D('Property','Value',...) creates a new TRANSEDIT2D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TransEdit2D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TransEdit2D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TransEdit2D

% Last Modified by GUIDE v2.5 25-Mar-2011 00:25:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TransEdit2D_OpeningFcn, ...
    'gui_OutputFcn',  @TransEdit2D_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TransEdit2D is made visible.
function TransEdit2D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TransEdit2D (see VARARGIN)

% Choose default command line output for TransEdit2D
handles.output = hObject;


handles.im = zeros(320,320);
[sm, sn] = size(handles.im);

handles.size =[sm, sn];
handles.shapes = makeShape([1 sn],[1 sm],'rectangle',20);

handles.shapes(1).type = 'background rect';
handles.T = eye(3);
handles.color = 20;
handles.shapeType = 'ellipse';
set(handles.slider1,'Value', handles.color);

set(handles.uitable1,'Data',handles.T);
clc
disp(handles);
% Update handles structure

ResetGui(handles);
guidata(hObject, handles);



% UIWAIT makes TransEdit2D wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = TransEdit2D_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in addShape.
function addShape_Callback(hObject, eventdata, handles)
% hObject    handle to addShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.helpText,'String','click on 2 points on the canves to draw the shape');
[X,Y] = ginput(2);
shape = makeShape(X,Y, handles.shapeType, handles.color);
handles.shapes(end+1) = shape;
handles.selected = length(handles.shapes);
updateShapesNames(handles)
set(handles.listbox1,'Value',handles.selected);
DrawScreen(handles);
guidata(hObject, handles);
set(handles.helpText,'String','Good...');


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
handles.selected = get(hObject,'Value');
set(handles.helpText,'String','Selects the shape for the transformations');
DrawScreen(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GuiTrans.
function GuiTrans_Callback(hObject, eventdata, handles)
% hObject    handle to GuiTrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.T = getGuiTrans(handles);
handles.shapes(handles.selected) = shapeTrans(handles.shapes(handles.selected), handles.T);
set(handles.uitable1,'Data',handles.T);
set(handles.helpText,'String','You can undo the transformation by cliking Inv Mat and then Apply Matrix Trans');
DrawScreen(handles);
guidata(hObject, handles);

function T = getGuiTrans(handles)
value = get(handles.popupmenu1,'Value');

switch value
    case 1 %% translation
        set(handles.helpText,'String','Press on 2 points on the canves for translation');
        [X,Y] = ginput(2);
        T = translationMatrix(X(2)-X(1),Y(2)-Y(1));
    case 2 %
        set(handles.helpText,'String','press on 2 points, first is the axis of rotation and secound will indecate the degres relitive to the axis');
        [X,Y] = ginput(2);
        T = rotationOnPointMatrix(X(1),Y(1), atan2(Y(2)-Y(1),X(2)-X(1)) );
    case 3
        set(handles.helpText,'String','Press on 2 points on the canves for shear, dx/50 is the Sx, and dy/50 is Sy');
        [X,Y] = ginput(2);
        T = shearMatrix((X(2)-X(1))/50, Y(1),abs(Y(2)-Y(1))/50, X(1));
    otherwise
        set(handles.helpText,'String','Press on 3 points on the canves for scaling, first point is the center secound is the refrance size and third is the new size');
        [X,Y] = ginput(3);
        T = scalingOnPointMatrix(X(1),Y(1),abs((X(3)-X(1))/max(abs(X(2)-X(1)),0.1)),abs((Y(3)-Y(1))/max(abs(Y(2)-Y(1)),0.1)));
end


% --- Executes on button press in InvMatrix.
function InvMatrix_Callback(hObject, eventdata, handles)
% hObject    handle to InvMatrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.T = handles.T^-1;
set(handles.uitable1,'Data',handles.T);
guidata(hObject, handles);


% --- Executes on button press in matrixTrans.
function matrixTrans_Callback(hObject, eventdata, handles)
% hObject    handle to matrixTrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.shapes(handles.selected) = shapeTrans(handles.shapes(handles.selected), handles.T);
set(handles.uitable1,'Data',handles.T);
DrawScreen(handles);
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.T = get(handles.uitable1,'Data');
guidata(hObject, handles);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function DrawScreen(handles)
handles.im = zeros(handles.size(1), handles.size(2));
handles.im = drawShapes(handles.im, handles.shapes);
handles.im = drawShapes(handles.im, handles.shapes(handles.selected),300);
image(handles.im);



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.color = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
contents = cellstr(get(hObject,'String')) ;
handles.shapeType = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadShapes.
function loadShapes_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to loadShapes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FileName = uigetfile('*.mat');
if ~isempty(FileName)
    temp = load(FileName);
    handles.shapes = temp.shapes;
    ResetGui(handles)
    guidata(hObject, handles);
end



% --- Executes on button press in saveShapes.
function saveShapes_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to saveShapes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
shapes = handles.shapes; %#ok<NASGU>
FileName = uiputfile();
if ~isempty(FileName)
    save(FileName, 'shapes');
end

function ResetGui(handles)
handles.selected = 1;
updateShapesNames(handles);
DrawScreen(handles)

function updateShapesNames(handles)
strings = cell(length(handles.shapes),1);
for i=1:length(handles.shapes)
    strings{i} = handles.shapes(i).type;
end
set(handles.listbox1,'value',min(length(strings),handles.selected));
set(handles.listbox1,'String',strings);

% --- Executes on button press in clearShapes.
function clearShapes_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to clearShapes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm = handles.size(1);
sn = handles.size(2);
handles.shapes = makeShape([1 sn],[1 sm],'rectangle',20);
ResetGui(handles)
guidata(hObject, handles);


% --- Executes on button press in saveAsImage.
function saveAsImage_Callback(hObject, eventdata, handles) %#ok<*INUSL,DEFNU>
% hObject    handle to saveAsImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FileName = uiputfile();
handles.im = drawShapes(handles.im, handles.shapes);
map = colormap(jet);
if ~isempty(FileName)
    imwrite(handles.im ,map,[FileName '.bmp'],'bmp');
end
