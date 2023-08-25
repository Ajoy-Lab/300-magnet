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
        
    end
    
    methods
        
        %%%%% Run experiment %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function RunExperiment(obj,handles)
           
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
            
            %here commented only for random noise exps
            cla(handles.axes_AvgData,'reset');
            cla(handles.axes_RawData,'reset');
            
%             obj.wf.open(); %OPEN THE windFreak
           
            % get number of sequence repetitions and averages
            % commented only for random  noise exp
            if get(handles.average_continuously,'Value')
                Averages = 1;
            else
                Averages = str2num(get(handles.edit_Averages,'String'));
            end

            Repetitions = str2num(get(handles.edit_Repetitions,'String'));
            handles.ExperimentalScan.Repetitions = Repetitions;
            
            % number of acquisition pulses in these pulse sequences
            number_acq = length(handles.Array_PSeq{1}.Channels(3).RiseTimes);
            for j=1:number_acq
            temp_data{j}=ones(1,handles.ExperimentalScan.vary_points(1))*NaN;
            end
            
            %initialization of Results cell
            Results_helper = mat2cell(zeros(1,handles.ExperimentalScan.vary_points(1)*number_acq),1,ones(number_acq,1)*handles.ExperimentalScan.vary_points(1));
            
            if length(handles.Var_to_be_varied) == 2
                for h=1:1:handles.ExperimentalScan.vary_points(2)
                    Results{h} = Results_helper;
                end
                scan2pts = handles.ExperimentalScan.vary_points(2);
            else
                Results{1} = Results_helper;
                scan2pts = 1;
            end
            
            %commented only for Random noise exp
            handles.kk = 1; %worst case picture
            
%             if ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
%                 %Initialize waitbar; 1.3 is measured approximate fudge factor
%                 %%%%%%%%%%%%%%%recalibrate this for AWG
%                 %tmax = handles.Array_PSeq{1}.GetMaxTime(); %only an estimate, take only first PSeq in array
%                  tmax = handles.Array_PSeq{1}.time_pointer; %only an estimate, take only first PSeq in array
%                 if handles.Imaginghandles.QEGhandles.pulse_mode == 1 || handles.Imaginghandles.QEGhandles.pulse_mode == 2 %use PB
%                     TotEstTime=1.3*tmax*handles.ExperimentalScan.vary_points*scan2pts*Repetitions*Averages;
%                 elseif  handles.Imaginghandles.QEGhandles.pulse_mode == 0 || handles.Imaginghandles.QEGhandles.pulse_mode == 3 %use AWG
%                     TotEstTime=1.5*tmax*handles.ExperimentalScan.vary_points*scan2pts*Repetitions*Averages;
%                     %RECALIBRATE
%                 end
%                 wbexp = waitbar(0,['Maximum expected experiment time: ',num2str(TotEstTime),'s']);
%                 obj.statuswbexp = 1;
%             end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Scan loop and plotting
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for helper_scan=1:1:scan2pts %loop over second scan dimension, if there is one
                
                if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                    set(handles.text_ExpStatus,'String',sprintf('Experiment Aborted, saved until average %d of scan %d', handles.kk-1,helper_scan-1));
                    break;
                end
                
                %commented only for random noise exp
                handles.kk = 1;
                cla(handles.axes_AvgData);
                colors = ['k' 'r' 'b' 'g' 'm' 'y']; % enough for 6 rises of SPD Acq
                if handles.scan_nonlinear==0
                x = linspace(handles.ExperimentalScan.vary_begin(1),handles.ExperimentalScan.vary_end(1),handles.ExperimentalScan.vary_points(1));
                else
                    x=handles.nonlinear_data.x;
                end
   
                % For phase lock
