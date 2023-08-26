function [nc,Tmax]=make_pw_nmr_10_2(pw,tacq,gain)

    %[fid, msg] = fopen(['Z:/vnmrsys/maclib/ga_save'], 'w');
    [fid, msg] = fopen(['\\192.168.10.4\vnmrsys\maclib\ga_save'], 'w');
    if fid == 1
        error(msg);
    end
    fprintf(fid, '%s \n');
     str = verbatim;
    %{
"macro for acquisition and subsequent saving of the FID"
"rewriting of command name (ga --> ga2, modified command as new ga)?"
    
seqfil = 'dressed_echo_vd'

$counter = counter
$counter_ct = counter_ct
$pslabel = pslabel
$date = '_'
shell('date +%Y-%m-%d_%H.%M.%OS; cat'):$date
$1 = $date+'_'+$pslabel

folder_name = '/home/vnmrsys/data'+ $1	
shell('mkdir '+ folder_name)


if (end_flag = 'y') then
	counter_ct = 1	
	end_flag = 'n'
endif

if ($counter_ct = $counter) then
	counter_ct = 1
	end_flag = 'y'
endif

%}
 sw=125e4;
%  sw=700000;
% neco=80;
dtacq=(1/sw)*1e6;
% tacq=32;
% tacq=32;
neco=tacq/dtacq;
acq_time=neco*dtacq;
np=2*262144;
% rof2_rem=mod(pw+acq_time+ddrtc,dtacq);
% rof2=dtacq*2 - rof2_rem;
rof1=2;
rof2=2;
rof3=3e-6;%17e-6; %34e-6;
tdead=rof1+rof2+4+rof3*1e6;
%nc=934;



% Tmax=350;
% Tmax=200;
% Tmax=1000;
%Tmax=3000/4;
%Tmax=5000/4;
%Tmax=1000/4;
%Tmax=50;
%Tmax=35000/192;
Tmax=5;
%pw2 = 85%32.5; %pw;%63; %30*9/2; %40*9/2; % 198; % 45; % 477; % pi is estimated to occur at pw = 106us
%pw2=32.5;
%  pw2=pw;
  pw2=85;
%   pw2=115;
%pw2=42;

%pw2=45;
% tof=17.46;
 tof=18.6;
% tof=17.6;
tof=19.0;
%tof=18.6;
%tof=17.46;
%tof=gain;

% pi/2 is estimated to occur at pw = 42us
%pw2 = 135*9/2;
 %Tmax=500;
nc_max=floor(Tmax*1e6/(neco*dtacq + pw2 + tdead));

loop_num = gain;

%tpwr = 54;
 tpwr = 44;
%tpwr=48;
% pw=30;
nc=nc_max;
% nc=12200;
nc=12000+loop_num;

% nc=1694;



fprintf(fid,'%s \n',str);
fprintf(fid,'%s \n',['tpwr =' num2str(tpwr)]);
fprintf(fid,'%s \n',['pw2 =' num2str(pw2)]);
fprintf(fid,'%s \n',['pw =' num2str(pw)]);
fprintf(fid,'%s \n',['nc =' num2str(nc)]);
fprintf(fid,'%s \n',['sw =' num2str(sw)]);
% fprintf(fid,'%s \n',['at =' num2str(at)]);
fprintf(fid,'%s \n',['neco =' num2str(neco)]);
% fprintf(fid,'%s \n',['gain =' num2str(gain)]);
fprintf(fid,'%s \n',['gain =' num2str(24)]);
fprintf(fid,'%s \n',['rof1 =' num2str(rof1)]);
fprintf(fid,'%s \n',['rof2 =' num2str(rof2)]);
fprintf(fid,'%s \n',['rof3 =' num2str(rof3)]);
fprintf(fid,'%s \n',['tof =' num2str(-tof*1000)]);
fprintf(fid,'%s \n',['loopnum =' num2str(loop_num)]);
%fprintf(fid,'%s \n',['tof =' num2str(-tof)]);
         
   str = verbatim;
    %{
au
wexp('ga_loop')
%}
   fprintf(fid,'%s \n',str);
    
   fclose(fid);
   
end