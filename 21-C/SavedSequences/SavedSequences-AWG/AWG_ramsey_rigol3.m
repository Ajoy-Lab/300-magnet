%Created by Jean-Christophe Jaskula, MIT 2015

function [sweepTable, CHs]=AWG_ramsey_rigol(Data_AWGparam, Transfer)
tic

if nargin < 2
    Transfer = 1;
end

s=Data_AWGparam(:,3);
swept_index=find([s{:}]==1);



% pulse_param{1}= length_rabi_pulse
% pulse_param{2}= amplitude
% pulse_param{3}= mw_freq
% pulse_param{4}= phase
% pulse_param{5}= tau
% pulse_param{6}=power_pi2_pulse
% pulse_param{7}= l
% pulse_param{8} =n
%pulse_param{9]=sample %%a fraction between 0 and 1 indicating the sample
%position

for i=1:length(Data_AWGparam(:,1))
    switch Data_AWGparam{i, 1}
        case 'mw_freq'
            pulse_param{3} = Data_AWGparam{i,2};
            pulse_param_index{3} = i;
        case 'mw_ampl'
            pulse_param{2} = sqrt(10^(Data_AWGparam{i,2}/10)*.001*50); %Volts for a sine wave
            pulse_param_index{2}=i;
            ampl= pulse_param{2};
        case 'length_rabi_pulse'
            %sweepTable = Data_AWGparam{i, 4}:Data_AWGparam{i, 5}:Data_AWGparam{i, 6};
            pulse_param{1}= Data_AWGparam{i, 2};
            pulse_param_index{1}=i;
        case 'power_pi2_pulse'
            %sweepTable = Data_AWGparam{i, 4}:Data_AWGparam{i, 5}:Data_AWGparam{i, 6};
            pulse_param{6}=  sqrt(10^(Data_AWGparam{i,2}/10)*.001*50); %Volts for a sine wave
            pulse_param_index{6}=i;
        case 'tau'
            pulse_param{5}= Data_AWGparam{i,2};
           % tau=pulse_param{5};
            pulse_param_index{5}=i;
        case 'phase'
            pulse_param{4}= pi/180*Data_AWGparam{i, 2};
            pulse_param_index{4}=i;
        case 'n' %XY8-n
            pulse_param{8}=Data_AWGparam{i,2};
            pulse_param_index{8}=i;
           
        case 'l_sweep' %linear sampling param in time unit
            pulse_param{7}=Data_AWGparam{i,2};
            pulse_param_index{7}=i;
            l_sweep=pulse_param{7};
        case 'sample' % a fraction between 0 and 1 
            pulse_param{9}=Data_AWGparam{i,2};
            pulse_param_index{9}=i; 
           
    end
    
end

if ~isempty(swept_index)
    sweepTable = Data_AWGparam{swept_index, 4}:Data_AWGparam{swept_index, 5}:Data_AWGparam{swept_index, 6};
    swept_parameter=find([pulse_param_index{:}]==swept_index);
else
    swept_index=pulse_param_index{3};
    swept_parameter=swept_index;
    sweepTable = Data_AWGparam{swept_index, 2};
end


% Only if sweeping amplitude, you need to set the right conversion factor
if swept_parameter==2 ||  swept_parameter==6
    sweepTable =  sqrt(10.^(sweepTable./10)*.001*50); 
     ampl=max(sweepTable);
elseif swept_parameter==4
    sweepTable = pi/180.*sweepTable;
end

%%
CHs={};

%         JCJ 20150923
% paramlist{1,1}=tau
% paramlist{2}= pi_length

%% Resetting the AWG and preparing the transfer
prepareWX1284C(Transfer, ampl);


%% Setting general parameters of the segments
samprate=1e9; % at least 10 times faster than the highest frequency of the sequence, arbitrary
dt=1/samprate;
starttime=20e-9; % 100ns
bufferBeg=round(starttime/dt);
bufferEnd=round(20e-9/dt); % 100ns


%% Define the sweep parameters and table

Pio2PulsePhase = 0; 

