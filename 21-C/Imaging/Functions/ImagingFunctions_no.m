classdef ImagingFunctions < handle
    
    properties
        
        %instruments
        interfaceDataAcq
        interfaceScanning
        interfacePulseGen
        
        %scan
        CurrentScanMat    % For easier indexing, actually a cell structure
        CounterRawData
        ImageRawData
        CursorPosition   % position in X,Y,Z space of confocal spot
        statuswb = 1;      %will be used as a handle to close the waitbar in case of stop scan
        cutoffVal        %the value of the cutoff for the filter
        useFilter = 0;       %indicate if supposed to apply the filter
        NumPoints
        bEnable          %scans directions that are enabled
        MinValues
        MaxValues
        PiezoStability1
        PiezoStability2
        
        %tracking and counting
        TrackerhasAborted
        TrackerNumberOfSamples
        TrackerDwellTime
        TrackerDutyCycle
        TrackerCounterInLine
        TrackerCounterOutLine
        TrackerInitialStepSize
        TrackerMinimumStepSize
        TrackerMaxIterations
        TrackerTrackingThreshold
        TrackerStepReductionFactor
        
    end
    
    methods
        
        %%%%% MOVING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function handles = SetCursor(obj,handles)
            
            for k=1:3
                obj.interfaceScanning.Mov(obj.CursorPosition(k),k);
            end
            
            handles = obj.UpdateCursorPosition(handles);
            
        end
        
        function handles = QueryPos(obj,handles)
            
            obj.CursorPosition=[obj.interfaceScanning.Pos(1) obj.interfaceScanning.Pos(2) obj.interfaceScanning.Pos(3)];
            handles = obj.UpdateCursorPosition(handles);
        end
        
        function handles = UpdateCursorPosition(obj,handles)
            
            set(handles.cursorX,'String',sprintf('%0.3f',obj.CursorPosition(1)));
            set(handles.cursorY,'String',sprintf('%0.3f',obj.CursorPosition(2)));
            set(handles.cursorZ,'String',sprintf('%0.3f',obj.CursorPosition(3)));
            handles = obj.DrawCrossHairsFromUpdate(handles);
            
        end
        
        function handles = DrawCrossHairsFromUpdate(obj,handles)
            
            lh1 = handles.xcrosshair;
            lh2 = handles.ycrosshair;
            
            if ~ishandle(lh1),
                lh1 = line([0 0],[0 0],[0 0],'Parent',handles.imageAxes);
                handles.xcrosshair = lh1;
            end
            
            if ~ishandle(lh2),
                lh2 = line([0 0],[0 0],[0 0],'Parent',handles.imageAxes);
                handles.ycrosshair = lh2;
            end
            
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
            % get the current limits of the axes1
            XLimits = get(handles.imageAxes,'XLim');
            YLimits = get(handles.imageAxes,'YLim');
            
            xP = obj.CursorPosition(1);
            yP = obj.CursorPosition(2);
            zP = obj.CursorPosition(3);
            
            if length(handles.ConfocalScanDisplayed.RangeX) > 1 && length(handles.ConfocalScanDisplayed.RangeY) > 1
                %2d scan, XY, or 3d scan
                if xP <= max(XLimits) && xP >= min(XLimits),
                    if yP <= max(YLimits) && yP >= min(YLimits),
                        set(lh1,'XData',[XLimits(1),XLimits(2)],'YData',[yP yP]);
                        set(lh2,'XData',[xP xP],'YData',[YLimits(1),YLimits(2)]);
                    end
                end
                
            elseif length(handles.ConfocalScanDisplayed.RangeX) > 1 && length(handles.ConfocalScanDisplayed.RangeZ) > 1
                %2d scan, XZ
                if xP <= max(XLimits) && xP >= min(XLimits),
                    if zP <= max(YLimits) && zP >= min(YLimits),
                        set(lh1,'XData',[XLimits(1),XLimits(2)],'YData',[zP zP]);
                        set(lh2,'XData',[xP xP],'YData',[YLimits(1),YLimits(2)]);
                    end
                end
                
            elseif length(handles.ConfocalScanDisplayed.RangeY) > 1 && length(handles.ConfocalScanDisplayed.RangeZ) > 1
                %2d scan, YZ
                if yP <= max(XLimits) && yP >= min(XLimits),
                    if zP <= max(YLimits) && zP >= min(YLimits),
                        set(lh1,'XData',[XLimits(1),XLimits(2)],'YData',[zP zP]);
                        set(lh2,'XData',[yP yP],'YData',[YLimits(1),YLimits(2)]);
                    end
                end
                
            end
            %if it is scan 1D do not do anything
            
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
        end
        
        function handles = SetCursorFromAxes(obj,handles)
            
            CP = get(handles.imageAxes,'CurrentPoint');
            
            if length(handles.ConfocalScanDisplayed.RangeX) > 1 && length(handles.ConfocalScanDisplayed.RangeY) > 1 && length(handles.ConfocalScanDisplayed.RangeZ) > 1
                %3d scan
                obj.CursorPosition(1) = CP(1,1);
                obj.CursorPosition(2) = CP(1,2);
                obj.CursorPosition(3) = handles.ConfocalScanDisplayed.RangeZ(get(handles.sliderZScan,'Value'));
                
            elseif length(handles.ConfocalScanDisplayed.RangeX) > 1 && length(handles.ConfocalScanDisplayed.RangeY) > 1
                %2d scan, XY
                obj.CursorPosition(1) = CP(1,1);
                obj.CursorPosition(2) = CP(1,2);
                obj.CursorPosition(3) = handles.ConfocalScanDisplayed.RangeZ;
                
            elseif length(handles.ConfocalScanDisplayed.RangeX) > 1 && length(handles.ConfocalScanDisplayed.RangeZ) > 1
                %2d scan, XZ
                obj.CursorPosition(1) = CP(1,1);
                obj.CursorPosition(3) = CP(1,2);
                obj.CursorPosition(2) = handles.ConfocalScanDisplayed.RangeY;
                
            elseif length(handles.ConfocalScanDisplayed.RangeY) > 1 && length(handles.ConfocalScanDisplayed.RangeZ) > 1
                %2d scan, YZ
                obj.CursorPosition(2) = CP(1,1);
                obj.CursorPosition(3) = CP(1,2);
                obj.CursorPosition(1) = handles.ConfocalScanDisplayed.RangeX;
                
            elseif length(handles.ConfocalScanDisplayed.RangeX) > 1
                %1d scan, X
                obj.CursorPosition(1) = CP(1,1);
                obj.CursorPosition(2) = handles.ConfocalScanDisplayed.RangeY;
                obj.CursorPosition(3) = handles.ConfocalScanDisplayed.RangeZ;
                
            elseif length(handles.ConfocalScanDisplayed.RangeY) > 1
                %1d scan, Y
                obj.CursorPosition(2) = CP(1,1);
                obj.CursorPosition(1) = handles.ConfocalScanDisplayed.RangeX;
                obj.CursorPosition(3) = handles.ConfocalScanDisplayed.RangeZ;
                
            elseif length(handles.ConfocalScanDisplayed.RangeZ) > 1
                %1d scan, Z
                obj.CursorPosition(3) = CP(1,1);
                obj.CursorPosition(1) = handles.ConfocalScanDisplayed.RangeX;
                obj.CursorPosition(2) = handles.ConfocalScanDisplayed.RangeY;
                
            end
            handles = obj.SetCursor(handles);
            
        end
        
        %%%%% END MOVING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%% SCANNING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function handles = PerformScan(obj, handles)
            
            handles.Xinit=obj.interfaceScanning.Pos(1);
            handles.Yinit=obj.interfaceScanning.Pos(2);
            handles.Zinit=obj.interfaceScanning.Pos(3);
            
            set(handles.text_power,'Visible','on');
            [laser_power_in_V,std_laser_power_in_V,power_array_in_V] = obj.MonitorPower();
            [laser_power,std_laser_power] = PhotodiodeConversionVtomW(laser_power_in_V,std_laser_power_in_V);
            set(handles.text_power,'String',sprintf('Power = %0.3f +- %0.3f mW',laser_power,std_laser_power));
            
            %initialize variables
            [handles,ND] = obj.InitVarsForScan(handles);
            
            set(handles.sliderZScan,'Visible','off');
            
            if ND == 1  %one dimensional scanning
                set(handles.buttonStop, 'Enable', 'off');
                obj.SetStatus(handles,'Performing 1D Scan.... ');
                handles = obj.StartScan1D(handles);
                set(handles.sliderZScan,'Visible', 'off');
                set(handles.text6,'Visible', 'off');
            elseif ND == 2 %two-dimensional scanning
                set(handles.buttonStop, 'Enable', 'on');
                obj.SetStatus(handles,'Performing 2D Scan.... ');
                handles = obj.StartScan2D(handles);
                set(handles.sliderZScan,'Visible', 'off');
                set(handles.text6,'Visible', 'off');
            else % ND == 3
                set(handles.buttonStop, 'Enable', 'on');
                obj.SetStatus(handles,'Performing 3D Scan.... ');
                handles = obj.StartScan3D(handles);
                if obj.statuswb
                    set(handles.sliderZScan,'Max', length(handles.ConfocalScanDisplayed.RangeZ));
                    set(handles.sliderZScan,'Min', 1);
                    set(handles.sliderZScan,'Value', 1);
                    set(handles.text6,'String', ['Z pos = ' num2str(handles.ConfocalScanDisplayed.RangeZ(1))]);
                    set(handles.sliderZScan,'Visible', 'on');
                    set(handles.text6,'Visible', 'on');
                end
            end
            
            %Make piezo go back to point prior to beginning of scan if desired
            if get(handles.returninit,'Value');
                obj.interfaceScanning.Mov(handles.Xinit,1);
                obj.interfaceScanning.Mov(handles.Yinit,2);
                obj.interfaceScanning.Mov(handles.Zinit,3);
            end
            
            % Relase the DAQ counter task
            obj.interfaceDataAcq.ClearTask('Counter');
            
            if ND == 1
                handles.ImagingFunctions.SetStatus(handles,'Scan Complete.');
            elseif obj.statuswb
                close(handles.wb);
                handles.ImagingFunctions.SetStatus(handles,'Scan Complete.');
            end
            
            [laser_power_in_V,std_laser_power_in_V,power_array2_in_V] = obj.MonitorPower();
            [laser_power,std_laser_power] = PhotodiodeConversionVtomW(laser_power_in_V,std_laser_power_in_V);
            set(handles.text_power,'String',sprintf('Power = %0.3f +- %0.3f mW',laser_power,std_laser_power));
            
            power_array_in_V = [power_array_in_V power_array2_in_V];
            mean_power_array_in_V = mean(power_array_in_V);
            std_power_array_in_V = std(power_array_in_V);
            [laser_power,std_laser_power] = PhotodiodeConversionVtomW(mean_power_array_in_V,std_power_array_in_V);
            handles.ConfocalScan.Laserpower(1) = laser_power;
            handles.ConfocalScan.Laserpower(2) = std_laser_power;
            
            % record the image
            % check for autosave
            if (strcmp(get(handles.menuAutoSave,'checked'),'on'))
                handles = obj.SaveScan(handles);
            end
            
            set(handles.text_power,'Visible','off');
            
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
%             load gong;
%             sound(y,Fs);
%            
            
        end
        
        function [handles,dim] = InitVarsForScan(obj,handles)
            
            % clear out the raw counter variables
            obj.CounterRawData = [];
            obj.ImageRawData = [];
            
            %initialize ScanMat
            for k=1:3
                if obj.bEnable(k)
                    X = linspace(obj.MinValues(k),obj.MaxValues(k),obj.NumPoints(k));
                    obj.CurrentScanMat{k} = X;
                else
                    obj.CurrentScanMat{k} = [];
                end
                
            end
            
            if obj.bEnable(3)
                handles.ConfocalScan.RangeZ = obj.CurrentScanMat{3};
            else
                handles.ConfocalScan.RangeZ = obj.interfaceScanning.Pos(3);
            end
            
            if obj.bEnable(2)
                handles.ConfocalScan.RangeY = obj.CurrentScanMat{2};
            else
                handles.ConfocalScan.RangeY = obj.interfaceScanning.Pos(2);
            end
            
            if obj.bEnable(1)
                handles.ConfocalScan.RangeX = obj.CurrentScanMat{1};
            else
                handles.ConfocalScan.RangeX = obj.interfaceScanning.Pos(1);
            end
            
            dim = sum(obj.bEnable);
            
        end
        
        function [handles,NA,NB] = InitVars2D(obj,handles,scan_code)
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'xY')
                NA = length(obj.CurrentScanMat{1});
                NB = length(obj.CurrentScanMat{2});
            elseif strcmp(scan_code,'Xz') || strcmp(scan_code,'xZ')
                NA = length(obj.CurrentScanMat{1});
                NB = length(obj.CurrentScanMat{3});
            else % scan_code = 'Yz', 'yZ'
                NA = length(obj.CurrentScanMat{2});
                NB = length(obj.CurrentScanMat{3});
            end
            
            %prelocate memory for image
            handles.ConfocalScan.ImageData = zeros(NB,NA);
            handles.ConfocalScan.Diffs = zeros(NB,NA);
            
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
        end
        
        function [handles,ramp_points,i1_end, i2_end] = InitVars3D(obj,handles,scan_code)
            
            %prelocate memory for image
            handles.ConfocalScan.ImageData = zeros(length(obj.CurrentScanMat{3}),length(obj.CurrentScanMat{2}),length(obj.CurrentScanMat{1}));
            handles.ConfocalScan.Diffs = zeros(length(obj.CurrentScanMat{2}),length(obj.CurrentScanMat{1}),length(obj.CurrentScanMat{3}));
            
            if strcmp(scan_code,'Xyz')
                ramp_points = length(obj.CurrentScanMat{1});
                i1_end = length(obj.CurrentScanMat{2});
                i2_end = length(obj.CurrentScanMat{3});
            elseif strcmp(scan_code,'xYz')
                ramp_points = length(obj.CurrentScanMat{2});
                i1_end = length(obj.CurrentScanMat{1});
                i2_end = length(obj.CurrentScanMat{3});
            else %scan_code = 'xyZ'
                ramp_points = length(obj.CurrentScanMat{3});
                i1_end = length(obj.CurrentScanMat{2});
                i2_end = length(obj.CurrentScanMat{1});
            end
            
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
        end
        
        function handles = StartScan1D_original(obj,handles)
            
            % loads scanning parameters from ConfocalScan object then
            % prepares configuration of proper tasks for hardware interface
            
            obj.statuswb = 0; %no waitbar for 1D scan
            handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5; %enable SPD
            handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            NT = length(obj.CurrentScanMat{logical(obj.bEnable)})*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
            timeout = 10*NT/obj.interfaceScanning.SampleRate;
            
            %prelocate memory for image
            handles.ConfocalScan.ImageData = zeros(1,length(obj.CurrentScanMat{logical(obj.bEnable)}));
            
            % Clock line via DAQ that triggers the new counter buffer
            obj.interfaceDataAcq.CreateTask('Counter');
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT);
            %obj.interfaceDataAcq.ConfigureCounterIn('Counter',1,1,NT);
            
            %obj.interfaceDataAcq.StartTask('Counter');
            
            % ashok 22/1/14. You need to make a clock line so that the
            % counter works ok.
                 
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/obj.TrackerDwellTime,obj.TrackerDutyCycle);
            
            obj.interfaceDataAcq.StartTask('PulseTrain');
            obj.interfaceDataAcq.StartTask('Counter');
            
           
            %counts = TotalCounts/(obj.TrackerNumberOfSamples-1)/obj.TrackerDwellTime/1000; %in kcps
            
            %NSQD == normalized squared quadratic differences
           % set(handles.NSQDnumber, 'String', 'NSQD line = ');
            
            if obj.bEnable(1) % X scan
                obj.interfaceScanning.Scan(obj.CurrentScanMat{1},handles.Yinit,handles.Zinit,handles.ConfocalScan.DwellTime,1);
                handles.ConfocalScan.PiezoStability1 = 100*(handles.Yinit/obj.interfaceScanning.Pos(2)-1);
                handles.ConfocalScan.PiezoStability2 = 100*(handles.Zinit/obj.interfaceScanning.Pos(3)-1);
                plot(handles.axes_piezo_stab1,handles.ConfocalScan.PiezoStability1,'*:')
                title(handles.axes_piezo_stab1,'% deviation in y')
                plot(handles.axes_piezo_stab2,handles.ConfocalScan.PiezoStability2,'*:')
                title(handles.axes_piezo_stab2,'% deviation in z')
            elseif obj.bEnable(2) % Y scan
                obj.interfaceScanning.Scan(handles.Xinit,obj.CurrentScanMat{2},handles.Zinit,handles.ConfocalScan.DwellTime,2);
                handles.ConfocalScan.PiezoStability1 = 100*(handles.Zinit/obj.interfaceScanning.Pos(3)-1);
                handles.ConfocalScan.PiezoStability2 = 100*(handles.Xinit/obj.interfaceScanning.Pos(1)-1);
                plot(handles.axes_piezo_stab1,handles.ConfocalScan.PiezoStability1,'*:')
                title(handles.axes_piezo_stab1,'% deviation in z')
                plot(handles.axes_piezo_stab2,handles.ConfocalScan.PiezoStability2,'*:')
                title(handles.axes_piezo_stab2,'% deviation in x')
            else % Z scan
                obj.interfaceScanning.Scan(handles.Xinit,handles.Yinit,obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                handles.ConfocalScan.PiezoStability1 = 100*(handles.Xinit/obj.interfaceScanning.Pos(1)-1);
                handles.ConfocalScan.PiezoStability2 = 100*(handles.Yinit/obj.interfaceScanning.Pos(2)-1);
                plot(handles.axes_piezo_stab1,handles.ConfocalScan.PiezoStability1,'*:')
                title(handles.axes_piezo_stab1,'% deviation in x')
                plot(handles.axes_piezo_stab2,handles.ConfocalScan.PiezoStability2,'*:')
                title(handles.axes_piezo_stab2,'% deviation in y')
            end
            
            %compute normalized quadratic differences
%             b = obj.interfaceScanning.theorywaveform;
%             c = obj.interfaceScanning.realwaveform;
%             handles.ConfocalScan.Diffs = b - c; %array of differences theory - real
            
            % A is the raw data matrix
             A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout);
            obj.interfaceDataAcq.StopTask('PulseTrain');
            obj.interfaceDataAcq.StopTask('Counter');
      
           
            
            obj.interfaceDataAcq.ClearTask('PulseTrain');
            obj.interfaceDataAcq.ClearTask('Counter');
            obj.ImageRawData=A;
            
            % now we ignore all the nFlat, nOverRun, LagPts and take only the counts for the real
            % points of interest + 1 before the scan range in order to take the
            % count difference
            D = A((obj.interfaceScanning.nFlat+obj.interfaceScanning.nOverRun+obj.interfaceScanning.LagPts+1):(obj.interfaceScanning.nFlat+obj.interfaceScanning.nOverRun+obj.interfaceScanning.LagPts+length(obj.CurrentScanMat{logical(obj.bEnable)})*2*n));
            % vector D above is length(obj.CurrentScanMat{logical(obj.bEnable)})*2*n long
            % ImageData now needs to be transformed from D into a matrix which is length(obj.CurrentScanMat{logical(obj.bEnable)}) long
            handles.ConfocalScan.ImageData = obj.CalcCountRate(D, n, obj.interfaceScanning.SampleRate);
            
            % the buffer count is cumulative; Ex: it reads [1 3 6 11], where the counts for our
            % scan range of interest are 3, 6, 10. We need to make a vector "one
            % position shorter" containing the amount of counts for that position
            % only (ie, we need to take the difference). The function above takes
            % [1 3 6 11] and returns [2 3 5], which are the real counts for the
            % scan range of interest
            
            handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0; %disable SPD
            handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
            
            %update handles
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
        end
        
        
        function handles = StartScan1D_old(obj,handles)
            
            % loads scanning parameters from ConfocalScan object then
            % prepares configuration of proper tasks for hardware interface
            
            obj.statuswb = 0; %no waitbar for 1D scan
            handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5; %enable SPD
            handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            %NT = length(obj.CurrentScanMat{logical(obj.bEnable)})*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
            NT=length(obj.CurrentScanMat{logical(obj.bEnable)});
            timeout =1000* 10*NT/obj.interfaceScanning.SampleRate;
            
            %prelocate memory for image
            handles.ConfocalScan.ImageData = zeros(1,length(obj.CurrentScanMat{logical(obj.bEnable)}));
            
            % Clock line via DAQ that triggers the new counter buffer
            obj.interfaceDataAcq.CreateTask('Counter');
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT);
            %obj.interfaceDataAcq.ConfigureCounterIn('Counter',1,1,NT);
            
            %obj.interfaceDataAcq.StartTask('Counter');
            
            % ashok 22/1/14. You need to make a clock line so that the
            % counter works ok.
                 
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/handles.ConfocalScan.DwellTime,obj.TrackerDutyCycle);
            obj.interfaceDataAcq.StartTask('PulseTrain');
            
           
         

           
            
            
           
            %counts = TotalCounts/(obj.TrackerNumberOfSamples-1)/obj.TrackerDwellTime/1000; %in kcps
            
            %NSQD == normalized squared quadratic differences
           % set(handles.NSQDnumber, 'String', 'NSQD line = ');
            
            if obj.bEnable(1) % X scan
                 
                [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},handles.Yinit,handles.Zinit,handles.ConfocalScan.DwellTime,1);
                ramp_axis=1;
                obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                obj.interfaceDataAcq.StartTask('Counter');
                obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
              
                
                pause(piezo_sampletime*n_points);
             
       
                obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                  
                
