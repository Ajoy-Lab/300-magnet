function [hObject,handles] = Experiment_InitScript(hObject,handles)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Signal Generator        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The signal generator, when it is on,  can also be accessed and controlled thru a web browser at the
% following address: http://a-N5183A-40016

% if handles.Imaginghandles.QEGhandles.pulse_mode == 1 || handles.Imaginghandles.QEGhandles.pulse_mode == 0
%     
%     Timeout = 10;
%     InputBufferSize =  1000000;
%     OutputBufferSize = 1000000;
%     handles.ExperimentFunctions.interfaceSigGen = SignalGeneratorAgilent('a-N5183A-40016',5025,Timeout,InputBufferSize,OutputBufferSize);
%     handles.ExperimentFunctions.interfaceSigGen.Timeout = Timeout;
%     handles.ExperimentFunctions.interfaceSigGen.InputBufferSize = InputBufferSize;
%     handles.ExperimentFunctions.interfaceSigGen.OutputBufferSize =  OutputBufferSize; 
%     handles.ExperimentFunctions.interfaceSigGen.MinFreq = 100*1e3; %Hz
%     handles.ExperimentFunctions.interfaceSigGen.MaxFreq = 20*1e9; %Hz
%     handles.ExperimentFunctions.interfaceSigGen.MinAmp = -20; %dBm
%     handles.ExperimentFunctions.interfaceSigGen.MaxAmp = 15; %dBm
%     
%     % apparently 5025 is the right port according to "Programming-mw-source-agilent.pdf"
%     % never use the IP to control the generator, as the DCHP makes the IP
%     % change constantly; rather use 'a-N5183A-40016'
%     
%     handles.ExperimentFunctions.interfaceSigGen.reset();
%     
% else
%     
%     handles.ExperimentFunctions.interfaceSigGen = SignalGeneratorAgilent_simu();
%     
% end


if handles.Imaginghandles.QEGhandles.pulse_mode == 0 || handles.Imaginghandles.QEGhandles.pulse_mode == 1
    IPAddress='18.62.12.111'; %SG386
    TCPPort=5025;  
    Timeout=10; 
    InputBufferSize=1000000;
    OutputBufferSize=1000000;    
    
    % Initialize the Signal Generator object and establish the TCP/IP connection
    disp('Setting up the Signal Generator')
    handles.ExperimentFunctions.interfaceSigGen = SG386(IPAddress,TCPPort,Timeout,InputBufferSize,OutputBufferSize);
    if strcmp(get(handles.ExperimentFunctions.interfaceSigGen.SocketHandle,'Status'),'closed')
        err = handles.ExperimentFunctions.interfaceSigGen.open();
        if err
            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
            return;
         end
    end
    
else
    handles.ExperimentFunctions.interfaceSigGen = SignalGeneratorAgilent_simu();
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP AWG                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if handles.Imaginghandles.QEGhandles.pulse_mode == 0
    
    %Setting levels of AWG markers
    
    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.open();
    %Switch: 1.5V
    %(channel,1/2,low,high)
    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.setmarker(1,2,0,1.5);
    
    %SPD: 2V
    %(channel,1/2,low,high)
    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.setmarker(2,1,0,2);
    
    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.close();
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  SETUP Data Acquisition Card (NI) for pulsed experiments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add Clock Line - This is the APD clock,
% the "clock" telling when to acquire;
% It is hooked up to ctr2 gate
handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.addClockLine('Dev1/ctr2','/Dev1/PFI1');
%clock line #3

% add Clock Line - This is the APD clock,
% the "clock" coming from the SignalGenerator Trig Out telling when to acquire;
% It is hooked up to ctr3 gate
handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.addClockLine('Dev1/ctr3','/Dev1/PFI6');
%clock line #4

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Experiment properties             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%delay init and end seq
handles.ExperimentFunctions.delay_init_and_end_seq = 0.1*1e-6; %s

