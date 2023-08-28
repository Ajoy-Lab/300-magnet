# -*- coding: utf-8 -*-
"""
Created on Wed Sep 28 00:11:49 2022

@author: ozgur
"""
from math import floor

def make_ga_save(pw,tacq,gain):

    fid = open(r'\\192.168.1.5\vnmrsys\maclib\ga_save', 'w');
    #fid = open(r'D:\OneDrive\Documents\Python\ga_save', 'w');
    
    string = """"macro for acquisition and subsequent saving of the FID"
"rewriting of command name (ga --> ga2, modified command as new ga)?"
    
seqfil = 'pulsed_spinlock_loop'

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

"""
    fid.write(string);
    sw=125e4;
    tpwr=tacq;
    dtacq=(1/sw)*1e6;
    tacq=32;
    neco=tacq/dtacq;
    acq_time=neco*dtacq;
    rof1=2;
    rof2=2;
    rof3=3e-6;
    tdead=rof1+rof2+4+rof3*1e6;
       
    Tmax = 5;
    
    pw2=pw;
    
    tof=18.8;
    
    
    pw2=pw;
    nc=floor(Tmax*1e6/(neco*dtacq + pw2 + tdead));
    
    tpwr = 44;
    
    tpwr=32;
    
    #tof sweep
    tof=gain;
    gain=20;
    
    
    pw2=0;
    nc=1;
       
    fid.write(f'tpwr={tpwr} \n');
    fid.write(f'pw2={pw2} \n');
    fid.write(f'pw ={pw} \n');
    fid.write(f'nc={nc} \n');
    fid.write(f'sw={sw} \n');
    fid.write(f'neco={neco} \n');
    fid.write(f'gain={gain} \n');
    fid.write(f'rof1={rof1} \n');
    fid.write(f'rof2={rof2} \n');
    fid.write(f'rof3={rof3} \n');
    fid.write(f'tof={-tof*1000} \n');
         
    string2 = """
au
wexp('ga_loop')
"""
    fid.write(f'{string2} \n');
    
    fid.close();
    return (nc,Tmax);
   
#make_ga_save(85, 32, 20);