function varargout = LaserDomeGUI4(varargin)
% LaserDomeGUI4 MATLAB code for LaserDomeGUI4.fig
%      LaserDomeGUI4, by itself, creates a new LaserDomeGUI4 or raises the existing
%      singleton*.
%
%      H = LaserDomeGUI4 returns the handle to a new LaserDomeGUI4 or the handle to
%      the existing singleton*.
%
%      LaserDomeGUI4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LaserDomeGUI4.M with the given input arguments.
%
%      LaserDomeGUI4('Property','Value',...) creates a new LaserDomeGUI4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LaserDomeGUI4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LaserDomeGUI4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LaserDomeGUI4

% Last Modified by GUIDE v2.5 07-Dec-2020 13:03:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LaserDomeGUI4_OpeningFcn, ...
                   'gui_OutputFcn',  @LaserDomeGUI4_OutputFcn, ...
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


% --- Executes just before LaserDomeGUI4 is made visible.
function LaserDomeGUI4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LaserDomeGUI4 (see VARARGIN)

% Choose default command line output for LaserDomeGUI4
handles.output = hObject;

%master vectors containing the values to be modified by the GUI
set(handles.toggle_b2l6,'value',0);
set(handles.toggle_b1l6,'value',0);
set(handles.toggle_b3l12,'value',0);
set(handles.toggle_b3l5,'value',0);
set(handles.toggle_b3l4,'value',0);
set(handles.toggle_b2l11,'value',0);
set(handles.toggle_b3l6,'value',0);
set(handles.toggle_b2l12,'value',0);
set(handles.toggle_b1l11,'value',0);
set(handles.toggle_b1l12,'value',0);
set(handles.toggle_b3l11,'value',0);
set(handles.toggle_b3l10,'value',0);
set(handles.toggle_b2l7,'value',0);
set(handles.toggle_b2l8,'value',0);
set(handles.toggle_b2l9,'value',0);
set(handles.toggle_b2l10,'value',0);
set(handles.toggle_b2l3,'value',0);
set(handles.toggle_b2l4,'value',0);
set(handles.toggle_b1l4,'value',0);
set(handles.toggle_b1l10,'value',0);
set(handles.toggle_b2l5,'value',0);
set(handles.toggle_b1l5,'value',0);
set(handles.toggle_b1l2,'value',0);
set(handles.toggle_b3l7,'value',0);
set(handles.toggle_b3l8,'value',0);
set(handles.toggle_b3l9,'value',0);
set(handles.toggle_b1l7,'value',0);
set(handles.toggle_b2l2,'value',0);
set(handles.toggle_b1l3,'value',0);
set(handles.toggle_b1l8,'value',0);
set(handles.toggle_b1l1,'value',0);
handles.mastervectorboard1 = [1 0 0 0 0 0 0 0 0 0 0 0 0];
handles.mastervectorboard2 = [2 0 0 0 0 0 0 0 0 0 0 0 0];
handles.mastervectorboard3 = [3 0 0 0 0 0 0 0 0 0 0 0 0];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LaserDomeGUI4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LaserDomeGUI4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in push_configuration. Put last in code
function push_configuration_Callback(hObject, eventdata, handles)

for j=1
        
    mastervectorboard1 = handles.mastervectorboard1;
    mastervectorboard2 = handles.mastervectorboard2;
    mastervectorboard3 = handles.mastervectorboard3;
    
    save('C:\300 magnet\21-C\Initialization\NV1\boardconfig.mat', 'mastervectorboard1', 'mastervectorboard2', 'mastervectorboard3')

% for  j=1
%     mastervectorboard1 = handles.mastervectorboard1;
%     mastervectorboard2 = handles.mastervectorboard2;
%     mastervectorboard3 = handles.mastervectorboard3;
% 
%     string_leftcarrot = '<';
%     string_rightcarrot = '>';
% 
%     %mastervectorboard1;
%     string_mastervectorboard1 = mat2str(mastervectorboard1);
%     string_mastervectorboard1_nobracket = string_mastervectorboard1(2:end-1);
%     sendData1_spaces = ['<' string_mastervectorboard1_nobracket '>'];
%     sendData1 = sendData1_spaces(find(~isspace(sendData1_spaces)))
% 
%     %mastervectorboard2;
%     string_mastervectorboard2 = mat2str(mastervectorboard2);
%     string_mastervectorboard2_nobracket = string_mastervectorboard2(2:end-1);
%     sendData2_spaces = ['<' string_mastervectorboard2_nobracket '>'];
%     sendData2 = sendData2_spaces(find(~isspace(sendData2_spaces)))
% 
%     %mastervectorboard3;
%     string_mastervectorboard3 = mat2str(mastervectorboard3);
%     string_mastervectorboard3_nobracket = string_mastervectorboard3(2:end-1);
%     sendData3_spaces = ['<' string_mastervectorboard3_nobracket '>'];
%     sendData3 = sendData3_spaces(find(~isspace(sendData3_spaces)))
% 
% 
%     laser_board1{1}=sendData1;
%     laser_board2{1}=sendData2;
%     laser_board3{1}=sendData3;
%     sendtoboard(laser_board1);
%     sendtoboard(laser_board2);
%     sendtoboard(laser_board3);


