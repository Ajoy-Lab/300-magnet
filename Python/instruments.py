# -*- coding: utf-8 -*-
"""
Created on Wed Sep 14 09:58:25 2022

@author: AjoyLabBlueOak
"""
import pyvisa as vis
import time
import serial
import numpy as np
import spinapi_py as sp
        
   ## START OF CLASS RIGOL_ARB     
        
class Rigol_arb_mag:  
    def __init__(self,port='USB0::0x0400::0x09C4::DG1D191902040::INSTR',rm=vis.ResourceManager()):
        #self.rm=vis.ResourceManager();
        self.vis_obj=rm.open_resource(port);

    def set_sine_wave(self,freq,Vpp,DCoff):
       #self.vis_obj.write('APPL:SIN ' +str(freq)+ ',' +str(Vpp)+ ',' +str(0));
       self.vis_obj.write('FUNC SIN');
       time.sleep(0.1);
       self.vis_obj.write('FREQ ' +str(freq));
       time.sleep(0.1);
       self.vis_obj.write('VOLT '+ str(Vpp));
       time.sleep(0.1);
       self.vis_obj.write('VOLT:OFFS '+ str(DCoff));
       time.sleep(0.1);
       self.vis_obj.write('OUTP:LOAD INF'); #puts the load to high Z
       time.sleep(0.1);
             
    def set_square_wave(self,freq,Vpp):
        self.vis_obj.write('APPL:SQU '+ str(freq)+ ','+ str(Vpp)+ ','+ str(0));
        time.sleep(0.1);
                 
    def set_sweep(self,start,stop,T,Vpp):
        self.vis_obj.write('SWE:TIME ' + str(T));
        time.sleep(0.1);
        self.vis_obj.write('SWE:STAT ON');
        time.sleep(0.1);
        self.vis_obj.write('FREQ:STAR ' + str(start));
        time.sleep(0.1);
        self.vis_obj.write('FREQ:STOP ' + str(stop));
        time.sleep(0.1);
        self.vis_obj.write('VOLT '+ str(Vpp));
        time.sleep(0.1);
        self.vis_obj.write('OUTP:LOAD INF'); #puts the load to high Z
        time.sleep(0.1);
               
    def set_burst(self, phase):
        #         '''Accepts the values:
        #         'cont' for continuous sweep mode
        #         'single' arms the sweeper for a single sweep
        #         '''
        self.vis_obj.write('BURS:STAT ON');
        time.sleep(0.1);
        self.vis_obj.write('BURS:MODE GAT');
        time.sleep(0.1);
        self.vis_obj.write('BURS:NCYC 49999');
        time.sleep(0.1);
        self.vis_obj.write('BURS:GAT:POL NORM');
        time.sleep(0.1);
        self.vis_obj.write('BURS:PHAS ' + str(phase));
        time.sleep(0.1);
                        
    def set_burst_cyc(self, phase, N_cyc):
        #         '''Accepts the values:
        #         'cont' for continuous sweep mode
        #         'single' arms the sweeper for a single sweep
        #         '''
        self.vis_obj.write('BURS:STAT ON');
        time.sleep(0.1); 
        self.vis_obj.write('BURS:MODE GAT');
        time.sleep(0.1);
        self.vis_obj.write('BURS:NCYC ' + str(N_cyc));
        time.sleep(0.1);
        self.vis_obj.write('BURS:GAT:POL NORM');
        time.sleep(0.1);
        self.vis_obj.write('BURS:PHAS ' + str(phase));
        time.sleep(0.1);
                        
    def set_burst_off(self, phase):
       #         '''Accepts the values:
       #         'cont' for continuous sweep mode
       #         'single' arms the sweeper for a single sweep
       #         '''
       self.vis_obj.write('BURS:STAT OFF');
         
    def set_mod(self,modfreq):
       self.vis_obj.write('AM:SOUR INT');
       time.sleep(0.1);
       self.vis_obj.write('AM:INT:FUNC SIN');
       time.sleep(0.1);
       self.vis_obj.write('AM:INT:FREQ '+ str(modfreq));
       time.sleep(0.1);
       self.vis_obj.write('AM:STATE ON');
       time.sleep(0.1);
                  
    def MW_RFOn(self):
        self.vis_obj.write("OUTP ON");
        time.sleep(0.1);
        
    def MW_RFOff(self):
        self.vis_obj.write('OUTP OFF');
        time.sleep(0.1);
        self.vis_obj.write('swe:stat off'); 
        time.sleep(0.1);
        self.vis_obj.write('burs:stat off'); 
        time.sleep(0.1);
        self.vis_obj.write('am:stat off');
        time.sleep(0.1)
          
    def __del__(self): #destructor
        try:
            self.vis_obj.close();
            print('Object closed\n');
        except:
            print('Object failed to close\n');
        
