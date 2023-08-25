classdef ExperimentFunctions < handle
    
    properties
        
        interfaceSigGen
        interfaceSigGen2 %for the second SG386 source
        interfaceBNC
        RawData
        AvgData
        Std_dev
        delay_init_and_end_seq
        statuswbexp =0; %will be used as a handle to close the waitbar in case of stop scan
        wf
        com
        mw2
        mw
        arb1
        arb2
        arb3
        arb4
        arb5
        arb6
        arb7
        arb8
        arb9
        arb10
        arb11
        arb12
        pw1
        pw2
        pw3
        pw4
        pw5
        pw6
        pw7
        pw8
        laser
        gpib_LockInAmp
        att
        ramp
       
    end
    
    methods
        
        %%%%% Run experiment %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function RunExperiment(obj,handles)
           warning('off','all');
            handles.ExperimentFinished=0;
            profile on
          
            err = 0; % var that tracks hardware limits on the sequence (for SG, AWG)
            err_latency=0;
            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 0;
            set(handles.text_power,'Visible','on');
            set(handles.slider_each_avg,'Visible','off');
            set(handles.avg_nb,'Visible','off');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % General setup
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            set(handles.uipanel90,'Visible','off');
            set(handles.text_ExpStatus,'String','Experiment Started');
            set(handles.sliderExpScan,'Visible','off');
            set(handles.edit_NoteExp,'Enable','on');
            set(handles.edit_NoteExp,'String','Notes on Experiment:');
            handles.ExperimentalScan.Notes = 'Notes on Experiment:';
            set(handles.button_NoteExp,'Enable','on');
            set(handles.sliderExpScan,'Visible','off');
            set(handles.popup_experiments,'Value',1);
            set(handles.axes_RawData,'Visible','on');
            set(handles.text181,'Visible','on');
            
            %Open MWGenerator
            %handles.ExperimentFunctions.mw.AM100();
            
            %here commented only for random noise exps
            cla(handles.axes_AvgData,'reset');
            cla(handles.axes_RawData,'reset');
           
            % get number of sequence repetitions and averages
            if get(handles.average_continuously,'Value')
                Averages = 1;
            else
                Averages = str2num(get(handles.edit_Averages,'String'));
            end

            Repetitions = str2num(get(handles.edit_Repetitions,'String'));
            handles.ExperimentalScan.Repetitions = Repetitions;
           
            %commented only for Random noise exp
            handles.kk = 1; %worst case picture

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            odnmr_rawdata=[];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % No loop over second dimension
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%OPEN SPIKE
            try
            Close_spike();
            end
            [start,stop]= Initialize_spike();
            

        for  avg_count=1:1:Averages
               %%Loop over averages
                  helper_scan=1;  
                 %handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                %handles.ExperimentFunctions.AvgData=[];
                 mean_odmr_data = NaN*ones(1,handles.ExperimentalScan.vary_points(1));
                 if avg_count==1
                     %odnmr_rawdata=NaN*ones(1,handles.ExperimentalScan.vary_points(1));
                     %odnmr_rawdata = repmat({[]}, 3, 3);
                     if handles.Array_PSeq{1}.Channels(16).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                         if ~isempty (handles.Array_PSeq{helper_scan,1}.Channels(16).Phase)
                         swp_position=-handles.Array_PSeq{helper_scan,1}.Channels(16).Phase;
                         obj.com.SetVelocity(obj.com.ACSC_AXIS_0,0.5);
                         obj.com.SetAcceleration(obj.com.ACSC_AXIS_0,5);
                         obj.com.SetDeceleration(obj.com.ACSC_AXIS_0,5);
                         obj.com.SetJerk(obj.com.ACSC_AXIS_0,50);
                         

                         
                         obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0, swp_position); %MOVE
                         obj.com.Go(obj.com.ACSC_AXIS_0);

                         obj.com.WaitMotionEnd (obj.com.ACSC_AXIS_0, 60000);
                         handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5;
                         handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
                         end

                     end
                     odnmr_rawdata=NaN*ones(Averages,handles.ExperimentalScan.vary_points(1));
                 end
                 
                 if ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                         
                   %% Open files to Save Matching log
                                            
                       
%                        [myyr, mymonth, mydy, myhr, mymin, mysecond] = datevec(now);
%                        mfilename=sprintf('%d-%02d-%02d_%02d.%02d.%02d.txt',myyr, mymonth, mydy, myhr, mymin, round(mysecond));
%                        fmatch=fopen(['D:\QEG2\21-C\Instruments\Spike\Matching_log\log_' mfilename],'wt');
%                        fprintf(fmatch,'Experiment_Number, dc_level, Vpp, dc_level2, Vpp2, dc_level3, Vpp3, dc_level4, Vpp4, dc_level5, Vpp5, dc_level6, Vpp6, dc_level7, Vpp7, dc_level8, Vpp8,Experiment_time\n');
                    %%
                    for aux=1:1:handles.ExperimentalScan.vary_points(1)  %loop over first scan dimension
                        
                        
                        
                        disp(['Running experiment number:' num2str(aux)])
                        status=1;                        
                        if ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                        tic;
                        %% Set attenuation
                        if handles.Array_PSeq{1}.Channels(29).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                        attenuation=handles.Array_PSeq{helper_scan,aux}.Channels(29).Amplitude;
                        dat1 = NET.addAssembly('D:\QEG2\21-C\mcl_RUDAT64.dll');
                        obj.att = mcl_RUDAT64.USB_RUDAT; 
                        obj.att.Connect();
                        obj.att.SetAttenuation(attenuation);
                        %obj.att.Read_Att();
                        end
                        
                        
                        %% MicroWave_Setting
% % %                             if handles.Array_PSeq{1}.Channels(16).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
% % % %                                     if mod(aux,2)==0
% % %                             obj.mw.MW_RFOn();
% % % %                                     end
% % %                             Frequency=handles.Array_PSeq{helper_scan,aux}.Channels(16).Frequency;
% % %                             Amplitude=handles.Array_PSeq{helper_scan,aux}.Channels(16).Amplitude;
% % %                             obj.mw.MW_FreqSet(Frequency);
% % %                             obj.mw.MW_AmpSet(Amplitude);
% % %                             end
                            
                          
                            
                            
%                               Agilent SWEEP
                            
                            if handles.Array_PSeq{1}.Channels(17).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                                    
                             obj.mw.MW_RFOn();
%                               
                            start_Frequency=handles.Array_PSeq{helper_scan,aux}.Channels(17).Frequency;
                             stop_Frequency=handles.Array_PSeq{helper_scan,aux}.Channels(17).Phase;
                             sweep_time=handles.Array_PSeq{helper_scan,aux}.Channels(17).AmpIQ;
                            Amplitude=handles.Array_PSeq{helper_scan,aux}.Channels(17).Amplitude;
                            
                            obj.mw.ise_mode(Amplitude,start_Frequency,stop_Frequency,sweep_time);
                          
                            
                            end
                            
                                %% Gigatronics SWEEP
                            if handles.Array_PSeq{1}.Channels(18).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                                    
