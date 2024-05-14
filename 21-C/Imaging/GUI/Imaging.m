%%%%% INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = Imaging(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...f
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Imaging_OpeningFcn, ...
    'gui_OutputFcn',  @Imaging_OutputFcn, ...
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

% --- Executes just before Imaging is made visible.
function Imaging_OpeningFcn(hObject, ~, handles, varargin)

% Choose default command line output for Imaging
handles.output = hObject;

% be able to access the functions in ImagingFunctions
handles.ImagingFunctions = ImagingFunctions();

% Pass on handles from QEG
gobj = findall(0,'Name','QEG');
handles.QEGhandles = guidata(gobj);
handles.QEGhandles.flag_imaging = 1;

% init devices
[hObject,handles] = InitDevices(hObject,handles);
%
%# comment this part to start 'imaging' without piezo
 % init Piezo position
set(handles.cursorX,'String',handles.ImagingFunctions.interfaceScanning.Pos(1));
pause(1);
set(handles.cursorY,'String',handles.ImagingFunctions.interfaceScanning.Pos(2));
set(handles.cursorZ,'String',handles.ImagingFunctions.interfaceScanning.Pos(3));

%set params in scan panel
set(handles.minX,'String',handles.ImagingFunctions.interfaceScanning.LowEndOfRange(1));
set(handles.minY,'String',handles.ImagingFunctions.interfaceScanning.LowEndOfRange(2));
set(handles.minZ,'String',handles.ImagingFunctions.interfaceScanning.LowEndOfRange(3));

set(handles.maxX,'String',handles.ImagingFunctions.interfaceScanning.HighEndOfRange(1));
set(handles.maxY,'String',handles.ImagingFunctions.interfaceScanning.HighEndOfRange(2));
set(handles.maxZ,'String',handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3));
%#

set(handles.pointsX,'String',handles.ImagingFunctions.NumPoints(1));
set(handles.pointsY,'String',handles.ImagingFunctions.NumPoints(2));
set(handles.pointsZ,'String',handles.ImagingFunctions.NumPoints(3));

%set(handles.DwellScanValue,'String',20/handles.ImagingFunctions.interfaceScanning.SampleRate);
set(handles.DwellScanValue,'String',num2str(0.0096));

set(handles.enableX,'Value',handles.ImagingFunctions.bEnable(1));
set(handles.enableY,'Value',handles.ImagingFunctions.bEnable(2));
set(handles.enableZ,'Value',handles.ImagingFunctions.bEnable(3));

%init axes
axes(handles.imageAxes);
handles.xcrosshair = NaN;
handles.ycrosshair = NaN;

% load scans
handles.ImagingFunctions.UpdateScanList(handles);
handles = handles.ImagingFunctions.LoadImagesFromScan(handles);

%init tracker
set(handles.InitStepX,'String',handles.ImagingFunctions.TrackerInitialStepSize(1));
set(handles.InitStepY,'String',handles.ImagingFunctions.TrackerInitialStepSize(2));
set(handles.InitStepZ,'String',handles.ImagingFunctions.TrackerInitialStepSize(3));

set(handles.MinStepX,'String',handles.ImagingFunctions.TrackerMinimumStepSize(1));
set(handles.MinStepY,'String',handles.ImagingFunctions.TrackerMinimumStepSize(2));
set(handles.MinStepZ,'String',handles.ImagingFunctions.TrackerMinimumStepSize(3));

set(handles.Thresh,'String',handles.ImagingFunctions.TrackerTrackingThreshold);
set(handles.MaxIter,'String',handles.ImagingFunctions.TrackerMaxIterations);

% Update handles structure
guidata(hObject, handles);

%init the objective actuator stage
%delete(instrfind);
% s_obj=  serial('com9');
% 
% addpath(genpath('ZaberInstrumentDriver'));
% % This is to display initialization
% disp('Initalizing objective stage');
% handles.zaber_obj = ZaberOpen(s_obj);
% zaber_obj = handles.zaber_obj;
% zaber_obj = ZaberUpdateDeviceList(zaber_obj);
% 
% set(handles.slider_obj, 'Max', (zaber_obj.maxPosition(zaber_obj.deviceIndex))*1000);
% maxrange=zaber_obj.maxPosition(zaber_obj.deviceIndex);
% set(handles.slider_obj, 'SliderStep',[10e-6/maxrange,100e-6/maxrange]);
% [ret ~] = ZaberReturnCurrentPosition(zaber_obj, zaber_obj.deviceIndex);
% set(handles.slider_obj, 'Value', (ret(2)*1000));
% set(handles.Pos_obj, 'String', get(handles.slider_obj, 'Value'));
% set(handles.objmax, 'String', [num2str((zaber_obj.maxPosition(zaber_obj.deviceIndex))*1000) ' [mm]']);

% This is for the coarse/fine toggle button
set(handles.coarsefine_toggle,'String','Coarse');
set(handles.coarsefine_toggle,'ForegroundColor',[0.0 0.487 0])

% This is for the coarse/fine toggle button for piezo Z
set(handles.piezoZ_toggle,'String','Piezo');
set(handles.piezoZ_toggle,'ForegroundColor',[0.0 0.487 0])


%init the motor X actuator stage
%delete(instrfind);
% s_motorX=  serial('com3');
% 
% addpath(genpath('ZaberInstrumentDriver'));
% % This is to display initialization
% disp('Initalizing Motor X');
% handles.zaber_motorX = ZaberOpen(s_motorX);
% zaber_motorX = handles.zaber_motorX;
% zaber_motorX = ZaberUpdateDeviceList(zaber_motorX);
% 
% [ret err] = ZaberSetMaximumPosition(zaber_motorX, zaber_motorX.deviceIndex,0.0127); %constrain the maximum range
% set(handles.slider_motorX, 'Max', 10.18);
% set(handles.slider_motorX, 'Min', 0.70);
% maxrange=(10.18 -0.70)*1e-3;
% set(handles.slider_motorX, 'SliderStep',[10e-6/maxrange,100e-6/maxrange]);
% [ret ~] = ZaberReturnCurrentPosition(zaber_motorX, zaber_motorX.deviceIndex);
% set(handles.slider_motorX, 'Value', (ret(2)*1000));
% set(handles.Pos_motorX, 'String', get(handles.slider_motorX, 'Value'));
% 
% %init the motor Y actuator stage
% %delete(instrfind);
% s_motorY=  serial('com4');
% 
% addpath(genpath('ZaberInstrumentDriver'));
% % This is to display initialization
% disp('Initalizing Motor Y');
% handles.zaber_motorY = ZaberOpen(s_motorY);
% zaber_motorY = handles.zaber_motorY;
% zaber_motorY = ZaberUpdateDeviceList(zaber_motorY);
% 
% [ret err] = ZaberSetMaximumPosition(zaber_motorY, zaber_motorY.deviceIndex,0.0127); %constrain the maximum range
% set(handles.slider_motorY, 'Max', 10.55);
% set(handles.slider_motorY, 'Min', 3.89);
% maxrange=(10.55-3.89)*1e-3;
% set(handles.slider_motorY, 'SliderStep',[10e-6/maxrange,100e-6/maxrange]);
% [ret ~] = ZaberReturnCurrentPosition(zaber_motorY, zaber_motorY.deviceIndex);
% set(handles.slider_motorY, 'Value', (ret(2)*1000));
% set(handles.Pos_motorY, 'String', get(handles.slider_motorY, 'Value'));

%NVpines();

guidata(hObject,handles);



function [hObject,handles] = InitDevices(hObject,handles)

fp = 'C:\300-magnet\21-C\Initialization'; %getpref('nv','SavedInitializationDirectory');
current_path = pwd;
cd(fp);
script = 'Imaging_InitScript.m';
[hObject,handles] = feval(script(1:end-2),hObject,handles);
cd(current_path);

handles.ImagingFunctions.SetStatus(handles,sprintf('Init script has been run',script));

% --- Outputs from this function are returned to the command line.
function varargout = Imaging_OutputFcn(~, ~, handles)
varargout{1} = handles.output;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, handles)

% clear all NI tasks
handles.ImagingFunctions.interfaceDataAcq.ResetDevice();

% %Closes Pulse Blaster
handles.ImagingFunctions.interfacePulseGen.PBStop();
handles.ImagingFunctions.interfacePulseGen.PBReset();
handles.ImagingFunctions.interfacePulseGen.PBClose();

handles.QEGhandles.flag_imaging = 0;
handles.QEGhandles.flag_experiment = 0;
set(handles.QEGhandles.button_imaging,'Enable', 'on');
set(handles.QEGhandles.pb_radiobutton, 'Enable', 'on');
set(handles.QEGhandles.awg_radiobutton, 'Enable', 'on');
set(handles.QEGhandles.simulate_checkbox, 'Enable', 'on');

gobj = findall(0, 'Name', 'QEG');
guidata(gobj,handles.QEGhandles);

delete(hObject);

%%%%% END INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% SCAN PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function buttonSaveScan_Callback(hObject, ~, handles)

% Initialize Scan
handles.ConfocalScan = ConfocalScan();

MinVal(1) = str2num(get(handles.minX,'String'));
MinVal(2) = str2num(get(handles.minY,'String'));
MinVal(3) = str2num(get(handles.minZ,'String'));

