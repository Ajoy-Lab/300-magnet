s = serial('com3');
set(s, 'Baudrate', 57600);
set(s, 'DataBits', 7);
set(s, 'Parity', 'odd');
%set(s, 'StartBits', 1);
set(s, 'StopBits', 1);
set(s, 'FlowControl', 'none');
fopen(s);
fprintf(s, 'RDGFIELD?');
val=fscanf(s)
fclose(s);
%set(s, 'Terminator', 'LF');