%                             obj.mw2.MW_RFOn();
%                               
                            start_Frequency=handles.Array_PSeq{helper_scan,aux}.Channels(18).Frequency;
                             stop_Frequency=handles.Array_PSeq{helper_scan,aux}.Channels(18).Phase;
                             sweep_time=handles.Array_PSeq{helper_scan,aux}.Channels(18).AmpIQ;
                            Amplitude=handles.Array_PSeq{helper_scan,aux}.Channels(18).Amplitude;
                            
                            obj.mw2.ise_mode(Amplitude,start_Frequency,stop_Frequency,sweep_time);
                          
                            
                            end
                            
                                     %% LASER
                            if handles.Array_PSeq{1}.Channels(20).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                Laser=handles.Array_PSeq{helper_scan,aux}.Channels(20).Frequency;
                                obj.laser.Zaber_rot(Laser);
                            end
                            
                             
                            
                            n_cyc=100;
                            
                            
                            %% SET RAMP1
                            if length(handles.Array_PSeq{1}.Channels)>29
                            if handles.Array_PSeq{1}.Channels(30).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                               
                                sweep_freq=handles.Array_PSeq{helper_scan,aux}.Channels(30).Frequency;
                                Vpp1=handles.Array_PSeq{helper_scan,aux}.Channels(30).Phase;
                                dc_level1=handles.Array_PSeq{helper_scan,aux}.Channels(30).AmpIQ;
                                phase1=handles.Array_PSeq{helper_scan,aux}.Channels(30).FreqIQ;
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(30).FreqmodQ;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(30).Amplitude;
                                Match_on_arb1=handles.Array_PSeq{helper_scan,aux}.Channels(30).Ampmod;
                                ramp1_on=handles.Array_PSeq{helper_scan,aux}.Channels(30).FreqmodI;
                                
                                if Match_on_arb1
                                if ramp1_on
                                A1=1.843617; B1=0.133212;
             
                                [vco1_range,vco1_volt]=Rampgen_matching_func(obj.ramp, 1 ,bw_center-bw_range/2,bw_center+bw_range/2,A1,B1);
                                
                                dc_level1=vco1_volt;
                                Vpp1=vco1_range;
                                end
                                end

                                obj.ramp.Set_RampVppVdc(1, Vpp1, dc_level1);
                              %  obj.ramp.Set_RampPhase(1,phase1);
                                pause(0.1);
                                obj.ramp.Set_RampFreq(sweep_freq);
                                pause(0.1);

                                if ~ramp1_on
                                    obj.ramp.Set_RampVppVdc(1, 0, 0);
                                end
                            end
                            end
                            
                            %% SET RAMP2
                            if length(handles.Array_PSeq{1}.Channels)>29
                            if handles.Array_PSeq{1}.Channels(30).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                               
                                sweep_freq=handles.Array_PSeq{helper_scan,aux}.Channels(31).Frequency;
                                Vpp1=handles.Array_PSeq{helper_scan,aux}.Channels(31).Phase;
                                dc_level1=handles.Array_PSeq{helper_scan,aux}.Channels(31).AmpIQ;
                                phase1=handles.Array_PSeq{helper_scan,aux}.Channels(31).FreqIQ;
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(31).FreqmodQ;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(31).Amplitude;
                                Match_on_arb1=handles.Array_PSeq{helper_scan,aux}.Channels(31).Ampmod;
                                ramp1_on=handles.Array_PSeq{helper_scan,aux}.Channels(31).FreqmodI;
                                
                                if Match_on_arb1
                                if ramp1_on
                                A1=1.843617; B1=0.133212;
                        
                                [vco1_range,vco1_volt]=Rampgen_matching_func(obj.ramp, 2 ,bw_center-bw_range/2,bw_center+bw_range/2,A1,B1);
                                
                                dc_level1=vco1_volt;
                                Vpp1=vco1_range;
                                end
                                end

                                obj.ramp.Set_RampVppVdc(2, Vpp1, dc_level1);
                                %obj.ramp.Set_RampPhase(1,phase1);
                                pause(0.1);
                                obj.ramp.Set_RampFreq(sweep_freq);
                                pause(0.1);

                                if ~ramp1_on
                                    obj.ramp.Set_RampVppVdc(2, 0, 0);
                                end
                            end
                            end
                            
                            %% SET RAMP3
                            if length(handles.Array_PSeq{1}.Channels)>29
                            if handles.Array_PSeq{1}.Channels(32).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                               
                                sweep_freq=handles.Array_PSeq{helper_scan,aux}.Channels(32).Frequency;
                                Vpp1=handles.Array_PSeq{helper_scan,aux}.Channels(32).Phase;
                                dc_level1=handles.Array_PSeq{helper_scan,aux}.Channels(32).AmpIQ;
                                phase1=handles.Array_PSeq{helper_scan,aux}.Channels(32).FreqIQ;
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(32).FreqmodQ;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(32).Amplitude;
                                Match_on_arb1=handles.Array_PSeq{helper_scan,aux}.Channels(32).Ampmod;
                                ramp1_on=handles.Array_PSeq{helper_scan,aux}.Channels(32).FreqmodI;
                                
                                if Match_on_arb1
                                if ramp1_on
                                A1=1.843617; B1=0.133212;
                             
                                [vco1_range,vco1_volt]=Rampgen_matching_func(obj.ramp, 3 ,bw_center-bw_range/2,bw_center+bw_range/2,A1,B1);
                                
                                dc_level1=vco1_volt;
                                Vpp1=vco1_range;
                                end
                                end

                                obj.ramp.Set_RampVppVdc(3, Vpp1, dc_level1);
                              %  obj.ramp.Set_RampPhase(1,phase1);
                                pause(0.1);
                                obj.ramp.Set_RampFreq(sweep_freq);
                                pause(0.1);

                                if ~ramp1_on
                                    obj.ramp.Set_RampVppVdc(3, 0, 0);
                                end
                            end
                            end
                            
                            %% SET RAMP4
                            if length(handles.Array_PSeq{1}.Channels)>29
                            if handles.Array_PSeq{1}.Channels(33).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                               
                                sweep_freq=handles.Array_PSeq{helper_scan,aux}.Channels(33).Frequency;
                                Vpp1=handles.Array_PSeq{helper_scan,aux}.Channels(33).Phase;
                                dc_level1=handles.Array_PSeq{helper_scan,aux}.Channels(33).AmpIQ;
                                phase1=handles.Array_PSeq{helper_scan,aux}.Channels(33).FreqIQ;
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(33).FreqmodQ;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(33).Amplitude;
                                Match_on_arb1=handles.Array_PSeq{helper_scan,aux}.Channels(33).Ampmod;
                                ramp1_on=handles.Array_PSeq{helper_scan,aux}.Channels(33).FreqmodI;
                                
                                if Match_on_arb1
                                if ramp1_on
                                A1=1.843617; B1=0.133212;
                          
                                [vco1_range,vco1_volt]=Rampgen_matching_func(obj.ramp, 4 ,bw_center-bw_range/2,bw_center+bw_range/2,A1,B1);
                                
                                dc_level1=vco1_volt;
                                Vpp1=vco1_range;
                                end
                                end

                                obj.ramp.Set_RampVppVdc(4, Vpp1, dc_level1);
                              %  obj.ramp.Set_RampPhase(1,phase1);
                                pause(0.1);
                                obj.ramp.Set_RampFreq(sweep_freq);
                                pause(0.1);

                                if ~ramp1_on
                                    obj.ramp.Set_RampVppVdc(4, 0, 0);
                                end
                            end
                            end

                            %% TURN OFF ALL DEVICES
                                spike_turn_off_devices(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.arb1,obj.arb2,obj.arb3,obj.arb4);
                                pause(0.2);
                                
                                if size(handles.Array_PSeq{1}.Channels,2)>24&&size(handles.Array_PSeq{1}.Channels,2)<=29
                                    spike_turn_off_devices_8VCOs(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.pw5,obj.pw6,obj.pw7,obj.arb1,obj.arb2,obj.arb3,obj.arb4,obj.arb9,obj.arb10,obj.arb11,obj.arb12);
                                    pause(0.2);
                                end
                                
                            %% Agilent ARB arb1
                            
                            if handles.Array_PSeq{1}.Channels(19).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb1.MW_RFOn();
                                %
                                Vpp=handles.Array_PSeq{helper_scan,aux}.Channels(19).Frequency;
                                phase=handles.Array_PSeq{helper_scan,aux}.Channels(19).Phase;
                                sweep_time=handles.Array_PSeq{helper_scan,aux}.Channels(19).AmpIQ;
                                Symmetry=handles.Array_PSeq{helper_scan,aux}.Channels(19).FreqIQ;
                                dc_level=handles.Array_PSeq{helper_scan,aux}.Channels(19).FreqmodQ;
                                agilent_on=handles.Array_PSeq{helper_scan,aux}.Channels(19).Amplitude;
                                agilent_match=handles.Array_PSeq{helper_scan,aux}.Channels(19).FreqmodI;
                                
                                if agilent_match
                                if agilent_on
                                %Fitting result of Freq-Volt curve
                                %Freq=A+B*Volt
                                %Minicircuits
                                  A1=1.843617; B1=0.133212;
                                % Best VCO
                                %A1=1.615935; B1=0.110454;
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(19).Ampmod)
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(19).Ampmod;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(19).Phasemod;
                                end
                                [vco1_range,vco1_volt]=spike_matching_func(obj.pw1,obj.arb1,bw_center-bw_range/2,bw_center+bw_range/2,A1,B1);
                                dc_level=vco1_volt;
                                Vpp=vco1_range;
                                end
                                end
                                
                                freq=round2(1/sweep_time,0.1);
                                % freq=sweep_time;
                                obj.pw1.PS_VoltSet(dc_level);
                                
                                obj.pw1.PS_CurrSet(1);
                                
                                obj.pw1.PS_OUTOn();
                                
                                obj.arb1.ise_mode(freq,Vpp,0,Symmetry);
                                obj.arb1.set_burst(phase);
                                
                                %%%%%%%%%%%%%%%%%%%
                                %obj.arb1.set_burst_cyc(phase,n_cyc);
                                % Set phase cycle
                                
                                if ~agilent_on
                                    obj.arb1.MW_RFOff();
                                    pause(0.2);
                                    obj.pw1.PS_OUTOff();
                                end
                            end
                            
                             %% TURN OFF ALL DEVICES
                                spike_turn_off_devices(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.arb1,obj.arb2,obj.arb3,obj.arb4);
                               pause(0.2);
                              %% Rigol ARB arb2
                            
                            if handles.Array_PSeq{1}.Channels(21).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb2.MW_RFOn();
                                %arb2
                                Vpp2=handles.Array_PSeq{helper_scan,aux}.Channels(21).Frequency;
                                phase2=handles.Array_PSeq{helper_scan,aux}.Channels(21).Phase;
                                sweep_time2=handles.Array_PSeq{helper_scan,aux}.Channels(21).AmpIQ;
                                Symmetry2=handles.Array_PSeq{helper_scan,aux}.Channels(21).FreqIQ;
                                dc_level2=handles.Array_PSeq{helper_scan,aux}.Channels(21).FreqmodQ;
                                freq2=round2(1/sweep_time2,0.1);
                                rigol_on2=handles.Array_PSeq{helper_scan,aux}.Channels(21).Amplitude;
                                rigol2_match=handles.Array_PSeq{helper_scan,aux}.Channels(21).FreqmodI;
                                
                                if rigol2_match
                                if rigol_on2
                                %Fitting result of Freq-Volt curve
                                %Freq=A+B*Volt
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(21).Ampmod)
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(21).Ampmod;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(21).Phasemod;
                                end
                               A2=1.824469; B2=0.136353;
                                %A2=1.614907; B2=0.111984;
                                [vco2_range,vco2_volt]=spike_matching_func(obj.pw2,obj.arb2,bw_center-bw_range/2,bw_center+bw_range/2,A2,B2);
                                dc_level2=vco2_volt;
                                Vpp2=vco2_range;
                                end
                                end
                                
                                %USE MATCH VALUES OF 1 in 2
                                 dc_level2=vco1_volt;
                                 Vpp2=vco1_range;
%                               
                                % freq=sweep_time;
                                obj.pw2.PS_CurrSet(1);
                                obj.pw2.PS_VoltSet(dc_level2);
                                obj.pw2.PS_OUTOn();
                                
                                obj.arb2.ise_mode(freq2,Vpp2,0,Symmetry2);
                                obj.arb2.set_burst(phase2);
                                %%%%%%%%%%%%%%%
                                %obj.arb2.set_burst_cyc(phase,n_cyc);
                                % Set phase cycle
                                
                                
                                pause(0.2);
                                obj.arb2.MW_RFOn();
                                if ~rigol_on2
                                    obj.arb2.MW_RFOff();
                                    pause(0.2);
                                    obj.pw2.PS_OUTOff();
                                end
                                
                            end
                            
                            %% TURN OFF ALL DEVICES
                                spike_turn_off_devices(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.arb1,obj.arb2,obj.arb3,obj.arb4);
                                  pause(0.2);
                             %% Rigol arb3
%                             
                            if handles.Array_PSeq{1}.Channels(22).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb3.MW_RFOn();
                                %arb3
                                Vpp3=handles.Array_PSeq{helper_scan,aux}.Channels(22).Frequency;
                                phase3=handles.Array_PSeq{helper_scan,aux}.Channels(22).Phase;
                                sweep_time3=handles.Array_PSeq{helper_scan,aux}.Channels(22).AmpIQ;
                                Symmetry3=handles.Array_PSeq{helper_scan,aux}.Channels(22).FreqIQ;
                                dc_level3=handles.Array_PSeq{helper_scan,aux}.Channels(22).FreqmodQ;
                                freq3=round2(1/sweep_time3,0.1);
                                rigol_on3=handles.Array_PSeq{helper_scan,aux}.Channels(22).Amplitude;
                                rigol3_match=handles.Array_PSeq{helper_scan,aux}.Channels(22).FreqmodI;
                                
                                if rigol3_match
                                if rigol_on3
                                %Fitting result of Freq-Volt curve
                                %Freq=A+B*Volt
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(22).Ampmod)
                                    bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(22).Ampmod;
                                    bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(22).Phasemod;
                                end
                                A3=1.831051; B3=0.133029;
                                %A3=1.639558; B3=0.108647;
                                [vco3_range,vco3_volt]=spike_matching_func(obj.pw3,obj.arb3,bw_center-bw_range/2,bw_center+bw_range/2,A3,B3);
                                dc_level3=vco3_volt;
                                Vpp3=vco3_range;
                                end
                                end
                                
                                %USE MATCH VALUES OF 1 in 3
                              dc_level3=vco1_volt;
                                 Vpp3=vco1_range;
%                                 
                                % freq=sweep_time;
                                obj.pw3.PS_CurrSet(1);                              
                                obj.pw3.PS_VoltSet(dc_level3);
                                obj.pw3.PS_OUTOn();
                                
                                obj.arb3.ise_mode(freq3,Vpp3,0,Symmetry3);
                                obj.arb3.set_burst(phase3);
                                %%%%%%%%%%%%%%%
                                %obj.arb3.set_burst_cyc(phase,n_cyc);
                                % Set phase & burst cycle
                                pause(0.2);
                                obj.arb3.MW_RFOn();
                                if ~rigol_on3
                                    obj.arb3.MW_RFOff();
                                    pause(0.2);
                                    obj.pw3.PS_OUTOff();
                                end
                                
                            end

                            %% TURN OFF ALL DEVICES
                           spike_turn_off_devices(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.arb1,obj.arb2,obj.arb3,obj.arb4);
                             pause(0.5);
%                             
                            
                            %% RIGOL arb4                       
                            if handles.Array_PSeq{1}.Channels(23).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb4.MW_RFOn();
                                %arb4
                                Vpp4=handles.Array_PSeq{helper_scan,aux}.Channels(23).Frequency;
                                phase4=handles.Array_PSeq{helper_scan,aux}.Channels(23).Phase;
                                sweep_time4=handles.Array_PSeq{helper_scan,aux}.Channels(23).AmpIQ;
                                Symmetry4=handles.Array_PSeq{helper_scan,aux}.Channels(23).FreqIQ;
                                dc_level4=handles.Array_PSeq{helper_scan,aux}.Channels(23).FreqmodQ;
                                freq4=round2(1/sweep_time4,0.1);
                                rigol_on4=handles.Array_PSeq{helper_scan,aux}.Channels(23).Amplitude;
                                rigol4_match=handles.Array_PSeq{helper_scan,aux}.Channels(23).FreqmodI;
                                
                                if rigol4_match
                                if rigol_on4
                                %Fitting result of Freq-Volt curve
                                %Freq=A+B*Volt
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(23).Ampmod)
                                    bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(23).Ampmod;
                                    bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(23).Phasemod;
                                end
                                 A4=1.831051; B4=0.133029;
                                %A4=1.563805; B4=0.112468;
                                [vco4_range,vco4_volt]=spike_matching_func(obj.pw4,obj.arb4,bw_center-bw_range/2,bw_center+bw_range/2,A4,B4);
                                dc_level4=vco4_volt;
                                Vpp4=vco4_range;
                                end
                                end
                                
                                 %USE MATCH VALUES OF 1 in 2
                                 dc_level4=vco1_volt;
                                 Vpp4=vco1_range;
