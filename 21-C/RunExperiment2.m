function RunExperiment2(obj,handles)
           
            handles.ExperimentFinished=0;
            profile on
          
            err = 0; % var that tracks hardware limits on the sequence (for SG, AWG)
            err_latency=0;
            handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted = 0;
            set(handles.text_power,'Visible','on');
            set(handles.slider_each_avg,'Visible','off');
            set(handles.avg_nb,'Visible','off');
           
            mw=MicroWave_Generator;
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
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % No loop over second dimension
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


               %% No Loop over averages
                  helper_scan=1;  
                 handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                 if ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                    for aux=1:1:handles.ExperimentalScan.vary_points(1)  %loop over first scan dimension
                        status=1;
                        
                        if ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                        tic;
                       
                        for rep_count=1:1:Repetitions              
                            if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted==1
                                obj.com.StopBuffer(1);
                                obj.com.KillAll();
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                                break;
                            else 
                                if aux>1 && rep_count>1
                                    pause(1); %recycle delay
                                end
                           %% Initialize acutator position for very first motion
%                            if handles.Array_PSeq{1}.Channels(12).Enable && rep_count ==1 && aux==1 && ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency)
%                                 start_pos=obj.com.GetFPosition(obj.com.ACSC_AXIS_0);
%                                  Position=handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency;
%                                  obj.com.SetVelocity(obj.com.ACSC_AXIS_0,50);
%                                  obj.com.SetAcceleration(obj.com.ACSC_AXIS_0,500);
%                                  obj.com.SetDeceleration(obj.com.ACSC_AXIS_0,500);
%                                  obj.com.SetJerk(obj.com.ACSC_AXIS_0,5000);
%                                  
%                                  obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0, -Position); %MOVE
%                                  obj.com.Go(obj.com.ACSC_AXIS_0);
%                                  displacement=abs(abs(start_pos)-abs(Position));
%                                  if displacement>2
%                                  obj.com.WaitMotionEnd (obj.com.ACSC_AXIS_0, 1000*10*displacement/50);
%                                  else
%                                    obj.com.WaitMotionEnd (obj.com.ACSC_AXIS_0, 3000);  
%                                  end
%                            end
                               
                                
                            %% SET actuator position
                            
%                             if handles.Array_PSeq{1}.Channels(12).Enable
%                                 if ~isempty(handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency)
%                                     Position=handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency;
%                                     Velocity=handles.Array_PSeq{helper_scan,aux}.Channels(12).Amplitude;
%                                     Accn=handles.Array_PSeq{helper_scan,aux}.Channels(12).Phase;
%                                     Jerk=handles.Array_PSeq{helper_scan,aux}.Channels(12).AmpIQ;
%                                     c_position=handles.Array_PSeq{helper_scan,aux}.Channels(12).FreqIQ;
%                                     
%                                     obj.com.SetVelocity(obj.com.ACSC_AXIS_0,Velocity);
%                                     obj.com.SetAcceleration(obj.com.ACSC_AXIS_0,Accn);
%                                     obj.com.SetDeceleration(obj.com.ACSC_AXIS_0,Accn);
%                                     obj.com.SetJerk(obj.com.ACSC_AXIS_0,Jerk);
%                                     
%                                     obj.com.ToPoint(obj.com.ACSC_AMF_WAIT, obj.com.ACSC_AXIS_0,-c_position);   %go up to coil position
%                                     obj.com.WriteVariable(-Position, 'V0', obj.com.ACSC_NONE);
%                                     obj.com.RunBuffer(1);                                    
%                                 end
%                             end
                            
                            
                            %% Main sequencing                    
                            if ~err & ~handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted
                                [stPB,durPB,err] = obj.ListOfStatesAndDurationsPB(handles.Array_PSeq{helper_scan,aux},handles);
                                handles.Imaginghandles.ImagingFunctions.interfacePulseGen.sendSequence(stPB,durPB,1);
                                
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
                                 obj.com.StopBuffer(1);
                                 obj.com.KillAll();
                                 handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                                break;
                            else
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart(); %will fire one single sequence Repetitions number of times
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();                            
                            
                            
                            Position=handles.Array_PSeq{helper_scan,aux}.Channels(12).Frequency;
                            Velocity=handles.Array_PSeq{helper_scan,aux}.Channels(12).Amplitude;
                            c_position=handles.Array_PSeq{helper_scan,aux}.Channels(12).FreqIQ;
                            pause(1.05*sum(durPB)+abs(abs(Position)-abs(c_position))/Velocity+abs(abs(Position)-abs(c_position))/100+6);
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%important%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %waitfor(handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop())
   
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            end 
                       
                            if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted==1
                                 obj.com.StopBuffer(1);
                                 obj.com.KillAll();
                                 handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                                 break;
                            end                            
                        end
                        if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted==1
                            obj.com.StopBuffer(1);
                            obj.com.KillAll();
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                            break;
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        end 
                        if handles.Imaginghandles.ImagingFunctions.interfaceDataAcq.hasAborted==1
                            obj.com.StopBuffer(1);
                            obj.com.KillAll();
                            handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
                            break;
                        end
                    end %END loop over first scan dimension
                 
                 end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Saving result and finishing
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            toc;
            
            profile off
            
            handles.ExperimentFinished=1;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end