%                 if ~isempty(handles.Array_PSeq{helper_scan,1}.Channels(4).Phase)
%                     if ~isempty(handles.Array_PSeq{helper_scan,1}.Channels(4).Frequency)
%                         obj.interfaceSigGen2.Amplitude = handles.Array_PSeq{helper_scan,1}.Channels(4).Amplitude;
%                         obj.interfaceSigGen2.Frequency = handles.Array_PSeq{helper_scan,1}.Channels(4).Frequency;
%                         err = obj.interfaceSigGen2.SetAll();
%                     else
%                         obj.interfaceSigGen2.Amplitude = handles.Array_PSeq{helper_scan,1}.Channels(4).Amplitude;        
%                         err = obj.interfaceSigGen2.setAmplitude();
%                     end
%                 end
                
              % obj.interfaceSigGen2.setzeroPhase;
                
                while handles.kk <= Averages %loop over averages
                    
                  
                      
                    if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                        break;
                    end
                    %This "if" sentense added by Masashi 2013/01/08
                    if mod(handles.kk,str2double(get(handles.tracking_period,'String')))==0;
                        if get(handles.checkbox_tracking,'Value') && get(handles.button_track_per_avg,'Value')
                            
                            obj.TrackCenterPB(handles);
                            
                        end
                    end
                    
                    
                    if get(handles.average_continuously,'Value')
                        Averages = Averages + 1;
                    end
                    
                    Counts_result = {};
                    standard_dev = {};
                    
                    grid(handles.axes_AvgData, 'on');
                    
                    for aux=1:1:handles.ExperimentalScan.vary_points(1)  %loop over first scan dimension
                        status=1;
                        
                        
                        tic;
                        if ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                            while status~=0
                            
                            if get(handles.checkbox_tracking,'Value') && get(handles.button_track_per_scan_pt,'Value')
                                
                                obj.TrackCenterPB(handles);
                                
                            end
                            
                            
                            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.CreateTask('Counting');
                            num = uint32(Repetitions*number_acq);
                            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.ConfigurePulseWidthCounterIn('Counting',1,3,num); % line 3 is PFI1
   
                            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.StartTask('Counting');
                            
                            %Main sequencing
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            % Load Sequence %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % err = obj.LoadSequenceToExperimentPB(handles.Array_PSeq{helper_scan,aux},Repetitions,handles);
                            
                            [stPB,durPB,err] = obj.ListOfStatesAndDurationsPB(handles.Array_PSeq{helper_scan,aux},handles);
                            if ~err
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.sendSequence(stPB,durPB,Repetitions);
                            end
                            
                            
                            if err
                                handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
                                break;
                            end
                            
                            if err_latency==1
                                continue;
                            end
                            
                            
                            % END Load Sequence %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           
                            % Configure Signal Generator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            if handles.Array_PSeq{1}.Channels(2).Enable %if Electron MW enabled (Use SRS)
%                                 
%                                 if isempty(handles.Array_PSeq{helper_scan,aux}.Channels(2).Frequency)
%                                      obj.interfaceSigGen.Amplitude = -38;
%                                      obj.interfaceSigGen.Frequency = 1e9;
%                                 else    
%                                 obj.interfaceSigGen.Amplitude = handles.Array_PSeq{helper_scan,aux}.Channels(2).Amplitude;
%                                 obj.interfaceSigGen.Frequency = handles.Array_PSeq{helper_scan,aux}.Channels(2).Frequency;
%                                 end
%                                 
                                
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(2).Frequency) && isempty(handles.Array_PSeq{helper_scan,aux}.Channels(4).Phase) && isempty(handles.Array_PSeq{helper_scan,aux}.Channels(5).Phase)   
                                    obj.interfaceSigGen.Amplitude = handles.Array_PSeq{helper_scan,aux}.Channels(2).Amplitude;
                                    obj.interfaceSigGen.Frequency = handles.Array_PSeq{helper_scan,aux}.Channels(2).Frequency;
                                    err = obj.interfaceSigGen.SetAll();
                                end
                                
                                 if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(2).Frequency) && (~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(4).Phase) || ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(5).Phase) )
                                    obj.interfaceSigGen.Amplitude = handles.Array_PSeq{helper_scan,aux}.Channels(2).Amplitude;
                                    obj.interfaceSigGen.Frequency = handles.Array_PSeq{helper_scan,aux}.Channels(2).Frequency;
                                    err = obj.interfaceSigGen.setAmplitude;
                                   % err = obj.interfaceSigGen.setFrequency;
                                 end
                                
                                %err = obj.interfaceSigGen.SetAll();
                                if err
                                    handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
                                    break;
                                end
                            end
                           
                            % --------- IF USING WindFreak on channel 4