end
disp('Board Config Saved')
% 


% --- Executes on button press in all_off.
function all_off_Callback(hObject, eventdata, handles)
for j = 1:12
    if handles.mastervectorboard1(j+1) == 1
        handles.mastervectorboard1(j+1) = 0;
        handles.mastervectorboard2(j+1) = 0;
        handles.mastervectorboard3(j+1) = 0;
    elseif handles.mastervectorboard1(j+1) == 0
        handles.mastervectorboard1(j+1) = 0;
        handles.mastervectorboard2(j+1) = 0;
        handles.mastervectorboard3(j+1) = 0;
    end
    set(handles.toggle_b2l6,'value',0);
    set(handles.toggle_b1l6,'value',0);
    set(handles.toggle_b3l12,'value',0);
    set(handles.toggle_b3l5,'value',0);
    set(handles.toggle_b3l4,'value',0);
    set(handles.toggle_b2l11,'value',0);
    set(handles.toggle_b3l6,'value',0);
    set(handles.toggle_b2l12,'value',0);
    set(handles.toggle_b1l11,'value',0);
    set(handles.toggle_b1l12,'value',0);
    set(handles.toggle_b3l11,'value',0);
    set(handles.toggle_b3l10,'value',0);
    set(handles.toggle_b2l7,'value',0);
    set(handles.toggle_b2l8,'value',0);
    set(handles.toggle_b2l9,'value',0);
    set(handles.toggle_b2l10,'value',0);
    set(handles.toggle_b2l3,'value',0);
    set(handles.toggle_b2l4,'value',0);
    set(handles.toggle_b1l4,'value',0);
    set(handles.toggle_b1l10,'value',0);
    set(handles.toggle_b2l5,'value',0);
    set(handles.toggle_b1l5,'value',0);
    set(handles.toggle_b1l2,'value',0);
    set(handles.toggle_b3l7,'value',0);
    set(handles.toggle_b3l8,'value',0);
    set(handles.toggle_b3l9,'value',0);
    set(handles.toggle_b1l7,'value',0);
    set(handles.toggle_b2l2,'value',0);
    set(handles.toggle_b1l3,'value',0);
    set(handles.toggle_b1l8,'value',0);
    set(handles.toggle_b1l1,'value',0);
    handles.mastervectorboard1(2) = 0;
    handles.mastervectorboard2(2) = 0;
    handles.mastervectorboard3(2) = 0;
    handles.mastervectorboard3(3) = 0;
    handles.mastervectorboard3(4) = 0;
end
guidata(hObject, handles);

% --- Executes on button press in all_on.
function all_on_Callback(hObject, eventdata, handles)
for j = 1:12
    if handles.mastervectorboard1(j+1) == 0
        handles.mastervectorboard1(j+1) = 1;
        handles.mastervectorboard2(j+1) = 1;
        handles.mastervectorboard3(j+1) = 1;
    elseif handles.mastervectorboard1(j+1) == 1
        handles.mastervectorboard1(j+1) = 1;
        handles.mastervectorboard2(j+1) = 1;
        handles.mastervectorboard3(j+1) = 1;
    end
    handles.mastervectorboard1(j+1)=1;
    handles.mastervectorboard2(j+1)=1;
    handles.mastervectorboard3(j+1)=1;
    set(handles.toggle_b2l6,'value',1);
    set(handles.toggle_b1l6,'value',1);
    set(handles.toggle_b3l12,'value',1);
    set(handles.toggle_b3l5,'value',1);
    set(handles.toggle_b3l4,'value',1);
    set(handles.toggle_b2l11,'value',1);
    set(handles.toggle_b3l6,'value',1);
    set(handles.toggle_b2l12,'value',1);
    set(handles.toggle_b1l11,'value',1);
    set(handles.toggle_b1l12,'value',1);
    set(handles.toggle_b3l11,'value',1);
    set(handles.toggle_b3l10,'value',1);
    set(handles.toggle_b2l7,'value',1);
    set(handles.toggle_b2l8,'value',1);
    set(handles.toggle_b2l9,'value',1);
    set(handles.toggle_b2l10,'value',1);
    set(handles.toggle_b2l3,'value',1);
    set(handles.toggle_b2l4,'value',1);
    set(handles.toggle_b1l4,'value',1);
    set(handles.toggle_b1l10,'value',1);
    set(handles.toggle_b2l5,'value',1);
    set(handles.toggle_b1l5,'value',1);
    set(handles.toggle_b1l2,'value',1);
    set(handles.toggle_b3l7,'value',1);
    set(handles.toggle_b3l8,'value',1);
    set(handles.toggle_b3l9,'value',1);
    set(handles.toggle_b1l7,'value',1);
    set(handles.toggle_b2l2,'value',1);
    set(handles.toggle_b1l3,'value',1);
    set(handles.toggle_b1l8,'value',1);
    set(handles.toggle_b1l1,'value',1);
    handles.mastervectorboard1(2) = 0;
    handles.mastervectorboard2(2) = 0;
    handles.mastervectorboard3(2) = 0;
    handles.mastervectorboard3(3) = 0;
    handles.mastervectorboard3(4) = 0;
