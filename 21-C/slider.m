function varargout = slider(varargin)
% SLIDER MATLAB code for slider.fig
%      SLIDER, by itself, creates a new SLIDER or raises the existing
%      singleton*.
%
%      H = SLIDER returns the handle to a new SLIDER or the handle to
%      the existing singleton*.
%
%      SLIDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLIDER.M with the given input arguments.
%
%      SLIDER('Property','Value',...) creates a new SLIDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before slider_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to slider_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help slider

% Last Modified by GUIDE v2.5 21-Dec-2013 16:48:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @slider_OpeningFcn, ...
                   'gui_OutputFcn',  @slider_OutputFcn, ...
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


% --- Executes just before slider is made visible.
function slider_OpeningFcn(hObject, eventdata, handles, varargin)
% Initialize COM ports for different axes of magnet stage
delete(instrfind);
s_x = serial('com6');
s_y=  serial('com5');
s_rot=  serial('com7');
s_obj=  serial('com4');

% Choose default command line output for slider
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% ---- Initializing Zaber and getting the position of the stage ---------%
% This is for X
% include driver directories
addpath(genpath('ZaberInstrumentDriver'));
% open device, build list of devices & start testing functions

handles.zaber_x = ZaberOpen(s_x);
zaber_x = handles.zaber_x;
zaber_x = ZaberUpdateDeviceList(zaber_x);
%% ---- End of intializing ---------------------------------------------%%

set(handles.slider_x, 'Max', (zaber_x.maxPosition(zaber_x.deviceIndex))*1000);
[ret ~] = ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex);
set(handles.slider_x, 'Value', (ret(2)*1000));
set(handles.Pos_x, 'String', get(handles.slider_x, 'Value'));
set(handles.xmax, 'String', [num2str((zaber_x.maxPosition(zaber_x.deviceIndex))*1000) ' [mm]']);
% UIWAIT makes slider wait for user response (see UIRESUME)
% uiwait(handles.figure1);

guidata(hObject,handles);

% --- Outputs from this function are returned to the command line.
function varargout = slider_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_x_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
disp(get(hObject, 'Value'));
set(handles.Pos_x, 'String', get(hObject, 'Value'));

function move_x(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
absolutePosition = get(handles.slider_x, 'Value')*1e-3;
zaber_x = handles.zaber_x;  
[ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, absolutePosition)
set(handles.slider_x, 'Value', ret(2)*1e3);
set(handles.Pos_x, 'String', num2str(ret(2)*1e3));

% --- Executes during object creation, after setting all properties.
function slider_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function Pos_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

% --- Executes during object creation, after setting all properties.
function Pos_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function home_x(hObject, eventdata, handles)

zaber_x = handles.zaber_x;
[ret err] = ZaberHome(zaber_x, zaber_x.deviceIndex);
refresh(handles);

function refresh(handles)
zaber_x = handles.zaber_x;
[ret err] = ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex)
set(handles.slider_x, 'Value', ret(2)*1e3);
set(handles.Pos_x, 'String', num2str(ret(2)*1e3));