%                           
%                             if handles.Array_PSeq{1}.Channels(4).Enable %if Electron RF enabled (Use WindFreak)
%                                
%                                 
%                                 if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(4).Frequency)
%                                     obj.wf.amp = handles.Array_PSeq{helper_scan,aux}.Channels(4).Amplitude;
%                                     obj.wf.freq = handles.Array_PSeq{helper_scan,aux}.Channels(4).Frequency;
%                                 else
%                                     obj.wf.freq = 2e9;
%                                     obj.wf.amp=-31;
%                                 end
%                                 obj.wf.setFreq(obj.wf.freq,1,0);
%                                 obj.wf.setAmp(obj.wf.amp);
%                                 
% 
%                             end
                            
                            % --------- IF USING SRS2 on channel 4
                             if handles.Array_PSeq{1}.Channels(4).Enable %if Electron MW enabled (Use SRS)
                                
%                                 if isempty(handles.Array_PSeq{helper_scan,aux}.Channels(4).Frequency)
%                                      obj.interfaceSigGen2.Amplitude = -38;
%                                      obj.interfaceSigGen2.Frequency = 1e9;
%                                 else    
%                                 obj.interfaceSigGen2.Amplitude = handles.Array_PSeq{helper_scan,aux}.Channels(4).Amplitude;
%                                 obj.interfaceSigGen2.Frequency = handles.Array_PSeq{helper_scan,aux}.Channels(4).Frequency;
%                                 end
%                                 
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(4).Frequency) && isempty(handles.Array_PSeq{helper_scan,aux}.Channels(4).Phase) 
                                obj.interfaceSigGen2.Amplitude = handles.Array_PSeq{helper_scan,aux}.Channels(4).Amplitude;
                                obj.interfaceSigGen2.Frequency = handles.Array_PSeq{helper_scan,aux}.Channels(4).Frequency;
                                 err = obj.interfaceSigGen2.SetAll();
%                                 obj.interfaceSigGen2.Phase=2*aux
                                 %obj.interfaceSigGen2.setPhase
                                end
                                
                               if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(4).Phase) 
                                    obj.interfaceSigGen2.Amplitude = handles.Array_PSeq{helper_scan,aux}.Channels(4).Amplitude;
                                   obj.interfaceSigGen2.Phase = handles.Array_PSeq{helper_scan,aux}.Channels(4).Phase;
                                   %obj.interfaceSigGen2.Phase =1.0;
                                   obj.interfaceSigGen2.setAmplitude;
                                   %obj.interfaceSigGen2.setzeroPhase;
                                  obj.interfaceSigGen2.setPhase;
                                    
                                  
                                 
                               end
                                
                                if err
                                    handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
                                    break;
                                end
                             end
                            
                              % --------- IF USING SRS2 on channel 5
                             if handles.Array_PSeq{1}.Channels(5).Enable %if Electron MW enabled (Use SRS)
                                                              
                                if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(5).Frequency) && isempty(handles.Array_PSeq{helper_scan,aux}.Channels(5).Phase) 
                                obj.interfaceSigGen2.Amplitude = handles.Array_PSeq{helper_scan,aux}.Channels(5).Amplitude;
                                obj.interfaceSigGen2.Frequency = handles.Array_PSeq{helper_scan,aux}.Channels(5).Frequency;
                                 err = obj.interfaceSigGen2.SetAll();
                                end
                                
                               if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(5).Phase) 
                                    obj.interfaceSigGen2.Amplitude = handles.Array_PSeq{helper_scan,aux}.Channels(5).Amplitude;
                                   obj.interfaceSigGen2.Phase = handles.Array_PSeq{helper_scan,aux}.Channels(5).Phase;
                                   obj.interfaceSigGen2.setAmplitude;
                               end
                                
                                if err
                                    handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
                                    break;
                                end
                             end
                            
                                           
                              % --------- IF USING BNC on channel 6
                              if size(handles.Array_PSeq{1}.Channels,2)=6
                                  if handles.Array_PSeq{1}.Channels(6).Enable
                                      
                                      if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(6).Amplitude)
                                          obj.interfaceBNC.Amplitude = handles.Array_PSeq{helper_scan,aux}.Channels(6).Amplitude;
                                          obj.interfaceBNC.Width = handles.Array_PSeq{helper_scan,aux}.Channels(6).Frequency; %Use frequency here as a dummy for width
                                          obj.interfaceBNC.Delay = handles.Array_PSeq{helper_scan,aux}.Channels(6).Phase; %Use phase here as a dummy for delay
                                          err=obj.interfaceBNC.setWidth(4,obj.interfaceBNC.Width);
                                          err=obj.interfaceBNC.setPeriod(obj.interfaceBNC.Width);
                                          err=obj.interfaceBNC.setDelay(4,obj.interfaceBNC.Delay);
                                          err=obj.interfaceBNC.setAmplitude(4,obj.interfaceBNC.Amplitude);
                                          obj.interfaceBNC.start;
                                      end
                                      
                                      if err
                                          handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
                                          break;
                                      end
                                  end
                              end
                              
                              % --------- IF USING AWG on channel 7
                              if size(handles.Array_PSeq{1}.Channels,2)=7
                                  if handles.Array_PSeq{1}.Channels(7).Enable
                                      
                                      if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(6).Amplitude)
                                          obj.AGW.SegNum = handles.Array_PSeq{helper_scan,aux}.Channels(7).Amplitude; %Use amplitude here as a dummy for segment number
                                          WX1284FunctionPool('selsegment',obj.AWG.SegNum) %% not sure and I don't know how to write the err part