end
guidata(hObject, handles);

function toggle_b1l1_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(8) == 1
    handles.mastervectorboard1(8) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(8) == 0
    handles.mastervectorboard1(8) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b1l2_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(3) == 1
    handles.mastervectorboard1(3) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(3) == 0
    handles.mastervectorboard1(3) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b3l7_Callback(hObject, eventdata, handles)
if handles.mastervectorboard3(8) == 1
    handles.mastervectorboard3(8) = 0;
    handles.mastervectorboard3
elseif handles.mastervectorboard3(8) == 0
    handles.mastervectorboard3(8) = 1;
    handles.mastervectorboard3
end
guidata(hObject, handles);

function toggle_b3l8_Callback(hObject, eventdata, handles)
if handles.mastervectorboard3(9) == 1
    handles.mastervectorboard3(9) = 0;
    handles.mastervectorboard3
elseif handles.mastervectorboard3(9) == 0
    handles.mastervectorboard3(9) = 1;
    handles.mastervectorboard3
end
guidata(hObject, handles);

function toggle_b3l9_Callback(hObject, eventdata, handles)
if handles.mastervectorboard3(10) == 1
    handles.mastervectorboard3(10) = 0;
    handles.mastervectorboard3
elseif handles.mastervectorboard3(10) == 0
    handles.mastervectorboard3(10) = 1;
    handles.mastervectorboard3
end
guidata(hObject, handles);

function toggle_b1l7_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(9) == 1
    handles.mastervectorboard1(9) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(9) == 0
    handles.mastervectorboard1(9) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b2l2_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(3) == 1
    handles.mastervectorboard2(3) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard2(3) == 0
    handles.mastervectorboard2(3) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b1l3_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(4) == 1
    handles.mastervectorboard1(4) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(4) == 0
    handles.mastervectorboard1(4) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b1l8_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(10) == 1
    handles.mastervectorboard1(10) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(10) == 0
    handles.mastervectorboard1(10) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b3l12_Callback(hObject, eventdata, handles)
if handles.mastervectorboard3(13) == 1
    handles.mastervectorboard3(13) = 0;
    handles.mastervectorboard3
elseif handles.mastervectorboard3(13) == 0
    handles.mastervectorboard3(13) = 1;
    handles.mastervectorboard3
end
guidata(hObject, handles);

function toggle_b3l5_Callback(hObject, eventdata, handles)
if handles.mastervectorboard3(6) == 1
    handles.mastervectorboard3(6) = 0;
    handles.mastervectorboard3
elseif handles.mastervectorboard3(6) == 0
% commented out to deactivate button, thermocouple on laser is broken
%     handles.mastervectorboard3(6) = 1; 
    handles.mastervectorboard3
end
guidata(hObject, handles);

function toggle_b3l4_Callback(hObject, eventdata, handles)
if handles.mastervectorboard3(5) == 1
    handles.mastervectorboard3(5) = 0;
    handles.mastervectorboard3
elseif handles.mastervectorboard3(5) == 0
    handles.mastervectorboard3(5) = 1;
    handles.mastervectorboard3
end
guidata(hObject, handles);

function toggle_b2l11_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(12) == 1
    handles.mastervectorboard2(12) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard2(12) == 0
    handles.mastervectorboard2(12) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b3l6_Callback(hObject, eventdata, handles)
if handles.mastervectorboard3(7) == 1
    handles.mastervectorboard3(7) = 0;
    handles.mastervectorboard3
elseif handles.mastervectorboard3(7) == 0
    handles.mastervectorboard3(7) = 1;
    handles.mastervectorboard3
end
guidata(hObject, handles);

function toggle_b2l6_Callback(hObject, eventdata, handles)   
if handles.mastervectorboard2(7) == 1
    handles.mastervectorboard2(7) = 0; 
    handles.mastervectorboard2
