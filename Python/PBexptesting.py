# -*- coding: utf-8 -*-
"""
Created on Wed Sep 21 17:56:07 2022

@author: qegpi
"""

import spinapi_py as sp
import time

def prog_board(filename=None):
    
    commdict={
        'CONTINUE' : 0,
    	'STOP' : 1,
    	'LOOP' : 2,
    	'END_LOOP' : 3,
    	'JSR' : 4,
    	'RTS' : 5,
    	'BRANCH' : 6,
    	'LONG_DELAY' : 7,
    	'WAIT' : 8,
    	'RTI' : 9
        }
    
    units={
        's' : 1e9,
        'ms' : 1e6,
        'us' : 1e3,
        'ns' : 1e0,
        };
    
    sp.pb_set_debug(0);
    sp.pb_select_board(0);
    if sp.pb_init() != 0:
    	raise ValueError("Error initializing board: %s" % sp.pb_get_error());
        
    # Configure the core clock
    sp.pb_core_clock(100)

    # Program the pulse program
    sp.pb_start_programming(sp.PULSE_PROGRAM);
    
    fid=open(r'C:\SpinCore\SpinAPI\interpreter\examples\channel0test.pb');
    #fid=open(filename);
    lines=fid.readlines();
    read_start=False;
    for text in lines:
        text=text.split('//')[0]; #stripping out the comments in a line
        if text != None and 'start' in text: #will not start reading until the keyword 'start'
            read_start=True;
        if not(read_start):
            continue
         
        if 'stop' in text: 
            break;
        
        if 'start:' in text:  #strip out keyword 'start' from the command
            text = text.split(':',2)[1]; #picks out the string after ':' character
        comms = text.strip(); #gets rid of white spaces
        comms = comms.split(',',2); 
        comms[0]=comms[0].replace(' ',''); #gets rid of any white spaces in the channels section
        comms[1]=comms[1].strip();
        comms[1]=comms[1].split(); #separates duration from units
        if len(comms[0])!=26:
            sp.pb_close();
            fid.close();
            raise Exception("Channel numbers in the program ("+ str(len(comms[0])) +") not consistent with channels on board.");
        try:            
            instruc = sp.pb_inst_pbonly(int(comms[0],0), 0, 0, int(comms[1][0]) * units[comms[1][1]]); #programs the pulse blaster
        except:
            sp.pb_stop_programming();   
            fid.close();
            sp.pb_close();
            raise Exception('Syntax error in PB file.');
            
        
    sp.pb_stop_programming();   
    fid.close();
   
    assert read_start, "Error reading PB file. Pulse Blaster programming stopped."

    
    
def start_board():
    # Trigger the board
    sp.pb_reset();
    sp.pb_start();

def stop_board():
    sp.pb_stop();
    sp.pb_close();

    	
prog_board();
start_board();
time.sleep(10);
stop_board();
print("Board stopped.");