%                 handles.ConfocalScan.PiezoStability1 = 100*(handles.Yinit/obj.interfaceScanning.Pos(2)-1);
%                 handles.ConfocalScan.PiezoStability2 = 100*(handles.Zinit/obj.interfaceScanning.Pos(3)-1);
%                 plot(handles.axes_piezo_stab1,handles.ConfocalScan.PiezoStability1,'*:')
%                 title(handles.axes_piezo_stab1,'% deviation in y')
%                 plot(handles.axes_piezo_stab2,handles.ConfocalScan.PiezoStability2,'*:')
%                 title(handles.axes_piezo_stab2,'% deviation in z')
            elseif obj.bEnable(2) % Y scan
                obj.interfaceScanning.Scan(handles.Xinit,obj.CurrentScanMat{2},handles.Zinit,handles.ConfocalScan.DwellTime,2);
                 

                
                
                handles.ConfocalScan.PiezoStability1 = 100*(handles.Zinit/obj.interfaceScanning.Pos(3)-1);
                handles.ConfocalScan.PiezoStability2 = 100*(handles.Xinit/obj.interfaceScanning.Pos(1)-1);
                plot(handles.axes_piezo_stab1,handles.ConfocalScan.PiezoStability1,'*:')
                title(handles.axes_piezo_stab1,'% deviation in z')
                plot(handles.axes_piezo_stab2,handles.ConfocalScan.PiezoStability2,'*:')
                title(handles.axes_piezo_stab2,'% deviation in x')
            else % Z scan
                obj.interfaceScanning.Scan(handles.Xinit,handles.Yinit,obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                handles.ConfocalScan.PiezoStability1 = 100*(handles.Xinit/obj.interfaceScanning.Pos(1)-1);
                handles.ConfocalScan.PiezoStability2 = 100*(handles.Yinit/obj.interfaceScanning.Pos(2)-1);
                plot(handles.axes_piezo_stab1,handles.ConfocalScan.PiezoStability1,'*:')
                title(handles.axes_piezo_stab1,'% deviation in x')
                plot(handles.axes_piezo_stab2,handles.ConfocalScan.PiezoStability2,'*:')
                title(handles.axes_piezo_stab2,'% deviation in y')
            end
            
            %compute normalized quadratic differences
%             b = obj.interfaceScanning.theorywaveform;
%             c = obj.interfaceScanning.realwaveform;
%             handles.ConfocalScan.Diffs = b - c; %array of differences theory - real
            %pause(5);
            % A is the raw data matrix
           
             A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout); 
        obj.interfaceDataAcq.StopTask('PulseTrain');
            obj.interfaceDataAcq.StopTask('Counter');
          
      
           
            
            obj.interfaceDataAcq.ClearTask('PulseTrain');
            obj.interfaceDataAcq.ClearTask('Counter');
            obj.ImageRawData=A;
            
           
            D = A;
            %handles.ConfocalScan.ImageData = [obj.CalcCountRate_new(D, n, 1/handles.ConfocalScan.DwellTime) 0];
            
            handles.ConfocalScan.ImageData = [diff(D)* 1/handles.ConfocalScan.DwellTime/1000 0];
            
                
