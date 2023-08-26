
% open synthNV serial port

function [s] = openSynthNV(port)

s = serial(port,'baudrate',115200,'databits',8,'parity','none','stopbits',1,'flowcontrol','none');
fopen(s);

end
