function [hObject,handles] = Imaging_InitScript(hObject,handles)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  SETUP Data Acquisition Card (NI)  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if handles.QEGhandles.pulse_mode == 1 || handles.QEGhandles.pulse_mode == 0
    
    warning off MATLAB:loadlibrary:TypeNotFound
    warning off MATLAB:loadlibrary:TypeNotFoundForStructure
    %disables warning having to do with bugs in loadlibrary function
    %http://www.mathworks.com/matlabcentral/answers/259-warnings-returned-by-loadlibrary
    
    % configure NIDAQ Instance
    LibraryName = 'nidaqmx';
    LibraryFilePath = 'nicaiu.dll';
    HeaderFilePath = 'NIDAQmx.h';
    handles.ImagingFunctions.interfaceDataAcq = DAQNI(LibraryName,LibraryFilePath,HeaderFilePath);
    
    handles.ImagingFunctions.interfaceDataAcq.SampleRate = 100e6; %100MHz is the sampling rate as specified for Pcie-6323
    handles.ImagingFunctions.interfaceDataAcq.AnalogOutMinVoltage = -10;
    handles.ImagingFunctions.interfaceDataAcq.AnalogOutMaxVoltage = 10;
    handles.ImagingFunctions.interfaceDataAcq.ReadTimeout = 10;
    handles.ImagingFunctions.interfaceDataAcq.WriteTimeout = 10;
    handles.ImagingFunctions.interfaceDataAcq.CounterOutSamples = 10000000000;
    
    % add Counter Line - coming from APD
    % hooked up to ctr0 source
    handles.ImagingFunctions.interfaceDataAcq.addCounterInLine('Dev1/ctr0','/Dev1/PFI8');
    
    % add Clock Line - This is the piezo sample clock,
    % the "clock" coming from piezo in pixel clock
    % hooked up to ctr0 gate
    handles.ImagingFunctions.interfaceDataAcq.addClockLine('Dev1/ctr0','/Dev1/PFI9');
    %clockline 1
    
    % for tracking/counting need one more clock,
    % corresponding to out of ctr1
    handles.ImagingFunctions.interfaceDataAcq.addClockLine('Dev1/ctr1','/Dev1/PFI13');
    %clockline 2
    
    % +5V for the two SPD gates
    handles.ImagingFunctions.interfaceDataAcq.addAOLine('/Dev1/ao0',5);
    handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
    
    handles.ImagingFunctions.interfaceDataAcq.addAOLine('/Dev1/ao1',5);
    handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(2);
    
    handles.ImagingFunctions.interfaceDataAcq.addAILine('/Dev1/ai6');
    %Analog Input line 1 to monitor photodiode
    
else
    
    handles.ImagingFunctions.interfaceDataAcq = DAQNI_simu();
    
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Pulse Generator                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if handles.QEGhandles.pulse_mode == 1
    
    LibraryName = 'spinapi';
    LibraryFilePath = 'spinapi.dll';
    HeaderFilePath = 'spinapi.h';
    
    handles.ImagingFunctions.interfacePulseGen = PulseGeneratorSpinCorePulseBlaster(LibraryFilePath,HeaderFilePath,LibraryName);
    handles.ImagingFunctions.interfacePulseGen.PBInit();
    handles.ImagingFunctions.interfacePulseGen.SampleRate = 500e6; %ClockRate of our pulse blaster is 500MHz
    handles.ImagingFunctions.interfacePulseGen.SetClock(handles.ImagingFunctions.interfacePulseGen.SampleRate);
     
