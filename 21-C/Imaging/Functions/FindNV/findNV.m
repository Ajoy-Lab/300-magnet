function varargout = findNV(varargin)
% FINDNV M-file for findNV.fig
%      FINDNV, by itself, creates a new FINDNV or raises the existing
%      singleton*.
%
%      H = FINDNV returns the handle to a new FINDNV or the handle to
%      the existing singleton*.
%
%      FINDNV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINDNV.M with the given input arguments.
%
%      FINDNV('Property','Value',...) creates a new FINDNV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before findNV_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to findNV_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help findNV

% Last Modified by GUIDE v2.5 15-Nov-2010 19:43:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @findNV_OpeningFcn, ...
                   'gui_OutputFcn',  @findNV_OutputFcn, ...
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


% --- Executes just before findNV is made visible.
function findNV_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to findNV (see VARARGIN)

% Choose default command line output for findNV
handles.output = hObject;
apps = getappdata(0);
fN = fieldnames(apps);
ImagingOpen=1;
for k=1:numel(fN),
    if sum(ishandle(getfield(apps,fN{k}))) && isa(getfield(apps,fN{k}),'double'), % take sum in case many handles
        name = get(getfield(apps,fN{k}),'Name');
        if strcmp('Imaging',name),
            hFig = getfield(apps,fN{k});
            IAHandles = guidata(hFig);
            ImagingOpen=0;
        end
    end
end
if ImagingOpen
    warning('You need to open Imaging before FindNV');
    hFig=Imaging;
    IAHandles = guidata(hFig);
end
handles.IAHandles=IAHandles;
handles.IAF = findNVfunctions();
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes findNV wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = findNV_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_findNV.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to button_findNV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to cutoffMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cutoffMin as text
%        str2double(get(hObject,'String')) returns contents of cutoffMin as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutoffMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in smoothCheck.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to smoothCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of smoothCheck


% --- Executes on selection change in centersBox.
function centersBox_Callback(hObject, eventdata, handles)
% hObject    handle to centersBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns centersBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from centersBox



info = handles.IAF.scanInfo;

contents = cellstr(get(hObject, 'String'));
cLabel = contents{get(hObject, 'Value')};
index = find(info(1,:)==str2double(cLabel));
handles.IAF.curIndex = index;

pixelVol = 1;

