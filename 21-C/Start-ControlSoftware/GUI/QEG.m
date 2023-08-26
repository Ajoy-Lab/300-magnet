%%%%% INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = QEG(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @QEG_OpeningFcn, ...
    'gui_OutputFcn',  @QEG_OutputFcn, ...
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

function QEG_OpeningFcn(hObject, ~, handles, varargin)

% Choose default command line output for QEG
handles.output = hObject;

movegui(handles.figure1,'northwest');

handles.flag_imaging = 0;
handles.flag_experiment = 0;

% check to make sure all preferences are set
CheckPrefs();

%initialize variable to default use AWG
handles.pulse_mode = 1;
set(handles.pb_radiobutton,'Value',1);
%set(handles.awg_radiobutton,'Value',0);

set(handles.sequencer_panel,'SelectionChangeFcn',@sequencer_panel_SelectionChangeFcn);

% Update handles structure
guidata(hObject, handles);

function varargout = QEG_OutputFcn(~, ~, handles)
varargout{1} = handles.output;

function figure1_CloseRequestFcn(hObject, ~, handles)

if (handles.flag_imaging + handles.flag_experiment) ~= 0 %if there is at least one software window opened
    
    selection = questdlg('Do you really want to close all opened software windows?',...
        'Close Request Function',...
        'Yes','No','Yes');
    
    switch selection
        case 'Yes'
            
            if handles.flag_imaging
                gobj = findall(0,'Name','Imaging');
                close(gobj);
            end
            if handles.flag_experiment
                gobj = findall(0,'Name','Experiment');
                close(gobj);
            end
            
            delete(gcf)
            
        case 'No'
            return;
    end
    
else
    delete(gcf);
    
end

%%%%% END INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% OTHER GUIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function button_imaging_Callback(hObject, ~, handles)

set(handles.pb_radiobutton,'Enable', 'off');
set(handles.awg_radiobutton,'Enable', 'off');
set(handles.simulate_checkbox, 'Enable', 'off');
Imaging();
monitor_pos=get(0,'MonitorPositions');
gobj = findall(0,'Name','Imaging');
set(gobj,'Position',[0    3.0769  272.0000   50.0769]);
set(hObject,'Enable', 'off');
handles.flag_imaging = 1;
gobj = findall(0,'Name','Imaging');
set(gobj,'Position',[0    3.0769  272.0000   50.0769]);
Experiment();
NVpines();
NVautomizer();
LaserDomeGUI4(); %LASER DOME GUI
Init_Stopwatch();
gobj = findall(0,'Name','Experiment');




function button_experiment_Callback(hObject, ~, handles)

set(handles.pb_radiobutton,'Enable', 'off');
set(handles.awg_radiobutton,'Enable', 'off');

% try to find Imaging; if it is not opened, open it
apps = getappdata(0);
fN = fieldnames(apps);
ImagingOpen=1;
% for k=1:numel(fN),
%     if sum(ishandle(getfield(apps,fN{k}))) && isa(getfield(apps,fN{k}),'double'), % take sum in case many handles
%         name = get(getfield(apps,fN{k}),'Name');
%         if strcmp('Imaging',name),
%             hFig = getfield(apps,fN{k});
%             ImagingHandles = guidata(hFig);
%             ImagingOpen=0;
%         end
%     end
% end
% if ImagingOpen
%     hFig=Imaging;
%     ImagingHandles = guidata(hFig);
% end
gobj = findall(0,'Name','Imaging');
set(gobj,'Position',[0    3.0769  272.0000   50.0769]);


Experiment();
gobj = findall(0,'Name','Experiment');

set(gobj,'Position',[608.0000    4.3846  384.0000   74.0769]);

set(hObject,'Enable', 'off');
set(handles.button_imaging,'Enable', 'off');
handles.flag_experiment = 1;
handles.flag_imaging = 1;
guidata(hObject, handles);

%%%%% END OTHER GUIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% CHOICE OF PULSE SEQUENCER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function simulate_checkbox_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')==1
    switch handles.pulse_mode
        case 1
            handles.pulse_mode = 2 % simulate PB
        case 0
            handles.pulse_mode = 3; % simulate AWG
    end
else
    switch handles.pulse_mode
        case 2
            handles.pulse_mode = 1; % use PB
        case 3
            handles.pulse_mode = 0; % use AWG
    end
end

guidata(hObject, handles);

function sequencer_panel_SelectionChangeFcn(hObject, eventdata, handles)

handles = guidata(hObject);

switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'pb_radiobutton'
        switch handles.pulse_mode
            case 0
                handles.pulse_mode = 1;
            case 1
                handles.pulse_mode = 1;
            case 2
                handles.pulse_mode = 2;
            case 3
                handles.pulse_mode = 2;
        end
    case 'awg_radiobutton'
        switch handles.pulse_mode
            case 0
                handles.pulse_mode = 0;
            case 1
                handles.pulse_mode = 0;
            case 2
                handles.pulse_mode = 3;
            case 3
                handles.pulse_mode = 3;
        end
end

%updates the handles structure
guidata(hObject, handles);

function awg_radiobutton_Callback(hObject, eventdata, handles)

function pb_radiobutton_Callback(hObject, eventdata, handles)

%%%%% END CHOICE OF PULSE SEQUENCER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
