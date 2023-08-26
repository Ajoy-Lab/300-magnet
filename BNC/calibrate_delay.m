function varargout = calibrate_delay(varargin)
% CALIBRATE_DELAY MATLAB code for calibrate_delay.fig
%      CALIBRATE_DELAY, by itself, creates a new CALIBRATE_DELAY or raises the existing
%      singleton*.
%
%      H = CALIBRATE_DELAY returns the handle to a new CALIBRATE_DELAY or the handle to
%      the existing singleton*.
%
%      CALIBRATE_DELAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATE_DELAY.M with the given input arguments.
%
%      CALIBRATE_DELAY('Property','Value',...) creates a new CALIBRATE_DELAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calibrate_delay_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calibrate_delay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calibrate_delay

% Last Modified by GUIDE v2.5 07-Apr-2014 07:56:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibrate_delay_OpeningFcn, ...
                   'gui_OutputFcn',  @calibrate_delay_OutputFcn, ...
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


% --- Executes just before calibrate_delay is made visible.
function calibrate_delay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calibrate_delay (see VARARGIN)

% Choose default command line output for calibrate_delay
handles.output = hObject;

handles.bnc = instrfind('Type', 'serial', 'Port', 'COM18', 'Tag', '');
obj1=handles.bnc;

if isempty(obj1)
    obj1 = serial('COM18', 'BaudRate',38400,'Terminator','CR/LF' );
else
    fclose(obj1);
    obj1 = obj1(1)
end
fopen(obj1);

set(handles.width1, 'String', '2e-6');
set(handles.slider_width1, 'Max', 2e-6);
set(handles.slider_width1, 'Value', str2num(get(handles.width1,'String')));

set(handles.delay1, 'String', '0');
set(handles.slider_delay1, 'Max', 2e-6);
set(handles.slider_delay1, 'Value', str2num(get(handles.delay1,'String')));

set(handles.width2, 'String', '2e-6');
set(handles.slider_width2, 'Max', 2e-6);
set(handles.slider_width2, 'Value', str2num(get(handles.width1,'String')));

set(handles.delay2, 'String', '0');
set(handles.slider_delay2, 'Max', 2e-6);
set(handles.slider_delay2, 'Value', str2num(get(handles.delay2,'String')));

set(handles.delay_res, 'String', '1e-9');
set(handles.width_res, 'String', '1e-9');
dres= str2num(get(handles.delay_res,'String'));
set(handles.slider_delay1, 'SliderStep', [dres 10*dres]/2e-6);
set(handles.slider_delay2, 'SliderStep', [dres 10*dres]/2e-6);
wres= str2num(get(handles.width_res,'String'));
set(handles.slider_width1, 'SliderStep', [wres 10*wres]/2e-6);
set(handles.slider_width2, 'SliderStep', [wres 10*wres]/2e-6);


width=get(handles.width1,'String');
delay=get(handles.delay1,'String');
query(obj1, [':PULSE2:WIDT ' num2str(width)]);
query(obj1, [':PULSE2:DELAY ' num2str(delay)]);

width=get(handles.width2,'String');
delay=get(handles.delay2,'String');
query(obj1, [':PULSE4:WIDT ' num2str(width)]);
query(obj1, [':PULSE4:DELAY ' num2str(delay)]);



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes calibrate_delay wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function calibrate_delay_ClosingFcn(hObject, eventdata, handles, varargin)
obj1=handles.bnc;
fclose(obj1);
delete(obj1);


% --- Outputs from this function are returned to the command line.
function varargout = calibrate_delay_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_width1_Callback(hObject, eventdata, handles)
% hObject    handle to slider_width1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
obj1=handles.bnc;
set(handles.width1, 'String', get(hObject, 'Value'));
width=get(handles.width1,'String')
query(obj1, [':PULSE2:WIDT ' num2str(width)])

% --- Executes during object creation, after setting all properties.
function slider_width1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_width1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function width1_Callback(hObject, eventdata, handles)
% hObject    handle to width1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width1 as text
%        str2double(get(hObject,'String')) returns contents of width1 as a double

obj1=handles.bnc;
set(handles.slider_width1, 'Value',str2num(get(handles.width1,'String')));
width=get(handles.width1,'String');
query(obj1, [':PULSE2:WIDT ' num2str(width)]);


% --- Executes during object creation, after setting all properties.
function width1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_width1.
function set_width1_Callback(hObject, eventdata, handles)
% hObject    handle to set_width1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
obj1=handles.bnc;
set(handles.slider_width1, 'Value',str2num(get(handles.width1,'String')));
width=get(handles.width1,'String');
query(obj1, [':PULSE2:WIDT ' num2str(width)]);