elseif handles.mastervectorboard2(7) == 0
    handles.mastervectorboard2(7) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b2l12_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(13) == 1
    handles.mastervectorboard2(13) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard2(13) == 0
    handles.mastervectorboard2(13) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b1l11_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(12) == 1
    handles.mastervectorboard1(12) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(12) == 0
    handles.mastervectorboard1(12) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b1l12_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(13) == 1
    handles.mastervectorboard1(13) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(13) == 0
    handles.mastervectorboard1(13) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function laser1_toggle_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(1) == 1
    handles.mastervectorboard1(1) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(1) == 0
    handles.mastervectorboard1(1) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b1l6_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(7) == 1
    handles.mastervectorboard1(7) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(7) == 0
    handles.mastervectorboard1(7) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b3l11_Callback(hObject, eventdata, handles)
if handles.mastervectorboard3(12) == 1
    handles.mastervectorboard3(12) = 0;
    handles.mastervectorboard3
elseif handles.mastervectorboard3(12) == 0
    handles.mastervectorboard3(12) = 1;
    handles.mastervectorboard3
end
guidata(hObject, handles);

function toggle_b3l10_Callback(hObject, eventdata, handles)
if handles.mastervectorboard3(11) == 1
    handles.mastervectorboard3(11) = 0;
    handles.mastervectorboard3
elseif handles.mastervectorboard3(11) == 0
    handles.mastervectorboard3(11) = 1;
    handles.mastervectorboard3
end
guidata(hObject, handles);

function toggle_b2l7_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(8) == 1
    handles.mastervectorboard2(8) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard2(8) == 0
    handles.mastervectorboard2(8) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b2l8_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(9) == 1
    handles.mastervectorboard2(9) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard2(9) == 0
    handles.mastervectorboard2(9) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b2l9_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(10) == 1
    handles.mastervectorboard2(10) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard2(10) == 0
    handles.mastervectorboard2(10) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b2l10_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(11) == 1
    handles.mastervectorboard2(11) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard2(11) == 0
    handles.mastervectorboard2(11) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b2l3_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(4) == 1
    handles.mastervectorboard2(4) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard1(4) == 0
    handles.mastervectorboard2(4) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b1l4_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(5) == 1
    handles.mastervectorboard1(5) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(5) == 0
    handles.mastervectorboard1(5) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b1l10_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(11) == 1
    handles.mastervectorboard1(11) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(11) == 0
    handles.mastervectorboard1(11) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);

function toggle_b2l5_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(6) == 1
    handles.mastervectorboard2(6) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard2(6) == 0
    handles.mastervectorboard2(6) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b2l4_Callback(hObject, eventdata, handles)
if handles.mastervectorboard2(5) == 1
    handles.mastervectorboard2(5) = 0;
    handles.mastervectorboard2
elseif handles.mastervectorboard2(5) == 0
    handles.mastervectorboard2(5) = 1;
    handles.mastervectorboard2
end
guidata(hObject, handles);

function toggle_b1l5_Callback(hObject, eventdata, handles)
if handles.mastervectorboard1(6) == 1
    handles.mastervectorboard1(6) = 0;
    handles.mastervectorboard1
elseif handles.mastervectorboard1(6) == 0
    handles.mastervectorboard1(6) = 1;
    handles.mastervectorboard1
end
guidata(hObject, handles);



% function sendtoboard(x)
% 
% %% Laser Board 1
% arduinoCom1 = serial('COM__','BaudRate',9600);  % insert your serial
% 
% %% Laser Board 2
% arduinoCom2 = serial('COM__','BaudRate',9600);  % insert your serial
% 
% %% Laser Board 3
% arduinoCom3 = serial('COM__','BaudRate',9600);  % insert your serial
% 
% x = char(x);
% 
% sendData = x(3:14);
% sendData = strcat('<', sendData, '>');
% 
% %Laser Board 1
% if(x(2)=='1')
%     fopen(arduinoCom1);
%     fprintf(arduinoCom1,'%s',sendData);
%     fscanf(arduinoCom1)
%     fclose(arduinoCom1)
% end
% 
% 
% %Laser Board 2
% if(x(2)=='2')
%     fopen(arduinoCom2);
%     fprintf(arduinoCom2,'%s',sendData);
%     fscanf(arduinoCom2)
%     fclose(arduinoCom2)
% end
% 
% 
% %Laser Board 3
% if(x(2)=='3')
%     fopen(arduinoCom3);
%     fprintf(arduinoCom3,'%s',sendData);
%     fscanf(arduinoCom3)
%     fclose(arduinoCom3);
% end

% fopen(arduinoCom1);
% fprintf(arduinoCom1,'%s','<000000000000>');
% fclose(arduinoCom1);
% fopen(arduinoCom2);
% fprintf(arduinoCom2,'%s','<000000000000>');
% fclose(arduinoCom2);
% fopen(arduinoCom3);
% fprintf(arduinoCom3,'%s','<000000000000>');
% fclose(arduinoCom3);

