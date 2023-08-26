
function RANGE_TYPE_n(n,Piezo_n,Pause_Time)
%Pause_Time=5e-4; % seconds


% Range type =044
%
% n gives the axis 
% query and return position of axis 
%  x  axis in case n=1, 
%  y  axis in case n=2, 
%  z  axis  in case n=3

address_RangeType_n=strcat('1183',num2str(n),'044');

cmdstr_RangeType_n=strcat('A0',address_RangeType_n,'55');
cmdstr_RangeType_n = cmdstr_RangeType_n([1 2 9 10 7 8 5 6 3 4 11 12]);
l_RangeType_n = length(cmdstr_RangeType_n);
c_RangeType_n = hex2dec(reshape(cmdstr_RangeType_n,2,l_RangeType_n/2)');
fwrite(Piezo_n,c_RangeType_n);
pause(Pause_Time);
numBytes = Piezo_n.BytesAvailable;
ret_str_RangeType_n = fread(Piezo_n,numBytes);
pause(Pause_Time);
[m_RangeType_n,n_RangeType_n] = size(address_RangeType_n);
k_RangeType_n = reshape(ret_str_RangeType_n,10,m_RangeType_n);
s_RangeType_n = k_RangeType_n(:,1);
s_RangeType_n = dec2hex(s_RangeType_n);
s_RangeType_n = reshape(s_RangeType_n',1,20);
s_RangeType_n = s_RangeType_n(11:18);
s_RangeType_n=s_RangeType_n([7 8 5 6 3 4 1 2]);
hex2dec(s_RangeType_n)
