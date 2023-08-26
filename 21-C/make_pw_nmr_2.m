function make_pw_nmr_2(pw)

    [fid, msg] = fopen(['Z:/vnmrsys/maclib/ga_save'], 'w');
    if fid == 1
        error(msg);
    end
    fprintf(fid, '%s \n');
    str = verbatim;
    %{
"macro for acquisition and subsequent saving of the FID"
"rewriting of command name (ga --> ga2, modified command as new ga)?"
    
seqfil = 'carbon_ext_trig_shuttle'

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
    
sw = 833333.3
at = 0.209
np = 2*262144
nf = 1
proc = 'lp'
%}
%     
%     sw = 62500
% at = 0.250
% np = 31250
% nf = 1
% proc = 'lp'
    
      fprintf(fid,'%s \n',str);
       fprintf(fid,'%s \n',['pw =' num2str(pw)]);
         
   str = verbatim;
    %{
au
werr('when_error')
wbs('save_current_wft')
wexp('ga_loop')
%}
   fprintf(fid,'%s \n',str);
    
   fclose(fid);
   
end