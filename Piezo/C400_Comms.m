%This code is a snippet from inside a GUIDE program.  I have the comm port
%attached to the global var called 'handles' like this.  The comm port
%number is a text box that the user enters.

    n = get(handles.txt_COMM_port,'String');
    s = ['COM' n];
    handles.s_port = serial(s);    
    st = get(handles.s_port,'Status');
    % cannot open a port a second time
    if(st(1) == 'o')
        fclose(handles.s_port);
    end
    handles.s_port.BaudRate = 115200;
    handles.s_port.InputBufferSize = 4096;
    fopen(handles.s_port);

%Then the following two functions take care of all the lower level comms
%with the controller.  They are vectorized functions so you can send either
%a single register or an array of registers.  Since the actual byte stream
%does not contain any data type information, it gets handled in the comms
%functions.  The 'type' parameter is a character string that indicates the
%data type.


function str = readDspAddr(addr,type,handles)
% reads a list of addresses and converts to either
% integer or floats
[m,n] = size(addr);
for j=1:m
    cmdstr = ['A0' addr(j,:) '55'];
    cmdstr = cmdstr([1 2 9 10 7 8 5 6 3 4 11 12]);
    l = length(cmdstr);
    c = hex2dec(reshape(cmdstr,2,l/2)');
    fwrite(handles.s_port,c);
    pause(0.08);
end
numBytes = handles.s_port.BytesAvailable;
ret_str = fread(handles.s_port,numBytes);
k = reshape(ret_str,10,m);
% -- reorder the bytes --
k = k([1 5 4 3 2 9 8 7 6 10],:);
for j = 1:m
    s = k(:,j);
    s = dec2hex(s);
    s = reshape(s',1,20);
    s = s(11:18);
    if (type(j) == 'f')       % float
        str(j) = my_hex2num32(s);
    elseif (type(j) == 'i')   % int
        str(j) = hex2dec(s);
        if (str(j) > 2^31)
            str(j) = -(2^32 - str(j));
        end
    elseif (type(j) == 'u') % unsigned int
        str(j) = hex2dec(s);
    end        
end



function writeDspAddr(addr,values,type,handles)
% write to a DSP address
v2 = [];
[m,n] = size(addr);
for j = 1:m
    if (type(j) == 'f')     % float
        v = my_num2hex32(values(j));
    elseif (type(j) == 'h') % hex
        v = values(j,:);
    elseif (type(j) == 'i') % signed int
        v = values(j);
        if v < 0
            v = (2^32 + v);
        end
        v = dec2hex(v,8);
    end
    cmdstr = ['A2' addr(j,:) v '55'];
    % -- reorder the bytes -- 
    cmdstr = cmdstr([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
    L = length(cmdstr);
    c = hex2dec(reshape(cmdstr,2,L/2)');
    fwrite(handles.s_port,c);    
    pause(0.01);
end


Examples:
---Read a single register (length of the step response)

addr_stepLength  = '1183036C';
len = readDspAddr(addr_stepLength,'i',handles);



---Read an array of values (channel 2 range and channel 2 enable status)
then populate GUI controls with the results.

addr = ['11832078';'11832080'];
RE = readDspAddr(addr,'ii',handles);
set(handles.txt_Range2,'String',RE(1));
set(handles.chk_Enabled2,'Value',RE(2));



---Read an array with mixed data types (channel 1 calibration data)
This is the analog input scale factor (32bit float) and offset (integer)
then the digital scale factor (float) and offset (integer) and then the
monitor scale factor (float) and offset (integer).

addr = ['11831224';'11831228';'1183122C';'11831234';'11831238';'1183123C'];
LinMon_OS = readDspAddr(addr,'fififi',handles);


% 
% ---Write a single register (execute the step response command)
% writeDspAddr('11829008',1,'i',handles);



% ---Write an array of registers (wavetable data for selected channel) 
% This uses the Write command to send the first value and then the WriteNext
% command top send the rest of them.  Its faster bcauset the address will 
% auto-increment with each value.  The data is a list of values held in
% the array 'handles.Wave' and has already been scaled by the digital scale
% factor.

addr_buffer = ['C0000000';'C0054000';'C00A8000';'C00FC000';'C0150000';'C01A4000']; % WaveBuffer1,2,3,4,5,6
ch = handles.channel;

writeDspAddr(addr_buffer(ch,:),round(handles.auxWave(1)),'i',handles);
for i = 2:numPoints
    val = round(handles.Wave(i));
    if val<0
        val = (2^32 + val); % because matlab cant convert neg numbers to hex
    end
    val = dec2hex(val,8);
    % -- reorder the bytes --
    val = val([7 8 5 6 3 4 1 2]);
    cmd_str = ['A3' val '55'];
    L = length(cmd_str);
    c = hex2dec(reshape(cmd_str,2,L/2)');
    fwrite(handles.s_port,c);
end

---------------------------------------------------------------------------

There are some helper functions in the above code to convert to the IEEE.754
32 bit floating point format.  The bin2dec, dec2bin and num2hex are built-in
Matlab functions, the others are listed here...

function y = my_hex2num32(x)
% x: 32bit hex string
% y: floating point value

% unpack the bits
b = hex2bin(x);
s = b(1);
e = b(2:9);
f = b(10:32);

if (e == '00000000')
    y = 0;
else
    ex = bin2dec(e) - 127;
    f = ['1' f];
    y = (-1)^s * 2^(ex) * bin2dec(f)/2^23;
end


function y = my_num2hex32(x)
% float to 32bit hex

% easier to convert to the 64bit version then back to the 32bit version
% rather than construct the whole thing from scratch.
b = num2hex(x);
b = hex2bin(b);

s = b(1);
e = b(2:12);
f = b(13:64);

if (x == 0)
    s = '0';
    e2 = '00000000';
    f2 = '00000000000000000000000';
else
    % denormalize the exponent
    e2 = bin2dec(e) - 1023;
    % the new exponent
    e2 = e2 + 127;
    e2 = dec2bin(e2);
    while(length(e2)<8)
        e2 = ['0' e2];
    end
    % truncate the fraction 
    f2 = f(1:23);
end
% all back together
y = [s e2 f2];
y = bin2hex(y);


function y = hex2bin(x)
% y = hex2bin(x)
% convert hex to binary (both strings)
[n,m] = size(x);
z = kron(ones(n,1),'0');
z = char(z);
for i=1:m
    d = dec2bin(hex2dec(x(:,i)),4);
    y(:,i*4-3:i*4) = d;
end