%             handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0; %disable SPD
%             handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
            
            %update handles
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
        end
        
        function handles = StartScan2D_original(obj,handles)
            %tic
            % set up waitbar
            for k=1:3
                if obj.bEnable(k)
                    L(k)=length(obj.CurrentScanMat{k});
                else
                    L(k)=0;
                end
            end
            L=sort(L);
            TotEstTime=(max(obj.interfaceScanning.ADCtime,obj.interfaceScanning.DAQtime)*L(3)*2e-3+1.2630+0.5+obj.interfaceScanning.StabilizeTime)*L(2);
           
            % ashok 22/1/14
           % TotEstTime=(((handles.ConfocalScan.DwellTime)*L(3)+5e-2)*L(2));
            handles.wb = waitbar(0,['Progress of 2D Scan. Expected Scan Time: ',num2str(TotEstTime),'s']);
            obj.statuswb = 1;
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            
            if ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{2}) % XY scan, loop over Y, ramp over X
                scan_code = 'Xy';
            elseif ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{2}) % XY scan, loop over X, ramp over Y
                scan_code = 'xY';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{3}) % XZ scan, loop over Z, ramp over X
                scan_code = 'Xz';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{3}) % XZ scan, loop over X, ramp over Z
                scan_code = 'xZ';
            elseif  ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) >= length(obj.CurrentScanMat{3}) % YZ scan, loop over Z, ramp over Y
                scan_code = 'Yz';
            else % ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) < length(obj.CurrentScanMat{3}) % YZ scan, loop over Y, ramp over Z
                scan_code = 'yZ';
            end
            
            [handles,NA,NB] = obj.InitVars2D(handles,scan_code);
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                i_end = NB;
                points = NA;
            else % scan_code = 'xY', 'xZ', 'yZ'
                i_end =  NA;
                points = NB;
            end
            
            NT = points*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
            timeout = 10*NT/obj.interfaceScanning.SampleRate;
            
            handles.ConfocalScan.PiezoStability1 = zeros(i_end,1);
            handles.ConfocalScan.PiezoStability2 = zeros(i_end,1);
            

            % ashok 21/1/2014
            obj.interfaceDataAcq.CreateTask('Counter');
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT);
            
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/obj.TrackerDwellTime,obj.TrackerDutyCycle);
            
     
           %tic
            for ind = 1:1:i_end
                
                if ~obj.statuswb
                    break;
                end
                
                obj.interfaceDataAcq.StartTask('PulseTrain');
                obj.interfaceDataAcq.StartTask('Counter');
               
                if ind == 1
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)                        
                        obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                     elseif strcmp(scan_code,'xZ')
                        obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                        obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                               
                else
                    
                    if  strcmp(scan_code,'Xy')
                        obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xZ')
                        obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                        obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                end
               %toc
                
                handles = obj.PlotPiezoStability(handles,scan_code,ind,0); %last argument not used in 2D
                
                %compute normalized quadratic differences
                b = obj.interfaceScanning.theorywaveform;
                c = obj.interfaceScanning.realwaveform;
                d = sum((b - c).^2)/length(b);
                
                if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                    handles.ConfocalScan.Diffs(ind,:) = b - c; %array of differences theory - real
                else % scan_code = 'xY', 'xZ', 'yZ'
                    handles.ConfocalScan.Diffs(:,ind) = b - c; %array of differences theory - real
                end
                
                obj.DisplayNSQD(handles,scan_code,d,0); %last argument not used in 2D
               
                A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout);
                
                obj.interfaceDataAcq.StopTask('PulseTrain');
                obj.interfaceDataAcq.StopTask('Counter');
                
               
                obj.CounterRawData=A;
                
                D = A((obj.interfaceScanning.nFlat+obj.interfaceScanning.nOverRun+obj.interfaceScanning.LagPts+1):(obj.interfaceScanning.nFlat+obj.interfaceScanning.nOverRun+obj.interfaceScanning.LagPts+points*2*n));
                % vector above is points*2*n long
                % D now needs to be transformed into a points long matrix
                
                if  strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                    handles.ConfocalScan.ImageData(ind,:) = obj.CalcCountRate(D, n, obj.interfaceScanning.SampleRate);
                else % scan_code = 'xY', 'xZ', 'yZ'
                    handles.ConfocalScan.ImageData(:,ind) = obj.CalcCountRate(D, n, obj.interfaceScanning.SampleRate);
                end
                
                obj.TemporaryPlot(handles,scan_code,0); %last argument not used in 2D
                
                if obj.statuswb
                    waitbar(ind/i_end);
                else
                    close(handles.wb);
                end
             
            end
            
            
            
            
             obj.interfaceDataAcq.ClearTask('PulseTrain');
             obj.interfaceDataAcq.ClearTask('Counter');
                
            
            %update handles
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
     %toc       
        end
        
        function handles = StartScan2D_working(obj,handles)
            %tic
            % set up waitbar
            
            for k=1:3
                if obj.bEnable(k)
                    L(k)=length(obj.CurrentScanMat{k});
                else
                    L(k)=0;
                end
            end
            L=sort(L);
            TotEstTime=(max(obj.interfaceScanning.ADCtime,obj.interfaceScanning.DAQtime)*L(3)*2e-3+1.2630+0.5+obj.interfaceScanning.StabilizeTime)*L(2);
           
            handles.wb = waitbar(0,['Progress of 2D Scan. Expected Scan Time: ',num2str(TotEstTime),'s']);
            obj.statuswb = 1;
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            
            if ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{2}) % XY scan, loop over Y, ramp over X
                scan_code = 'Xy';
            elseif ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{2}) % XY scan, loop over X, ramp over Y
                scan_code = 'xY';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{3}) % XZ scan, loop over Z, ramp over X
                scan_code = 'Xz';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{3}) % XZ scan, loop over X, ramp over Z
                scan_code = 'xZ';
            elseif  ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) >= length(obj.CurrentScanMat{3}) % YZ scan, loop over Z, ramp over Y
                scan_code = 'Yz';
            else % ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) < length(obj.CurrentScanMat{3}) % YZ scan, loop over Y, ramp over Z
                scan_code = 'yZ';
            end
            
            [handles,NA,NB] = obj.InitVars2D(handles,scan_code);
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                i_end = NB;
                points = NA;
            else % scan_code = 'xY', 'xZ', 'yZ'
                i_end =  NA;
                points = NB;
            end
            
            %NT = points*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
            %NT=points;
            NT=ceil(7/5*points);
            timeout = 10*NT/obj.interfaceScanning.SampleRate;
            
            handles.ConfocalScan.PiezoStability1 = zeros(i_end,1);
            handles.ConfocalScan.PiezoStability2 = zeros(i_end,1);
            

            % ashok 21/1/2014
            obj.interfaceDataAcq.CreateTask('Counter');
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT);
            
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/handles.ConfocalScan.DwellTime,obj.TrackerDutyCycle);
            
     
           %tic
            for ind = 1:1:i_end
                
                if ~obj.statuswb
                    break;
                end
                
                obj.interfaceDataAcq.StartTask('PulseTrain');
                %obj.interfaceDataAcq.StartTask('Counter');
               clear tStart tElapsed;
                if ind == 1
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)    
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        %obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        
                        tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       tElapsed=toc(tStart);
                       
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                     elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                             
                else
                    
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)    
                       [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        
                       
                        obj.interfaceDataAcq.StartTask('Counter');
                        tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       tElapsed=toc(tStart);
                        pause(piezo_sampletime*n_points);
                       obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                       %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                         [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                         ramp_axis=2;
                         obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                         obj.interfaceDataAcq.StartTask('Counter');
                         obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                         pause(piezo_sampletime*n_points);
                         obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                         %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                   
                end
               %toc
                
                handles = obj.PlotPiezoStability(handles,scan_code,ind,0); %last argument not used in 2D
                
%                 %compute normalized quadratic differences
%                 b = obj.interfaceScanning.theorywaveform;
%                 c = obj.interfaceScanning.realwaveform;
%                 d = sum((b - c).^2)/length(b);
%                 
%                 if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
%                     handles.ConfocalScan.Diffs(ind,:) = b - c; %array of differences theory - real
%                 else % scan_code = 'xY', 'xZ', 'yZ'
%                     handles.ConfocalScan.Diffs(:,ind) = b - c; %array of differences theory - real
%                 end
%                 
%                 obj.DisplayNSQD(handles,scan_code,d,0); %last argument not used in 2D
                A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout);
                obj.interfaceDataAcq.StopTask('PulseTrain');
                obj.interfaceDataAcq.StopTask('Counter');
               
               cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
                obj.CounterRawData=A(end-points+1:end);
                %obj.CounterRawData=A;
                D = A(ceil(cut):ceil(cut)+points-1);
                %D=A;
                               
                
                if  strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                    handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                else % scan_code = 'xY', 'xZ', 'yZ'
                    handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                end
                
                obj.TemporaryPlot(handles,scan_code,0); %last argument not used in 2D
                
                if obj.statuswb
                    waitbar(ind/i_end);
                else
                    close(handles.wb);
                end
             
            end
            
            
            
            
             obj.interfaceDataAcq.ClearTask('PulseTrain');
             obj.interfaceDataAcq.ClearTask('Counter');
                
            
            %update handles
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
     %toc       
        end
        
        
         
        function handles = StartScan1D(obj,handles)
            
            % loads scanning parameters from ConfocalScan object then
            % prepares configuration of proper tasks for hardware interface
            
            obj.statuswb = 0; %no waitbar for 1D scan
            handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=5; %enable SPD
            handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            %NT = length(obj.CurrentScanMat{logical(obj.bEnable)})*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
            
            NT=length(obj.CurrentScanMat{logical(obj.bEnable)});
            %timeout = n*NT/obj.interfaceScanning.SampleRate;
            timeout=0;
            
            %prelocate memory for image
            handles.ConfocalScan.ImageData = zeros(1,length(obj.CurrentScanMat{logical(obj.bEnable)}));
            
            
            Clock_Counts=(NT*n*1/2)-1;
            % Clock line via DAQ that triggers the new counter buffer
            obj.interfaceDataAcq.CreateTask('Counter');
            %obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT*n);
            %obj.interfaceDataAcq.ConfigureCounterIn('Counter',1,1,NT*n);
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',1,1,Clock_Counts);
            
            %obj.interfaceDataAcq.StartTask('Counter');
            
            % ashok 22/1/14. You need to make a clock line so that the
            % counter works ok.
                 
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/handles.ConfocalScan.DwellTime,obj.TrackerDutyCycle);
            obj.interfaceDataAcq.StartTask('PulseTrain');
            
           
            %counts = TotalCounts/(obj.TrackerNumberOfSamples-1)/obj.TrackerDwellTime/1000; %in kcps
            
            %NSQD == normalized squared quadratic differences
           % set(handles.NSQDnumber, 'String', 'NSQD line = ');
            
            if obj.bEnable(1) % X scan
                 
                [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},handles.Yinit,handles.Zinit,handles.ConfocalScan.DwellTime,1);
                ramp_axis=1;
                obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                obj.interfaceDataAcq.StartTask('Counter');
                obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
              
                
                pause(piezo_sampletime*n_points);
                %pause(5e-1);
       
                obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                  
                
                handles.ConfocalScan.PiezoStability1 = 100*(handles.Yinit/obj.interfaceScanning.Pos(2)-1);
                handles.ConfocalScan.PiezoStability2 = 100*(handles.Zinit/obj.interfaceScanning.Pos(3)-1);
                plot(handles.axes_piezo_stab1,handles.ConfocalScan.PiezoStability1,'*:')
                title(handles.axes_piezo_stab1,'% deviation in y')
                plot(handles.axes_piezo_stab2,handles.ConfocalScan.PiezoStability2,'*:')
                title(handles.axes_piezo_stab2,'% deviation in z')
            elseif obj.bEnable(2) % Y scan
                [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(handles.Xinit,obj.CurrentScanMat{2},handles.Zinit,handles.ConfocalScan.DwellTime,2)
                ramp_axis=2;
                obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                obj.interfaceDataAcq.StartTask('Counter');
                obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
              
                
                pause(piezo_sampletime*n_points);
                %pause(5e-1);
       
                obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                  
                %obj.interfaceScanning.Scan(handles.Xinit,obj.CurrentScanMat{2},handles.Zinit,handles.ConfocalScan.DwellTime,2);
             
                handles.ConfocalScan.PiezoStability1 = 100*(handles.Zinit/obj.interfaceScanning.Pos(3)-1);
                handles.ConfocalScan.PiezoStability2 = 100*(handles.Xinit/obj.interfaceScanning.Pos(1)-1);
                plot(handles.axes_piezo_stab1,handles.ConfocalScan.PiezoStability1,'*:')
                title(handles.axes_piezo_stab1,'% deviation in z')
                plot(handles.axes_piezo_stab2,handles.ConfocalScan.PiezoStability2,'*:')
                title(handles.axes_piezo_stab2,'% deviation in x')
            else % Z scan
                 
                [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(handles.Xinit,handles.Yinit,obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                ramp_axis=3;
                obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                obj.interfaceDataAcq.StartTask('Counter');
                obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
              
                
                pause(piezo_sampletime*n_points);
                %pause(5e-1);
       
                obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                  
                %obj.interfaceScanning.Scan(handles.Xinit,handles.Yinit,obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                handles.ConfocalScan.PiezoStability1 = 100*(handles.Xinit/obj.interfaceScanning.Pos(1)-1);
                handles.ConfocalScan.PiezoStability2 = 100*(handles.Yinit/obj.interfaceScanning.Pos(2)-1);
                plot(handles.axes_piezo_stab1,handles.ConfocalScan.PiezoStability1,'*:')
                title(handles.axes_piezo_stab1,'% deviation in x')
                plot(handles.axes_piezo_stab2,handles.ConfocalScan.PiezoStability2,'*:')
                title(handles.axes_piezo_stab2,'% deviation in y')
            end
            
            %compute normalized quadratic differences
%             b = obj.interfaceScanning.theorywaveform;
%             c = obj.interfaceScanning.realwaveform;
%             handles.ConfocalScan.Diffs = b - c; %array of differences theory - real
            %pause(5);
            
            % A is the raw data matrix
           
             %A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT*n,timeout); 
             A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',Clock_Counts,timeout); 
             %if n==2  
                A=[A A(end)];
             %else if   
             %end
             length_A=size(A,2);
             B=A;
             SUM_A=[];
             
             if (n>1) 
                 c=n/2;
             for i=1:length_A/c
                 s=0;
                 for j=1:c
                 s=s+B(j);
                 SUM_A(i)=ceil(s/c);  
                 end
             B=B(c+1:end);
             end
             
             end
%              c=n/2;
%              for i=1:length_A/c
%                  s=0;
%                  for j=1:c
%                  s=s+B(j);
%                  SUM_A(i)=s/c;  
%                  end
%              B=B(c+1:end);
%              end 
%             switch (n)
%                  
%                  case 10
%                      c=10/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%                      
%                  case 20
%                      c=20/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%              end 
             
            A=SUM_A;
            obj.interfaceDataAcq.StopTask('PulseTrain');
            obj.interfaceDataAcq.StopTask('Counter');
          
            obj.interfaceDataAcq.ClearTask('PulseTrain');
            obj.interfaceDataAcq.ClearTask('Counter');
            obj.ImageRawData=A;
            
           
            D = A;
            %handles.ConfocalScan.ImageData = [obj.CalcCountRate_new(D, n, 1/handles.ConfocalScan.DwellTime) 0];
             handles.ConfocalScan.ImageData = obj.CalcCountRate(D, n, obj.interfaceScanning.SampleRate);
            
            %handles.ConfocalScan.ImageData = [diff(D)* 1/handles.ConfocalScan.DwellTime/1000 0];
            
                
%             handles.ImagingFunctions.interfaceDataAcq.AnalogOutVoltages(1)=0; %disable SPD
%             handles.ImagingFunctions.interfaceDataAcq.WriteAnalogOutLine(1);
            
            %update handles
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
        end
        
        function handles = StartScan2D(obj,handles)
            %tic
            % set up waitbar
            
            for k=1:3
                if obj.bEnable(k)
                    L(k)=length(obj.CurrentScanMat{k});
                else
                    L(k)=0;
                end
            end
            L=sort(L);
            TotEstTime=(max(obj.interfaceScanning.ADCtime,obj.interfaceScanning.DAQtime)*L(3)*2e-3+1.2630+0.5+obj.interfaceScanning.StabilizeTime)*L(2);
           
            handles.wb = waitbar(0,['Progress of 2D Scan. Expected Scan Time: ',num2str(TotEstTime),'s']);
            obj.statuswb = 1;
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            
            if ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{2}) % XY scan, loop over Y, ramp over X
                scan_code = 'Xy';
            elseif ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{2}) % XY scan, loop over X, ramp over Y
                scan_code = 'xY';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{3}) % XZ scan, loop over Z, ramp over X
                scan_code = 'Xz';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{3}) % XZ scan, loop over X, ramp over Z
                scan_code = 'xZ';
            elseif  ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) >= length(obj.CurrentScanMat{3}) % YZ scan, loop over Z, ramp over Y
                scan_code = 'Yz';
            else % ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) < length(obj.CurrentScanMat{3}) % YZ scan, loop over Y, ramp over Z
                scan_code = 'yZ';
            end
            
            [handles,NA,NB] = obj.InitVars2D(handles,scan_code);
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                i_end = NB;
                points = NA;
            else % scan_code = 'xY', 'xZ', 'yZ'
                i_end =  NA;
                points = NB;
            end
            
            %NT = points*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
            NT=points;
            %NT=ceil(5/5*points);
            timeout = 10*NT/obj.interfaceScanning.SampleRate;
            
            handles.ConfocalScan.PiezoStability1 = zeros(i_end,1);
            handles.ConfocalScan.PiezoStability2 = zeros(i_end,1);
            
            Clock_Counts=(NT*n*1/2)-1;