%                                           err=obj.interfaceBNC.setWidth(4,obj.interfaceBNC.Width);
%                                           err=obj.interfaceBNC.setPeriod(obj.interfaceBNC.Width);
%                                           err=obj.interfaceBNC.setDelay(4,obj.interfaceBNC.Delay);
%                                           err=obj.interfaceBNC.setAmplitude(4,obj.interfaceBNC.Amplitude);
%                                           err=WX1284CFunctionPool('checkerr');
                                          obj.AWG.start;
                                      end
                                      
%                                       if err
%                                           handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
%                                           break;
%                                       end
                                  end
                              end
                            
                            % END Configure Signal Generator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            % Experiment routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart(); %will fire one single sequence Repetitions number of times
                           
                         
                            [counts,status] = handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.ReadCounterBuffer('Counting',num);
                           
                            
                            
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.StopTask('Counting');
                            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.ClearTask('Counting');
                           
                            end
                            for s=1:1:number_acq
                                %separate the different SPD acquisitions, sum over the reps per point, plus normalize
                                clear helper;
                                helper = sum(double(counts(s:number_acq:end)))/handles.Array_PSeq{helper_scan,aux}.Channels(3).RiseDurations(s)/1000/Repetitions;%kcps per rise of SPD Acq
                                standard_dev{s}(aux) = std(double(counts(s:number_acq:end)))/handles.Array_PSeq{helper_scan,aux}.Channels(3).RiseDurations(s)/1000/sqrt(Repetitions);
                                Counts_result{s}(aux) = helper;
                                if handles.kk~=1
                                temp_data{s}(aux) = ((temp_data{s}(aux))*(handles.kk-1) + Counts_result{s}(aux))/handles.kk;
                                else
                                     temp_data{s}(aux)=Counts_result{s}(aux);
                                end
                                    
                                
                            end
                            
                            
                            %PLOT! pointwise
                           cla(handles.axes_AvgData);
                            for j=1:1:number_acq
                                hold(handles.axes_AvgData,'on');
                                plot(x,temp_data{j}(:),['.-' colors(j)],'Parent',handles.axes_AvgData,'MarkerSize',15,'LineWidth',0.5);
                            end
                            hold(handles.axes_AvgData,'off');
                            drawnow();
                            
                            clear counts;
