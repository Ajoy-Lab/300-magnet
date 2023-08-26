


Pause_Time=5e-5; % seconds


 %addr='11831334';

 %addr='1183036B';

%Channel Boards Connected – Shows how many channels are physically present in the controller
%addr='118303A0';

%X-Axis which should be 100
% addr='11831078';

%Y-Axis which should be 100
% addr='11832078';

%Z-Axis which should be 20
% addr='11833078';

%range type
% addr='11831044';

%zero
% addr='11831218';

% addr='18128311'
% addr='11831334E8030000'
% addr='00026666';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%                                   %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%            X COORDINATE           %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%                                   %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%zero_X
address_X='11831218';

cmdstr_X=strcat('A0',address_X,'55');
cmdstr_X = cmdstr_X([1 2 9 10 7 8 5 6 3 4 11 12]);
l_X = length(cmdstr_X);
c_X = hex2dec(reshape(cmdstr_X,2,l_X/2)');
fwrite(s1,c_X);
pause(Pause_Time);
numBytes = s1.BytesAvailable;
ret_str_X = fread(s1,numBytes);
pause(Pause_Time);
[m_X,n_X] = size(address_X);
k_X = reshape(ret_str_X,10,m_X);
s_X = k_X(:,1);
s_X = dec2hex(s_X);
s_X = reshape(s_X',1,20);
s_X = s_X(11:18);
s_X=s_X([7 8 5 6 3 4 1 2]);
hex2dec(s_X)
%fclose(s1)