if ~handles.IAF.is2D
    
    %convert the units of the center of the NV from pixels to absolute units 
    scaleX = handles.IAF.xMin + (info(4, index)-1)*(handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1);
    scaleY = handles.IAF.yMin + (info(5, index)-1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
    scaleZ = handles.IAF.zMin + (info(6, index)-1)*(handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1);

    %convert the units of the weighted center of the NV from pixels to absolute units 
    scaleWX = handles.IAF.xMin + (info(7, index)-1)*(handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1);
    scaleWY = handles.IAF.yMin + (info(8, index)-1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
    scaleWZ = handles.IAF.zMin + (info(9, index)-1)*(handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1);

    pixelVol = ((handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1))*((handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1))*((handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1));
    
else

   
    if handles.IAF.constDim == 1
        scaleX = handles.IAF.xMin;  %x dimension is constant
        scaleWX = handles.IAF.xMin;
    else
        scaleX = handles.IAF.xMin + (info(4, index)-1)*(handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1);
        scaleWX = handles.IAF.xMin + (info(7, index)-1)*(handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1);
       
        pixelVol = pixelVol * ((handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1));
    end
    
    if handles.IAF.constDim == 2
        scaleY = handles.IAF.yMin;  %y dimension is constant
        scaleWY = handles.IAF.yMin;
    else
        if handles.IAF.constDim == 1
            scaleY = handles.IAF.yMin + (info(5, index)-1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
            scaleWY = handles.IAF.yMin + (info(8, index)-1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
        else
            scaleY = handles.IAF.yMin + (info(5, index)-1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
            scaleWY = handles.IAF.yMin + (info(8, index)-1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
        end
        
        pixelVol = pixelVol * ((handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1));
    end
    
    if handles.IAF.constDim == 3
        scaleZ = handles.IAF.zMin;  %z dimension is constant
        scaleWZ = handles.IAF.zMin;
    else
        scaleZ = handles.IAF.zMin + (info(5, index)-1)*(handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1);
        scaleWZ = handles.IAF.zMin + (info(8, index)-1)*(handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1);
        
        pixelVol = pixelVol * ((handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1));
    end
    
end

handles.IAF.pixelVolume = pixelVol;

set(handles.compSizeText, 'String', info(2, index));
set(handles.compVolText, 'String', sprintf('%0.3e', pixelVol*info(2,index)));
set(handles.compIntText, 'String', info(3, index));
strLoc = sprintf('(%0.2f, %0.2f, %0.2f)', scaleX, scaleY, scaleZ);
set(handles.compLocText, 'String', strLoc);
strWLoc = sprintf('(%0.2f, %0.2f, %0.2f)', scaleWX, scaleWY, scaleWZ);
set(handles.compWLocText, 'String', strWLoc);
set(handles.compSphereness, 'String', info(13, index));



% --- Executes during object creation, after setting all properties.
function centersBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to centersBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in findNV.
function button_findNV_Callback(hObject, eventdata, handles)
% hObject    handle to findNV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gobj = findall(0, 'Name', 'Imaging');
myhandles = guidata(gobj);
contents = get(myhandles.popupScan,'String');
selectedScan = contents{get(myhandles.popupScan,'Value')};

handles.IAF.xMin = str2double(get(myhandles.minxdisp, 'String'));
handles.IAF.xMax = str2double(get(myhandles.maxxdisp, 'String'));
handles.IAF.xPts = str2double(get(myhandles.ptsxdisp, 'String'));

handles.IAF.yMin = str2double(get(myhandles.minydisp, 'String'));
handles.IAF.yMax = str2double(get(myhandles.maxydisp, 'String'));
handles.IAF.yPts = str2double(get(myhandles.ptsydisp, 'String'));

handles.IAF.zMin = str2double(get(myhandles.minzdisp, 'String'));
handles.IAF.zMax = str2double(get(myhandles.maxzdisp, 'String'));
handles.IAF.zPts = str2double(get(myhandles.ptszdisp, 'String'));

fp = getpref('nv','SavedImageDirectory');
SavedScan = load(fullfile(fp,selectedScan));
image = SavedScan.Scan.ImageData;

handles.IAF.is2D = 0;

if ndims(image)==2

    handles.IAF.is2D = 1;
    
    if handles.IAF.xPts == 1
        handles.IAF.constDim = 1;
    end

    if handles.IAF.yPts == 1
        handles.IAF.constDim = 2;
    end

    if handles.IAF.zPts == 1
        handles.IAF.constDim = 3;
    end

end
    
cutoffValMin = str2double(get(handles.cutoffMin, 'String'));
cutoffValMax = str2double(get(handles.cutoffMax, 'String'));
smoothVal = get(handles.smoothCheck, 'Value');

if ~handles.IAF.is2D
    info = handles.IAF.processData(image,cutoffValMin, cutoffValMax, smoothVal);
else
    info = handles.IAF.processData2D(image, cutoffValMin, cutoffValMax, smoothVal);
end

handles.IAF.scanInfo = info;
handles.IAF.compSet = info(1,:);
set(handles.centersBox, 'Value', 1);
set(handles.centersBox, 'String', info(1, :));




function cutoffMin_Callback(hObject, eventdata, handles)
% hObject    handle to cutoffMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cutoffMin as text
%        str2double(get(hObject,'String')) returns contents of cutoffMin as a double


% --- Executes during object creation, after setting all properties.
function cutoffMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutoffMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in smoothCheck.
function smoothCheck_Callback(hObject, eventdata, handles)
% hObject    handle to smoothCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of smoothCheck


% --- Executes on button press in setScan.
function setScan_Callback(hObject, eventdata, handles)
% hObject    handle to setScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gobj = findall(0, 'Name', 'Imaging');
myhandles = guidata(gobj);

info = handles.IAF.scanInfo;
index = handles.IAF.curIndex;

scanType = get(handles.relToggle,'Value');

nDev = str2double(get(handles.nStdDevs, 'String'));
scanSize = str2double(get(handles.absScanSize, 'String'));

if ~handles.IAF.is2D

    %convert the units of the center of the NV from pixels to absolute units 
    scaleX = handles.IAF.xMin + (info(4, index)-1)*(handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1);
    scaleY = handles.IAF.yMin + (info(5, index)-1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
    scaleZ = handles.IAF.zMin + (info(6, index)-1)*(handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1);

    
    if scanType

        %convert the units of the standard deviations from pixels to absolute units
        %max(info( __ , index), 1) is to ensure that we are creating a scan of
        %size at least one around the spot in question
        dScaleX = max(info(10, index),1)*(handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1);
        dScaleY = max(info(11, index),1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
        dScaleZ = max(info(12, index),1)*(handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1);
    
        xScanRad = nDev*dScaleX;
        yScanRad = nDev*dScaleY;
        zScanRad = nDev*dScaleZ;
        
    else
        xScanRad = scanSize;
        yScanRad = scanSize;
        zScanRad = scanSize;        
    end
    
    set(myhandles.minX, 'String', max(scaleX - xScanRad, handles.IAF.xMin));
    set(myhandles.minY, 'String', max(scaleY - yScanRad, handles.IAF.yMin));
    set(myhandles.minZ, 'String', max(scaleZ - zScanRad, handles.IAF.zMin));

    set(myhandles.maxX, 'String', min(scaleX + xScanRad, handles.IAF.xMax));
    set(myhandles.maxY, 'String', min(scaleY + yScanRad, handles.IAF.yMax));
    set(myhandles.maxZ, 'String', min(scaleZ + zScanRad, handles.IAF.zMax));
    
    axis(myhandles.imageAxes, [max(scaleX - xScanRad, handles.IAF.xMin), min(scaleX + xScanRad, handles.IAF.xMax), max(scaleY - yScanRad, handles.IAF.yMin), min(scaleY + yScanRad, handles.IAF.yMax)]);
    
    set(myhandles.enableX, 'Value', 1);
    set(myhandles.enableY, 'Value', 1);
    set(myhandles.enableZ, 'Value', 1);

else
    
    if handles.IAF.constDim == 1
        scaleX = handles.IAF.xMin;
        dScaleX = 0; % we don`t want to scan in x direction
        set(myhandles.enableX, 'Value', 0);
    else
        scaleX = handles.IAF.xMin + (info(4, index)-1)*(handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1);
        dScaleX = max(info(10, index),1)*(handles.IAF.xMax - handles.IAF.xMin)/(handles.IAF.xPts-1);
        set(myhandles.enableX, 'Value', 1);
    end
    
    if handles.IAF.constDim == 2
        scaleY = handles.IAF.yMin;
        dScaleY = 0; % we don`t want to scan in y direction
        set(myhandles.enableY, 'Value', 0);
    else
        if handles.IAF.constDim == 1  %then y is the first dimension we see
            scaleY = handles.IAF.yMin + (info(4, index)-1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
            dScaleY = max(info(10, index),1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
        else %otherwise y is the second dimension we see
            scaleY = handles.IAF.yMin + (info(5, index)-1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
            dScaleY = max(info(11, index),1)*(handles.IAF.yMax - handles.IAF.yMin)/(handles.IAF.yPts-1);
        end
        
        set(myhandles.enableY, 'Value', 1);
    end
    
    if handles.IAF.constDim == 3
        scaleZ = handles.IAF.zMin;
        dScaleZ = 0; % we don`t want to scan in z direction
        set(myhandles.enableZ, 'Value', 0);
    else    
        scaleZ = handles.IAF.zMin + (info(5, index)-1)*(handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1);
        dScaleZ = max(info(11, index),1)*(handles.IAF.zMax - handles.IAF.zMin)/(handles.IAF.zPts-1);
        set(myhandles.enableZ, 'Value', 1);
    end
    
    if scanType
        
        xScanRad = nDev*dScaleX;
        yScanRad = nDev*dScaleY;
        zScanRad = nDev*dScaleZ;
        
    else
        xScanRad = scanSize;
        yScanRad = scanSize;
        zScanRad = scanSize;        
    end
             
set(myhandles.minX, 'String', max(scaleX - xScanRad, handles.IAF.xMin));
    set(myhandles.minY, 'String', max(scaleY - yScanRad, handles.IAF.yMin));
    set(myhandles.minZ, 'String', max(scaleZ - zScanRad, handles.IAF.zMin));

    set(myhandles.maxX, 'String', min(scaleX + xScanRad, handles.IAF.xMax));
    set(myhandles.maxY, 'String', min(scaleY + yScanRad, handles.IAF.yMax));
    set(myhandles.maxZ, 'String', min(scaleZ + zScanRad, handles.IAF.zMax));
    
    axis(myhandles.imageAxes, [max(scaleX - xScanRad, handles.IAF.xMin), min(scaleX + xScanRad, handles.IAF.xMax), max(scaleY - yScanRad, handles.IAF.yMin), min(scaleY + yScanRad, handles.IAF.yMax)]);
end

guidata(gobj, myhandles);



function absScanSize_Callback(hObject, eventdata, handles)
% hObject    handle to absScanSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of absScanSize as text
%        str2double(get(hObject,'String')) returns contents of absScanSize as a double


% --- Executes during object creation, after setting all properties.
function absScanSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to absScanSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intMin_Callback(hObject, eventdata, handles)
% hObject    handle to intMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intMin as text
%        str2double(get(hObject,'String')) returns contents of intMin as a double


% --- Executes during object creation, after setting all properties.
function intMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intMax_Callback(hObject, eventdata, handles)
% hObject    handle to intMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intMax as text
%        str2double(get(hObject,'String')) returns contents of intMax as a double


% --- Executes during object creation, after setting all properties.
function intMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in intFilter.
function intFilter_Callback(hObject, eventdata, handles)
% hObject    handle to intFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

info = handles.IAF.scanInfo;
indSet = handles.IAF.compSet;

iMin = str2double(get(handles.intMin, 'String'));
iMax = str2double(get(handles.intMax, 'String'));


ind = 1;
while ind <= length(indSet);

    cInd = find(info(1,:)==indSet(ind));
    if info(3,cInd) <= iMin || info(3,cInd) >= iMax 
        indSet(ind) = [];
    else
        ind = ind+1;
    end
end

handles.IAF.compSet = indSet;
set(handles.centersBox, 'Value', 1);
set(handles.centersBox, 'String', indSet);




function volMin_Callback(hObject, eventdata, handles)
% hObject    handle to volMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volMin as text
%        str2double(get(hObject,'String')) returns contents of volMin as a double


% --- Executes during object creation, after setting all properties.
function volMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function volMax_Callback(hObject, eventdata, handles)
% hObject    handle to volMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volMax as text
%        str2double(get(hObject,'String')) returns contents of volMax as a double


% --- Executes during object creation, after setting all properties.
function volMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in volFilter.
function volFilter_Callback(hObject, eventdata, handles)
% hObject    handle to volFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


info = handles.IAF.scanInfo;
indSet = handles.IAF.compSet;
pixelVol = handles.IAF.pixelVolume

vMin = str2double(get(handles.volMin, 'String'));
vMax = str2double(get(handles.volMax, 'String'));


ind = 1;
while ind <= length(indSet);

    cInd = find(info(1,:)==indSet(ind));
    if info(2,cInd) <= vMin/pixelVol || info(2,cInd) >= vMax/pixelVol 
        indSet(ind) = [];
    else
        ind = ind+1;
    end
end

handles.IAF.compSet = indSet;
set(handles.centersBox, 'Value', 1);
set(handles.centersBox, 'String', indSet);


function sNessMin_Callback(hObject, eventdata, handles)
% hObject    handle to sNessMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sNessMin as text
%        str2double(get(hObject,'String')) returns contents of sNessMin as a double


% --- Executes during object creation, after setting all properties.
function sNessMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sNessMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sNessMax_Callback(hObject, eventdata, handles)
% hObject    handle to sNessMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sNessMax as text
%        str2double(get(hObject,'String')) returns contents of sNessMax as a double


% --- Executes during object creation, after setting all properties.
function sNessMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sNessMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sNessFilter.
function sNessFilter_Callback(hObject, eventdata, handles)
% hObject    handle to sNessFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


info = handles.IAF.scanInfo;
indSet = handles.IAF.compSet;

sNMin = str2double(get(handles.sNessMin, 'String'));
sNMax = str2double(get(handles.sNessMax, 'String'));


ind = 1;
while ind <= length(indSet);

    cInd = find(info(1,:)==indSet(ind));
    if (info(13,cInd) <= sNMin || info(13,cInd) >= sNMax) && info(2,ind)>5
        indSet(ind) = [];
    else
        ind = ind+1;
    end
end

handles.IAF.compSet = indSet;
set(handles.centersBox, 'Value', 1);
set(handles.centersBox, 'String', indSet);



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cutoffMax_Callback(hObject, eventdata, handles)
% hObject    handle to cutoffMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cutoffMax as text
%        str2double(get(hObject,'String')) returns contents of cutoffMax as a double


% --- Executes during object creation, after setting all properties.
function cutoffMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutoffMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