% Clock line via DAQ that triggers the new counter buffer
            obj.interfaceDataAcq.CreateTask('Counter');
            %obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT*n);
            %obj.interfaceDataAcq.ConfigureCounterIn('Counter',1,1,NT*n);
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',1,1,Clock_Counts);
            
            %obj.interfaceDataAcq.StartTask('Counter');
            
            % ashok 22/1/14. You need to make a clock line so that the
            % counter works ok.
                 
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/handles.ConfocalScan.DwellTime,obj.TrackerDutyCycle);
            obj.interfaceDataAcq.StartTask('PulseTrain');
            
           
            % ashok 21/1/2014
            %obj.interfaceDataAcq.CreateTask('Counter');
            %obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT);
             %obj.interfaceDataAcq.ConfigureCounterIn('Counter',1,1,Clock_Counts);
           
            %obj.interfaceDataAcq.CreateTask('PulseTrain');
            %obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/handles.ConfocalScan.DwellTime,obj.TrackerDutyCycle);
            
     
           %tic
            for ind = 1:1:i_end
                
                if ~obj.statuswb
                    break;
                end
                
                %obj.interfaceDataAcq.StartTask('PulseTrain');
                %obj.interfaceDataAcq.StartTask('Counter');
               clear tStart tElapsed;
                if ind == 1
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)    
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        %obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        
                        tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       tElapsed=toc(tStart);
                       
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                     elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                             
                else
                    
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)    
                       [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        
                       
                        obj.interfaceDataAcq.StartTask('Counter');
                        tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       tElapsed=toc(tStart);
                        pause(piezo_sampletime*n_points);
                       obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                       %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                         [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                         ramp_axis=2;
                         obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                         obj.interfaceDataAcq.StartTask('Counter');
                         obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                         pause(piezo_sampletime*n_points);
                         obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                         %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                   
                end
               %toc
                
                handles = obj.PlotPiezoStability(handles,scan_code,ind,0); %last argument not used in 2D
                
%                 %compute normalized quadratic differences
%                 b = obj.interfaceScanning.theorywaveform;
%                 c = obj.interfaceScanning.realwaveform;
%                 d = sum((b - c).^2)/length(b);
%                 
%                 if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
%                     handles.ConfocalScan.Diffs(ind,:) = b - c; %array of differences theory - real
%                 else % scan_code = 'xY', 'xZ', 'yZ'
%                     handles.ConfocalScan.Diffs(:,ind) = b - c; %array of differences theory - real
%                 end
%                 
%                 obj.DisplayNSQD(handles,scan_code,d,0); %last argument not used in 2D
%                 A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout);
%                 obj.interfaceDataAcq.StopTask('PulseTrain');
%                 obj.interfaceDataAcq.StopTask('Counter');
%                
%                %cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
%                 %obj.CounterRawData=A(end-points+1:end);
%                 obj.CounterRawData=A;
%                 %D = A(ceil(cut):ceil(cut)+points-1);
%                 D=A;
                    A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',Clock_Counts,timeout); 
             %if n==2  
                A=[A A(end)];
             %else if   
             %end
             length_A=size(A,2);
             B=A;
             SUM_A=[];
             
             if (n>1) 
                 c=n/2;
             for i=1:length_A/c
                 s=0;
                 for j=1:c
                 s=s+B(j);
                 SUM_A(i)=ceil(s/c);  
                 end
             B=B(c+1:end);
             end
             
             end
%              c=n/2;
%              for i=1:length_A/c
%                  s=0;
%                  for j=1:c
%                  s=s+B(j);
%                  SUM_A(i)=s/c;  
%                  end
%              B=B(c+1:end);
%              end 
%             switch (n)
%                  
%                  case 10
%                      c=10/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%                      
%                  case 20
%                      c=20/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%              end 
             
            A=SUM_A;
            obj.interfaceDataAcq.StopTask('PulseTrain');
            obj.interfaceDataAcq.StopTask('Counter');
          
            obj.interfaceDataAcq.ClearTask('PulseTrain');
            obj.interfaceDataAcq.ClearTask('Counter');
            obj.ImageRawData=A;
            
           
            D = A;            
                
                if  strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                    handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                else % scan_code = 'xY', 'xZ', 'yZ'
                    handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                end
                
                obj.TemporaryPlot(handles,scan_code,0); %last argument not used in 2D
                
                if obj.statuswb
                    waitbar(ind/i_end);
                else
                    close(handles.wb);
                end
             
            end
            
            
            
            
             obj.interfaceDataAcq.ClearTask('PulseTrain');
             obj.interfaceDataAcq.ClearTask('Counter');
                
            
            %update handles
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
     %toc       
        end
        
        
       
        function handles = StartScan2D_new(obj,handles)
            %tic
            % set up waitbar
            
            for k=1:3
                if obj.bEnable(k)
                    L(k)=length(obj.CurrentScanMat{k});
                else
                    L(k)=0;
                end
            end
            L=sort(L);
            TotEstTime=(max(obj.interfaceScanning.ADCtime,obj.interfaceScanning.DAQtime)*L(3)*2e-3+1.2630+0.5+obj.interfaceScanning.StabilizeTime)*L(2);
           
            handles.wb = waitbar(0,['Progress of 2D Scan. Expected Scan Time: ',num2str(TotEstTime),'s']);
            obj.statuswb = 1;
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            
            if ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{2}) % XY scan, loop over Y, ramp over X
                scan_code = 'Xy';
            elseif ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{2}) % XY scan, loop over X, ramp over Y
                scan_code = 'xY';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{3}) % XZ scan, loop over Z, ramp over X
                scan_code = 'Xz';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{3}) % XZ scan, loop over X, ramp over Z
                scan_code = 'xZ';
            elseif  ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) >= length(obj.CurrentScanMat{3}) % YZ scan, loop over Z, ramp over Y
                scan_code = 'Yz';
            else % ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) < length(obj.CurrentScanMat{3}) % YZ scan, loop over Y, ramp over Z
                scan_code = 'yZ';
            end
            
            [handles,NA,NB] = obj.InitVars2D(handles,scan_code);
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                i_end = NB;
                points = NA;
            else % scan_code = 'xY', 'xZ', 'yZ'
                i_end =  NA;
                points = NB;
            end
            
            %NT = points*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
            NT=points;
            Clock_Counts=(NT*n*1/2)-1;
            %NT=ceil(7/5*points);
            timeout = 10*NT/obj.interfaceScanning.SampleRate;
            %timeout=0;
            
            handles.ConfocalScan.PiezoStability1 = zeros(i_end,1);
            handles.ConfocalScan.PiezoStability2 = zeros(i_end,1);
            

            % ashok 21/1/2014
            obj.interfaceDataAcq.CreateTask('Counter');
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,Clock_Counts);
            
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/handles.ConfocalScan.DwellTime,obj.TrackerDutyCycle);
            
     
           %tic
            for ind = 1:1:i_end
                
                if ~obj.statuswb
                    break;
                end
                
                obj.interfaceDataAcq.StartTask('PulseTrain');
                %obj.interfaceDataAcq.StartTask('Counter');
               clear tStart tElapsed;
                if ind == 1
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)    
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        %obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        
                        %tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       %tElapsed=toc(tStart);
                       
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                     elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                             
                else
                    
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)    
                       [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        
                       
                        obj.interfaceDataAcq.StartTask('Counter');
                        %tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       %tElapsed=toc(tStart);
                        pause(piezo_sampletime*n_points);
                       obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                       %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                         [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                         ramp_axis=2;
                         obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                         obj.interfaceDataAcq.StartTask('Counter');
                         obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                         pause(piezo_sampletime*n_points);
                         obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                         %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                   
                end
               %toc
                
                handles = obj.PlotPiezoStability(handles,scan_code,ind,0); %last argument not used in 2D
                
%                 %compute normalized quadratic differences
%                 b = obj.interfaceScanning.theorywaveform;
%                 c = obj.interfaceScanning.realwaveform;
%                 d = sum((b - c).^2)/length(b);
%                 
%                 if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
%                     handles.ConfocalScan.Diffs(ind,:) = b - c; %array of differences theory - real
%                 else % scan_code = 'xY', 'xZ', 'yZ'
%                     handles.ConfocalScan.Diffs(:,ind) = b - c; %array of differences theory - real
%                 end
%                 
%                 obj.DisplayNSQD(handles,scan_code,d,0); %last argument not used in 2D
%                 A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',Clock_Counts,timeout);
%                 obj.interfaceDataAcq.StopTask('PulseTrain');
%                 obj.interfaceDataAcq.StopTask('Counter');
%                
               %cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
                %obj.CounterRawData=A(end-points+1:end);
%                 obj.CounterRawData=A;
%                 %D = A(ceil(cut):ceil(cut)+points-1);
%                 D=A;
                               
                
                
                A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',Clock_Counts,timeout);
                pause(piezo_sampletime*n_points);
                obj.interfaceDataAcq.StopTask('PulseTrain');
                obj.interfaceDataAcq.StopTask('Counter');
               %if n==2  
                A=[A A(end)];
             %else if   
             %end
             length_A=size(A,2);
             B=A;
             SUM_A=[];
%              
%              c=n/2;
%              for i=1:length_A/c
%                  s=0;
%                  for j=1:c
%                  s=s+B(j);
%                  SUM_A(i)=s/c;  
%                  end
%              B=B(c+1:end);
%              end 
%              
             

             if (n>1) 
                 c=n/2;
             for i=1:length_A/c
                 s=0;
                 for j=1:c
                 s=s+B(j);
                 SUM_A(i)=ceil(s/c);  
                 end
             B=B(c+1:end);
             end
%              else
%                  SUM_A=B;
             end
%              switch (n)
%                  
%                  case 2
%                      c=2/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%                      
%                  case 10
%                      c=10/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%                      
%                  case 20
%                      c=20/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%              end 
%              
            A=SUM_A;
                
               
%                cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
%                 obj.CounterRawData=A(end-points+1:end);
%                 D = A(ceil(cut):ceil(cut)+points-1);                
%                 
                
               %cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
                %obj.CounterRawData=A;
               %obj.CounterRawData=A(points_extra+1:end);
               %D=A(points_extra+1:end);
                D=A;
                
                if  strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                    handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                    %handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime)];
                else % scan_code = 'xY', 'xZ', 'yZ'
                    handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                    %handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime)];
                end
                
                obj.TemporaryPlot(handles,scan_code,0); %last argument not used in 2D
                
%                 if  strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
%                     %handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
%                     handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime)];
%                     
%                 else % scan_code = 'xY', 'xZ', 'yZ'
%                     %handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
%                handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime)];
%                 end
%                 
%                 obj.TemporaryPlot(handles,scan_code,0); %last argument not used in 2D
%                 
                if obj.statuswb
                    waitbar(ind/i_end);
                else
                    close(handles.wb);
                end
             
            end
            
            
            
            
             obj.interfaceDataAcq.ClearTask('PulseTrain');
             obj.interfaceDataAcq.ClearTask('Counter');
                
            
            %update handles
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
     %toc       
        end
         
       
        function handles = StartScan2D_old(obj,handles)
            %tic
            % set up waitbar
            
            for k=1:3
                if obj.bEnable(k)
                    L(k)=length(obj.CurrentScanMat{k});
                else
                    L(k)=0;
                end
            end
            L=sort(L);
            TotEstTime=(max(obj.interfaceScanning.ADCtime,obj.interfaceScanning.DAQtime)*L(3)*2e-3+1.2630+0.5+obj.interfaceScanning.StabilizeTime)*L(2);
           
            handles.wb = waitbar(0,['Progress of 2D Scan. Expected Scan Time: ',num2str(TotEstTime),'s']);
            obj.statuswb = 1;
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            
            if ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{2}) % XY scan, loop over Y, ramp over X
                scan_code = 'Xy';
            elseif ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{2}) % XY scan, loop over X, ramp over Y
                scan_code = 'xY';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{3}) % XZ scan, loop over Z, ramp over X
                scan_code = 'Xz';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{3}) % XZ scan, loop over X, ramp over Z
                scan_code = 'xZ';
            elseif  ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) >= length(obj.CurrentScanMat{3}) % YZ scan, loop over Z, ramp over Y
                scan_code = 'Yz';
            else % ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) < length(obj.CurrentScanMat{3}) % YZ scan, loop over Y, ramp over Z
                scan_code = 'yZ';
            end
            
            [handles,NA,NB] = obj.InitVars2D(handles,scan_code);
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                i_end = NB;
                points = NA;
            else % scan_code = 'xY', 'xZ', 'yZ'
                i_end =  NA;
                points = NB;
            end
             NT=points;
            %NT=ceil(7/5*points);
            Clock_Counts=(NT*n*1/2)-1;
            
            %timeout = n*NT/obj.interfaceScanning.SampleRate;
            timeout=0;
            
            handles.ConfocalScan.PiezoStability1 = zeros(i_end,1);
            handles.ConfocalScan.PiezoStability2 = zeros(i_end,1);
            

            % ashok 21/1/2014
            obj.interfaceDataAcq.CreateTask('Counter');
             obj.interfaceDataAcq.ConfigureCounterIn('Counter',1,1,Clock_Counts);
            %obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,Clock_Counts);
            
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/handles.ConfocalScan.DwellTime,obj.TrackerDutyCycle);
            
     
           %tic
            for ind = 1:1:i_end
                
                if ~obj.statuswb
                    break;
                end
                
                obj.interfaceDataAcq.StartTask('PulseTrain');
                %obj.interfaceDataAcq.StartTask('Counter');
               %clear tStart tElapsed;
                if ind == 1
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)    
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        %obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        
                        %tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       %tElapsed=toc(tStart);
                       
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                     elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                             
                else
                    
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)    
                       [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        
                       
                        obj.interfaceDataAcq.StartTask('Counter');
                        tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       tElapsed=toc(tStart);
                        pause(piezo_sampletime*n_points);
                       obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                       %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                         [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                         ramp_axis=2;
                         obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                         obj.interfaceDataAcq.StartTask('Counter');
                         obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                         pause(piezo_sampletime*n_points);
                         obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                         %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                   
                end
               %toc
                
                handles = obj.PlotPiezoStability(handles,scan_code,ind,0); %last argument not used in 2D
                
%                 %compute normalized quadratic differences
%                 b = obj.interfaceScanning.theorywaveform;
%                 c = obj.interfaceScanning.realwaveform;
%                 d = sum((b - c).^2)/length(b);
%                 
%                 if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
%                     handles.ConfocalScan.Diffs(ind,:) = b - c; %array of differences theory - real
%                 else % scan_code = 'xY', 'xZ', 'yZ'
%                     handles.ConfocalScan.Diffs(:,ind) = b - c; %array of differences theory - real
%                 end
%                 
%                 obj.DisplayNSQD(handles,scan_code,d,0); %last argument not used in 2D
%                 A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout);
%                 obj.interfaceDataAcq.StopTask('PulseTrain');
%                 obj.interfaceDataAcq.StopTask('Counter');
%                
%                cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
%                 obj.CounterRawData=A(end-points+1:end);
%                 %obj.CounterRawData=A;
%                 D = A(ceil(cut):ceil(cut)+points-1);
                %D=A;
                               
                A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',Clock_Counts,timeout);
                obj.interfaceDataAcq.StopTask('PulseTrain');
                obj.interfaceDataAcq.StopTask('Counter');
               %if n==2  
                A=[A A(end)];
             %else if   
             %end
             length_A=size(A,2);
             B=A;
             SUM_A=[];
%              
%              c=n/2;
%              for i=1:length_A/c
%                  s=0;
%                  for j=1:c
%                  s=s+B(j);
%                  SUM_A(i)=s/c;  
%                  end
%              B=B(c+1:end);
%              end 
%              
             

             if (n>1) 
                 c=n/2;
             for i=1:length_A/c
                 s=0;
                 for j=1:c
                 s=s+B(j);
                 SUM_A(i)=ceil(s/c);  
                 end
             B=B(c+1:end);
             end
%              else
%                  SUM_A=B;
             end
%              switch (n)
%                  
%                  case 2
%                      c=2/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%                      
%                  case 10
%                      c=10/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%                      
%                  case 20
%                      c=20/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%              end 
%              
            A=SUM_A;
                
               
%                cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
%                 obj.CounterRawData=A(end-points+1:end);
%                 D = A(ceil(cut):ceil(cut)+points-1);                
%                 
                
               %cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
                obj.CounterRawData=A;
               %obj.CounterRawData=A(points_extra+1:end);
               %D=A(points_extra+1:end);
               D=A;
                if  strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                    handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                else % scan_code = 'xY', 'xZ', 'yZ'
                    handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                end
                
                obj.TemporaryPlot(handles,scan_code,0); %last argument not used in 2D
                
                if obj.statuswb
                    waitbar(ind/i_end);
                else
                    close(handles.wb);
                end
             
            end
            
            
            
            
             obj.interfaceDataAcq.ClearTask('PulseTrain');
             obj.interfaceDataAcq.ClearTask('Counter');
                
            
            %update handles
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
     %toc       
        end
        
        function handles = StartScan2D_new2(obj,handles)
            %tic
            % set up waitbar
            
            for k=1:3
                if obj.bEnable(k)
                    L(k)=length(obj.CurrentScanMat{k});
                else
                    L(k)=0;
                end
            end
            L=sort(L);
            TotEstTime=(max(obj.interfaceScanning.ADCtime,obj.interfaceScanning.DAQtime)*L(3)*2e-3+1.2630+0.5+obj.interfaceScanning.StabilizeTime)*L(2);
           
            handles.wb = waitbar(0,['Progress of 2D Scan. Expected Scan Time: ',num2str(TotEstTime),'s']);
            obj.statuswb = 1;
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            
            if ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{2}) % XY scan, loop over Y, ramp over X
                scan_code = 'Xy';
            elseif ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{2}) % XY scan, loop over X, ramp over Y
                scan_code = 'xY';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{3}) % XZ scan, loop over Z, ramp over X
                scan_code = 'Xz';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{3}) % XZ scan, loop over X, ramp over Z
                scan_code = 'xZ';
            elseif  ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) >= length(obj.CurrentScanMat{3}) % YZ scan, loop over Z, ramp over Y
                scan_code = 'Yz';
            else % ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) < length(obj.CurrentScanMat{3}) % YZ scan, loop over Y, ramp over Z
                scan_code = 'yZ';
            end
            
            [handles,NA,NB] = obj.InitVars2D(handles,scan_code);
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                i_end = NB;
                points = NA;
            else % scan_code = 'xY', 'xZ', 'yZ'
                i_end =  NA;
                points = NB;
            end
            
            %NT = points*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
           % NT = points*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
           
           %stablize_time=20e-3; %time for piezo to reach const velocity
           stablize_time=0; %time for piezo to reach const velocity
           points_extra= ceil(stablize_time/handles.ConfocalScan.DwellTime); %these are the extra points we add on the left side of the waveform
           points=points+points_extra;
           
            NT=points;
            %NT=ceil(7/5*points);
            Clock_Counts=(NT*n*1/2)-1;
            %timeout = n*NT/obj.interfaceScanning.SampleRate;
            timeout=0;
            
            handles.ConfocalScan.PiezoStability1 = zeros(i_end,1);
            handles.ConfocalScan.PiezoStability2 = zeros(i_end,1);
            

            % ashok 21/1/2014
            obj.interfaceDataAcq.CreateTask('Counter');
            %obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT);
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',1,1,Clock_Counts);
            
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/handles.ConfocalScan.DwellTime,obj.TrackerDutyCycle);
          
            for ind = 1:1:i_end
                
                if ~obj.statuswb
                    break;
                end
                
                obj.interfaceDataAcq.StartTask('PulseTrain');
                %obj.interfaceDataAcq.StartTask('Counter');
               clear tStart tElapsed;
              
                if ind == 1
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)  
                       % obj.CurrentScanMat{1}(1)=obj.CurrentScanMat{1}(1)-points_extra; %shift scan region left by extra points
                       slope=obj.CurrentScanMat{1}(2)-obj.CurrentScanMat{1}(1);
                       extra_array=linspace(obj.CurrentScanMat{1}(1)-slope*points_extra,obj.CurrentScanMat{1}(1)-slope,points_extra);
                       % obj.CurrentScanMat{1}=[extra_array obj.CurrentScanMat{1}]; %shift scan region left by extra points
                        NewScan=[extra_array obj.CurrentScanMat{1}]; %shift scan region left by extra points
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(NewScan,obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        %obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        
                        %tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       %tElapsed=toc(tStart);
                       
                        pause(piezo_sampletime*n_points);
                        %pause(piezo_sampletime*NT);
                        
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                     elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                             
                else
                    
                    if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)   
                      slope=obj.CurrentScanMat{1}(2)-obj.CurrentScanMat{1}(1);
                       extra_array=linspace(obj.CurrentScanMat{1}(1)-slope*points_extra,obj.CurrentScanMat{1}(1)-slope,points_extra);
                       % obj.CurrentScanMat{1}=[extra_array obj.CurrentScanMat{1}]; %shift scan region left by extra points
                        NewScan=[extra_array obj.CurrentScanMat{1}]; %shift scan region left by extra points
                        
                       [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(NewScan,obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        %tStart = tic;
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                       %tElapsed=toc(tStart);
                        pause(piezo_sampletime*n_points);
                        %pause(piezo_sampletime*NT);
                       obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                       %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(ind),obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xY')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                        ramp_axis=2;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                        ramp_axis=1;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                    elseif strcmp(scan_code,'xZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                         [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                         ramp_axis=2;
                         obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                         obj.interfaceDataAcq.StartTask('Counter');
                         obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                         pause(piezo_sampletime*n_points);
                         obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                         %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        [n_points,piezo_sampletime]=obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        ramp_axis=3;
                        obj.interfaceScanning.WAVETABLE_ENABLE(1,ramp_axis);
                        obj.interfaceDataAcq.StartTask('Counter');
                        obj.interfaceScanning.WAVETABLE_ACTIVE(1,ramp_axis);
                        pause(piezo_sampletime*n_points);
                        obj.interfaceScanning.WAVETABLE_ENABLE(0,ramp_axis);
                        %obj.interfaceScanning.Trigg(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    end
                    
                   
                end
               %toc
                
                handles = obj.PlotPiezoStability(handles,scan_code,ind,0); %last argument not used in 2D
                
%                 %compute normalized quadratic differences
%                 b = obj.interfaceScanning.theorywaveform;
%                 c = obj.interfaceScanning.realwaveform;
%                 d = sum((b - c).^2)/length(b);
%                 
%                 if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
%                     handles.ConfocalScan.Diffs(ind,:) = b - c; %array of differences theory - real
%                 else % scan_code = 'xY', 'xZ', 'yZ'
%                     handles.ConfocalScan.Diffs(:,ind) = b - c; %array of differences theory - real
%                 end
%                 
%                 obj.DisplayNSQD(handles,scan_code,d,0); %last argument not used in 2D
                A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',Clock_Counts,timeout);
                obj.interfaceDataAcq.StopTask('PulseTrain');
                obj.interfaceDataAcq.StopTask('Counter');
               %if n==2  
                A=[A A(end)];
             %else if   
             %end
             length_A=size(A,2);
             B=A;
             SUM_A=[];
%              
%              c=n/2;
%              for i=1:length_A/c
%                  s=0;
%                  for j=1:c
%                  s=s+B(j);
%                  SUM_A(i)=s/c;  
%                  end
%              B=B(c+1:end);
%              end 
%              
             

             if (n>1) 
                 c=n/2;
             for i=1:length_A/c
                 s=0;
                 for j=1:c
                 s=s+B(j);
                 SUM_A(i)=ceil(s/c);  
                 end
             B=B(c+1:end);
             end
%              else
%                  SUM_A=B;
             end
%              switch (n)
%                  
%                  case 2
%                      c=2/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%                      
%                  case 10
%                      c=10/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%                      
%                  case 20
%                      c=20/2;
%                      for i=1:length_A/c
%                          s=0;
%                          for j=1:c
%                              s=s+B(j);
%                          SUM_A(i)=s/c;  
%                          end
%                          B=B(c+1:end);
%                          
%                      end 
%              end 
%              
            A=SUM_A;
                
               
%                cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
%                 obj.CounterRawData=A(end-points+1:end);
%                 D = A(ceil(cut):ceil(cut)+points-1);                
%                 
                
               %cut=tElapsed*(1/handles.ConfocalScan.DwellTime);
                %obj.CounterRawData=A;
               obj.CounterRawData=A(points_extra+1:end);
               D=A(points_extra+1:end);
                
%                 if  strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
%                     handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate_new(D, n, 1/handles.ConfocalScan.DwellTime) 0];
%                 else % scan_code = 'xY', 'xZ', 'yZ'
%                     handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate_new(D, n, 1/handles.ConfocalScan.DwellTime) 0];
%                 end
                
                if  strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                    handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                    %handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime)];
                else % scan_code = 'xY', 'xZ', 'yZ'
                    handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                    %handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate(D, n, 1/handles.ConfocalScan.DwellTime)];
                end
                
                obj.TemporaryPlot(handles,scan_code,0); %last argument not used in 2D
                
                if obj.statuswb
                    waitbar(ind/i_end);
                else
                    close(handles.wb);
                end
             
            end
            
             obj.interfaceDataAcq.ClearTask('PulseTrain');
             obj.interfaceDataAcq.ClearTask('Counter');
                
            
            %update handles
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
     %toc       
        end
        
        
         function handles = SLOW_StartScan2D(obj,handles)
            %tic
            % set up waitbar
            
            for k=1:3
                if obj.bEnable(k)
                    L(k)=length(obj.CurrentScanMat{k});
                else
                    L(k)=0;
                end
            end
            L=sort(L);
            TotEstTime=(max(obj.interfaceScanning.ADCtime,obj.interfaceScanning.DAQtime)*L(3)*2e-3+1.2630+0.5+obj.interfaceScanning.StabilizeTime)*L(2);
           
            handles.wb = waitbar(0,['Progress of 2D Scan. Expected Scan Time: ',num2str(TotEstTime),'s']);
            obj.statuswb = 1;
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            
            if ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{2}) % XY scan, loop over Y, ramp over X
                scan_code = 'Xy';
            elseif ~obj.bEnable(3)  && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{2}) % XY scan, loop over X, ramp over Y
                scan_code = 'xY';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{3}) % XZ scan, loop over Z, ramp over X
                scan_code = 'Xz';
            elseif ~obj.bEnable(2) && length(obj.CurrentScanMat{1}) < length(obj.CurrentScanMat{3}) % XZ scan, loop over X, ramp over Z
                scan_code = 'xZ';
            elseif  ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) >= length(obj.CurrentScanMat{3}) % YZ scan, loop over Z, ramp over Y
                scan_code = 'Yz';
            else % ~obj.bEnable(1) && length(obj.CurrentScanMat{2}) < length(obj.CurrentScanMat{3}) % YZ scan, loop over Y, ramp over Z
                scan_code = 'yZ';
            end
            
            [handles,NA,NB] = obj.InitVars2D(handles,scan_code);
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                i_end = NB;
                points = NA;
            else % scan_code = 'xY', 'xZ', 'yZ'
                i_end =  NA;
                points = NB;
            end
            
            %NT = points*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
            NT=points;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WORKING UNCOMMENT
            %NT=ceil(7/5*points);
            
            timeout = 10*NT/obj.interfaceScanning.SampleRate;
            
            handles.ConfocalScan.PiezoStability1 = zeros(i_end,1);
            handles.ConfocalScan.PiezoStability2 = zeros(i_end,1);
            

            % ashok 21/1/2014
            obj.interfaceDataAcq.CreateTask('Counter');
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT);
            
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/handles.ConfocalScan.DwellTime,obj.TrackerDutyCycle);
            
           for ind = 1:1:i_end
                
                if ~obj.statuswb
                    break;
                end
                
                
                
               clear tStart tElapsed;
