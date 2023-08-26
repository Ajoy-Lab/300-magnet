function varargout = NVautomizer(varargin)
% NVAUTOMIZER MATLAB code for NVautomizer.fig
%      NVAUTOMIZER, by itself, creates a new NVAUTOMIZER or raises the existing
%      singleton*.
%
%      H = NVAUTOMIZER returns the handle to a new NVAUTOMIZER or the handle to
%      the existing singleton*.
%
%      NVAUTOMIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NVAUTOMIZER.M with the given input arguments.
%
%      NVAUTOMIZER('Property','Value',...) creates a new NVAUTOMIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NVautomizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NVautomizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NVautomizer

% Last Modified by GUIDE v2.5 25-May-2014 17:15:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NVautomizer_OpeningFcn, ...
                   'gui_OutputFcn',  @NVautomizer_OutputFcn, ...
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


% --- Executes just before NVautomizer is made visible.
function NVautomizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NVautomizer (see VARARGIN)

gobj = findall(0,'Name','Imaging');
handles.Imaginghandles = guidata(gobj);


% Choose default command line output for NVautomizer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NVautomizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NVautomizer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_automizer.
function add_automizer_Callback(hObject, eventdata, handles)
% hObject    handle to add_automizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles.automizer_data=get(handles.automizer,'Data');
handles.automizer_data{end+1,1} = str2num(get(handles.Imaginghandles.cursorX,'String'));
handles.automizer_data{end,2} =str2num(get(handles.Imaginghandles.cursorY,'String'));
handles.automizer_data{end,3} =str2num(get(handles.Imaginghandles.cursorZ,'String'));
set(handles.automizer,'Data',handles.automizer_data);
guidata(hObject, handles);



% --- Executes on button press in remove_automizer.
function remove_automizer_Callback(hObject, eventdata, handles)
% hObject    handle to remove_automizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 handles.automizer_data(end,:)=[]
set(handles.automizer,'Data',handles.automizer_data);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function automizer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to automizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.automizer_data = {};
guidata(hObject, handles);
