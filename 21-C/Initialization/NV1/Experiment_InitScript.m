function [hObject,handles] = Experiment_InitScript(hObject,handles)

%% CLOSE ALL OPEN PORTS
serialObj = instrfind;
s=size(serialObj);
for i=1:s(1,2)
fclose(serialObj(i));
delete(serialObj(i));
end

%% RESET all instrument connections
instrreset;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  SETUP Data Acquisition Card (NI) for pulsed experiments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % add Clock Line - This is the APD clock,
% % the "clock" telling when to acquire;
% % It is hooked up to ctr2 gate
% handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.addClockLine('Dev1/ctr2','/Dev1/PFI1');
% %clock line #3
% 
% % add Clock Line - This is the APD clock,
% % the "clock" coming from the SignalGenerator Trig Out telling when to acquire;
% % It is hooked up to ctr3 gate
% handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.addClockLine('Dev1/ctr3','/Dev1/PFI6');

%handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.CreateTask('NIDAQTask')
%handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutRamp('/Dev1/ao0', 0, 0, 0, 0, false);
%clock line #4

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GPIB LockIn Amp
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.gpib_LockInAmp=SR830;
% handles.ExperimentFunctions.gpib_LockInAmp=handles.ExperimentFunctions.gpib_LockInAmp.Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Signal Generator        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The signal generator, when it is on,  can also be accessed and controlled thru a web browser at the
% following address: http://a-N5183A-40016
%handles.ExperimentFunctions.mw=MicroWave_Generator;

% handles.ExperimentFunctions.mw=Agilent_sweeper;
% handles.ExperimentFunctions.mw=handles.ExperimentFunctions.mw.MW_Open();
% 
% handles.ExperimentFunctions.mw2=Gigatronics_sweeper;
% handles.ExperimentFunctions.mw2=handles.ExperimentFunctions.mw2.MW_Open();
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Agilent ARB   (ARB 1)     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb1=Agilent_arb;
% handles.ExperimentFunctions.arb1=handles.ExperimentFunctions.arb1.MW_Open();

% handles.ExperimentFunctions.arb1=Rigol_arb('USB0::0x0400::0x09C4::DG1D192002131::INSTR');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol  (ARB 2)     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb3=Rigol_arb('USB0::0x400::0x09C4::DG1D191601702::INSTR');
% handles.ExperimentFunctions.arb3=handles.ExperimentFunctions.arb3.MW_Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol (ARB 3)      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb2=Rigol_arb('USB0::0x0400::0x09C4::DG1D191601684::INSTR');
% handles.ExperimentFunctions.arb2=handles.ExperimentFunctions.arb2.MW_Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol (ARB 4)      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb4=Rigol_arb('USB0::0x0400::0x09C4::DG1D192002144::INSTR');
% handles.ExperimentFunctions.arb2=handles.ExperimentFunctions.arb2.MW_Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol  (ARB 5)      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb5=Rigol_arb('USB0::0x0400::0x09C4::DG1D191701802::INSTR');
% handles.ExperimentFunctions.arb2=handles.ExperimentFunctions.arb2.MW_Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol  (ARB 6)      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb6=Rigol_arb('USB0::0x0400::0x09C4::DG1D191902048::INSTR');
% handles.ExperimentFunctions.arb2=handles.ExperimentFunctions.arb2.MW_Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol  (ARB 7)      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb7=Rigol_arb('USB0::0x0400::0x09C4::DG1D191701785::INSTR');
% handles.ExperimentFunctions.arb2=handles.ExperimentFunctions.arb2.MW_Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol  (ARB 8)      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb8=Rigol_arb('USB0::0x0400::0x09C4::DG1D191501598::INSTR');
% handles.ExperimentFunctions.arb2=handles.ExperimentFunctions.arb2.MW_Open();
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol  (ARB 9-12)      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% handles.ExperimentFunctions.arb9=Agilent_arb;
% handles.ExperimentFunctions.arb9=handles.ExperimentFunctions.arb9.MW_Open();
% 
% handles.ExperimentFunctions.arb10=Rigol_arb('USB0::0x0400::0x09C4::DG1D191701816::INSTR');
% handles.ExperimentFunctions.arb11=Rigol_arb('USB0::0x0400::0x09C4::DG1D192002129::INSTR');
% handles.ExperimentFunctions.arb12=Rigol_arb('USB0::0x0400::0x09C4::DG1D191902040::INSTR');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP HP ARB 1 (ARB 4)       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb4=HP_arb4;
% handles.ExperimentFunctions.arb4=handles.ExperimentFunctions.arb4.MW_Open();
% handles.ExperimentFunctions.arb2=handles.ExperimentFunctions.arb2.MW_Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Power supply        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.pw=Power_Supply;
% handles.ExperimentFunctions.pw=handles.ExperimentFunctions.pw.PS_Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Power supply        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%handles.ExperimentFunctions.pw1=Prog_Supply('COM13');
%handles.ExperimentFunctions.pw2=Prog_Supply('COM6');
% handles.ExperimentFunctions.pw3=Prog_Supply('COM7');
%handles.ExperimentFunctions.pw4=Prog_Supply('COM14');