%                  obj.interfaceDataAcq.StartTask('PulseTrain');
%                 obj.interfaceDataAcq.StartTask('Counter');
                       
               if  strcmp(scan_code,'Xy') %Scan(obj, X,Y,Z, TPixel, ramp_axis)
                        
                   A=0;
                        obj.interfaceScanning.Mov(obj.CurrentScanMat{2}(ind),2);
                        initial=round(obj.CurrentScanMat{1}(1));
                        final=round(obj.CurrentScanMat{1}(end));
                        for j=initial:((final-initial)/NT):final
                       %tStart = tic;
                      
                       
                       obj.interfaceScanning.Mov(j,1);  
                       obj.interfaceDataAcq.StartTask('PulseTrain');
                       obj.interfaceDataAcq.StartTask('Counter');
                       pause(handles.ConfocalScan.DwellTime)
                       %pause(2.4e-6)
                       handles = obj.PlotPiezoStability(handles,scan_code,ind,0); %last argument not used in 2D 
                       %A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout);
                      
                       A =[A obj.interfaceDataAcq.ReadCounterBuffer('Counter',1,timeout)];
                       
                       obj.interfaceDataAcq.StopTask('PulseTrain');
                       obj.interfaceDataAcq.StopTask('Counter');
                       
                       %tElapsed=toc(tStart)
                                         
                         
                        end
                       
                        
                        elseif strcmp(scan_code,'xY')
                         
                        %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.CurrentScanMat{2},obj.interfaceScanning.Pos(3),handles.ConfocalScan.DwellTime,2);
                    elseif strcmp(scan_code,'Xz')
                         %obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,1);
                     elseif strcmp(scan_code,'xZ')
                         %obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(ind),obj.interfaceScanning.Pos(2),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                    elseif strcmp(scan_code,'Yz')
                         %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(ind),handles.ConfocalScan.DwellTime,2);
                    else % strcmp(scan_code,'yZ')
                        %obj.interfaceScanning.Scan(obj.interfaceScanning.Pos(1),obj.CurrentScanMat{2}(ind),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                end
                              
                %handles = obj.PlotPiezoStability(handles,scan_code,ind,0); %last argument not used in 2D
                             
%                 A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout);
%                 obj.interfaceDataAcq.StopTask('PulseTrain');
%                 obj.interfaceDataAcq.StopTask('Counter');
%                
                             