##  END OF CLASS RIGOL_ARB
 
## CLASS FOR TABOR PM8572
class TaborPM8572:
    def __init__(self,port_name,rm=vis.ResourceManager()):
        self.rm=vis.ResourceManager();
        self.vis_obj=self.rm.open_resource(port_name);
                
        # set(self.vis_obj, ...
        #     'BaudRate', 9600, ...
        #     'DataBits', 8, ...
        #     'FlowControl', 'none', ...
        #     'Parity', 'none', ...
        #     'StopBits', 1, ...
        #     'Terminator','CR/LF',...
        #     'OutputBufferSize',2*2048*16)
     
    def set_sine_wave(self,freq,Vpp,DCoff,pha,instno): #sets the normal sine mode
        self.vis_obj.write('INIT:CONT ON');
        time.sleep(0.1);
        self.vis_obj.write('INST:SEL ' + str(instno));
        time.sleep(0.1);
        self.vis_obj.write('SOUR:MOD:TYPE OFF');
        time.sleep(0.1);
        self.vis_obj.write('FUNC:MODE FIX');
        time.sleep(0.1);
        self.vis_obj.write('FUNC:SHAP SIN');
        time.sleep(0.1);
        self.vis_obj.write('SOUR:FREQ '+ str(freq));
        time.sleep(0.1);
        self.vis_obj.write('SOUR:VOLT:LEV:AMPL ' +str(Vpp));
        time.sleep(0.1);
        self.vis_obj.write('SOUR:VOLT:LEV:OFFS '+ str(DCoff));
        time.sleep(0.1);
        self.vis_obj.write('SIN:PHAS '+ str(pha));
        time.sleep(0.1);
        self.vis_obj.write('OUTP:LOAD 1e6'); #puts the load to high Z
        time.sleep(0.1);
     
    def  set_burst(self, phase):
        #         '''Accepts the values:
        #         'cont' for continuous sweep mode
        #         'single' arms the sweeper for a single sweep
        #         '''
        self.vis_obj.write('TRIG:BURS ON');
        time.sleep(0.1);
        self.vis_obj.write('BURS:PHAS '+ str(phase));
        time.sleep(0.1);

    def set_gate(self): #sets the gated mode which waits for trigger from pulse blaster
        self.vis_obj.write('INIT:CONT OFF');
        time.sleep(0.1);
        self.vis_obj.write('TRIG:SOUR EXT');
        time.sleep(0.1);
        self.vis_obj.write('TRIG:GATE ON');
        time.sleep(0.1);
        self.vis_obj.write('TRIG:SLOP NEG');
        time.sleep(0.1);
        self.vis_obj.write('TRIG:LEV 2');
        time.sleep(0.1);
     
    def set_sweep(self,fstart,fstop,famp,Tchirp,instno):
        self.vis_obj.write('INST:SEL ' +str(instno));
        time.sleep(0.1);
        self.vis_obj.write('FUNC:MODE MOD');
        time.sleep(0.1);
        self.vis_obj.write('MOD:TYPE SWE');
        time.sleep(0.1);
        self.vis_obj.write('SWE:START ' +str(fstart));
        time.sleep(0.1);
        self.vis_obj.write('SWE:STOP ' +str(fstop));
        time.sleep(0.1);
        self.vis_obj.write('SWE:TIME '+ str(Tchirp));
        time.sleep(0.1);
        self.vis_obj.write('SWE:DIR UP');
        time.sleep(0.1);
        self.vis_obj.write('SWE:SPAC LIN');
        time.sleep(0.1);
        self.vis_obj.write('SOUR:VOLT:LEV:AMPL ' +str(famp));
        time.sleep(0.1);
     
        # def set_arb(self,Vpp,t1,Vpp2):
        #     ## The following script demonstrates how to create the sequence
        #     #  via ww257x IVI-C driver
        #     #
        #     #  Author: Irina Tseitlin
        #     #  email:  support@taborelec.com
        #     #
        #     #  Copyright (C) 2005-2021 Tabor Electronics Ltd
        #     #  $Revision: 3.0.0 $  $Date: 22/02/2021 15:07:00 $


        #     # Open connection to instrument with address
        #     fclose(obj.vis_obj);
        #     dev = icdevice('ww257x_64.mdd', 'COM16');

        #     try
        #         connect(dev);

        #         # Reset device
        #         groupCnf = get(dev, 'Utility');
        #         invoke(groupCnf, 'reset')

        #         # Set the sample clock
        #         filedir='C:\Users\qegpi\Desktop\sound files\';
        #         seg=1;
        #         pha=[0,0];
        #         amp=[Vpp2/Vpp, 1];
        #         amp=amp/max(amp);
        #         amp=1;
        #         freq=1953.125; #square
        #         #freq=1801.8018; #pentagon
        #         cyc=floor(t1*freq);
        #         n=2048;
        #         for ind=1:seg
        #             fn{ind}=[filedir 'arbwfm' str(floor(freq)) ' ' str(ind) '.asc'];
        #             [Fs]=wfmgen(fn{ind},freq,n,pha(ind),amp(ind));
        #          

        #         groupArb = get(dev, 'Configurationdefsarbitraryoutput');
        #         invoke(groupArb, 'configuresamplerate', Fs)

        #         # Create three segments in the channel A and load waves in them
        #         groupArb = get(dev, 'Configurationdefsarbitraryoutputarbitrarywaveform');

        #         #   wavesdir = 'C:\Program Files\IVI Foundation\IVI\Drivers\ww257x\examples\matlab\waves\';
        #         #   wavesdir = 'C:\Users\qegpi\Desktop\sound files\';
        #         for ind=1:seg
        #             wfmHandle(ind) = invoke(groupArb, 'loadarbwfmfromfile', 'CHAN_A', fn{ind});
        #          

        #         # Create the sequence in the active channel, currently the active
        #         # channel is A because the 'loadarbwfmfromfile' def used with 'CHAN_A'
        #         # parameter ## Sequence Description:
        #         #  Step #              Segment #               Repeats Count
        #         #  [ 1 ]    [ Segment 1 ( sine_1kpts.wav )]         [ 2 ]
        #         #  [ 2 ]    [ Segment 2 ( dc_256pts.wav ) ]         [ 3 ]
        #         #  [ 3 ]    [ Segment 3 ( am_ramp_2kpts.wav )]      [ 1 ]
        #         #
        #         groupArb = get(dev, 'Configurationdefsarbitraryoutputarbitrarysequence');
        #         seqHandle = invoke(groupArb, 'createarbsequence', seg , wfmHandle, cyc*ones(1,seg));

        #         # Create the sequence in the active channel, currently the active
        #         groupCnf = get(dev, 'Configuration');

        #         # Output Modes:
        #         #  0 - Standard waveform
        #         #  1 - Arbitrary
        #         #  2 - Sequence
        #         #  3 - Modulation
        #         invoke(groupCnf, 'configureoutputmode', 2)

        #         # Output enable
        #         #invoke(groupCnf, 'configureoutputenabled', 'CHAN_A', 1)

        #         # Output SYNC signal enable## SYNC Types:
        #         #  0 - BIT
        #         #  1 - LCOM
        #         #   sync_type = 1;
        #         #   invoke(groupCnf, 'configuresyncsignal', wfmHandle1, sync_type, 1, 0)

        #         # Close the connection with instrument
        #         disconnect(dev);
        #         delete(dev);
        #     catch err
        #         # Close the connection with instrument
        #         self.vis_obj.write(err.message);
        #         disconnect(dev);
        #         delete(dev);
        #      
            
        #     fclose(obj.vis_obj);
        #     #obj=TaborPM8572('COM16');
        #     fopen(obj.vis_obj);
        #     obj.set_gate();
        #     obj.set_gate();
        #     obj.set_gate();
        #     self.vis_obj.write(['SOUR:VOLT:LEV:AMPL ' str(Vpp)]);
        #     time.sleep(0.1);
        #     self.vis_obj.write('OUTP:LOAD 1e6'); #puts the load to high Z
        #     time.sleep(0.1);
        #     #obj.MW_RFOn(1);
        #  

    def  set_burst_cyc(self, phase, N_cyc):
        #         '''Accepts the values:
        #         'cont' for continuous sweep mode
        #         'single' arms the sweeper for a single sweep
        #         '''
        self.vis_obj.write('BURS:STAT ON');
        time.sleep(0.1);
        self.vis_obj.write('BURS:MODE GAT');
        time.sleep(0.1);
        self.vis_obj.write('BURS:NCYC ' +str(N_cyc));
        time.sleep(0.1);
        self.vis_obj.write('BURS:GAT:POL NORM');
        time.sleep(0.1);
        self.vis_obj.write('BURS:PHAS '+ str(phase));
        time.sleep(0.1);

    def  set_burst_off(self, phase):
        #         '''Accepts the values:
        #         'cont' for continuous sweep mode
        #         'single' arms the sweeper for a single sweep
        #         '''
        self.vis_obj.write('BURS:STAT OFF');
     
    def set_AMmod(self, CW_freq, modfreq,Vpp): #sets amplitude modulation mode with sinusoidal modulation on CH1
        self.vis_obj.write('INIT:CONT ON');
        time.sleep(0.1);
        self.vis_obj.write('INST:SEL 1');
        time.sleep(0.1);
        self.vis_obj.write('FUNC:MODE MOD');
        time.sleep(0.1);
        self.vis_obj.write('SOUR:MOD:TYPE AM');
        time.sleep(0.1);
        self.vis_obj.write('SOUR:MOD:CARR' +str(CW_freq));
        time.sleep(0.1);
        self.vis_obj.write('AM:FUNC:SHAP SIN');
        time.sleep(0.1);
        self.vis_obj.write('AM:MOD:FREQ' +str(modfreq));
        time.sleep(0.1);
        self.vis_obj.write('SOUR:VOLT:LEV:AMPL '+ str(Vpp));
        time.sleep(0.1);
             
    def MW_RFOn(self,channo=1):
        self.vis_obj.write('INST:SEL ' +str(channo));
        time.sleep(0.1);
        self.vis_obj.write('OUTP ON');
        time.sleep(0.1);
     
    def MW_RFOff(self,channo=1):
        self.vis_obj.write('INST:SEL '+ str(channo));
        time.sleep(0.1);
        self.vis_obj.write('OUTP OFF');
        time.sleep(0.1);
     
    def __del__(self):
        try:
            self.vis_obj.close();
            print('Rigol_mag object closed\n');
        except:
            print('Rigol_mag object failed to close\n');
     
 ## END OF CLASS TABOR PM8572
 


