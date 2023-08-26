clear;
close_devices();

%% Power supply ports
pw1=Prog_Supply('COM13');pw1.PS_OUTOff;
pw2=Prog_Supply('COM6');pw2.PS_OUTOff;
pw3=Prog_Supply('COM7');pw3.PS_OUTOff;

%% Sig gen ports
arb1=Agilent_arb;
arb1=arb1.MW_Open();arb1.MW_RFOff();arb1.set_burst_off();

arb2=Rigol_arb('USB0::0x0400::0x09C4::DG1D191601684::INSTR');
arb2.MW_RFOff();arb2.set_burst_off();

arb3=Rigol_arb('USB0::0x400::0x09C4::DG1D191601702::INSTR');
arb3.MW_RFOff();arb3.set_burst_off();




%% Set up target BW
bw_min=2.7;
bw_max=3.2;



%% Sweep range in volts
volt1=linspace(6.5,9.5,25);
volt2=linspace(6.5,9.5,25);
volt3=linspace(6.5,9.5,25);

%% Sweep range with calibrated tuning voltages
% volt1=6.8:0.1:9.8;
% volt2=6.78:0.1:9.73;
% volt3=6.90:0.1:9.72;
% volt1=round(linspace(6.80,9.80,25),2);
% volt2=round(linspace(6.78,9.73,25),2);
% volt3=round(linspace(6.90,9.92,25),2);

%% Init power supply
pw1.PS_OUTOn;
[data,freq_vec,peak_val1]=sweep_VCO(pw1,volt1,11);
pw1.PS_OUTOff;
[f1,xvec,fitted]= fit_linear(volt1,peak_val1/1e9);
vco1_range=[(bw_min-f1.m(1))/f1.m(2) (bw_max-f1.m(1))/f1.m(2)];
vco1_volt=mean(vco1_range);
vco1_range=diff(vco1_range);
pw1.PS_VoltSet(vco1_volt);pw1.PS_OUTOn;
arb1.define_ramp(1e3,vco1_range,0,0);
[data1,freq_vec,peak_val]=sweep_VCO(pw1,vco1_volt,1);pause(1);
arb1.MW_RFOff();pw1.PS_OUTOff;


pw2.PS_OUTOn;
[data,freq_vec,peak_val2]=sweep_VCO(pw2,volt2,12);
pw2.PS_OUTOff;
[f2,xvec,fitted]= fit_linear(volt2,peak_val2/1e9);
vco2_range=[(bw_min-f2.m(1))/f2.m(2) (bw_max-f2.m(1))/f2.m(2)];
vco2_volt=mean(vco2_range);
vco2_range=diff(vco2_range);
pw2.PS_VoltSet(vco1_volt);pw2.PS_OUTOn;
arb2.define_ramp(1e3,vco2_range,0,0);arb2.MW_RFOn();
[data2,freq_vec,peak_val]=sweep_VCO(pw2,vco2_volt,2);pause(1);
arb2.MW_RFOff();pw2.PS_OUTOff;

pw3.PS_OUTOn;
[data,freq_vec,peak_val3]=sweep_VCO(pw3,volt3,13);
pw3.PS_OUTOff;
[f3,xvec,fitted]= fit_linear(volt3,peak_val3/1e9);
vco3_range=[(bw_min-f3.m(1))/f3.m(2) (bw_max-f3.m(1))/f3.m(2)];
vco3_volt=mean(vco3_range);
vco3_range=diff(vco3_range);
pw3.PS_VoltSet(vco1_volt);pw3.PS_OUTOn;
arb3.define_ramp(1e3,vco3_range,0,0);arb3.MW_RFOn();
[data3,freq_vec,peak_val]=sweep_VCO(pw3,vco3_volt,3);pause(1);
arb3.MW_RFOff();pw3.PS_OUTOff;

start_fig(5,[3 2]);
plot_preliminaries(freq_vec,data1/1e9,1,'nomarker');
plot_preliminaries(freq_vec,data2/1e9,2,'nomarker');
plot_preliminaries(freq_vec,data3/1e9,3,'nomarker');

start_fig(2,[3 2]);
plot_preliminaries(volt1,peak_val1/1e9,1);
plot_preliminaries(volt2,peak_val2/1e9,2);
plot_preliminaries(volt3,peak_val3/1e9,3);
legend('Sweeper1', 'Sweeper2','Sweeper3');
plot_labels('Voltage [V]','Frequency [GHz]');

%% Close
LibraryName = 'sa_api';
handle = uint32(0);
[close] = calllib(LibraryName, 'saCloseDevice', handle);
pw1.PS_Close();