%                  handles = obj.PlotPiezoStability(handles,scan_code,ind,0); %last argument not used in 2D 
%                        A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout);
%                       
%                        %A =[A obj.interfaceDataAcq.ReadCounterBuffer('Counter',1,timeout)];
%                        
%                        obj.interfaceDataAcq.StopTask('PulseTrain');
%                        obj.interfaceDataAcq.StopTask('Counter');
%                  obj.CounterRawData=A;
%                       D=A;

                      obj.CounterRawData=A(3:end);
                      D=A(3:end);
                               
                
                if  strcmp(scan_code,'Xy') || strcmp(scan_code,'Xz') || strcmp(scan_code,'Yz')
                    handles.ConfocalScan.ImageData(ind,:) = [obj.CalcCountRate_new(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                else % scan_code = 'xY', 'xZ', 'yZ'
                    handles.ConfocalScan.ImageData(:,ind) = [obj.CalcCountRate_new(D, n, 1/handles.ConfocalScan.DwellTime) 0];
                end
                 obj.TemporaryPlot(handles,scan_code,0); %last argument not used in 2D
               
                
                if obj.statuswb
                    waitbar(ind/i_end);
                else
                    close(handles.wb);
                end
             
            end
            
            
            
            
             obj.interfaceDataAcq.ClearTask('PulseTrain');
             obj.interfaceDataAcq.ClearTask('Counter');
                
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
          
        end
          
        
        function handles = StartScan3D(obj, handles)
            
            for k=1:3
                L(k)=length(obj.CurrentScanMat{k});
            end
            L=sort(L);
            TotEstTime=(max(obj.interfaceScanning.ADCtime,obj.interfaceScanning.DAQtime)*L(3)*2e-3+1.2630+0.5+obj.interfaceScanning.StabilizeTime)*L(2)*L(1);
            handles.wb = waitbar(0,['Progress of 3D Scan. Expected Scan Time: ',num2str(TotEstTime),'s']);
            obj.statuswb = 1;
            
            n = ceil(handles.ConfocalScan.DwellTime*obj.interfaceScanning.SampleRate);
            
            if length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{2}) && length(obj.CurrentScanMat{1}) >= length(obj.CurrentScanMat{3}) % ramp over X
                scan_code = 'Xyz';
            elseif  length(obj.CurrentScanMat{2}) > length(obj.CurrentScanMat{1}) && length(obj.CurrentScanMat{2}) >= length(obj.CurrentScanMat{3})  % ramp over Y
                scan_code = 'xYz';
            else % length(obj.CurrentScanMat{3}) > length(obj.CurrentScanMat{1}) && length(obj.CurrentScanMat{3}) > length(obj.CurrentScanMat{2})  % ramp over Z
                scan_code = 'xyZ';
            end
            
            [handles,ramp_points, i1_end, i2_end] = obj.InitVars3D(handles,scan_code);
            
            NT = (ramp_points)*2*n + obj.interfaceScanning.nFlat + 2*obj.interfaceScanning.nOverRun;
            timeout = 10*NT/obj.interfaceScanning.SampleRate;
            
             % ashok 21/1/2014
            obj.interfaceDataAcq.CreateTask('Counter');
            obj.interfaceDataAcq.ConfigureCounterIn('Counter',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,NT);
            
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/obj.TrackerDwellTime,obj.TrackerDutyCycle);
            
            aux_nb = 1;
            
            handles.PiezoStability1 = zeros(i1_end,i2_end);
            handles.PiezoStability2 = zeros(i1_end,i2_end);
            
            for i2=1:1:i2_end
                
                for i1=1:1:i1_end
                    
                    if ~obj.statuswb
                        break;
                    end
                    
                    obj.interfaceDataAcq.StartTask('PulseTrain');
                    obj.interfaceDataAcq.StartTask('Counter');
                    
                    if i1 == 1
                        if strcmp(scan_code,'Xyz')
                            obj.interfaceScanning.Scan(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(i1),obj.CurrentScanMat{3}(i2),handles.ConfocalScan.DwellTime,1);
                        elseif strcmp(scan_code,'xYz')
                            obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(i1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(i2),handles.ConfocalScan.DwellTime,2);
                        else % strcmp(scan_code,'xyZ')
                            obj.interfaceScanning.Scan(obj.CurrentScanMat{1}(i2),obj.CurrentScanMat{2}(i1),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        end
                    else
                        if  strcmp(scan_code,'Xyz')
                            obj.interfaceScanning.Trigg(obj.CurrentScanMat{1},obj.CurrentScanMat{2}(i1),obj.CurrentScanMat{3}(i2),handles.ConfocalScan.DwellTime,1);
                        elseif  strcmp(scan_code,'xYz')
                            obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(i1),obj.CurrentScanMat{2},obj.CurrentScanMat{3}(i2),handles.ConfocalScan.DwellTime,2);
                        else %  strcmp(scan_code,'xyZ')
                            obj.interfaceScanning.Trigg(obj.CurrentScanMat{1}(i2),obj.CurrentScanMat{2}(i1),obj.CurrentScanMat{3},handles.ConfocalScan.DwellTime,3);
                        end
                    end
                    
                    handles = obj.PlotPiezoStability(handles,scan_code,i1,i2);
                    
                    %compute normalized quadratic differences
                    b = obj.interfaceScanning.theorywaveform;
                    c = obj.interfaceScanning.realwaveform;
                    d = sum((b - c).^2)/length(b);
                    
                    if strcmp(scan_code,'Xyz')
                        handles.ConfocalScan.Diffs(i1,:,i2) = b - c; %array of differences theory - real
                    elseif strcmp(scan_code,'xYz')
                        handles.ConfocalScan.Diffs(:,i1,i2) = b - c; %array of differences theory - real
                    else % strcmp(scan_code,'xyZ')
                        handles.ConfocalScan.Diffs(i1,i2,:) = b - c; %array of differences theory - real
                    end
                    
                    obj.DisplayNSQD(handles,scan_code,d,i2);
                    
                    A = obj.interfaceDataAcq.ReadCounterBuffer('Counter',NT,timeout);
                    obj.interfaceDataAcq.StopTask('PulseTrain');
                    obj.interfaceDataAcq.StopTask('Counter');
                    
                
                    obj.ImageRawData = A;
                    
                    D = A((obj.interfaceScanning.nFlat+obj.interfaceScanning.nOverRun+obj.interfaceScanning.LagPts+1):(obj.interfaceScanning.nFlat+obj.interfaceScanning.nOverRun+obj.interfaceScanning.LagPts+(ramp_points)*2*n)); %vector that is ramp_points*2*n long
                    % D now needs to be transformed into a ramp_points long matrix
                    
                    if strcmp(scan_code,'Xyz')
                        handles.ConfocalScan.ImageData(i2, i1, :) = obj.CalcCountRate(D, n, obj.interfaceScanning.SampleRate);
                    elseif strcmp(scan_code,'xYz')
                        handles.ConfocalScan.ImageData(i2,:,i1) = obj.CalcCountRate(D, n, obj.interfaceScanning.SampleRate);
                    else % strcmp(scan_code,'xyZ')
                        handles.ConfocalScan.ImageData(:,i1,i2) = obj.CalcCountRate(D, n, obj.interfaceScanning.SampleRate);
                    end
                    
                    obj.TemporaryPlot(handles,scan_code,i2)
                    
                    if obj.statuswb
                        waitbar(aux_nb/(i1_end*i2_end));
                    else
                        close(handles.wb);
                    end
                    
                    aux_nb = aux_nb + 1;
                    
                end
                
            end
            obj.interfaceDataAcq.ClearTask('PulseTrain');
            obj.interfaceDataAcq.ClearTask('Counter');
        end
        
        function handles = SaveScan(obj,handles)
            
            if size(handles.ConfocalScan.ImageData,1) > 1
                handles.ConfocalScan.ImageData = obj.UnpackImage(handles);
            end
            
            fp = getpref('nv','SavedImageDirectory');
            
            handles.k = sum(obj.bEnable);
            
            if handles.k == 3
                name = 'XYZ';
            elseif handles.k == 1
                %luca
                handles.ConfocalScan.ImageData=[handles.ConfocalScan.ImageData handles.ConfocalScan.ImageData(end)];
                
                if obj.bEnable(1)
                    name = 'X';
                elseif obj.bEnable(2)
                    name = 'Y';
                else
                    name = 'Z';
                end
            else % handles.k ==2
                if ~obj.bEnable(1)
                    name = 'YZ';
                elseif ~obj.bEnable(2)
                    name = 'XZ';
                else
                    name = 'XY';
                end
            end
            
            a = datestr(now,'yyyy-mm-dd-HHMMSS');
            fn = [num2str(handles.k),'D',name,'-Image-',a];
            
            fullFN = fullfile(fp,fn);
            
            Scan = handles.ConfocalScan;
            Scan.DateTime = a;
            
            if ~isempty(Scan),
                save(fullFN,'Scan');
            else
                alertdlg('No Images found for current scan');
            end
            
            obj.UpdateScanList(handles);
            handles = obj.LoadImagesFromScan(handles);
            
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
        end
        
        function handles = PlotPiezoStability(obj,handles,scan_code,ind,i2)
            
            if strcmp(scan_code,'Xy')
                %Ramp X
                handles.ConfocalScan.PiezoStability1(ind)=100*(obj.CurrentScanMat{2}(ind)/obj.interfaceScanning.Pos(2)-1);
                handles.ConfocalScan.PiezoStability2(ind)=100*(handles.Zinit/obj.interfaceScanning.Pos(3)-1);
                argData1 = handles.ConfocalScan.PiezoStability1;
                argData2 = handles.ConfocalScan.PiezoStability2;
                dirs = ['y','z'];
            elseif strcmp(scan_code,'xY')
                handles.ConfocalScan.PiezoStability1(ind)=100*(obj.CurrentScanMat{1}(ind)/obj.interfaceScanning.Pos(1)-1);
                %Ramp Y
                handles.ConfocalScan.PiezoStability2(ind)=100*(handles.Zinit/obj.interfaceScanning.Pos(3)-1);
                argData1 = handles.ConfocalScan.PiezoStability1;
                argData2 = handles.ConfocalScan.PiezoStability2;
                dirs = ['x','z'];
            elseif strcmp(scan_code,'Xz')
                %Ramp X
                handles.ConfocalScan.PiezoStability2(ind)=100*(handles.Yinit/obj.interfaceScanning.Pos(2)-1);
                handles.ConfocalScan.PiezoStability1(ind)=100*(obj.CurrentScanMat{3}(ind)/obj.interfaceScanning.Pos(3)-1);
                argData1 = handles.ConfocalScan.PiezoStability1;
                argData2 = handles.ConfocalScan.PiezoStability2;
                dirs = ['z','y'];
            elseif strcmp(scan_code,'xZ')
                handles.ConfocalScan.PiezoStability1(ind)=100*(obj.CurrentScanMat{1}(ind)/obj.interfaceScanning.Pos(1)-1);
                handles.ConfocalScan.PiezoStability2(ind)=100*(handles.Yinit/obj.interfaceScanning.Pos(2)-1);
                % Ramp Z
                argData1 = handles.ConfocalScan.PiezoStability1;
                argData2 = handles.ConfocalScan.PiezoStability2;
                dirs = ['x','y'];
            elseif strcmp(scan_code,'Yz')
                handles.ConfocalScan.PiezoStability2(ind)=100*(handles.Xinit/obj.interfaceScanning.Pos(1)-1);
                % Ramp Y
                handles.ConfocalScan.PiezoStability1(ind)=100*(obj.CurrentScanMat{3}(ind)/obj.interfaceScanning.Pos(3)-1);
                argData1 = handles.ConfocalScan.PiezoStability1;
                argData2 = handles.ConfocalScan.PiezoStability2;
                dirs = ['z','x'];
            elseif strcmp(scan_code,'yZ')
                handles.ConfocalScan.PiezoStability2(ind)=100*(handles.Xinit/obj.interfaceScanning.Pos(1)-1);
                handles.ConfocalScan.PiezoStability1(ind)=100*(obj.CurrentScanMat{2}(ind)/obj.interfaceScanning.Pos(2)-1);
                % Ramp Z
                argData1 = handles.ConfocalScan.PiezoStability1;
                argData2 = handles.ConfocalScan.PiezoStability2;
                dirs = ['y','x'];
            elseif strcmp(scan_code,'Xyz')
                % Ramp x
                handles.ConfocalScan.PiezoStability2(ind,i2)=100*(obj.CurrentScanMat{2}(ind)/obj.interfaceScanning.Pos(2)-1);
                handles.ConfocalScan.PiezoStability1(ind,i2)=100*(obj.CurrentScanMat{3}(i2)/obj.interfaceScanning.Pos(3)-1);
                argData1 = handles.ConfocalScan.PiezoStability1(:,i2);
                argData2 = handles.ConfocalScan.PiezoStability2(:,i2);
                dirs = ['z','y'];
            elseif strcmp(scan_code,'xYz')
                handles.ConfocalScan.PiezoStability2(ind,i2)=100*(obj.CurrentScanMat{1}(ind)/obj.interfaceScanning.Pos(1)-1);
                % Ramp Y
                handles.ConfocalScan.PiezoStability1(ind,i2)=100*(obj.CurrentScanMat{3}(i2)/obj.interfaceScanning.Pos(3)-1);
                argData1 = handles.ConfocalScan.PiezoStability1(:,i2);
                argData2 = handles.ConfocalScan.PiezoStability2(:,i2);
                dirs = ['z','x'];
            elseif strcmp(scan_code,'xyZ')
                handles.ConfocalScan.PiezoStability1(ind,i2)=100*(obj.CurrentScanMat{1}(i2)/obj.interfaceScanning.Pos(1)-1);
                handles.ConfocalScan.PiezoStability2(ind,i2)=100*(obj.CurrentScanMat{2}(ind)/obj.interfaceScanning.Pos(2)-1);
                % Ramp Z
                argData1 = handles.ConfocalScan.PiezoStability1(:,i2);
                argData2 = handles.ConfocalScan.PiezoStability2(:,i2);
                dirs = ['x','y'];
            else
                uiwait(warndlg('Invalid scan code.'));
                return;
            end
            
            plot(handles.axes_piezo_stab1,argData1,'*:')
            title(handles.axes_piezo_stab1,['% deviation in ' dirs(1)])
            
            plot(handles.axes_piezo_stab2,argData2,'*:')
            title(handles.axes_piezo_stab2,['% deviation in ' dirs(2)])
            
        end
        
        function DisplayNSQD(obj,handles,scan_code,d,i2)
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'xY')
                argX = obj.CurrentScanMat{1};
                argY = obj.CurrentScanMat{2};
                argData = handles.ConfocalScan.Diffs;
                textxlabel = 'y (\mum)';
                textylabel = 'x (\mum)';
            elseif strcmp(scan_code,'Xz') || strcmp(scan_code,'xZ')
                argX = obj.CurrentScanMat{1};
                argY = obj.CurrentScanMat{3};
                argData = handles.ConfocalScan.Diffs;
                textxlabel = 'z (\mum)';
                textylabel = 'x (\mum)';
            elseif strcmp(scan_code,'Yz') || strcmp(scan_code,'yZ')
                argX = obj.CurrentScanMat{2};
                argY = obj.CurrentScanMat{3};
                argData = handles.ConfocalScan.Diffs;
                textxlabel = 'z (\mum)';
                textylabel = 'y (\mum)';
            elseif strcmp(scan_code,'Xyz')
                argX = obj.CurrentScanMat{1};
                argY = obj.CurrentScanMat{2};
                argData = handles.ConfocalScan.Diffs(:,:,i2);
                textxlabel = 'y (\mum)';
                textylabel = 'x (\mum)';
            elseif strcmp(scan_code,'xYz')
                argX = obj.CurrentScanMat{1};
                argY = obj.CurrentScanMat{2};
                argData = handles.ConfocalScan.Diffs(:,:,i2);
                textxlabel = 'y (\mum)';
                textylabel = 'x (\mum)';
            elseif strcmp(scan_code,'xyZ')
                argX = obj.CurrentScanMat{2};
                argY = obj.CurrentScanMat{3};
                argData = reshape(handles.ConfocalScan.Diffs(:,i2,:),length(obj.CurrentScanMat{2}),length(obj.CurrentScanMat{3}));
                textxlabel = 'y (\mum)';
                textylabel = 'z (\mum)';
            else
                uiwait(warndlg('Invalid scan code.'));
                return;
            end
            
            % display normalized quadratic differences
            set(handles.NSQDnumber,'String',['NSQD line = ' num2str(d)]);
            imagesc(argX,argY,argData,'Parent',handles.axes1);
            set(handles.axes1,'YDir','normal');
            axis(handles.axes1,'square');
            xlabel(handles.axes1,textylabel);
            ylabel(handles.axes1,textxlabel);
            set(handles.axes1, 'XLim',[min(argX) max(argX)], 'YLim', [min(argY) max(argY)]);
            set(handles.axes1, 'CLim',[min(argData(:)) max(argData(:))]);
            h = colorbar('peer', handles.axes1,'EastOutside');
            set(get(h,'ylabel'),'String','Diff (theo - real)(\mum)');
            drawnow();
            
        end
        
        function TemporaryPlot(obj,handles,scan_code,i2)
            
            if strcmp(scan_code,'Xy') || strcmp(scan_code,'xY')
                argX = obj.CurrentScanMat{1};
                argY = obj.CurrentScanMat{2};
                argData = handles.ConfocalScan.ImageData;
                textxlabel = 'x (\mum)';
                textylabel = 'y (\mum)';
            elseif strcmp(scan_code,'Xz') || strcmp(scan_code,'xZ')
                argX = obj.CurrentScanMat{1};
                argY = obj.CurrentScanMat{3};
                argData = handles.ConfocalScan.ImageData;
                textxlabel = 'x (\mum)';
                textylabel = 'z (\mum)';
            elseif strcmp(scan_code,'Yz') || strcmp(scan_code,'yZ')
                argX = obj.CurrentScanMat{2};
                argY = obj.CurrentScanMat{3};
                argData = handles.ConfocalScan.ImageData;
                textxlabel = 'y (\mum)';
                textylabel = 'z (\mum)';
            elseif strcmp(scan_code,'Xyz')
                tmpimg = obj.UnpackImage(handles);
                argX = obj.CurrentScanMat{1};
                argY = obj.CurrentScanMat{2};
                argData = tmpimg(:,:,i2);
                textxlabel = 'x (\mum)';
                textylabel = 'y (\mum)';
                textpos = ['Z pos = ' num2str(obj.CurrentScanMat{3}(i2))];
                set(handles.text6, 'Visible', 'on');
                set(handles.text6,'String', textpos);
            elseif strcmp(scan_code,'xYz')
                tmpimg = obj.UnpackImage(handles);
                argX = obj.CurrentScanMat{1};
                argY = obj.CurrentScanMat{2};
                argData = tmpimg(:,:,i2);
                textxlabel = 'x (\mum)';
                textylabel = 'y (\mum)';
                textpos = ['Z pos = ' num2str(obj.CurrentScanMat{3}(i2))];
                set(handles.text6, 'Visible', 'on');
                set(handles.text6,'String', textpos);
            elseif strcmp(scan_code,'xyZ')
                tmpimg = obj.UnpackImage(handles);
                argX = obj.CurrentScanMat{3};
                argY = obj.CurrentScanMat{2};
                argData = reshape(tmpimg(:,i2,:), length(obj.CurrentScanMat{2}),length(obj.CurrentScanMat{3}));
                textxlabel = 'z (\mum)';
                textylabel = 'y (\mum)';
                textpos = ['X pos = ' num2str(obj.CurrentScanMat{1}(i2))];
                set(handles.text6, 'Visible', 'on');
                set(handles.text6,'String', textpos);
            else
                uiwait(warndlg('Invalid scan code.'));
                return;
            end
            
            %plot temporarily
            imagesc(argX,argY,argData,'Parent',handles.imageAxes);
            set(handles.imageAxes,'YDir','normal');
            axis(handles.imageAxes,'square');
            xlabel(handles.imageAxes,textxlabel);
            ylabel(handles.imageAxes,textylabel);
            set(handles.imageAxes, 'XLim',[min(argX) max(argX)], 'YLim',[min(argY) max(argY)]);