class Prog_Supply:    ##  CLASS FOR PROGRAMMABLE POWER SUPPLY
    def __init__(self,port_name,rm=vis.ResourceManager()):
        self.vis_obj=rm.open_resource(port_name);
     #        set(obj.vis_obj, ...
     # 'BaudRate', 9600, ...
     # 'DataBits', 8, ...
     # 'FlowControl', 'none', ...
     # 'Parity', 'none', ...
     # 'StopBits', 1, ...
     # 'Terminator','CR/LF')
            
         
    # def VoltRead=PS_VoltRead(obj):
    #     self.vis_obj.write(obj. vis_obj,'VOLT?');
    #     VoltStr=fscanf(obj. vis_obj);
    #     VoltRead=str2num(VoltStr);
     
    def PS_VoltSet(self,Volt_Set): #does not work with Korad PSU
        Voltset=round(Volt_Set*100);
        VoltSetStr='su%04d' % (Voltset);
        self.vis_obj.write(VoltSetStr);
     
    # def CurrRead=PS_CurrRead(obj):
    #     self.vis_obj.write(obj. vis_obj,'CURR?');
    #     CurrStr=fscanf(obj. vis_obj);
    #     CurrRead=str2num(CurrStr);
     
    # def PS_CurrSet(self,Curr_Set): #does not work with Korad PSU
    #     CurrSetStr='si%04d'% (Curr_Set*1000);
    #     self.vis_obj.write(CurrSetStr);
          
    def PS_OUTOn(self):
       # self.vis_obj.write('o1'); #for circuitspecialists PSU
       self.vis_obj.write('OUT1'); #for Korad PSU
     
    def PS_OUTOff(self):
        # self.vis_obj.write('o0'); #for circuitspecialists PSU
        self.vis_obj.write('OUT0'); #for Korad PSU
        
    def __del__(self):
        try:
            self.vis_obj.close();
            print('Helmholtz coil object closed\n');
        except:
            print('Helmholtz coil object failed to close\n');
                       
            