%                             
%                             if obj.statuswbexp
%                                 waitbar((aux + (handles.kk-1)*(handles.ExperimentalScan.vary_points(1))+ (helper_scan-1)*handles.ExperimentalScan.vary_points(1)*Averages)/(Averages*scan2pts*handles.ExperimentalScan.vary_points(1)));
%                             else
%                                 close(wbexp);
%                             end
                            
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                      
                    end %END loop over first scan dimension
                    
                    
                    
                    
                    if ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                        
                        %reorder the random scan points if random scan was
                        %chosen
                        if ~isempty(handles.rand_indices_1dscan)
                            for len=1:1:number_acq
                                Counts_result{len} = Counts_result{len}(handles.rand_indices_1dscan);
                                standard_dev{len} = standard_dev{len}(handles.rand_indices_1dscan);
                            end
                            handles.ExperimentalScan.israndom = 1;
                        else
                            handles.ExperimentalScan.israndom = 0;
                        end
                        
                        obj.RawData = Counts_result;
                        
                        
                        ResultsEachAvg{helper_scan}{handles.kk} = obj.RawData;
                        ErrorEachAvg{helper_scan}{handles.kk} = standard_dev;
                        
                        obj.UpdateSingleDataPlot(handles,handles.kk);
                        
                        %plot avg data
                        if handles.kk == 1
                            obj.AvgData = obj.RawData;
                            obj.Std_dev = standard_dev;
                        else
                            for f=1:1:length(obj.RawData)
                                obj.AvgData{f} = ((obj.AvgData{f})*(handles.kk-1) + double(obj.RawData{f}))/handles.kk ;
                                obj.Std_dev{f} = sqrt(obj.Std_dev{f}.^2 + standard_dev{f}.^2); %gaussian error propagation 
                            end
                        end
                        
                        %Commented for random noise exp only
                        if Averages > 1
                            for q=1:1:number_acq
                                obj.Std_dev{q} = obj.Std_dev{q}*(1/sqrt((Averages)*(Averages-1)));  % insert factor for standard error of the mean
                            end
                        end
                        
                        obj.UpdateAvgDataPlot(handles,handles.kk);
                        
                        if get(handles.average_continuously,'Value')
                            set(handles.text_ExpStatus,'String',sprintf('%d averages completed for %d scans',handles.kk,scan2pts));
                        else
                            set(handles.text_ExpStatus,'String',sprintf('(%d/%d) averages completed for %d scans',handles.kk,Averages,helper_scan));
                        end
                        
                        %commented only for random noise exps
                        handles.kk = handles.kk+1;
                        
                    end
                    
              
                end %END loop over averages
                
               %save('fullcounts.mat','COUNTARRAY'); 
                
                Results{helper_scan} = obj.AvgData;
                handles.ExperimentalScan.ExperimentDataError{helper_scan} = obj.Std_dev;
                
                if scan2pts > 1
                    set(handles.text_vary2_param,'Visible','on');
                    set(handles.text_vary2_param,'String',sprintf('%s = %d', handles.ExperimentalScan.vary_prop{2},handles.ExperimentalScan.vary_begin(2) + (helper_scan-1)*handles.ExperimentalScan.vary_step_size(2)))
                end
                
            end %END loop over second scan dimension
            
            handles.ExperimentalScan.Averages = handles.kk-1; %saved at the end bc can change if avg continuously checkbutton is checked
            
             % ashok 12/4 UNCOMMENT THIS 
%             obj.interfaceSigGen.setRFOff();
%             obj.interfaceSigGen2.setRFOff(); % For source 2
            
            
%             obj.wf.open();
%             obj.wf.setFreq(2e9,1,1); %SET windFreak OFF
%             pause(0.5); %necessary, otherwise will not turn off
%             
%            
%             
%             %commented only for random noise exps
%              % ashok 12/4 UNCOMMENT THIS 
% %             obj.interfaceSigGen.close();
% %             obj.interfaceSigGen2.close();
% 
%             obj.wf.close();
%             pause(0.5);
          
          
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Saving result and finishing
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
                       
            if ((strcmp(get(handles.menuAutoSaveExp,'checked'),'on')) && ~err && handles.kk ~= 1) % check for autosave and if there are hardware errors, in which case scan did not execute
                handles.ExperimentalScan.ExperimentData = Results;
                handles.ExperimentalScan.ExperimentDataEachAvg = ResultsEachAvg;
                handles.ExperimentalScan.ExperimentDataErrorEachAvg = ErrorEachAvg;
                obj.SaveExp(handles);
            end
            
            obj.UpdateExpScanList(handles);
            
            set(handles.text_power,'Visible','off');
            
            if scan2pts > 1 %2d scan
                set(handles.text_vary2_param,'Visible','on');
                set(handles.text_vary2_param,'String',sprintf('%s = %s',handles.ExperimentalScan.vary_prop{2},num2str(handles.ExperimentalScan.vary_begin(2))));
                set(handles.sliderExpScan,'Visible','on');
                set(handles.sliderExpScan,'Max', handles.ExperimentalScan.vary_points(2));
                set(handles.sliderExpScan,'Min', 1);
                set(handles.sliderExpScan,'Value', 1);
            end
            
            %obj.EachAvgPlot(handles,handles.ExperimentalScan,1,1);
            obj.LoadExpFromScan(handles);
            