%                                 
                                
                                % freq=sweep_time;
                                obj.pw4.PS_CurrSet(1);                              
                                obj.pw4.PS_VoltSet(dc_level4);
                                obj.pw4.PS_OUTOn();
                                
                                obj.arb4.ise_mode(freq4,Vpp4,0,Symmetry4);
                                obj.arb4.set_burst(phase4);
                                %%%%%%%%%%%%%%%
                                %obj.arb3.set_burst_cyc(phase,n_cyc);
                                % Set phase & burst cycle
                                pause(0.2);
                                obj.arb4.MW_RFOn();
                                if ~rigol_on4
                                    obj.arb4.MW_RFOff();
                                    pause(0.2);
                                    obj.pw4.PS_OUTOff();
                                end
                                
                            end
                            
%                             if handles.Array_PSeq{1}.Channels(23).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                                 %
%                                 obj.arb4.MW_RFOn();
%                                 %
%                                 Vpp4=handles.Array_PSeq{helper_scan,aux}.Channels(23).Frequency;
%                                 phase4=handles.Array_PSeq{helper_scan,aux}.Channels(23).Phase;
%                                 sweep_time4=handles.Array_PSeq{helper_scan,aux}.Channels(23).AmpIQ;
%                                 Symmetry4=handles.Array_PSeq{helper_scan,aux}.Channels(23).FreqIQ;
%                                 dc_level4=handles.Array_PSeq{helper_scan,aux}.Channels(23).FreqmodQ;
%                                 hp_on4=handles.Array_PSeq{helper_scan,aux}.Channels(23).Amplitude;
%                                 
%                                 
%                                 freq4=round2(1/sweep_time,0.1);
%                                 % freq=sweep_time;
% %                                 obj.pw4.PS_VoltSet(dc_level4);
% %                                 
% %                                 obj.pw4.PS_CurrSet(1);
% %                                 
% %                                 obj.pw4.PS_OUTOn();
%                                 
%                                 obj.arb4.ise_mode(freq4,Vpp4,0,Symmetry4);
%                                 obj.arb4.set_burst(phase4);
%                                 %%%%%%%%%%%%%%%
%                                 %obj.arb4.set_burst_cyc(phase,n_cyc);
%                                 % Set phase & burst cycle
%                                 pause(0.2);
%                                 obj.arb4.MW_RFOn();
%                                 
%                                 if ~hp_on4
%                                     obj.arb4.MW_RFOff();
%                                     pause(0.2);
% %                                     obj.pw4.PS_OUTOff();
%                                 end
%                             end
                            %% TURN on ALL DEVICES?
                      % spike_turn_on_devices(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.arb1,obj.arb2,obj.arb3,obj.arb4,agilent_on,rigol_on2,rigol_on3,rigol_on4);
                            

                            %% Rigol arb5
                            
                            if handles.Array_PSeq{1}.Channels(14).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb5.MW_RFOn();
                                %arb3
                                Vpp3=handles.Array_PSeq{helper_scan,aux}.Channels(14).Frequency;
                                phase3=handles.Array_PSeq{helper_scan,aux}.Channels(14).Phase;
                                sweep_time3=handles.Array_PSeq{helper_scan,aux}.Channels(14).AmpIQ;
                                Symmetry3=handles.Array_PSeq{helper_scan,aux}.Channels(14).FreqIQ;
                                dc_level3=handles.Array_PSeq{helper_scan,aux}.Channels(14).FreqmodQ;
%                                 freq3=round2(1/sweep_time3,0.1);
                                rigol_on5=handles.Array_PSeq{helper_scan,aux}.Channels(14).Amplitude;
                                
                                
                                % freq=sweep_time;
%                                 obj.pw3.PS_CurrSet(1);
%                                 obj.pw3.PS_VoltSet(dc_level3);
%                                 obj.pw3.PS_OUTOn();
                                
                                obj.arb5.ise_mode(freq3,Vpp3,0,Symmetry3);
                                obj.arb5.set_burst(phase3);
                                %%%%%%%%%%%%%%%
                                %obj.arb5.set_burst_cyc(phase3,n_cyc);
                                % Set phase & burst cycle
                                pause(0.2);
                                obj.arb5.MW_RFOn();
                                if ~rigol_on5
                                    obj.arb5.MW_RFOff();
                                    pause(0.2);
                                    obj.pw1.PS_OUTOff();
                                end
                                
                            end
                            
                            %% Rigol ARB2 arb6
                            
                            if handles.Array_PSeq{1}.Channels(15).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb6.MW_RFOn();
                                %arb6
                                Vpp3=handles.Array_PSeq{helper_scan,aux}.Channels(15).Frequency;
                                phase3=handles.Array_PSeq{helper_scan,aux}.Channels(15).Phase;
                                sweep_time3=handles.Array_PSeq{helper_scan,aux}.Channels(15).AmpIQ;
                                Symmetry3=handles.Array_PSeq{helper_scan,aux}.Channels(15).FreqIQ;
                                dc_level3=handles.Array_PSeq{helper_scan,aux}.Channels(15).FreqmodQ;
                                freq3=round2(1/sweep_time3,0.1);
                                rigol_on6=handles.Array_PSeq{helper_scan,aux}.Channels(15).Amplitude;
                                
                                
                                % freq=sweep_time;
%                                 obj.pw3.PS_CurrSet(1);
%                                 obj.pw3.PS_VoltSet(dc_level3);
%                                 obj.pw3.PS_OUTOn();
                                
                                obj.arb6.ise_mode(freq3,Vpp3,0,Symmetry3);
                                obj.arb6.set_burst(phase3);
                                %%%%%%%%%%%%%%%
                                %obj.arb6.set_burst_cyc(phase3,n_cyc);
                                % Set phase & burst cycle
                                pause(0.2);
                                obj.arb6.MW_RFOn();
                                if ~rigol_on6
                                    obj.arb6.MW_RFOff();
                                    pause(0.2);
                                    obj.pw2.PS_OUTOff();
                                end
                                
                            end
                            
                            %% Rigol ARB2 arb7
                            
                            if handles.Array_PSeq{1}.Channels(6).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb7.MW_RFOn();
                                %arb3
                                Vpp3=handles.Array_PSeq{helper_scan,aux}.Channels(6).Frequency;
                                phase3=handles.Array_PSeq{helper_scan,aux}.Channels(6).Phase;
                                sweep_time3=handles.Array_PSeq{helper_scan,aux}.Channels(6).AmpIQ;
                                Symmetry3=handles.Array_PSeq{helper_scan,aux}.Channels(6).FreqIQ;
                                dc_level3=handles.Array_PSeq{helper_scan,aux}.Channels(6).FreqmodQ;
                                freq3=round2(1/sweep_time3,0.1);
                                rigol_on7=handles.Array_PSeq{helper_scan,aux}.Channels(6).Amplitude;
                                
                                
                                % freq=sweep_time;
%                                 obj.pw3.PS_CurrSet(1);
%                                 obj.pw3.PS_VoltSet(dc_level3);
%                                 obj.pw3.PS_OUTOn();
                                
                                obj.arb7.ise_mode(freq3,Vpp3,0,Symmetry3);
                                obj.arb7.set_burst(phase3);
                                %%%%%%%%%%%%%%%
                                %obj.arb7.set_burst_cyc(phase3,n_cyc);
                                % Set phase & burst cycle
                                pause(0.2);
                                obj.arb7.MW_RFOn();
                                if ~rigol_on7
                                    obj.arb7.MW_RFOff();
                                    pause(0.2);
                                    obj.pw3.PS_OUTOff();
                                end
                                
                            end
%                             
                            %% Rigol ARB2 arb8
                            
                            if handles.Array_PSeq{1}.Channels(7).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb8.MW_RFOn();
                                Vpp4=handles.Array_PSeq{helper_scan,aux}.Channels(7).Frequency;
                                phase4=handles.Array_PSeq{helper_scan,aux}.Channels(7).Phase;
                                sweep_time4=handles.Array_PSeq{helper_scan,aux}.Channels(7).AmpIQ;
                                Symmetry4=handles.Array_PSeq{helper_scan,aux}.Channels(7).FreqIQ;
                                dc_level4=handles.Array_PSeq{helper_scan,aux}.Channels(7).FreqmodQ;
                                freq4=round2(1/sweep_time4,0.1);
                                rigol_on8=handles.Array_PSeq{helper_scan,aux}.Channels(7).Amplitude;
                                
                                
                                % freq=sweep_time;
%                                 obj.pw3.PS_CurrSet(1);
%                                 obj.pw3.PS_VoltSet(dc_level3);
%                                 obj.pw3.PS_OUTOn();
                                
                                obj.arb8.ise_mode(freq4,Vpp4,0,Symmetry4);
                                obj.arb8.set_burst(phase4);
                                %%%%%%%%%%%%%%%
                                %obj.arb6.set_burst_cyc(phase3,n_cyc);
                                % Set phase & burst cycle
                                pause(0.2);
                                obj.arb8.MW_RFOn();
                                if ~rigol_on8
                                    obj.arb8.MW_RFOff();
                                    pause(0.2);
                                    obj.pw4.PS_OUTOff();
                                end
                                
                            end
                            
                            
                            %%%%%%% Only on when we use matching script
                            if size(handles.Array_PSeq{1}.Channels,2)>24
                                
                               %% TURN OFF ALL DEVICES
                              spike_turn_off_devices_8VCOs(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.pw5,obj.pw6,obj.pw7,obj.arb1,obj.arb2,obj.arb3,obj.arb4,obj.arb9,obj.arb10,obj.arb11,obj.arb12);
                               pause(0.2);
                             %% Rigol ARB arb9
                            
                            if handles.Array_PSeq{1}.Channels(25).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb9.MW_RFOn();
                                %arb2
                                Vpp9=handles.Array_PSeq{helper_scan,aux}.Channels(25).Frequency;
                                phase9=handles.Array_PSeq{helper_scan,aux}.Channels(25).Phase;
                                sweep_time9=handles.Array_PSeq{helper_scan,aux}.Channels(25).AmpIQ;
                                Symmetry9=handles.Array_PSeq{helper_scan,aux}.Channels(25).FreqIQ;
                                dc_level9=handles.Array_PSeq{helper_scan,aux}.Channels(25).FreqmodQ;
                                freq9=round2(1/sweep_time9,0.1);
                                rigol_on9=handles.Array_PSeq{helper_scan,aux}.Channels(25).Amplitude;
                                rigol9_match=handles.Array_PSeq{helper_scan,aux}.Channels(25).FreqmodI;
                                
                                if rigol9_match
                                if rigol_on9
                                %Fitting result of Freq-Volt curve
                                %Freq=A+B*Volt
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(25).Ampmod)
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(25).Ampmod;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(25).Phasemod;
                                end
                                A2=1.615935; B2=0.110454;