function [data,freq_vec,peak_val]=sweep_VCO(pw,volt,fig_num)
%% Initialize spike
LibraryName = 'sa_api';
LibraryFilePath = 'sa_api.dll';
HeaderFilePath = 'sa_api.h';
[start,stop]=Initialize();
%% Sweep and get peak
start_fig(fig_num,[4 1]);
for j=1:size(volt,2)
    pw.PS_VoltSet(volt(j));
    disp(['Getting sweep for ' num2str(volt(j)) ' V']);
    [data,sweeplen] = GetSweep();
    freq_vec=linspace(start,stop,sweeplen.Value);
    [maxval,IX]=max(data);
    peak_val(j)=freq_vec(IX);
    
    plot_preliminaries(freq_vec,data,j,'nomarker');hold on;
end
end
%reads current frequency sweep and returns y-axis amplitudes over sweep
%length
function [data,sweeplen] = GetSweep()
handle = uint32(0);
LibraryName = 'sa_api';
LibraryFilePath = 'sa_api.dll';
HeaderFilePath = 'sa_api.h';
%Returns relevant characteristics of a sweep after device configuration
sweeplen = libpointer('int32Ptr', 1);
startf = libpointer('doublePtr', 1);
binsize = libpointer('doublePtr', 2);
trace = calllib('sa_api', 'saQuerySweepInfo', handle, sweeplen, startf, binsize);

min = libpointer('singlePtr', zeros(1, sweeplen.Value));
max = libpointer('singlePtr', zeros(1, sweeplen.Value));
sweep = calllib(LibraryName, 'saGetSweep_32f', handle, min, max);
data = max.value;
end



%Initializes SA44b device and configures settings for sweeping mode.
function [start,stop]= Initialize()
LibraryName = 'sa_api';
LibraryFilePath = 'sa_api.dll';
HeaderFilePath = 'sa_api.h';
%Load Spike Library
[status] = loadlibrary(LibraryFilePath,HeaderFilePath,'alias',LibraryName);

%Open Spectrum Analyzer
devicePtr=libpointer('int32Ptr',0);
handle = devicePtr.Value;
message=calllib('sa_api','saOpenDevice',devicePtr);

%Get Device type and serial number (only for testing communications)
% type = libpointer('saDeviceType', 1);
% [status] = calllib(LibraryName,'saGetDeviceType', handle,type); 
% 
% serial = libpointer('int32Ptr', 1);
% [status] = calllib(LibraryName,'saGetSerialNumber',handle,serial);

%Configure detection mode and linear/log scaling
SA_MIN_MAX = uint32(0);
detector = SA_MIN_MAX;
SA_LIN_SCALE = uint32(0);
scale = SA_LIN_SCALE;
settings(1,:) = calllib(LibraryName, 'saConfigAcquisition', handle, detector, scale);

%Configure sweep frequency range
center = 2.95e9;
span = 6e8;
stop = center + (span/2);
start = center - (span/2);
settings(2,:) = calllib(LibraryName, 'saConfigCenterSpan', handle, center, span);

%Configure reference level
ref = double(18);
settings(3,:) = calllib(LibraryName, 'saConfigLevel', handle, ref);

%Configure gain and attenuation (automatic if function is not called
atten = -1;
gain = -1;
settings(4,:) = calllib(LibraryName, 'saConfigGainAtten', handle, atten, gain, 0);

%Configure RBW/VBW settings
rbw =100e3;
vbw = 100e3;
reject = 1; %enables image rejection
coupling = calllib(LibraryName, 'saConfigSweepCoupling', handle, rbw, vbw, reject);

%Configure VBW Processing
SA_POWER_UNITS = uint32(0);
units = SA_POWER_UNITS;
settings(6,:) = calllib(LibraryName, 'saConfigProcUnits', handle, units);

%Configure RBW Shape
SA_RBW_SHAPE_FLATTOP = uint32(0);
flat = SA_RBW_SHAPE_FLATTOP;
[shape] = calllib(LibraryName, 'saConfigRBWShape', handle, flat);

%Initialize Sweep mode
SA_SWEEPING = uint32(0);
[status] = calllib(LibraryName, 'saInitiate', handle, SA_SWEEPING, 0);

end

function  close_devices()
serialObj = instrfind;
s=size(serialObj);
for i=1:s(1,2)
    fclose(serialObj(i));
end
end

function [f2,xvec,fitted]= fit_linear(x,y,varargin)
x(isnan(y))=[]; %to remove the NaNs
y(isnan(y))=[]; %to remove the NaNs
f2 = ezfit(x,y, 'z(v)=poly1');
if(nargin>2)
    xvec=varargin{1};
else
xvec=linspace(x(1),x(end),1000);
end
fitted=(f2.m(1) + f2.m(2).*xvec);

end

