classdef magnetfunctions < handle
    
    properties
        
        NumPoints
        
    end
    
    methods
        
        function handles = refresh_magnet(obj,handles)
            
            zaber_x = handles.zaber_x;
            [ret err] = ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex);
            set(handles.slider_x, 'Value', ret(2)*1e3);
            set(handles.Pos_x, 'String', num2str(ret(2)*1e3));
            
            zaber_y = handles.zaber_y;
            [ret err] = ZaberReturnCurrentPosition(zaber_y, zaber_y.deviceIndex);
            set(handles.slider_y, 'Value', ret(2)*1e3);
            set(handles.Pos_y, 'String', num2str(ret(2)*1e3));
            
            zaber_z = handles.zaber_z;
            [ret err] = ZaberReturnCurrentPosition(zaber_z, zaber_z.deviceIndex);
            set(handles.slider_z, 'Value', ret(2)*1e3);
            set(handles.Pos_z, 'String', num2str(ret(2)*1e3));
        end
        
        function handles = move_magnet_y(obj,handles)
            absolutePosition = str2num(get(handles.Pos_y, 'String'))*1e-3;
            zaber_y = handles.zaber_y;
            [ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, absolutePosition);
            set(handles.slider_y, 'Value', ret(2)*1e3);
            set(handles.Pos_y, 'String', num2str(ret(2)*1e3));
        end
        
        function handles = move_magnet_x(obj,handles)
            absolutePosition = str2num(get(handles.Pos_x, 'String'))*1e-3;
            zaber_x = handles.zaber_x;
            [ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, absolutePosition);
            set(handles.slider_x, 'Value', ret(2)*1e3);
            set(handles.Pos_x, 'String', num2str(ret(2)*1e3));
        end
        
        function handles = move_magnet_z(obj,handles)
            absolutePosition = str2num(get(handles.Pos_z, 'String'))*1e-3;
            zaber_z = handles.zaber_z;
            [ret err] = ZaberMoveAbsolute(zaber_z, zaber_z.deviceIndex, absolutePosition);
            set(handles.slider_z, 'Value', ret(2)*1e3);
            set(handles.Pos_z, 'String', num2str(ret(2)*1e3));
        end
        
        function magnet_track(obj,handles)
            
              handles.Imaginghandles.ImagingFunctions.TrackCenter(handles.Imaginghandles);
            for loopcounter=1:3
                magnet_track_x(obj,handles);
                magnet_track_y(obj,handles);
            end
        end
        
        function magnet_track_x(obj,handles)
            % track
            step = 6e-3;
            loopcounter = 0;
            refresh_magnet(obj,handles);
            currpos_x = str2num(get(handles.Pos_x, 'String'));
            
            while(step > 0.5e-3 && loopcounter<10)
                disp('Tracking X ... be patient');
                % Get 10 microns left and right of current point
                currentcount = count(obj,handles);
                %currentcount = handles.counts;
                
                
                % move right 10
                rpos = currpos_x+step;
                handles.newposition_x = rpos;
                step_x(obj,handles);
                rcount = count(obj,handles);
                %rcount = handles.counts;
                
                % move left 10
                lpos = currpos_x-step;
                handles.newposition_x= lpos;
                step_x(obj,handles);
                lcount = count(obj,handles);
                %lcount = handles.counts;
                
                if (currentcount > rcount) && (currentcount > lcount)
                    handles.newposition_x = currpos_x;
                    step_x(obj,handles);
                    disp('Changing step by half')
                    step = step/1.2;
                elseif (rcount > currentcount) && (rcount > lcount)
                    handles.newposition_x = rpos;
                    step_x(obj,handles);
                    
                elseif (lcount > currentcount) && (lcount > rcount)
                    handles.newposition_x = lpos;
                    step_x(obj,handles);
                end
                loopcounter = loopcounter+1;
                currpos_x=handles.newposition_x;
                disp(['left count: '  num2str(lcount) 10 'current count: ' num2str(currentcount)  10 'right count: ' num2str(rcount) 10 'step:' num2str(step*1e3) 10 5 5 ]);
            end
            
            disp('End of tracking X')
        end
        
        function magnet_track_y(obj,handles)
            % track
            step = 12e-3;
            loopcounter = 0;
            refresh_magnet(obj,handles);
            currpos_y = str2num(get(handles.Pos_y, 'String'));
            
            while(step > 2e-3 && loopcounter<10)
                disp('Tracking Y ... be patient');
                % Get 10 microns left and right of current point
                currentcount = count(obj,handles);
                %currentcount = handles.counts;
                
                
                % move right 10
                rpos = currpos_y+step;
                handles.newposition_y = rpos;
                step_y(obj,handles);
                rcount = count(obj,handles);
                %rcount = handles.counts;
                
                % move left 10
                lpos = currpos_y-step;
                handles.newposition_y= lpos;
                step_y(obj,handles);
                lcount = count(obj,handles);
                %lcount = handles.counts;
                
                if (currentcount > rcount) && (currentcount > lcount)
                    handles.newposition_y = currpos_y;
                    step_y(obj,handles);
                    disp('Changing step by half')
                    step = step/1.2;
                elseif (rcount > currentcount) && (rcount > lcount)
                    handles.newposition_y = rpos;
                    step_y(obj,handles);
                    
                elseif (lcount > currentcount) && (lcount > rcount)
                    handles.newposition_y = lpos;
                    step_y(obj,handles);
                end
                loopcounter = loopcounter+1;
                currpos_y=handles.newposition_y;
                disp(['left count: '  num2str(lcount) 10 'current count: ' num2str(currentcount)  10 'right count: ' num2str(rcount) 10 'step:' num2str(step*1e3) 10 5 5 ]);
            end
            
            disp('End of tracking Y')
        end
        
        % --- Executes on button press in magnet_track.
        function step_x(obj,handles)
            % hObject    handle to magnet_track (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            set(handles.Pos_x, 'String', handles.newposition_x);
            move_magnet_x(obj,handles);
        end
        
        % --- Executes on button press in magnet_track.
        function step_y(obj,handles)
            % hObject    handle to magnet_track (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            set(handles.Pos_y, 'String', handles.newposition_y);
            move_magnet_y(obj,handles);
        end
        
        
        function counts = count(obj,handles)
            tracker_points=10;
            time_move_per_point = 100e-3;
            %time_move_per_point=5e-6;
            
            
            daq=handles.Imaginghandles.ImagingFunctions.interfaceDataAcq;
            handles.magnet_counter_line=handles.Imaginghandles.ImagingFunctions.TrackerCounterOutLine;
            
            daq.AnalogOutVoltages(1)=5; %enable SPD
            daq.WriteAnalogOutLine(1);
            
            daq.CreateTask('Counter_magnet');
            daq.CreateTask('PulseTrain_magnet');
            
            
            daq.ConfigureCounterIn('Counter_magnet',handles.Imaginghandles.ImagingFunctions.TrackerCounterInLine,handles.magnet_counter_line,tracker_points);
            daq.ConfigureClockOut('PulseTrain_magnet',handles.magnet_counter_line,1/time_move_per_point,0.5);
            
            
            daq.StartTask('PulseTrain_magnet');
            daq.StartTask('Counter_magnet');
            
            A = daq.ReadCounterBuffer('Counter_magnet',tracker_points+1,10);
            daq.StopTask('Counter_magnet');
            daq.StopTask('PulseTrain_magnet');
            
            daq.ClearTask('Counter_magnet');
            daq.ClearTask('PulseTrain_magnet');
            
            
            argData =double(diff(A)/(time_move_per_point));
            counts=median(argData(1:end-1));
        end
        end
    end
    
