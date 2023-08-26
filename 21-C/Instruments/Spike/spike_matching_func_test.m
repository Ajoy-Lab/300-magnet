function [final_vco_range,final_vco_volt]=spike_matching_func(pw1,arb1,vco1_range,vco1_volt,bw_min,bw_max)

% clear;
% close_devices();

%% Power supply ports
%pw1=Prog_Supply('COM13');
pw1.PS_OUTOff;

%% Sig gen ports
%arb1=Agilent_arb;
%arb1=arb1.MW_Open();
arb1.MW_RFOff();arb1.set_burst_off();


%% Set up target deviation  
deviation=0.005;                   

%% feedback loop for VCO1
cyc=0;

pw1.PS_VoltSet(vco1_volt);pw1.PS_OUTOn;
arb1.define_ramp(2e3,vco1_range,0,0);
arb1.MW_RFOn();
[data1,freq_vec,peak_val]=sweep_VCO(pw1,vco1_volt,1,bw_min,bw_max);
pause(0.2);
arb1.MW_RFOff();pw1.PS_OUTOff;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[left1,right1]=getsides(freq_vec,data1);
err_bw=(right1-left1)/(bw_max-bw_min);
err_mean=(right1+left1)/(bw_max+bw_min);
err_dc=(right1+left1-(bw_max+bw_min))/(2.6642*10^8);

while max(abs(1-abs(err_bw))*(bw_max-bw_min),abs(1-abs(err_mean))*(bw_max+bw_min)/2)>=deviation
  
    vco1_range=vco1_range/err_bw;
    %vco1_volt=vco1_volt/err_mean;
    vco1_volt=vco1_volt-err_dc;
    
    
    cyc=cyc+1;
    if cyc>20
        break;
    end
      
    disp(['... Tuning VCO bandwidth, iteration ' num2str(cyc)]);
    
    err(cyc)=max(abs(1-abs(err_bw))*(bw_max-bw_min),abs(1-abs(err_mean))*(bw_max+bw_min)/2);
    pw1.PS_VoltSet(vco1_volt);pw1.PS_OUTOn;
    arb1.define_ramp(2e3,vco1_range,0,0);arb1.MW_RFOn();
      pause(0.5);
    [data1,freq_vec,peak_val]=sweep_VCO(pw1,vco1_volt,1,bw_min,bw_max);
    arb1.MW_RFOff();pw1.PS_OUTOff;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [left1,right1]=getsides(freq_vec,data1);
    err_bw=(right1-left1)/(bw_max-bw_min);
    err_mean=(right1+left1)/(bw_max+bw_min);
end
disp(['The voltage range of VCO1:' num2str(vco1_range)]);
disp(['The voltage center of VCO1:' num2str(vco1_volt)]);

final_vco_range=vco1_range;
final_vco_volt=vco1_volt;

%% Close
LibraryName = 'sa_api';
handle = uint32(0);
[close] = calllib(LibraryName, 'saCloseDevice', handle);
arb1.MW_RFOff();pw1.PS_OUTOff;


end

function [data,freq_vec,peak_val]=sweep_VCO(pw,volt,fig_num,bw_min,bw_max)
%% Initialize spike
LibraryName = 'sa_api';
LibraryFilePath = 'sa_api.dll';
HeaderFilePath = 'sa_api.h';
[start,stop]=Initialize(bw_min,bw_max);
%% Sweep and get peak
start_fig(fig_num,[4 1]);
for j=1:size(volt,2)
    pw.PS_VoltSet(volt(j));
    %disp(['Getting sweep for ' num2str(volt(j)) ' V']);
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
function [start,stop]= Initialize(bw_min,bw_max)
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
center = 1e9*(bw_min+bw_max)/2;
span = 1e9*4*abs(bw_min-bw_max);
if span>1e9
    span=1e9;
end
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

