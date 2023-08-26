function varargout = magnet(varargin)
% MAGNET MATLAB code for magnet.fig
%      MAGNET, by itself, creates a new MAGNET or raises the existing
%      singleton*.
%
%      H = MAGNET returns the handle to a new MAGNET or the handle to
%      the existing singleton*.
%
%      MAGNET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAGNET.M with the given input arguments.
%
%      MAGNET('Property','Value',...) creates a new MAGNET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before magnet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to magnet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help magnet

% Last Modified by GUIDE v2.5 23-Jan-2017 17:21:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @magnet_OpeningFcn, ...
                   'gui_OutputFcn',  @magnet_OutputFcn, ...
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


% --- Executes just before magnet is made visible.
function magnet_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to magnet (see VARARGIN)

% Choose default command line output for magnet

gobj = findall(0,'Name','Imaging');
handles.Imaginghandles = guidata(gobj);

axis(handles.magnet_axes,'square');
ylabel(handles.magnet_axes,'Counts [cps]');

handles.output = hObject;

%delete(instrfind);
s_x = serial('com3');
s_y=  serial('com4');

s_rot=  serial('com6');
s_z=  serial('com5');

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

% this is to set maximum position
handles.defaultMax_x = zaber_x.maxPosition(zaber_x.deviceIndex);
ZaberSetMaximumPosition(zaber_x, zaber_x.deviceIndex, handles.defaultMax_x);

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


% this is to set maximum position
handles.defaultMax_y = zaber_y.maxPosition(zaber_y.deviceIndex);
ZaberSetMaximumPosition(zaber_y, zaber_y.deviceIndex, handles.defaultMax_y);



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


% this is to set maximum position
handles.defaultMax_z = zaber_z.maxPosition(zaber_z.deviceIndex);
ZaberSetMaximumPosition(zaber_z, zaber_z.deviceIndex, handles.defaultMax_z);


% This is for Rot
disp('Initalizing magnet stage in Rotation');
handles.zaber_rot = ZaberOpen(s_rot);
zaber_rot = handles.zaber_rot;
zaber_rot = ZaberUpdateDeviceList(zaber_rot);

for j=1:zaber_rot.nrOfDevices
    if strcmp(zaber_rot.devNames{j}, 'T-RSW60A')
        zaber_rot.microStepSize(j) = 0.000234375;
        zaber_rot.maxPosition(j) = 360*4;
        zaber_rot.maxSpeed(j) = 13.2;    
    end
end
handles.zaber_rot=zaber_rot;
set(handles.slider_rot, 'Max', (zaber_rot.maxPosition(zaber_rot.deviceIndex)));
[ret ~] = ZaberReturnCurrentPosition(zaber_rot, zaber_rot.deviceIndex);
set(handles.slider_rot, 'Value', (ret(2)));
set(handles.Pos_rot, 'String', get(handles.slider_rot, 'Value'));
set(handles.rotmax, 'String', [num2str((zaber_rot.maxPosition(zaber_rot.deviceIndex))) ' [deg]']);

handles.magnetfunctions = magnetfunctions();

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes magnet wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = magnet_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_x_Callback(hObject, eventdata, handles)
% hObject    handle to slider_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.Pos_x, 'String', get(hObject, 'Value'));
move_x_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function slider_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function Pos_x_Callback(hObject, eventdata, handles)
% hObject    handle to Pos_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pos_x as text
%        str2double(get(hObject,'String')) returns contents of Pos_x as a double
set(handles.slider_x, 'Value', str2num(get(handles.Pos_x, 'String')));


% --- Executes during object creation, after setting all properties.
function Pos_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pos_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in move_x.
function move_x_Callback(hObject, eventdata, handles)
% hObject    handle to move_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
absolutePosition = str2num(get(handles.Pos_x, 'String'))*1e-3;
zaber_x = handles.zaber_x;  
[ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, absolutePosition);
set(handles.slider_x, 'Value', ret(2)*1e3);
set(handles.Pos_x, 'String', num2str(ret(2)*1e3));
refresh_magnet_Callback(hObject, eventdata,handles);


% --- Executes on button press in home_x.
function home_x_Callback(hObject, eventdata, handles)
% hObject    handle to home_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
absolutePosition =25.4*1e-3;
zaber_x = handles.zaber_x;  
[ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, absolutePosition);
set(handles.slider_x, 'Value', ret(2)*1e3);
set(handles.Pos_x, 'String', num2str(ret(2)*1e3));
refresh_magnet_Callback(hObject, eventdata,handles);


% --- Executes on slider movement.
function slider_y_Callback(hObject, eventdata, handles)
% hObject    handle to slider_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.Pos_y, 'String', get(hObject, 'Value'));
move_y_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function slider_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_rot_Callback(hObject, eventdata, handles)
% hObject    handle to slider_rot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.Pos_rot, 'String', get(hObject, 'Value'));
move_rot_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function slider_rot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_rot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function Pos_y_Callback(hObject, eventdata, handles)
% hObject    handle to Pos_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pos_y as text
%        str2double(get(hObject,'String')) returns contents of Pos_y as a double
set(handles.slider_y, 'Value', str2num(get(handles.Pos_y, 'String')));


% --- Executes during object creation, after setting all properties.
function Pos_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pos_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pos_z_Callback(hObject, eventdata, handles)
% hObject    handle to Pos_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pos_z as text
%        str2double(get(hObject,'String')) returns contents of Pos_z as a double
set(handles.slider_z, 'Value', str2num(get(handles.Pos_z, 'String')));


% --- Executes during object creation, after setting all properties.
function Pos_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pos_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pos_rot_Callback(hObject, eventdata, handles)
% hObject    handle to Pos_rot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pos_rot as text
%        str2double(get(hObject,'String')) returns contents of Pos_rot as a double
set(handles.slider_rot, 'Value', str2num(get(handles.Pos_rot, 'String')));


% --- Executes during object creation, after setting all properties.
function Pos_rot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pos_rot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in move_y.
function move_y_Callback(hObject, eventdata, handles)
% hObject    handle to move_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
absolutePosition = str2num(get(handles.Pos_y, 'String'))*1e-3;
zaber_y = handles.zaber_y;  
[ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, absolutePosition);
set(handles.slider_y, 'Value', ret(2)*1e3);
set(handles.Pos_y, 'String', num2str(ret(2)*1e3));
refresh_magnet_Callback(hObject, eventdata,handles);


% --- Executes on button press in move_z.
function move_z_Callback(hObject, eventdata, handles)
% hObject    handle to move_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
absolutePosition = str2num(get(handles.Pos_z, 'String'))*1e-3;
zaber_z = handles.zaber_z;  
[ret err] = ZaberMoveAbsolute(zaber_z, zaber_z.deviceIndex, absolutePosition);
set(handles.slider_z, 'Value', ret(2)*1e3);
set(handles.Pos_z, 'String', num2str(ret(2)*1e3));
refresh_magnet_Callback(hObject, eventdata,handles);


% --- Executes on button press in move_rot.
function move_rot_Callback(hObject, eventdata, handles)
% hObject    handle to move_rot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
absolutePosition = str2num(get(handles.Pos_rot, 'String'));
zaber_rot = handles.zaber_rot;  
[pos_initial err] = ZaberReturnCurrentPosition(zaber_rot, zaber_rot.deviceIndex);
[ret err] = ZaberMoveAbsolute(zaber_rot, zaber_rot.deviceIndex, absolutePosition,false);
pause(zaber_rot.maxSpeed(zaber_rot.deviceIndex)*abs(absolutePosition-pos_initial)*2); %pause to make sure rotation has finished
[ret err] = ZaberReturnCurrentPosition(zaber_rot, zaber_rot.deviceIndex); %update value
set(handles.slider_rot, 'Value', ret(2));
set(handles.Pos_rot, 'String', num2str(ret(2)));
refresh_magnet_Callback(hObject, eventdata,handles);


% --- Executes on button press in home_y.
function home_y_Callback(hObject, eventdata, handles)
% hObject    handle to home_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
absolutePosition =25.4*1e-3;
zaber_y = handles.zaber_y;  
[ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, absolutePosition);
set(handles.slider_y, 'Value', ret(2)*1e3);
set(handles.Pos_y, 'String', num2str(ret(2)*1e3));
refresh_magnet_Callback(hObject, eventdata,handles);


% --- Executes on button press in home_z.
function home_z_Callback(hObject, eventdata, handles)
% hObject    handle to home_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
absolutePosition =25.4*1e-3;
zaber_z = handles.zaber_z;  
[ret err] = ZaberMoveAbsolute(zaber_z, zaber_z.deviceIndex, absolutePosition);
set(handles.slider_z, 'Value', ret(2)*1e3);
set(handles.Pos_z, 'String', num2str(ret(2)*1e3));
refresh_magnet_Callback(hObject, eventdata,handles);


% --- Executes on button press in home_rot.
function home_rot_Callback(hObject, eventdata, handles)
% hObject    handle to home_rot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in refresh_magnet.
function refresh_magnet_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_magnet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zaber_x = handles.zaber_x;
[ret err] = ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex);
set(handles.slider_x, 'Value', ret(2)*1e3);
set(handles.Pos_x, 'String', num2str(ret(2)*1e3));

zaber_y = handles.zaber_y;
[ret err] = ZaberReturnCurrentPosition(zaber_y, zaber_y.deviceIndex);
set(handles.slider_y, 'Value', ret(2)*1e3);
set(handles.Pos_y, 'String', num2str(ret(2)*1e3));

zaber_z = handles.zaber_z;
[ret err] = ZaberReturnCurrentPosition(zaber_z, zaber_z.deviceIndex);
set(handles.slider_z, 'Value', ret(2)*1e3);
set(handles.Pos_z, 'String', num2str(ret(2)*1e3));

zaber_rot = handles.zaber_rot;
[ret err] = ZaberReturnCurrentPosition(zaber_rot, zaber_rot.deviceIndex);
set(handles.slider_rot, 'Value', ret(2));
set(handles.Pos_rot, 'String', num2str(ret(2)));

guidata(hObject, handles);


% --- Executes on slider movement.
function slider_z_Callback(hObject, eventdata, handles)
% hObject    handle to slider_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.Pos_z, 'String', get(hObject, 'Value'));
move_z_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function slider_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function speed_Callback(hObject, eventdata, handles)
% hObject    handle to speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed as text
%        str2double(get(hObject,'String')) returns contents of speed as a double


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


% --- Executes on button press in magnet_scan.
function magnet_scan_Callback(hObject, eventdata, handles)
speed  = str2num(get(handles.speed, 'String'))*1e-3;


daq=handles.Imaginghandles.ImagingFunctions.interfaceDataAcq;
handles.magnet_counter_line=handles.Imaginghandles.ImagingFunctions.TrackerCounterOutLine;