MaxVal(1) = str2num(get(handles.maxX,'String'));
MaxVal(2) = str2num(get(handles.maxY,'String'));
MaxVal(3) = str2num(get(handles.maxZ,'String'));

NumPoints(1) = str2num(get(handles.pointsX,'String'));
NumPoints(2) = str2num(get(handles.pointsY,'String'));
NumPoints(3) = str2num(get(handles.pointsZ,'String'));

DwellTime = str2num(get(handles.DwellScanValue,'String'));

bEnable(1) = get(handles.enableX,'Value');
bEnable(2) = get(handles.enableY,'Value');
bEnable(3) = get(handles.enableZ,'Value');

%Start checking if scan can be done
if sum(bEnable) == 0
    uiwait(warndlg({'No scan direction selected!'}));
    return;
end

if sum(bEnable) == 1
    
    for j=1:1:3
        if bEnable(j)
            if MinVal(j) == MaxVal(j)
                uiwait(warndlg({'Scan range in 1D must be different from zero!'}));
                return;
            end
        end
    end
    
elseif sum(bEnable) == 2
    
    if bEnable(1) && bEnable(2)
        if (MinVal(1) == MaxVal(1))||(MinVal(2) == MaxVal(2))
            uiwait(warndlg({'Both scan ranges in 2D must be different from zero!'}));
            return;
        end
    elseif bEnable(1) && bEnable(3)
        if (MinVal(1) == MaxVal(1))||(MinVal(3) == MaxVal(3))
            uiwait(warndlg({'Both scan ranges in 2D must be different from zero!'}));
            return;
        end
    else
        if (MinVal(3) == MaxVal(3))||(MinVal(2) == MaxVal(2))
            uiwait(warndlg({'Both scan ranges in 2D must be different from zero!'}));
            return;
        end
    end
    
else %3d %only case where it is possible for scan range to be 0, but only if the dimension is not ramped
    if (MinVal(1) == MaxVal(1)|| MinVal(2) == MaxVal(2))
        uiwait(warndlg({'In a 3D scan only z can have range zero!'}));
        return;
    end
    
    size = 0;
    for j=1:1:3
        if NumPoints(j) > size
            size = NumPoints(j);
            rampover = j;
        end
    end
    
    if (rampover == 3 && (MinVal(3) == MaxVal(3)))
        uiwait(warndlg({'Z is currently the ramp-over direction, cannot have range zero!'}));
        return;
    end
    
    
end


if (((MinVal(1)> MaxVal(1)) && bEnable(1))||((MinVal(2) > MaxVal(2)) && bEnable(2))|| ((MinVal(3)> MaxVal(3)) && bEnable(3)))
    uiwait(warndlg({'Scan start point must be smaller than end point!'}));
    return;
end

if MinVal(1) < handles.ImagingFunctions.interfaceScanning.LowEndOfRange(1)
    uiwait(warndlg('X too low, out of range!'));
    set(handles.minX,'String',handles.ImagingFunctions.MinValues(1));
    return;
end

if MaxVal(1) > handles.ImagingFunctions.interfaceScanning.HighEndOfRange(1)
    uiwait(warndlg('X too high, out of range!'));
    set(handles.maxX,'String',handles.ImagingFunctions.MaxValues(1));
    return;
end

if MaxVal(2)> handles.ImagingFunctions.interfaceScanning.HighEndOfRange(2)
    uiwait(warndlg('Y too high, out of range!'));
    set(handles.maxY,'String',handles.ImagingFunctions.MaxValues(2));
    return;
end

if MinVal(2)< handles.ImagingFunctions.interfaceScanning.LowEndOfRange(2)
    uiwait(warndlg('Y too low, out of range!'));
    set(handles.minY,'String',handles.ImagingFunctions.MinValues(2));
    return;
end

Piezotoggle=get(handles.piezoZ_toggle,'Value');
if Piezotoggle==0
    if MaxVal(3)> handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3)
        uiwait(warndlg('Z too high, out of range!'));
        %set(handles.maxZ,'String',handles.ImagingFunctions.MaxValues(3));
        set(handles.maxZ,'String',handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3));
        return;
    end
else
    if MaxVal(3)> 1000
        uiwait(warndlg('Z too high, out of range!'));
        set(handles.maxZ,'String',1000);
        return;
    end
end

if MinVal(3)< handles.ImagingFunctions.interfaceScanning.LowEndOfRange(3)
    uiwait(warndlg('Z too low, out of range!'));
    set(handles.minZ,'String',handles.ImagingFunctions.MinValues(3));
    return;
end

if DwellTime < (1.0/handles.ImagingFunctions.interfaceScanning.SampleRate)
    uiwait(warndlg('Dwell time too small!'));
    set(handles.DwellScanValue,'String',1/handles.ImagingFunctions.interfaceScanning.SampleRate);
    return;
end

handles.ImagingFunctions.NumPoints = NumPoints;
handles.ImagingFunctions.bEnable = bEnable;
handles.ImagingFunctions.MinValues = MinVal;
handles.ImagingFunctions.MaxValues = MaxVal;
handles.ConfocalScan.DwellTime = DwellTime;
handles.ConfocalScan.Notes = 'Notes on Scan:';

set(handles.buttonScan,'Enable','on');

guidata(hObject,handles);

function buttonScan_Callback(hObject, eventdata, handles)

if sum(handles.ImagingFunctions.bEnable) ~= 3
    set(handles.text6,'Visible','off');
    set(handles.sliderZScan,'Visible','off');
end
LaserOn=get(handles.toggle_LaserOnOff,'Value');
if ~LaserOn
    set(handles.toggle_LaserOnOff,'Value',1);
    toggle_LaserOnOff_Callback(handles.toggle_LaserOnOff, eventdata, handles)
    hwd=warndlg('Turning on the laser');
    pause(1)
    close(hwd)
end

handles.ImagingFunctions.statuswb = 1;

set(handles.buttonSaveNote,'Enable','off');
set(handles.popupScan,'Value',1);

% Blank Notes field
set(handles.Note, 'Enable', 'off');
set(handles.Note, 'String', 'Notes on Scan:');

set(handles.minX,'String',handles.ImagingFunctions.MinValues(1));
set(handles.minY,'String',handles.ImagingFunctions.MinValues(2));
set(handles.minZ,'String',handles.ImagingFunctions.MinValues(3));

set(handles.maxX,'String',handles.ImagingFunctions.MaxValues(1));
set(handles.maxY,'String',handles.ImagingFunctions.MaxValues(2));
set(handles.maxZ,'String',handles.ImagingFunctions.MaxValues(3));

set(handles.pointsX,'String',handles.ImagingFunctions.NumPoints(1));
set(handles.pointsY,'String',handles.ImagingFunctions.NumPoints(2));
set(handles.pointsZ,'String',handles.ImagingFunctions.NumPoints(3));

handles = handles.ImagingFunctions.PerformScan(handles);

guidata(hObject,handles);

%check the scan continuously button
cont = get(handles.cbScanContinuous, 'Value');

while cont && handles.ImagingFunctions.statuswb
    set(handles.Note,'Enable','off');
    handles = handles.ImagingFunctions.PerformScan(handles);
    cont = get(handles.cbScanContinuous,'Value');
    guidata(hObject,handles);
end

set(handles.Note,'Enable','on');
set(handles.Note, 'Enable', 'on');

set(handles.buttonStop, 'Enable', 'off');

function buttonStop_Callback(~, ~, handles)

handles.ImagingFunctions.statuswb = 0;
handles.ImagingFunctions.SetStatus(handles,'Scan Aborted.');
set(handles.text6, 'Visible', 'off');
set(handles.buttonStop, 'Enable', 'off');

function cbScanContinuous_Callback(~, ~, ~)

function minX_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function minX_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxX_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function maxX_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pointsX_Callback(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function enableX_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function minY_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function minY_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxY_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function maxY_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pointsY_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function pointsY_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function enableY_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function minZ_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function minZ_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxZ_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function maxZ_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pointsZ_Callback(~, ~, handles)

set(handles.buttonScan,'Enable','off');

function pointsZ_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function enableZ_Callback(~, ~, handles)
set(handles.buttonScan,'Enable','off');

function Note_Callback(~, ~, ~)

function buttonSaveNote_Callback(hObject, ~, handles)

scans = get(handles.popupScan,'String');
selectedScan = scans{get(handles.popupScan,'Value')};

if strcmp(selectedScan,'Current Scan')
    selectedScan = scans{get(handles.popupScan,'Value')+1};
end

fp = getpref('nv','SavedImageDirectory');
load(fullfile(fp,selectedScan));
Scan.Notes = get(handles.Note, 'String');
save(fullfile(fp,selectedScan),'Scan');

% Update handles structure
guidata(hObject, handles);

function buttonSaveNote_CreateFcn(~, ~, ~)

function Note_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function returninit_Callback(~, ~, ~)

function DwellScanValue_Callback(~, ~, ~)

%%%%% END SCAN PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% NAVIGATION PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function buttonQueryPos_Callback(~, ~, handles)
handles = handles.ImagingFunctions.QueryPos(handles);

function buttonSetCursor_Callback(~, ~, handles)

% fixate to the current position
X = get(handles.cursorX,'String');
Y = get(handles.cursorY,'String');
Z = get(handles.cursorZ,'String');

X = str2num(X);
Y = str2num(Y);
Z = str2num(Z);

if (X >= handles.ImagingFunctions.interfaceScanning.LowEndOfRange(1)) && ...
        (X <= handles.ImagingFunctions.interfaceScanning.HighEndOfRange(1)) && ...
        (Y >= handles.ImagingFunctions.interfaceScanning.LowEndOfRange(2)) && ...
        (Y <= handles.ImagingFunctions.interfaceScanning.HighEndOfRange(2)) && ...
        (Z >= handles.ImagingFunctions.interfaceScanning.LowEndOfRange(3)) && ...
        (Z <= handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3))
    % if allowed movement range
    
    newCursorPosition = [X,Y,Z];
    
    if length(newCursorPosition) ~= 3,
        errordlg('Could not set cursor');
    else
        
        % update the cursor position
        handles.ImagingFunctions.CursorPosition = newCursorPosition;
        handles = handles.ImagingFunctions.SetCursor(handles);
        
    end
    
