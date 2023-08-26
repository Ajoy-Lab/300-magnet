function handles = buttonScan_Callback(hObject, eventdata, handles)

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
end