% handles.ExperimentFunctions.pw5=Prog_Supply('COM15');
% handles.ExperimentFunctions.pw6=Prog_Supply('COM16');
% handles.ExperimentFunctions.pw7=Prog_Supply('COM17');
%handles.ExperimentFunctions.pw8=Prog_Supply('COM18');

% handles.ExperimentFunctions.pw4=Siglent_Supply('USB0::0x0483::0x7540::SPD3ECAC1L1266::INSTR');
% handles.ExperimentFunctions.pw1=handles.ExperimentFunctions.pw1.PS_Open();
% 
% handles.ExperimentFunctions.pw2=Prog_Supply2;
% handles.ExperimentFunctions.pw2=handles.ExperimentFunctions.pw2.PS_Open();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Laser rotation stage       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.laser=Zaber;
%handles.ExperimentFunctions.laser=handles.ExperimentFunctions.laser.Zaber_Open();


%handles.ExperimentFunctions.mw.AM100();
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

% %if handles.Imaginghandles.QEGhandles.pulse_mode == 0 || handles.Imaginghandles.QEGhandles.pulse_mode == 1
% %ashok 12/12/13 Make right sig gen work in simu mode
% %IPAddress='18.62.18.197'; %SG386
%     IPAddress='18.62.18.59'; %SG386
%     TCPPort=5025;  
%     %Timeout=10; 
%     Timeout=30; %s 
%     InputBufferSize=1024;
%     OutputBufferSize=1024;    
%     %InputBufferSize=1000000;
%     %OutputBufferSize=1000000;    
%     
%     % Initialize the Signal Generator object and establish the TCP/IP connection
%     disp('Setting up the Signal Generator')
%     handles.ExperimentFunctions.interfaceSigGen = SG386(IPAddress,TCPPort,Timeout,InputBufferSize,OutputBufferSize);
%     if strcmp(get(handles.ExperimentFunctions.interfaceSigGen.SocketHandle,'Status'),'closed')
%         err = handles.ExperimentFunctions.interfaceSigGen.open();
%         if err
%             handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
%             return;
%          end
%     end
%     
%else
    
 %   handles.ExperimentFunctions.interfaceSigGen = SignalGeneratorAgilent_simu();
    
%end



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Signal Generator 2       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if handles.Imaginghandles.QEGhandles.pulse_mode == 0 || handles.Imaginghandles.QEGhandles.pulse_mode == 1
%ashok 12/12/13 Make right sig gen work in simu mode
%     IPAddress='18.62.18.197'; %SG386
%     %  IPAddress='18.62.18.59'; %SG386
%     TCPPort=5025;  
%     %Timeout=10; 
%     Timeout=30; %s 
%     InputBufferSize=1024;
%     OutputBufferSize=1024;    
%     %InputBufferSize=1000000;
%     %OutputBufferSize=1000000;    
%     
%     % Initialize the Signal Generator object and establish the TCP/IP connection
%     disp('Setting up the Signal Generator')
%     handles.ExperimentFunctions.interfaceSigGen2 = SG386(IPAddress,TCPPort,Timeout,InputBufferSize,OutputBufferSize);
%     if strcmp(get(handles.ExperimentFunctions.interfaceSigGen2.SocketHandle,'Status'),'closed')
%         err = handles.ExperimentFunctions.interfaceSigGen2.open();
%         if err
%             handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
%             return;
%          end
%     end
%     
%else
    
 %   handles.ExperimentFunctions.interfaceSigGen = SignalGeneratorAgilent_simu();
    