daq.AnalogOutVoltages(1)=5; %enable SPD
daq.WriteAnalogOutLine(1);

daq.CreateTask('Counter_magnet');
daq.CreateTask('PulseTrain_magnet');

tracker_points = str2num(get(handles.track_point, 'String'));

% 1D scan Z
if get(handles.check_scanz,'Value')==1 && get(handles.check_scanx,'Value')==0 && get(handles.check_scany,'Value')==0

    textxlabel='z [mm]';textylabel='Counts [cps]';
    
    zmin = str2num(get(handles.scan_zmin, 'String'))*1e-3;
    zmax = str2num(get(handles.scan_zmax, 'String'))*1e-3;
    
    points = str2num(get(handles.points_z, 'String'));
    points=ceil(points/tracker_points)*tracker_points;
    set(handles.points_z, 'String',num2str(points));
    
    track_intervals=ceil(points/tracker_points);
    Arg=linspace(zmin*1e3,zmax*1e3,points);
    argData=ones(1,points)*NaN;
    
    zmax=Arg(tracker_points)*1e-3;
    zmin=Arg(1)*1e-3;
    time_move = (zmax - zmin)/speed;
    time_move_per_point = time_move/(tracker_points+1);
    
    daq.ConfigureCounterIn('Counter_magnet',handles.Imaginghandles.ImagingFunctions.TrackerCounterInLine,handles.magnet_counter_line,tracker_points+1);
    daq.ConfigureClockOut('PulseTrain_magnet',handles.magnet_counter_line,1/time_move_per_point,0.5);
  
    for track_counter=1:track_intervals
        clear A;
        
        zmax=Arg((tracker_points*(track_counter)))*1e-3;
        zmin=Arg((tracker_points*(track_counter-1))+1)*1e-3;
    
        zaber_z = handles.zaber_z;
        [ret err] = ZaberMoveAbsolute(zaber_z, zaber_z.deviceIndex, zmin);
        handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
        
        ZaberSetMaximumPosition(zaber_z, zaber_z.deviceIndex, zmax);
        
        daq.StartTask('PulseTrain_magnet');
        daq.StartTask('Counter_magnet');
        
        ZaberMoveAtConstantSpeed(zaber_z, zaber_z.deviceIndex, speed);
        pause(time_move*1.1);
        
        A = daq.ReadCounterBuffer('Counter_magnet',tracker_points+1,10);
        daq.StopTask('Counter_magnet');
        daq.StopTask('PulseTrain_magnet');
        
        argData((tracker_points*(track_counter-1))+1:tracker_points*(track_counter)) = double(diff(A)/(time_move_per_point));
        
        plot(handles.magnet_axes,Arg,argData);
        axis(handles.magnet_axes,'square');
        xlabel(handles.magnet_axes,textxlabel);
        ylabel(handles.magnet_axes,textylabel);
        drawnow();
        
        ZaberSetMaximumPosition(zaber_z, zaber_z.deviceIndex,handles.defaultMax_z); %set back the maximum position

    end
% 1D scan X
elseif get(handles.check_scanx,'Value')==1 && get(handles.check_scanz,'Value')==0 && get(handles.check_scany,'Value')==0
    
    fp = getpref('nv','SavedExpDirectory');
    
    a = datestr(now,'yyyy-mm-dd-HHMMSS');
    fn=['magnet-1D-X-' a];
    filename=[fp '\' fn '.mat'];
    set(handles.magnet_file,'String',fn);
    
    textxlabel='x [mm]';textylabel='Counts [cps]';
    
    xmin = str2num(get(handles.scan_xmin, 'String'))*1e-3;
    xmax = str2num(get(handles.scan_xmax, 'String'))*1e-3;
    
    averages  = str2num(get(handles.magnet_average, 'String'));
    
    points = str2num(get(handles.points_x, 'String'));
    points=ceil(points/tracker_points)*tracker_points;
    set(handles.points_x, 'String',num2str(points));
    
    track_intervals=ceil(points/tracker_points);
    Arg=linspace(xmin*1e3,xmax*1e3,points);
    
    
    xmax=Arg(tracker_points)*1e-3;
    xmin=Arg(1)*1e-3;
    time_move = (xmax - xmin)/speed;
    time_move_per_point = time_move/(tracker_points+1);
    
    daq.ConfigureCounterIn('Counter_magnet',handles.Imaginghandles.ImagingFunctions.TrackerCounterInLine,handles.magnet_counter_line,tracker_points+1);
    daq.ConfigureClockOut('PulseTrain_magnet',handles.magnet_counter_line,1/time_move_per_point,0.5);
    
    zaber_x = handles.zaber_x;
    
    argDatamean=zeros(1,points);
    for av_ind=1:averages
        argData=ones(1,points)*NaN;
        
        for track_counter=1:track_intervals
            clear A;
            
            xmax=Arg((tracker_points*(track_counter)))*1e-3;
            xmin=Arg((tracker_points*(track_counter-1))+1)*1e-3;
            
            [ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, xmin);
            handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
            
            ZaberSetMaximumPosition(zaber_x, zaber_x.deviceIndex, xmax);
            
            daq.StartTask('PulseTrain_magnet');
            daq.StartTask('Counter_magnet');
            
            ZaberMoveAtConstantSpeed(zaber_x, zaber_x.deviceIndex, speed);
            pause(time_move*1.1);
            
            A = daq.ReadCounterBuffer('Counter_magnet',tracker_points+1,10);
            daq.StopTask('Counter_magnet');
            daq.StopTask('PulseTrain_magnet');
            
            argData((tracker_points*(track_counter-1))+1:tracker_points*(track_counter)) = double(diff(A)/(time_move_per_point));
            argDatamean((tracker_points*(track_counter-1))+1:tracker_points*(track_counter))=((argDatamean((tracker_points*(track_counter-1))+1:tracker_points*(track_counter)))*(av_ind-1)+ ...
                argData((tracker_points*(track_counter-1))+1:tracker_points*(track_counter)))/av_ind;
            
            
            plot(handles.magnet_axes,Arg,argDatamean,'-bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',5,'LineWidth',1); hold (handles.magnet_axes,'on');
            plot(handles.magnet_axes,Arg,smooth(argDatamean,5),'r-','LineWidth',2); hold (handles.magnet_axes,'off');
            
            axis(handles.magnet_axes,'square');
            xlabel(handles.magnet_axes,textxlabel);
            ylabel(handles.magnet_axes,textylabel);
            grid(handles.magnet_axes);
            title(handles.magnet_axes,fn);
            drawnow();
            
            ZaberSetMaximumPosition(zaber_x, zaber_x.deviceIndex,handles.defaultMax_x); %set back the maximum position
           % set(handles.magnet_status,'String',['Done averages (' num2str(av_ind) '/' num2str(averages) ')']);
            
        end
        set(handles.magnet_status,'String',['Done averages (' num2str(av_ind) '/' num2str(averages) ')']);
    end
    save(filename,'argDatamean','Arg','textxlabel','textylabel','averages','fn');
    send_email(fn,' ',filename);
% 1D scan Y
elseif get(handles.check_scany,'Value')==1 && get(handles.check_scanx,'Value')==0 && get(handles.check_scanz,'Value')==0
    
    fp = getpref('nv','SavedExpDirectory');
    a = datestr(now,'yyyy-mm-dd-HHMMSS');
    fn=['magnet-1D-Y-' a];
    filename=[fp '\' fn '.mat'];
    set(handles.magnet_file,'String',fn);
    
    textxlabel='y [mm]';textylabel='Counts [cps]';
    
    ymin = str2num(get(handles.scan_ymin, 'String'))*1e-3;
    ymax = str2num(get(handles.scan_ymax, 'String'))*1e-3;
    
    averages  = str2num(get(handles.magnet_average, 'String'));
    
    points = str2num(get(handles.points_y, 'String'));
    points=ceil(points/tracker_points)*tracker_points;
    set(handles.points_y, 'String',num2str(points));
    
    track_intervals=ceil(points/tracker_points);
    Arg=linspace(ymin*1e3,ymax*1e3,points);
    argData=ones(1,points)*NaN;
    
    ymax=Arg(tracker_points)*1e-3;
    ymin=Arg(1)*1e-3;
    time_move = (ymax - ymin)/speed;
    time_move_per_point = time_move/(tracker_points+1);
    
    daq.ConfigureCounterIn('Counter_magnet',handles.Imaginghandles.ImagingFunctions.TrackerCounterInLine,handles.magnet_counter_line,tracker_points+1);
    daq.ConfigureClockOut('PulseTrain_magnet',handles.magnet_counter_line,1/time_move_per_point,0.5);
    
     zaber_y = handles.zaber_y;
    argDatamean=zeros(1,points);
    
    for av_ind=1:averages
        argData=ones(1,points)*NaN;
        
        for track_counter=1:track_intervals
            clear A;
            
            ymax=Arg((tracker_points*(track_counter)))*1e-3;
            ymin=Arg((tracker_points*(track_counter-1))+1)*1e-3;
            
          
            [ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, ymin);
            handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
            
            ZaberSetMaximumPosition(zaber_y, zaber_y.deviceIndex, ymax);
            
            daq.StartTask('PulseTrain_magnet');
            daq.StartTask('Counter_magnet');
            
            ZaberMoveAtConstantSpeed(zaber_y, zaber_y.deviceIndex, speed);
            pause(time_move*1.1);
            
            A = daq.ReadCounterBuffer('Counter_magnet',tracker_points+1,10);
            daq.StopTask('Counter_magnet');
            daq.StopTask('PulseTrain_magnet');
            
            %argData((tracker_points*(track_counter-1))+1:tracker_points*(track_counter)) = double(diff(A)/(time_move_per_point));
            
            argData((tracker_points*(track_counter-1))+1:tracker_points*(track_counter)) = double(diff(A)/(time_move_per_point));
            argDatamean((tracker_points*(track_counter-1))+1:tracker_points*(track_counter))=((argDatamean((tracker_points*(track_counter-1))+1:tracker_points*(track_counter)))*(av_ind-1)+ ...
                argData((tracker_points*(track_counter-1))+1:tracker_points*(track_counter)))/av_ind;
            
            plot(handles.magnet_axes,Arg,argDatamean,'-bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',5,'LineWidth',1); hold (handles.magnet_axes,'on');
            plot(handles.magnet_axes,Arg,smooth(argDatamean,5),'r-','LineWidth',2); hold (handles.magnet_axes,'off');
            
            
            %plot(handles.magnet_axes,Arg,argData);
            axis(handles.magnet_axes,'square');
            xlabel(handles.magnet_axes,textxlabel);
            ylabel(handles.magnet_axes,textylabel);
            grid(handles.magnet_axes);
            title(handles.magnet_axes,fn);
            drawnow();
            
            ZaberSetMaximumPosition(zaber_y, zaber_y.deviceIndex,handles.defaultMax_y); %set back the maximum position
            %set(handles.magnet_status,'String',['Done averages (' num2str(av_ind) '/' num2str(averages) ')']);
        end
         set(handles.magnet_status,'String',['Done averages (' num2str(av_ind) '/' num2str(averages) ')']);
    end
    save(filename,'argDatamean','Arg','textxlabel','textylabel','averages','fn');
    send_email(fn,' ',filename);
% 2D scan XZ
elseif get(handles.check_scanz,'Value')==1 && get(handles.check_scanx,'Value')==1 && get(handles.check_scany,'Value')==0
    
    fp = getpref('nv','SavedExpDirectory');
    a = datestr(now,'yyyy-mm-dd-HHMMSS');
    fn=['magnet-2D-XZ-' a];
    filename=[fp '\' fn '.mat'];
    set(handles.magnet_file,'String',fn);

    textxlabel='x [mm]';textylabel='z [mm]';
    xmin = str2num(get(handles.scan_xmin, 'String'))*1e-3;
    xmax = str2num(get(handles.scan_xmax, 'String'))*1e-3;
    
    averages  = str2num(get(handles.magnet_average, 'String'));
    
    zmin = str2num(get(handles.scan_zmin, 'String'))*1e-3;
    zmax = str2num(get(handles.scan_zmax, 'String'))*1e-3;
    
    points_z = str2num(get(handles.points_z, 'String'));
    points_x = str2num(get(handles.points_x, 'String'));
    
    points_x=ceil(points_x/tracker_points)*tracker_points;
    set(handles.points_x, 'String',num2str(points_x));
    track_intervals=ceil(points_x/tracker_points);
    
    Arg_z=linspace(zmax*1e3,zmin*1e3,points_z); %scan backwards
    Arg_x=linspace(xmin*1e3,xmax*1e3,points_x);
    
    argData=ones(points_z,points_x)*NaN;
    argDatamean=ones(points_z,points_x)*NaN ;%so that it plots OK;
    
    imagesc(Arg_x,Arg_z,argData,'Parent',handles.magnet_axes);
    colormap(handles.magnet_axes,hot);
    set(handles.magnet_axes,'YDir','normal');
    daspect(handles.magnet_axes,[1 1 1]);
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_z) max(Arg_z)]);
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');
    grid(handles.magnet_axes);
    title(handles.magnet_axes,fn);
    drawnow();
    
    zaber_z = handles.zaber_z;
    zaber_x = handles.zaber_x;
    
    xmax=Arg_x(tracker_points)*1e-3;
    xmin=Arg_x(1)*1e-3;
    time_move = (xmax - xmin)/speed;
    time_move_per_point = time_move/(tracker_points+1);
    
    daq.ConfigureCounterIn('Counter_magnet',handles.Imaginghandles.ImagingFunctions.TrackerCounterInLine,handles.magnet_counter_line,tracker_points+1);
    daq.ConfigureClockOut('PulseTrain_magnet',handles.magnet_counter_line,1/time_move_per_point,0.5);
    
    % SCAN OVER X (sweep dimnesion), and crawl over Z
    for scan_ind=1:points_z
        [ret err] = ZaberMoveAbsolute(zaber_z, zaber_z.deviceIndex, Arg_z(scan_ind)*1e-3);
        cutoff=str2num(get(handles.magnet_cutoff, 'String'));
        argDatamean(scan_ind,:)=zeros(1,points_x); %to build the averages
        for av_ind=1:averages
            for track_counter=1:track_intervals
                clear A;
                
                xmax=Arg_x((tracker_points*(track_counter)))*1e-3;
                xmin=Arg_x((tracker_points*(track_counter-1))+1)*1e-3;
                
                [ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, xmin);
                handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
                
                %Multiple tracks
