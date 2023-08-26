function varargout = stage(varargin)
% STAGE MATLAB code for stage.fig
%      STAGE, by itself, creates a new STAGE or raises the existing
%      singleton*.
%
%      H = STAGE returns the handle to a new STAGE or the handle to
%      the existing singleton*.
%
%      STAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STAGE.M with the given input arguments.
%
%      STAGE('Property','Value',...) creates a new STAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stage

% Last Modified by GUIDE v2.5 19-Mar-2015 13:24:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stage_OpeningFcn, ...
                   'gui_OutputFcn',  @stage_OutputFcn, ...
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


% --- Executes just before stage is made visible.
function stage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stage (see VARARGIN)

% Choose default command line output for stage

gobj = findall(0,'Name','Imaging');
handles.Imaginghandles = guidata(gobj);

gobj = findall(0,'Name','magnet');
handles.Magnethandles = guidata(gobj);

handles.stagefunctions = stagefunctions();

axis(handles.magnet_axes,'square');
ylabel(handles.magnet_axes,'Counts [cps]');

handles.output = hObject;

%delete(instrfind);
% s_x = serial('com3');
% s_y=  serial('com4');

s_x = serial('com8');
s_y=  serial('com7');

set(handles.ref_table,'Data',[]);
set(handles.new_table,'Data',[]);
set(handles.target_table,'Data',[]);
set(handles.new_target_table,'Data',[]);
set(handles.auto_table,'Data',[]);

 handles.auto_points_x={};
 handles.auto_points_y={};
 handles.auto_speed={};
 handles.auto_track_point={};
 handles.auto_averages={};
 
% Update handles structure
guidata(hObject, handles);

% ---- Initializing Zaber and getting the position of the stage ---------%
addpath(genpath('ZaberInstrumentDriver'));
% This is for X
disp('Initalizing stage stage in X');
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
disp('Initalizing stage stage in Y');
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


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stage wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stage_OutputFcn(hObject, eventdata, handles) 
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

% absolutePosition = str2num(get(handles.Pos_x, 'String'))*1e-3;
% zaber_x = handles.zaber_x;  
% [ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, absolutePosition);
% set(handles.slider_x, 'Value', ret(2)*1e3);
% set(handles.Pos_x, 'String', num2str(ret(2)*1e3));

handles.stagefunctions.move_stage_x(handles);
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


% --- Executes on button press in move_y.
function move_y_Callback(hObject, eventdata, handles)
% hObject    handle to move_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% absolutePosition = str2num(get(handles.Pos_y, 'String'))*1e-3;
% zaber_y = handles.zaber_y;  
% [ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, absolutePosition);
% set(handles.slider_y, 'Value', ret(2)*1e3);
% set(handles.Pos_y, 'String', num2str(ret(2)*1e3));

handles.stagefunctions.move_stage_y(handles);
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


% --- Executes on button press in refresh_magnet.
function refresh_magnet_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_magnet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)\

% THIS CODE HAS MOVED TO STAGEFUNCTIONS TO BE CALLED BY AUTOMIZER

% zaber_x = handles.zaber_x;
% [ret err] = ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex);
% set(handles.slider_x, 'Value', ret(2)*1e3);
% set(handles.Pos_x, 'String', num2str(ret(2)*1e3));
% 
% zaber_y = handles.zaber_y;
% [ret err] = ZaberReturnCurrentPosition(zaber_y, zaber_y.deviceIndex);
% set(handles.slider_y, 'Value', ret(2)*1e3);
% set(handles.Pos_y, 'String', num2str(ret(2)*1e3));

handles.stagefunctions.refresh_stage(handles);

guidata(hObject, handles);



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

% 1D scan X
if get(handles.check_scanx,'Value')==1 && get(handles.check_scanz,'Value')==0 && get(handles.check_scany,'Value')==0
    
    fp = getpref('nv','SavedExpDirectory');
    
    a = datestr(now,'yyyy-mm-dd-HHMMSS');
    fn=['stage-1D-X-' a];
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
    fn=['stage-1D-Y-' a];
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2D XY scan    
elseif get(handles.check_scanz,'Value')==0 && get(handles.check_scanx,'Value')==1 && get(handles.check_scany,'Value')==1    
    
    fp = getpref('nv','SavedExpDirectory');
    
    a = datestr(now,'yyyy-mm-dd-HHMMSS');
    fn=['stage-2D-XY-' a];
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
            %handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
            
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
            argData_display=argDatamean;
                
            %argData_disp=argData;
            if cutoff~=0
            argData_disp(argData_disp>cutoff)=cutoff;
            argData_display(argData_display>cutoff)=cutoff;
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
    
    clear handles.argData_display;
    handles.Arg_x=Arg_x;
    handles.Arg_y=Arg_y;
    handles.argData_display=argData_display;
    handles.textxlabel=textxlabel;
    handles.textylabel=textylabel;
    
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
guidata(hObject, handles);



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

