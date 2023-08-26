function [final_vco_range,final_vco_volt]=spike_matching_func(pw1,arb1,vco1_range,vco1_volt,bw_min,bw_max,A,B)
vco1_volt=((bw_min+bw_max)/2-A)/B;
% vco1_volt=2.8;
% vco1_range=7;
% clear;
% close_devices();

%% Power supply ports
%pw1=Prog_Supply('COM13');
pw1.PS_OUTOff;

%% Sig gen ports
%arb1=Agilent_arb;
%arb1=arb1.MW_Open();
arb1.MW_RFOff();
pause(0.2);
arb1.set_burst_off();
pause(0.2);


%% Set up target deviation  
deviation=0.005;                   

%% Linear fit
% volt1=linspace(6.5,9.5,25);
% pw1.PS_OUTOn;
% [data,freq_vec,peak_val1]=sweep_VCO(pw1,volt1,11);
% pw1.PS_OUTOff;
% %%%%%%%%%%% Saving results
% fp=fopen('D:\QEG2\21-C\Instruments\Spike\Fitting log\F_V_data_bestVCO.txt','wt');
%     for i=1:length(volt1)
%        fprintf(fp,['%f %f\n'],volt1(i),peak_val1(i));
%     end
%     [f1,xvec,fitted]= fit_linear(volt1,peak_val1/1e9);
%     fprintf(fp,['A=%f, B= %f\n'],f1.m(1),f1.m(2));
%     fclose(fp);
% disp('The F-V data for VCO1 has been written in D:\QEG2\21-C\Instruments\Spike\Fitting log\F_V_data_bestVCO.txt.txt');
% 


%% feedback loop for VCO1
cyc=0;

pw1.PS_VoltSet(vco1_volt);
pw1.PS_OUTOn;
arb1.define_ramp(2e3,vco1_range,0,0);
pause(0.2);
arb1.MW_RFOn();
pause(0.2);
[data1,freq_vec,peak_val]=sweep_VCO(pw1,vco1_volt,1,bw_min,bw_max);
pause(0.2);
arb1.MW_RFOff();
pause(0.2);
pw1.PS_OUTOff;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[left1,right1]=getsides2(freq_vec,data1);
err_bw=(right1-left1)/(bw_max-bw_min);
err_mean=(right1+left1)/(bw_max+bw_min);
%err_dc=(right1+left1-(bw_max+bw_min))/(2.6642*10^8);
d1_right=abs((1-err_mean)*(bw_max+bw_min)/2+(1-err_bw)*(bw_max-bw_min)/2);
d1_left=abs((1-err_mean)*(bw_max+bw_min)/2-(1-err_bw)*(bw_max-bw_min)/2);
%while max(abs(1-abs(err_bw))*(bw_max-bw_min),abs(1-abs(err_mean))*(bw_max+bw_min)/2)>=deviation
while max(d1_left,d1_right)>deviation
    vco1_range=vco1_range/err_bw;
    vco1_volt=vco1_volt/err_mean;
%     vco1_volt=A+(vco1_volt-A)/err_mean;
    %vco1_volt=vco1_volt-err_dc;
    
    if vco1_volt<2||vco1_volt>20
        vco1_volt=7.3;
    end
%     if vco1_volt<1||vco1_volt>16
%         vco1_volt=2.4;
%     end
    if vco1_range>20
        vco1_range=6.0;
    end
    if vco1_range>2.5*vco1_volt
        vco1_range=vco1_volt;
    end
    %% If there are no box in the data range, set the parameters to some default value
%     if left1==2||right1==3.6
%          vco1_volt=8;
%          vco1_range=3;
%     end
    %%
    
    
    cyc=cyc+1;
    if cyc>40
        final_vco_range=7.3;
        final_vco_range=6.0;
        disp('... Tuning failed! Set VCO range=7.3 and volt=6.0 to be default value!');
        [yr, month, dy, hr, min, second] = datevec(now);
        mfilename=sprintf('%d-%02d-%02d_%02d.%02d.%02d',yr, month, dy, hr, min, round(second));
        fmatchwrong=fopen(['D:\QEG2\21-C\Instruments\Spike\Matching_log\Wrong_log_' mfilename '.txt'],'wt');
        fprintf(fmatchwrong,[mfilename '\n Cyc>25, Set Set VCO range=7.3 and volt=6.0\n']);
        fclose(fmatchwrong);
        break;
    end
      
    disp(['... Tuning VCO bandwidth, iteration ' num2str(cyc)]);
    
    err(cyc)=max(abs(1-abs(err_bw))*(bw_max-bw_min),abs(1-abs(err_mean))*(bw_max+bw_min)/2);
    pw1.PS_VoltSet(vco1_volt);
    pw1.PS_OUTOn;
    arb1.define_ramp(2e3,vco1_range,0,0);
    pause(0.2);
    arb1.MW_RFOn();
    pause(0.5);
    [data1,freq_vec,peak_val]=sweep_VCO(pw1,vco1_volt,1,bw_min,bw_max);
    pause(0.2);
    arb1.MW_RFOff();pw1.PS_OUTOff;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [left1,right1]=getsides2(freq_vec,data1);
    err_bw=(right1-left1)/(bw_max-bw_min);
    err_mean=(right1+left1)/(bw_max+bw_min);
    d1_right=abs((1-err_mean)*(bw_max+bw_min)/2+(1-err_bw)*(bw_max-bw_min)/2);
    d1_left=abs((1-err_mean)*(bw_max+bw_min)/2-(1-err_bw)*(bw_max-bw_min)/2);
end
disp(['The voltage range of current VCO:' num2str(vco1_range)]);
disp(['The voltage center of current VCO:' num2str(vco1_volt)]);

final_vco_range=vco1_range;
final_vco_volt=vco1_volt;

% %% Close
% LibraryName = 'sa_api';
% handle = uint32(0);
% [close] = calllib(LibraryName, 'saCloseDevice', handle);
arb1.MW_RFOff();pw1.PS_OUTOff;


end

function [data,freq_vec,peak_val]=sweep_VCO(pw,volt,fig_num,bw_min,bw_max)
%% Initialize spike
LibraryName = 'sa_api';
LibraryFilePath = 'sa_api.dll';
HeaderFilePath = 'sa_api.h';
%[start,stop]=Initialize(bw_min,bw_max);
 %start=1.7e9; stop=3.5e9;     %%If change value here, you also need to change value in initialize function
 
 %start=2.2e9; stop=3.8e9;     %%If change value here, you also need to change value in initialize function
 
 %start=1.8e9; stop=3.2e9; 

 %start=2.1e9; stop=3.3e9; 
 
 start=2.1e9; stop=3.5e9; 
 
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

%Configure sweep frequency range  (This should be the same as the data measure part in sweep_VCO function)
center = 2.6e9;
span = 1.8e9;
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