%                 if track_counter==1
%                     handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
%                 end
%                 
%                 if scan_ind==1 && track_counter==1
%                     handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
%                 end
                
                ZaberSetMaximumPosition(zaber_x, zaber_x.deviceIndex, xmax);
                
                daq.StartTask('PulseTrain_magnet');
                daq.StartTask('Counter_magnet');
                
                ZaberMoveAtConstantSpeed(zaber_x, zaber_x.deviceIndex, speed);
                pause(time_move*1.1);
                
                A = daq.ReadCounterBuffer('Counter_magnet',tracker_points+1,10);
                daq.StopTask('Counter_magnet');
                daq.StopTask('PulseTrain_magnet');
                
                argData(scan_ind,(tracker_points*(track_counter-1))+1:tracker_points*(track_counter)) = double(diff(A)/(time_move_per_point));
                argDatamean(scan_ind,(tracker_points*(track_counter-1))+1:tracker_points*(track_counter))=((argDatamean(scan_ind,(tracker_points*(track_counter-1))+1:tracker_points*(track_counter)))*(av_ind-1)+ ...
                    argData(scan_ind,(tracker_points*(track_counter-1))+1:tracker_points*(track_counter)))/av_ind;
                argData_disp=argDatamean;
                if cutoff~=0
                    argData_disp(argData_disp>cutoff)=cutoff;
                end
                
                
                imagesc(Arg_x,Arg_z,argData_disp,'Parent',handles.magnet_axes);
                colormap(handles.magnet_axes,hot);
                set(handles.magnet_axes,'YDir','normal');
                daspect(handles.magnet_axes,[1 1 1]);
                set(handles.magnet_axes,'ticklength',[0.02 0.02]);
                set(handles.magnet_axes,'tickdir','out');
                
                xlabel(handles.magnet_axes,textxlabel);
                ylabel(handles.magnet_axes,textylabel);
                set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_z) max(Arg_z)]);
                h = colorbar('peer',handles.magnet_axes,'EastOutside');
                set(get(h,'ylabel'),'String','cps');
                grid(handles.magnet_axes);
                title(handles.magnet_axes,fn);
                set(handles.magnet_axes,'layer','top');
                
                ZaberSetMaximumPosition(zaber_x, zaber_x.deviceIndex,handles.defaultMax_x); %set back the maximum position
                
            end
            %save(filename,'argData','Arg_x','Arg_z','textxlabel','textylabel');
            save(filename,'argDatamean','Arg_x','Arg_z','textxlabel','textylabel','averages','fn');
            set(handles.magnet_status,'String',['Done averages (' num2str(av_ind) '/' num2str(averages) ')']);
        end
        
    end
    refresh_magnet_Callback(hObject, eventdata,handles);
    imagesc(Arg_x,Arg_z,argData_disp,'Parent',handles.magnet_axes);
    colormap(handles.magnet_axes,hot);
    set(handles.magnet_axes,'YDir','normal');
    daspect(handles.magnet_axes,[1 1 1]);
    set(handles.magnet_axes,'ticklength',[0.02 0.02]);
    set(handles.magnet_axes,'tickdir','out');
    
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_z) max(Arg_z)]);
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');
    grid(handles.magnet_axes);
    title(handles.magnet_axes,fn);
    set(handles.magnet_axes,'layer','top');
    
    drawnow();
    %save(filename,'argData','Arg_x','Arg_z','textxlabel','textylabel');
    send_email(fn,' ',filename);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2D YZ scan