else
    if X  < handles.ImagingFunctions.interfaceScanning.LowEndOfRange(1)
        uiwait(warndlg({'X too low, did not move'}));
    elseif X > handles.ImagingFunctions.interfaceScanning.HighEndOfRange(1)
        uiwait(warndlg({'X too high, did not move'}));
    elseif Y  < handles.ImagingFunctions.interfaceScanning.LowEndOfRange(2)
        uiwait(warndlg({'Y too low, did not move'}));
    elseif Y > handles.ImagingFunctions.interfaceScanning.HighEndOfRange(2)
        uiwait(warndlg({'Y too high, did not move'}));
    elseif Z < handles.ImagingFunctions.interfaceScanning.LowEndOfRange(3)
        uiwait(warndlg({'Z too low, did not move'}));
    elseif Z > handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3)
        uiwait(warndlg({'Z too high, did not move'}));
    end
    
    handles = handles.ImagingFunctions.QueryPos(handles);
end

function buttonSetCursor_CreateFcn(~, ~, ~)

function StartCounting_Callback(~, ~, handles)
% switch on the SPD only during counting
handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
   

%%%%%Add command to update dwell time%%%%%
%%%%%Masashi 2012 07/26%%%%%%%%%%%%%%%%%%%
DwellTime = str2num(get(handles.DwellScanValue,'String'));
if DwellTime < (1.0/handles.ImagingFunctions.interfaceScanning.SampleRate)
    uiwait(warndlg('Dwell time too small!'));
    set(handles.DwellScanValue,'String',1/handles.ImagingFunctions.interfaceScanning.SampleRate);
    return;
end
handles.ImagingFunctions.TrackerDwellTime = DwellTime;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.ImagingFunctions.TrackerhasAborted = 0;

set(handles.StopCounting,'Enable','on');
cla(handles.axes1,'reset');
set(handles.axes1,'Visible','off');
cla(handles.axes_piezo_stab1,'reset');
set(handles.axes_piezo_stab1,'Visible','off');
cla(handles.axes_piezo_stab2,'reset');
set(handles.axes_piezo_stab2,'Visible','off');
set(handles.NSQDnumber,'Visible','off');
set(handles.TrackingRefCounts,'Visible','on');
set(handles.text27,'Visible','on');
set(handles.text62,'Visible','on');
set(handles.NbAvgShown,'Visible','on');
drawnow();

gobj = findall(0,'Name','Imaging');
guidata(gobj,handles);

VectorReferenceCounts = [];
  
%%%%Masashi 10/26/2012%%
%    pos=cell(4,1);
%    figure();
%%%%%%%%%%%%%%%%%%

while ~handles.ImagingFunctions.TrackerhasAborted
    
    %ashok 1/15/14
%     handles = handles.ImagingFunctions.QueryPos(handles);
    
    
    
    ReferenceCounts = handles.ImagingFunctions.kCountsPerSecond();
    set(handles.TrackingRefCounts,'String',ReferenceCounts);
    
    maxstack = ceil(str2num(get(handles.NbAvgShown,'String')));
   % maxstack = 2000;
    %maxstack=0.5e6;
    tic;
    if maxstack <= 0
        uiwait(warndlg({'Negative value, reversing to standard value of 200'}));
        maxstack = 200;
    end
    set(handles.NbAvgShown,'String',maxstack);
    
    VectorReferenceCounts = [VectorReferenceCounts ReferenceCounts];
    helper = length(VectorReferenceCounts);
    
    if helper > maxstack
        VectorReferenceCounts = VectorReferenceCounts(helper-maxstack+1:helper);
    end
    
    
    
   
    %%%%Masashi 10/26/2012%%
%         subplot(5,1,1);
%         t=0:length(VectorReferenceCounts)-1;
%         time=t*(0.04+DwellTime*(handles.ImagingFunctions.TrackerNumberOfSamples-1));%*handles.ImagingFunctions.interfaceScanning.SampleRate;
%         time=t*0.2397;
%         plot(time, VectorReferenceCounts);
%         xlabel('time');
%         ylabel('counts(kcps)');
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    plot(0:length(VectorReferenceCounts)-1, VectorReferenceCounts,'.-','Parent',handles.imageAxes);
    
    xlabel(handles.imageAxes,'time');
    set(handles.imageAxes,'XTickLabel',{});
    ylabel(handles.imageAxes,'kcps');
    
   
    %%%%Masashi 10/26/2012%%
%    [V_ave,V_std]=handles.ImagingFunctions.MonitorPower();
%             [laser_power,std_laser_power] = PhotodiodeConversionVtomW(V_ave,V_std);
%     pos{4}=[pos{4},laser_power];
%     
%      for k=1:1:3
%                 Pos(k) = handles.ImagingFunctions.interfaceScanning.Pos(k);
%                 pos{k}=[pos{k},Pos(k)];
%             end          
%                     
%                     %positions(:,iterCounter+1)=Pos;
%                     if length(time)<length(pos{1})
%                         toc
%                         break
%                     end
%                     subplot(5,1,2);
%                     plot(time,pos{1});
%                     xlabel('time');     
%                     ylabel('X Pos [\mum]');
% 
%                     subplot(5,1,3);
%                     plot(time,pos{2});
%                     xlabel('time');
%                     ylabel('Y Pos [\mum]');
%                    
%                     subplot(5,1,4);
%                     plot(time,pos{3});
%                     xlabel('time');
%                     ylabel('Z Pos [\mum]');
%                     
%                     subplot(5,1,5);
%                     plot(time,pos{4});
%                     xlabel('time');
%                     ylabel('Laser power(mW)');
%                     
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    drawnow();
end

set(handles.TrackingRefCounts,'Visible','off');
set(handles.text27,'Visible','off');
set(handles.text62,'Visible','off');
set(handles.NbAvgShown,'Visible','off');
set(handles.axes1,'Visible','on');
set(handles.axes_piezo_stab1,'Visible','on');
set(handles.axes_piezo_stab2,'Visible','on');
set(handles.NSQDnumber,'Visible','on');

handles = handles.ImagingFunctions.LoadImagesFromScan(handles);

gobj = findall(0,'Name','Imaging');
guidata(gobj,handles);

function StopCounting_Callback(hObject, ~, handles)

handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);

handles.ImagingFunctions.TrackerhasAborted = 1;

set(hObject,'Enable','off');

function cursorX_Callback(~, ~, ~)

function cursorX_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cursorX_KeyPressFcn(~, ~, handles)
set(handles.buttonSetCursor,'Enable','on');

function cursorY_Callback(~, ~, ~)

function cursorY_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cursorY_KeyPressFcn(~, ~, handles)
set(handles.buttonSetCursor,'Enable','on');

function cursorZ_Callback(~, ~, ~)

function cursorZ_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cursorZ_KeyPressFcn(~, ~, handles)
set(handles.buttonSetCursor,'Enable','on');

function PX_Callback(~, ~, handles)

stepSize = get(handles.stepsizex,'String');
cp = handles.ImagingFunctions.CursorPosition;
cp = cp + [str2num(stepSize) 0 0];
if cp(1) > handles.ImagingFunctions.interfaceScanning.HighEndOfRange(1)
    uiwait(warndlg({'X too high, did not move'}));
else
    handles.ImagingFunctions.CursorPosition = cp;
    handles = handles.ImagingFunctions.SetCursor(handles);
end

function MX_Callback(~, ~, handles)

stepSize = get(handles.stepsizex,'String');
cp = handles.ImagingFunctions.CursorPosition;
cp = cp - [str2num(stepSize) 0 0];
if cp(1) < handles.ImagingFunctions.interfaceScanning.LowEndOfRange(1)
    uiwait(warndlg({'X too low, did not move'}));
else
    handles.ImagingFunctions.CursorPosition = cp;
    handles = handles.ImagingFunctions.SetCursor(handles);
end

function PY_Callback(~, ~, handles)

stepSize = get(handles.stepsizey,'String');
cp = handles.ImagingFunctions.CursorPosition;
cp = cp + [0 str2num(stepSize) 0];
if cp(2)> handles.ImagingFunctions.interfaceScanning.HighEndOfRange(2)
    uiwait(warndlg({'Y too high, did not move'}));
