# -*- coding: utf-8 -*-
"""
Created on Wed Sep 14 10:27:46 2022

@author: AjoyLabBlueOak
"""


import instruments
import pyvisa
import time
import spinapi_py as pb
import win32com.client as w32

rigol_flag=False;
tabor_flag=False;
psu_flag=False;
ACS_flag=True;
PB_flag=True;

devs={};

## rigol_arb init
rm=pyvisa.ResourceManager();
rigol_port='USB0::0x0400::0x09C4::DG1D191701816::INSTR';
tabor_port='COM16';
helmpsu_port='COM17';

if rigol_flag:
    devs['rigol']=instruments.Rigol_arb_mag(rigol_port);
    devs['rigol'].set_sine_wave(3000, 0.2, 0);
    devs['rigol'].MW_RFOn();
    time.sleep(2);
    devs['rigol'].MW_RFOff();
    devs['rigol'].__del__();

##
if tabor_flag:
    devs['tabor']=instruments.TaborPM8572(tabor_port); 
    devs['tabor'].set_sine_wave(2000, 0.1, 0, 0, 1);
    devs['tabor'].MW_RFOn(1);
    time.sleep(2);
    devs['tabor'].MW_RFOff(1);
    devs['tabor'].__del__();
    
if psu_flag:   
    devs['psu']=instruments.Prog_Supply(helmpsu_port);
    devs['psu'].PS_OUTOn();
    time.sleep(2);
    devs['psu'].PS_OUTOff();
    
    
if ACS_flag:
    devs['com']=w32.Dispatch('SPiiPlusCOM660.Channel.1');
    devs['com'].OpenCommEthernetTCP('10.0.0.100', 701);
    devs['com'].Enable(devs['com'].ACSC_AXIS_0);
    
    devs['com'].SetVelocity(devs['com'].ACSC_AXIS_0,10);
    devs['com'].ToPoint(devs['com'].ACSC_AMF_WAIT, devs['com'].ACSC_AXIS_0,-668.5)
    devs['com'].Go(devs['com'].ACSC_AXIS_0);
    devs['com'].WaitMotionEnd(devs['com'].ACSC_AXIS_0,10000);
    
if PB_flag:
    devs['PB']=instruments.PulseBlaster();
    prog_file='channel0test.pb';
    PB_program=devs['PB'].prog_board("C:\\SpinCore\\SpinAPI\\interpreter\\examples\\" + prog_file);
    devs['PB'].start_board();
    time.sleep(5);
    devs['PB'].stop_board();
    