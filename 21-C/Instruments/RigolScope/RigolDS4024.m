DS1000z = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0514::DS7A241600226::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(DS1000z)
    DS1000z = visa('NI', 'USB0::0x1AB1::0x0514::DS7A241600226::INSTR');
else
    fclose(DS1000z);
    DS1000z = DS1000z(1);
end

% Set the device property. In this demo, the length of the input buffer is set to 2048. 
DS1000z.InputBufferSize = 2048;
% Connect to instrument object, obj1.
fopen(DS1000z);
% Set channel
fprintf(DS1000z, ':WAV:SOURce CHAN1' ); 
% Normal Mode
fprintf(DS1000z, ':WAV:MODE NORM' ); 
% Samplerate T?
fprintf(DS1000z, ':WAVeform:XINCrement?');
SampRate = fscanf(DS1000z);
% Read the waveform data 
fprintf(DS1000z, ':wav:data?' ); 
% Request the data 
[data,len]= fread(DS1000z,2048); 