elseif get(handles.check_scanz,'Value')==1 && get(handles.check_scany,'Value')==1 && get(handles.check_scanx,'Value')==0
    
    fp = getpref('nv','SavedImageDirectory');
    fn=get(handles.magnet_file,'String');
    filename=[fp '\' fn '.mat'];

    textxlabel='y [mm]';textylabel='z [mm]';
    ymin = str2num(get(handles.scan_ymin, 'String'))*1e-3;
    ymax = str2num(get(handles.scan_ymax, 'String'))*1e-3;
    
    zmin = str2num(get(handles.scan_zmin, 'String'))*1e-3;
    zmax = str2num(get(handles.scan_zmax, 'String'))*1e-3;
    
    points_z = str2num(get(handles.points_z, 'String'));
    points_y = str2num(get(handles.points_y, 'String'));
    
    points_y=ceil(points_y/tracker_points)*tracker_points;
    set(handles.points_y, 'String',num2str(points_y));
    track_intervals=ceil(points_y/tracker_points);
    
    Arg_z=linspace(zmin*1e3,zmax*1e3,points_z);
    Arg_y=linspace(ymin*1e3,ymax*1e3,points_y);
    
    argData=ones(points_z,points_y)*NaN;
    
    imagesc(Arg_y,Arg_z,argData,'Parent',handles.magnet_axes);
    set(handles.magnet_axes,'YDir','normal');
    axis(handles.magnet_axes,'square');
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_y) max(Arg_y)], 'YLim',[min(Arg_z) max(Arg_z)]);
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');
    grid;
    drawnow();
    
    zaber_z = handles.zaber_z;
    zaber_y = handles.zaber_y;
    
    ymax=Arg_y(tracker_points)*1e-3;
    ymin=Arg_y(1)*1e-3;
    time_move = (ymax - ymin)/speed;
    time_move_per_point = time_move/(tracker_points+1);
    
    daq.ConfigureCounterIn('Counter_magnet',handles.Imaginghandles.ImagingFunctions.TrackerCounterInLine,handles.magnet_counter_line,tracker_points+1);
    daq.ConfigureClockOut('PulseTrain_magnet',handles.magnet_counter_line,1/time_move_per_point,0.5);
    
    % SCAN OVER Y (sweep dimnesion), and crawl over Z
    for scan_ind=1:points_z
        [ret err] = ZaberMoveAbsolute(zaber_z, zaber_z.deviceIndex, Arg_z(scan_ind)*1e-3);
        cutoff=str2num(get(handles.magnet_cutoff, 'String'));
        for track_counter=1:track_intervals
            clear A;
            
            ymax=Arg_y((tracker_points*(track_counter)))*1e-3;
            ymin=Arg_y((tracker_points*(track_counter-1))+1)*1e-3;
            
            [ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, ymin);
            handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
            
            ZaberSetMaximumPosition(zaber_y, zaber_y.deviceIndex, ymax);
            
            daq.StartTask('PulseTrain_magnet');
            daq.StartTask('Counter_magnet');
            
            ZaberMoveAtConstantSpeed(zaber_y, zaber_y.deviceIndex, speed);
            pause(time_move*1.1);
            
            A = daq.ReadCounterBuffer('Counter_magnet',tracker_points+1,10);
            daq.StopTask('Counter_magnet');
            daq.StopTask('PulseTrain_magnet');
            
            argData(scan_ind,(tracker_points*(track_counter-1))+1:tracker_points*(track_counter)) = double(diff(A)/(time_move_per_point));
            argData_disp=argData;
            if cutoff~=0
            argData_disp(argData_disp>cutoff)=cutoff;
            end
            
            imagesc(Arg_y,Arg_z,argData_disp,'Parent',handles.magnet_axes);
            set(handles.magnet_axes,'YDir','normal');
            axis(handles.magnet_axes,'square');
            xlabel(handles.magnet_axes,textxlabel);
            ylabel(handles.magnet_axes,textylabel);
            set(handles.magnet_axes, 'XLim',[min(Arg_y) max(Arg_y)], 'YLim',[min(Arg_z) max(Arg_z)]);
            h = colorbar('peer',handles.magnet_axes,'EastOutside');
            set(get(h,'ylabel'),'String','cps');
            grid;
            drawnow();
        
            ZaberSetMaximumPosition(zaber_y, zaber_y.deviceIndex,handles.defaultMax_y); %set back the maximum position
            
        end
        save(filename,'argData','Arg_y','Arg_z','textxlabel','textylabel');
    end
    refresh_magnet_Callback(hObject, eventdata,handles);
    imagesc(Arg_y,Arg_z,argData_disp,'Parent',handles.magnet_axes);
    set(handles.magnet_axes,'YDir','normal');
    axis(handles.magnet_axes,'square');
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_y) max(Arg_y)], 'YLim',[min(Arg_z) max(Arg_z)]);
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');
    grid;
    drawnow();
    save(filename,'argData','Arg_y','Arg_z','textxlabel','textylabel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2D XY scan    
elseif get(handles.check_scanz,'Value')==0 && get(handles.check_scanx,'Value')==1 && get(handles.check_scany,'Value')==1    
    
    fp = getpref('nv','SavedExpDirectory');
    
    a = datestr(now,'yyyy-mm-dd-HHMMSS');
    fn=['magnet-2D-XY-' a];
    filename=[fp '\' fn '.mat'];
    set(handles.magnet_file,'String',fn);
   
    textxlabel='x [mm]';textylabel='y [mm]';
    xmin = str2num(get(handles.scan_xmin, 'String'))*1e-3;
    xmax = str2num(get(handles.scan_xmax, 'String'))*1e-3;
    
     averages  = str2num(get(handles.magnet_average, 'String'));
     
    ymin = str2num(get(handles.scan_ymin, 'String'))*1e-3;
    ymax = str2num(get(handles.scan_ymax, 'String'))*1e-3;
    
    points_y = str2num(get(handles.points_y, 'String'));
    points_x = str2num(get(handles.points_x, 'String'));
    
    points_x=ceil(points_x/tracker_points)*tracker_points;
    set(handles.points_x, 'String',num2str(points_x));
    track_intervals=ceil(points_x/tracker_points);
    
    Arg_y=linspace(ymin*1e3,ymax*1e3,points_y);
    Arg_x=linspace(xmin*1e3,xmax*1e3,points_x);
    
    argData=ones(points_y,points_x)*NaN;
    argDatamean=ones(points_y,points_x)*NaN ;%so that it plots OK;
    
    imagesc(Arg_x,Arg_y,argData,'Parent',handles.magnet_axes);
    colormap(hot);
    set(handles.magnet_axes,'YDir','normal');
    set(handles.magnet_axes,'ticklength',[0.02 0.02]);
    set(handles.magnet_axes,'tickdir','out');
    daspect(handles.magnet_axes,[1 1 1]);
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_y) max(Arg_y)]);
    grid(handles.magnet_axes);
    title(handles.magnet_axes,fn);
    set(handles.magnet_axes,'layer','top');
    
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');

    drawnow();
    
    zaber_y = handles.zaber_y;
    zaber_x = handles.zaber_x;
       
    xmax=Arg_x(tracker_points)*1e-3;
    xmin=Arg_x(1)*1e-3;
    time_move = (xmax - xmin)/speed;
    time_move_per_point = time_move/(tracker_points+1)
    
    daq.ConfigureCounterIn('Counter_magnet',handles.Imaginghandles.ImagingFunctions.TrackerCounterInLine,handles.magnet_counter_line,tracker_points+1);
    daq.ConfigureClockOut('PulseTrain_magnet',handles.magnet_counter_line,1/time_move_per_point,0.5);
    
    % SCAN OVER X (sweep dimnesion), and crawl over Y
    for scan_ind=1:points_y
        [ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, Arg_y(scan_ind)*1e-3);
        cutoff=str2num(get(handles.magnet_cutoff, 'String'));
         argDatamean(scan_ind,:)=zeros(1,points_x); %to build the averages
        for av_ind=1:averages
        for track_counter=1:track_intervals
            clear A;
            
            xmax=Arg_x((tracker_points*(track_counter)))*1e-3;
            xmin=Arg_x((tracker_points*(track_counter-1))+1)*1e-3;
            
            [ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, xmin);
            handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
            
%             if track_counter==1
%                 handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
%             end    
            
            ZaberSetMaximumPosition(zaber_x, zaber_x.deviceIndex, xmax);
            
            daq.StartTask('PulseTrain_magnet');
            daq.StartTask('Counter_magnet');
            
            ZaberMoveAtConstantSpeed(zaber_x, zaber_x.deviceIndex, speed);
            pause(time_move*1.1);
            
            A = daq.ReadCounterBuffer('Counter_magnet',tracker_points+1,10);
            daq.StopTask('Counter_magnet');
            daq.StopTask('PulseTrain_magnet');
            
            argData(scan_ind,(tracker_points*(track_counter-1))+1:tracker_points*(track_counter)) = double(diff(A)/(time_move_per_point));
            argDatamean(scan_ind,(tracker_points*(track_counter-1))+1:tracker_points*(track_counter))=((argDatamean(scan_ind,(tracker_points*(track_counter-1))+1:tracker_points*(track_counter)))*(av_ind-1)+ ...
                    argData(scan_ind,(tracker_points*(track_counter-1))+1:tracker_points*(track_counter)))/av_ind;
            argData_disp=argDatamean;
                
            %argData_disp=argData;
            if cutoff~=0
            argData_disp(argData_disp>cutoff)=cutoff;
            end
            
            imagesc(Arg_x,Arg_y,argData_disp,'Parent',handles.magnet_axes);
            colormap(handles.magnet_axes,hot);
            set(handles.magnet_axes,'YDir','normal');
            daspect(handles.magnet_axes,[1 1 1]);
            set(handles.magnet_axes,'ticklength',[0.02 0.02]);
            set(handles.magnet_axes,'tickdir','out');
            xlabel(handles.magnet_axes,textxlabel);
            ylabel(handles.magnet_axes,textylabel);
            set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_y) max(Arg_y)]);
            h = colorbar('peer',handles.magnet_axes,'EastOutside');
            set(get(h,'ylabel'),'String','cps');
            grid(handles.magnet_axes);
             title(handles.magnet_axes,fn);
            set(handles.magnet_axes,'layer','top');
            drawnow();
            
            ZaberSetMaximumPosition(zaber_x, zaber_x.deviceIndex,handles.defaultMax_x); %set back the maximum position
            
        end
        save(filename,'argDatamean','Arg_x','Arg_y','textxlabel','textylabel','averages','fn');
         set(handles.magnet_status,'String',['Done averages (' num2str(av_ind) '/' num2str(averages) ')']);
        end
    end
    refresh_magnet_Callback(hObject, eventdata,handles);
    imagesc(Arg_x,Arg_y,argData_disp,'Parent',handles.magnet_axes);
    colormap(handles.magnet_axes,hot);
    set(handles.magnet_axes,'YDir','normal');
    daspect(handles.magnet_axes,[1 1 1]);
    set(handles.magnet_axes,'ticklength',[0.02 0.02]);
    set(handles.magnet_axes,'tickdir','out');
    
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_y) max(Arg_y)]);
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');
    grid(handles.magnet_axes);
    title(handles.magnet_axes,fn);
    set(handles.magnet_axes,'layer','top');
    
    drawnow();
    %save(filename,'argData','Arg_x','Arg_y','textxlabel','textylabel');
    send_email(fn,' ',filename);
end

daq.ClearTask('Counter_magnet');
daq.ClearTask('PulseTrain_magnet');

refresh_magnet_Callback(hObject, eventdata,handles);






% --- Executes on button press in check_scanz.
function check_scanz_Callback(hObject, eventdata, handles)
% hObject    handle to check_scanz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_scanz



function scan_zmax_Callback(hObject, eventdata, handles)
% hObject    handle to scan_zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scan_zmax as text
%        str2double(get(hObject,'String')) returns contents of scan_zmax as a double
zmax = str2num(get(handles.scan_zmax, 'String'))*1e-3;
if(zmax > handles.defaultMax_z)
    set(handles.scan_zmax, 'String', num2str(handles.defaultMax_z*1e3));
end


% --- Executes during object creation, after setting all properties.
function scan_zmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scan_zmin_Callback(hObject, eventdata, handles)
% hObject    handle to scan_zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scan_zmin as text
%        str2double(get(hObject,'String')) returns contents of scan_zmin as a double


% --- Executes during object creation, after setting all properties.
function scan_zmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function points_z_Callback(hObject, eventdata, handles)
% hObject    handle to points_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of points_z as text
%        str2double(get(hObject,'String')) returns contents of points_z as a double


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


