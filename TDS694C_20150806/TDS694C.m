function varargout = TDS694C(varargin)
% TDS694C MATLAB code for TDS694C.fig
%      TDS694C, by itself, creates a new TDS694C or raises the existing
%      singleton*.
%
%      H = TDS694C returns the handle to a new TDS694C or the handle to
%      the existing singleton*h.
%
%      TDS694C('CALLBACK',hObject,eventData,handles,...) calls the local
%      func?tion named CALLBACK in TDS694C.M with the given input arguments.
%
%      TDS694C('Property','Value',...) creates a new TDS694C or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TDS694C_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TDS694C_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TDS694C

% Last Modified by GUIDE v2.5 08-Jun-2015 17:05:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TDS694C_OpeningFcn, ...
                   'gui_OutputFcn',  @TDS694C_OutputFcn, ...
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

% --- Executes just before TDS694C is made visible.
function TDS694C_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TDS694C (see VARARGIN)

% Choose default command line output for TDS694C
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using TDS694C.

% UIWAIT makes TDS694C wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global scopebusy
scopebusy=0;
TDS694cFunctionPool('Init');


% --- Outputs from this function are returned to the command line.
function varargout = TDS694C_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope

tic
disp(['new trace ' datestr(now,'dd-mmm-yyyy_HHMMSS')])

while true % do-while loop: condition ~get(handles.realTimeBox, 'Value') at the end
    if scope.currentCH < 1 || scope.currentCH> 4
        for i=1:4
            TDS694cFunctionPool('setChannel',i);
            list=TDS694cFunctionPool('getCurve');
            if ~isempty(list)
                plot(handles.axes1,list);
                hold(handles.axes1,'on');
            end
        end
        hold(handles.axes1,'off');
        pause(.001)
        if ~get(handles.realTimeBox, 'Value')
            return
        end
        continue
    end
    scope.trace=TDS694cFunctionPool('getCurve')'; 
    [scaleX,scaleY]=TDS694cFunctionPool('getScales',scope.currentCH);
    scope.scaleXperPoint=scaleX/50; % 10 division over X is always 500 points
    scope.scaleYperPoint=scaleY/(255/10);  % 8 divisions over Y is always 255 points (if DAT:Wid = 1)
    lenTrace=length(scope.trace);
    if ~isempty(scope.trace)
        plot(handles.axes1,...
            0:scope.scaleXperPoint:scope.scaleXperPoint*(lenTrace-1),... X
            scope.scaleYperPoint*scope.trace); % Y
        xlabel(handles.axes1, 'Time (s)')
        ylabel(handles.axes1, ['CH' num2str(scope.currentCH) ' (V)'])
    end
    
   % pause(.001)
      toc
    if ~get(handles.realTimeBox, 'Value')
        break
    end
  
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global scope;
scope.currentCH = str2double(get(hObject,'String')); 
TDS694cFunctionPool('setchannel',scope.currentCH);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global scope;

cch=TDS694cFunctionPool('getchannel');
scope.currentCH=str2double(cch(3:end));
set(hObject,'String',num2str(scope.currentCH));

% --- Executes on button press in holdBox.
function holdBox_Callback(hObject, eventdata, handles)
% hObject    handle to holdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of holdBox

if get(hObject,'Value')
    hold(handles.axes1,'on');
else
    hold(handles.axes1,'off');
end


% --- Executes on button press in realTimeBox.
function realTimeBox_Callback(hObject, eventdata, handles)
% hObject    handle to realTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of realTimeBox


% --- Executes on button press in setMeas.
function setMeas_Callback(hObject, eventdata, handles)
% hObject    handle to setMeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of setMeas
setMeas


% --- Executes on button press in saveTrace.
function saveTrace_Callback(hObject, eventdata, handles)
% hObject    handle to saveTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope
save(['Temp' datestr(now,'dd-mmm-yyyy_HHMMSS') '.mat'], 'scope');