%             set(handles.imageAxes, 'CLim', [min(argData(:)) max(argData(:))]);
            h = colorbar('peer', handles.imageAxes,'EastOutside');
            set(get(h,'ylabel'),'String','kcps');
            drawnow();
            
        end
        
        %%%%% END SCANNING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%% IMAGE HANDLING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [img] = UnpackImage(obj,handles)
            dimX = obj.NumPoints(1);
            dimY = obj.NumPoints(2);
            dimZ = obj.NumPoints(3);
            
            if obj.bEnable(1) && obj.bEnable(2) && obj.bEnable(3) %3d scan
                
                img = zeros(dimY,dimX,dimZ);
                
                %New code. CDA
                for a=1:1:dimX
                    for b=1:1:dimY
                        for c=1:1:dimZ
                            img(b,a,c) = handles.ConfocalScan.ImageData(c,b,a);
                        end
                    end
                end
                
            else % 2d scan
                
                img = handles.ConfocalScan.ImageData;
                
            end
            
        end
        
        function handles = LoadImagesFromScan(obj,handles)
            
            scans = get(handles.popupScan,'String');
            selectedScan = scans{get(handles.popupScan,'Value')};
            
            set(handles.buttonSaveNote, 'Enable','off');
            set(handles.Note, 'Enable','off');
            set(handles.DwellDisplayedValue, 'String','');
            
            if length(scans)>1
                
                if strcmp(selectedScan,'Current Scan')
                    
                    % display current scan images
                    
                    set(handles.buttonSaveNote, 'Enable', 'on');
                    
                    fp = getpref('nv','SavedImageDirectory');
                    selectedScan= scans{get(handles.popupScan,'Value')+1}; %loads the first exp in the list, that corresponds to the displayed 'Current Experiment'
                    SavedScan = load(fullfile(fp,selectedScan));
                    set(handles.Note,'String', SavedScan.Scan.Notes);
                    set(handles.Note, 'Enable', 'on');
                    
                    handles.ConfocalScanDisplayed = SavedScan.Scan;
                    
                else
                    % load up images from saved file
                    fp = getpref('nv','SavedImageDirectory');
                    SavedScan = load(fullfile(fp,selectedScan));
                    
                    handles.ConfocalScanDisplayed = SavedScan.Scan;
                    
                    set(handles.Note, 'String', handles.ConfocalScanDisplayed.Notes);
                    set(handles.buttonSaveNote, 'Enable', 'on');
                    set(handles.Note, 'Enable','on');
                    
                end
                
                set(handles.DwellDisplayedValue, 'String', num2str(handles.ConfocalScanDisplayed.DwellTime));
                
                set(handles.minxdisp,'String',min(handles.ConfocalScanDisplayed.RangeX));
                set(handles.maxxdisp,'String',max(handles.ConfocalScanDisplayed.RangeX));
                set(handles.ptsxdisp,'String',length(handles.ConfocalScanDisplayed.RangeX));
                
                set(handles.minydisp,'String',min(handles.ConfocalScanDisplayed.RangeY));
                set(handles.maxydisp,'String',max(handles.ConfocalScanDisplayed.RangeY));
                set(handles.ptsydisp,'String',length(handles.ConfocalScanDisplayed.RangeY));
                
                set(handles.minzdisp,'String',min(handles.ConfocalScanDisplayed.RangeZ));
                set(handles.maxzdisp,'String',max(handles.ConfocalScanDisplayed.RangeZ));
                set(handles.ptszdisp,'String',length(handles.ConfocalScanDisplayed.RangeZ));
                
                set(handles.text_saved_power, 'String',sprintf('Power = %0.3f +- %0.3f mW',handles.ConfocalScanDisplayed.Laserpower(1),handles.ConfocalScanDisplayed.Laserpower(2)));
                
                if length(handles.ConfocalScanDisplayed.RangeX) > 1
                    set(handles.enx,'Value',1);
                else
                    set(handles.enx,'Value',0);
                end
                
                if length(handles.ConfocalScanDisplayed.RangeY) > 1
                    set(handles.eny,'Value',1);
                else
                    set(handles.eny,'Value',0);
                end
                
                if length(handles.ConfocalScanDisplayed.RangeZ) > 1
                    set(handles.enz,'Value',1);
                else
                    set(handles.enz,'Value',0);
                end
                
                %display slider if 3d scan
                if length(size(handles.ConfocalScanDisplayed.ImageData)) == 3
                    set(handles.sliderZScan,'Max', length(handles.ConfocalScanDisplayed.RangeZ));
                    set(handles.sliderZScan,'Min', 1);
                    set(handles.sliderZScan,'Value', 1);
                    set(handles.text6,'String', ['Z pos = ' num2str(handles.ConfocalScanDisplayed.RangeZ(1))]);
                    set(handles.sliderZScan,'Visible', 'on');
                    set(handles.text6,'Visible', 'on');
                    
                else
                    set(handles.sliderZScan,'Visible', 'off');
                    set(handles.text6,'Visible', 'off');
                    
                end
                
                obj.DisplayImage(handles);
                
            end
            
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
        end
        
        function DisplayImage(obj,handles)
            
            cImage = handles.ConfocalScanDisplayed;
            if obj.useFilter
                cImage.ImageData(cImage.ImageData>obj.cutoffVal) = obj.cutoffVal;
            end
            
            if (length(cImage.RangeX)>1 && length(cImage.RangeY)>1 && length(cImage.RangeZ)>1) %3d scan
                
                sliderValue = get(handles.sliderZScan,'Value');
                set(handles.sliderZScan,'Value', sliderValue);
                
                imagesc(cImage.RangeX,cImage.RangeY,cImage.ImageData(:,:,1),'Parent',handles.imageAxes);
                set(gca,'YDir','normal');
                axis square;
                xlabel('x (\mum)');
                ylabel('y (\mum)');
                axis([min(cImage.RangeX), max(cImage.RangeX), min(cImage.RangeY), max(cImage.RangeY)]);
                caxis([min(cImage.ImageData(:)) max(cImage.ImageData(:))]);
                h = colorbar('EastOutside');
                set(get(h,'ylabel'),'String','kcps');
                
                set(handles.NSQDnumber,'String',['NSQD 2D image = ' num2str(sum(sum(cImage.Diffs(:,:,1).^2))/size(cImage.Diffs,1)/size(cImage.Diffs,2))]);
                imagesc(cImage.RangeX,cImage.RangeY,cImage.Diffs(:,:,1),'Parent',handles.axes1);
                set(handles.axes1,'YDir','normal');
                axis(handles.axes1,'square');
                xlabel(handles.axes1,'x (\mum)');
                ylabel(handles.axes1,'y (\mum)');
                set(handles.axes1, 'XLim',[min(cImage.RangeX) max(cImage.RangeX)], 'YLim', [min(cImage.RangeY) max(cImage.RangeY)]);
                set(handles.axes1, 'CLim',[min(cImage.Diffs(:)) max(cImage.Diffs(:))]);
                h = colorbar('peer', handles.axes1,'EastOutside');
                set(get(h,'ylabel'),'String','Diff (theo - real)(\mum)');
                drawnow();
                
                if length(cImage.RangeX) >= length(cImage.RangeY) && length(cImage.RangeX) >= length(cImage.RangeZ) %'Xyz' scan
                    textpiezo1 = 'z';
                    textpiezo2 = 'y';
                    argPiezo1 = cImage.PiezoStability1(:,1);
                    argPiezo2 = cImage.PiezoStability2(:,1);
                elseif length(cImage.RangeY) > length(cImage.RangeX) && length(cImage.RangeY) >= length(cImage.RangeZ) %'xYz' scan
                    textpiezo1 = 'z';
                    textpiezo2 = 'x';
                    argPiezo1 = cImage.PiezoStability1(:,1);
                    argPiezo2 = cImage.PiezoStability2(:,1);
                else % 'xyZ' scan
                    argPiezo1 = zeros(1,length(cImage.RangeY));
                    argPiezo2 = zeros(1,length(cImage.RangeY));
                    for aux=1:1:length(cImage.RangeY)
                        argPiezo1(aux) = mean(cImage.PiezoStability1(aux,:));
                        argPiezo2(aux) = mean(cImage.PiezoStability2(aux,:));
                    end
                    textpiezo1 = 'x (avg over all z)';
                    textpiezo2 = 'y (avg over all z)';
                end
                
                plot(handles.axes_piezo_stab1,argPiezo1,'*:')
                title(handles.axes_piezo_stab1,['% deviation in ' textpiezo1])
                
                plot(handles.axes_piezo_stab2,argPiezo2,'*:')
                title(handles.axes_piezo_stab2,['% deviation in ' textpiezo2])
                
            elseif ((length(cImage.RangeX)>1 && length(cImage.RangeY)>1 && length(cImage.RangeZ) ==1)||...
                    (length(cImage.RangeX) >1 && length(cImage.RangeY)==1 && length(cImage.RangeZ)>1) ||...
                    (length(cImage.RangeX)==1 && length(cImage.RangeY)>1 && length(cImage.RangeZ)>1) ) %2d scan
                
                if length(cImage.RangeZ)==1 %xy scan
                    if length(cImage.RangeX) >= length(cImage.RangeY) % 'Xy' scan
                        textpiezo1 = 'y';
                        textpiezo2 = 'z';
                    else % 'xY'
                        textpiezo1 = 'x';
                        textpiezo2 = 'z';
                    end
                    obj.PlotImage2D(handles,cImage,cImage.RangeX,cImage.RangeY,'x (\mum)','y (\mum)',textpiezo1,textpiezo2,0,0);
                elseif length(cImage.RangeY) == 1 %xz scan
                    if length(cImage.RangeX) >= length(cImage.RangeZ) % 'Xz' scan
                        textpiezo1 = 'z';
                        textpiezo2 = 'y';
                    else % 'xZ'
                        textpiezo1 = 'x';
                        textpiezo2 = 'y';
                    end
                    
                    obj.PlotImage2D(handles,cImage,cImage.RangeX,cImage.RangeZ,'x (\mum)','z (\mum)',textpiezo1,textpiezo2,0,0);
                else %yz scan
                    if length(cImage.RangeY) >= length(cImage.RangeZ) % 'Yz' scan
                        textpiezo1 = 'z';
                        textpiezo2 = 'x';
                    else % 'yZ'
                        textpiezo1 = 'y';
                        textpiezo2 = 'x';
                    end
                    
                    obj.PlotImage2D(handles,cImage,cImage.RangeY,cImage.RangeZ,'y (\mum)','z (\mum)',textpiezo1,textpiezo2,0,0);
                end
                
            else %1d scan
                if length(cImage.RangeZ)>1 %% z scan
                    obj.PlotImage1D(handles,cImage,cImage.RangeZ,'z (\mum)','x','y');
                elseif length(cImage.RangeY)>1 %% y scan
                    obj.PlotImage1D(handles,cImage,cImage.RangeY,'y (\mum)','z','x');
                else %% x scan
                    obj.PlotImage1D(handles,cImage,cImage.RangeX,'x (\mum)','y','z');
                end
                
            end
            
        end
        
        %%%%% END IMAGE HANDLING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%% TRACKING & COUNTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [counts] = kCountsPerSecond(obj)
           
           
            obj.interfaceDataAcq.CreateTask('CounterTracker');
            obj.interfaceDataAcq.ConfigureCounterIn('CounterTracker',obj.TrackerCounterInLine,obj.TrackerCounterOutLine,obj.TrackerNumberOfSamples);
            
            obj.interfaceDataAcq.CreateTask('PulseTrain');
            obj.interfaceDataAcq.ConfigureClockOut('PulseTrain',obj.TrackerCounterOutLine,1/obj.TrackerDwellTime,obj.TrackerDutyCycle);
            
            obj.interfaceDataAcq.StartTask('PulseTrain');
            obj.interfaceDataAcq.StartTask('CounterTracker');
            
            % read out the data
            CounterData =  obj.interfaceDataAcq.ReadCounterBuffer('CounterTracker',obj.TrackerNumberOfSamples);
            
            % clear the tasks
            obj.interfaceDataAcq.ClearTask('CounterTracker');
            obj.interfaceDataAcq.ClearTask('PulseTrain');
            
            DiffCounts = diff(CounterData);
            TotalCounts = sum(DiffCounts);
            
            % counts per second is total counts divided by the total
            % acquisition time, which is the number of sample periods X
            % dwell time X duty cycle
            counts = TotalCounts/(obj.TrackerNumberOfSamples-1)/obj.TrackerDwellTime/1000; %in kcps
            
        end
        
        function SaveTrack(obj,handles)
            
            initstep(1) =  str2num(get(handles.InitStepX,'String'));
            initstep(2) =  str2num(get(handles.InitStepY,'String'));
            initstep(3) =  str2num(get(handles.InitStepZ,'String'));
            
            minstep(1) = str2num(get(handles.MinStepX,'String'));
            minstep(2) = str2num(get(handles.MinStepY,'String'));
            minstep(3) = str2num(get(handles.MinStepZ,'String'));
            
            thresh = str2num(get(handles.Thresh,'String'));
            maxiter = ceil(str2num(get(handles.MaxIter,'String')));
            
            if minstep(1) < obj.interfaceScanning.precision(1)
                uiwait(warndlg({'Min step in x below scanning precision. Coercing.'}));
                set(handles.MinStepX,'String',obj.TrackerMinimumStepSize(1));
                minstep(1) = obj.TrackerMinimumStepSize(1);
            end
            if minstep(2) < obj.interfaceScanning.precision(2)
                uiwait(warndlg({'Min step in y below scanning precision. Coercing.'}));
                set(handles.MinStepY,'String',obj.TrackerMinimumStepSize(2));
                minstep(2) = obj.TrackerMinimumStepSize(2);
            end
            if minstep(3) < obj.interfaceScanning.precision(3)
                uiwait(warndlg({'Min step in z below scanning precision. Coercing.'}));
                set(handles.MinStepZ,'String',obj.TrackerMinimumStepSize(3));
                minstep(3) = obj.TrackerMinimumStepSize(3);
            end
            if initstep(1) < minstep(1)
                uiwait(warndlg({'Init step in x below min step. Coercing.'}));
                set(handles.InitStepX,'String',obj.TrackerInitialStepSize(1));
                initstep(1) = obj.TrackerInitialStepSize(1);
            end
            if initstep(2) < minstep(2)
                uiwait(warndlg({'Init step in y below min step. Coercing.'}));
                set(handles.InitStepY,'String',obj.TrackerInitialStepSize(2));
                initstep(2) = obj.TrackerInitialStepSize(2);
            end
            if initstep(3) < minstep(3)
                uiwait(warndlg({'Init step in z below min step. Coercing.'}));
                set(handles.InitStepZ,'String',obj.TrackerInitialStepSize(3));
                initstep(3) = obj.TrackerInitialStepSize(3);
            end
            if thresh <= 0
                uiwait(warndlg({'Count threshold should be positive. Coercing.'}));
                set(handles.Thresh,'String',obj.TrackerTrackingThreshold);
                thresh = obj.TrackerTrackingThreshold;
            end
            if maxiter <= 0
                uiwait(warndlg({'Max number of iterations should be positive. Coercing.'}));
                set(handles.MaxIter,'String',obj.TrackerMaxIterations);
                maxiter = obj.TrackerMaxIterations;
            end
            
            for k=1:1:3
                obj.TrackerInitialStepSize(k) = initstep(k);
                obj.TrackerMinimumStepSize(k) = minstep(k);
            end
            
            obj.TrackerTrackingThreshold = thresh;
            obj.TrackerMaxIterations = maxiter;
            set(handles.TrackingStart,'Enable','on');
            set(handles.CurrStepX,'String',initstep(1));
            set(handles.CurrStepY,'String',initstep(2));
            set(handles.CurrStepZ,'String',initstep(3));
            drawnow();
            
        end
        
        function TrackCenter(obj,handles)
            
            obj.TrackerhasAborted = 0;
            
            % set up initial step sizes
            CurrentStepSize = obj.TrackerInitialStepSize;
            
            % setup local vars
            iterCounter = 0;
            
            % get current position 
            for k=1:1:3
                Pos(k) = obj.interfaceScanning.Pos(k);
            end
           
            init_counts = obj.kCountsPerSecond();
            set(handles.text_init_counts,'String',sprintf('Init = %0.3f kcps',init_counts));
            set(handles.text_final_counts,'String','Final = ');
            set(handles.text_improv,'String','% Improv = ');
            set(handles.text_date,'String', 'Last tracker');
            
            % main while loop for tracking center logic
            % as long as we haven't aborted or iterated too much or took
            % too small of a step, keep taking gradients and maximize the
            % counts
            positions(:,1) = Pos;
            while (~obj.TrackerhasAborted && (iterCounter < obj.TrackerMaxIterations) && (CurrentStepSize(1) >  obj.TrackerMinimumStepSize(1)) && ...
                    (CurrentStepSize(2) >  obj.TrackerMinimumStepSize(2)) && (CurrentStepSize(3) >  obj.TrackerMinimumStepSize(3)))
                
                % define local vars
                PosX = Pos(1);
                PosY = Pos(2);
                PosZ = Pos(3);
                
                %iterate the counter
                iterCounter = iterCounter + 1;
                
                % setup the nearest neighbor points
                Nearest(1,:) = [PosX,PosY,PosZ] + [0,0,0];
                Nearest(2,:) = [PosX,PosY,PosZ] + [CurrentStepSize(1),0,0];
                Nearest(3,:) = [PosX,PosY,PosZ] + [-CurrentStepSize(1),0,0];
                Nearest(4,:) = [PosX,PosY,PosZ] + [0,CurrentStepSize(2),0];
                Nearest(5,:) = [PosX,PosY,PosZ] + [0,-CurrentStepSize(2),0];
                Nearest(6,:) = [PosX,PosY,PosZ] + [0,0,CurrentStepSize(3)];
                Nearest(7,:) = [PosX,PosY,PosZ] + [0,0,-CurrentStepSize(3)];
                
                % check to see if any of the nearest points are over max.
                % allowed positions
                if (any(Nearest(:,1)>obj.interfaceScanning.HighEndOfRange(1)) || any(Nearest(:,2)>obj.interfaceScanning.HighEndOfRange(2)) ...
                        || any(Nearest(:,3)>obj.interfaceScanning.HighEndOfRange(3)))
                    warning('Position over allowed max. Track aborted.');
                    obj.TrackerhasAborted = 1;
                    break;
                end
                if (any(Nearest(:,1)<obj.interfaceScanning.LowEndOfRange(1)) || any(Nearest(:,2)<obj.interfaceScanning.LowEndOfRange(2)) ...
                        || any(Nearest(:,3)<obj.interfaceScanning.LowEndOfRange(3)))
                    warning('Position over allowed min. Track Aborted');
                    obj.TrackerhasAborted = 1;
                    break;
                end
                
                % iterate though the NN points, getting counts
                for k=1:7,
                    obj.CursorPosition = Nearest(k,:);
                    handles = obj.SetCursor(handles);
                    NNCounts(k) = obj.kCountsPerSecond();
                end
              
                % plot counts (check adds to plot)
                 bar(NNCounts,'Parent',handles.axes_tracking_counts);
                 drawnow;
                
                % apply a threshold to the obtained NN counts
                deltaNNCounts = NNCounts - NNCounts(1);
                [Inds] = find(deltaNNCounts > obj.TrackerTrackingThreshold);
                
                % create a boolean vector of the points above the threshold
                % only these are included in the gradient calculation
                bThresh = zeros(1,7);
                bThresh(Inds) = 1;
                
                % If no points greater than threshold, keep orginal reference
                if  sum(bThresh)==0,
                    % If Ref. Position did not change, reduce the step sizes
                    CurrentStepSize = CurrentStepSize.*obj.TrackerStepReductionFactor;
                    
                    set(handles.CurrStepX,'String',CurrentStepSize(1));
                    set(handles.CurrStepY,'String',CurrentStepSize(2));
                    set(handles.CurrStepZ,'String',CurrentStepSize(3));
                    drawnow();
                    
                else % calculate the new maximum point, climb the hill
                    
                    % 3D deformed to 1D steps
                    stepVec = [1 CurrentStepSize(1),...
                        -CurrentStepSize(1),CurrentStepSize(2),-CurrentStepSize(2),...
                        CurrentStepSize(3),-CurrentStepSize(3)];
                    
                    % calculate the Gradient Directions
                    gradVec = (deltaNNCounts./stepVec).*bThresh;
                    
                    % Update the reference position
                    G = [gradVec(2) + gradVec(3),gradVec(4)+gradVec(5),gradVec(6) + gradVec(7)];
                    
                    % seems to be a bug with G/norm(G) giving NaN, so check to make
                    % sure the numbers are non-zero
                    if norm(G) < 1e-8
                        
                    else
                        posMove = G/norm(G).*CurrentStepSize;
                        Pos = Pos + posMove;
                    end
                    
                end
                
                if (iterCounter == obj.TrackerMaxIterations),
                    dlg = warndlg('End tracking: max iter reached');
                    pause(1);
                    close(dlg);
                
                elseif ~((CurrentStepSize(1) >  obj.TrackerMinimumStepSize(1)) && (CurrentStepSize(2) >  obj.TrackerMinimumStepSize(2)) && (CurrentStepSize(3) >  obj.TrackerMinimumStepSize(3)))
                    dlg = warndlg('End tracking: min step reached');
                    pause(1);
                    close(dlg);
            
                end
                
                helper = findobj(findall(0),'Tag','axes_TrackX');
                if ~isempty(helper)
                    
                    positions(:,iterCounter+1)=Pos;
                    helper = helper(1);
                    plot(helper,positions(1,:));
                    xlabel(helper,'time');
                    set(helper,'XTickLabel',{},'fontsize',8);
                    ylabel(helper,'X Pos [\mum]');
                    set(helper,'fontsize',8);
                    
                    helper = findobj(findall(0),'Tag','axes_TrackY');
                    helper = helper(1);
                    plot(helper,positions(2,:));
                    xlabel(helper,'time');
                    set(helper,'XTickLabel',{},'fontsize',8);
                    ylabel(helper,'Y Pos [\mum]');
                    set(helper,'fontsize',8);
                    
                    helper = findobj(findall(0),'Tag','axes_TrackZ');
                    helper = helper(1);
                    plot(helper,positions(3,:));
                    xlabel(helper,'time');
                    set(helper,'XTickLabel',{},'fontsize',8);
                    ylabel(helper,'Z Pos [\mum]');
                    set(helper,'fontsize',8);
                    drawnow();
                end
                
            end % main while loop
            
            if obj.TrackerhasAborted
                % does not update position
                obj.CursorPosition = Pos;
                obj.SetCursor(handles);
                obj.TrackerhasAborted = 0;
                obj.SetStatus(handles,'Position not updated by tracking.');
                final_counts = obj.kCountsPerSecond();
                set(handles.text_final_counts,'String',sprintf('Final = %0.3f kcps',final_counts));
                set(handles.text_improv,'String','Track unsuccessful');
                set(handles.text_date,'String', datestr(now));
            else
                % update Cursor to final tracked position
                obj.CursorPosition = [PosX,PosY,PosZ];
                obj.SetCursor(handles);
                obj.SetStatus(handles,'Position updated by tracking.');
                final_counts = obj.kCountsPerSecond();
                set(handles.text_final_counts,'String',sprintf('Final = %0.3f kcps',final_counts));
                set(handles.text_improv,'String',sprintf('Perc Improv = %0.3f',final_counts/init_counts - 1));
                set(handles.text_date,'String', datestr(now));
            end
            
        end
        
        function [power_data_in_V,power_stdev_in_V,power_array] = MonitorPower(obj)
            % Monitor laser power by reading the voltage sent by a
            % photodiode
            
            data = [];
            obj.interfaceDataAcq.CreateTask('MonitoringPower');
            
            max_signal = 10; % in V
            min_signal = -10; % in V
            NSamples = 10000; % taking n samples and taking the mean
            Freq = 250000;  % freq of acquisition
            analog_input_line = 1; % as specified in init script
            
            obj.interfaceDataAcq.ConfigReadVoltageInput('MonitoringPower',analog_input_line, max_signal, min_signal,NSamples,Freq)
           
            obj.interfaceDataAcq.StartTask('MonitoringPower');
            data = obj.interfaceDataAcq.ReadVoltageInput('MonitoringPower',NSamples);
          
            obj.interfaceDataAcq.StopTask('MonitoringPower');
            obj.interfaceDataAcq.ClearTask('MonitoringPower');
            
            power_data_in_V = mean(data);
            power_stdev_in_V = std(data);
            power_array = data;
        end
        
        %%%%% END TRACKING & COUNTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    methods (Static)
        
        function PlotImage1D(handles,cImage,arg,textlabel,piezo1label,piezo2label)
            
            plot(arg,cImage.ImageData,'-b.','Parent',handles.imageAxes);
            if  min(cImage.ImageData)~=max(cImage.ImageData)
            axis([min(arg), max(arg), min(cImage.ImageData), max(cImage.ImageData)]);
            else
                axis([min(arg), max(arg), min(cImage.ImageData)-10, max(cImage.ImageData)+10]);
            end
            xlabel(textlabel);
            ylabel('kcps');
            
            %ashok 27/1/14