percentage=10;
TotalSegNb=length(sweepTable)+1;

iseg=0;



%% Creating all the XY8 blocks for different l
for ind=1:length(sweepTable)
    iseg=iseg+1;
    
    if Transfer
        WX1284CFunctionPool('setchn',2);
    end
    
     
    %% Make the swept variable
    pulse_param{swept_parameter} = sweepTable(ind);%%defining the amplitude as the largest amplitude if power is being swept
    
    tau=pulse_param{5} + 1e-9*floor(pulse_param{7}/1e-9);
 
    
    n=pulse_param{8};
    n=floor(n);
    sample = pulse_param{9};
    %% Setting up sequence construction
    
    U0=[tau,2*(tau),tau];
    U1=[tau+1e-9,2*(tau+1e-9),tau+1e-9];
    delay={};
    count=0;
    %% Creat the optimal construction
    m = 0;
    min_interval = 1/(4*n);
    

    sample2=round2(sample,min_interval);
   for j=1:4*n
        m = m + sample2; % sample is a fraction like 5/16
        if abs(m)<=1/2
            count = count +1;
            delay{count} = U0;
        else
            count = count+1;
            delay{count} = U1;
            m = m-1;
        end
    end
    

    

    %% Preparing the sequence table
    % Will be rounded when creating the segment because npoints-192 must be divisible by 16,
    % npoints = bufferBeg + round(sweepTable(end)/dt) + bufferEnd;
    %npoints = bufferBeg + round(pulse_param{1}/dt) + bufferEnd;
    npoints = bufferBeg  +(10*n)*round(pulse_param{1}/dt) + (20*n)*round(pulse_param{5}/dt) + bufferEnd;
    %npoints=round2(npoints-192,16)+192;
    seg = ClassWX1284CSegment(iseg, dt, npoints);
    
    
   
    %% First pi/2 pulse about X
    startPulsetime = starttime;
    seg.addSinePulse(startPulsetime, 0.5*pulse_param{1}, pulse_param{6}, pulse_param{3}, 0);
    startPulsetime = startPulsetime + 0.5*pulse_param{1}+ tau;
    
    %
    
    %% Last pi/2 pulse about -X
    seg.addSinePulse(startPulsetime, 0.5*pulse_param{1}, pulse_param{6}, pulse_param{3},pi);
    
     
    
    %% Transfering the segment to the WX1284C or plot it in a figure
    if Transfer
        seg.upload();
        
        s = warning('off','MATLAB:structOnObject');
        segstruct=struct(seg);
        CHs{seg.segNb}=segstruct; %#ok<AGROW>
        warning(s);
    else
        seg.plot(iseg);
    end
    
    if iseg*100/TotalSegNb >= percentage
        telapsed = toc;
        disp([num2str(iseg) '/' num2str(TotalSegNb) ' = ' ...
            num2str(iseg*100/TotalSegNb) '% (' num2str(telapsed) ' s)']);
        percentage=percentage+10;
    end
end

%% Finishing setting the AWG up
if Transfer
    WX1284CFunctionPool('setchn',2);
    
    WX1284CFunctionPool('setoutput','on');
    %     if i == 2
    %         WX1284CFunctionPool('setmarker',1);
    %         WX1284CFunctionPool('setmarkeroutput','on');
    %     end
end

toc

function prepareWX1284C(Transfer, amp)
if Transfer
    fprintf('Preparing WX1284C... ');
    WX1284CFunctionPool('reset');
    WX1284CFunctionPool('setTransferMode','single');
    
    WX1284CFunctionPool('setchn',2);
    WX1284CFunctionPool('eraseSeg','all');
    WX1284CFunctionPool('setAmplitude',2*amp+.01);
    WX1284CFunctionPool('setmode','user');
    
    WX1284CFunctionPool('setTriggermode','triggered');
    WX1284CFunctionPool('settimingmode', 'coherent'); % Switch to coherent mode to avoid transients
    
    WX1284CFunctionPool('setmarkersource','user');
    fprintf('done.\n');
end
