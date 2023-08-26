
function INTEGRAL_GAIN_n(n,Piezo,pause_Time)
%Pause_Time=5e-4; % seconds

% zero=218
%
% n gives the axis 
% query and return position of axis 
%  x  axis in case n=1, 
%  y  axis in case n=2, 
%  z  axis  in case n=3

address_n=strcat('1183',num2str(n),'728');
cmdstr_n=strcat('A0',address_n,'55');
cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 11 12]);
l_n = length(cmdstr_n);
c_n = hex2dec(reshape(cmdstr_n,2,l_n/2)');
fwrite(Piezo,c_n);

pause(pause_Time);
numBytes = Piezo.BytesAvailable;
ret_str_n = fread(Piezo,numBytes);
pause(pause_Time);

[m_n,n_n] = size(address_n);
k_n = reshape(ret_str_n,10,m_n);
s_n = k_n(:,1);
s_n = dec2hex(s_n);
s_n = reshape(s_n',1,20);
s_n = s_n(11:18);
s_n=s_n([7 8 5 6 3 4 1 2]);
hex2dec(s_n)