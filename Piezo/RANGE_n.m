

function RANGE_n(n,Piezo_Range_n,Pause_Time)

% Range  = 078

% n gives the axis 
% query and return position of axis 
%  x  axis in case n=1, 
%  y  axis in case n=2, 
%  z  axis  in case n=3

address_Range_n=strcat('1183',num2str(n),'078');

cmdstr_Range_n=strcat('A0',address_Range_n,'55');
cmdstr_Range_n = cmdstr_Range_n([1 2 9 10 7 8 5 6 3 4 11 12]);
l_Range_n = length(cmdstr_Range_n);
c_Range_n = hex2dec(reshape(cmdstr_Range_n,2,l_Range_n/2)');
fwrite(Piezo_Range_n,c_Range_n);
pause(Pause_Time);
numBytes = Piezo_Range_n.BytesAvailable;
ret_str_n = fread(Piezo_Range_n,numBytes);
pause(Pause_Time);
[m_range_n,n_n] = size(address_Range_n);
k_n = reshape(ret_str_n,10,m_range_n);
s_n = k_n(:,1);
s_n = dec2hex(s_n);
s_n = reshape(s_n',1,20);
s_n = s_n(11:18);
s_n=s_n([7 8 5 6 3 4 1 2]);
hex2dec(s_n)