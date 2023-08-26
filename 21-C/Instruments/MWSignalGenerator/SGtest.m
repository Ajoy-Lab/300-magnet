%IPAddress='18.62.13.25'; %A device name with static IPAddress provided by RLE 
IPAddress='18.62.31.28'; %A device name with static IPAddress provided by RLE 
TCPPort=5025;  
Timeout=30; %s 
InputBufferSize=1024;
OutputBufferSize=1024;    
    
% Initialize Signal Generator Object
sg = SG386(IPAddress,TCPPort,Timeout,InputBufferSize,OutputBufferSize);

% Set TCP/IP protocol
SG386 = tcpip(IPAddress,TCPPort);
set(SG386,'Timeout',Timeout);
set(SG386,'InputBufferSize',InputBufferSize);
set(SG386,'OutputBufferSize',OutputBufferSize);

%fopen(SG384);
%fclose(SG384);
sg.open();
sg.reset;
sg.Amplitude=0; %dBm
sg.Frequency=12e6; %Hz
sg.SetAll();
pause(0.1);

%sg.writeToSocket('*rst\n');
%sg.writeToSocket('*idn?\n')
%sg.writeReadToSocket('*opc?\n')
%sg.reset();
sg.close();
delete(sg.SocketHandle);
clear sg.SocketHandle;
delete(sg);
clear sg;
clear SG384;