function varargout = NVpines(varargin)
% NVPINES MATLAB code for NVpines.fig
%      NVPINES, by itself, creates a new NVPINES or raises the existing
%      singleton*.
%
%      H = NVPINES returns the handle to a new NVPINES or the handle to
%      the existing singleton*.
%
%      NVPINES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NVPINES.M with the given input arguments.
%
%      NVPINES('Property','Value',...) creates a new NVPINES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NVpines_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NVpines_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NVpines

% Last Modified by GUIDE v2.5 30-Oct-2018 07:21:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NVpines_OpeningFcn, ...
                   'gui_OutputFcn',  @NVpines_OutputFcn, ...
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
end

% --- Executes just before NVpines is made visible.
function NVpines_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NVpines (see VARARGIN)

% Choose default command line output for NVpines
% 
 gobj = findall(0,'Name','Imaging');
 handles.Imaginghandles = guidata(gobj);
 % be able to access the functions in ImagingFunctions
handles.ImagingFunctions = ImagingFunctions();

%% Close all open ports
% serialObj = instrfind;
% for j=1:size(serialObj,2)
%     if strcmp(serialObj(j).Status,'open')
%         fclose(serialObj(j));
%     end
% end

  %%%%% Pulse Blaster %%%%%%%%%%
LibraryName = 'spinapi';
    LibraryFilePath = 'spinapi64.dll';
    HeaderFilePath = 'spinapi.h';
    
    handles.ImagingFunctions.interfacePulseGen = PulseGeneratorSpinCorePulseBlaster(LibraryFilePath,HeaderFilePath,LibraryName);
    %handles.ImagingFunctions.interfacePulseGen.PBInit();
    handles.ImagingFunctions.interfacePulseGen.SampleRate = 100e6; %ClockRate of our pulse blaster is 500MHz
    handles.ImagingFunctions.interfacePulseGen.SetClock(handles.ImagingFunctions.interfacePulseGen.SampleRate);

    %%%%% DAQ%%%%%%%%%%
    LibraryName = 'nidaqmx';
    LibraryFilePath = 'nicaiu.dll';
    HeaderFilePath = 'NIDAQmx.h';
    handles.ImagingFunctions.interfaceDataAcq = DAQNI(LibraryName,LibraryFilePath,HeaderFilePath);
    
    handles.ImagingFunctions.interfaceDataAcq.SampleRate = 100e6; %100MHz is the sampling rate as specified for Pcie-6323
    handles.ImagingFunctions.interfaceDataAcq.AnalogOutMinVoltage = -10;
    handles.ImagingFunctions.interfaceDataAcq.AnalogOutMaxVoltage = 10;
    handles.ImagingFunctions.interfaceDataAcq.ReadTimeout = 10; 
    handles.ImagingFunctions.interfaceDataAcq.WriteTimeout = 10;
    handles.ImagingFunctions.interfaceDataAcq.CounterOutSamples = 10000000000;
   
    handles.ImagingFunctions.interfaceDataAcq.addAOLine('/Dev1/ao0',0);
    handles.ImagingFunctions.interfaceDataAcq.addAOLine('/Dev1/ao1',0);   
    handles.ImagingFunctions.interfaceDataAcq.addAILine('/Dev1/ai6');
    %Analog Input line 1 to monitor photodiode
handles.output = hObject;

%% Rotation stage

% % port = serial('COM4');
% % 
% % % Set default serial port properties for the ASCII protocol.
% % set(port, ...
% %     'BaudRate', 115200, ...
% %     'DataBits', 8, ...
% %     'FlowControl', 'none', ...
% %     'Parity', 'none', ...
% %     'StopBits', 1, ...
% %     'Terminator','CR/LF');
% % set(port, 'Timeout', 0.5)
% % warning off MATLAB:serial:fgetl:unsuccessfulRead
% % fopen(port);
% % protocol = Zaber.AsciiProtocol(port);
% % device = Zaber.AsciiDevice.initialize(protocol, 1); 
% % axes = [];
% %     if (device.IsAxis)
% %         axes = device;
% %     else
% %         axes = device.Axes;
% %     end
% %     
% % axis = axes(1);
% % handles.axis=axis;


