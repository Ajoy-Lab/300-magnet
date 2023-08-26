function varargout = setMeas(varargin)
% SETMEAS MATLAB code for setMeas.fig
%      SETMEAS, by itself, creates a new SETMEAS or raises the existing
%      singleton*.
%
%      H = SETMEAS returns the handle to a new SETMEAS or the handle to
%      the existing singleton*.
%
%      SETMEAS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETMEAS.M with the given input arguments.
%
%      SETMEAS('Property','Value',...) creates a new SETMEAS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setMeas_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setMeas_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setMeas

% Last Modified by GUIDE v2.5 18-Jun-2015 16:45:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setMeas_OpeningFcn, ...
                   'gui_OutputFcn',  @setMeas_OutputFcn, ...
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


% --- Executes just before setMeas is made visible.
function setMeas_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setMeas (see VARARGIN)

% Choose default command line output for setMeas
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setMeas wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = setMeas_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
global cMeas
contents=cellstr(get(hObject,'String'));
sel = contents{get(hObject,'Value')};
switch sel
    case 'CycleArea'
        cMeas.type = 'Carea';
    otherwise
        cMeas.type = sel;
end
cMeas.modified = 1;

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
apply_Callback(hObject, eventdata, handles)
% close()

% --- Executes on button press in apply.
function apply_Callback(hObject, eventdata, handles)
% hObject    handle to apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cMeas

loadMeasuremet(cMeas);
cMeas.modified = 0;

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in measNb.
function measNb_Callback(hObject, eventdata, handles)
% hObject    handle to measNb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measNb contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measNb
global cMeas

contents = cellstr(get(hObject,'String'));
cMeas.i=str2double(contents{get(hObject,'Value')});
res=TDS694cFunctionPool('getMeasurementParam',cMeas.i);
if isempty(res)
    return;
end
[sel,res]=strtok(res,';');
% set selection in listbox1
switch sel
    case 'Carea'
        cMeas.type = 'CycleArea';
    otherwise
        cMeas.type = sel;
end
contents=cellstr(get(handles.listbox1,'String'));
for i=1:length(contents)
    if strcmpi(strtrim(contents{i}),cMeas.type)
        set(handles.listbox1,'Value',i);
        break
    end
end


[cMeas.units,res]=strtok(res(2:end),';');
cMeas.units = cMeas.units(2:end-1);

[cMeas.mainCHN,res]=strtok(res(2:end),';');
set(handles.mainCHN,'Value',str2double(cMeas.mainCHN(3:end)));
[cMeas.secondaryCHN,res]=strtok(res(2:end),';');
set(handles.secCHN,'Value',str2double(cMeas.secondaryCHN(3:end)));
% [cMeas.delay,res]=strtok(res(2:end),';');
% cMeas.delay=str2double(cMeas.delay);

[cMeas.edge1,res]=strtok(res(2:end),';');
[cMeas.edge2,res]=strtok(res(2:end),';');
[cMeas.direction,res]=strtok(res(2:end),';');

[cMeas.state,~]=strtok(res(2:end),';');
cMeas.state=str2double(cMeas.state);
set(handles.state,'Value',cMeas.state);

if cMeas.state
    cMeas.lastValue=TDS694cFunctionPool('getmeasurement',cMeas.i);
    cMeas.lastValueDate=datestr(datetime);
    set(handles.value,'String', [num2str(cMeas.lastValue) ' ' cMeas.units]) 
end

% --- Executes during object creation, after setting all properties.
function measNb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measNb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in state.
function state_Callback(hObject, eventdata, handles)
% hObject    handle to state (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of state
global cMeas
cMeas.state=get(hObject,'Value');
cMeas.modified=0;


% --- Executes on selection change in mainCHN.
function mainCHN_Callback(hObject, eventdata, handles)
% hObject    handle to mainCHN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mainCHN contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mainCHN
global cMeas
contents = cellstr(get(hObject,'String'));
cMeas.mainCHN=['CH' contents{get(hObject,'Value')}];
cMeas.modified=0;


% --- Executes during object creation, after setting all properties.
function mainCHN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainCHN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in secCHN.
function secCHN_Callback(hObject, eventdata, handles)
% hObject    handle to secCHN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns secCHN contents as cell array
%        contents{get(hObject,'Value')} returns selected item from secCHN
global cMeas
contents = cellstr(get(hObject,'String'));
cMeas.secondaryCHN=['CH' contents{get(hObject,'Value')}];
cMeas.modified=0;


% --- Executes during object creation, after setting all properties.
function secCHN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to secCHN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function loadMeasuremet(meas)

% {'TYPE','SOURCE1', 'SOURCE2', 'DELAY:EDGE1','DELAY:EDGE2', 'DELAY:DIRE',
% 'STATE'}
param={meas.i,...
    meas.type,...
    meas.mainCHN,...
    meas.secondaryCHN,...
    meas.edge1,...
    meas.edge2,...
    meas.direction,...
    meas.state};

TDS694cFunctionPool('setMeasurementParam', param);


% --- Executes on button press in RefreshMeas.
function RefreshMeas_Callback(hObject, eventdata, handles)
% hObject    handle to RefreshMeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global cMeas
% if cMeas.state
%     cMeas.lastValue=TDS694cFunctionPool('getmeasurement',cMeas.i);
%     cMeas.lastValueDate=datestr(datetime);
%     set(handles.value,'String', [num2str(cMeas.lastValue) ' ' cMeas.units]) 
% end

% --- Executes on button press in liveRefresh.
function liveRefresh_Callback(hObject, eventdata, handles)
% hObject    handle to liveRefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of liveRefresh