% --- Executes on slider movement.
function slider_delay1_Callback(hObject, eventdata, handles)
% hObject    handle to slider_delay1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
obj1=handles.bnc;
set(handles.delay1, 'String', get(hObject, 'Value'));
delay=get(handles.delay1,'String')
query(obj1, [':PULSE2:DELAY ' num2str(delay)])


% --- Executes during object creation, after setting all properties.
function slider_delay1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_delay1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function delay1_Callback(hObject, eventdata, handles)
% hObject    handle to delay1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay1 as text
%        str2double(get(hObject,'String')) returns contents of delay1 as a double
obj1=handles.bnc;
set(handles.slider_delay1, 'Value',str2num(get(handles.delay1,'String')));
delay=get(handles.delay1,'String');
query(obj1, [':PULSE2:DELAY ' num2str(delay)]);


% --- Executes during object creation, after setting all properties.
function delay1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_delay1.
function set_delay1_Callback(hObject, eventdata, handles)
% hObject    handle to set_delay1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
obj1=handles.bnc;
set(handles.slider_delay1, 'Value',str2num(get(handles.delay1,'String')));
delay=get(handles.delay1,'String');
query(obj1, [':PULSE2:DELAY ' num2str(delay)]);


% --- Executes on slider movement.
function slider_width2_Callback(hObject, eventdata, handles)
% hObject    handle to slider_width2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
obj1=handles.bnc;
set(handles.width2, 'String', get(hObject, 'Value'));
width=get(handles.width2,'String')
query(obj1, [':PULSE4:WIDT ' num2str(width)])

% --- Executes during object creation, after setting all properties.
function slider_width2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_width2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function width2_Callback(hObject, eventdata, handles)
% hObject    handle to width2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width2 as text
%        str2double(get(hObject,'String')) returns contents of width2 as a double
obj1=handles.bnc;
set(handles.slider_width2, 'Value',str2num(get(handles.width2,'String')));
width=get(handles.width2,'String');
query(obj1, [':PULSE4:WIDT ' num2str(width)]);


% --- Executes during object creation, after setting all properties.
function width2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_width2.
function set_width2_Callback(hObject, eventdata, handles)
% hObject    handle to set_width2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
obj1=handles.bnc;
set(handles.slider_width2, 'Value',str2num(get(handles.width2,'String')));
width=get(handles.width2,'String');
query(obj1, [':PULSE4:WIDT ' num2str(width)]);


% --- Executes on slider movement.
function slider_delay2_Callback(hObject, eventdata, handles)
% hObject    handle to slider_delay2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
obj1=handles.bnc;
set(handles.delay2, 'String', get(hObject, 'Value'));
delay=get(handles.delay2,'String')
query(obj1, [':PULSE4:DELAY ' num2str(delay)])


% --- Executes during object creation, after setting all properties.
function slider_delay2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_delay2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function delay2_Callback(hObject, eventdata, handles)
% hObject    handle to delay2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay2 as text
%        str2double(get(hObject,'String')) returns contents of delay2 as a double
obj1=handles.bnc;
set(handles.slider_delay2, 'Value',str2num(get(handles.delay2,'String')));
delay=get(handles.delay2,'String');
query(obj1, [':PULSE4:DELAY ' num2str(delay)]);

% --- Executes during object creation, after setting all properties.
function delay2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_delay2.
function set_delay2_Callback(hObject, eventdata, handles)
% hObject    handle to set_delay2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
obj1=handles.bnc;
set(handles.slider_delay2, 'Value',str2num(get(handles.delay2,'String')));
delay=get(handles.delay2,'String');
query(obj1, [':PULSE4:DELAY ' num2str(delay)]);



function width_res_Callback(hObject, eventdata, handles)
% hObject    handle to width_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width_res as text
%        str2double(get(hObject,'String')) returns contents of width_res as a double


% --- Executes during object creation, after setting all properties.
function width_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_width_res.
function set_delay_res_Callback(hObject, eventdata, handles)
% hObject    handle to set_width_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
obj1=handles.bnc;
dres= str2num(get(handles.delay_res,'String'));
set(handles.slider_delay1, 'SliderStep', [dres 10*dres]/2e-6);
set(handles.slider_delay2, 'SliderStep', [dres 10*dres]/2e-6);

function delay_res_Callback(hObject, eventdata, handles)
% hObject    handle to delay_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay_res as text
%        str2double(get(hObject,'String')) returns contents of delay_res as a double


% --- Executes during object creation, after setting all properties.
function delay_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_delay_res.
function set_width_res_Callback(hObject, eventdata, handles)
% hObject    handle to set_delay_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
obj1=handles.bnc;
wres= str2num(get(handles.width_res,'String'));
set(handles.slider_width1, 'SliderStep', [wres 10*wres]/2e-6);
set(handles.slider_width2, 'SliderStep', [wres 10*wres]/2e-6);