% --- Executes on button press in check_scany.
function check_scany_Callback(hObject, eventdata, handles)
% hObject    handle to check_scany (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_scany



function scan_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to scan_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scan_ymax as text
%        str2double(get(hObject,'String')) returns contents of scan_ymax as a double
ymax = str2num(get(handles.scan_ymax, 'String'))*1e-3;
if(ymax > handles.defaultMax_y)
    set(handles.scan_ymax, 'String', num2str(handles.defaultMax_y*1e3));
end


% --- Executes during object creation, after setting all properties.
function scan_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scan_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to scan_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scan_ymin as text
%        str2double(get(hObject,'String')) returns contents of scan_ymin as a double


% --- Executes during object creation, after setting all properties.
function scan_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function points_y_Callback(hObject, eventdata, handles)
% hObject    handle to points_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of points_y as text
%        str2double(get(hObject,'String')) returns contents of points_y as a double


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


% --- Executes on button press in check_scanx.
function check_scanx_Callback(hObject, eventdata, handles)
% hObject    handle to check_scanx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_scanx



function points_x_Callback(hObject, eventdata, handles)
% hObject    handle to points_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of points_x as text
%        str2double(get(hObject,'String')) returns contents of points_x as a double


% --- Executes during object creation, after setting all properties.
function points_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to points_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scan_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to scan_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scan_xmax as text
%        str2double(get(hObject,'String')) returns contents of scan_xmax as a double
xmax = str2num(get(handles.scan_xmax, 'String'))*1e-3;
if(xmax > handles.defaultMax_x)
    set(handles.scan_xmax, 'String', num2str(handles.defaultMax_x*1e3));
end


% --- Executes during object creation, after setting all properties.
function scan_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scan_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to scan_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scan_xmin as text
%        str2double(get(hObject,'String')) returns contents of scan_xmin as a double


% --- Executes during object creation, after setting all properties.
function scan_xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in magnet_stop.
function magnet_stop_Callback(hObject, eventdata, handles)
% Stop the individual motors
ZaberStop(handles.zaber_x, handles.zaber_x.deviceIndex);
ZaberStop(handles.zaber_y, handles.zaber_y.deviceIndex);
ZaberStop(handles.zaber_z, handles.zaber_z.deviceIndex);
daq=handles.Imaginghandles.ImagingFunctions.interfaceDataAcq;
daq.ClearTask('Counter_magnet');
daq.ClearTask('PulseTrain_magnet');


function track_point_Callback(hObject, eventdata, handles)
% hObject    handle to track_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of track_point as text
%        str2double(get(hObject,'String')) returns contents of track_point as a double


% --- Executes during object creation, after setting all properties.
function track_point_CreateFcn(hObject, eventdata, handles)
% hObject    handle to track_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function magnet_cutoff_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of magnet_cutoff as text
%        str2double(get(hObject,'String')) returns contents of magnet_cutoff as a double


% --- Executes during object creation, after setting all properties.
function magnet_cutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnet_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function magnet_file_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of magnet_file as text
%        str2double(get(hObject,'String')) returns contents of magnet_file as a double


% --- Executes during object creation, after setting all properties.
function magnet_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnet_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in magnet_load.
function magnet_load_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fp = getpref('nv','SavedExpDirectory');
handles.Arg_x=[];handles.Arg_y=[];handles.Arg_z=[];handles.file=[];
[file] = uigetfile('*.mat', 'Choose existing sequence file to load',fp);
load(file);
handles.file=file;

%clf(handles.magnet_axes);

% for XZ
if exist('Arg_x','var') && exist('Arg_z','var')
    imagesc(Arg_x,Arg_z,argDatamean,'Parent',handles.magnet_axes);
%     pcolor(handles.magnet_axes,Arg_x,Arg_z,argData);
%    shading interp;
    colormap(hot);
    
    set(handles.magnet_axes,'YDir','normal');
    set(handles.magnet_axes,'ticklength',[0.02 0.02]);
    set(handles.magnet_axes,'tickdir','out');
    
    daspect(handles.magnet_axes,[1 1 1]);
    
    %axis(handles.magnet_axes,'square');
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_z) max(Arg_z)]);
    
    grid(handles.magnet_axes);
    set(handles.magnet_axes,'layer','top');
    
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');
    title(handles.magnet_axes,file);
    drawnow();
    handles.argData_loaded=argDatamean;
    handles.Arg_x=Arg_x;handles.Arg_z=Arg_z;
    handles.textxlabel=textxlabel;handles.textylabel=textylabel;
%for YZ
elseif exist('Arg_y','var') && exist('Arg_z','var')
    %imagesc(Arg_y,Arg_z,argData,'Parent',handles.magnet_axes);
    pcolor(handles.magnet_axes,Arg_y,Arg_z,argData);
    shading interp;
    colormap(hot);
    
    set(handles.magnet_axes,'YDir','normal');
    set(handles.magnet_axes,'ticklength',[0.02 0.02]);
    set(handles.magnet_axes,'tickdir','out');
    
     daspect([1 1 1]);
    
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_y) max(Arg_y)], 'YLim',[min(Arg_z) max(Arg_z)]);
    
     grid on;
    set(handles.magnet_axes,'layer','top');
    
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');
    title(file);
    drawnow();
    handles.argData_loaded=argData;
    handles.Arg_y=Arg_y;handles.Arg_z=Arg_z;
    handles.textxlabel=textxlabel;handles.textylabel=textylabel;
%for XY
elseif exist('Arg_x','var') && exist('Arg_y','var')
    imagesc(Arg_x,Arg_y,argDatamean,'Parent',handles.magnet_axes);
    %argData(isnan(argData)) = 10e3;
    %pcolor(handles.magnet_axes,Arg_x,Arg_y,argData);
    %shading interp;
    colormap(hot);
    
    set(handles.magnet_axes,'YDir','normal');
    set(handles.magnet_axes,'ticklength',[0.02 0.02]);
    set(handles.magnet_axes,'tickdir','out');
    
     daspect(handles.magnet_axes,[1 1 1]);
     
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_y) max(Arg_y)]);
    
        grid(handles.magnet_axes);
    set(handles.magnet_axes,'layer','top');
    
    
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');

    title(handles.magnet_axes,file);
    drawnow();
    handles.argData_loaded=argDatamean;
    handles.Arg_x=Arg_x;handles.Arg_y=Arg_y;
    handles.textxlabel=textxlabel;handles.textylabel=textylabel;
    
% 1D scans    
elseif exist('Arg','var') 
    plot(handles.magnet_axes,Arg,argDatamean,'-bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',5,'LineWidth',1); hold (handles.magnet_axes,'on');
    plot(handles.magnet_axes,Arg,smooth(argDatamean,5),'r-','LineWidth',2); hold (handles.magnet_axes,'off');
    
    axis(handles.magnet_axes,'square');
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    grid(handles.magnet_axes);
    title(handles.magnet_axes,fn);
    drawnow();
    
end

guidata(hObject, handles);


% --- Executes on button press in magnet_setcutoff.
function magnet_setcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_setcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
argData_disp=handles.argData_loaded;
Arg_x=handles.Arg_x;Arg_z=handles.Arg_z;Arg_y=handles.Arg_y;

% for XZ
if isempty(Arg_x)==0 && isempty(Arg_z)==0 

textxlabel=handles.textxlabel;textylabel=handles.textylabel;
cutoff=str2num(get(handles.magnet_cutoff, 'String'));
if cutoff~=0
    argData_disp(argData_disp>cutoff)=cutoff;
end

imagesc(Arg_x,Arg_z,argData_disp,'Parent',handles.magnet_axes);
%clf(handles.magnet_axes,'reset');
% pcolor(handles.magnet_axes,Arg_x,Arg_z,argData_disp);
% shading interp;
colormap(hot);
set(handles.magnet_axes,'YDir','normal');
set(handles.magnet_axes,'ticklength',[0.02 0.02]);
set(handles.magnet_axes,'tickdir','out');
daspect (handles.magnet_axes,[1 1 1]);
%axis(handles.magnet_axes,'square');
xlabel(handles.magnet_axes,textxlabel);
ylabel(handles.magnet_axes,textylabel);
set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_z) max(Arg_z)]);

grid(handles.magnet_axes);
set(handles.magnet_axes,'layer','top');

h = colorbar('peer',handles.magnet_axes,'EastOutside');
set(get(h,'ylabel'),'String','cps');

title(handles.file);
drawnow();
% for YZ
elseif isempty(Arg_y)==0 && isempty(Arg_z)==0 

textxlabel=handles.textxlabel;textylabel=handles.textylabel;
cutoff=str2num(get(handles.magnet_cutoff, 'String'));
if cutoff~=0
    argData_disp(argData_disp>cutoff)=cutoff;
end

pcolor(handles.magnet_axes,Arg_y,Arg_z,argData_disp);
%imagesc(Arg_y,Arg_z,argData_disp,'Parent',handles.magnet_axes);
shading interp;
colormap(hot);
set(handles.magnet_axes,'YDir','normal');
set(handles.magnet_axes,'ticklength',[0.02 0.02]);
set(handles.magnet_axes,'tickdir','out');
daspect ([1 1 1]);

xlabel(handles.magnet_axes,textxlabel);
ylabel(handles.magnet_axes,textylabel);
set(handles.magnet_axes, 'XLim',[min(Arg_y) max(Arg_y)], 'YLim',[min(Arg_z) max(Arg_z)]);

grid on;
set(handles.magnet_axes,'layer','top');

h = colorbar('peer',handles.magnet_axes,'EastOutside');
set(get(h,'ylabel'),'String','cps');

title(handles.file);
drawnow();

% for XY
elseif isempty(Arg_x)==0 && isempty(Arg_y)==0 

textxlabel=handles.textxlabel;textylabel=handles.textylabel;
cutoff=str2num(get(handles.magnet_cutoff, 'String'));
if cutoff~=0
    argData_disp(argData_disp>cutoff)=cutoff;
end

imagesc(Arg_x,Arg_y,argData_disp,'Parent',handles.magnet_axes);
%pcolor(handles.magnet_axes,Arg_x,Arg_y,argData_disp);
%shading interp;

colormap(hot);
set(handles.magnet_axes,'YDir','normal');
set(handles.magnet_axes,'ticklength',[0.02 0.02]);
set(handles.magnet_axes,'tickdir','out');
daspect (handles.magnet_axes,[1 1 1]);

xlabel(handles.magnet_axes,textxlabel);
ylabel(handles.magnet_axes,textylabel);
set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_y) max(Arg_y)]);

grid (handles.magnet_axes);
set(handles.magnet_axes,'layer','top');

h = colorbar('peer',handles.magnet_axes,'EastOutside');
set(get(h,'ylabel'),'String','cps');

title(handles.magnet_axes,handles.file);
drawnow();

end


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

argData_disp=handles.argData_loaded;
Arg_x=handles.Arg_x;Arg_z=handles.Arg_z;Arg_y=handles.Arg_y;



% for XZ
if isempty(Arg_x)==0 && isempty(Arg_z)==0
    opengl software
    textxlabel=handles.textxlabel;textylabel=handles.textylabel;
    cutoff=str2num(get(handles.magnet_cutoff, 'String'));
    if cutoff~=0
        argData_disp(argData_disp>cutoff)=cutoff;
    end
    
    Range_z=size(Arg_z,2);
    [v,b]=max(handles.argData_loaded,[],2);
    for j=1:size(b,1)
        maxline(j)=Arg_x(b(j));
    end
    
  imagesc(Arg_x,Arg_z,argData_disp,'Parent',handles.magnet_axes);   hold(handles.magnet_axes,'on');
%      pcolor(handles.magnet_axes,Arg_x,Arg_z,argData_disp);hold on;
%      shading interp;
    colormap(hot);
   scatter(handles.magnet_axes,maxline,Arg_z);
    hold(handles.magnet_axes,'on');
    s=smooth(maxline,0.5,'rloess');
    plot(handles.magnet_axes,s,Arg_z,'b-','linewidth',2);  hold(handles.magnet_axes,'off');
  
    
    set(handles.magnet_axes,'YDir','normal');
    set(handles.magnet_axes,'ticklength',[0.02 0.02]);
    set(handles.magnet_axes,'tickdir','out');
    daspect (handles.magnet_axes,[1 1 1]);
    %axis(handles.magnet_axes,'square');
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_z) max(Arg_z)]);
    
    
    
    grid(handles.magnet_axes);
    set(handles.magnet_axes,'layer','top');
    
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');
    
    title(handles.file);
    drawnow();
    
    handles.magnet_line=s;
    % for YZ