else
    handles.ImagingFunctions.CursorPosition = cp;
    handles = handles.ImagingFunctions.SetCursor(handles);
end

function MY_Callback(~, ~, handles)

stepSize = get(handles.stepsizey,'String');
cp = handles.ImagingFunctions.CursorPosition;
cp = cp - [0 str2num(stepSize) 0];
if cp(2) < handles.ImagingFunctions.interfaceScanning.LowEndOfRange(2)
    uiwait(warndlg({'Y too low, did not move'}));
else
    handles.ImagingFunctions.CursorPosition = cp;
    handles = handles.ImagingFunctions.SetCursor(handles);
end

function PZ_Callback(~, ~, handles)

stepSize = get(handles.stepsizez,'String');
cp = handles.ImagingFunctions.CursorPosition;
cp = cp + [0 0 str2num(stepSize)];
if cp(3)> handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3)
    uiwait(warndlg({'Z too high, did not move'}));
else
    handles.ImagingFunctions.CursorPosition = cp;
    handles = handles.ImagingFunctions.SetCursor(handles);
end

function MZ_Callback(~, ~, handles)

stepSize = get(handles.stepsizez,'String');
cp = handles.ImagingFunctions.CursorPosition;
cp = cp - [0 0 str2num(stepSize)];
if cp(3)  < handles.ImagingFunctions.interfaceScanning.LowEndOfRange(3)
    uiwait(warndlg({'Z too low, did not move'}));
else
    handles.ImagingFunctions.CursorPosition = cp;
    handles = handles.ImagingFunctions.SetCursor(handles);
end

function stepsizex_Callback(~, ~, ~)

function stepsizex_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stepsizey_Callback(~, ~, ~)

function stepsizey_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stepsizez_Callback(~, ~, ~)

function stepsizez_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NbAvgShown_Callback(~, ~, ~)

function NbAvgShown_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% END NAVIGATION PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% IMAGE HANDLING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popupScan_Callback(~, ~, handles)
% Executes on selection change in popupScan.
% This is where you select older images

handles.ImagingFunctions.UpdateScanList(handles);

handles.ImagingFunctions.LoadImagesFromScan(handles);

function popupScan_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sliderZScan_Callback(hObject, ~, handles)

scans = get(handles.popupScan,'String');
selectedScan = scans{get(handles.popupScan,'Value')};

if strcmp(selectedScan,'Current Scan')
    selectedScan = scans{get(handles.popupScan,'Value')+1};
end

% load up images from saved file
fp = getpref('nv','SavedImageDirectory');
SavedScan = load(fullfile(fp,selectedScan));

val = int32((get(handles.sliderZScan,'Value')));
set(handles.sliderZScan,'Value',val);
set(handles.text6,'String',['Z pos = ' num2str(SavedScan.Scan.RangeZ(val))]);

if length(SavedScan.Scan.RangeX) >= length(SavedScan.Scan.RangeY) && length(SavedScan.Scan.RangeX) >= length(SavedScan.Scan.RangeZ) % 'Xyz' scan
    piezo1label = 'z';
    piezo2label = 'y';
elseif length(SavedScan.Scan.RangeY) > length(SavedScan.Scan.RangeX) && length(SavedScan.Scan.RangeY) >= length(SavedScan.Scan.RangeZ) % 'xYz' scan
    piezo1label = 'z';
    piezo2label = 'x';
else % 'xyZ' scan
    piezo1label = 'x (avg over all z)';
    piezo2label = 'y (avg over all z)';
end

handles.ImagingFunctions.PlotImage2D(handles,SavedScan.Scan,SavedScan.Scan.RangeX,SavedScan.Scan.RangeY,'x (\mum)','y (\mum)',piezo1label,piezo2label,1,val);

guidata(hObject, handles);

function sliderZScan_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function findNV_Callback(hObject, ~, handles)
%findNV();
%Gimg=rgb2gray(handles.ConfocalScanDisplayed.ImageData);
Gimg=handles.ConfocalScanDisplayed.ImageData;
xax=handles.ConfocalScanDisplayed.RangeX;
yax=handles.ConfocalScanDisplayed.RangeY;

BW=Gimg>str2double(get(handles.cutoffEdit, 'String'));
rp=regionprops(BW,Gimg,'EquivDiameter','WeightedCentroid');
count=0;
for j=1:size(rp,1)
    nv_pos_x_temp=xax(floor(rp(j).WeightedCentroid(1)));
    nv_pos_y_temp=yax(floor(rp(j).WeightedCentroid(2)));
    if nv_pos_x_temp>=str2num(get(handles.minX,'String')) && nv_pos_x_temp<=str2num(get(handles.maxX,'String')) && nv_pos_y_temp>=str2num(get(handles.minY,'String')) && nv_pos_y_temp<=str2num(get(handles.maxY,'String'))
        count=count+1;
        nv_pos_x(count)= nv_pos_x_temp;
        nv_pos_y(count)= nv_pos_y_temp;
    end
end    

%handles.ImagingFunctions.LoadImagesFromScan(handles);
%filterButton_Callback(1,2,handles)
hold (handles.imageAxes,'on');
scatter(handles.imageAxes,nv_pos_x,nv_pos_y);
hold (handles.imageAxes,'off');
handles.nv_pos_x = nv_pos_x;
handles.nv_pos_y = nv_pos_y;
handles.nv_pos_z = handles.ConfocalScanDisplayed.RangeZ;
guidata(hObject, handles);


function text_power_CreateFcn(~, ~, ~)

function filterButton_Callback(~, ~, handles)

handles.ImagingFunctions.useFilter = 1;
handles.ImagingFunctions.cutoffVal = str2double(get(handles.cutoffEdit, 'String'));
handles.ImagingFunctions.LoadImagesFromScan(handles);

function cutoffEdit_Callback(~, ~, ~)

function cutoffEdit_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% END IMAGE HANDLING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% TOOLBARS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function menuTools_Callback(~, ~, ~)

function menuResetNI_Callback(~, ~, handles)
handles.ImagingFunctions.interfaceDataAcq.ResetDevice();
warndlg('NI Device Reset.');

function menuAutoSave_Callback(hObject, ~, ~)

% toggle the state of the AutoSave check box
switch get(hObject,'checked');
    case 'on'
        set(hObject,'checked','off');
    case 'off'
        set(hObject,'checked','on');
end

function menuPopoutImage_Callback(~, ~, handles)

scans = get(handles.popupScan,'String');
selectedScan = scans{get(handles.popupScan,'Value')};
if strcmp(selectedScan,'Current Scan')
    selectedScan = scans{get(handles.popupScan,'Value')+1};
end

fp = getpref('nv','SavedImageDirectory');
SavedScan = load(fullfile(fp,selectedScan));

hF = figure();
copyobj(handles.imageAxes,hF);
A = get(hF,'Children');
P = get(A,'OuterPosition');
set(A,'OuterPosition',[.2 .2 P(3) P(4)]);
colorbar();

title_line(1) = {selectedScan};