%for XY
if exist('Arg_x','var') && exist('Arg_y','var')
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


%for XY
if isempty(Arg_x)==0 && isempty(Arg_y)==0 

textxlabel=handles.textxlabel;textylabel=handles.textylabel;
cutoff=str2num(get(handles.magnet_cutoff, 'String'));
if cutoff~=0
    argData_disp(argData_disp>cutoff)=cutoff;
end

imagesc(Arg_x,Arg_y,argData_disp,'Parent',handles.magnet_axes);





colormap(handles.magnet_axes,hot);
set(handles.magnet_axes,'YDir','normal');
set(handles.magnet_axes,'ticklength',[0.02 0.02]);
set(handles.magnet_axes,'tickdir','out');
daspect (handles.magnet_axes,[1 1 1]);

xlabel(handles.magnet_axes,textxlabel);
ylabel(handles.magnet_axes,textylabel);
set(handles.magnet_axes, 'XLim',[min(Arg_x) max(Arg_x)], 'YLim',[min(Arg_y) max(Arg_y)]);

% hold (handles.magnet_axes,'on');
% 
% C=corner(argData_disp,'QualityLevel',0.3);
% scatter(handles.magnet_axes,Arg_x(C(:,1)),Arg_y(C(:,2)));
% hold (handles.magnet_axes,'off');

% BW1 = edge(argData_disp,'prewitt');;
% 
% figure();imshow(BW1)


% [B,L] = bwboundaries(argData_disp,'holes');
%
% for k = 1:length(B)
%     boundary = B{k};
%     plot(handles.magnet_axes,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 10)
% end
% hold (handles.magnet_axes,'off');
    
grid (handles.magnet_axes);
set(handles.magnet_axes,'layer','top');

h = colorbar('peer',handles.magnet_axes,'EastOutside');
set(get(h,'ylabel'),'String','cps');

title(handles.magnet_axes,handles.file);
drawnow();

end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
s_x = serial('com3');
s_y=  serial('com4');


ZaberClose(handles.zaber_x);
ZaberClose(handles.zaber_y);

delete(hObject);





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
fn=['stage-auto-' a];
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
        xmin= new_x_val-range_x/4;
        xmax= new_x_val+range_x/4;
        
        if xmin<0 
            xmin=0; 
        end
        if xmax>50 
            xmax=50 ;
        end;
        
        range_x=xmax-xmin;
        
        ymin= new_y_val-range_y/4;
        ymax= new_y_val+range_y/4;
        
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


[v b]=max(smooth(argDatamean,3));
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

[v b]=max(smooth(argDatamean,3));
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
function scan_zmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in add_ref.
function add_ref_Callback(hObject, eventdata, handles)
% hObject    handle to add_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ref_table_data=get(handles.ref_table,'Data');
handles.ref_table_data{end+1,1} =  handles.cursor_value(1) ;
handles.ref_table_data{end,2} =handles.cursor_value(2);
handles.ref_table_data{end,3} =false;
set(handles.ref_table,'Data',handles.ref_table_data);
guidata(hObject, handles);


% --- Executes on button press in remove_ref.
function remove_ref_Callback(hObject, eventdata, handles)
% hObject    handle to remove_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tabledata=get(handles.ref_table,'Data');
handles.ref_table_data=get(handles.ref_table,'Data');
for i=1:length([tabledata{:,3}]);
    if tabledata{i,3}==1;
        handles.ref_table_data(i,:)=[];    
    end
end
set(handles.ref_table,'Data',handles.ref_table_data);
guidata(hObject, handles);

% --- Executes on button press in clear_ref.
function clear_ref_Callback(hObject, eventdata, handles)
% hObject    handle to clear_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 handles.ref_table_data(:,:)=[];
set(handles.ref_table,'Data',handles.ref_table_data);
guidata(hObject, handles);