elseif isempty(Arg_y)==0 && isempty(Arg_z)==0
    
    textxlabel=handles.textxlabel;textylabel=handles.textylabel;
    cutoff=str2num(get(handles.magnet_cutoff, 'String'));
    if cutoff~=0
        argData_disp(argData_disp>cutoff)=cutoff;
    end
    
    pcolor(handles.magnet_axes,Arg_y,Arg_z,argData_disp);
    %imagesc(Arg_y,Arg_z,argData_disp,'Parent',handles.magnet_axes);
    shading interp;
    colormap(hot);
    set(handles.magnet_axes,'YDir','normal');
    set(handles.magnet_axes,'ticklength',[0.02 0.02]);
    set(handles.magnet_axes,'tickdir','out');
    daspect ([1 1 1]);
    
    xlabel(handles.magnet_axes,textxlabel);
    ylabel(handles.magnet_axes,textylabel);
    set(handles.magnet_axes, 'XLim',[min(Arg_y) max(Arg_y)], 'YLim',[min(Arg_z) max(Arg_z)]);
    
    grid on;
    set(handles.magnet_axes,'layer','top');
    
    h = colorbar('peer',handles.magnet_axes,'EastOutside');
    set(get(h,'ylabel'),'String','cps');
    
    title(handles.file);
    drawnow();
end

guidata(hObject, handles);



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

argData_disp=handles.argData_loaded;
Arg_x=handles.Arg_x;Arg_z=handles.Arg_z;Arg_y=handles.Arg_y;
z_val=str2num(get(handles.edit24,'String'));

x_val=handles.magnet_line(z_val);
set(handles.edit22,'String',num2str(x_val));

set(handles.Pos_x,'String',num2str(x_val));
move_x_Callback(hObject, eventdata, handles)

set(handles.Pos_z,'String',num2str(Arg_z(z_val)));
move_z_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% --- Executes on button press in magnet_odmr.
function magnet_odmr_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_odmr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


gobj = findall(0,'Name','Imaging');
handles.Imaginghandles = guidata(gobj);

gobj = findall(0,'Name','Experiment');
handles.Experimenthandles = guidata(gobj);


xmin = str2num(get(handles.scan_xmin, 'String'))*1e-3;
xmax = str2num(get(handles.scan_xmax, 'String'))*1e-3;

ymin = str2num(get(handles.scan_ymin, 'String'))*1e-3;
ymax = str2num(get(handles.scan_ymax, 'String'))*1e-3;

points_y = str2num(get(handles.points_y, 'String'));
points_x = str2num(get(handles.points_x, 'String'));


Arg_y=linspace(ymin*1e3,ymax*1e3,points_y);
Arg_x=linspace(xmin*1e3,xmax*1e3,points_x);

contrast=zeros(points_x,points_y);
freq=zeros(points_x,points_y);

textxlabel='x [mm]'; textylabel='y [mm]';

zaber_y = handles.zaber_y;
zaber_x = handles.zaber_x;