class Laser_Dome_Arduino:
        def __init__(self,port_names):
            self.arduinoCom=[];
            for port in port_names:
                self.arduinoCom.append(serial.Serial(port,baudrate=9600,timeout=3));
        
        def all_lasers_off(self):
            mastervectorboard = np.zeros((len(self.arduinoCom),13));
            mastervectorboard[:,0]=np.arange(1,len(self.arduinoCom)+1);
            
            # mastervectorboard1 = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            # mastervectorboard2 = [2, 0, 0, 0, 0, 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0];
            # mastervectorboard3 = [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            print('Turning off Lasers');
            self.send_arduino(mastervectorboard);
        
        def send_arduino(self,x):
            sData=[None]*x.shape[0];
            las=[None]*x.shape[0];      
            for i,board in enumerate(x):
                sData[i]='<'+''.join(str(int(e)) for e in board[1:])+'>';
                self.arduinoCom[i].write(sData[i].encode());
                #las[i]=self.arduinoCom[i].read();
        
        def read_arduino(self):
            laser_state=[None]*len(self.arduinoCom);
            for i,ard in enumerate(self.arduinoCom):
                laser_state[i]=ard.read().decode();
                time.sleep(1);
                print(f'Laser Board {i}: {laser_state[i]}\n');
                
        def orderlasers(self, laser_count):
            mat = np.zeros((len(self.arduinoCom),13));
            mat[:,0]=np.arange(1,len(self.arduinoCom)+1);
            print('Turning ON Laser');
            fid = open('C:\\300 magnet\\21-C\\Initialization\\NV1\\lasernumbers_v1.txt','r');            
            for i in range(int(laser_count)): 
                txt=fid.readline()  
                txt_sep=txt.split();
                boardnum = int(txt_sep[0]);
                lasernum = int(txt_sep[1]);
                mat[boardnum-1, lasernum] = 1;          
            fid.close();
            self.send_arduino(mat);   

        def lasernumber(self, laser_num):
            mat = np.zeros((len(self.arduinoCom),13));
            mat[:,0]=np.arange(1,len(self.arduinoCom)+1);
            print('Turning ON Laser');
            fid = open('C:\\300 magnet\\21-C\\Initialization\\NV1\\lasernumbers_v1.txt','r');
          
            for i in range(int(laser_num)): 
                txt=fid.readline();
                
            txt_sep=txt.split();
            boardnum = int(txt_sep[0]);
            lasernum = int(txt_sep[1]);
            mat[boardnum-1, lasernum] = 1;
          
            fid.close();
            self.send_arduino(mat);   
            
        def __del__(self):
            try:
                for las_board in self.arduinoCom:
                    las_board.close();
                print("All laser boards succesfully closed.");
            except:
                print("Error closing laser boards.");
