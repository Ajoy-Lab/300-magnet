%%%%% INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = Imaging_copy(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...f
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Imaging_copy_OpeningFcn, ...
    'gui_OutputFcn',  @Imaging_copy_OutputFcn, ...
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

% --- Executes just before Imaging_copy is made visible.
function Imaging_copy_OpeningFcn(hObject, ~, handles, varargin)

% Choose default command line output for Imaging_copy
handles.output = hObject;

% be able to access the functions in ImagingFunctions
handles.ImagingFunctions = ImagingFunctions();

% Pass on handles from QEG
gobj = findall(0,'Name','QEG');
handles.QEGhandles = guidata(gobj);
handles.QEGhandles.flag_imaging = 1;

% init devices
[hObject,handles] = InitDevices(hObject,handles);

% init Piezo position
set(handles.cursorX,'String',handles.ImagingFunctions.interfaceScanning.Pos(1));
set(handles.cursorY,'String',handles.ImagingFunctions.interfaceScanning.Pos(2));
set(handles.cursorZ,'String',handles.ImagingFunctions.interfaceScanning.Pos(3));

%set params in scan panel
set(handles.minX,'String',handles.ImagingFunctions.interfaceScanning.LowEndOfRange(1));
set(handles.minY,'String',handles.ImagingFunctions.interfaceScanning.LowEndOfRange(2));
set(handles.minZ,'String',handles.ImagingFunctions.interfaceScanning.LowEndOfRange(3));

set(handles.maxX,'String',handles.ImagingFunctions.interfaceScanning.HighEndOfRange(1));
set(handles.maxY,'String',handles.ImagingFunctions.interfaceScanning.HighEndOfRange(2));
set(handles.maxZ,'String',handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3));

set(handles.pointsX,'String',handles.ImagingFunctions.NumPoints(1));
set(handles.pointsY,'String',handles.ImagingFunctions.NumPoints(2));
set(handles.pointsZ,'String',handles.ImagingFunctions.NumPoints(3));

set(handles.DwellScanValue,'String',1/handles.ImagingFunctions.interfaceScanning.SampleRate);

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

function [hObject,handles] = InitDevices(hObject,handles)

fp = getpref('nv','SavedInitializationDirectory');
current_path = pwd;
cd(fp);
script = 'Imaging_InitScript.m';
[hObject,handles] = feval(script(1:end-2),hObject,handles);
cd(current_path);

handles.ImagingFunctions.SetStatus(handles,sprintf('Init script has been run',script));

% --- Outputs from this function are returned to the command line.
function varargout = Imaging_copy_OutputFcn(~, ~, handles)
varargout{1} = handles.output;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, handles)

% clear all NI tasks
handles.ImagingFunctions.interfaceDataAcq.ResetDevice();

if handles.QEGhandles.pulse_mode == 1
    %Closes Pulse Blaster
    handles.ImagingFunctions.interfacePulseGen.PBStop();
    handles.ImagingFunctions.interfacePulseGen.PBClose();
elseif handles.QEGhandles.pulse_mode == 0 %use AWG
    %Closes AWG
    handles.ImagingFunctions.interfacePulseGen.open();
    handles.ImagingFunctions.interfacePulseGen.AWGStop();
    handles.ImagingFunctions.interfacePulseGen.reset();
    pause(5); %needs about 5 sec to reset
    handles.ImagingFunctions.interfacePulseGen.close();
    handles.ImagingFunctions.interfacePulseGen.delete();
end

%Closes connection to Piezo
handles.ImagingFunctions.interfaceScanning.CloseConnection();

apps = getappdata(0);
fN = fieldnames(apps);
for k=1:numel(fN),
    if sum(ishandle(getfield(apps,fN{k}))) && isa(getfield(apps,fN{k}),'double'), % take sum in case many handles
        name = get(getfield(apps,fN{k}),'Name');
        if strcmp('Experiment',name),
            close(name);
        end
    end
end

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

if MaxVal(3)> handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3)
    uiwait(warndlg('Z too high, out of range!'));
    set(handles.maxZ,'String',handles.ImagingFunctions.MaxValues(3));
    return;
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
    
    handles = handles.ImagingFunctions.QueryPos(handles);
    
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

function findNV_Callback(~, ~, ~)
findNV();

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
