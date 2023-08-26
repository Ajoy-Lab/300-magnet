 function varargout = magnet_align(varargin)
% MAGNET_ALIGN MATLAB code for magnet_align.fig
%      MAGNET_ALIGN, by itself, creates a new MAGNET_ALIGN or raises the existing
%      singleton*.
%
%      H = MAGNET_ALIGN returns the handle to a new MAGNET_ALIGN or the handle to
%      the existing singleton*.
%
%      MAGNET_ALIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAGNET_ALIGN.M with the given input arguments.
%
%      MAGNET_ALIGN('Property','Value',...) creates a new MAGNET_ALIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before magnet_align_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to magnet_align_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help magnet_align

% Last Modified by GUIDE v2.5 07-Apr-2014 19:44:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @magnet_align_OpeningFcn, ...
                   'gui_OutputFcn',  @magnet_align_OutputFcn, ...
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


% --- Executes just before magnet_align is made visible.
function magnet_align_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to magnet_align (see VARARGIN)

% Initialize COM ports for different axes of magnet stage
delete(instrfind);
s_x = serial('com6');

addpath(genpath('ZaberInstrumentDriver'));
% This is for X
disp('Initalizing magnet stage in X');
handles.zaber_x = ZaberOpen(s_x);
zaber_x = handles.zaber_x;
zaber_x = ZaberUpdateDeviceList(zaber_x);

handles.defaultMax_x = zaber_x.maxPosition(zaber_x.deviceIndex);
ZaberSetMaximumPosition(zaber_x, zaber_x.deviceIndex, handles.defaultMax_x);

set(handles.xmin, 'String', '0');
set(handles.xmax, 'String', '10');
set(handles.speed, 'String', '1');

% Choose default command line output for slider
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% Choose default command line output for magnet_align
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes magnet_align wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Executes on button press in magnet_scan.
function magnet_scan_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
speed  = str2num(get(handles.speed, 'String'))*1e-3;
xmin = str2num(get(handles.xmin, 'String'))*1e-3;
xmax = str2num(get(handles.xmax, 'String'))*1e-3;
zaber_x = handles.zaber_x;
[ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, xmin);

% while(abs(ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex)-xmin) > 1*e-6)
% pause(0.01);
% end

ZaberSetMaximumPosition(zaber_x, zaber_x.deviceIndex, xmax);
ZaberMoveAtConstantSpeed(zaber_x, zaber_x.deviceIndex, speed);
time_move = (xmax - xmin)/speed;
pause(time_move*1.3);
[currentpos ~]= ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex);
set(handles.current_posx, 'String', num2str(currentpos(zaber_x.deviceIndex)*1e3));

function xmax_Callback(hObject, eventdata, handles)
% Check for max allowed
xmax = str2num(get(handles.xmax, 'String'))*1e-3;
if(xmax > handles.defaultMax_x)
    set(handles.xmax, 'String', num2str(handles.defaultMax_x*1e3));
end


% --- Executes on button press in magnet_stop.
function magnet_stop_Callback(hObject, eventdata, handles)
% Stop zaber
ZaberStop(handles.zaber_x, handles.zaber_x.deviceIndex);


% --- Executes during object creation, after setting all properties.
function xmin_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function current_posx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_posx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function current_posy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_posy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function current_posz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_posz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function points_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to points_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function points_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to points_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function check_scanx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to check_scanx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function check_scany_CreateFcn(hObject, eventdata, handles)
% hObject    handle to check_scany (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function check_scanz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to check_scanz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function magnet_scan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnet_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function magnet_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnet_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function zmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function zmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Outputs from this function are returned to the command line.
function varargout = magnet_align_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