#end of laser_dome_arduino

#pulse blaster
class PulseBlaster():
    def __init__(self):
        sp.pb_set_debug(0);
        sp.pb_select_board(0);
        if sp.pb_init() != 0:
        	raise ValueError("Error initializing board: %s" % sp.pb_get_error());
            
        # Configure the core clock
        sp.pb_core_clock(100)
    
    def prog_board(self,filename=None):
        
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
        
        program=[]
        # Program the pulse blaster
        sp.pb_start_programming(sp.PULSE_PROGRAM);
        
        #fid=open(r'C:\SpinCore\SpinAPI\interpreter\examples\channel0test.pb');
        try:
            fid=open(filename);
        except:
            sp.pb_close();
            raise Exception('File unable to be opened. Check if the filename is correct.')
            
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
                dur=int(comms[1][0]) * units[comms[1][1]];
                sp.pb_inst_pbonly(int(comms[0],0), 0, 0, dur); #programs the pulse blaster
                program.append([int(comms[0],0),dur])
            except:
                sp.pb_stop_programming();   
                fid.close();
                sp.pb_close();
                raise Exception('Syntax error in PB file.');
                
            
        sp.pb_stop_programming(); 
        fid.close();
       
        assert read_start, "Error reading PB file. Pulse Blaster programming stopped."
        return program;
    
    def start_board(self):
        # Trigger the board
        sp.pb_reset();
        sp.pb_start();
        print("Pulse Blaster started and playing.");
    
    def stop_board(self):
        sp.pb_reset();
        sp.pb_stop();
        sp.pb_close();  
        print("Pulse Blaster stopped playing and closed.");
        
    def __del__(self):
        sp.pb_close();
        print('Pulse Blaster connection is closed.');
        
#end of class pulseblaster