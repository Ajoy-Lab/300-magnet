# -*- coding: utf-8 -*-
"""
Created on Thu Sep 29 00:09:21 2022

@author: ozgur
"""
import numpy as np
import Experiments
import instruments
import win32com.client as w32
import datetime

def paraminterpreter(fn): 
    '''Interprets the param file to create a dictionary of parameters'''
    fid=open(fn,'r');
    param={};

    for count,line in enumerate(fid): #interpreter for the param file
        line=line.split('#')[0]; #gets rid of the comments
        line=line.replace('[','');#gets rid of several unnecessary characters
        line=line.replace(']','');
        line=line.replace(';','');
        line=line.strip();
        if len(line)==0: #skips empty lines
            continue;
        sep=line.split('=');
        assert len(sep)==2, f"Syntax error in \"{par_file}\" at line {count+1}";
        for count,i in enumerate(sep):
            sep[count]=i.strip();
            
        par=sep[0]; #this is the parameter name
        if par=='PB_file':
            param[par]=sep[1];
            continue;
        
        if ":" in sep[1]: #this is for a varied parameter
            vals=sep[1].split(":")
            assert len(vals)==2 or len(vals)==3, f"Syntax error in \"{par_file}\" at line {count+1}";
            if len(vals)==3:
                val=np.arange(float(vals[0]),float(vals[2])+float(vals[1]),float(vals[1]));
            else:
                val=np.arange(float(vals[0]),float(vals[1])+1);
        else:   
            val=float(sep[1]);
        
        param[par]=val;
        
    fid.close();
    return param;

def count_experiments(param):
    '''Returns how many experiments a given run will execute.'''
    count=1;
    for i in param:
        if not(np.isscalar(param[i])):
            count*=len(param[i]);
    return count;

def vary_pars(param):
    '''Returns the names of the parameters being varied'''
    #keys=[];
    for i in param:
        if not(np.isscalar(param[i])):
            #keys.append(i);
            keys=i;
            return keys;
    return [];
        
def dummy_Exp(params,parlook):
    string=f'The experiment is running with {parlook}={params[parlook]}';
    print(string)
    
def dev_interp(flag_file):
    """Interpreter for the device flags file"""
    fid=open(flag_file,'r');
    flags={};
    for count,line in enumerate(fid):
        line=line.replace('[','');#gets rid of several unnecessary characters
        line=line.replace(']','');
        line=line.replace(';','');
        sep=line.split('=');
        assert len(sep)==2, f'Syntax error in the {flag_file} at line {count+1}';
        sep[1]=bool(int(sep[1]));
        assert (sep[1]==0 or sep[1]==1), f'Syntax error in the {flag_file} at line {count+1}';
        flags[sep[0]]=sep[1];
    fid.close();
    return flags;
    
def turn_all_devs_off(devs):
    for dev_name in devs:
        try:
            if dev_name=='ACS':
                continue
            devs[dev_name].__del__();
        except:
            print(f'{dev_name} was unable to be turned off.');

#%%
# =============================================================================
# =============================================================================
# # START OF THE EXPERIMENT
# =============================================================================

# =============================================================================
# =============================================================================
# Read flags
# =============================================================================
flag_file=r'device_flags.txt';
flags=dev_interp(flag_file);
#%%
# =============================================================================
# Establish connection with all of the devices
# =============================================================================

devs={};

try:
    dev_name='ACS';    
    if flags[dev_name]:
        devs[dev_name]=w32.Dispatch('SPiiPlusCOM660.Channel.1');
        devs[dev_name].OpenCommEthernetTCP('10.0.0.100', 701);
        devs[dev_name].Enable(devs[dev_name].ACSC_AXIS_0);
        print(f'{dev_name} connection successful.\n');
        
    dev_name='PB';    
    if flags[dev_name]:
        devs[dev_name]=instruments.PulseBlaster();
        print(f'{dev_name} connection successful.\n');
        PB_file=r'channel0test.pb';
        program=devs['PB'].prog_board(PB_file);
        print('PB programming successful.\n')
        
    dev_name='Rigol_mag';
    if flags[dev_name]:
        rigol_port='USB0::0x0400::0x09C4::DG1D191701816::INSTR';       
        devs[dev_name]=instruments.Rigol_arb_mag(rigol_port);
        print(f'{dev_name} connection successful.\n');
        
    dev_name='Tabor_mag';
    if flags[dev_name]:
        tabor_port='COM16';       
        devs[dev_name]=instruments.TaborPM8572(tabor_port); 
        print(f'{dev_name} connection successful.\n');
    
    dev_name='Helmholtz_coil';
    if flags[dev_name]: 
        helmpsu_port='COM17';
        devs[dev_name]=instruments.Prog_Supply(helmpsu_port); 
        print(f'{dev_name} connection successful.\n'); 
        
    dev_name='Lasers';
    if flags[dev_name]:
        #laser_ports=('COM11','COM12','COM13');
        laser_ports=['COM11'];
        devs[dev_name]=instruments.Laser_Dome_Arduino(laser_ports);
        devs[dev_name].all_lasers_off();
        print(f'{dev_name} connection successful.\n');
except:
    turn_all_devs_off(devs);
    raise Exception('One or more devices was not able to be connected. Please make sure \
every device is connected or the flags for disconnected devices are turned off.')
 
#%%       
# =============================================================================
# Set parameters for the experiment
# =============================================================================
par_file=r'exp_parameters.txt'; #set parameters from file
param_full=paraminterpreter(par_file);
print(count_experiments(param_full));
varied=vary_pars(param_full);

#%%
# =============================================================================
# Save the experimental record to a file with the date
# =============================================================================

dirname=r'C:\300 magnet\Python\saved_experiments';
now=datetime.datetime.now().isoformat(sep='_',timespec='seconds').replace(':','').replace('-','_');
filename=f'{dirname}\\exp_info_{now}.txt';

try:
    fid=open(filename,'w');
    fid.write('# Parameters #\n');
    for keys in param_full:
        fid.write(f'{keys}={param_full[keys]}\n');
    
    fid.write('\n# Flags #\n');
    for keys in flags:
        fid.write(f'{keys}={flags[keys]}\n');
        
    fid.close();
    print(f'Experiment parameters successfully written to {filename}');
except:
    turn_all_devs_off(devs);
    raise Exception(f'Error writing to {filename}. Closing all ports and aborting experiment.')
    

#%%
# =============================================================================
# Run the experiment
# =============================================================================
curr_param=param_full.copy();
par_next=param_full.copy();
if len(varied)==0:
    count_exp=1;
else:
    count_exp=len(param_full[varied]);
    
for i in range(count_exp):
    if count_exp!=1:
        curr_param[varied]=param_full[varied][i];
    if i!=count_exp-1:
        par_next[varied]=param_full[varied][i+1];
    Experiments.Hyperpolar(curr_param,devs,flags,par_next);
    # dummy_Exp(curr_param,var);

 
#%%       
# =============================================================================
# Closing all active devices        
# =============================================================================
try:
    dev_name='Rigol_mag';
    if flags[dev_name]:       
        devs[dev_name].__del__();
        
    dev_name='Tabor_mag';
    if flags[dev_name]:       
        devs[dev_name].__del__(); 
    
    dev_name='Helmholtz_coil';
    if flags[dev_name]: 
        devs[dev_name].__del__();
        
    dev_name='PB';    
    if flags[dev_name]:
       devs[dev_name].stop_board();
       
    dev_name='Lasers';
    if flags[dev_name]:       
        devs[dev_name].__del__();
        
except:
    raise Exception('One or more devices was not able to be disconnected. Please make sure \
the device is turned off manually.')