% --- Executes on button press in add_new.
function add_new_Callback(hObject, eventdata, handles)
% hObject    handle to add_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.new_table_data=get(handles.new_table,'Data');
handles.new_table_data{end+1,1} =  handles.cursor_value(1) ;
handles.new_table_data{end,2} =handles.cursor_value(2);
handles.new_table_data{end,3} =false;
set(handles.new_table,'Data',handles.new_table_data);
guidata(hObject, handles);



% --- Executes on button press in remove_new.
function remove_new_Callback(hObject, eventdata, handles)
% hObject    handle to remove_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabledata=get(handles.new_table,'Data');
handles.new_table_data=get(handles.new_table,'Data');
for i=1:length([tabledata{:,3}]);
    if tabledata{i,3}==1;
        handles.new_table_data(i,:)=[];    
    end
end
set(handles.new_table,'Data',handles.new_table_data);
guidata(hObject, handles);

% --- Executes on button press in clear_new.
function clear_new_Callback(hObject, eventdata, handles)
% hObject    handle to clear_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 handles.new_table_data(:,:)=[];
set(handles.new_table,'Data',handles.new_table_data);
guidata(hObject, handles);

function stage_cursor_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to depth_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  CP = get(handles.magnet_axes,'CurrentPoint');

[CP(1),CP(2)]=ginput(1);
handles.cursor_value = CP(1,:);
gobj=findall(0,'Name','stage');
guidata(gobj,handles);

% --------------------------------------------------------------------
function stage_cursor_OffCallback(hObject, eventdata, handles)
% hObject    handle to depth_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set(handles.magnet_axes,'ButtonDownFcn','');
% % also need to set the image as well
% C = get(handles.magnet_axes,'Children');
% if C,
%     set(C,'ButtonDownFcn','');
% end
% gobj=findall(0,'Name','stage');
% guidata(gobj,handles);


% --------------------------------------------------------------------
function stage_cursor_OnCallback(hObject, eventdata, handles)
% hObject    handle to depth_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  CP = get(handles.magnet_axes,'CurrentPoint');
%  handles.cursor_value = CP(1,:);
%  C = get(handles.magnet_axes,'Children');
% if C,
%     set(C,'ButtonDownFcn','');
% end
% gobj=findall(0,'Name','stage');
% guidata(gobj,handles);
% 


% --- Executes on button press in transform.
function transform_Callback(hObject, eventdata, handles)
% hObject    handle to transform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
H=vision.GeometricTransformEstimator('Transform','Nonreflective similarity');
handles.ref_table_data=get(handles.ref_table,'Data');
handles.new_table_data=get(handles.new_table,'Data');
for i=1:length([handles.ref_table_data{:,3}]);
    a(i,:)=cell2mat([handles.ref_table_data(i,1) handles.ref_table_data(i,2)]);
    b(i,:)=cell2mat([handles.new_table_data(i,1) handles.new_table_data(i,2)]);
end
tform=step(H,a,b)

handles.target_data=get(handles.target_table,'Data');
handles.new_target_table_data=get(handles.new_target_table,'Data');

for i=1:length([handles.target_table_data{:,3}]);
    c(i,:)=cell2mat([handles.target_table_data(i,1) handles.target_table_data(i,2) 1]);
    d(i,:)=c(i,:)*tform;
    handles.new_target_table_data{i,1} =  d(i,1);
      handles.new_target_table_data{i,2} =  d(i,2);
end
set(handles.new_target_table,'Data',handles.new_target_table_data);


    
    
    

% --- Executes on button press in add_target.
function add_target_Callback(hObject, eventdata, handles)
% hObject    handle to add_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.target_table_data=get(handles.target_table,'Data');
handles.target_table_data{end+1,1} =  handles.cursor_value(1) ;
handles.target_table_data{end,2} =handles.cursor_value(2);
handles.target_table_data{end,3} =false;
set(handles.target_table,'Data',handles.target_table_data);
guidata(hObject, handles);

% --- Executes on button press in remove_target.
function remove_target_Callback(hObject, eventdata, handles)
% hObject    handle to remove_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabledata=get(handles.target_table,'Data');
handles.target_table_data=get(handles.target_table,'Data');
for i=1:length([tabledata{:,3}]);
    if tabledata{i,3}==1;
        handles.target_table_data(i,:)=[];    
    end
