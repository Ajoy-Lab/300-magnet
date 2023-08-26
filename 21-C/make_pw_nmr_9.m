function [nc,Tmax]=make_pw_nmr_9(pw,tacq,gain)

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
    
seqfil = 'fidecay'

$counter = counter
$counter_ct = counter_ct
$pslabel = pslabel
$date = '_'
shell('date +%Y-%m-%d_%H.%M.%OS; cat'):$date
$1 = $date+'_'+$pslabel

folder_name = '/home/ashok/FID_spectra/'+ $1	
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
tdead=rof1+rof2;
nc=934;


% Tmax=350;
% Tmax=200;
% Tmax=1000;
%Tmax=3000/4;
%Tmax=5000/4;
%Tmax=1000/4;
%Tmax=50;
Tmax=tacq;
pw2 = 63;
%pw2 = 135*9/2;
 %Tmax=500;
% nc_max=floor(Tmax*1e3/(neco*dtacq + pw+tdead));
% nc_max=floor(Tmax*1e3/(neco*dtacq + pw2 +tdead));
nc_max=1;
% tof=18.6;
tof=gain;
tpwr=44;
gain=32;

nc=nc_max;
% gain=18;
% nc=1694;



fprintf(fid,'%s \n',str);
fprintf(fid,'%s \n',['pw2 =' num2str(pw2)]);
fprintf(fid,'%s \n',['pw =' num2str(pw)]);
fprintf(fid,'%s \n',['nc =' num2str(nc)]);
fprintf(fid,'%s \n',['sw =' num2str(sw)]);
% fprintf(fid,'%s \n',['at =' num2str(at)]);
fprintf(fid,'%s \n',['neco =' num2str(neco)]);
fprintf(fid,'%s \n',['gain =' num2str(gain)]);
fprintf(fid,'%s \n',['rof1 =' num2str(rof1)]);
fprintf(fid,'%s \n',['rof2 =' num2str(rof2)]);
% fprintf(fid,'%s \n',['rof3 =' num2str(rof3)]);
fprintf(fid,'%s \n',['tof =' num2str(-tof*1000)]);
         
   str = verbatim;
    %{
au
wexp('ga_loop')
%}
   fprintf(fid,'%s \n',str);
    
   fclose(fid);
   
end