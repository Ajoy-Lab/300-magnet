# -*- coding: utf-8 -*-
"""
Created on Wed Sep 28 00:11:22 2022

@author: ozgur
"""
from Sage_write import Sage_write
import ga_save_scripts as ga
import time

def Hyperpolar(params,devs,flags,pars_next):
  
    print("Running Experiment: Hyperpolarization");

    # =============================================================================
    #     Set attenuation
    # =============================================================================
    
    # =============================================================================
    #     Setup Helmholtz Coil
    # =============================================================================
    if flags['Helmholtz_coil']:    
        helmholtz_current=params['current'];
        
    # =============================================================================
    #     Laser Dome Arduino Turn Off
    # =============================================================================
    if flags['Lasers']:
        devs['Lasers'].all_lasers_off();
    # =============================================================================
    #     Setup MW parameters
    # =============================================================================
    if flags['Tabor_MW']:
        awg_center_freq=params['awg_center_freq'];
        awg_bw_freq=params['awg_bw_freq'];
        awg_amp=params['awg_amp'];
        sweep_freq=params['sweep_freq'];
        sweep_sigma=params['sweep_sigma'];
        symm=params['symm'];
        srs_freq=params['srs_freq'];
        srs_amp=params['srs_amp'];
        if flags['tasktable']:
            poltime=[None]*6;
            for i in range(6):
                poltime[i]=params[f'poltime{i+1}'];
            starting_pol_sign=params['starting_pol_sign'];
            Sage_write(f'''6,{awg_center_freq},{awg_bw_freq},{awg_amp},{sweep_freq},{sweep_sigma},{symm},{srs_freq},
                                                    {srs_amp},{poltime[1]},{poltime[2]},{poltime[3]},
                                                    {poltime[4]},{poltime[5]},{poltime[6]},{starting_pol_sign}''')
            print('Writing sage parameters');
            time.sleep(25);
            Sage_write('7');
        else:
            Sage_write(f'''6,{awg_center_freq},
                       {awg_bw_freq},
                       {awg_amp},
                       {sweep_freq},
                       {sweep_sigma},
                       {symm},
                       {srs_freq},
                       {srs_amp}''');
            print('Writing sage parameters');
            time.sleep(25);
            Sage_write('7');
        
    # =============================================================================
    #     Initialize Proteus
    # =============================================================================
    Sage_write('1');    
    # =============================================================================
    #     Laser Dome Arduino Set Configuration
    # =============================================================================
    if flags['Lasers']:
        laser_count=params['laser'];
        laser_sequence=params['laser_sequence']; 
        if laser_sequence==1:
            devs['Lasers'].orderlasers(laser_count);
        elif laser_sequence==2:
            devs['Lasers'].lasernumber(laser_count);

    # =============================================================================
    #     Setup NMR Pulse Parameters
    # =============================================================================
    pw=pars_next['pw'];
    tacq=pars_next['tacq'];
    sequence_type=pars_next['sequence_type']; 
    gain=pars_next['gain'];
    if flags['Mag_trigger']:
        pw3=pars_next['pw3'];
        rigol_time1=pars_next['rigol_time1'];
        rigol_time2=pars_next['rigol_time2'];
        rigol_wait1=pars_next['rigol_wait1'];
        rigol_wait2=pars_next['rigol_wait2'];
        Tmaxlol=pars_next['Tmax'];
        rigol_rep=pars_next['rigol_rep'];
        
    if sequence_type==2:
        pw_current=params['pw'];
        tacq_current=params['tacq'];
        gain_current=params['gain'];
        if flags['Mag_trigger']:
            pw3_current=params['pw3'];
            rigol_time1_current=params['rigol_time1'];
            rigol_wait1_current=params['rigol_wait1'];
            rigol_time2_current=params['rigol_time2'];
            rigol_wait2_current=params['rigol_wait2'];
            rigol_rep_current=params['rigol_rep'];
            Tmax_current=params['Tmax'];
            (nc,nc2,nc3,Tmax,Tmax2)=ga.make_ga_save_13(pw_current,
                                                       pw3_current,
                                                       tacq_current,
                                                       rigol_time1_current+rigol_wait1_current,
                                                       rigol_time2_current+rigol_wait2_current);
            
            time.sleep(0.1);
            
            ga.make_ga_save_13(pw_current,
                                                       pw3_current,
                                                       tacq_current,
                                                       rigol_time1_current+rigol_wait1_current,
                                                       rigol_time2_current+rigol_wait2_current);
        else:
            (nc, Tmax)=ga.make_ga_save(pw_current, tacq_current, gain_current);
            time.sleep(0.1);
            ga.make_ga_save(pw, tacq, gain);
    # @WILL: YOU WILL NEED TO CODE THE LASER SEQUENCES YOU WANT TO USE    
    time.sleep(0.2)
    # =============================================================================
    #     Setup Helmholtz coil     
    # =============================================================================
    if flags['Helmholtz_coil']:
        devs['Helmholtz_coil'].PS_OUTOff();
        
    print(f'...Running repetition number');
    # =============================================================================
    #     Turn on Tabor and Rigol AWGs for mag 
    # =============================================================================
    if flags['Tabor_mag']:
        rigol_Vpp=params['rigol_Vpp'];
        rigol_freq=params['rigol_freq'];
        rigol_DC_Offset=params['rigol_DC_offset'];
        mod_state=params['mod_state'];
        if flags['Mag_sweep']: #only works on rigol systems
            rigol_swp_start=params['rigol_swp_sta'];
            rigol_swp_stop=params['rigol_swp_stop'];
            chirpT=params['Tchirp'];
            devs['Tabor_mag'].set_sweep(rigol_swp_start,rigol_swp_stop,chirpT,rigol_Vpp);
            time.sleep(1);
        rigol2_Vpp=params['rigol_Vpp'];
        rigol2_freq=params['rigol2_freq']; 
        devs['Tabor_mag'].set_sine_wave(rigol_freq,rigol_Vpp,rigol_DC_Offset);
        time.sleep(1);
        if mod_state==1:
            mod_freq=params['mod_freq'];
            devs['Tabor_mag'].set_mod(mod_freq);
            time.sleep(0.1);
        devs['Tabor_mag'].MW_RFOn();
        time.sleep(.1);
        devs['Tabor_mag'].MW_RFOn();
        time.sleep(.1);
        devs['Tabor_mag'].MW_RFOn();
        time.sleep(.1);
        
        if flags['Mag_trigger']:
            if mod_state==1:
                devs['Tabor_mag'].set_AMmod(rigol_freq,mod_freq,rigol_Vpp);
                time.sleep(.1);
            elif mod_state==0:
                devs['Tabor_mag'].set_sine_wave(rigol_freq,rigol_Vpp,rigol_DC_Offset,0,1);
                time.sleep(.1);
                devs['Tabor_mag'].set_gate();
                time.sleep(.1);
            elif mod_state==2:
                devs['Tabor_mag'].set_arb(rigol_Vpp,4,rigol2_Vpp);
                time.sleep(.1);
                
            devs['Tabor_mag'].MW_RfOn(1);
            time.sleep(.1);
        time.sleep(.5);
        
    # =============================================================================
    #   Kill all active ACS and PB processes
    # =============================================================================
    if flags['Helmholtz_coil']:
        devs['Helmholtz_coil'].PS_OUTOn(); 
    if flags['ACS']:
        for i in [1,3,7,6,9]:
            devs['ACS'].StopBuffer(i);
        devs['ACS'].KillAll();
    if flags['PB']:
        devs['PB'].stop_board();
          
    # =============================================================================
    #     Turn on Helmholtz
    # =============================================================================
    if flags['Helmholtz_coil']:
        devs['Helmholtz_coil'].PS_OUTOn();    
    # =============================================================================
    #     Initialize actuator position for very first motion
    # =============================================================================
    if flags['ACS']:
        start_pos=devs['ACS'].GetFPosition(devs['ACS'].ACSC_AXIS_0);
        Position=params['g_position'];  
        Velocity=params['velocity'];
        Accn=params['accn'];
        Jerk=params['jerk'];
        c_position=params['coil_position'];
        Wait_time=params['wait_time'];
        tt1=params['tt1'];
        if flags['tasktable']:
            
            Wait_time=sum(poltime);
            print(f'task table mode on, new wait_time value is {Wait_time}');
        
        devs['ACS'].SetVelocity(devs['ACS'].ACSC_AXIS_0,50);
        devs['ACS'].SetAcceleration(devs['ACS'].ACSC_AXIS_0,500);
        devs['ACS'].SetDeceleration(devs['ACS'].ACSC_AXIS_0,500);
        devs['ACS'].SetJerk(devs['ACS'].ACSC_AXIS_0,5000);
    
        devs['ACS'].ToPoint(devs['ACS'].ACSC_AMF_WAIT, devs['ACS'].ACSC_AXIS_0, -Position); #MOVE
        devs['ACS'].Go(devs['ACS'].ACSC_AXIS_0);
        displacement=abs(abs(start_pos)-abs(Position));
        if displacement>2:
            devs['ACS'].WaitMotionEnd(devs['ACS'].ACSC_AXIS_0,1000*10*displacement/50);
            
        fliptime = params['fliptime'];
        waitpos = params['T1_wait_pos'];
        postime = params['T1_wait_time'];
        
        devs['ACS'].SetVelocity(devs['ACS'].ACSC_AXIS_0,Velocity);
        devs['ACS'].SetAcceleration(devs['ACS'].ACSC_AXIS_0,Accn);
        devs['ACS'].SetDeceleration(devs['ACS'].ACSC_AXIS_0,Accn);
        devs['ACS'].SetJerk(devs['ACS'].ACSC_AXIS_0,Jerk);
        
        devs['ACS'].WriteVariable(Wait_time*1e3, 'V1', devs['ACS'].ACSC_NONE); #need to do 1e3 because ACS times are in ms
        devs['ACS'].WriteVariable(-Position, 'V0', devs['ACS'].ACSC_NONE);
        
        devs['ACS'].WriteVariable(postime,'V2', devs['ACS'].ACSC_NONE);
        devs['ACS'].WriteVariable(fliptime*1e3,'V3', devs['ACS'].ACSC_NONE);
        devs['ACS'].ToPoint(devs['ACS'].ACSC_AMF_WAIT, devs['ACS'].ACSC_AXIS_0,-c_position);  #go up to coil position
        devs['ACS'].RunBuffer(8);

    # =============================================================================
    #     Start Pulse Blaster
    # =============================================================================
    if flags['PB']:
        devs['PB'].start_board(); 
    # =============================================================================
    #     Delay for system preparation (hyperpolarization) and acquisition
    # =============================================================================
    if flags['ACS']:
        durPB=0;  
        total_delay = 1.03*sum(durPB)+2*abs(abs(Position)-abs(c_position))/Velocity+3+30+tt1/1000; #don't forget to use the correct value for durPB
        time.sleep(1.03*Wait_time-1.03*0.374-0.95); #3 sec between reps
    Sage_write('8');
    Sage_write('1');
    if flags['Tabor_mag']:
        Sage_write(f'''2,{pw_current},
                   {pw3_current},
                   {nc},
                   {nc2},
                   {rigol_wait1_current+rigol_time1_current},
                   {rigol_wait2_current+rigol_time2_current},
                   {tacq_current},
                   {nc3},
                   {rigol_rep_current},
                   {Tmaxlol}''');
    else:
        Sage_write(f'''2,{pw_current},
                   {nc},
                   {Tmax}
                   {tacq_current}''');
    print('Writing sage parameters');
    # =============================================================================
    #     High field part of the experiment
    # =============================================================================
    time.sleep(total_delay-1.03*Wait_time); #waits for the experiment at high field
    Sage_write('3');
    print('Initializing Sage for measurement');
                   
    # =============================================================================
    #     Turn off all devices that are on
    # =============================================================================
    if flags['PB']:
        devs['PB'].stop_board();
    
    if flags['Helmholtz_coil']:
        devs['Helmholtz_coil'].PS_OUTOff();    
          
    if flags['Tabor_mag']:
        devs['Tabor_mag'].MW_RFOff();
        
    if flags['Lasers']:
        devs['Lasers'].all_lasers_off();
        
    Sage_write('4');
    time.sleep(150);
    print(f'Wait time for Experiment: {Wait_time}');
    