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
%s_obj=  serial('com8');
s_z=  serial('com4');

% Choose default command line output for slider
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% ---- Initializing Zaber and getting the position of the stage ---------%
addpath(genpath('ZaberInstrumentDriver'));
% This is for X
disp('Initalizing magnet stage in X');
handles.zaber_x = ZaberOpen(s_x);
zaber_x = handles.zaber_x;
zaber_x = ZaberUpdateDeviceList(zaber_x);

set(handles.slider_x, 'Max', (zaber_x.maxPosition(zaber_x.deviceIndex))*1000);
[ret ~] = ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex);
set(handles.slider_x, 'Value', (ret(2)*1000));
set(handles.Pos_x, 'String', get(handles.slider_x, 'Value'));
set(handles.xmax, 'String', [num2str((zaber_x.maxPosition(zaber_x.deviceIndex))*1000) ' [mm]']);

% This is for Y
disp('Initalizing magnet stage in Y');
handles.zaber_y = ZaberOpen(s_y);
zaber_y = handles.zaber_y;
zaber_y = ZaberUpdateDeviceList(zaber_y);
set(handles.slider_y, 'Max', (zaber_y.maxPosition(zaber_y.deviceIndex))*1000);
[ret ~] = ZaberReturnCurrentPosition(zaber_y, zaber_y.deviceIndex);
set(handles.slider_y, 'Value', (ret(2)*1000));
set(handles.Pos_y, 'String', get(handles.slider_y, 'Value'));
set(handles.ymax, 'String', [num2str((zaber_y.maxPosition(zaber_y.deviceIndex))*1000) ' [mm]']);


% This is for Z
disp('Initalizing magnet stage in Z');
handles.zaber_z = ZaberOpen(s_z);
zaber_z = handles.zaber_z;
zaber_z = ZaberUpdateDeviceList(zaber_z);

set(handles.slider_z, 'Max', (zaber_z.maxPosition(zaber_z.deviceIndex))*1000);
[ret ~] = ZaberReturnCurrentPosition(zaber_z, zaber_z.deviceIndex);
set(handles.slider_z, 'Value', (ret(2)*1000));
set(handles.Pos_z, 'String', get(handles.slider_z, 'Value'));
set(handles.zmax, 'String', [num2str((zaber_z.maxPosition(zaber_z.deviceIndex))*1000) ' [mm]']);

% This is for Rot
disp('Initalizing magnet stage in Rotation');
handles.zaber_rot = ZaberOpen(s_rot);
zaber_rot = handles.zaber_rot;
zaber_rot = ZaberUpdateDeviceList(zaber_rot);

for j=1:zaber_rot.nrOfDevices
    if strcmp(zaber_rot.devNames{j}, 'T-RSW60A')
        zaber_rot.microStepSize(j) = 0.000234375;
        zaber_rot.maxPosition(j) = 360;
        zaber_rot.maxSpeed(j) = 13.2;    
    end
end
handles.zaber_rot=zaber_rot;
set(handles.slider_rot, 'Max', (zaber_rot.maxPosition(zaber_rot.deviceIndex)));
[ret ~] = ZaberReturnCurrentPosition(zaber_rot, zaber_rot.deviceIndex);
set(handles.slider_rot, 'Value', (ret(2)));
set(handles.Pos_rot, 'String', get(handles.slider_rot, 'Value'));
set(handles.rotmax, 'String', [num2str((zaber_rot.maxPosition(zaber_rot.deviceIndex))) ' [deg]']);

guidata(hObject,handles);

% --- Outputs from this function are returned to the command line.
function varargout = slider_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make the textbox display slider position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function slider_x_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
disp(get(hObject, 'Value'));
set(handles.Pos_x, 'String', get(hObject, 'Value'));

function slider_y_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
disp(get(hObject, 'Value'));
set(handles.Pos_y, 'String', get(hObject, 'Value'));

function slider_z_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
disp(get(hObject, 'Value'));
set(handles.Pos_z, 'String', get(hObject, 'Value'));

