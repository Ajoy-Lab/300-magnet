%% THIS function is taken out from Imaging so that it can be used in AUTOMIZER (ashok 8/1/14)
function handles=buttonSaveScan_Callback(hObject, ~, handles)

% Initialize Scan
handles.ConfocalScan = ConfocalScan();

MinVal(1) = str2num(get(handles.minX,'String'));
MinVal(2) = str2num(get(handles.minY,'String'));
MinVal(3) = str2num(get(handles.minZ,'String'));

MaxVal(1) = str2num(get(handles.maxX,'String'));
MaxVal(2) = str2num(get(handles.maxY,'String'));
MaxVal(3) = str2num(get(handles.maxZ,'String'));

NumPoints(1) = str2num(get(handles.pointsX,'String'));
NumPoints(2) = str2num(get(handles.pointsY,'String'));
NumPoints(3) = str2num(get(handles.pointsZ,'String'));

DwellTime = str2num(get(handles.DwellScanValue,'String'));

bEnable(1) = get(handles.enableX,'Value');
bEnable(2) = get(handles.enableY,'Value');
bEnable(3) = get(handles.enableZ,'Value');

%Start checking if scan can be done
if sum(bEnable) == 0
    uiwait(warndlg({'No scan direction selected!'}));
    return;
end

if sum(bEnable) == 1
    
    for j=1:1:3
        if bEnable(j)
            if MinVal(j) == MaxVal(j)
                uiwait(warndlg({'Scan range in 1D must be different from zero!'}));
                return;
            end
        end
    end
    
elseif sum(bEnable) == 2
    
    if bEnable(1) && bEnable(2)
        if (MinVal(1) == MaxVal(1))||(MinVal(2) == MaxVal(2))
            uiwait(warndlg({'Both scan ranges in 2D must be different from zero!'}));
            return;
        end
    elseif bEnable(1) && bEnable(3)
        if (MinVal(1) == MaxVal(1))||(MinVal(3) == MaxVal(3))
            uiwait(warndlg({'Both scan ranges in 2D must be different from zero!'}));
            return;
        end
    else
        if (MinVal(3) == MaxVal(3))||(MinVal(2) == MaxVal(2))
            uiwait(warndlg({'Both scan ranges in 2D must be different from zero!'}));
            return;
        end
    end
    
else %3d %only case where it is possible for scan range to be 0, but only if the dimension is not ramped
    if (MinVal(1) == MaxVal(1)|| MinVal(2) == MaxVal(2))
        uiwait(warndlg({'In a 3D scan only z can have range zero!'}));
        return;
    end
    
    size = 0;
    for j=1:1:3
        if NumPoints(j) > size
            size = NumPoints(j);
            rampover = j;
        end
    end
    
    if (rampover == 3 && (MinVal(3) == MaxVal(3)))
        uiwait(warndlg({'Z is currently the ramp-over direction, cannot have range zero!'}));
        return;
    end
    
    
end


if (((MinVal(1)> MaxVal(1)) && bEnable(1))||((MinVal(2) > MaxVal(2)) && bEnable(2))|| ((MinVal(3)> MaxVal(3)) && bEnable(3)))
    uiwait(warndlg({'Scan start point must be smaller than end point!'}));
    return;
end

if MinVal(1) < handles.ImagingFunctions.interfaceScanning.LowEndOfRange(1)
    uiwait(warndlg('X too low, out of range!'));
    set(handles.minX,'String',handles.ImagingFunctions.MinValues(1));
    return;
end

if MaxVal(1) > handles.ImagingFunctions.interfaceScanning.HighEndOfRange(1)
    uiwait(warndlg('X too high, out of range!'));
    set(handles.maxX,'String',handles.ImagingFunctions.MaxValues(1));
    return;
end

if MaxVal(2)> handles.ImagingFunctions.interfaceScanning.HighEndOfRange(2)
    uiwait(warndlg('Y too high, out of range!'));
    set(handles.maxY,'String',handles.ImagingFunctions.MaxValues(2));
    return;
end

if MinVal(2)< handles.ImagingFunctions.interfaceScanning.LowEndOfRange(2)
    uiwait(warndlg('Y too low, out of range!'));
    set(handles.minY,'String',handles.ImagingFunctions.MinValues(2));
    return;
end

Piezotoggle=get(handles.piezoZ_toggle,'Value');
if Piezotoggle==0
    if MaxVal(3)> handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3)
        uiwait(warndlg('Z too high, out of range!'));
        %set(handles.maxZ,'String',handles.ImagingFunctions.MaxValues(3));
        set(handles.maxZ,'String',handles.ImagingFunctions.interfaceScanning.HighEndOfRange(3));
        return;
    end
else
    if MaxVal(3)> 1000
        uiwait(warndlg('Z too high, out of range!'));
        set(handles.maxZ,'String',1000);
        return;
    end
end

if MinVal(3)< handles.ImagingFunctions.interfaceScanning.LowEndOfRange(3)
    uiwait(warndlg('Z too low, out of range!'));
    set(handles.minZ,'String',handles.ImagingFunctions.MinValues(3));
    return;
end

if DwellTime < (1.0/handles.ImagingFunctions.interfaceScanning.SampleRate)
    uiwait(warndlg('Dwell time too small!'));
    set(handles.DwellScanValue,'String',1/handles.ImagingFunctions.interfaceScanning.SampleRate);
    return;
end

handles.ImagingFunctions.NumPoints = NumPoints;
handles.ImagingFunctions.bEnable = bEnable;
handles.ImagingFunctions.MinValues = MinVal;
handles.ImagingFunctions.MaxValues = MaxVal;
handles.ConfocalScan.DwellTime = DwellTime;
handles.ConfocalScan.Notes = 'Notes on Scan:';

set(handles.buttonScan,'Enable','on');

guidata(hObject,handles);

end