%% ACS start
com = actxserver('SPiiPlusCOM660.Channel.1');
com.OpenCommEthernetTCP('10.0.0.100', 701)
com.Enable(com.ACSC_AXIS_0);
com.SetKillDeceleration(com.ACSC_AXIS_0,30000);
handles.com=com;
guidata(hObject, handles);


%com.Callbuffer(buffer0);
%Imaging_InitScript();
%com.RunBuffer(0);                      %run homing buffer 0 in MMI %Xudong

%% Refresh position of COM
ACS_refresh_Callback(hObject, eventdata, handles);

%% Refresh position of Laser
%refresh_pines_Callback(hObject, eventdata,handles);

%% Set slider step
handles.acs_slider.SliderStep(1)=1/1598;
handles.acs_slider.SliderStep(2)=2/1598;

%% Set default velocity
set(handles.acs_vel, 'String', num2str(10));
end

% --- Outputs from this function are returned to the command line.
function varargout = NVpines_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;
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
end

% --- Executes during object creation, after setting all properties.
function slider_rot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_rot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end



function Pos_rot_Callback(hObject, eventdata, handles)
% hObject    handle to Pos_rot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pos_rot as text
%        str2double(get(hObject,'String')) returns contents of Pos_rot as a double
end

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
end

% --- Executes on button press in move_rot.
function move_rot_Callback(hObject, eventdata, handles)
% hObject    handle to move_rot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
absolutePosition = str2num(get(handles.Pos_rot, 'String'));
real_absPosition = absolutePosition + 88.25390625;
axis = handles.axis;  
micrst_change = axis.Units.positiontonative(real_absPosition);
axis.moveabsolute(micrst_change);
axis.waitforidle();
pause(1.0);
current_pos = axis.Units.nativetoposition(axis.getposition());
mod_pos = current_pos - 88.25390625;
while mod_pos > 90
    mod_pos = mod_pos - 90; 
end
set(handles.slider_rot, 'Value', mod_pos);
set(handles.Pos_rot, 'String', num2str(mod_pos));
% PORT HAS TO BE CLOSED AT THE END

refresh_pines_Callback(hObject, eventdata,handles);

end

% --- Executes on button press in refresh_pines.
function refresh_pines_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_pines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axis = handles.axis;
current_pos = axis.Units.nativetoposition(axis.getposition());
mod_pos = current_pos - 88.25390625;
while mod_pos > 90
    mod_pos = mod_pos - 90;    