function slider_rot_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
disp(get(hObject, 'Value'));
set(handles.Pos_rot, 'String', get(hObject, 'Value'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Move the stages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function move_x(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
absolutePosition = str2num(get(handles.Pos_x, 'String'))*1e-3;
zaber_x = handles.zaber_x;  
[ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, absolutePosition);
set(handles.slider_x, 'Value', ret(2)*1e3);
set(handles.Pos_x, 'String', num2str(ret(2)*1e3));
refresh(hObject, eventdata,handles);

function move_y(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
absolutePosition = str2num(get(handles.Pos_y, 'String'))*1e-3;
zaber_y = handles.zaber_y;  
[ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, absolutePosition);
set(handles.slider_y, 'Value', ret(2)*1e3);
set(handles.Pos_y, 'String', num2str(ret(2)*1e3));
refresh(hObject, eventdata,handles);

function move_z(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
absolutePosition = str2num(get(handles.Pos_z, 'String'))*1e-3;
zaber_z = handles.zaber_z;  
[ret err] = ZaberMoveAbsolute(zaber_z, zaber_z.deviceIndex, absolutePosition);
set(handles.slider_z, 'Value', ret(2)*1e3);
set(handles.Pos_z, 'String', num2str(ret(2)*1e3));
refresh(hObject, eventdata,handles);


function move_rot(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
absolutePosition = str2num(get(handles.Pos_rot, 'String'));
zaber_rot = handles.zaber_rot;  
[pos_initial err] = ZaberReturnCurrentPosition(zaber_rot, zaber_rot.deviceIndex);
[ret err] = ZaberMoveAbsolute(zaber_rot, zaber_rot.deviceIndex, absolutePosition,false);
pause(zaber_rot.maxSpeed(zaber_rot.deviceIndex)*abs(absolutePosition-pos_initial)*2); %pause to make sure rotation has finished
[ret err] = ZaberReturnCurrentPosition(zaber_rot, zaber_rot.deviceIndex); %update value
set(handles.slider_rot, 'Value', ret(2));
set(handles.Pos_rot, 'String', num2str(ret(2)));
refresh(hObject, eventdata,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Just set the background colors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function slider_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider_y_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider_z_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider_rot_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make the textbox move the slider
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pos_x_Callback(hObject, eventdata, handles)
set(handles.slider_x, 'Value', str2num(get(handles.Pos_x, 'String')));

function Pos_y_Callback(hObject, eventdata, handles)
set(handles.slider_y, 'Value', str2num(get(handles.Pos_y, 'String')));

function Pos_z_Callback(hObject, eventdata, handles)
set(handles.slider_z, 'Value', str2num(get(handles.Pos_z, 'String')));

function Pos_rot_Callback(hObject, eventdata, handles)
set(handles.slider_rot, 'Value', str2num(get(handles.Pos_rot, 'String')));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dummy functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Pos_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Pos_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Pos_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Pos_rot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Go Home on different devices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function home_x(hObject, eventdata, handles)

zaber_x = handles.zaber_x;
[ret err] = ZaberHome(zaber_x, zaber_x.deviceIndex);
refresh(hObject, eventdata,handles);

function home_y(hObject, eventdata, handles)

zaber_y = handles.zaber_y;
[ret err] = ZaberHome(zaber_y, zaber_y.deviceIndex);
refresh(hObject, eventdata,handles);

function home_z(hObject, eventdata, handles)

zaber_z = handles.zaber_z;
[ret err] = ZaberHome(zaber_z, zaber_z.deviceIndex);
refresh(hObject, eventdata,handles);

function home_rot(hObject, eventdata, handles)

zaber_rot = handles.zaber_rot;
[ret err] = ZaberHome(zaber_rot, zaber_rot.deviceIndex);
refresh(hObject, eventdata,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Refresh all positions and sliders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refresh(hObject, eventdata,handles)
zaber_x = handles.zaber_x;
[ret err] = ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex)
set(handles.slider_x, 'Value', ret(2)*1e3);
set(handles.Pos_x, 'String', num2str(ret(2)*1e3));

zaber_y = handles.zaber_y;
[ret err] = ZaberReturnCurrentPosition(zaber_y, zaber_y.deviceIndex)
set(handles.slider_y, 'Value', ret(2)*1e3);
set(handles.Pos_y, 'String', num2str(ret(2)*1e3));

zaber_z = handles.zaber_z;
[ret err] = ZaberReturnCurrentPosition(zaber_z, zaber_z.deviceIndex)
set(handles.slider_z, 'Value', ret(2)*1e3);
set(handles.Pos_z, 'String', num2str(ret(2)*1e3));

zaber_rot = handles.zaber_rot;
[ret err] = ZaberReturnCurrentPosition(zaber_rot, zaber_rot.deviceIndex)
set(handles.slider_rot, 'Value', ret(2));
set(handles.Pos_rot, 'String', num2str(ret(2)));

guidata(hObject, handles);