elseif handles.QEGhandles.pulse_mode == 0 %use AWG
    
    InputBufferSize = 1000000;
    OutputBufferSize = 1000000;
    Timeout = 60;
    
    handles.ImagingFunctions.interfacePulseGen = ArbitraryWaveformGeneratorTektronix('Awg',1012,Timeout,InputBufferSize,OutputBufferSize); %port 1012 is the port that is "opened to connections" as chosen in the AWG software window
    handles.ImagingFunctions.interfacePulseGen.open();
    
    handles.ImagingFunctions.interfacePulseGen.InputBufferSize = InputBufferSize;
    handles.ImagingFunctions.interfacePulseGen.OutputBufferSize = OutputBufferSize;
    handles.ImagingFunctions.interfacePulseGen.Timeout = Timeout;
    handles.ImagingFunctions.interfacePulseGen.Frequency = [0,0,0,0];
    handles.ImagingFunctions.interfacePulseGen.Amplitude = [0,0,0,0]; 
    handles.ImagingFunctions.interfacePulseGen.MinFreq = 0;
    handles.ImagingFunctions.interfacePulseGen.MaxFreq = 250*1e6;
    handles.ImagingFunctions.interfacePulseGen.MinAmp = -30; %or 20mVpp
    handles.ImagingFunctions.interfacePulseGen.MaxAmp = 17;  %4.5Vpp
    handles.ImagingFunctions.interfacePulseGen.MinSampleRate = 1e7; 
    handles.ImagingFunctions.interfacePulseGen.MaxSampleRate = 1.2e9;
    handles.ImagingFunctions.interfacePulseGen.max_number_of_reps = 65000; % Actually number of reps go from 1 to 65,536; to simplify, taken here max number of reps 65000
    
    handles.ImagingFunctions.interfacePulseGen.SampleRate = 1.0e9; %Max SampleRate of our AWG is 1.2GS/s; using 1.0GS/s because it gives a time detail of exactly 1ns
    handles.ImagingFunctions.interfacePulseGen.Set();
    
    %AOM: 2.7V min at on, 7V max
    %(channel,1/2,low,high)
    handles.ImagingFunctions.interfacePulseGen.setmarker(1,1,0,3);  
    handles.ImagingFunctions.interfacePulseGen.close();
    
elseif handles.QEGhandles.pulse_mode == 2 %simu PB
    
    handles.ImagingFunctions.interfacePulseGen = PulseGeneratorSpinCorePulseBlaster_simu();
    
elseif handles.QEGhandles.pulse_mode == 3 %simu AWG
    
    handles.ImagingFunctions.interfacePulseGen = ArbitraryWaveformGeneratorTektronix_simu();
    
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP Piezo (Mad City Labs) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if handles.QEGhandles.pulse_mode == 1 || handles.QEGhandles.pulse_mode == 0

    LibraryName = 'Madlib';
    LibraryFilePath = 'Madlib.dll';
    HeaderFilePath = 'Madlib.h';
    ADCtime = 5; %in ms
    DAQtime = 1; %in ms
    %handles.ImagingFunctions.interfaceScanning = PiezoMadCityLabs(LibraryName,LibraryFilePath,HeaderFilePath,ADCtime,DAQtime);
    handles.ImagingFunctions.interfaceScanning = PiezoNpoint(LibraryName,LibraryFilePath,HeaderFilePath,ADCtime,DAQtime);
    handles.ImagingFunctions.interfaceScanning.ADCtime = ADCtime;
    handles.ImagingFunctions.interfaceScanning.DAQtime = DAQtime;
    handles.ImagingFunctions.interfaceScanning.HighEndOfRange = [200 200 200]; %in mum
    handles.ImagingFunctions.interfaceScanning.LowEndOfRange = [0 0 0]; %in mum
    handles.ImagingFunctions.interfaceScanning.StabilizeTime=0.05; %sec
    handles.ImagingFunctions.interfaceScanning.nFlat = 100;           
    handles.ImagingFunctions.interfaceScanning.nOverRun = 75;      
    handles.ImagingFunctions.interfaceScanning.LagPts = 5; % PC
    handles.ImagingFunctions.interfaceScanning.precision = [0.0001,0.0001,0.0001]; %in mum

else
    
    handles.ImagingFunctions.interfaceScanning = PiezoMadCityLabs_simu();
    
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP Tracking                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.ImagingFunctions.TrackerDwellTime = 0.005;
handles.ImagingFunctions.TrackerDutyCycle = 0.5;
handles.ImagingFunctions.TrackerCounterInLine = 1; % corresponds to gate of crt0
handles.ImagingFunctions.TrackerCounterOutLine = 2; % corresponds to out of crt1
handles.ImagingFunctions.TrackerInitialStepSize = [1.5,1.5,1.5];
handles.ImagingFunctions.TrackerMinimumStepSize = [0.0005,0.0005,0.0005]; %determined by piezo
handles.ImagingFunctions.TrackerMaxIterations = 250;
handles.ImagingFunctions.TrackerTrackingThreshold = 1; %in kcps
handles.ImagingFunctions.TrackerStepReductionFactor  = [.5,.5,.5];
handles.ImagingFunctions.TrackerNumberOfSamples = 20;%50 is good for tracking; 20 is good for optimizing counts

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP Scans and properties of ImagingFunctions  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initial values to show
handles.ImagingFunctions.NumPoints = [100,100,100];
handles.ImagingFunctions.bEnable = [0,0,0];