%              if obj.statuswbexp
%                 close(wbexp);
%                 
%              end
%              

            toc;
            
            profile off
            
            handles.ExperimentFinished=1;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
         function PhaseSet(obj,handles)
            obj.interfaceSigGen2.Phase=handles.phase_val;
            obj.interfaceSigGen2.setPhase;
            obj.interfaceSigGen2.readPhase
         end
         
         function [phase]= PhaseRead(obj,handles)
            phase=obj.interfaceSigGen2.readPhase;
         end
         
         function AmpSet(obj,handles)
            obj.interfaceSigGen2.Amplitude=handles.amp_val;
            obj.interfaceSigGen2.setAmplitude;
         end
        
         function FreqSet(obj,handles)
             obj.interfaceSigGen.Frequency=handles.lock_val;
             obj.interfaceSigGen.setFrequency;
             obj.interfaceSigGen2.Frequency=handles.lock_val;
             obj.interfaceSigGen2.setFrequency;
         end
         
        function AbortRun(obj,handles)
            
            % ashok 12/4 UNCOMMENT THIS 
            %obj.interfaceSigGen.open();
            %obj.interfaceSigGen.setRFOff();
            %obj.interfaceSigGen.close();
            
            %for source 2
            %obj.interfaceSigGen2.open();
           % obj.interfaceSigGen2.setRFOff();
            %obj.interfaceSigGen2.close();
%             
%             obj.wf.open();
%             obj.wf.setFreq(2e9,1,1);
%             obj.wf.close();
            
            
            if handles.Imaginghandles.QEGhandles.pulse_mode == 1 || handles.Imaginghandles.QEGhandles.pulse_mode == 2
                
                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
                
            elseif handles.Imaginghandles.QEGhandles.pulse_mode == 0 || handles.Imaginghandles.QEGhandles.pulse_mode == 3
                
                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.open();
                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.AWGStop();
                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.clear_waveforms();
                
                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SetAllChannelsOff();
                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.close();
                
            end
            
            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.StopTask('Counting');
            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.ClearTask('Counting');
            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 1;
            handles.Tracker.hasAborted=1;
            
        end
        
        %%%%% Sequencing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [err] = LoadSequenceToExperimentAWG(obj,PS,handles,aux,vary_pts,q,k)
            
            [IShape,AOMShape,MWShape,QShape,SPDShape,CShape,NShape,NullShape,err] = obj.ListOfStatesAndDurationsAWG(PS,handles);
            
            if ~err
                
                C_is_on = (PS.Channels(4).Enable);
                N_is_on = (PS.Channels(5).Enable);
                
                if aux == 1
                    handles.Imaginghandles.ImagingFunctions.interfacePulseGen.create_null(NullShape,C_is_on,N_is_on);
                end
                
                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.send_sequence(IShape,AOMShape,MWShape,QShape,SPDShape,CShape,NShape,NullShape,aux,vary_pts,C_is_on,N_is_on,q,k);
                
                
            else
                return;
            end
            
            
        end
        
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
            
            handles.ExperimentalScan.scan_nonlinear=handles.scan_nonlinear;
  
            handles.ExperimentalScan.nonlinear_data=handles.nonlinear_data;
            handles.ExperimentalScan.SampleRate = handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate;
            handles.ExperimentalScan.ShapedPulses = handles.Array_PSeq{1}.ShapedPulses; %any PSeq element is good bc ShapedPulses cannot change
            
            if get(handles.checkbox_tracking,'Value') %if tracking enabled
                if get(handles.button_track_per_avg,'Value') % tracking per avg
                   handles.ExperimentalScan.istracking = 'Per average'; 
                else % tracking per scan point
                   handles.ExperimentalScan.istracking = 'Per scan point';  
                end
            else    
                handles.ExperimentalScan.istracking = 'Disabled';
            end
            
            if get(handles.checkbox_power,'Value') %if power measurement enabled
                if get(handles.button_power_per_avg,'Value') % power meas per avg
                   handles.ExperimentalScan.ispower = 'Per average'; 
                else % tracking per scan point
                   handles.ExperimentalScan.ispower = 'Per scan point';  
                end
            else    
                handles.ExperimentalScan.ispower = 'Disabled';
            end
            
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
            
            send_email(fn,'',[fullFN '.mat']);
            
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
            
            go_on = 0;
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