%                                 A2=2.45; B2=0.15;
                                [vco_range,vco_volt]=spike_matching_func(obj.pw5,obj.arb9,3,8,bw_center-bw_range/2,bw_center+bw_range/2,A2,B2);
                                dc_level9=vco_volt;
                                Vpp9=vco_range;
                                end
                                end
                                % freq=sweep_time;
                                obj.pw5.PS_CurrSet(1);
                                obj.pw5.PS_VoltSet(dc_level9);
                                obj.pw5.PS_OUTOn();
                                
                                obj.arb9.ise_mode(freq9,Vpp9,0,Symmetry9);
                                obj.arb9.set_burst(phase9);
                                %%%%%%%%%%%%%%%
                                %obj.arb2.set_burst_cyc(phase,n_cyc);
                                % Set phase cycle
                                
                                
                                pause(0.2);
                                obj.arb9.MW_RFOn();
                                if ~rigol_on9
                                    obj.arb9.MW_RFOff();
                                    pause(0.2);
                                    obj.pw5.PS_OUTOff();
                                end
                                
                            end   
                            
                               %% TURN OFF ALL DEVICES
                               spike_turn_off_devices_8VCOs(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.pw5,obj.pw6,obj.pw7,obj.arb1,obj.arb2,obj.arb3,obj.arb4,obj.arb9,obj.arb10,obj.arb11,obj.arb12);
                               pause(0.2);
                             %% Rigol ARB arb10
                            
                            if handles.Array_PSeq{1}.Channels(26).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb10.MW_RFOn();
                                %arb2
                                Vpp10=handles.Array_PSeq{helper_scan,aux}.Channels(26).Frequency;
                                phase10=handles.Array_PSeq{helper_scan,aux}.Channels(26).Phase;
                                sweep_time10=handles.Array_PSeq{helper_scan,aux}.Channels(26).AmpIQ;
                                Symmetry10=handles.Array_PSeq{helper_scan,aux}.Channels(26).FreqIQ;
                                dc_level10=handles.Array_PSeq{helper_scan,aux}.Channels(26).FreqmodQ;
                                freq10=round2(1/sweep_time10,0.1);
                                rigol_on10=handles.Array_PSeq{helper_scan,aux}.Channels(26).Amplitude;
                                rigol10_match=handles.Array_PSeq{helper_scan,aux}.Channels(26).FreqmodI;
                                
                                if rigol10_match
                                if rigol_on10
                                %Fitting result of Freq-Volt curve
                                %Freq=A+B*Volt
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(26).Ampmod)
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(26).Ampmod;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(26).Phasemod;
                                end
                                A2=1.614907; B2=0.111984;
%                                 A2=2.45; B2=0.15;
                                [vco_range,vco_volt]=spike_matching_func(obj.pw6,obj.arb10,3,8,bw_center-bw_range/2,bw_center+bw_range/2,A2,B2);
                                dc_level10=vco_volt;
                                Vpp10=vco_range;
                                end
                                end
                                % freq=sweep_time;
                                obj.pw6.PS_CurrSet(1);
                                obj.pw6.PS_VoltSet(dc_level10);
                                obj.pw6.PS_OUTOn();
                                
                                obj.arb10.ise_mode(freq10,Vpp10,0,Symmetry10);
                                obj.arb10.set_burst(phase10);
                                %%%%%%%%%%%%%%%
                                %obj.arb2.set_burst_cyc(phase,n_cyc);
                                % Set phase cycle
                                
                                
                                pause(0.2);
                                obj.arb10.MW_RFOn();
                                if ~rigol_on10
                                    obj.arb10.MW_RFOff();
                                    pause(0.2);
                                    obj.pw6.PS_OUTOff();
                                end
                                
                            end   
                              
                            %% TURN OFF ALL DEVICES
                               spike_turn_off_devices_8VCOs(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.pw5,obj.pw6,obj.pw7,obj.arb1,obj.arb2,obj.arb3,obj.arb4,obj.arb9,obj.arb10,obj.arb11,obj.arb12);
                               pause(0.2);
                             %% Rigol ARB arb11
                            
                            if handles.Array_PSeq{1}.Channels(27).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb11.MW_RFOn();
                                %arb2
                                Vpp11=handles.Array_PSeq{helper_scan,aux}.Channels(27).Frequency;
                                phase11=handles.Array_PSeq{helper_scan,aux}.Channels(27).Phase;
                                sweep_time11=handles.Array_PSeq{helper_scan,aux}.Channels(27).AmpIQ;
                                Symmetry11=handles.Array_PSeq{helper_scan,aux}.Channels(27).FreqIQ;
                                dc_level11=handles.Array_PSeq{helper_scan,aux}.Channels(27).FreqmodQ;
                                freq11=round2(1/sweep_time11,0.1);
                                rigol_on11=handles.Array_PSeq{helper_scan,aux}.Channels(27).Amplitude;
                                rigol11_match=handles.Array_PSeq{helper_scan,aux}.Channels(27).FreqmodI;
                                
                                if rigol11_match
                                if rigol_on11
                                %Fitting result of Freq-Volt curve
                                %Freq=A+B*Volt
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(27).Ampmod)
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(27).Ampmod;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(27).Phasemod;
                                end
                                A2=1.639558; B2=0.108647;
%                                 A2=2.45; B2=0.15;
                                [vco_range,vco_volt]=spike_matching_func(obj.pw7,obj.arb11,3,8,bw_center-bw_range/2,bw_center+bw_range/2,A2,B2);
                                dc_level11=vco_volt;
                                Vpp11=vco_range;
                                end
                                end
                                % freq=sweep_time;
                                obj.pw7.PS_CurrSet(1);
                                obj.pw7.PS_VoltSet(dc_level11);
                                obj.pw7.PS_OUTOn();
                                
                                obj.arb11.ise_mode(freq11,Vpp11,0,Symmetry11);
                                obj.arb11.set_burst(phase11);
                                %%%%%%%%%%%%%%%
                                %obj.arb2.set_burst_cyc(phase,n_cyc);
                                % Set phase cycle
                                
                                
                                pause(0.2);
                                obj.arb11.MW_RFOn();
                                if ~rigol_on11
                                    obj.arb11.MW_RFOff();
                                    pause(0.2);
                                    obj.pw7.PS_OUTOff();
                                end
                                
                            end   
                            
                            %% TURN OFF ALL DEVICES
                               spike_turn_off_devices_8VCOs(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.pw5,obj.pw6,obj.pw7,obj.arb1,obj.arb2,obj.arb3,obj.arb4,obj.arb9,obj.arb10,obj.arb11,obj.arb12);
                               pause(0.2);
                             %% Rigol ARB arb12
                            
                            if handles.Array_PSeq{1}.Channels(28).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                %
                                obj.arb12.MW_RFOn();
                                %arb2
                                Vpp12=handles.Array_PSeq{helper_scan,aux}.Channels(28).Frequency;
                                phase12=handles.Array_PSeq{helper_scan,aux}.Channels(28).Phase;
                                sweep_time12=handles.Array_PSeq{helper_scan,aux}.Channels(28).AmpIQ;
                                Symmetry12=handles.Array_PSeq{helper_scan,aux}.Channels(28).FreqIQ;
                                dc_level12=handles.Array_PSeq{helper_scan,aux}.Channels(28).FreqmodQ;
                                freq12=round2(1/sweep_time12,0.1);
                                rigol_on12=handles.Array_PSeq{helper_scan,aux}.Channels(28).Amplitude;
                                rigol12_match=handles.Array_PSeq{helper_scan,aux}.Channels(28).FreqmodI;
                                
                                if rigol12_match
                                if rigol_on12
                                %Fitting result of Freq-Volt curve
                                %Freq=A+B*Volt
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(28).Ampmod)
                                bw_range=handles.Array_PSeq{helper_scan,aux}.Channels(28).Ampmod;
                                bw_center=handles.Array_PSeq{helper_scan,aux}.Channels(28).Phasemod;
                                end
                                A2=1.563805; B2=0.112468;
%                                 A2=2.45; B2=0.15;
                                [vco_range,vco_volt]=spike_matching_func(obj.pw8,obj.arb12,3,8,bw_center-bw_range/2,bw_center+bw_range/2,A2,B2);
                                dc_level12=vco_volt;
                                Vpp12=vco_range;
                                end
                                end
                                % freq=sweep_time;
% % %                                 obj.pw8.PS_CurrSet(1);
% % %                                 obj.pw8.PS_VoltSet(dc_level12);
% % %                                 obj.pw8.PS_OUTOn();
                                
                                obj.arb12.ise_mode(freq12,Vpp12,0,Symmetry12);
                                obj.arb12.set_burst(phase12);
                                %%%%%%%%%%%%%%%
                                %obj.arb2.set_burst_cyc(phase,n_cyc);
                                % Set phase cycle
                                
                                
                                pause(0.2);
                                obj.arb12.MW_RFOn();
                                if ~rigol_on12
                                    obj.arb12.MW_RFOff();
                                    pause(0.2);
%                                     obj.pw8.PS_OUTOff();
                                end
                                
                            end   
                           
                            %% Turn on devices
                           %spike_turn_on_devices_8VCOs(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.pw5,obj.pw6,obj.pw7,obj.pw8,obj.arb1,obj.arb2,obj.arb3,obj.arb4,obj.arb9,obj.arb10,obj.arb11,obj.arb12,agilent_on,rigol_on2,rigol_on3,rigol_on4,rigol_on9,rigol_on10,rigol_on11,rigol_on12);
                           %spike_turn_on_devices_4VCOs(obj.pw1,obj.pw2,obj.pw3,obj.pw4,obj.arb1,obj.arb2,obj.arb3,obj.arb4,agilent_on,rigol_on2,rigol_on3,rigol_on4)
                            end
                            
                            
