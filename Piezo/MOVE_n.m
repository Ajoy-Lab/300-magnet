
function MOVE_n(Move_n,n,Piezo_n,Pause_Time)
%Pause_Time=1e-5; % seconds

%Move_X=100 % micron  - Range X [0-100] Microns


%err = calllib(obj.LibraryName,'MCL_SingleWriteN',Pos,Axis,obj.ID);

%addr='11831334'
% zero=218
%
% n gives the axis 
% query and return position of axis 
%  x  axis in case n=1, 
%  y  axis in case n=2, 
%  z  axis  in case n=3

address_n=strcat('1183',num2str(n),'218')

Write_n=num2str(dec2hex(Move_n,8))
%addr=26666

cmdstr_n=strcat('A2',address_n,Write_n,'55')% -- reorder the bytes -- 
cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20])
L_n = length(cmdstr_n)
c_n = hex2dec(reshape(cmdstr_n,2,L_n/2)')
fwrite(Piezo_n,c_n)
pause(Pause_Time);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
