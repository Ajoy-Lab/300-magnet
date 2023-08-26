function [nc,Tmax]=make_pw_nmr_7(pw,tacq,gain)

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
    
seqfil = 'doubleFloquet'

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

% pw3 = pw;
nc3 = 8;
% pw3 = 120;
% tacq = 32;
% pw = pw*1e-6;

sw=125e4;
dtacq=(1/sw)*1e6;
neco=tacq/dtacq;
acq_time=neco*dtacq;
np=2*262144;
% rof2_rem=mod(pw+acq_time+ddrtc,dtacq);
% rof2=dtacq*2 - rof2_rem;
rof1=2;
rof2=2;
rof3=3e-6;
tdead=rof1+rof2+4+rof3*1e6;

Tmax=15;
tpwr = 54;
pw2 = 45;
% pw2 = 50;
tof=19.45;


% gain = gain;
nc_max=floor(Tmax*1e6/(neco*dtacq + pw2 + tdead));
nc2=floor(nc_max/(nc3+1));
nc=nc2*nc3;

% nc2 = floor(8*(1.5^(pw)));
% 
% nc=floor((170454-6000)/nc2);
% nc=floor(164454/nc2);
% 
% pw2=(88*1.3^gain)-88;

% nc = 131072 / 30;
% nc=250;

% nc=1;

% pw4 = ((neco*dtacq + 4) - pw)*1e-6;


% table1 = 0:1:(nc-1);
% table2 = pw*table1;
% table3 = 90+table2;
% table4 = mod(table3,360);

fprintf(fid,'%s \n',str);
% fprintf(fid,'%s \n',['t4 ={' num2str(table4) '}']);
% fprintf(fid,'%s \n',['t4 ={90,120,150}']);

fprintf(fid,'%s \n',['nc3 =' num2str(nc3)]);
fprintf(fid,'%s \n',['pw2 =' num2str(pw2)]);
fprintf(fid,'%s \n',['pw =' num2str(pw)]);
fprintf(fid,'%s \n',['nc =' num2str(nc)]);
fprintf(fid,'%s \n',['nc2 =' num2str(nc2)]);
fprintf(fid,'%s \n',['sw =' num2str(sw)]);
% fprintf(fid,'%s \n',['at =' num2str(at)]);
fprintf(fid,'%s \n',['neco =' num2str(neco)]);
fprintf(fid,'%s \n',['gain =' num2str(24)]);
fprintf(fid,'%s \n',['rof1 =' num2str(rof1)]);
fprintf(fid,'%s \n',['rof2 =' num2str(rof2)]);
fprintf(fid,'%s \n',['rof3 =' num2str(rof3)]);
% fprintf(fid,'%s \n',['pw4 =' num2str(pw4)]);
fprintf(fid,'%s \n',['tof =' num2str(-tof*1000)]);
fprintf(fid,'%s \n',['tpwr =' num2str(tpwr)]);
         
   str = verbatim;
    %{
au
wbs('save_current_wft')
wexp('ga_loop')
%}
   fprintf(fid,'%s \n',str);
   fclose(fid);
    
end