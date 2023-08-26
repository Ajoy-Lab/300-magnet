% Check open ports with Rigol scopes and close any if open
serialObj = instrfind;
s=size(serialObj);
for i=1:s(1,2)
    if strcmp(serialObj(i).Name,'VISA-USB-0-0x1AB1-0x0514-DS7A241600226-0')
        fclose(serialObj(i));
    end
end
for i=1:s(1,2)
    if strcmp(serialObj(i).Status,'closed')
        delete(serialObj(i));
    end
end

clear b1 SampRate yor data1 DS1000z 
DS1000z = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0514::DS7A241600226::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(DS1000z)
    DS1000z = visa('NI', 'USB0::0x1AB1::0x0514::DS7A241600226::INSTR');
else
    fclose(DS1000z);
    DS1000z = DS1000z(1);
end

%% Initial setup
% Set the device property. In this demo, the length of the input buffer is set to 2048. 
DS1000z.InputBufferSize = 20480;
% Connect to instrument object, obj1.
fopen(DS1000z);
% Set channel
fprintf(DS1000z, ':WAV:SOURce CHAN1' ); 
% Normal Mode
fprintf(DS1000z, ':WAV:MODE NORM' ); 
% Samplerate T?
fprintf(DS1000z, ':WAVeform:XINCrement?');
SampRate = str2num(fscanf(DS1000z));
% Query Yorigin
%fprintf(DS1000z, ':WAVeform:YOR?' ); a=fread(DS1000z);yor=str2num(char(a(1:end-1)'))
fprintf(DS1000z, ':WAVeform:YOR?' ); yor=num2str(fscanf(DS1000z));
% Set in Ascii mode
fprintf(DS1000z, ':wav:form asc' );
% set points to maximum
fprintf(DS1000z, ':wav:points max' );
% query number of points
fprintf(DS1000z, ':wav:points?' );
points=str2num(fscanf(DS1000z));
% set start and stop
fprintf(DS1000z, [':WAVeform:STOP ' num2str(points)]);
fprintf(DS1000z, ':WAVeform:STAR 1');
% Begin acquisition
fprintf(DS1000z, ':WAVeform:BEG' );
% Read the waveform data 
% fprintf(DS1000z, ':wav:data?' ); 
% Request the data 
%[data,len]= fread(DS1000z,2048); 
fprintf(DS1000z, ':WAVeform:DATA?' ); 

a=  fread(DS1000z);
b1=char(a(1:end-1))';
for j=1:points
    data1(j)=str2num(b1(12+12*(j-1)+2*(j-1): 24+12*(j-1) + 2*(j-1)));
end
timeaxis=SampRate*[1:points];
start_fig(100,[5 1]);
p1=plot_preliminaries(timeaxis*1e3,data1,2,'nomarker');
set(p1,'linewidth',0.5);
plot_labels('Time [ms]','Signal [V]');