function [final_vco_range,final_vco_volt]=Rampgen_matching_func(ramp, Ramp_No,bw_min,bw_max,A,B)
% vco1_volt=((bw_min+bw_max)/2-A)/B;
% Vpp=((-bw_min+bw_max)/2-A)/B;
% Vdc=vco1_volt;


%  Vpp=3;Vdc=8;
%  Vpp=3;Vdc=7;
 Vpp=3;Vdc=10;
%  Vpp=1;Vdc=4.5;
RampOffset=Vdc-Vpp/2;

vco1_volt=Vdc;
vco1_range=Vpp;

%% Set up target deviation  
deviation=0.002;                   

%% feedback loop for VCO1
cyc=0;
ramp.Set_RampVppVdc(Ramp_No, Vpp, Vdc);
pause(0.1);
ramp.Set_RampFreq(2e3);
ramp.Set_RampSymm(0);

%[data1,freq_vec,peak_val]=sweep_VCO(pw1,vco1_volt,1,bw_min,bw_max);
[data1,freq_vec]=sweep_VCO(ramp, Ramp_No,RampOffset,1,bw_min,bw_max);
pause(0.2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[left1,right1]=getsides2(freq_vec,data1);
err_bw=(right1-left1)/(bw_max-bw_min);
err_mean=(right1+left1)/(bw_max+bw_min);
err_mean1=(bw_max+bw_min)/2-(right1+left1)/2;
%err_dc=(right1+left1-(bw_max+bw_min))/(2.6642*10^8);
d1_right=abs((1-err_mean)*(bw_max+bw_min)/2+(1-err_bw)*(bw_max-bw_min)/2);
d1_left=abs((1-err_mean)*(bw_max+bw_min)/2-(1-err_bw)*(bw_max-bw_min)/2);
%while max(abs(1-abs(err_bw))*(bw_max-bw_min),abs(1-abs(err_mean))*(bw_max+bw_min)/2)>=deviation
slope_B=((right1+left1)/2-1.7)/vco1_volt;
while max(d1_left,d1_right)>deviation
    vco1_range=vco1_range/err_bw;
    %vco1_volt=vco1_volt/err_mean;
    vco1_volt=vco1_volt+err_mean1/slope_B;
    
    if vco1_volt<0.1||vco1_volt>20
        vco1_volt=7.3;
    end

    if vco1_range>20
        vco1_range=20;
    end
%     if vco1_range>2.5*vco1_volt
%         vco1_range=vco1_volt;
%     end
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

    ramp.Set_RampVppVdc(Ramp_No, vco1_range,vco1_volt);
    pause(0.2);
    
    [data1,freq_vec]=sweep_VCO(ramp, Ramp_No,RampOffset,1,bw_min,bw_max);
    pause(0.2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [left1,right1]=getsides2(freq_vec,data1);
    err_bw=(right1-left1)/(bw_max-bw_min);
    err_mean=(right1+left1)/(bw_max+bw_min);
    err_mean1=(bw_max+bw_min)/2-(right1+left1)/2;
    slope_B=((right1+left1)/2-1.7)/vco1_volt;
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
% arb1.MW_RFOff();pw1.PS_OUTOff;


end

function [data,freq_vec]=sweep_VCO(ramp, Ramp_No, RampOffset,fig_num,bw_min,bw_max)
%% Initialize spike
LibraryName = 'sa_api';
LibraryFilePath = 'sa_api.dll';
HeaderFilePath = 'sa_api.h';
% %[start,stop]=Initialize(bw_min,bw_max);
%  start=1.7e9; stop=3.5e9;     %%If change value here, you also need to change value in initialize function
 
%  start=2.2e9; stop=3.8e9;     %%If change value here, you also need to change value in initialize function
 
% start=1.8e9; stop=3.2e9; 

 %start=2.1e9; stop=3.3e9; 
 
%  start=2.1e9; stop=3.5e9; 
 
%  start=1.8e9; stop=3.6e9; 
%  
%  start=2.1e9; stop=3.5e9; 
 
%    start=2.4e9; stop=3.8e9; 
  
      start=2.6e9; stop=4e9; 
      
%       start=3e9; stop=4.4e9; 

%  start=2e9; stop=3.6e9; 

%-1 manifold
%  start=1.7e9; stop=3.6e9; 
 
%% Sweep and get peak
start_fig(fig_num,[4 1]);

%pw.PS_VoltSet(volt(j));
%ramp.Set_RampOffset( Ramp_No, RampOffset)
%disp(['Getting sweep for ' num2str(volt(j)) ' V']);
[data,sweeplen] = GetSweep();
freq_vec=linspace(start,stop,sweeplen.Value);
[maxval,IX]=max(data);

plot_preliminaries(freq_vec,data,1,'nomarker');hold on;

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