%                             if handles.Array_PSeq{1}.Channels(21).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                                 maxV = handles.Array_PSeq{helper_scan,aux}.Channels(21).Frequency;
%                                 minV = handles.Array_PSeq{helper_scan,aux}.Channels(21).Phase;
%                                 period = handles.Array_PSeq{helper_scan,aux}.Channels(21).AmpIQ;
%                                 symmetry = handles.Array_PSeq{helper_scan,aux}.Channels(21).FreqIQ;
%                                 maxSamplingRate = 250000;
%                                 numSamples = maxSamplingRate*period;
%                                 
%                                 [status,~,  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles] = ...
%                                     calllib(handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxCreateTask','NIDAQTask',  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles);
%                                 % create an analog out voltage channel
%                                 [status] = calllib(  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxCreateAOVoltageChan',  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles,'/Dev1/ao0','MyAO',...
%                                     -10, 10,handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.DAQmx_Val_Volts ,[]);
%                                 
%                                 % Error Check
%                                 handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.CheckErrorStatus(status);
%                                 
%                                 % set regen mode to continuous
%                                 [status] = ...
%                                     calllib(handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxSetWriteRegenMode',handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles,handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.DAQmx_Val_AllowRegen);
%                                 
%                                 % Error Check
%                                 handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.CheckErrorStatus(status);
%                                 
%                                 % set sample clock rate
%                                 [status] = ...
%                                     calllib(  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxCfgSampClkTiming',...
%                                     handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles,[], maxSamplingRate,   handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.DAQmx_Val_Rising,   handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.DAQmx_Val_ContSamps, maxSamplingRate);
%                                 
%                                 % Error Check
%                                 handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.CheckErrorStatus(status);
%                                 
%                                 % read actual sample clock rate
%                                 [status] = ...
%                                     calllib(  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxGetSampClkRate',  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles, 1);
%                                 
%                                 % Error Check
%                                 handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.CheckErrorStatus(status);
%                                 
%                                 
%                                 % write an arbitrary voltage to the task
%                                 AutoStart = 1;
%                                 DefaultTimeOut = 10; %seconds
%                                 
%                                 data = [linspace(minV, maxV, (numSamples*(1-symmetry/100))), linspace(maxV, minV, numSamples-(numSamples*(1-symmetry/100)))];
%                                 [status] = calllib(  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxWriteAnalogF64',...
%                                     handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles,numSamples, AutoStart, DefaultTimeOut,   handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.DAQmx_Val_GroupByChannel, data,[], []);
%                                 %
%                                 %                                               % stop the task
%                                 %                                               [status]=calllib(  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxStopTask',  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles);
%                                 %
%                                 %                                               % Error Check
%                                 %                                                 handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.CheckErrorStatus(status);
%                                 %
%                                 %                                               % clear the task
%                                 %                                               [status]=calllib(  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxClearTask',  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles);
%                                 
%                             end
                            
                            
                            
%                             if handles.Array_PSeq{1}.Channels(24).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                             str11=[datestr(now,1) '-' num2str(hour(now)) '-' num2str(minute(now)) '-' num2str(second(now))];
%                             fp1=fopen(['D:\QEG2\ShuttleTime_Log\' str11 '-ground-T1pos.txt'],'wt');
%                             fp2=fopen(['D:\QEG2\ShuttleTime_Log\' str11 '-T1pos-coil.txt'],'wt');
%                             fp3=fopen(['D:\QEG2\ShuttleTime_Log\' str11 '-coil-ground.txt'],'wt');
% %                             else 
% %                             str11=[datestr(now,1) '-' num2str(hour(now)) '-' num2str(minute(now)) '-' num2str(second(now))];
% %                             fp1=fopen(['D:\QEG2\ShuttleTime_Log\3\' str11 '-ground_to_top.txt'],'wt');
% %                             fp2=fopen(['D:\QEG2\ShuttleTime_Log\3\' str11 '-top_to_ground.txt'],'wt');
%                             end
                            
                            %Loop over repitions
                            for rep_count=1:1:Repetitions
                                disp(['... Running repitition number:' num2str(rep_count)])
                                %pause(rep_count*2);
                                pause(3);
                                % Read from ACS software travelling time
                                % (ground->T1pos)(T1pos->coil)(coil->ground)
%                                 if handles.Array_PSeq{1}.Channels(24).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                                 T_inter1=obj.com.ReadVariable('T_inter1', obj.com.ACSC_NONE);
%                                 T_inter2=obj.com.ReadVariable('T_inter2', obj.com.ACSC_NONE);
%                                 T_inter3=obj.com.ReadVariable('T_inter3', obj.com.ACSC_NONE);
%                                 if T_inter1~=0
%                                     fprintf(fp1,'%d ',T_inter1);
%                                 end
%                                 if T_inter2~=0
%                                     fprintf(fp2,'%d ',T_inter2);
%                                 end
%                                 if T_inter3~=0
%                                     fprintf(fp3,'%d ',T_inter3);
%                                 end
% %                                 else
% %                                     T_inter1=obj.com.ReadVariable('T_inter1', obj.com.ACSC_NONE);
% %                                     T_inter2=obj.com.ReadVariable('T_inter2', obj.com.ACSC_NONE);
% %                                 
% %                                   if T_inter1~=0
% %                                     fprintf(fp1,'%d ',T_inter1);
% %                                   end
% %                                   if T_inter2~=0
% %                                     fprintf(fp2,'%d ',T_inter2);
% %                                   end
%                                 
%                                 end
                                %stopwatch(1);
                            if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted==1
                                
                               obj.com.StopBuffer(1); obj.com.StopBuffer(3);
                                obj.com.KillAll();
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                               
                                %obj.mw.MW_Close();
                                break;
                            else 
%                                 if aux>1 && rep_count>1
%                                     pause(1); %recycle delay
%                                 end
                           %% Initialize acutator position for very first motion
                           if handles.Array_PSeq{1}.Channels(12).Enable && rep_count ==1 && aux==1 && ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency)
                                start_pos=obj.com.GetFPosition(obj.com.ACSC_AXIS_0);
                                 Position=handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency;
                                 obj.com.SetVelocity(obj.com.ACSC_AXIS_0,50);
                                 obj.com.SetAcceleration(obj.com.ACSC_AXIS_0,500);
                                 obj.com.SetDeceleration(obj.com.ACSC_AXIS_0,500);
                                 obj.com.SetJerk(obj.com.ACSC_AXIS_0,5000);
                                 
                                 obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0, -Position); %MOVE
                                 obj.com.Go(obj.com.ACSC_AXIS_0);
                                 displacement=abs(abs(start_pos)-abs(Position));
                                 if displacement>2
                                 obj.com.WaitMotionEnd (obj.com.ACSC_AXIS_0, 1000*10*displacement/50);
                                 else
                                   %obj.com.WaitMotionEnd (obj.com.ACSC_AXIS_0, 5000);  
                                 end
                           end
                               
                                
                            %%% SET actuator position
                            %Actuator wait time and pos for T1(B) experiments
                            if handles.Array_PSeq{1}.Channels(24).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                
                                waitpos = handles.Array_PSeq{helper_scan,aux}.Channels(24).Frequency;
                                postime = handles.Array_PSeq{helper_scan,aux}.Channels(24).Phase;
                           
                            end
                            
                            if handles.Array_PSeq{1}.Channels(12).Enable
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency)
                                    Position=handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency;
                                    Velocity=handles.Array_PSeq{helper_scan,aux}.Channels(12).Amplitude;
                                    Accn=handles.Array_PSeq{helper_scan,aux}.Channels(12).Phase;
                                    Jerk=handles.Array_PSeq{helper_scan,aux}.Channels(12).AmpIQ;
                                    c_position=handles.Array_PSeq{helper_scan,aux}.Channels(12).FreqIQ;
                                    Wait_time=handles.Array_PSeq{helper_scan,aux}.Channels(12).FreqmodQ;
                                    tt2=handles.Array_PSeq{helper_scan,aux}.Channels(10).Frequency;
                                    
                                    %% Only used in 2 shuttles
                                    if handles.Array_PSeq{1}.Channels(8).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                    loop_time=handles.Array_PSeq{helper_scan,aux}.Channels(10).Amplitude;
                                    top_time=tt2;
                                    end
                                    
                                    %% Used for acquistion delay
                                    if handles.Array_PSeq{1}.Channels(9).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                    acq_time=handles.Array_PSeq{helper_scan,aux}.Channels(9).Frequency;
                                    end
                                    
                                    obj.com.SetVelocity(obj.com.ACSC_AXIS_0,Velocity);
                                    obj.com.SetAcceleration(obj.com.ACSC_AXIS_0,Accn);
                                    obj.com.SetDeceleration(obj.com.ACSC_AXIS_0,Accn);
                                    obj.com.SetJerk(obj.com.ACSC_AXIS_0,Jerk);
                                    
                                    %this line for having sample wait at
                                    %bottom position before moving up
%                                    obj.com.WriteVariable(Wait_time*1e3+tt2, 'V1', obj.com.ACSC_NONE);%need to do 1e3 because ACS times are in ms
                                    %normal 
                                   obj.com.WriteVariable(Wait_time*1e3, 'V1', obj.com.ACSC_NONE); %need to do 1e3 because ACS times are in ms
                                   obj.com.WriteVariable(-Position, 'V0', obj.com.ACSC_NONE);
                                   
                                   if handles.Array_PSeq{1}.Channels(8).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                     obj.com.WriteVariable(top_time*1e3, 'V91', obj.com.ACSC_NONE); %need to do 1e3 because ACS times are in ms
                                     obj.com.WriteVariable(loop_time*1e3, 'V92', obj.com.ACSC_NONE); %need to do 1e3 because ACS times are in ms
                                    end
                                    
                                    %top position after moving up
                                    %obj.com.WriteVariable(tt2, 'V91', obj.com.ACSC_NONE);
                                    

                                   
                                    %For T1 time experiments only
%                                     if handles.Array_PSeq{1}.Channels(24).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                                         obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0,-waitpos);   %go up to coil position %wait position instead?
%                                         obj.com.WriteVariable(postime*1e3,'V2', obj.com.ACSC_NONE);
%                                         obj.com.RunBuffer(3); 


                                   % For 2 shuttles only                                
                                    if handles.Array_PSeq{1}.Channels(8).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                        obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0,-c_position);   %go up to coil position
                                        obj.com.RunBuffer(5); 
                                    % For T1(B) experiment
                                    elseif handles.Array_PSeq{1}.Channels(24).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                        obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0,-waitpos);   %go up to coil position %wait position instead?
                                        obj.com.WriteVariable(postime*1e3,'V2', obj.com.ACSC_NONE);
                                        obj.com.RunBuffer(3); 
%                                    % For Pyruvic Acid Sample, UNCOMMENT
%                                     elseif handles.Array_PSeq{1}.Channels(9).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%             
%                                         obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0,-c_position);
%                                         %go to wait position
% %                                         obj.com.WriteVariable(postime*1e3,'V1', obj.com.ACSC_NONE);
%                                         obj.com.RunBuffer(2);

                                    % For acq delay experiments
                                    elseif handles.Array_PSeq{1}.Channels(9).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                        obj.com.WriteVariable(acq_time*1e3,'V2', obj.com.ACSC_NONE);
                                        obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0,-c_position);   %go up to coil position
                                        obj.com.RunBuffer(6);
                                    else
                                        obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0,-c_position);   %go up to coil position
                                        obj.com.RunBuffer(1);
                                    end
                            end
                         end
                            
                            
                            %%%% Main sequence                  
                            if ~err & ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                [stPB,durPB,err] = obj.ListOfStatesAndDurationsPB(handles.Array_PSeq{helper_scan,aux},handles);
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.sendSequence(stPB,durPB,1);
                                %%%%%%%%%%% add for new PB  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                               % handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart();
                            end
                            
                            
                            if err
                                handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
                                break;
                            end
                            
                            if err_latency==1
                               break;
                            end
                            
                            
                            % END Load Sequence %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                          
                            
                            % Experiment routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted==1
                               obj.com.StopBuffer(1); obj.com.StopBuffer(3);
                     
                                obj.com.KillAll();
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%% add for new PB
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                                break;
                            else %If not aborted
%                                 clear odnmr_data1;
%                                 if rep_count==1nt=1
%                                     clear odnmr_data;
%                                     odnmr_data = NaN*ones(1,Repetitions);
%                                 end
                                
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart(); %will fire one single sequence Repetitions number of times
                                %handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();

                                %%%% NO NEED PAUSE FOR NEW PB %%%%%%%%%%%%
                                if handles.Array_PSeq{1}.Channels(12).Enable % For motion
                                    Position=handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency;
                                    Velocity=handles.Array_PSeq{helper_scan,aux}.Channels(12).Amplitude;
                                    c_position=handles.Array_PSeq{helper_scan,aux}.Channels(12).FreqIQ;
                                    Wait_time=handles.Array_PSeq{helper_scan,aux}.Channels(12).FreqmodQ;
                                   % pause(1.05*sum(durPB)+2*abs(abs(Position)-abs(c_position))/Velocity+Wait_time+1); %3 sec between reps
                                    pause(1.05*sum(durPB)+2*abs(abs(Position)-abs(c_position))/Velocity+3+tt2/1000); %3 sec between reps
                               
                                
                                elseif handles.Array_PSeq{1}.Channels(16).Enable %for odmr 
                                    %handles.ExperimentFunctions.mw.AM100();
                                    %%%%%%%%%%%%% Move to the Position
                                    
                                    [y, m, d, h, mn, t1] = datevec(now);                                  
                                    for j1=1:floor(sum(durPB)/25e-3)
                                    odnmr_data1(j1)=handles.ExperimentFunctions.gpib_LockInAmp.SigRead();
                                    end
                                    [y, m, d, h, mn, t2] = datevec(now);                                    
                                    %pause(abs(1.1*sum(durPB)-abs(t2-t1))); 
                                    wait_time=sum(durPB)-abs(t2-t1);
                                    pause(round2(wait_time,0.1)+0.1);                                   
                                    %time_read(rep_count) = abs(t2-t1);
                                else
                                     pause(abs(1.1*sum(durPB)));
                                end
                                
                                
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%important%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 waitfor(handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop())
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                 
                            end
                       
                            if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted==1
                                obj.com.StopBuffer(1); obj.com.StopBuffer(3);
                                 obj.com.KillAll();
                                 handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
                                 handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                                 break;
                            end                            
                        end
                        if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted==1
                           obj.com.StopBuffer(1); obj.com.StopBuffer(3);
                            obj.com.KillAll();
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                            break;
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                      %  stopwatch(0);
                      % obj.mw.MW_RFOff();
                      %obj.arb4.MW_RFOff();
                      %pause(waittime/1000);   %bring this back if you want
                      %to do normal T1 exp
                        end %%%End Rep
%                             if handles.Array_PSeq{1}.Channels(24).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                             fclose(fp1);
%                             fclose(fp2);
%                             fclose(fp3);
% %                             else
% %                             fclose(fp1);
% %                             fclose(fp2);
%                             end
                        
                    %    if handles.Array_PSeq{1}.Channels(16).Enable
                         %   obj.mw.MW_RFOff();
                            %handles.ExperimentFunctions.mw.AM0();
%                         odnmr_data(rep_count)=mean(odnmr_data1,2);
%                         odnmr_rawdata(avg_count,aux)=mean(odnmr_data,2); %mean over reps                         Number_nnan=find(~isnan(odnmr_rawdata));
%                         mean_odmr_data=nanmean(odnmr_rawdata,1);
%                         handles.ExperimentFunctions.AvgData{1} = mean_odmr_data;
%                         if aux==1
%                         obj.PinesDataPlot(handles,1);
%                         else
%                             obj.PinesDataPlot(handles,0);
%                         end
                       % end
                        
                        if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted==1
                           obj.com.StopBuffer(1); obj.com.StopBuffer(3);
                            obj.com.KillAll();
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                            break;
                        end
                        end
                        
%                         if handles.Array_PSeq{1}.Channels(21).Enable && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                             
%                             % stop the task
%                             [status]=calllib(  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxStopTask',  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles);
%                             
%                             % Error Check
%                             handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.CheckErrorStatus(status);
%                             
%                             % clear the task
%                             [status]=calllib(  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.LibraryName,'DAQmxClearTask',  handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.TaskHandles);
%                             
%                         end
%                         
                     %vp
                     
                     if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted~=1
                         
                         disp(['Wait time for Experiment No.' num2str(aux) ': ' num2str(Wait_time)]);
                         %pause(300);
                     end
                     
                     
                     %% Saving log of dc_level and Vpp and freq range
                  
%                      [myyr, mymonth, mydy, myhr, mymin, mysecond] = datevec(now);
%                      mfilename=sprintf(', Time:%d-%02d-%02d_%02d.%02d.%02d',myyr, mymonth, mydy, myhr, mymin, round(mysecond));
%                      fprintf(fmatch,'%d',aux);
%                      if agilent_on
%                      fprintf(fmatch,', %f, %f',dc_level,Vpp);
%                      else
%                      fprintf(fmatch,', , ');
%                      end
%                      if rigol_on2
%                      fprintf(fmatch,', %f, %f',dc_level2,Vpp2);
%                      else
%                      fprintf(fmatch,', , ');
%                      end
%                      if rigol_on3
%                      fprintf(fmatch,', %f, %f',dc_level3,Vpp3);
%                      else
%                      fprintf(fmatch,', , ');
%                      end
%                      if rigol_on4
%                      fprintf(fmatch,', %f, %f',dc_level4,Vpp4); 
%                      else
%                      fprintf(fmatch,', , ');
%                      end
%                      if rigol_on9
%                      fprintf(fmatch,', %f, %f',dc_level9,Vpp9); 
%                      else
%                      fprintf(fmatch,', , ');
%                      end
%                      if rigol_on10
%                      fprintf(fmatch,', %f, %f',dc_level10,Vpp10); 
%                      else
%                      fprintf(fmatch,', , ');
%                      end
%                      if rigol_on11
%                      fprintf(fmatch,', %f, %f',dc_level11,Vpp11); 
%                      else
%                      fprintf(fmatch,', , ');
%                      end
%                      if rigol_on12
%                      fprintf(fmatch,', %f, %f',dc_level12,Vpp12); 
%                      else
%                      fprintf(fmatch,', , ');
%                      end
%                      fprintf(fmatch,[mfilename, '\n']);
                     %%
                  
                                        
                     email_recent;  
                    pause(30);
                                          
                    end %END loop over first scan dimension end aux
                    
                    %% Close matching saving file
%                       fclose(fmatch);
                 end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             end % end loop Averages
%              obj.mw.MW_RFOff();
Close_spike();

%         % update average


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Saving result and finishing
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
       
            
%               if handles.Array_PSeq{1}.Channels(16).Enable && ~err && ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                 handles.ExperimentalScan.ExperimentData = handles.ExperimentFunctions.AvgData;
% %                 handles.ExperimentalScan.ExperimentDataEachAvg = odnmr_rawdata;
% %                 handles.ExperimentalScan.ExperimentDataErrorEachAvg = ErrorEachAvg;
%                 obj.SaveExp(handles);
%                 obj.UpdateExpScanList(handles);
%               end
            
                 toc;
            
            email_recent;
                 
            profile off
            %obj.mw.MW_Close();
            handles.ExperimentFinished=1;
            
            %pause(30);
       
        end
                 
        function AbortRun(obj,handles)
            
            obj.com.KillAll();
           obj.com.StopBuffer(1); obj.com.StopBuffer(3);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();

            
            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
            handles.Tracker.hasAborted=1;
            
        end
        
        %%%%% Sequencing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
       
        function [err] = LoadSequenceToExperimentPB(obj,PS,rep,handles)
            
            [stPB,durPB,err] = obj.ListOfStatesAndDurationsPB(PS,handles);
            if ~err
                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.sendSequence(stPB,durPB,rep);
            else
                return;
            end
            
        end
       
        %%%%% Results handling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function UpdateAvgDataPlot(obj,handles,is_first)
            
            cla(handles.axes_AvgData);
            colors = ['k' 'r' 'b' 'g' 'm' 'y']; % enough for 6 rises of SPD Acq
             if isfield(handles,'scan_nonlinear') && handles.scan_nonlinear==1
                x=handles.nonlinear_data.x;
            else    
                x = linspace(handles.ExperimentalScan.vary_begin(1),handles.ExperimentalScan.vary_end(1),handles.ExperimentalScan.vary_points(1));
             end
            
            for j=1:1:length(obj.AvgData)
                y = obj.AvgData{j};
                hold(handles.axes_AvgData,'on');
                line(j)=plot(x,y,['.-' colors(j)],'Parent',handles.axes_AvgData,'MarkerSize',15,'LineWidth',0.5);
                hold(handles.axes_AvgData,'on');
                plot(x,smooth(y),['-' colors(j)],'Parent',handles.axes_AvgData,'LineWidth',1.5);
                
                title(handles.axes_AvgData,datestr(now,'yyyy-mm-dd-HHMMSS'));
                if get(handles.checkbox_errorbar,'Value')
                    errorbar(x, y, obj.Std_dev{j}, '.','Parent',handles.axes_AvgData)
                end
            end
             grid(handles.axes_AvgData, 'on');
            hold(handles.axes_AvgData,'off');
            
            if is_first == 1
                
                a = {'Rise 1', 'Rise 2', 'Rise 3', 'Rise 4', 'Rise 5', 'Rise 6'};
                legend(handles.axes_AvgData,line,a(1:1:length(obj.AvgData)));
                xlabel(handles.axes_AvgData,handles.ExperimentalScan.vary_prop{1});
                ylabel(handles.axes_AvgData,'kcps');
                title(handles.axes_AvgData,datestr(now,'yyyy-mm-dd-HHMMSS'));
            end
            grid(handles.axes_AvgData, 'on');
            drawnow();
            
        end
        
        
         function PinesDataPlot(obj,handles,is_first)
            
            cla(handles.axes_AvgData); %clear axis
            colors = ['k' 'r' 'b' 'g' 'm' 'y']; % enough for 6 rises of SPD Acq
            x = linspace(handles.ExperimentalScan.vary_begin(1),handles.ExperimentalScan.vary_end(1),handles.ExperimentalScan.vary_points(1));
            set(handles.axes_AvgData,'xlim',[min(x) max(x)]);
           diff_x=diff(x);
           delta_x=diff_x(1);
            for j=1:1:length(obj.AvgData)
                y = obj.AvgData{j};
                hold(handles.axes_AvgData,'on');
                line(1)=plot(x(1:2:end)+delta_x,y(1:2:end),['.-' colors(1)],'Parent',handles.axes_AvgData,'MarkerSize',15,'LineWidth',0.5);
                line(2)=plot(x(2:2:end),y(2:2:end),['.-' colors(2)],'Parent',handles.axes_AvgData,'MarkerSize',15,'LineWidth',0.5);
            end
             grid(handles.axes_AvgData, 'on');
            hold(handles.axes_AvgData,'off');
            
            if is_first == 1
                
                a = {'Rise 1', 'Rise 2', 'Rise 3', 'Rise 4', 'Rise 5', 'Rise 6'};
                legend(handles.axes_AvgData,line,a(1:1:length(obj.AvgData)));
                xlabel(handles.axes_AvgData,handles.ExperimentalScan.vary_prop{1});
                ylabel(handles.axes_AvgData,'kcps');
                title(handles.axes_AvgData,datestr(now,'yyyy-mm-dd-HHMMSS'));
            end
            grid(handles.axes_AvgData, 'on');
            drawnow();
            
        end
        
        
        function UpdateSingleDataPlot(obj,handles,is_first)
            
            cla(handles.axes_RawData);
            colors = ['k' 'r' 'b' 'g' 'm' 'y']; % enough for 6 rises of SPD Acq
            if isfield(handles,'scan_nonlinear') && handles.scan_nonlinear==1
                x=handles.nonlinear_data.x;
            else    
                x = linspace(handles.ExperimentalScan.vary_begin(1),handles.ExperimentalScan.vary_end(1),handles.ExperimentalScan.vary_points(1));
            end
            for j=1:1:length(obj.RawData)
                y = obj.RawData{j};
                hold(handles.axes_RawData,'on');
                plot(x,y,['.-' colors(j)],'Parent',handles.axes_RawData);
                title(handles.axes_AvgData,datestr(now,'yyyy-mm-dd-HHMMSS'));
            end
            hold(handles.axes_RawData,'off');
            
            if is_first == 1
                a = {'Rise 1', 'Rise 2', 'Rise 3', 'Rise 4', 'Rise 5', 'Rise 6'};
                legend(handles.axes_RawData,a(1:1:length(obj.RawData)));
                xlabel(handles.axes_AvgData,{handles.ExperimentalScan.vary_prop{1}});
                ylabel(handles.axes_AvgData,'kcps');
                title(handles.axes_AvgData,datestr(now,'yyyy-mm-dd-HHMMSS'));
            end
            grid(handles.axes_AvgData,'on');
            drawnow();
            
        end
        
        function LoadExpFromScan(obj,handles)
               
            
            
            set(handles.sliderExpScan,'Visible','off');
            set(handles.text_vary2_param,'Visible','off');
            set(handles.slider_each_avg,'Visible','off');
            set(handles.avg_nb,'Visible','off');    
            exps = get(handles.popup_experiments,'String');
            selectedExp= exps{get(handles.popup_experiments,'Value')};
            
            if length(exps)>1
               
                fp = getpref('nv','SavedExpDirectory');
                if strcmp(selectedExp,'Current Experiment')
                    selectedExp= exps{get(handles.popup_experiments,'Value')+1}; %loads the first exp in the list, that corresponds to the displayed 'Current Experiment'
                end
                
                SavedExp = load(fullfile(fp,selectedExp));
                
                
                handles.ExperimentalScanDisplayed = SavedExp.Scan;
                set(handles.edit_NoteExp, 'String', handles.ExperimentalScanDisplayed.Notes)
                set(handles.edit_NoteExp,'Enable','on');
                set(handles.button_NoteExp,'Enable','on');
                
                if length(handles.ExperimentalScanDisplayed.vary_points) == 2 %2d scan
                    set(handles.sliderExpScan,'Visible','on');
                    set(handles.text_vary2_param,'Visible','on');
                    set(handles.sliderExpScan,'Max', handles.ExperimentalScanDisplayed.vary_points(2));
                    set(handles.sliderExpScan,'Min', 1);
                    set(handles.sliderExpScan,'Value', 1);
                    set(handles.text_vary2_param,'String',sprintf('%s = %s',handles.ExperimentalScanDisplayed.vary_prop{2},num2str(handles.ExperimentalScanDisplayed.vary_begin(2))));
                end
                
                if ~isempty(handles.ExperimentalScanDisplayed.scan_nonlinear) 
                    if handles.ExperimentalScanDisplayed.scan_nonlinear~=0
                    handles.scan_nonlinear=handles.ExperimentalScanDisplayed.scan_nonlinear;
                    handles.nonlinear_data=handles.ExperimentalScanDisplayed.nonlinear_data;
                    set(handles.checkbox18,'Value',1);
                    else
                        set(handles.checkbox18,'Value',0);
                    
                    end
                
                    
                end
                
                
                set(handles.uipanel90,'Visible','on');
                
                set(handles.text_scan_avg, 'String', handles.ExperimentalScanDisplayed.Averages);
                set(handles.text_scan_reps, 'String', handles.ExperimentalScanDisplayed.Repetitions);
                set(handles.text_sequence,'String',handles.ExperimentalScanDisplayed.Sequence);
                set(handles.displayed_power,'String',sprintf('Power = %0.3f +- %0.3f mW',handles.ExperimentalScanDisplayed.Laserpower(1),handles.ExperimentalScanDisplayed.Laserpower(2)));
                set(handles.text_name_displayed_seq,'String',handles.ExperimentalScanDisplayed.SequenceName);
                
               
                obj.ExpPlot(handles,handles.ExperimentalScanDisplayed,1);
                obj.EachAvgPlot(handles,handles.ExperimentalScanDisplayed,1,1);
                
                
                %load veriable data to table_show_float
                a = size(handles.ExperimentalScanDisplayed.Variable_values);
                tabledata = cell(a(2), 6);
                
                for p=1:1:a(2)  %number of lines in matrix
                    tabledata{p,1} = handles.ExperimentalScanDisplayed.Variable_values{p}.name;
                    
                    %needs something here to display correctly
                    if length(handles.ExperimentalScanDisplayed.vary_prop) == 2
                        j_end = 2;
                    else
                        j_end = 1;
                    end
                    
                    
                    for j=1:1:j_end
                        if strcmp(handles.ExperimentalScanDisplayed.Variable_values{p}.name, handles.ExperimentalScanDisplayed.vary_prop{j})
                            tabledata{p,3} = true;
                            tabledata{p,4} = handles.ExperimentalScanDisplayed.vary_begin(j);
                            tabledata{p,5} = handles.ExperimentalScanDisplayed.vary_step_size(j);
                            tabledata{p,6} = handles.ExperimentalScanDisplayed.vary_end(j);
                        else
                            tabledata{p,2} = handles.ExperimentalScanDisplayed.Variable_values{p}.value;
                        end
                    end
                end
                
                set(handles.table_show_float,'data',tabledata);
                
                %load variable data to table_show_float
                a = size(handles.ExperimentalScanDisplayed.Bool_values);
                
                if a(2) ~= 0
                    tabledata = cell(a(2), 2);
                    for p=1:1:a(2)  %number of lines in matrix
                        tabledata{p,2} = handles.ExperimentalScanDisplayed.Bool_values{p}.name;
                        if handles.ExperimentalScanDisplayed.Bool_values{p}.value
                            tabledata{p,1} = true;
                        else
                            tabledata{p,1} = false;
                        end
                    end
                    
                    set(handles.table_show_bool,'data',tabledata);
                    
                end
                
                set(handles.button_NoteExp, 'Enable','on');
                set(handles.edit_NoteExp, 'Enable','on');
                
                %plot single averages
                if handles.ExperimentalScanDisplayed.Averages > 1
                set(handles.slider_each_avg,'Max', handles.ExperimentalScanDisplayed.Averages);
                set(handles.slider_each_avg,'Min', 1);
                set(handles.slider_each_avg,'Value', 1);
                set(handles.avg_nb,'String','1');
                set(handles.slider_each_avg,'Visible','on');
                set(handles.avg_nb,'Visible','on');    
                end
                
            
                % Update handles structure
                gobj = findall(0, 'Name', 'Experiment');
                guidata(gobj, handles);
                
            end
            
        end
        
    end
    
    methods (Static)
        
        function UpdateExpScanList(handles)
            
            fp = getpref('nv','SavedExpDirectory');
            files = dir(fp);
            
            datenums = [];
            found_filenames = {};
            % sort files by modifying date desc
            for k=1:length(files)
                % takes the date from the filename
                r = regexp(files(k).name, '(\d{4}-\d{2}-\d{2}-\d{6})','tokens');
                if ~isempty(r) %remove dirs '.' and '..', and other files
                    datenums(end+1) = datenum(r{1}, 'yyyy-mm-dd-HHMMSS');
                    found_filenames{end+1} = files(k).name;
                end
                
            end
            if ~isempty(datenums)
                [~,dind] = sort(datenums,'descend');
            end;
            
            fn{1} = 'Current Experiment';
            
            for k=1:length(datenums),
                
                
                fn{end+1} = found_filenames{dind(k)};
                
                
            end
            set(handles.popup_experiments,'String',fn);
            
            gobj = findall(0,'Name','Experiment');
            guidata(gobj,handles);
            
        end
        
        function SaveExp(handles)
            
            fp = getpref('nv','SavedExpDirectory');
            
            if length(handles.ExperimentalScan.vary_prop) == 2 %2d scan
                handles.num = 2;
                text = ['-vary-',handles.ExperimentalScan.vary_prop{1}, '-',handles.ExperimentalScan.vary_prop{2},'-'];
                
            else %1d scan
                handles.num = 1;
                text = ['-vary-' handles.ExperimentalScan.vary_prop{1} '-'];
            end
            
            a = datestr(now,'yyyy-mm-dd-HHMMSS');
            fn = [num2str(handles.num),'DExp-seq-' handles.ExperimentalScan.SequenceName(1:1:end-4),text,a];
            
            fullFN = fullfile(fp,fn);
            
            Scan = handles.ExperimentalScan;
            
            Scan.DateTime = a;
            
            if ~isempty(Scan.ExperimentData),
                save(fullFN,'Scan');
            else
                uiwait(warndlg({'No data found for current experiment. Saving aborted.'}));
                return;
            end
            
            %send_email(fn,'',[fullFN '.mat']);
            
            gobj = findall(0,'Name','Experiment');
            guidata(gobj,handles);
            handles = guidata(gobj);
            
        end
        
        function ExpPlot(handles,scan,sliderValue)
            
            cla(handles.axes_AvgData,'reset')
            colors = ['k' 'r' 'b' 'g' 'm' 'y']; % enough for 6 rises of SPD Acq
            if ~isempty(scan.scan_nonlinear) && scan.scan_nonlinear==1
                x=scan.nonlinear_data.x;
            else    
                x = linspace(scan.vary_begin(1),scan.vary_end(1),scan.vary_points(1));
            end
            %x = linspace(scan.vary_begin(1),scan.vary_end(1),scan.vary_points(1));
            for j=1:1:length(scan.ExperimentData{sliderValue})
                y = scan.ExperimentData{sliderValue}{j};
                %plot(x,y,['.-' colors(j)],'Parent',handles.axes_AvgData,'MarkerSize',15);
                line(j)=plot(x,y,['.-' colors(j)],'Parent',handles.axes_AvgData,'MarkerSize',15,'LineWidth',0.5);
                hold(handles.axes_AvgData,'on');
                plot(x,smooth(y),['-' colors(j)],'Parent',handles.axes_AvgData,'LineWidth',1.5);
                if get(handles.checkbox_errorbar, 'Value')
                    errorbar(x, y, scan.ExperimentDataError{sliderValue}{j}, '.','Parent',handles.axes_AvgData)
                end
            end
            hold(handles.axes_AvgData,'off');
            a = {'Rise 1', 'Rise 2', 'Rise 3', 'Rise 4', 'Rise 5', 'Rise 6'};
            legend(handles.axes_AvgData,line,a(1:1:length(scan.ExperimentData{sliderValue})));
            xlabel(handles.axes_AvgData,scan.vary_prop{1});
            ylabel(handles.axes_AvgData,'kcps');
            title(handles.axes_AvgData,scan.DateTime);
            grid(handles.axes_AvgData, 'on');
            drawnow();
        end
        
%         function ExpPlot_spectrum(handles,fidname,FTtype)
%             fname=fidname;
%             [y, SizeTD2, SizeTD1] = Qfidread(fname, 17000 ,1, 5, 1);
%             MatrixOut = matNMRFT1D(y, FTtype);
%             cla(handles.axes_AvgData,'reset')
%             %colors = ['k' 'r' 'b' 'g' 'm' 'y']; % enough for 6 rises of SPD Acq
%                 plot(abs(MatrixOut),['.-' 'b'],'Parent',handles.axes_AvgData,'MarkerSize',15,'LineWidth',0.5);
%                 hold(handles.axes_AvgData,'on');
%             hold(handles.axes_AvgData,'off');
%             xlabel(handles.axes_AvgData,'frequency');
%             ylabel(handles.axes_AvgData,'A');
%             title(handles.axes_AvgData,scan.DateTime);
%             grid(handles.axes_AvgData, 'on');
%             drawnow();
%              %plot(abs(MatrixOut));
%         end
        
        function EachAvgPlot(handles,scan,sliderValue,twodsliderValue)
            
            colors = ['k' 'r' 'b' 'g' 'm' 'y']; % enough for 6 rises of SPD Acq
             if ~isempty(scan.scan_nonlinear) && scan.scan_nonlinear==1
                x=scan.nonlinear_data.x; 
            else    
                x = linspace(scan.vary_begin(1),scan.vary_end(1),scan.vary_points(1));
            end
            %x = linspace(scan.vary_begin(1),scan.vary_end(1),scan.vary_points(1));
            for j=1:1:length(scan.ExperimentDataEachAvg{twodsliderValue}{sliderValue})
                y = scan.ExperimentDataEachAvg{twodsliderValue}{sliderValue}{j};
                plot(x,y,['.-' colors(j)],'Parent',handles.axes_RawData);
                hold(handles.axes_RawData,'on');
                 if get(handles.checkbox_errorbar_each_avg, 'Value')
                     errorbar(x, y, scan.ExperimentDataErrorEachAvg{twodsliderValue}{sliderValue}{j}, '.','Parent',handles.axes_RawData)
                 end
            end
            hold(handles.axes_RawData,'off');
            a = {'Rise 1', 'Rise 2', 'Rise 3', 'Rise 4', 'Rise 5', 'Rise 6'};
            legend(handles.axes_RawData,a(1:1:length(scan.ExperimentDataEachAvg{twodsliderValue}{sliderValue})));
            xlabel(handles.axes_RawData,scan.vary_prop{1});
            ylabel(handles.axes_RawData,'kcps');
            title(handles.axes_RawData,datestr(now,'yyyy-mm-dd-HHMMSS'));
            grid(handles.axes_RawData, 'on');
            drawnow();
        end
        
        
        
        function [IShape,AOMShape,MWShape,QShape,SPDShape,CShape,NShape,NullShape,err] = ListOfStatesAndDurationsAWG(PulseSequence,handles)
            
            err = 0;
            % This function takes the PulseSequence and transforms it into a format
            % that is readable by the AWG (exclusively)
            
            % get max and min time for this sequence
            mintime = PulseSequence.GetMinRiseTime();
            maxtime = PulseSequence.time_pointer;
            
            num_points = int64((maxtime-mintime)*handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate);
            
            NullShape = zeros(1,num_points);
            IShape = zeros(1,num_points);
            AOMShape = zeros(1,num_points);
            MWShape = zeros(1,num_points);
            QShape = zeros(1,num_points);
            SPDShape = zeros(1,num_points);
            CShape = zeros(1,num_points);
            NShape = zeros(1,num_points);
            
            %AWG states must be a multiple of the clock frequency
            for hlp=1:1:length(PulseSequence.Channels)
                if PulseSequence.Channels(hlp).Enable
                    
                    if ~isequal(mod(round(PulseSequence.Channels(hlp).RiseDurations*1e11),round(1e11/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate)),zeros(1,length(PulseSequence.Channels(hlp).RiseDurations)))
                        % without round won't work; multiplying by 1e11
                        err = 1;
                        uiwait(warndlg('Sequence durations not a multiple of AWG sample rate. Abort. (Or: you enabled a channel that you are not using)'));
                        return;
                    end
                end
            end
            
            if PulseSequence.Channels(1).Enable  %pulsed mode for laser
                
                for p=1:1:length(PulseSequence.Channels(1).RiseTimes)
                    AOMShape(int32(1+(PulseSequence.Channels(1).RiseTimes(p)+mintime)*handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate):1:int32((PulseSequence.Channels(1).RiseTimes(p)+mintime+PulseSequence.Channels(1).RiseDurations(p))*handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate)) = 1;
                end
            end
            
            if PulseSequence.Channels(2).Enable  %pulsed mode for mw
                
                for p=1:1:length(PulseSequence.Channels(2).RiseTimes)
                    MWShape(int32(1+(PulseSequence.Channels(2).RiseTimes(p)+mintime)*handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate):1:int32((PulseSequence.Channels(2).RiseTimes(p)+mintime+PulseSequence.Channels(2).RiseDurations(p))*handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate)) = 1;
                end
                
                n = round(100e9*(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate/2))/100e9:round(100e9*(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate))/100e9:round(100e9*((maxtime-mintime)-(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate/2)))/100e9;
                IShape =  sin(2*pi*PulseSequence.Channels(2).FreqIQ*n + PulseSequence.Channels(2).Phasemod).*PulseSequence.Channels(2).Ampmod + PulseSequence.Channels(2).FreqmodI;
                QShape =  cos(2*pi*PulseSequence.Channels(2).FreqIQ*n + PulseSequence.Channels(2).Phasemod).*PulseSequence.Channels(2).Ampmod + PulseSequence.Channels(2).FreqmodQ; %or sin(x + pi/2)
                
            end
            
            if PulseSequence.Channels(3).Enable  %pulsed mode for SPD
                
                for p=1:1:length(PulseSequence.Channels(3).RiseTimes)
                    SPDShape(int32(1+(PulseSequence.Channels(3).RiseTimes(p)+mintime)*handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate):1:int32((PulseSequence.Channels(3).RiseTimes(p)+mintime+PulseSequence.Channels(3).RiseDurations(p))*handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate)) = 1;
                end
                
            end
            
            if PulseSequence.Channels(4).Enable  %pulsed mode for C
                
                n = (1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate/2):(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate):((maxtime-mintime)-(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate/2));
                CShape = sin(2*pi*PulseSequence.Channels(4).Frequency*n + PulseSequence.Channels(4).Phasemod).*PulseSequence.Channels(4).Ampmod + PulseSequence.Channels(4).FreqmodI;
            end
            
            if PulseSequence.Channels(5).Enable %pulsed mode for N
                %Masashi commented 20130409;
                %n = (1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate/2):(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate):((maxtime-mintime)-(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate/2));
                n = round(100e9*(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate/2))/100e9:round(100e9*(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate))/100e9:round(100e9*((maxtime-mintime)-(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate/2)))/100e9;
                NShape = sin(2*pi*PulseSequence.Channels(5).Frequency*n + PulseSequence.Channels(5).Phasemod).*PulseSequence.Channels(5).Ampmod + PulseSequence.Channels(5).FreqmodI;
            end
            
            %Make sure first and last states of the array are 0, otherwise markers will be "on"
            %at undesirable places
            
            %put a zero-shape in the beginning and end
            additional_zeros = handles.ExperimentFunctions.delay_init_and_end_seq*handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate; %ALWAYS integer bc min sampl rate 1e7
            
            NullShape = [zeros(1,additional_zeros) NullShape zeros(1,additional_zeros)];
            IShape = [zeros(1,additional_zeros) IShape zeros(1,additional_zeros)];
            AOMShape =  [zeros(1,additional_zeros) AOMShape zeros(1,additional_zeros)];
            MWShape =  [zeros(1,additional_zeros) MWShape zeros(1,additional_zeros)];
            QShape =  [zeros(1,additional_zeros) QShape zeros(1,additional_zeros)];
            SPDShape =  [zeros(1,additional_zeros) SPDShape zeros(1,additional_zeros)];
            CShape =  [zeros(1,additional_zeros) CShape zeros(1,additional_zeros)];
            NShape = [zeros(1,additional_zeros) NShape zeros(1,additional_zeros)];
            
%             figure();
%             subplot(2,2,1);
%             plot(MWShape);
%             subplot(2,2,2);
%             plot(QShape);
%             subplot(2,2,3);
%             plot(CShape);
%             subplot(2,2,4);
%             plot(NShape);
        end
        
        function [statesPB,durationsPB,err] = ListOfStatesAndDurationsPB(PulseSequence,handles)
            
            err = 0;
            
            % This function takes the PulseSequence and transforms it into a format
            % that is readable by the Pulse Blaster. For the Pulse Blaster,
            % this format consists of the binary value representing the states of the four lines, plus
            % the duration of each state in s.
            
            %Start all channels at off
            %Everytime there is an event related to a channel, bitflip operation
            
            %initialize to sth
            Big_matrix_times = [];
            Big_matrix_indices = [];
            
            current_state = 0;
            
            for k=1:1:length(PulseSequence.Channels)
                
                if PulseSequence.Channels(k).Enable  %pulsed mode
                    
                    Final_times = PulseSequence.Channels(k).RiseTimes + PulseSequence.Channels(k).RiseDurations;
                    
                    Unsorted_times = [PulseSequence.Channels(k).RiseTimes Final_times];
                    %Times = [to^1, tf^1, to^2, tf^2, ... to^last, tf^last]
                    Times = sort(Unsorted_times);
                    Channel_ind = k*ones(1,length(Times));
                    
                    Big_matrix_times = [Big_matrix_times Times];
                    Big_matrix_indices = [Big_matrix_indices Channel_ind];
                    
                    
                    
                    %else, or off, does not need to do anything
                    
                end
                
            end
            
            % Treat PB data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [Sorted_big_matrix_times, Ind] = sort(Big_matrix_times);
            Sorted_big_matrix_indices = Big_matrix_indices(Ind);
            
            Sorted_list_states = [];
            
            for k=1:1:(length(Sorted_big_matrix_times)-1)
                
                new_state = SingleBitFlip(current_state, Sorted_big_matrix_indices(k));
                
                Sorted_list_states = [Sorted_list_states new_state];
                
                current_state = new_state;
                
            end
            
            Final_sorted_big_matrix_times = diff(Sorted_big_matrix_times);
            Final_sorted_list_states = Sorted_list_states;
            
            A = find(Final_sorted_big_matrix_times > 1e-12);    %~= 0 gives a numerical bug
            Final_sorted_list_states = Final_sorted_list_states(A);
            Final_sorted_big_matrix_times = Final_sorted_big_matrix_times(A);
            
            % first and last states are 0
            Final_sorted_big_matrix_times = [handles.ExperimentFunctions.delay_init_and_end_seq Final_sorted_big_matrix_times handles.ExperimentFunctions.delay_init_and_end_seq];
            Final_sorted_list_states = [0 Final_sorted_list_states 0];
            
            durationsPB = Final_sorted_big_matrix_times;
            statesPB = Final_sorted_list_states;
            
            %PB states must be a multiple of the clock frequency
            if ~isequal(mod(round(durationsPB*1e11),round(1e11/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate)),zeros(1,length(durationsPB)))
                % without round won't work; multiplying by 1e11 as in
                % send_sequence in pulse blaster class
                err = 1;
                uiwait(warndlg('Sequence durations not a multiple of Pulse Blaster sample rate. Abort.'));
                return;
            end
            
            %PB has a latency of 5 clock cycles;
            latency = 5*(1/handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate);
            if ~isempty(find(durationsPB<latency-10*eps, 1)) %10eps for numerical value
                %err = 1;
                err_latency=1
               % uiwait(warndlg('Pulse Blaster latency critera not met. Abort.'));
                return;
            end
            
            
            % END Treat PB data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
        end
        
        function TrackCenterPB(handles)
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StartProgramming();
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StopProgramming();
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart();
            handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
        end
        
        function TrackCenterAWG(handles)
            
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.writeToSocket('AWGCONTROL:RMODE CONTINUOUS');
            
            NullShape = zeros(6*1e4,1); %length here is arbitrary
            OnShape = [zeros(1,1)' ones(6*1e4-2,1)' zeros(1,1)']';
            
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.clear_waveforms();
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.create_waveform('POWMEAS',NullShape,OnShape,NullShape);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.setSourceWaveForm(1,'POWMEAS');
            
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SetChannelOn(1);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.AWGStart();
            go_on = 0;
            while ~go_on
                go_on = handles.Imaginghandles.ImagingFunctions.interfacePulseGen.writeReadToSocket('AWGControl:RSTate?');
            end
            
             handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
             
             handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SetChannelOff(1);
             handles.Imaginghandles.ImagingFunctions.interfacePulseGen.AWGStop();
        end
        
        function [power_array_in_V] = PowerMeasurementPB(handles)
            
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StartProgramming();
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_CONTINUE, 0, 750,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_BRANCH, 0, 150,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StopProgramming();
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart();
            [laser_power_in_V,std_laser_power_in_V,power_array_in_V] = handles.Imaginghandles.ImagingFunctions.MonitorPower();
            pause(1);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
            
            [laser_power,std_laser_power] = PhotodiodeConversionVtomW(laser_power_in_V,std_laser_power_in_V);
            set(handles.text_power,'String',sprintf('Power = %0.3f +- %0.3f mW',laser_power,std_laser_power));
            
        end
        
        function [power_array_in_V] = PowerMeasurementAWG(handles)
            
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.writeToSocket('AWGCONTROL:RMODE CONTINUOUS');
            
            NullShape = zeros(6*1e4,1); %length here is arbitrary
            OnShape = [zeros(1,1)' ones(6*1e4-2,1)' zeros(1,1)']';
            
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.clear_waveforms();
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.create_waveform('POWMEAS',NullShape,OnShape,NullShape);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.setSourceWaveForm(1,'POWMEAS');
            
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SetChannelOn(1);
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.AWGStart();
            PLO
            while ~go_on
                go_on = handles.Imaginghandles.ImagingFunctions.interfacePulseGen.writeReadToSocket('AWGControl:RSTate?');
            end
            
            [laser_power_in_V,std_laser_power_in_V,power_array_in_V] = handles.Imaginghandles.ImagingFunctions.MonitorPower();
            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SetChannelOff(1);
            
            [laser_power,std_laser_power] = PhotodiodeConversionVtomW(laser_power_in_V,std_laser_power_in_V);
            set(handles.text_power,'String',sprintf('Power = %0.3f +- %0.3f mW',laser_power,std_laser_power));
        end
        
        
        
       
    end
    
end