%save other dimensions
if length(SavedScan.Scan.RangeX) > 1 && length(SavedScan.Scan.RangeY) > 1 && length(SavedScan.Scan.RangeZ) > 1
    %3d scan
    title_line(2) = {['z = ' sprintf('%f',SavedScan.Scan.RangeZ(get(handles.sliderZScan,'Value'))) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeX) > 1 && length(SavedScan.Scan.RangeY) > 1
    %2d scan, XY
    title_line(2) = {['z = ' sprintf('%f',SavedScan.Scan.RangeZ) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeX) > 1 && length(SavedScan.Scan.RangeZ) > 1
    %2d scan, XZ
    title_line(2) = {['y = ' sprintf('%f',SavedScan.Scan.RangeY) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeY) > 1 && length(SavedScan.Scan.RangeZ) > 1
    %2d scan, YZ
    title_line(2) = {['x = ' sprintf('%f',SavedScan.Scan.RangeX) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeX) > 1
    %1d scan, X
    title_line(2) = {['y = ' sprintf('%f',SavedScan.Scan.RangeY) '(\mum), z = ' sprintf('%f',SavedScan.Scan.RangeZ) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeY) > 1
    %1d scan, Y
    title_line(2) = {['x = ' sprintf('%f',SavedScan.Scan.RangeX) '(\mum), z = ' sprintf('%f',SavedScan.Scan.RangeZ) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.ConfocalImage.RangeZ) > 1
    %1d scan, Z
    title_line(2) = {['x = ' sprintf('%f',SavedScan.Scan.RangeX) '(\mum), y = ' sprintf('%f',SavedScan.Scan.RangeY) '(\mum)']};
    title(title_line);
end

function menuExportImage_Callback(~,~,handles)

scans = get(handles.popupScan,'String');
selectedScan = scans{get(handles.popupScan,'Value')};
if strcmp(selectedScan,'Current Scan')
    selectedScan = scans{get(handles.popupScan,'Value')+1};
end

fp = getpref('nv','SavedImageDirectory');
SavedScan = load(fullfile(fp,selectedScan));
[fn,fp] = uiputfile({'*.jpg','*.jpeg'},'Save Image...',fullfile(fp,'ExportedImages'));

hF = figure('Visible','off');
copyobj(handles.imageAxes,hF);
A = get(hF,'Children');
P = get(A,'OuterPosition');
set(A,'OuterPosition',[.2 .2 P(3) P(4)]);
colorbar();

title_line(1) = {selectedScan};

%save other dimensions
if length(SavedScan.Scan.RangeX) > 1 && length(SavedScan.Scan.RangeY) > 1 && length(SavedScan.Scan.RangeZ) > 1
    %3d scan
    title_line(2) = {['z = ' sprintf('%f',SavedScan.Scan.RangeZ(get(handles.sliderZScan,'Value'))) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeX) > 1 && length(SavedScan.Scan.RangeY) > 1
    %2d scan, XY
    title_line(2) = {['z = ' sprintf('%f',SavedScan.Scan.RangeZ) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeX) > 1 && length(SavedScan.Scan.RangeZ) > 1
    %2d scan, XZ
    title_line(2) = {['y = ' sprintf('%f',SavedScan.Scan.RangeY) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeY) > 1 && length(SavedScan.Scan.RangeZ) > 1
    %2d scan, YZ
    title_line(2) = {['x = ' sprintf('%f',SavedScan.Scan.RangeX) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeX) > 1
    %1d scan, X
    title_line(2) = {['y = ' sprintf('%f',SavedScan.Scan.RangeY) '(\mum), z = ' sprintf('%f',SavedScan.Scan.RangeZ) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeY) > 1
    %1d scan, Y
    title_line(2) = {['x = ' sprintf('%f',SavedScan.Scan.RangeX) '(\mum), z = ' sprintf('%f',SavedScan.Scan.RangeZ) '(\mum)']};
    title(title_line);
    
elseif length(SavedScan.Scan.RangeZ) > 1
    %1d scan, Z
    title_line(2) = {['x = ' sprintf('%f',SavedScan.Scan.RangeX) '(\mum), y = ' sprintf('%f',SavedScan.Scan.RangeY) '(\mum)']};
    title(title_line);
end


saveas(hF,fullfile(fp,fn));
close(hF);

function toggletoolCursorSet_OffCallback(~, ~, handles)

set(handles.imageAxes,'ButtonDownFcn','');
% also need to set the image as well
C = get(handles.imageAxes,'Children');
if C,
    set(C,'ButtonDownFcn','');
end

function toggletoolCursorSet_OnCallback(~, ~, handles)

handles = handles.ImagingFunctions.SetCursorFromAxes(handles);
%set(handles.imageAxes,'ButtonDownFcn',@(src,evt)handles.ImagingFunctions.SetCursorFromAxes(handles));
% also need to set the image as well
C = get(handles.imageAxes,'Children');
if C,
    set(C,'ButtonDownFcn',@(src,evt)handles.ImagingFunctions.SetCursorFromAxes(handles));
end

function toggletoolCursorSet_ClickedCallback(~, ~, ~)

function toolSetToAxes_ClickedCallback(~, ~, handles)

XL = get(handles.imageAxes,'XLim');
YL = get(handles.imageAxes,'YLim');

if length(handles.ConfocalScanDisplayed.RangeX) > 1 && length(handles.ConfocalScanDisplayed.RangeY) > 1 && length(handles.ConfocalScanDisplayed.RangeZ) > 1
    %3d scan
    set(handles.maxX,'String',max(XL));
    set(handles.maxY,'String',max(YL));
    set(handles.minX,'String',min(XL));
    set(handles.minY,'String',min(YL));
    zvalue = handles.ConfocalScanDisplayed.RangeZ(get(handles.sliderZScan,'Value'));
    set(handles.maxZ,'String',zvalue);
    set(handles.minZ,'String',zvalue);
    
elseif length(handles.ConfocalScanDisplayed.RangeX) > 1 && length(handles.ConfocalScanDisplayed.RangeY) > 1
    %2d scan, XY
    set(handles.maxX,'String',max(XL));
    set(handles.maxY,'String',max(YL));
    set(handles.minX,'String',min(XL));
    set(handles.minY,'String',min(YL));
    zvalue = handles.ConfocalScanDisplayed.RangeZ;
    set(handles.maxZ,'String',zvalue);
    set(handles.minZ,'String',zvalue);
    
elseif length(handles.ConfocalScanDisplayed.RangeX) > 1 && length(handles.ConfocalScanDisplayed.RangeZ) > 1
    %2d scan, XZ
    set(handles.maxX,'String',max(XL));
    set(handles.maxZ,'String',max(YL));
    set(handles.minX,'String',min(XL));
    set(handles.minZ,'String',min(YL));
    yvalue = handles.ConfocalScanDisplayed.RangeY;
    set(handles.maxY,'String',yvalue);
    set(handles.minY,'String',yvalue);
    
elseif length(handles.ConfocalScanDisplayed.RangeY) > 1 && length(handles.ConfocalScanDisplayed.RangeZ) > 1
    %2d scan, YZ
    set(handles.maxY,'String',max(XL));
    set(handles.maxZ,'String',max(YL));
    set(handles.minY,'String',min(XL));
    set(handles.minZ,'String',min(YL));
    xvalue = handles.ConfocalScanDisplayed.RangeX;
    set(handles.maxX,'String',xvalue);
    set(handles.minX,'String',xvalue);
    
elseif  length(handles.ConfocalScanDisplayed.RangeX) > 1 %1d scan, X
    
    set(handles.maxX,'String',max(XL));
    set(handles.minX,'String',min(XL));
    yvalue = handles.ConfocalScanDisplayed.RangeY;
    set(handles.maxY,'String',yvalue);
    set(handles.minY,'String',yvalue);
    zvalue = handles.ConfocalScanDisplayed.RangeZ;
    set(handles.maxZ,'String',zvalue);
    set(handles.minZ,'String',zvalue);
    
    
elseif  length(handles.ConfocalScanDisplayed.RangeY) > 1 %1d scan, Y
    
    set(handles.maxY,'String',max(XL));
    set(handles.minY,'String',min(XL));
    xvalue = handles.ConfocalScanDisplayed.RangeX;
    set(handles.maxX,'String',xvalue);
    set(handles.minX,'String',xvalue);
    zvalue = handles.ConfocalScanDisplayed.RangeZ;
    set(handles.maxZ,'String',zvalue);
    set(handles.minZ,'String',zvalue);
    
    
    
else % 1d scan, Z length(handles.ConfocalScanDisplayed.RangeZ) > 1
    
    set(handles.maxZ,'String',max(XL));
    set(handles.minZ,'String',min(XL));
    xvalue = handles.ConfocalScanDisplayed.RangeX;
    set(handles.maxX,'String',xvalue);
    set(handles.minX,'String',xvalue);
    yvalue = handles.ConfocalScanDisplayed.RangeY;
    set(handles.maxY,'String',yvalue);
    set(handles.minY,'String',yvalue);
    
    
    
end

function menuFile_Callback(~, ~, ~)

%%%%% END TOOLBARS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% DISPLAY SCAN PARAMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function enz_Callback(~, ~, ~)

function ptszdisp_Callback(~, ~, ~)

function ptszdisp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxzdisp_Callback(~, ~, ~)

function maxzdisp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minzdisp_Callback(~, ~, ~)

function minzdisp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function eny_Callback(~, ~, ~)

function ptsydisp_Callback(~, ~, ~)

function ptsydisp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxydisp_Callback(~, ~, ~)

function maxydisp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minydisp_Callback(~, ~, ~)

function minydisp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minxdisp_Callback(~, ~, ~)

function minxdisp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxxdisp_Callback(~, ~, ~)

function maxxdisp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ptsxdisp_Callback(~, ~, ~)

function ptsxdisp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function enx_Callback(~, ~, ~)

%%%%% END DISPLAY SCAN PARAMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% LASER TOGGLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function toggle_LaserOnOff_Callback(hObject, ~, handles)
% Executes on button press in toggle_LaserOnOff.

LaserOn=get(hObject,'Value');
if LaserOn
    
    if handles.QEGhandles.pulse_mode == 1 %use PB
        
        handles.ImagingFunctions.interfacePulseGen.StartProgramming();
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.StopProgramming();
        handles.ImagingFunctions.interfacePulseGen.PBStart();
         handles.ImagingFunctions.interfacePulseGen.PBStop();
        
    elseif handles.QEGhandles.pulse_mode == 0 %use AWG
        handles.ImagingFunctions.interfacePulseGen.open();
        handles.ImagingFunctions.interfacePulseGen.writeToSocket('AWGCONTROL:RMODE CONTINUOUS');
        
        NullShape = zeros(6*1e4,1); %length here is arbitrary
        OnShape = ones(6*1e4,1);
        
        handles.ImagingFunctions.interfacePulseGen.clear_waveforms();
        handles.ImagingFunctions.interfacePulseGen.create_waveform('IMAGING',NullShape,OnShape,NullShape);
        handles.ImagingFunctions.interfacePulseGen.setSourceWaveForm(1,'IMAGING');
        
        handles.ImagingFunctions.interfacePulseGen.SetChannelOn(1);
        handles.ImagingFunctions.interfacePulseGen.close();
        
        % neglect simu cases
        
    end
    
    set(handles.toggle_LaserOnOff,'String','Laser On')
    set(handles.toggle_LaserOnOff,'ForegroundColor',[0.847 0.161 0])
    
else
    
    if handles.QEGhandles.pulse_mode == 1 %use PB
        
        handles.ImagingFunctions.interfacePulseGen.StartProgramming();
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(0,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.StopProgramming();
        handles.ImagingFunctions.interfacePulseGen.PBStart();
        handles.ImagingFunctions.interfacePulseGen.PBStop();
        
    elseif handles.QEGhandles.pulse_mode == 0 %use AWG
        
        handles.ImagingFunctions.interfacePulseGen.open();
        handles.ImagingFunctions.interfacePulseGen.SetChannelOff(1);
        handles.ImagingFunctions.interfacePulseGen.close();
        
    end
    
    set(handles.toggle_LaserOnOff,'String','Laser Off')
    set(handles.toggle_LaserOnOff,'ForegroundColor',[0.0 0.487 0])
    
end

%%%%% END LASER TOGGLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% TRACKING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function TrackingSave_Callback(~,~,handles)
%%%%%Add command to update dwell time%%%%%
%%%%%Masashi 2012 07/26%%%%%%%%%%%%%%%%%%%
DwellTime = str2num(get(handles.DwellScanValue,'String'));
if DwellTime < (1.0/handles.ImagingFunctions.interfaceScanning.SampleRate)
    uiwait(warndlg('Dwell time too small!'));
    set(handles.DwellScanValue,'String',1/handles.ImagingFunctions.interfaceScanning.SampleRate);
    return;
end
handles.ImagingFunctions.TrackerDwellTime = DwellTime;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.ImagingFunctions.SaveTrack(handles);

function TrackingStart_Callback(~, eventdata, handles)

set(handles.TrackStop, 'Enable', 'on');
LaserOn=get(handles.toggle_LaserOnOff,'Value');
if ~LaserOn
    set(handles.toggle_LaserOnOff,'Value',1);
    toggle_LaserOnOff_Callback(handles.toggle_LaserOnOff, eventdata, handles)
    hwd=warndlg('Turning on the laser');
    pause(1)
    close(hwd)
end

handles.ImagingFunctions.TrackCenter(handles);

set(handles.TrackStop, 'Enable', 'off');

function TrackStop_Callback(hObject, ~, handles)

handles.ImagingFunctions.TrackerhasAborted = 1;

set(hObject,'Enable','off');

function TrackingRefCounts_CreateFcn(~, ~, ~)

function Thresh_Callback(~, ~, ~)

function Thresh_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MaxIter_Callback(~, ~, ~)

function MaxIter_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function InitStepX_Callback(~, ~, ~)

function InitStepX_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function InitStepY_Callback(~, ~, ~)

function InitStepY_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function InitStepZ_Callback(~, ~, ~)

function InitStepZ_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinStepX_Callback(~, ~, ~)

function MinStepX_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinStepY_Callback(~, ~, ~)

function MinStepY_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinStepZ_Callback(~, ~, ~)

function MinStepZ_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CurrStepX_Callback(~, ~, ~)

function CurrStepX_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CurrStepY_Callback(~, ~, ~)

function CurrStepY_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CurrStepZ_Callback(~, ~, ~)

function CurrStepZ_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% END TRACKING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in move_obj.
function move_obj_Callback(hObject, eventdata, handles)
% hObject    handle to move_obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
absolutePosition = str2num(get(handles.Pos_obj, 'String'))*1e-3;
zaber_obj = handles.zaber_obj;  
[ret err] = ZaberMoveAbsolute(zaber_obj, zaber_obj.deviceIndex, absolutePosition);
set(handles.slider_obj, 'Value', ret(2)*1e3);
set(handles.Pos_obj, 'String', num2str(ret(2)*1e3));
refresh_obj_Callback(hObject, eventdata,handles);

% --- Executes on button press in home_obj.
function home_obj_Callback(hObject, eventdata, handles)
% hObject    handle to home_obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%zaber_obj = handles.zaber_obj;
%[ret err] = ZaberHome(zaber_obj, zaber_obj.deviceIndex);
%refresh_obj_Callback(hObject, eventdata,handles);



% --- Executes on button press in refresh_obj.
function refresh_obj_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zaber_obj = handles.zaber_obj;
[ret err] = ZaberReturnCurrentPosition(zaber_obj, zaber_obj.deviceIndex);
set(handles.slider_obj, 'Value', ret(2)*1e3);
set(handles.Pos_obj, 'String', num2str(ret(2)*1e3));



function Pos_obj_Callback(hObject, eventdata, handles)
% hObject    handle to Pos_obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pos_obj as text
%        str2double(get(hObject,'String')) returns contents of Pos_obj as a double
set(handles.slider_obj, 'Value', str2num(get(handles.Pos_obj, 'String')));

function Pos_obj_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function slider_obj_Callback(hObject, eventdata, handles)
% hObject    handle to slider_obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%disp(get(hObject, 'Value'));
set(handles.Pos_obj, 'String', get(hObject, 'Value'));
move_obj_Callback(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function slider_obj_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function imageAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate imageAxes


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider_obj.
function slider_obj_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider_obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SelectRegion.
function SelectRegion_Callback(hObject, eventdata, handles)
% hObject    handle to SelectRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rect=getrect(handles.imageAxes);
xmin=rect(1);
ymin=rect(2);
width=rect(3);
height=rect(4);

set(handles.minX,'String',num2str(xmin));
set(handles.maxX,'String',num2str(xmin+width));
set(handles.minY,'String',num2str(ymin));
set(handles.maxY,'String',num2str(ymin+height));
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);


% --- Executes on button press in coarsefine_toggle.
function coarsefine_toggle_Callback(hObject, eventdata, handles)
zaber_obj = handles.zaber_obj;
FineOn=get(hObject,'Value');
if FineOn
    set(handles.coarsefine_toggle,'String','Fine');
    set(handles.coarsefine_toggle,'ForegroundColor',[0.847 0.161 0]);
    maxrange=zaber_obj.maxPosition(zaber_obj.deviceIndex);
    set(handles.slider_obj, 'SliderStep',[1e-6/maxrange,10e-6/maxrange]);
else
    set(handles.coarsefine_toggle,'String','Coarse');
    set(handles.coarsefine_toggle,'ForegroundColor',[0.0 0.487 0]);
    maxrange=zaber_obj.maxPosition(zaber_obj.deviceIndex);
    set(handles.slider_obj, 'SliderStep',[10e-6/maxrange,100e-6/maxrange]);
end
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);


% --- Executes on button press in enableZcoarse.
function enableZcoarse_Callback(hObject, eventdata, handles)
% hObject    handle to enableZcoarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enableZcoarse



function pointsZcoarse_Callback(hObject, eventdata, handles)
% hObject    handle to pointsZcoarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pointsZcoarse as text
%        str2double(get(hObject,'String')) returns contents of pointsZcoarse as a double


% --- Executes during object creation, after setting all properties.
function pointsZcoarse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pointsZcoarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxZcoarse_Callback(hObject, eventdata, handles)
% hObject    handle to maxZcoarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxZcoarse as text
%        str2double(get(hObject,'String')) returns contents of maxZcoarse as a double


% --- Executes during object creation, after setting all properties.
function maxZcoarse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxZcoarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minZcoarse_Callback(hObject, eventdata, handles)
% hObject    handle to minZcoarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minZcoarse as text
%        str2double(get(hObject,'String')) returns contents of minZcoarse as a double


% --- Executes during object creation, after setting all properties.
function minZcoarse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minZcoarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in piezoZ_toggle.
function piezoZ_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to piezoZ_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of piezoZ_toggle
ActOn=get(hObject,'Value');
if ActOn
    set(handles.piezoZ_toggle,'String','Actuator');
    set(handles.piezoZ_toggle,'ForegroundColor',[0.847 0.161 0]);
else
    set(handles.piezoZ_toggle,'String','Piezo');
    set(handles.piezoZ_toggle,'ForegroundColor',[0.0 0.487 0]);
end
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);


% --- Executes on button press in square_select.
function square_select_Callback(hObject, eventdata, handles)
% hObject    handle to square_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear width middle
xmin=str2num(get(handles.minX,'String'));
xmax=str2num(get(handles.maxX,'String'));
ymin=str2num(get(handles.minY,'String'));
ymax=str2num(get(handles.maxY,'String'));

if (xmax-xmin)>=(ymax-ymin)
    width=(xmax-xmin);
    middle=(ymax+ymin)/2;
    ymax=middle+0.5*width;
    ymin=middle-0.5*width;
elseif (xmax-xmin)<(ymax-ymin)
    width=(ymax-ymin);
    middle=(xmax+xmin)/2;
    xmax=middle+0.5*width;
    xmin=middle-0.5*width;
end

set(handles.minX,'String',num2str(xmin));
set(handles.maxX,'String',num2str(xmax));
set(handles.minY,'String',num2str(ymin));
set(handles.maxY,'String',num2str(ymax));
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);


% --- Executes on button press in set_surface.
function set_surface_Callback(hObject, eventdata, handles)
% hObject    handle to set_surface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.surface(1)=str2num(get(handles.Pos_obj,'String'));
%handles.surface(1)=str2num(get(handles.Pos_obj,'String'))+handles.set_surface_cursor_value*1e-3;
handles.surface(1)=handles.zscan_start +handles.set_surface_cursor_value*1e-3;
handles.surface(2)=handles.ImagingFunctions.interfaceScanning.Pos(3);
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);




function depth_Callback(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth as text
%        str2double(get(hObject,'String')) returns contents of depth as a double
refresh_obj_Callback(hObject, eventdata,handles);
calc_depth=(str2num(get(handles.Pos_obj,'String')) - handles.surface)*1e3;
set(handles.depth,'String',num2str(calc_depth));
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);


% --- Executes during object creation, after setting all properties.
function depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in display_depth.
function display_depth_Callback(hObject, eventdata, handles)
% hObject    handle to display_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_obj_Callback(hObject, eventdata,handles);
piezo_pos=handles.ImagingFunctions.interfaceScanning.Pos(3);
calc_depth1=(str2num(get(handles.Pos_obj,'String')) - handles.surface(1))*1e3;
calc_depth2=(-piezo_pos + handles.surface(2));
calc_depth=calc_depth1+calc_depth2;
set(handles.depth,'String',num2str(calc_depth));
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);


% --------------------------------------------------------------------
function depth_cursor_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to depth_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 CP = get(handles.imageAxes,'CurrentPoint');
 handles.set_surface_cursor_value = CP(1,2);
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);

% --------------------------------------------------------------------
function depth_cursor_OffCallback(hObject, eventdata, handles)
% hObject    handle to depth_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.imageAxes,'ButtonDownFcn','');
% also need to set the image as well
C = get(handles.imageAxes,'Children');
if C,
    set(C,'ButtonDownFcn','');
end
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);


% --------------------------------------------------------------------
function depth_cursor_OnCallback(hObject, eventdata, handles)
% hObject    handle to depth_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 CP = get(handles.imageAxes,'CurrentPoint');
 handles.set_surface_cursor_value = CP(1,2);
 C = get(handles.imageAxes,'Children');
if C,
    set(C,'ButtonDownFcn','');
end
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);



function speed_slope_Callback(hObject, eventdata, handles)
% hObject    handle to speed_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed_slope as text
%        str2double(get(hObject,'String')) returns contents of speed_slope as a double


% --- Executes during object creation, after setting all properties.
function speed_slope_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slope_Callback(hObject, eventdata, handles)
% hObject    handle to slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slope as text
%        str2double(get(hObject,'String')) returns contents of slope as a double


% --- Executes during object creation, after setting all properties.
function slope_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in scan_slope.
function scan_slope_Callback(hObject, eventdata, handles)
% hObject    handle to scan_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in stop_slope.
function stop_slope_Callback(hObject, eventdata, handles)
% hObject    handle to stop_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.slope_scan,'String','Stopped');
set(handles.slope_scan,'ForegroundColor',[0.0 0.487 0]);
zaber_motorX = handles.zaber_motorX;
zaber_motorY = handles.zaber_motorY;
[ret err] = ZaberStop(zaber_motorX, zaber_motorX.deviceIndex);
[ret err] = ZaberStop(zaber_motorY, zaber_motorY.deviceIndex);


function sign_motorX_Callback(hObject, eventdata, handles)
% hObject    handle to sign_motorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sign_motorX as text
%        str2double(get(hObject,'String')) returns contents of sign_motorX as a double


% --- Executes during object creation, after setting all properties.
function sign_motorX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sign_motorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sign_motorY_Callback(hObject, eventdata, handles)
% hObject    handle to sign_motorY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sign_motorY as text
%        str2double(get(hObject,'String')) returns contents of sign_motorY as a double


% --- Executes during object creation, after setting all properties.
function sign_motorY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sign_motorY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in slope_scan.
function slope_scan_Callback(hObject, eventdata, handles)
% hObject    handle to slope_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of slope_scan
SlopeScan=get(hObject,'Value');
while (SlopeScan)
    set(handles.slope_scan,'String','Scanning');
    set(handles.slope_scan,'ForegroundColor',[0.847 0.161 0]);
    zaber_motorX = handles.zaber_motorX;
    zaber_motorY = handles.zaber_motorY;
    speed=str2num(get(handles.speed_slope, 'String'))*1e-6;
    slope=str2num(get(handles.slope, 'String'));
    sign_X=str2num(get(handles.sign_motorX, 'String'));
    sign_Y=str2num(get(handles.sign_motorY, 'String'));
    
    [ret err] = ZaberMoveAtConstantSpeed(zaber_motorX, zaber_motorX.deviceIndex, sign_X*speed);
    pause(1);
    [ret err] = ZaberStop(zaber_motorX, zaber_motorX.deviceIndex);
    [ret err] = ZaberMoveAtConstantSpeed(zaber_motorY, zaber_motorY.deviceIndex, speed*sign_Y*slope);
    pause(1);
    [ret err] = ZaberStop(zaber_motorY, zaber_motorY.deviceIndex);
    SlopeScan=get(hObject,'Value');
end
SlopeScan=get(hObject,'Value');
if ~SlopeScan
    set(handles.slope_scan,'String','Press Stop');
    set(handles.slope_scan,'ForegroundColor',[0.847 0.161 0]);
end
gobj=findall(0,'Name','Imaging');
guidata(gobj,handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over coarsefine_toggle.
function coarsefine_toggle_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to coarsefine_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in export_params.
function export_params_Callback(hObject, eventdata, handles)
% hObject    handle to export_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fp = getpref('nv','SavedImageDirectory');
ppt_path=[fp 'temp.pptx'];
h = actxserver('PowerPoint.Application');
try
    h.ActivePresentation.Close;
catch exception
end

%h.Quit

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

% bring in image
cImage = handles.ConfocalScanDisplayed;
cutoff=str2num(get(handles.cutoffEdit,'String'));
cImage.ImageData(cImage.ImageData>cutoff) = cutoff;

argData = cImage.ImageData;
argX=cImage.RangeX;
argY=cImage.RangeY;
textxlabel='x (\mum)';
textylabel='y (\mum)';
figH=1;
figure(figH);clf;

imagesc(argX,argY,argData);
axis square;
set(gca,'YDir','normal');
xlabel(textxlabel);
ylabel(textylabel);
axis([min(argX), max(argX), min(argY), max(argY)]);
h = colorbar('EastOutside');
set(get(h,'ylabel'),'String','kcps');

%refresh parameters
refresh_motorX_Callback(hObject, eventdata,handles);
refresh_motorY_Callback(hObject, eventdata,handles);
refresh_obj_Callback(hObject, eventdata,handles);


% get parameters
Pos_motorX=str2num(get(handles.Pos_motorX,'String'));
Pos_motorY=str2num(get(handles.Pos_motorY,'String'));
Pos_obj=str2num(get(handles.Pos_obj,'String'));
cursorX=str2num(get(handles.cursorX,'String'));
cursorY=str2num(get(handles.cursorY,'String'));
cursorZ=str2num(get(handles.cursorZ,'String'));
depth=str2num(get(handles.depth,'String'));

% save
exportToPPTX('open',ppt_path);
slideNum = exportToPPTX('addslide');
fprintf('Added slide %d\n',slideNum);
exportToPPTX('addpicture',figH);
exportToPPTX('addtext',sprintf('Actuators: X %2.4f  Y %2.4f  Z %2.4f\nPiezo:         X %2.4f  Y %2.4f  Z %2.4f\nDepth:           %2.4f',...
    Pos_motorX,Pos_motorY,Pos_obj,cursorX,cursorY,cursorZ,depth),'Position',[1 0 10 1.5],'FontSize',30);
%exportToPPTX('addtext',sprintf('Piezo: X %2.3f  Y %2.3f  Z %2.3f',minX,minX,minX),'Position',[1 0.5 10 0.5],'FontSize',30);
%exportToPPTX('addtext',sprintf('Depth: %2.3f',minX),'Position',[1 1 10 0.5],'FontSize',30);

close(figH);
newFile = exportToPPTX('save',ppt_path);
exportToPPTX('close');
h = actxserver('PowerPoint.Application');
h.Presentations.Open(ppt_path);
h.Visible = 1; % make the window show up


% --- Executes on button press in overnight.
function overnight_Callback(hObject, eventdata, handles)
% hObject    handle to overnight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Make a new pptX

fp = getpref('nv','SavedImageDirectory');
fn=get(handles.ov_filename,'String');
ppt_path=[fp '\' fn '.pptx'];
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

% Get Parameters and make grid
ov_startX=str2num(get(handles.ov_startX,'String'));
ov_startY=str2num(get(handles.ov_startY,'String'));
ov_gridX=str2num(get(handles.ov_gridX,'String'));
ov_gridY=str2num(get(handles.ov_gridY,'String'));

cutoff=str2num(get(handles.ov_cutoff,'String'));
res=1e-3*str2num(get(handles.ov_resolution,'String'));

gridX=[ov_startX:res:ov_startX+(ov_gridX-1)*res];
gridY=[ov_startY:res:ov_startY+(ov_gridY-1)*res];

% Set Scan Parameters
set(handles.minX,'String',num2str(20));
set(handles.maxX,'String',num2str(20 + res*1e3));
set(handles.pointsX,'String',num2str(400));
set(handles.pointsY,'String',num2str(400));
set(handles.minY,'String',num2str(20));
set(handles.maxY,'String',num2str(20 + res*1e3));
set(handles.DwellScanValue,'String',num2str(0.0096));
handles.ConfocalScan.DwellTime=str2num(get(handles.DwellScanValue,'String'));

set(handles.enableX,'Value',1);
set(handles.enableY,'Value',1);
set(handles.enableZ,'Value',0);


for ind_Y=1:size(gridY,2)
    for ind_X=1:size(gridX,2)
        % MOVE ACTUATORS
        set(handles.Pos_motorX,'String',num2str(gridX(ind_X)));
        set(handles.Pos_motorY,'String',num2str(gridY(ind_Y)));
        move_motorX_Callback(hObject, eventdata, handles);
        pause(1);
        move_motorY_Callback(hObject, eventdata, handles);
        pause(1);
        
        
        %SCAN
        buttonSaveScan_Callback(hObject,eventdata,handles);
        pause(2);
        buttonScan_Callback(hObject, eventdata, handles);
        pause(2); %give it enough time to load new image
        % GET IMAGE
        scans = get(handles.popupScan,'String');
        selectedScan = scans{get(handles.popupScan,'Value')};
        fp = getpref('nv','SavedImageDirectory');
        selectedScan= scans{get(handles.popupScan,'Value')+1}; %loads the first exp in the list, that corresponds to the displayed 'Current Experiment'
        SavedScan = load(fullfile(fp,selectedScan));
        handles.ConfocalScanDisplayed = SavedScan.Scan;
        
        
        %get Image
        cImage = handles.ConfocalScanDisplayed;
        cImage.ImageData(cImage.ImageData>cutoff) = cutoff;
        
        argData = cImage.ImageData;
        argX=cImage.RangeX;
        argY=cImage.RangeY;
        textxlabel='x (\mum)';
        textylabel='y (\mum)';
        figH=1;
        figure(figH);clf;
        
        imagesc(argX,argY,argData);
        axis square;
        set(gca,'YDir','normal');
        xlabel(textxlabel);
        ylabel(textylabel);
        axis([min(argX), max(argX), min(argY), max(argY)]);
        h = colorbar('EastOutside');
        set(get(h,'ylabel'),'String','kcps');
        
        % get parameters
        Pos_motorX=str2num(get(handles.Pos_motorX,'String'));
        Pos_motorY=str2num(get(handles.Pos_motorY,'String'));
        Pos_obj=str2num(get(handles.Pos_obj,'String'));
        cursorX=str2num(get(handles.cursorX,'String'));
        cursorY=str2num(get(handles.cursorY,'String'));
        cursorZ=str2num(get(handles.cursorZ,'String'));
        depth=str2num(get(handles.depth,'String'));

        % save
        
        fp = getpref('nv','SavedImageDirectory');
        fn=get(handles.ov_filename,'String');
        ppt_path=[fp '\' fn '.pptx'];
        h = actxserver('PowerPoint.Application');
        try
            h.ActivePresentation.Close;
        catch exception
        end
        
        exportToPPTX('open',ppt_path);
        slideNum = exportToPPTX('addslide');
        fprintf('Added slide %d\n',slideNum);
        exportToPPTX('addpicture',figH,'Position',[1 2 6*1.25 6]);
        exportToPPTX('addtext',sprintf('Actuators: X %2.4f  Y %2.4f  Z %2.4f\nPiezo:         X %2.4f  Y %2.4f  Z %2.4f\nDepth:           %2.4f',...
       Pos_motorX,Pos_motorY,Pos_obj,cursorX,cursorY,cursorZ,depth),'Position',[1 0 10 1.5],'FontSize',30);
        
        close(figH);
        newFile = exportToPPTX('save',ppt_path);
        exportToPPTX('close');
        h = actxserver('PowerPoint.Application');
        h.Presentations.Open(ppt_path);
        h.Visible = 1; % make the window show up
        pause(2);
    end
end


function ov_startX_Callback(hObject, eventdata, handles)
% hObject    handle to ov_startX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ov_startX as text
%        str2double(get(hObject,'String')) returns contents of ov_startX as a double


% --- Executes during object creation, after setting all properties.
function ov_startX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ov_startX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ov_startY_Callback(hObject, eventdata, handles)
% hObject    handle to ov_startY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ov_startY as text
%        str2double(get(hObject,'String')) returns contents of ov_startY as a double


% --- Executes during object creation, after setting all properties.
function ov_startY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ov_startY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ov_gridX_Callback(hObject, eventdata, handles)
% hObject    handle to ov_gridX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ov_gridX as text
%        str2double(get(hObject,'String')) returns contents of ov_gridX as a double


% --- Executes during object creation, after setting all properties.
function ov_gridX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ov_gridX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ov_gridY_Callback(hObject, eventdata, handles)
% hObject    handle to ov_gridY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ov_gridY as text
%        str2double(get(hObject,'String')) returns contents of ov_gridY as a double


% --- Executes during object creation, after setting all properties.
function ov_gridY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ov_gridY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ov_resolution_Callback(hObject, eventdata, handles)
% hObject    handle to ov_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ov_resolution as text
%        str2double(get(hObject,'String')) returns contents of ov_resolution as a double


% --- Executes during object creation, after setting all properties.
function ov_resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ov_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ov_cutoff_Callback(hObject, eventdata, handles)
% hObject    handle to ov_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ov_cutoff as text
%        str2double(get(hObject,'String')) returns contents of ov_cutoff as a double


% --- Executes during object creation, after setting all properties.
function ov_cutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ov_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ov_filename_Callback(hObject, eventdata, handles)
% hObject    handle to ov_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ov_filename as text
%        str2double(get(hObject,'String')) returns contents of ov_filename as a double


% --- Executes during object creation, after setting all properties.
function ov_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ov_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nvautomizer.
function nvautomizer_Callback(hObject, eventdata, handles)
% hObject    handle to nvautomizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)'
NVautomizer();
gobj = findall(0,'Name','NVautomizer');
pos=get(gobj,'Position');
set(gobj,'Position',[711.6000   23.3846  240.2000   46.3846]);
 
%WinOnTop(NVautomizer,true);
guidata(hObject,handles);


% --- Executes on button press in measure_power.
function measure_power_Callback(hObject, eventdata, handles)
% hObject    handle to measure_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[laser_power_in_V,std_laser_power_in_V,power_array_in_V] = handles.ImagingFunctions.MonitorPower();
set(handles.opt_power,'String',num2str(laser_power_in_V));



% --- Executes on button press in Magnet_Align.
function Magnet_Align_Callback(hObject, eventdata, handles)
% hObject    handle to Magnet_Align (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
magnet();
gobj = findall(0,'Name','magnet');
%set(gobj,'Position',[384.0000 4.3077 256.0000 72.9231]);

set(gobj,'Position',[0 3.0769 384.0000 74.1538]);
guidata(hObject,handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider_motorX.
function slider_motorX_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider_motorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stage_align.
function stage_align_Callback(hObject, eventdata, handles)
% hObject    handle to stage_align (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stage();
gobj = findall(0,'Name','stage');
%set(gobj,'Position',[384.0000 4.3077 256.0000 72.9231]);

set(gobj,'Position',[0 3.0769 384.0000 74.1538]);
guidata(hObject,handles);


% --- Executes on button press in toggle_valve1.
function toggle_valve1_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_valve1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_valve1

LaserOn=get(hObject,'Value');
if LaserOn
    
%     handles.ImagingFunctions.interfacePulseGen.setLines(1,4);
%     handles.ImagingFunctions.interfacePulseGen.PBStart();
%     handles.ImagingFunctions.interfacePulseGen.PBStop();
    
handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
 handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);

    set(handles.toggle_valve1,'String','Valve 1 On')
    set(handles.toggle_valve1,'ForegroundColor',[0.847 0.161 0])
    
else
    
    
%     handles.ImagingFunctions.interfacePulseGen.setLines(0,4);
%     handles.ImagingFunctions.interfacePulseGen.PBStart();
%     handles.ImagingFunctions.interfacePulseGen.PBStop();
%     
handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0;
 handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);

    set(handles.toggle_valve1,'String','Valve 1 Off')
    set(handles.toggle_valve1,'ForegroundColor',[0.0 0.487 0])
end


% --- Executes on button press in toggle_valve2.
function toggle_valve2_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_valve2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_valve2
LaserOn=get(hObject,'Value');
if LaserOn

handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(2)=5;
 handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(2);

    set(handles.toggle_valve2,'String','Valve 2 On')
    set(handles.toggle_valve2,'ForegroundColor',[0.847 0.161 0])
    
else

handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(2)=0;
 handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(2);

    set(handles.toggle_valve2,'String','Valve 2Off')
    set(handles.toggle_valve2,'ForegroundColor',[0.0 0.487 0])
end


% --- Executes on button press in pines.
function pines_Callback(hObject, eventdata, handles)
% hObject    handle to pines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NVpines();
gobj = findall(0,'Name','NVpines');
%pos=get(gobj,'Position');
%set(gobj,'Position',[0    3.0769  272.0000   50.0769]);
 
%WinOnTop(NVpines,true);
guidata(hObject,handles);