%             set(handles.NSQDnumber,'String',['NSQD line = ' num2str(sum((cImage.Diffs).^2)/length(cImage.Diffs))]);
%             plot(arg, cImage.Diffs, '-b.','Parent', handles.axes1);
%             xlabel(handles.axes1,textlabel);
%             ylabel(handles.axes1,'Diff (theo - real) mov of piezo (\mum)');
%             drawnow();
%             
%             plot(handles.axes_piezo_stab1,cImage.PiezoStability1,'*:')
%             title(handles.axes_piezo_stab1,['% deviation in ' piezo1label])
%             
%             plot(handles.axes_piezo_stab2,cImage.PiezoStability2,'*:')
%             title(handles.axes_piezo_stab2,['% deviation in ' piezo2label])
            
        end
        
        function PlotImage2D(handles,cImage,argX,argY,textxlabel,textylabel,piezo1label,piezo2label,threeDflag,val)
            %plots both scan and piezo NSQD figure
            
            if threeDflag
                
                 if handles.ImagingFunctions.useFilter
                 cImage.ImageData(cImage.ImageData>handles.ImagingFunctions.cutoffVal) = handles.ImagingFunctions.cutoffVal;
                 end
                 
                 
                argData = cImage.ImageData(:,:,val);
                argDiffs = cImage.Diffs(:,:,val);
                
                if length(cImage.RangeZ) > length(cImage.RangeX) && length(cImage.RangeZ) > length(cImage.RangeY) %'xyZ' scan
                    argPiezo1 = zeros(1,length(cImage.RangeY));
                    argPiezo2 = zeros(1,length(cImage.RangeY));
                    for aux=1:1:length(cImage.RangeY)
                        argPiezo1(aux) = mean(cImage.PiezoStability1(aux,:));
                        argPiezo2(aux) = mean(cImage.PiezoStability2(aux,:));
                    end
                else
                    argPiezo1 = cImage.PiezoStability1(:,val);
                    argPiezo2 = cImage.PiezoStability2(:,val);
                end
                
            else
                argData = cImage.ImageData;
                argDiffs = cImage.Diffs;
                argPiezo1 = cImage.PiezoStability1;
                argPiezo2 = cImage.PiezoStability2;
            end
            
            imagesc(argX,argY,argData,'Parent',handles.imageAxes);
            axis square;
            set(gca,'YDir','normal');
            xlabel(textxlabel);
            ylabel(textylabel);
            axis([min(argX), max(argX), min(argY), max(argY)]);
            h = colorbar('EastOutside');
            set(get(h,'ylabel'),'String','kcps');
            
            %ashok 27/1/14
%             set(handles.NSQDnumber,'String',['NSQD 2D image = ' num2str(sum(sum((argDiffs).^2))/size(argDiffs,1)/size(argDiffs,2))]);
%             imagesc(argX,argY,argDiffs,'Parent',handles.axes1);
%             set(handles.axes1,'YDir','normal');
%             axis(handles.axes1,'square');
%             xlabel(handles.axes1,textxlabel);
%             ylabel(handles.axes1,textylabel);
%             set(handles.axes1, 'XLim',[min(argX) max(argX)], 'YLim', [min(argY) max(argY)]);
%             h = colorbar('peer', handles.axes1,'EastOutside');
%             set(get(h,'ylabel'),'String','Diff (theo - real)(\mum)');
%             drawnow();
%             
%             plot(handles.axes_piezo_stab1,argPiezo1,'*:')
%             title(handles.axes_piezo_stab1,['% deviation in ' piezo1label])
%             
%             plot(handles.axes_piezo_stab2,argPiezo2,'*:')
%             title(handles.axes_piezo_stab2,['% deviation in ' piezo2label])
        end
        
        function UpdateScanList(handles)
            
            fp = getpref('nv','SavedImageDirectory');
            files = dir(fp);
            
            datenums = [];
            found_filenames = {};
            % sort files by modifying date desc
            for k=1:length(files)
                % takes the date from the filename
                r = regexp(files(k).name, '(\d{4}-\d{2}-\d{2}-\d{6})','tokens');
                if ~isempty(r)  %remove dirs '.' and '..', and other files
                    datenums(end+1) = datenum(r{1}, 'yyyy-mm-dd-HHMMSS');
                    found_filenames{end+1} = files(k).name;
                end
                
            end
            if ~isempty(datenums)
                [~,dind] = sort(datenums,'descend');
            end;
            
            fn{1} = 'Current Scan';
            
            for k=1:length(datenums),
                
                fn{end+1} = found_filenames{dind(k)};
                
            end
            set(handles.popupScan,'String',fn);
            
            gobj = findall(0,'Name','Imaging');
            guidata(gobj,handles);
            
        end
        
        function result = CalcCountRate_old(D, n, rate)
            % calculates the count rate from the raw data (= APD buffer readout)
            % i.e. buffer[k+1] - buffer[k] = countrate[k]
            
            aux1=D(1:2:end);
            aux2=D(2:2:end);
            hlp=double(aux2-aux1);
            
            if n>1
                E = [];
                for k = 1:1:n
                    E = [E.' hlp(k:n:end).'].';
                end
                E = mean(E)/1000;%transform to have kcps
            else
                E = hlp/1000;%transform to have kcps
            end
            
            result = E*rate;
        end
        
        function result = CalcCountRate(D, n, rate)
                    
            result = diff(D)*rate/1000;
        end
       
        function SetStatus(handles,msg)
            
            set(handles.textStatus,'String',msg);
        end
        
    end
    
end
