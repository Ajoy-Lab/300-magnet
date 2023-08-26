%Created by Jean-Christophe Jaskula, MIT 2015

function [sweepTable, CHs]=transferXY8n_WX1284C(Data_AWGparam, Transfer)
tic

if nargin < 2
    Transfer = 1;
end

for i=1:length(Data_AWGparam(:,1))
    switch Data_AWGparam{i, 1}
        case 'mw_freq'
            RFfreq = Data_AWGparam{i,2};
        case 'length_pi2'
            Pio2Pulse=Data_AWGparam{i,2};
        case 'length_pi'
            PiPulse=Data_AWGparam{i,2};
        case 'mw_ampl'
            ampl = sqrt(10^(Data_AWGparam{i,2}/10)*.001*50); %Volts for a sine wave
        case 'tau'
            sweepTable = Data_AWGparam{i, 4}:Data_AWGparam{i, 5}:Data_AWGparam{i, 6};
        case 'n'
            n=Data_AWGparam{i,2};
    end
end

%%
CHs={};

%% Resetting the AWG and preparing the transfer
prepareWX1284C(Transfer, ampl)


%% Setting general parameters of the segments
samprate=1e9; % at least 10 times faster than the highest frequency of the sequence, arbitrary
dt=1/samprate;
starttime=20e-9; % 100ns
bufferBeg=round(starttime/dt);
bufferEnd=round(20e-9/dt); % 100ns


%% Define the sweep parameters and table

Pattern = [1 0 1 0 0 1 0 1]*pi/2; %XY8
NbPulses=length(Pattern);

Pio2PulsePhase = 0; 

percentage=10;
TotalSegNb=length(sweepTable);

iseg=0;

%% Creating all the XY8 blocks for different tau
for tau=sweepTable
    iseg=iseg+1;
    
    if Transfer
        WX1284CFunctionPool('setchn',2);
    end
    
    %% Preparing the sequence table
    % Will be rounded when creating the segment because npoints-192 must be divisible by 16,
    npoints = bufferBeg + 2*round(Pio2Pulse/dt) + n*(NbPulses*round(PiPulse/dt) + (NbPulses+1)*round(2*tau/dt)) + bufferEnd;
    seg = ClassWX1284CSegment(iseg, dt, npoints);
    
    %% First pi/2 pulse about X
    startPulsetime = starttime;
    seg.addSinePulse(startPulsetime, Pio2Pulse, ampl, RFfreq, Pio2PulsePhase);
    
    startPulsetime = startPulsetime + Pio2Pulse + tau;
    %% Creating Microwave pi pulse train
    for j=0:n-1
        for i=0:NbPulses-1
            seg.addSinePulse(startPulsetime , PiPulse, ampl, RFfreq, Pattern(i+1));
            startPulsetime = startPulsetime + PiPulse + 2*tau;
        end
    end
    
    %% Last pi/2 pulse about X
    seg.addSinePulse(startPulsetime - tau, Pio2Pulse, ampl, RFfreq, Pio2PulsePhase);

    
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
    
    % To use the marker (digital output sync with CH1,2 and resolution twice worse)
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