fp = getpref('nv','SavedImageDirectory');
fn=get(handles.magnet_contrast_file,'String');
filename=[fp '\' fn '.mat'];

for odmr_y=1:points_y
    [ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, Arg_x(1)*1e-3);
    [ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, Arg_y(odmr_y)*1e-3);
    
   
    %TURN ON LASER
    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_CONTINUE,...
        0, 750,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_BRANCH,...
        0, 150,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart();
    set(handles.Imaginghandles.toggle_LaserOnOff,'String','Laser On');
    set(handles.Imaginghandles.toggle_LaserOnOff,'ForegroundColor',[0.847 0.161 0]);
    
    refresh_magnet_Callback(hObject, eventdata,handles);
    
    %TRACK
    handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
    for odmr_x=1:points_x
        [ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, Arg_x(odmr_x)*1e-3);
         refresh_magnet_Callback(hObject, eventdata,handles);

         %pcolor(handles.magnet_contrast,Arg_x,Arg_y,contrast);
         imagesc(Arg_x,Arg_y,contrast','Parent',handles.magnet_contrast);
        % shading (handles.magnet_contrast,'interp');
         colormap(handles.magnet_contrast,hot);
         set(handles.magnet_contrast,'YDir','normal');
         daspect(handles.magnet_contrast,[1 1 1]);
         set(handles.magnet_contrast,'ticklength',[0.02 0.02]);
         set(handles.magnet_contrast,'tickdir','out');
         xlabel(handles.magnet_contrast,textxlabel);
         ylabel(handles.magnet_contrast,textylabel);
         axis(handles.magnet_contrast,[min(Arg_x), max(Arg_x), min(Arg_y), max(Arg_y)]);
         grid(handles.magnet_contrast);
         set(handles.magnet_contrast,'layer','top');
         set(handles.magnet_contrast,'LineWidth',2);
         h = colorbar('peer',handles.magnet_contrast,'EastOutside');
         set(get(h,'ylabel'),'String','Contrast');
         title(handles.magnet_contrast,fn);
         
         %pcolor(handles.magnet_freq,Arg_x,Arg_y,freq);
        % shading (handles.magnet_freq,'interp');
        imagesc(Arg_x,Arg_y,freq','Parent',handles.magnet_freq);
         colormap(handles.magnet_freq,hot);
         set(handles.magnet_freq,'YDir','normal');
         daspect(handles.magnet_freq,[1 1 1]);
         set(handles.magnet_freq,'ticklength',[0.02 0.02]);
         set(handles.magnet_freq,'tickdir','out');
         xlabel(handles.magnet_freq,textxlabel);
         ylabel(handles.magnet_freq,textylabel);
         axis(handles.magnet_freq,[min(Arg_x), max(Arg_x), min(Arg_y), max(Arg_y)]);
         grid(handles.magnet_freq);
         set(handles.magnet_freq,'layer','top');
         set(handles.magnet_freq,'LineWidth',2);
         h = colorbar('peer',handles.magnet_freq,'EastOutside');
         set(get(h,'ylabel'),'String','Frequency');
         title(handles.magnet_freq,fn);
         
         drawnow();

         % RUN the experiment
         clear Rise1 yData xData coeffs x y pbest out
         handles.Experimenthandles.ExperimentFinished=0;
         handles.Experimenthandles.ExperimentFunctions.RunExperiment(handles.Experimenthandles);
         
         
         
         % Now get the experiment data
         exps = get(handles.Experimenthandles.popup_experiments,'String');
         selectedExp= exps{get(handles.Experimenthandles.popup_experiments,'Value')+1};
         fp = getpref('nv','SavedExpDirectory');
         SavedExp = load(fullfile(fp,selectedExp));
         handles.ExperimentalScanDisplayed = SavedExp.Scan;
         scan=handles.ExperimentalScanDisplayed;
         sliderValue=1;
         
         

         
         Rise1=scan.ExperimentData{1}{1};
         avg=size(scan.ExperimentDataEachAvg{1});
         if isempty(scan.nonlinear_data)
             x=scan.vary_begin:scan.vary_step_size:scan.vary_end;
         else
             x=scan.nonlinear_data.x;
         end
         
         % Now do the fitting -- from Clarice         
%          yData=Rise1;
%          threshold=0.5;
%          yOffset = median(yData);
%          yData = yData - median(yData);
%          yAmplitude = max(abs(yData));
%          ySign = sign(max(yData) + min(yData));
%          
%          xData = linspace(1, 10, size(yData,2));
%          
%          sample = find(abs(yData) > threshold*yAmplitude);
%          sampleStart = max(min(sample) - 5, 1);
%          sampleEnd = min(max(sample) + 5, length(xData));
%          
%          yDataMod = yData(sampleStart:sampleEnd);
%          xDataMod = xData(sampleStart:sampleEnd);
%          
%          [coeffs,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(xDataMod, yDataMod, @modelLorentzian, [median(xDataMod), 1, median(yDataMod)]);
%          yModel =modelLorentzian(coeffs, xData);
%          yModel = yModel + yOffset;
%          
%          coeffsPr = [0 0 0];
%          coeffsPr(1) = ((coeffs(1) - 1)/9)*(x(end) - x(1)) + x(1);
%          coeffsPr(2) = 9*coeffs(2)/(x(end) - x(1));
%          coeffsPr(3) = coeffs(3);
%          
%          freq(odmr_x,odmr_y)=coeffsPr(1);
%          contrast(odmr_x,odmr_y)=100*(max(yModel)-min(yModel))/max(yModel);
         
         
          % Now do the fitting -- from Masashi
%          f=mean(x);
%          y=Rise1;
%          myfun =@(c,x) -c(4).*(x-x(1))+c(5)- c(1)./2./(1+((x-c(2))/c(3)).^2);
%          
%          cont=y(1)-min(y);
%          drift=(y(1)-y(end))./(x(end)-x(1));
%          pinit=[cont,f,0.5e6,drift,y(1)];
%          LB=[cont*0.5,f*0.99,0.1e3,drift*0.5,y(1)*0.9];
%          UB=[cont*3,f*1.01,1e6*11,drift*1.5,y(1)*1.9];
%          [pbest,delta_p]=easyfit(x, y, pinit, myfun, LB, UB);
%          dip=min(myfun(pbest,x));
%          contrast(odmr_x,odmr_y)=100*(pbest(5)-dip)/(pbest(5))
%          freq(odmr_x,odmr_y)=pbest(2)

        % Now do the fitting -- from Ulf
        y=Rise1;
        out=fit_Lorentzian(x,y);
        freq(odmr_x,odmr_y)=out(4);
        contrast(odmr_x,odmr_y)=-100*out(1)/(pi*out(3));
        save(filename,'freq','contrast','Arg_x','Arg_y','textxlabel','textylabel');
        
    end
    contrast
end
imagesc(Arg_x,Arg_y,contrast','Parent',handles.magnet_contrast);
colormap(handles.magnet_contrast,hot);
set(handles.magnet_contrast,'YDir','normal');
daspect(handles.magnet_contrast,[1 1 1]);
set(handles.magnet_contrast,'ticklength',[0.02 0.02]);
set(handles.magnet_contrast,'tickdir','out');
xlabel(handles.magnet_contrast,textxlabel);
ylabel(handles.magnet_contrast,textylabel);
axis(handles.magnet_contrast,[min(Arg_x), max(Arg_x), min(Arg_y), max(Arg_y)]);
grid(handles.magnet_contrast);
set(handles.magnet_contrast,'layer','top');
set(handles.magnet_contrast,'LineWidth',2);
h = colorbar('peer',handles.magnet_contrast,'EastOutside');
set(get(h,'ylabel'),'String','Contrast');
title(handles.magnet_contrast,fn);

imagesc(Arg_x,Arg_y,freq','Parent',handles.magnet_freq);
colormap(handles.magnet_freq,hot);
set(handles.magnet_freq,'YDir','normal');
daspect(handles.magnet_freq,[1 1 1]);
set(handles.magnet_freq,'ticklength',[0.02 0.02]);
set(handles.magnet_freq,'tickdir','out');
xlabel(handles.magnet_freq,textxlabel);
ylabel(handles.magnet_freq,textylabel);
axis(handles.magnet_freq,[min(Arg_x), max(Arg_x), min(Arg_y), max(Arg_y)]);
grid(handles.magnet_freq);
set(handles.magnet_freq,'layer','top');
set(handles.magnet_freq,'LineWidth',2);
h = colorbar('peer',handles.magnet_freq,'EastOutside');
set(get(h,'ylabel'),'String','Frequency');
title(handles.magnet_freq,fn);

drawnow();

% %% Now plot separately
% figH=2;clf;
% set(figH, 'color', 'white');
% plot(x,Rise1,'.b-','MarkerSize',15,'LineWidth',1);
% hold on;
% xlabel(scan.vary_prop{1});
% ylabel('kcps');
% title([scan.SequenceName ' ' scan.DateTime]);
% grid(figH);
% plot(x,yModel,'r-','linewidth',2);
% 
% drawnow();
% WinOnTop(figH, true);


guidata(hObject, handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
s_x = serial('com3');
s_y=  serial('com4');
s_rot=  serial('com6');
s_z=  serial('com5');

ZaberClose(handles.zaber_x);
ZaberClose(handles.zaber_y);
ZaberClose(handles.zaber_rot);
ZaberClose(handles.zaber_z);

delete(hObject);


% --- Executes on button press in magnet_contrast_load.
function magnet_contrast_load_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_contrast_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fp = getpref('nv','SavedImageDirectory');
handles.Arg_x=[];handles.Arg_y=[];handles.Arg_z=[];handles.file=[];
[file] = uigetfile('*.mat', 'Choose existing sequence file to load',fp);
load(file);
handles.file=file;

imagesc(Arg_x,Arg_y,contrast','Parent',handles.magnet_contrast);
colormap(handles.magnet_contrast,hot);
set(handles.magnet_contrast,'YDir','normal');
daspect(handles.magnet_contrast,[1 1 1]);
set(handles.magnet_contrast,'ticklength',[0.02 0.02]);
set(handles.magnet_contrast,'tickdir','out');
xlabel(handles.magnet_contrast,textxlabel);
ylabel(handles.magnet_contrast,textylabel);
axis(handles.magnet_contrast,[min(Arg_x), max(Arg_x), min(Arg_y), max(Arg_y)]);
grid(handles.magnet_contrast);
set(handles.magnet_contrast,'layer','top');
set(handles.magnet_contrast,'LineWidth',2);
h = colorbar('peer',handles.magnet_contrast,'EastOutside');
set(get(h,'ylabel'),'String','Contrast');
 title(file);

imagesc(Arg_x,Arg_y,freq','Parent',handles.magnet_freq);
colormap(handles.magnet_freq,hot);
set(handles.magnet_freq,'YDir','normal');
daspect(handles.magnet_freq,[1 1 1]);
set(handles.magnet_freq,'ticklength',[0.02 0.02]);
set(handles.magnet_freq,'tickdir','out');
xlabel(handles.magnet_freq,textxlabel);
ylabel(handles.magnet_freq,textylabel);
axis(handles.magnet_freq,[min(Arg_x), max(Arg_x), min(Arg_y), max(Arg_y)]);
grid(handles.magnet_freq);
set(handles.magnet_freq,'layer','top');
set(handles.magnet_freq,'LineWidth',2);
h = colorbar('peer',handles.magnet_freq,'EastOutside');
set(get(h,'ylabel'),'String','Frequency');
 title(file);

drawnow();

guidata(hObject, handles);



function magnet_average_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of magnet_average as text
%        str2double(get(hObject,'String')) returns contents of magnet_average as a double


% --- Executes during object creation, after setting all properties.
function magnet_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnet_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in magnet_align.
function magnet_align_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_align (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fp = getpref('nv','SavedExpDirectory');

a = datestr(now,'yyyy-mm-dd-HHMMSS');
fn=['magnet-auto-' a];
ppt_path=[fp '\' fn '.pptx'];
set(handles.magnet_ppt,'String',fn);

init_xmin = str2num(get(handles.scan_xmin, 'String'));
init_xmax = str2num(get(handles.scan_xmax, 'String'));

init_ymin = str2num(get(handles.scan_ymin, 'String'));
init_ymax = str2num(get(handles.scan_ymax, 'String'));


averages  = str2num(get(handles.magnet_average, 'String'));
iterations  = str2num(get(handles.magnet_iterations, 'String'));

%initialize ppt
h = actxserver('PowerPoint.Application');
try
    h.ActivePresentation.Close;
catch exception
end
isOpen  = exportToPPTX();
if ~isempty(isOpen),
    exportToPPTX('close');
end
exportToPPTX('new','Dimensions',[10 8], ...
    'Title','Example Presentation', ...
    'Author','MatLab', ...
    'Subject','Automatically generated PPTX file', ...
    'Comments','This file has been automatically generated by exportToPPTX');
newFile = exportToPPTX('save',ppt_path);
exportToPPTX('close');

% start scan X

zaber_x = handles.zaber_x;
zaber_y = handles.zaber_y;

for iter_ind=1:iterations
    if iter_ind==1
        xmin=init_xmin;
        xmax=init_xmax;
        range_x=xmax-xmin;
        
        ymin=init_ymin;
        ymax=init_ymax;
        range_y=ymax-ymin;
        
        
        
    else
%         xmin= new_x_val-range_x/4;
%         xmax= new_x_val+range_x/4;
        
        xmin=init_xmin;
        xmax=init_xmax;
        
        if xmin<0 
            xmin=0; 
        end
        if xmax>50 
            xmax=50 ;
        end;
        
        range_x=xmax-xmin;
        
%         ymin= new_y_val-range_y/4;
%         ymax= new_y_val+range_y/4;
%         
         ymin=init_ymin;
        ymax=init_ymax;
        
        if ymin<0 
            ymin=0; 
        end
        if ymax>50 
            ymax=50 ;
        end;
        
        range_y=ymax-ymin;
    end
points_x=100; %some fixed value;
points_y=100; %some fixed value;
    
speed=0.5*(xmax-xmin)/15; %just some calibrated fudge factor
set(handles.scan_xmin, 'String',num2str(xmin));
set(handles.scan_xmax, 'String',num2str(xmax));
set(handles.points_x, 'String',num2str(points_x));
set(handles.speed, 'String',num2str(speed));
set(handles.track_point, 'String',num2str(points_x));
set(handles.check_scanx,'Value',1);set(handles.check_scany,'Value',0);set(handles.check_scanz,'Value',0); %scan in X

magnet_scan_Callback(hObject, eventdata, handles); %SCAN X

% plot in separate figure and calculate maximum value
h = actxserver('PowerPoint.Application');
try
    h.ActivePresentation.Close;
catch exception
end

fn = get(handles.magnet_file,'String');file=[fp '\' fn '.mat'];
load(file);
figH=2;figure(figH);clf;set(figH, 'color', 'white');
plot(Arg,argDatamean,'-bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',5,'LineWidth',1); hold on;
plot(Arg,smooth(argDatamean,5),'r-','LineWidth',2); hold (handles.magnet_axes,'off');
axis('square');xlabel(textxlabel);ylabel(textylabel);grid on;title(fn);drawnow();WinOnTop(figH, true);
exportToPPTX('open',ppt_path);slideNum = exportToPPTX('addslide');fprintf('Added slide %d\n',slideNum);
exportToPPTX('addpicture',figH,'Position',[1.5 1 8 6]); %PUT in the figure
close(figH);


%[v b]=max(smooth(argDatamean,3));
[v b]=max(argDatamean);
new_x_val=Arg(b); %THIS is the new X position
[ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, new_x_val*1e-3); %MOVE TO X position

% put data in ppt
exportToPPTX('addtext',sprintf('Maximum: %2.4f ', ...
            new_x_val),'Position',[4.5 7 12 1.5],'FontSize',20);

newFile = exportToPPTX('save',ppt_path);
exportToPPTX('close');
h = actxserver('PowerPoint.Application');
h.Presentations.Open(ppt_path);
h.Visible = 1; % make the window show up

refresh_magnet_Callback(hObject, eventdata,handles);

% NOW SCAN IN Y
speed=0.5*(ymax-ymin)/15; %just some calibrated fudge factor
set(handles.scan_ymin, 'String',num2str(ymin));
set(handles.scan_ymax, 'String',num2str(ymax));
set(handles.points_y, 'String',num2str(points_y));
set(handles.speed, 'String',num2str(speed));
set(handles.track_point, 'String',num2str(points_y));
set(handles.check_scany,'Value',1);set(handles.check_scanx,'Value',0);set(handles.check_scanz,'Value',0); %scan in X

magnet_scan_Callback(hObject, eventdata, handles); %SCAN Y

% plot in separate figure and calculate maximum value
h = actxserver('PowerPoint.Application');
try
    h.ActivePresentation.Close;
catch exception
end

fn = get(handles.magnet_file,'String');file=[fp '\' fn '.mat'];
load(file);
figH=2;figure(figH);clf;set(figH, 'color', 'white');
plot(Arg,argDatamean,'-bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',5,'LineWidth',1); hold on;
plot(Arg,smooth(argDatamean,5),'r-','LineWidth',2); hold (handles.magnet_axes,'off');
axis('square');xlabel(textxlabel);ylabel(textylabel);grid on;title(fn);drawnow();WinOnTop(figH, true);
exportToPPTX('open',ppt_path);slideNum = exportToPPTX('addslide');fprintf('Added slide %d\n',slideNum);
exportToPPTX('addpicture',figH,'Position',[1.5 1 8 6]); %PUT in the figure
close(figH);

%[v b]=max(smooth(argDatamean,3));

[v b]=max(argDatamean);
new_y_val=Arg(b); %THIS is the new X position
[ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, new_y_val*1e-3); %MOVE TO X position

% put data in ppt
exportToPPTX('addtext',sprintf('Maximum: %2.4f ', ...
            new_y_val),'Position',[4.5 7 12 1.5],'FontSize',20);

newFile = exportToPPTX('save',ppt_path);
exportToPPTX('close');
h = actxserver('PowerPoint.Application');
h.Presentations.Open(ppt_path);
h.Visible = 1; % make the window show up

refresh_magnet_Callback(hObject, eventdata,handles);

% SCAN AGAIN in X
speed=0.5*(xmax-xmin)/15; %just some calibrated fudge factor
set(handles.speed, 'String',num2str(speed));
set(handles.check_scanx,'Value',1);set(handles.check_scany,'Value',0);set(handles.check_scanz,'Value',0); %scan in X

magnet_scan_Callback(hObject, eventdata, handles); %SCAN X

% plot in separate figure and calculate maximum value
h = actxserver('PowerPoint.Application');
try
    h.ActivePresentation.Close;
catch exception
end

fn = get(handles.magnet_file,'String');file=[fp '\' fn '.mat'];
load(file);
figH=2;figure(figH);clf;set(figH, 'color', 'white');
plot(Arg,argDatamean,'-bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',5,'LineWidth',1); hold on;
plot(Arg,smooth(argDatamean,5),'r-','LineWidth',2); hold (handles.magnet_axes,'off');
axis('square');xlabel(textxlabel);ylabel(textylabel);grid on;title(fn);drawnow();WinOnTop(figH, true);
exportToPPTX('open',ppt_path);slideNum = exportToPPTX('addslide');fprintf('Added slide %d\n',slideNum);
exportToPPTX('addpicture',figH,'Position',[1.5 1 8 6]); %PUT in the figure
close(figH);

%[v b]=max(smooth(argDatamean,3));
[v b]=max(argDatamean);
new_x_val=Arg(b); %THIS is the new X position
[ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, new_x_val*1e-3); %MOVE TO X position

% put data in ppt
exportToPPTX('addtext',sprintf('Maximum: %2.4f ', ...
            new_x_val),'Position',[4.5 7 12 1.5],'FontSize',20);

newFile = exportToPPTX('save',ppt_path);
exportToPPTX('close');
h = actxserver('PowerPoint.Application');
h.Presentations.Open(ppt_path);
h.Visible = 1; % make the window show up

refresh_magnet_Callback(hObject, eventdata,handles);


end

%In the end track and send email
handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
send_email(fn,' ',ppt_path);
    

function magnet_iterations_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of magnet_iterations as text
%        str2double(get(hObject,'String')) returns contents of magnet_iterations as a double


% --- Executes during object creation, after setting all properties.
function magnet_iterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnet_iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function magnet_ppt_Callback(hObject, eventdata, handles)
% hObject    handle to magnet_ppt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of magnet_ppt as text
%        str2double(get(hObject,'String')) returns contents of magnet_ppt as a double


% --- Executes during object creation, after setting all properties.
function magnet_ppt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnet_ppt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function magnet_contrast_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnet_contrast_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function speed_motorX_Callback(hObject, eventdata, handles)
% hObject    handle to speed_motorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed_motorX as text
%        str2double(get(hObject,'String')) returns contents of speed_motorX as a double


% --- Executes during object creation, after setting all properties.
function speed_motorX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed_motorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in scan_motorX.
function scan_motorX_Callback(hObject, eventdata, handles)
% hObject    handle to scan_motorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zaber_motorX = handles.zaber_x;  
speed=str2num(get(handles.speed_motorX, 'String'))*1e-6;
[ret err] = ZaberMoveAtConstantSpeed(zaber_motorX, zaber_motorX.deviceIndex, speed);

% --- Executes on button press in reverse_motorX.
function reverse_motorX_Callback(hObject, eventdata, handles)
% hObject    handle to reverse_motorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zaber_motorX = handles.zaber_x;  
speed=str2num(get(handles.speed_motorX, 'String'))*1e-6;
speed=-speed;
set(handles.speed_motorX, 'String', num2str(speed*1e6))

% --- Executes on button press in stop_motorX.
function stop_motorX_Callback(hObject, eventdata, handles)
% hObject    handle to stop_motorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zaber_motorX = handles.zaber_x;  
[ret err] = ZaberStop(zaber_motorX, zaber_motorX.deviceIndex);


function speed_motorY_Callback(hObject, eventdata, handles)
% hObject    handle to speed_motorY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed_motorY as text
%        str2double(get(hObject,'String')) returns contents of speed_motorY as a double


% --- Executes during object creation, after setting all properties.
function speed_motorY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed_motorY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in scan_motorY.
function scan_motorY_Callback(hObject, eventdata, handles)
% hObject    handle to scan_motorY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zaber_motorY = handles.zaber_y;  
speed=str2num(get(handles.speed_motorY, 'String'))*1e-6;
[ret err] = ZaberMoveAtConstantSpeed(zaber_motorY, zaber_motorY.deviceIndex, speed);

% --- Executes on button press in reverse_motorY.
function reverse_motorY_Callback(hObject, eventdata, handles)
% hObject    handle to reverse_motorY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zaber_motorY = handles.zaber_y;  
speed=str2num(get(handles.speed_motorY, 'String'))*1e-6;
speed=-speed;
set(handles.speed_motorY, 'String', num2str(speed*1e6))

% --- Executes on button press in stop_motorY.
function stop_motorY_Callback(hObject, eventdata, handles)
% hObject    handle to stop_motorY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zaber_motorY = handles.zaber_y;  
[ret err] = ZaberStop(zaber_motorY, zaber_motorY.deviceIndex);
refresh_motorX_Callback(hObject, eventdata,handles);

function magnet_track_Callback(hObject, eventdata, handles)
handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
for loopcounter=1:4
magnet_track_x(hObject, eventdata, handles);
magnet_track_y(hObject, eventdata, handles);
end

function magnet_track_x(hObject, eventdata, handles)
% track 
step = 6e-3;
loopcounter = 0;
refresh_magnet_Callback(hObject, eventdata,handles);
currpos_x = str2num(get(handles.Pos_x, 'String'));

while(step > 0.5e-3 && loopcounter<10)
    disp('Tracking X ... be patient');
% Get 10 microns left and right of current point
currentcount = count(hObject, eventdata, handles);
%currentcount = handles.counts;


% move right 10
rpos = currpos_x+step;
handles.newposition_x = rpos;
step_x(hObject, eventdata, handles);
rcount = count(hObject, eventdata, handles);
%rcount = handles.counts;

% move left 10
lpos = currpos_x-step;
handles.newposition_x= lpos;
step_x(hObject, eventdata, handles);
lcount = count(hObject, eventdata, handles);
%lcount = handles.counts;

if (currentcount > rcount) && (currentcount > lcount)
    handles.newposition_x = currpos_x;
    step_x(hObject, eventdata, handles);   
    disp('Changing step by half')
    step = step/1.2;
elseif (rcount > currentcount) && (rcount > lcount)
    handles.newposition_x = rpos;
    step_x(hObject, eventdata, handles);    
    
elseif (lcount > currentcount) && (lcount > rcount)
    handles.newposition_x = lpos;
    step_x(hObject, eventdata, handles);    
end
loopcounter = loopcounter+1;
currpos_x=handles.newposition_x;
disp(['left count: '  num2str(lcount) 10 'current count: ' num2str(currentcount)  10 'right count: ' num2str(rcount) 10 'step:' num2str(step*1e3) 10 5 5 ]);
end

disp('End of tracking X')

function magnet_track_y(hObject, eventdata, handles)
% track 
step = 10e-3;
loopcounter = 0;
refresh_magnet_Callback(hObject, eventdata,handles);
currpos_y = str2num(get(handles.Pos_y, 'String'));

while(step > 2e-3 && loopcounter<10)
    disp('Tracking Y ... be patient');
% Get 10 microns left and right of current point
currentcount = count(hObject, eventdata, handles);
%currentcount = handles.counts;


% move right 10
rpos = currpos_y+step;
handles.newposition_y = rpos;
step_y(hObject, eventdata, handles);
rcount = count(hObject, eventdata, handles);
%rcount = handles.counts;

% move left 10
lpos = currpos_y-step;
handles.newposition_y= lpos;
step_y(hObject, eventdata, handles);
lcount = count(hObject, eventdata, handles);
%lcount = handles.counts;

if (currentcount > rcount) && (currentcount > lcount)
    handles.newposition_y = currpos_y;
    step_y(hObject, eventdata, handles);   
    disp('Changing step by half')
    step = step/1.2;
elseif (rcount > currentcount) && (rcount > lcount)
    handles.newposition_y = rpos;
    step_y(hObject, eventdata, handles);    
    
elseif (lcount > currentcount) && (lcount > rcount)
    handles.newposition_y = lpos;
    step_y(hObject, eventdata, handles);    
end
loopcounter = loopcounter+1;
currpos_y=handles.newposition_y;
disp(['left count: '  num2str(lcount) 10 'current count: ' num2str(currentcount)  10 'right count: ' num2str(rcount) 10 'step:' num2str(step*1e3) 10 5 5 ]);
end

disp('End of tracking Y')

% --- Executes on button press in magnet_track.
function step_x(hObject, eventdata, handles)
% hObject    handle to magnet_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Pos_x, 'String', handles.newposition_x);
move_x_Callback(hObject, eventdata, handles)

% --- Executes on button press in magnet_track.
function step_y(hObject, eventdata, handles)
% hObject    handle to magnet_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Pos_y, 'String', handles.newposition_y);
move_y_Callback(hObject, eventdata, handles)


function counts = count(hObject, eventdata, handles)
tracker_points=10;
time_move_per_point = 10e-3;
%time_move_per_point=5e-6;


daq=handles.Imaginghandles.ImagingFunctions.interfaceDataAcq;
handles.magnet_counter_line=handles.Imaginghandles.ImagingFunctions.TrackerCounterOutLine;

daq.AnalogOutVoltages(1)=5; %enable SPD
daq.WriteAnalogOutLine(1);

daq.CreateTask('Counter_magnet');
daq.CreateTask('PulseTrain_magnet');


daq.ConfigureCounterIn('Counter_magnet',handles.Imaginghandles.ImagingFunctions.TrackerCounterInLine,handles.magnet_counter_line,tracker_points);
daq.ConfigureClockOut('PulseTrain_magnet',handles.magnet_counter_line,1/time_move_per_point,0.5);


daq.StartTask('PulseTrain_magnet');
daq.StartTask('Counter_magnet');

A = daq.ReadCounterBuffer('Counter_magnet',tracker_points+1,10);
daq.StopTask('Counter_magnet');
daq.StopTask('PulseTrain_magnet');

daq.ClearTask('Counter_magnet');
daq.ClearTask('PulseTrain_magnet');


argData =double(diff(A)/(time_move_per_point));
counts=median(argData(1:end-1));
% handles.counts=counts;
% guidata(hObject, handles);
