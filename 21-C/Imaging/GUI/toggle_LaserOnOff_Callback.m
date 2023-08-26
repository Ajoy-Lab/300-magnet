function toggle_LaserOnOff_Callback(hObject, ~, handles)
% Executes on button press in toggle_LaserOnOff.

LaserOn=get(hObject,'Value');
if LaserOn
    
    if handles.QEGhandles.pulse_mode == 1 %use PB
        
        handles.ImagingFunctions.interfacePulseGen.StartProgramming();
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.ImagingFunctions.interfacePulseGen.ON);
        handles.ImagingFunctions.interfacePulseGen.StopProgramming();
        handles.ImagingFunctions.interfacePulseGen.PBStart();
        
    elseif handles.QEGhandles.pulse_mode == 0 %use AWG
        handles.ImagingFunctions.interfacePulseGen.open();
        handles.ImagingFunctions.interfacePulseGen.writeToSocket('AWGCONTROL:RMODE CONTINUOUS');
        
        NullShape = zeros(6*1e4,1); %length here is arbitrary
        OnShape = ones(6*1e4,1);
        
        handles.ImagingFunctions.interfacePulseGen.clear_waveforms();
        handles.ImagingFunctions.interfacePulseGen.create_waveform('IMAGING',NullShape,OnShape,NullShape);
        handles.ImagingFunctions.interfacePulseGen.setSourceWaveForm(1,'IMAGING');
        
        handles.ImagingFunctions.interfacePulseGen.SetChannelOn(1);
        handles.ImagingFunctions.interfacePulseGen.close();
        
        % neglect simu cases
        
    end
    
    set(handles.toggle_LaserOnOff,'String','Laser On')
    set(handles.toggle_LaserOnOff,'ForegroundColor',[0.847 0.161 0])
    
else
    
    if handles.QEGhandles.pulse_mode == 1 %use PB
        
        handles.ImagingFunctions.interfacePulseGen.PBStop();
        
    elseif handles.QEGhandles.pulse_mode == 0 %use AWG
        
        handles.ImagingFunctions.interfacePulseGen.open();
        handles.ImagingFunctions.interfacePulseGen.SetChannelOff(1);
        handles.ImagingFunctions.interfacePulseGen.close();
        
    end
    
    set(handles.toggle_LaserOnOff,'String','Laser Off')
    set(handles.toggle_LaserOnOff,'ForegroundColor',[0.0 0.487 0])
    
end