end
set(handles.slider_rot, 'Value', mod_pos);
set(handles.Pos_rot, 'String', num2str(mod_pos));
int = mod_pos * pi / 2 / 44.646;
int_sin = sin(int) * 100;
set(handles.slider3, 'Value', int_sin);
set(handles.Intensity_rot, 'String', num2str(int_sin));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function zaber_home_Callback(hObject, eventdata, handles)
% hObject    handle to zaber_home (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
axis = handles.axis;
micrst_change = axis.Units.positiontonative(88.254);
axis.moveabsolute(micrst_change);
axis.waitforidle();
pause(1.0);
refresh_pines_Callback(hObject, eventdata,handles);
end


% --- Executes rotation based on desired intensity.
function slider_intensity_Zaber(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
int = 0.01 * get(hObject, 'Value'); 
arcsin_int = asin(int);
degree = arcsin_int / pi * 2 * 44.646;
set(handles.Pos_rot, 'String', degree);
move_rot_Callback(hObject, eventdata, handles);
end


% --- Executes on button press in acs_move.
function acs_move_Callback(hObject, eventdata, handles)
% hObject    handle to acs_move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
com=handles.com;
com.StopBuffer(1);
des_pos=-str2num(get(handles.acs_pos, 'String'));
start_pos=com.GetFPosition(com.ACSC_AXIS_0);
if des_pos>-1598
%curr_pos=com.GetFPosition(com.ACSC_AXIS_0);
move_vel=str2num(get(handles.acs_vel, 'String'));
if move_vel<2000
com.SetVelocity(com.ACSC_AXIS_0, move_vel);
com.SetAcceleration(com.ACSC_AXIS_0,move_vel*10);
com.SetDeceleration(com.ACSC_AXIS_0,move_vel*10);
com.SetJerk(com.ACSC_AXIS_0,move_vel*100);
com.ToPoint(com.ACSC_AMF_WAIT, com.ACSC_AXIS_0, des_pos); %MOVE
com.Go(com.ACSC_AXIS_0);
% displacement=abs(abs(start_pos)-abs(des_pos));
% if displacement>2
%    com.WaitMotionEnd (com.ACSC_AXIS_0, 1000*2*displacement/move_vel);
% else
%     com.WaitMotionEnd (com.ACSC_AXIS_0, 3000);
% end

ACS_refresh_Callback(hObject, eventdata, handles);
end
end
end

% --- Executes on slider movement.
function acs_slider_Callback(hObject, eventdata, handles)
% hObject    handle to acs_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
com=handles.com;
des_pos=-get(handles.acs_slider, 'Value');
start_pos=com.GetFPosition(com.ACSC_AXIS_0);
if des_pos>-1598   
%curr_pos=com.GetFPosition(com.ACSC_AXIS_0);
move_vel=1;
if move_vel<300
com.SetVelocity(com.ACSC_AXIS_0, move_vel);
com.SetAcceleration(com.ACSC_AXIS_0,move_vel*10);
com.SetDeceleration(com.ACSC_AXIS_0,move_vel*10);
com.SetJerk(com.ACSC_AXIS_0,move_vel*100);
com.ToPoint(com.ACSC_AMF_WAIT, com.ACSC_AXIS_0, des_pos); %MOVE
com.Go(com.ACSC_AXIS_0);
% displacement=abs(abs(start_pos)-abs(des_pos));
% if displacement>2
%     com.WaitMotionEnd (com.ACSC_AXIS_0, 1000*2*displacement/move_vel);
% else
%     com.WaitMotionEnd (com.ACSC_AXIS_0, 3000);
% end
ACS_refresh_Callback(hObject, eventdata, handles);
end
end
end
% --- Executes during object creation, after setting all properties.
function acs_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acs_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on button press in ACS_refresh.
function ACS_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to ACS_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
com=handles.com;
curr_pos=abs(com.GetFPosition(com.ACSC_AXIS_0));
set(handles.acs_pos, 'String', num2str(curr_pos));
set(handles.acs_slider, 'Value',  curr_pos);
end


function acs_pos_Callback(hObject, eventdata, handles)
% hObject    handle to acs_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acs_pos as text
%        str2double(get(hObject,'String')) returns contents of acs_pos as a double
end

% --- Executes during object creation, after setting all properties.
function acs_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acs_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function acs_vel_Callback(hObject, eventdata, handles)
% hObject    handle to acs_vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acs_vel as text
%        str2double(get(hObject,'String')) returns contents of acs_vel as a double
end

% --- Executes during object creation, after setting all properties.
function acs_vel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acs_vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in acs_stop.
function acs_stop_Callback(hObject, eventdata, handles)
% hObject    handle to acs_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
com=handles.com;
com.KillAll();
com.StopBuffer(1);
end

% --- Executes on button press in toggle_valve1.
function toggle_valve1_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_valve1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LaserOn=get(hObject,'Value');
if LaserOn

%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.toggle_valve1,'String','Laser 1 On')
    set(handles.toggle_valve1,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.toggle_valve1,'String','Laser 1 Off')
    set(handles.toggle_valve1,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end
% --- Executes on button press in toggle_valve2.
function toggle_valve2_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_valve2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LaserOn=get(hObject,'Value');
if LaserOn
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^9,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^9,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.toggle_valve2,'String','Laser 2 On')
    set(handles.toggle_valve2,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.toggle_valve2,'String','Laser 2 Off')
    set(handles.toggle_valve2,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end

end
% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LaserOn=get(hObject,'Value');
if LaserOn
   
        handles.ImagingFunctions.interfacePulseGen.StartProgramming();
%         handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^6+2^9+2^10+2^12+2^14+2^16,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
%         handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^6+2^9+2^10+2^12+2^14+2^16,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^11,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^11,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
     
        handles.ImagingFunctions.interfacePulseGen.StopProgramming();
        handles.ImagingFunctions.interfacePulseGen.PBStart();
        handles.ImagingFunctions.interfacePulseGen.PBStop();
        
   
    
    set(handles.togglebutton3,'String','Laser On')
    set(handles.togglebutton3,'ForegroundColor',[0.847 0.161 0])
    
else
    
   
        handles.ImagingFunctions.interfacePulseGen.StartProgramming();
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.StopProgramming();
        handles.ImagingFunctions.interfacePulseGen.PBStart();
        handles.ImagingFunctions.interfacePulseGen.PBStop();
  
    set(handles.togglebutton3,'String','Laser Off')
    set(handles.togglebutton3,'ForegroundColor',[0.0 0.487 0])

% Hint: get(hObject,'Value') returns toggle state of togglebutton3
end
end


% --- Executes on button press in toggle_openB.
function toggle_openB_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_openB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_openB
LaserOn=get(hObject,'Value');
if LaserOn

    
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
%     handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^12+2^6+2^10,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
%     handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^12+2^6+2^10,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
%     
     handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^12+2^6,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^12+2^6,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
%     
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.toggle_openB,'String','Both On')
    set(handles.toggle_openB,'ForegroundColor',[0.847 0.161 0])
    
else

    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.toggle_openB,'String','Both Off')
    set(handles.toggle_openB,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end


% --- Executes on button press in togglebutton5.
function togglebutton5_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton5
LaserOn=get(hObject,'Value');
if LaserOn

%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^10,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^10,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.togglebutton5,'String','Laser 3 On')
    set(handles.togglebutton5,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.togglebutton5,'String','Laser 3 Off')
    set(handles.togglebutton5,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end


% --- Executes on button press in togglebutton6.
function togglebutton6_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton6

LaserOn=get(hObject,'Value');
if LaserOn
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^12,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^12,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.togglebutton6,'String','Laser 4 On')
    set(handles.togglebutton6,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.togglebutton6,'String','Laser 4 Off')
    set(handles.togglebutton6,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end


% --- Executes on button press in togglebutton8.
function togglebutton8_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton8

LaserOn=get(hObject,'Value');
if LaserOn
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^14,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^14,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.togglebutton8,'String','Laser 5 On')
    set(handles.togglebutton8,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.togglebutton8,'String','Laser 5 Off')
    set(handles.togglebutton8,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end


% --- Executes on button press in togglebutton9.
function togglebutton9_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton9

LaserOn=get(hObject,'Value');
if LaserOn
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^16,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^16,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.togglebutton9,'String','Laser 6 On')
    set(handles.togglebutton9,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.togglebutton9,'String','Laser 6 Off')
    set(handles.togglebutton9,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end


% --- Executes on button press in togglebutton10.
function togglebutton10_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton10

LaserOn=get(hObject,'Value');
if LaserOn
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^17,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^17,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.togglebutton10,'String','Laser 7 On')
    set(handles.togglebutton10,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.togglebutton10,'String','Laser 7 Off')
    set(handles.togglebutton10,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end


% --- Executes on button press in togglebutton11.
function togglebutton11_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton11

LaserOn=get(hObject,'Value');
if LaserOn
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^18,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^18,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.togglebutton11,'String','Laser 8 On')
    set(handles.togglebutton11,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.togglebutton11,'String','Laser 8 Off')
    set(handles.togglebutton11,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end


% --- Executes on button press in togglebutton12.
function togglebutton12_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton12

LaserOn=get(hObject,'Value');
if LaserOn
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^15,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^15,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.togglebutton12,'String','Laser 9 On')
    set(handles.togglebutton12,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.togglebutton12,'String','Laser 9 Off')
    set(handles.togglebutton12,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end


% --- Executes on button press in togglebutton13.
function togglebutton13_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton13
LaserOn=get(hObject,'Value');
if LaserOn
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^13,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(2^13,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    
    set(handles.togglebutton13,'String','MW Switch On')
    set(handles.togglebutton13,'ForegroundColor',[0.847 0.161 0])
    
else
%     handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
%     handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
%     
    handles.ImagingFunctions.interfacePulseGen.StartProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
    handles.ImagingFunctions.interfacePulseGen.StopProgramming();
    handles.ImagingFunctions.interfacePulseGen.PBStart();
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    set(handles.togglebutton13,'String','MW Switch Off')
    set(handles.togglebutton13,'ForegroundColor',[0.0 0.487 0])
    % Hint: get(hObject,'Value') returns toggle state of toggle_valve1
end
end
