%Created by Jean-Christophe Jaskula, MIT 2015

function [sweepTable, CHs]=AWGRabi_xy_compare(Data_AWGparam, Transfer)
tic

if nargin < 2
    Transfer = 1;
end

s=Data_AWGparam(:,3);
swept_index=find([s{:}]==1);


% swept_parameter==1 length_rabi_pulse
% swept_parameter==2 amplitude
% swept_parameter==3 ma_freq


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
         case 'tau'
            tau = Data_AWGparam{i,2};
         case 'n' %XY8-n
            n = Data_AWGparam{i,2};
    end
    
end

%sweepTable = Data_AWGparam{swept_index, 4}:Data_AWGparam{swept_index, 5}:Data_AWGparam{swept_index, 6};
%swept_parameter=find([pulse_param_index{:}]==swept_index);


if ~isempty(swept_index)
    sweepTable = Data_AWGparam{swept_index, 4}:Data_AWGparam{swept_index, 5}:Data_AWGparam{swept_index, 6};
    swept_parameter=find([pulse_param_index{:}]==swept_index);
else
    swept_index=pulse_param_index{3};
    swept_parameter=3;
    sweepTable = Data_AWGparam{swept_index, 2};
end

% Only if sweeping amplitude, you need to set the right conversion factor
if swept_parameter==2
    sweepTable =  sqrt(10.^(sweepTable./10)*.001*50); 
     ampl=max(sweepTable);
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
     pulse_param{swept_parameter} = sweepTable(ind);
    
    
    %% Preparing the sequence table
    % Will be rounded when creating the segment because npoints-192 must be divisible by 16,
   % npoints = bufferBeg + round(sweepTable(end)/dt) + bufferEnd;
    %npoints = bufferBeg + round(pulse_param{1}/dt) + bufferEnd;
     npoints = bufferBeg  + n*round(pulse_param{1}/dt) + n*round(2*tau/dt) + bufferEnd;
    seg = ClassWX1284CSegment(iseg, dt, npoints);
   
    %% First pulse about X
    startPulsetime = starttime;
    for n_ind=1:n
    seg.addSinePulse(startPulsetime, pulse_param{1}, pulse_param{2}, pulse_param{3}, Pio2PulsePhase);
    % syntax: seg.addSinePulse(starttime, length_pi_pulse, mw_ampl, RFfreq, Pio2PulsePhase);
    startPulsetime = startPulsetime + pulse_param{1} + tau;
    end
    %seg.addSinePulse(startPulsetime, pulse_param{1}, pulse_param{2}, pulse_param{3}, Pio2PulsePhase);
     
    
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
