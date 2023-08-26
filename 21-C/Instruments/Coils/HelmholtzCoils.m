function varargout = HelmholtzCoils(varargin)
% HELMHOLTZCOILS M-file for HelmholtzCoils.fig
%      HELMHOLTZCOILS, by itself, creates a new HELMHOLTZCOILS or raises the existing
%      singleton*.
%
%      H = HELMHOLTZCOILS returns the handle to a new HELMHOLTZCOILS or the handle to
%      the existing singleton*.
%
%      HELMHOLTZCOILS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HELMHOLTZCOILS.M with the given input arguments.
%
%      HELMHOLTZCOILS('Property','Value',...) creates a new HELMHOLTZCOILS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HelmholtzCoils_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HelmholtzCoils_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HelmholtzCoils

% Last Modified by GUIDE v2.5 20-Dec-2007 11:02:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HelmholtzCoils_OpeningFcn, ...
                   'gui_OutputFcn',  @HelmholtzCoils_OutputFcn, ...
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


% --- Executes just before HelmholtzCoils is made visible.
function HelmholtzCoils_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HelmholtzCoils (see VARARGIN)

% Choose default command line output for HelmholtzCoils
handles.output = hObject;

% Create a LD340PseudoObject
handles.LD340Device{1}.GPIB = 11;
handles.LD340Device{1}.Current = 0.00;
handles.LD340Device{1}.GUIButtonID = 'toggleOnOff1';

handles.LD340Device{2}.GPIB = 12;
handles.LD340Device{2}.Current = 0.00;
handles.LD340Device{2}.GUIButtonID = 'toggleOnOff2';

handles.LD340Device{3}.GPIB = 10;
handles.LD340Device{3}.Current = 0.00;
handles.LD340Device{3}.GUIButtonID = 'toggleOnOff3';


% get the initial state of the device
HelmholtzCoilsFunctionPool('Initialize',hObject,eventdata,handles);



% Update handles structure
guidata(hObject, handles);  

% UIWAIT makes HelmholtzCoils wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HelmholtzCoils_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function current3_Callback(hObject, eventdata, handles)
% hObject    handle to currentZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentZ as text
%        str2double(get(hObject,'String')) returns contents of currentZ as a double


% --- Executes during object creation, after setting all properties.
function current3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in toggleOnOff.
function toggleOnOff3_Callback(hObject, eventdata, handles)
% hObject    handle to toggleOnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleOnOff

% get toggle state
toggleState = get(handles.toggleOnOff3,'Value');
channel = 3;
if toggleState > 0,
    HelmholtzCoilsFunctionPool('TurnLaserOn',hObject,eventdata,handles,channel);
else
    HelmholtzCoilsFunctionPool('TurnLaserOff',hObject,eventdata,handles,channel);
end


% --- Executes on button press in updateButton.
function updateZButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channel = 3;
HelmholtzCoilsFunctionPool('UpdateDevice',hObject,eventdata,handles,channel)




% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2





function current2_Callback(hObject, eventdata, handles)
% hObject    handle to currentY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentY as text
%        str2double(get(hObject,'String')) returns contents of currentY as a double


% --- Executes during object creation, after setting all properties.
function current2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in toggleOnOffY.
function toggleOnOff2_Callback(hObject, eventdata, handles)
% hObject    handle to toggleOnOffY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleOnOffY
% get toggle state
toggleState = get(handles.toggleOnOff2,'Value');
channel = 2;
if toggleState > 0,
    HelmholtzCoilsFunctionPool('TurnLaserOn',hObject,eventdata,handles,channel);
else
    HelmholtzCoilsFunctionPool('TurnLaserOff',hObject,eventdata,handles,channel);
end



% --- Executes on button press in updateYButton.
function updateYButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateYButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channel = 2;
HelmholtzCoilsFunctionPool('UpdateDevice',hObject,eventdata,handles,channel)



function current1_Callback(hObject, eventdata, handles)
% hObject    handle to currentX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentX as text
%        str2double(get(hObject,'String')) returns contents of currentX as a double


% --- Executes during object creation, after setting all properties.
function current1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in toggleOnOffX.
function toggleOnOff1_Callback(hObject, eventdata, handles)
% hObject    handle to toggleOnOffX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleOnOffX
% get toggle state
toggleState = get(handles.toggleOnOff1,'Value');
channel = 1;
if toggleState > 0,
    HelmholtzCoilsFunctionPool('TurnLaserOn',hObject,eventdata,handles,channel);
else
    HelmholtzCoilsFunctionPool('TurnLaserOff',hObject,eventdata,handles,channel);
end



% --- Executes on button press in updateXButton.
function updateXButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateXButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channel = 1;
HelmholtzCoilsFunctionPool('UpdateDevice',hObject,eventdata,handles,channel)


% --- Executes on button press in toggleMaster.
function toggleMaster_Callback(hObject, eventdata, handles)
% hObject    handle to toggleMaster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleMaster


