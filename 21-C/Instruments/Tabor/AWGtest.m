% Created by Jean-Christophe Jaskula, MIT 2015
%%
tic
CHs={};
Transfer=1;
amp=0.1;
%% Resetting the AWG and preparing the transfer
prepareSE5082(Transfer, amp);

%% Setting general parameters of the segments
samprate=3.2e9; % at least 10 times faster than the highest frequency of the sequence, arbitrary
dt=1/samprate;
starttime=100e-9; % 100ns
bufferBeg=round(starttime/dt);
bufferEnd=round(10e-9/dt); % 100ns

%% Define the sweep parameters and table
Pio2PulsePhase = 0; 
percentage=10;
TotalSegNb=1;
iseg=0;
    
%% Creating all the XY8 blocks for different tau
iseg=iseg + 1;
if Transfer
    SE5082FunctionPool('setchn',2);
end

%% Preparing the sequence table
% Will be rounded when creating the segment because npoints-384 must be divisible by 32,
% parameter T: pulse length
% T=1e-6;
T=50e-7;
% T=50e-8;
% T=5e-4;
% T=5e-3;

npoints = bufferBeg + round(T/dt) + bufferEnd; % number of points
seg = ClassSE5082Segment(iseg, dt, npoints); % create a segment with size npoints

% set pulse params
start_freq=1e6; % initial frequency
stop_freq=99e6; % final frequency, use for chirp pulse
amp=0.1; % amplitude
phase=0; % phase shift
starttime=0;

% seg.addSinePulse(starttime, T, amp, start_freq, phase);
seg.addChirpPulse(starttime, T, amp, start_freq, stop_freq, phase);

figure(1);plot(seg.AWF,'-b') % plot the pulse sequence

%% Transfering the segment to the SE5082 or plot it in a figure

if Transfer
    seg.upload();
    
    s = warning('off','MATLAB:structOnObject');
    segstruct=struct(seg);
    CHs{seg.segNb}=segstruct; 
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

%% Finishing setting the AWG up
if Transfer
    SE5082FunctionPool('setchn',2);
    SE5082FunctionPool('setoutput','on');
end
toc


function prepareSE5082(Transfer, amp)
if Transfer
    fprintf('Preparing SE5082... ');
    SE5082FunctionPool('reset');
    SE5082FunctionPool('setchn',2);
    SE5082FunctionPool('eraseSeg','all');
    SE5082FunctionPool('setAmplitude',2*amp+.01);
    SE5082FunctionPool('setmode','user');
    SE5082FunctionPool('setTriggermode','cont'); % changed to continuous for testing purposes
%     SE5082FunctionPool('setsamplingmode', 'RTZ');
    SE5082FunctionPool('setmarkersource','user');
    fprintf('done.\n');
end
end