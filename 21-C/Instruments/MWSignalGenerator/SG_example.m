% Parameters
IPAddress='18.62.13.9';
TCPPort=5025;  
Timeout=30; %s 
InputBufferSize=1024;
OutputBufferSize=1024;    
    
% Set TCP/IP protocol
SG384 = tcpip(IPAddress,TCPPort);
set(SG384,'Timeout',Timeout);
set(SG384,'InputBufferSize',InputBufferSize);
set(SG384,'OutputBufferSize',OutputBufferSize);

% Control the SG384 
echotcpip('on',TCPPort);
fopen(SG384);
    % Control commands for SG384
fclose(SG384);
echotcpip('off');
% Once the connection has been closed once, the SG384 freezes.
% % The front panel is also frozen (buttons cannot be pushed).
% It usually takes about 2 minutes to reestablish the situation and allow
% Matlab to control the SG384 again.

% Deleting the protocol object does not solve the problem
delete(SG384);
clear SG384;