%end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP WindFreak        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handles.ExperimentFunctions.wf=WindFreak_CFA('com16');
% handles.ExperimentFunctions.wf.setClockRef(0); %external clock
%handles.ExperimentFunctions.wf.open();
% to test uncomment the statements below
% handles.ExperimentFunctions.wf.setFreq(2e9,1,0);
% handles.ExperimentFunctions.wf.setAmp(-10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP BNC       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp('Setting up the BNC pulse generator')
% handles.ExperimentFunctions.interfaceBNC = BNCpb();
% if strcmp(get(handles.ExperimentFunctions.interfaceBNC.SocketHandle,'Status'),'closed')
%     err = handles.ExperimentFunctions.interfaceBNC.open();
% %     if err
% %         handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
% %         return;
% %     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP AWG                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if handles.Imaginghandles.QEGhandles.pulse_mode == 0
%     
%     %Setting levels of AWG markers
%     
%     handles.Imaginghandles.ImagingFunctions.interfacePulseGen.open();
%     %Switch: 1.5V
%     %(channel,1/2,low,high)
%     handles.Imaginghandles.ImagingFunctions.interfacePulseGen.setmarker(1,2,0,1.5);
%     
%     %SPD: 2V
%     %(channel,1/2,low,high)
%     handles.Imaginghandles.ImagingFunctions.interfacePulseGen.setmarker(2,1,0,2);
%     
%     handles.Imaginghandles.ImagingFunctions.interfacePulseGen.close();
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP RAMP GENERATOR                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   handles.ExperimentFunctions.ramp=RampGen();
%   handles.ExperimentFunctions.ramp=handles.ExperimentFunctions.ramp.Ramp_Open();
%   handles.ExperimentFunctions.ramp.Start_RampGen();

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP BK Power supply        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%handles.ExperimentFunctions.psu=BKPowerSupply();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Circuit Specialist Power supply        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.ExperimentFunctions.psu2=Prog_Supply('COM3');
% handles.ExperimentFunctions.psu2=Prog_Supply('COM17');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP TABOR AWG    %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.tabor=TaborAWG();
% handles.ExperimentFunctions.tabor.awg_stop();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP SG386 signal generator    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.srs=SG386gpib();
% handles.ExperimentFunctions.srs.MW_Open();
% handles.ExperimentFunctions.srs.set_MWoff();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP HP8672A signal generator    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.srs=HP8672A();
% handles.ExperimentFunctions.srs.MW_Open();
% handles.ExperimentFunctions.srs.set_MWoff();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol 1 Sine     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb2=Rigol_arb_sine('USB0::0x0400::0x09C4::DG1D192002131::INSTR');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol 2 Sine     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%handles.ExperimentFunctions.arb3=Rigol_arb_sine('USB0::0x0400::0x09C4::DG1D191601684::INSTR');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ACTUATOR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.ExperimentFunctions.com = actxserver('SPiiPlusCOM660.Channel.1');
handles.ExperimentFunctions.com.OpenCommEthernetTCP('10.0.0.100', 701)
handles.ExperimentFunctions.com.Enable(handles.ExperimentFunctions.com.ACSC_AXIS_0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ARDUINO LASER DOME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.ExperimentFunctions.laserdome=Laser_Dome_Arduino('COM11','COM12','COM13');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol for magnetometer    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.arb_mag=Rigol_arb_mag('USB0::0x0400::0x09C4::DG1D191701785::INSTR');
% handles.ExperimentFunctions.arb_mag=Rigol_arb_mag('USB0::0x0400::0x09C4::DG1D191701816::INSTR');
%handles.ExperimentFunctions.arb_mag=Rigol_arb_mag('COM16');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol for magnetometer 2    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%handles.ExperimentFunctions.arb_mag2=Rigol_arb_mag('USB0::0x0400::0x09C4::DG1D191902040::INSTR');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Tabor AWG (Slow) for magnetometer    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handles.ExperimentFunctions.arb_mag_tabor=TaborPM8572("COM16");
% handles.ExperimentFunctions.arb_mag_tabor2=TaborPM8572("COM5");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Rigol DS7024 scope for experimental capture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.scope=RigolDS7024();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Experiment properties             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Tektronix AFG 31000 for AC field generation for magnetometry
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentFunctions.tektronix_AFG_31000 = Tektronix_AFG_31000("USB0::0x0699::0x0355::C019986::INSTR");

%delay init and end seq
handles.ExperimentFunctions.delay_init_and_end_seq = 0.1*1e-6; %s


