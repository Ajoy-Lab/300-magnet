%Created by Jean-Christophe Jaskula, MIT 2015

function [sweepTable, CHs]=AWG_supersampling(Data_AWGparam, Transfer)
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
            n = Data_AWGparam{i,2};
        case 'p'
            p = Data_AWGparam{i,2};
        case 'q'
            q = Data_AWGparam{i,2};
        case 'p1'
            p1 = Data_AWGparam{i,2};
        case 'q1'
            q1 = Data_AWGparam{i,2};
        case 'm1'
            m1 = Data_AWGparam{i,2};
        case 'p2'
            p2 = Data_AWGparam{i,2};
        case 'q2'
            q2 = Data_AWGparam{i,2};
    end
    
end

sweepTable = Data_AWGparam{swept_index, 4}:Data_AWGparam{swept_index, 5}:Data_AWGparam{swept_index, 6};
swept_parameter=find([pulse_param_index{:}]==swept_index);
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


    
%% Creating all the XY8 blocks for different tau
for ind=1:length(sweepTable)
    iseg=iseg+1;
    
    if Transfer
        WX1284CFunctionPool('setchn',2);
    end
    
     
    %% Make the swept variable
    pulse_param{swept_parameter} = sweepTable(ind);%%defining the amplitude as the largest amplitude if power is being swept
    
    tau=pulse_param{5};
    
    %% Setting up sequence construction
    
    U0=[tau,2*(tau),tau];
    %U1=[tau+2e-9,2*(tau+2e-9),tau+2e-9];
    U1=[tau+1e-9,2*(tau+1e-9),tau+1e-9];
    delay={};
    count=0;
    for j=1:m1
        for j1=1:p1
            count=count+1;
            delay{count}=U0;
        end
        for j1=1:q1
            count=count+1;
            delay{count}=U1;
        end
    end
    for j=1:p2
        count=count+1;
        delay{count}=U0;
    end
    for j=1:q2
        count=count+1;
        delay{count}=U1;
    end
    
    delay2=repmat(delay,1,4*n/(p+q));%% k is XY8-k
    clear delay;
    delay=delay2;
    
    %Pattern = [0,1,0,1,1,0,1,0]*pi/2;
    %Pattern = rapmat(Pattern,1,n);
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
     startPulsetime = startPulsetime + 0.5*pulse_param{1};
  
    %% Creating sequence
    for j=1:size(delay,2)
        if mod(j,4)==1||mod(j,4)==2
            startPulsetime = startPulsetime + delay{j}(1,1);
            seg.addSinePulse(startPulsetime, pulse_param{1}, pulse_param{2}, pulse_param{3},0);
            startPulsetime = startPulsetime + pulse_param{1} + delay{j}(1,2);
            seg.addSinePulse(startPulsetime, pulse_param{1}, pulse_param{2}, pulse_param{3},pi/2);
            startPulsetime = startPulsetime + pulse_param{1} + delay{j}(1,3);
        else
            startPulsetime = startPulsetime + delay{j}(1,1);
            seg.addSinePulse(startPulsetime, pulse_param{1}, pulse_param{2}, pulse_param{3},pi/2);
            startPulsetime = startPulsetime + pulse_param{1} + delay{j}(1,2);
            seg.addSinePulse(startPulsetime, pulse_param{1}, pulse_param{2}, pulse_param{3},0);
            startPulsetime = startPulsetime + pulse_param{1} + delay{j}(1,3);
        end
    end
    
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
    
    WX1284CFunctionPool('setmarkersource','user');
    fprintf('done.\n');
end