end
set(handles.target_table,'Data',handles.target_table_data);
guidata(hObject, handles);


% --- Executes on button press in clear_target.
function clear_target_Callback(hObject, eventdata, handles)
% hObject    handle to clear_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 handles.target_table_data(:,:)=[];
set(handles.target_table,'Data',handles.target_table_data);
guidata(hObject, handles);

% --- Executes on button press in add_new_target.
function add_new_target_Callback(hObject, eventdata, handles)
% hObject    handle to add_new_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in remove_new_target.
function remove_new_target_Callback(hObject, eventdata, handles)
% hObject    handle to remove_new_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear_new_target.
function clear_new_target_Callback(hObject, eventdata, handles)
% hObject    handle to clear_new_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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


% --- Executes on button press in add_stage_auto.
function add_stage_auto_Callback(hObject, eventdata, handles)
% hObject    handle to add_stage_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.auto_table_data=get(handles.auto_table,'Data');
handles.auto_table_data{end+1,1} = str2num(get(handles.scan_xmin, 'String'));
handles.auto_table_data{end,2} = str2num(get(handles.scan_xmax, 'String'));
handles.auto_table_data{end,3} = str2num(get(handles.scan_ymin, 'String'));
handles.auto_table_data{end,4} = str2num(get(handles.scan_ymax, 'String'));
handles.auto_table_data{end,5} =false;
handles.auto_table_data{end,6} =false;

handles.auto_points_x{end+1} = str2num(get(handles.points_x, 'String'));
handles.auto_points_y{end+1} = str2num(get(handles.points_y, 'String'));
handles.auto_speed{end+1} = str2num(get(handles.speed, 'String'));
handles.auto_track_point{end+1} = str2num(get(handles.track_point, 'String'));
handles.auto_averages{end+1} = str2num(get(handles.magnet_average, 'String'));



set(handles.auto_table,'Data',handles.auto_table_data);
guidata(hObject, handles);

% --- Executes on button press in remove_stage_auto.
function remove_stage_auto_Callback(hObject, eventdata, handles)
% hObject    handle to remove_stage_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tabledata=get(handles.auto_table,'Data');
handles.auto_table_data=get(handles.auto_table,'Data');
for i=1:length([tabledata{:,3}]);
    if tabledata{i,5}==1;
        handles.auto_table_data(i,:)=[];    
        handles.auto_points_x(i) = [];
        handles.auto_points_y(i) = [];
        handles.auto_speed(i) = [];
        handles.auto_track_point(i) = [];
        handles.auto_averages(i) = [];
    end
end
set(handles.auto_table,'Data',handles.auto_table_data);

guidata(hObject, handles);


% --- Executes on button press in clear_stage_auto.
function clear_stage_auto_Callback(hObject, eventdata, handles)
% hObject    handle to clear_stage_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 handles.auto_table_data(:,:)=[];
set(handles.auto_table,'Data',handles.auto_table_data);
 handles.auto_points_x={};
 handles.auto_points_y={};
 handles.auto_speed={};
 handles.auto_track_point={};
 handles.auto_averages={};
 
guidata(hObject, handles)

% --- Executes on button press in stage_auto.
function stage_auto_Callback(hObject, eventdata, handles)
% hObject    handle to stage_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabledata=get(handles.auto_table,'Data');
handles.auto_table_data=get(handles.auto_table,'Data');
for i=1:length([tabledata{:,5}]);
    set(handles.scan_xmin, 'String',num2str(handles.auto_table_data{i,1}));
    set(handles.scan_xmax, 'String',num2str(handles.auto_table_data{i,2}));
    set(handles.scan_ymin, 'String',num2str(handles.auto_table_data{i,3}));
    set(handles.scan_ymax, 'String',num2str(handles.auto_table_data{i,4}));
    set(handles.points_x, 'String',num2str(handles.auto_points_x{i}));
    set(handles.points_y, 'String',num2str(handles.auto_points_y{i}));
    set(handles.speed, 'String',num2str(handles.auto_speed{i}));
    set(handles.track_point, 'String',num2str(handles.auto_track_point{i}));
    set(handles.magnet_average, 'String',num2str(handles.auto_averages{i}));
    
    set(handles.check_scanx,'Value',1);
    set(handles.check_scany,'Value',1);
    
    
    magnet_scan_Callback(hObject, eventdata, handles);
   pause(2);
    
    
