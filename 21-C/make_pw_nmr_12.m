function [nc,nc2,T1,Tmax]=make_pw_nmr_12(pw,pw3,tacq,T1,Tmax)

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
    
seqfil = 'pulsed_spinlock_two_flip_angles'

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

dtacq=(1/sw)*1e6;

neco=tacq/dtacq;
np=2*262144;
% rof2_rem=mod(pw+acq_time+ddrtc,dtacq);
% rof2=dtacq*2 - rof2_rem;
rof1=2;
rof2=2;
rof3=3e-6;%17e-6; %34e-6;
tdead=rof1+rof2+4+rof3*1e6;


% Tmax1=15;
% Tmax2=15;
%pw2=32.5;
%  pw2=pw;
  pw2=85;

% tof=17.46;
 tof=18.6;
% tof=17.6;
%tof=19.0;



nc_max1=floor(T1*1e6/(neco*dtacq + pw + tdead));
nc_max2=floor((Tmax-T1)*1e6/(neco*dtacq + pw3 + tdead));

%tpwr = 54;
 tpwr = 44;

nc=nc_max1;
nc2=nc_max2;





fprintf(fid,'%s \n',str);
fprintf(fid,'%s \n',['tpwr =' num2str(tpwr)]);
fprintf(fid,'%s \n',['pw2 =' num2str(pw2)]);
fprintf(fid,'%s \n',['pw =' num2str(pw)]);
fprintf(fid,'%s \n',['pw3 =' num2str(pw3)]);
fprintf(fid,'%s \n',['nc =' num2str(nc)]);
fprintf(fid,'%s \n',['nc2 =' num2str(nc2)]);
fprintf(fid,'%s \n',['sw =' num2str(sw)]);
% fprintf(fid,'%s \n',['at =' num2str(at)]);
fprintf(fid,'%s \n',['neco =' num2str(neco)]);
fprintf(fid,'%s \n',['gain =' num2str(24)]);
%fprintf(fid,'%s \n',['gain =' num2str(18)]);
fprintf(fid,'%s \n',['rof1 =' num2str(rof1)]);
fprintf(fid,'%s \n',['rof2 =' num2str(rof2)]);
fprintf(fid,'%s \n',['rof3 =' num2str(rof3)]);
fprintf(fid,'%s \n',['tof =' num2str(-tof*1000)]);
%fprintf(fid,'%s \n',['tof =' num2str(-tof)]);
         
   str = verbatim;
    %{
au
wexp('ga_loop')
%}
   fprintf(fid,'%s \n',str);
    
   fclose(fid);
   
end