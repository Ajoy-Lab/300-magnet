function [nc,Tmax]=make_pw_nmr_8(pw,tacq,gain)

    %[fid, msg] = fopen(['Z:/vnmrsys/maclib/ga_save'], 'w');
    [fid, msg] = fopen(['\\192.168.1.5\vnmrsys\maclib\ga_save'], 'w');
    % [fid, msg] = fopen(['C:\300 magnet\ga_save'], 'w');
    if fid == 1
        error(msg);
    end
    fprintf(fid, '%s \n');
     str = verbatim;
    %{
"macro for acquisition and subsequent saving of the FID"
"rewriting of command name (ga --> ga2, modified command as new ga)?"
    
seqfil = 'WAHUHA'
seqfil = 'pulsed_spinlock_pitrain_KAH'

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
% tpwr=tacq;
%  sw=700000;
% neco=80;
dtacq=(1/sw)*1e6;
% tacq=32;
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

delay_tau = (1.1^pw)*163 - 163;
tdead=rof1+rof2+4+rof3*1e6+delay_tau;
pw = delay_tau;



%nc=934;
%neco=40000; % undo this later!!


% Tmax=350;
% Tmax=200;
% Tmax=1000;
%Tmax=3000/4;
%Tmax=5000/4;
%Tmax=1000/4;
%Tmax=50;
%Tmax=35000/192;
%Tmax = 1;
%Tmax =30;


%Tmax=10;
% Tmax = 60;
%Tmax=30;
%Tmax=5;
%pw2 = 85%32.5; %pw;%63; %30*9/2; %40*9/2; % 198; % 45; % 477; % pi is estimated to occur at pw = 106us
%pw2=32.5;

  Tmax = 20;
%   Tmax = 40;
%   Tmax = 58;
%   Tmax = 60;
% Tmax = 1;
% Tmax = 10;

  % % % pw2=pw;
%pw2=85;
pw2=122.5/2;
pw2=23;
pw2=65;
pw2=85;
pw2=80;
pw2=75;
% pw2=85;
pw2=100;
pw2=35;
pw2=100;
pw2=60;
pw2=120;
% pw2=80;


% pw2=pw;

% pw=61.25;
%pw=70;
%pw2=85;
 %pw2=75;
%     pw=85;
%pw2=45;


%pw2=45;
% tof=17.46;
tof=18.6;
%tof=17.5;
 % tof=18.6;
% tof=19.0; 
% tof=19.5;
% tof=19.9;
% tof=19.8;
% tof=19.7;
tof=18.1;
%tof=18;
%tof=tof;
%tof=18.4;
 tof=19.2;
% tof=19.4;
%tof=19.34;
% tof=19.45;
%tof=16.6;
tof=18.8;

% tof=17.6;
% %tof=19.0;
% tof=18.6;
%tof=17.46;
% % % % % % % tof=17.8;
% tof=gain;

% pi/2 is estimated to occur at pw = 42us
%pw2 = 135*9/2;
 %Tmax=500;
% pw=round(190*10^((37-tpwr)/20));

nc_max=floor(Tmax*1e6/(neco*dtacq + pw2 + tdead));

tpwr = 48;
% tpwr=54;
% tpwr=51;
%   tpwr=40;
% tpwr=37;
% tpwr=34;
%   %tpwr = 54;
% %  tpwr=50;
% tpwr = 40;
%tpwr=48;
%tpwr=32;
% tpwr=41;

tpwr=40;
tpwr=44;
tpwr=49;

% pw=30;
nc=nc_max;

% nc=1694;
%nc=pw;

%tof sweep
tof=19.25;
tof=20;
tof=19;
tof=21;
tof=20.5;
tof=20.3;
tof=24.84;
tof=25.0613;

tof=gain;
% tof=pw;
% tpwr=gain;
gain=18;
gain=14;
%gain=14; %original gain
% gain=20;


%pw2=0;
%nc=1;


fprintf(fid,'%s \n',str);
fprintf(fid,'%s \n',['tpwr =' num2str(tpwr)]);
%fprintf(fid,'%s \n',['pw3 =' num2str(pw4)]);
fprintf(fid,'%s \n',['pw2 =' num2str(pw2)]);
fprintf(fid,'%s \n',['pw =' num2str(pw)]);
fprintf(fid,'%s \n',['nc =' num2str(nc)]);
fprintf(fid,'%s \n',['sw =' num2str(sw)]);
% fprintf(fid,'%s \n',['at =' num2str(at)]);
fprintf(fid,'%s \n',['neco =' num2str(neco)]);
fprintf(fid,'%s \n',['gain =' num2str(gain)]);
% fprintf(fid,'%s \n',['gain =' num2str(20)]);
fprintf(fid,'%s \n',['rof1 =' num2str(rof1)]);
fprintf(fid,'%s \n',['rof2 =' num2str(rof2)]);
fprintf(fid,'%s \n',['rof3 =' num2str(rof3)]);
fprintf(fid,'%s \n',['tof =' num2str(-tof*1000)]);
%fprintf(fid,'%s \n',['tof =' num2str(-tof)]);
%fprintf(fid,'%s \n',['tof =' num2str(tof)]);
         
   str = verbatim;
    %{
au
wexp('ga_loop')
%}
   fprintf(fid,'%s \n',str);
    
   fclose(fid);
   
end