end




% --- Executes on button press in stop_stage_auto.
function stop_stage_auto_Callback(hObject, eventdata, handles)
% hObject    handle to stop_stage_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in edit_stage_auto.
function edit_stage_auto_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stage_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_satge_auto.
function push_satge_auto_Callback(hObject, eventdata, handles)
% hObject    handle to push_satge_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in target_table.
function target_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to target_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

handles.target_table_data=get(handles.target_table,'Data');
set(handles.target_table,'Data',handles.target_table_data);
guidata(hObject, handles);


% --- Executes on button press in stage_scan.
function stage_scan_Callback(hObject, eventdata, handles)
% hObject    handle to stage_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fp = getpref('nv','SavedExpDirectory');
a = datestr(now,'yyyy-mm-dd-HHMMSS');
fn=['scan-' a];

ppt_path=[fp '\' fn '.pptx'];
mat_path=[fp '\' fn '.mat'];

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


for j=1:30
if get(handles.StopAllScan,'Value')==1;
      break;
end
    
    
set(handles.Pos_x, 'String', num2str(13.9047));
move_x_Callback(hObject, eventdata, handles);

set(handles.Pos_y, 'String', num2str(11.476));
move_y_Callback(hObject, eventdata, handles);

yPos=str2num(get(handles.Magnethandles.Pos_y, 'String'));
set(handles.Magnethandles.Pos_y, 'String', num2str(yPos-0.02));
handles.Magnethandles.magnetfunctions.move_stage_y(handles.Magnethandles);

set(handles.Magnethandles.Pos_z, 'String', num2str(24.8));
handles.Magnethandles.magnetfunctions.move_stage_z(handles.Magnethandles);

handles.Magnethandles.magnetfunctions.refresh_stage(handles.Magnethandles);

yPos=str2num(get(handles.Magnethandles.Pos_y, 'String'));
set(handles.Magnethandles.Pos_y, 'String', num2str(yPos+0.04));
handles.Magnethandles.magnetfunctions.move_stage_y(handles.Magnethandles);

set(handles.Magnethandles.Pos_z, 'String', num2str(28));
handles.Magnethandles.magnetfunctions.move_stage_z(handles.Magnethandles);

handles.Magnethandles.magnetfunctions.refresh_stage(handles.Magnethandles);

 magnet_scan_Callback(hObject, eventdata, handles);
% 
% h = actxserver('PowerPoint.Application');
% try
%     h.ActivePresentation.Close;
% catch exception
% end
% 
% figH=2;figure(figH);clf;set(figH, 'color', 'white');
% 
% imagesc(handles.Arg_x,handles.Arg_y,handles.argData_display);
%     colormap(hot);
%    
%     daspect([1 1 1]);
%    
%     
%     xlabel(handles.textxlabel);
%     ylabel(handles.textylabel);
% %     set('XLim',[min(handles.Arg_x) max(handles.Arg_x)], 'YLim',[min(handles.Arg_y) max(handles.Arg_y)]);
% %     h = colorbar(figH,'peer','EastOutside');
% %     set(get(h,'ylabel'),'String','cps');
%     grid();
%   drawnow();WinOnTop(figH, true);
% exportToPPTX('open',ppt_path);slideNum = exportToPPTX('addslide');fprintf('Added slide %d\n',slideNum);
% exportToPPTX('addpicture',figH,'Position',[1.5 1 8 6]); %PUT in the figure
% close(figH);
% 
% % put data in ppt
% new_y_val=(yPos+0.04);
% exportToPPTX('addtext',sprintf('y: %2.4f ', ...
%             new_y_val),'Position',[4.5 7 12 1.5],'FontSize',20);
% 
% newFile = exportToPPTX('save',ppt_path);
% exportToPPTX('close');
% h = actxserver('PowerPoint.Application');
% h.Presentations.Open(ppt_path);
% h.Visible = 1; % make the window show up
% 
end



% --- Executes on button press in stage_stop.
function stage_stop_Callback(hObject, eventdata, handles)
% hObject    handle to stage_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in StopAllScan.
function StopAllScan_Callback(hObject, eventdata, handles)
% hObject    handle to StopAllScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StopAllScan
