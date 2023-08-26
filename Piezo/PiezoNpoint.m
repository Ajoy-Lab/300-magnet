classdef PiezoNpoint < handle
    
    properties
        LibraryName             % alias for library loaded
        LibraryFilePath         % path to Madlib.dll
        HeaderFilePath          % path to Madlib.h
        ID
        HighEndOfRange          % in mum
        LowEndOfRange           % in mum
        SampleRate
        ADCtime                 % in ms
        DAQtime                 % in ms
        StabilizeTime           % Time to wait before starting each ramp for the piezo to stabilize.
        nFlat                   % A flat section at the start of ramp
        nOverRun                % Let the waveform over run the start and end
        
        % the scan is done in the following way: say you want to scan from A to
        % B; first nFlat points are scanned, then nOverRun, then the points of interest
        % from A to B, then other nOverRun points.
        
        % The sensor reading lags the written value by approximately 5pts.
        % This was determined by running MCL_TriggerWaveformAcquisition and
        % comparing the written and read waveforms for a range of different "ramps"
        
        % the LagPts are then the
        % extra points between the first nOverRun scan points and the scan
        % range of interest
        
        LagPts
        totWaveform;
        theorywaveform;
        realwaveform;
        precision %in mum; used for tracking
        
    end
    
    methods
        
        function [obj] = PiezoNpoint(LibraryName,LibraryFilePath,HeaderFilePath,ADCtime,DAQtime)
            % instantiation function
            obj.LibraryName = LibraryName;
            obj.LibraryFilePath = LibraryFilePath;
            obj.HeaderFilePath = HeaderFilePath;
            obj.Initialization(ADCtime,DAQtime);
        end
        
        function Connect(obj)  %   MODIFIED
            %obj.ID = calllib(obj.LibraryName,'MCL_InitHandleOrGetExisting');
            %initialize
            
            obj = serial('COM3');

            if strcmp(obj.Status,'closed')== 1
                fopen(obj);
            end    
            USBTime=1e3; %factor
            obj.BaudRate = 115200*USBTime;
            pause_Time=1e-1;
            
            if obj.ID == 0
                disp('Failed to attain control of device');
                
            end
        end
       
        
        function CloseConnection(obj)  %   MODIFIED
            %calllib(obj.LibraryName,'MCL_ReleaseAllHandles');
            % function returns void, so no check possible
            fclose(obj);
            disp('All handles to MCL Piezo released');
        end
        
        function Initialization(obj,ADCtime,DAQtime)
            if ~libisloaded(obj.LibraryName)
                disp(['Loading ',obj.LibraryName]);
                loadlibrary(obj.LibraryFilePath,obj.HeaderFilePath,'alias',obj.LibraryName);
                %this function returns void, so no check possible
            end
            disp([obj.LibraryName,'library loaded']);
            obj.Connect;
            
            adcPtr=libpointer('doublePtr',0);
            daqPtr=libpointer('doublePtr',0);
            [err] = calllib(obj.LibraryName,'MCL_ChangeClock',ADCtime,0,obj.ID); %this is ADC (reading data) clock
            if err ~= 0
                obj.TranslateError(err);
            end
            [err] = calllib(obj.LibraryName,'MCL_ChangeClock',DAQtime,1,obj.ID); %this is DAQ (writing data) clock
            if err ~= 0
                obj.TranslateError(err);
            end
            [err] = calllib(obj.LibraryName,'MCL_GetClockFrequency',adcPtr,daqPtr,obj.ID);
            if err ~= 0
                obj.TranslateError(err);
            end
            obj.SampleRate = 1/(adcPtr.Value*1e-3);
            disp(['piezo sample rate set to: ' num2str(obj.SampleRate) 'Hz']);
            disp(['piezo adc rate set to: ' num2str(adcPtr.Value) 'ms']);
            disp(['piezo daq rate set to: ' num2str(daqPtr.Value) 'ms']);
            [err] = calllib(obj.LibraryName,'MCL_IssConfigurePolarity',1,3,obj.ID);
            if err ~= 0
                obj.TranslateError(err);
            end
            [err] = calllib(obj.LibraryName,'MCL_PixelClock',obj.ID);
            if err ~= 0
                obj.TranslateError(err);
            end
            [err] = calllib(obj.LibraryName,'MCL_IssBindClockToAxis',1,3,5,obj.ID);
            if err ~= 0
                obj.TranslateError(err);
            end
            % Allows an external clock pulse to be bound to the read of a particular axis.
            % clock=1 -> pixel clock, mode=3 high to low pulse axis=5 : Waveform Read
            
        end
        
        function p = Pos(obj,axis)    %   MODIFIED
            %query and return position of axis (x=1, y=2, z=3)
            %p = calllib(obj.LibraryName,'MCL_SingleReadN',axis,obj.ID);
           
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pause_Time=1e-1;  %% PAUSE TIME 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            p= READ_n(axis,obj.ID,pause_Time);
            if p < 0
                obj.TranslateError(p);
            end
            
        end
        
        function READ_n(n,Piezo,pause_Time) %   ADDED
        %Pause_Time=5e-4; % seconds
        % zero=218
        %
        % n gives the axis 
        % query and return position of axis 
        %  x  axis in case n=1, 
        %  y  axis in case n=2, 
        %  z  axis  in case n=3

        address_n=strcat('1183',num2str(n),'334');
        cmdstr_n=strcat('A0',address_n,'55');
        cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 11 12]);
        l_n = length(cmdstr_n);
        c_n = hex2dec(reshape(cmdstr_n,2,l_n/2)');
        fwrite(Piezo,c_n);
        pause(pause_Time);
        numBytes = Piezo.BytesAvailable;
        ret_str_n = fread(Piezo,numBytes);
        pause(pause_Time);
        [m_n,n_n] = size(address_n);
        k_n = reshape(ret_str_n,10,m_n);
        s_n = k_n(:,1);
        s_n = dec2hex(s_n);
        s_n = reshape(s_n',1,20);
        s_n = s_n(11:18);
        s_n=s_n([7 8 5 6 3 4 1 2]);
        hex2dec(s_n);
        end
    
       
        
        function Mov(obj, Pos, Axis)  %   MODIFIED
            %absolute change in position (pos) of axis (x=1, y=2, z=3)
            %err = calllib(obj.LibraryName,'MCL_SingleWriteN',Pos,Axis,obj.ID);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pause_Time=1e-1;  %% PAUSE TIME 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            err = MOVE_n(Pos,Axis,obj.ID,pause_Time);
            if err ~= 0
                obj.TranslateError(err);
            end
            %in our implementation, this error should not be called bc
            %Imaging GUI tests for moving errors beyond the piezo limits
        end
        

        function MOVE_n(Move_n,n,Piezo_n,pause_Time)    %   ADDED
        %Pause_Time=1e-5; % seconds
        %
        % micron  - Range X [0-100] Microns
        % zero=218
        %
        % n gives the axis 
        % query and return position of axis 
        %  x  axis in case n=1, 
        %  y  axis in case n=2, 
        %  z  axis  in case n=3
        address_n=strcat('1183',num2str(n),'218');
        Write_n=num2str(dec2hex(Move_n,8));
        cmdstr_n=strcat('A2',address_n,Write_n,'55');
        % -- reorder the bytes -- 
        cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
        L_n = length(cmdstr_n);
        c_n = hex2dec(reshape(cmdstr_n,2,L_n/2)');
        fwrite(Piezo_n,c_n);    
        pause(pause_Time);
        end
        
        function Scan(obj, X,Y,Z, TPixel, ramp_axis) %1d scan
            % TPixel: Pixel time (set by user, in Imaging: it is the dwell)
            % X, Y, Z: arrays of the points that are scanned, only one should be an array (corresponding to the ramp_axis), the others should be constants single values
            % ramp_axis: values: 1,2,3, defines the direction of the scan
            % nFlat (nb of points): A flat section at the start of ramp
            % nOverRun (nb of points): Let the waveform over run the start and end
            
            points{1} = X;
            points{2} = Y;
            points{3} = Z;
            
            %PC: Initial and final position
            init_pos=points{ramp_axis}(1);
            fin_pos=points{ramp_axis}(end);
            %Move to first point in the scan
            obj.Mov(X(1),1);
            obj.Mov(Y(1),2);
            obj.Mov(Z(1),3);
            pause(obj.StabilizeTime); %  means: piezo needs at most Stabilize time in sec to go to any scan starting point
            % PC: From tests, it seems that 50ms is enough for the piezo to move and stabilize
            
            N = length(points{ramp_axis});
            
            %warning below should never be called bc another warning exist
            %in Imaging GUI
            if TPixel*obj.SampleRate<1
                warning(['Dwell time too short. The piezo samp rate is ',num2str(obj.SampleRate),...
                    ', so the dwell time must be at least ',num2str(1/obj.SampleRate),'sec.']);
                return;
            end
            
            %As explained in ImagingFunctions' StartScan1D function, in
            %the original code the function below was round, but this gave
            %an error - changed to ceil
            n = ceil(TPixel*obj.SampleRate);
            % Total waveform points in the ramp
            nRamp = N*2*n;
            %PC: We acquire two points for every calculated/displayed point.
            % Also, apparently, if we set a dwell time longer than 1/SampleRate we do not sit at the same point
            % for all that time, but subdivide the interval in smaller steps.
            % Not sure if this is a good solution.
            % CDA: yes it is a good solution bc we want that the piezo be
            % moving with a constant speed. It is *not* a good idea to
            % program a "stair-like" waveform; if we increase the dwell
            % time, what we are in fact doing is making the scan ramp less
            % and less steep by acquiring more points (as pointed out
            % above, by subdividing the interval in smaller steps).
            
            % points in the waveform to be written to piezo
            nWaveform = obj.nFlat + obj.nOverRun + nRamp + obj.nOverRun;        
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % New Ramping Mechanism
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % take first two points and calculate the increment per point including the dwell time (n)
            incr = (fin_pos-init_pos)/(nRamp-2*n);
            % the initial smooth starting ramp
            smooth_ramp=(init_pos-(2*n-1)*incr/2-incr*obj.nOverRun)+incr*obj.nOverRun*(1-cos(pi/4/(obj.nFlat+obj.nOverRun)*(0:obj.nFlat+obj.nOverRun-1)))/(1-cos(pi/4));
            % the ramp over the scanning points including the overun points at the end
            scan_ramp = (init_pos-(2*n-1)*incr/2):incr:(fin_pos + (2*n-1)*incr/2 + incr*obj.nOverRun);
            % connect both ramps
            smooth_ramp = [smooth_ramp scan_ramp];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Coerce Waveform
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj.totWaveform =smooth_ramp;
            for k=1:1:length(obj.totWaveform)
                if obj.totWaveform(k) < obj.LowEndOfRange(1)
                    obj.totWaveform(k) = obj.LowEndOfRange(1);
                elseif obj.totWaveform(k) > obj.HighEndOfRange(1)
                    obj.totWaveform(k) = obj.HighEndOfRange(1);
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Send Waveform to Piezo
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            WaveformTime=max(obj.ADCtime,obj.DAQtime);
            WaveformPtr = libpointer('doublePtr',obj.totWaveform);
            WaveformRead = obj.totWaveform; %WaveformRead will record the actual movement of the piezo;
            WaveformReadPtr = libpointer('doublePtr',WaveformRead);
            [err] = calllib(obj.LibraryName,'MCL_Setup_LoadWaveFormN',ramp_axis,nWaveform,WaveformTime,WaveformPtr,obj.ID); %here
            if err ~= 0
                obj.TranslateError(err);
            end
            [err] = calllib(obj.LibraryName,'MCL_Setup_ReadWaveFormN',ramp_axis,nWaveform,WaveformTime,obj.ID);%here
            if err ~= 0
                obj.TranslateError(err);
            end
            [err] = calllib(obj.LibraryName,'MCL_TriggerWaveformAcquisition',ramp_axis,nWaveform,WaveformReadPtr,obj.ID);
            if err ~= 0
                obj.TranslateError(err);
            end
            % The pixel clock fires one pulse per waveform point now that
            % both "time interval"  in ms in the two functions marked %here
            % above are the same (set to 5ms, which is the longest time
            % between the piezo adc rate and the piezo daq rate)
            % PC: changed so that this is really what it is done, irrespective of what time we fix.
            
            obj.theorywaveform = WaveformPtr.Value((obj.nFlat+obj.nOverRun+1):2*n:(obj.nFlat+obj.nOverRun+nRamp));  %or NX*2*n
            obj.realwaveform = WaveformReadPtr.Value((obj.nFlat+obj.nOverRun+1+obj.LagPts):2*n:(obj.nFlat+obj.nOverRun+nRamp+obj.LagPts));  %or NX*2*n
            %PC: These are the waveforms sent and read. Used to check the piezo behavior
            % Vary LagPoints until the two match!!!
            %             figure(101)
            %             Lag=4;
            %             plot(WaveformPtr.Value);
            %             hold on
            %             plot(WaveformReadPtr.Value(1+Lag:end),'r');
            %             plot(smooth_ramp,'k');
            %             hold off
            %             grid on
            %             axis tight
            %             figure(102)
            %             plot(WaveformPtr.Value(1:end-Lag)-WaveformReadPtr.Value(1+Lag:end),'r');
            %             axis tight
        end
        
        function Trigg(obj, X, Y, Z,TPixel,ramp_axis) %2d scan, looping over some axis 'm'
            % setup the scan ramp for the ramped axis with Scan for the first point of the looped direction 'm', Trig to repeat
            % the same ramp-scan for each 'm'-column.
            % ramp_axis: values: 1,2,3, defines the direction of the scan
            
            points{1} = X;
            points{2} = Y;
            points{3} = Z;
            
            %Move to first point in the scan
            obj.Mov(X(1),1);
            obj.Mov(Y(1),2);
            obj.Mov(Z(1),3);
            pause(obj.StabilizeTime);
            % PC: From tests, it seems that 50ms is enough for the piezo to move and stabilize
            
            N = length(points{ramp_axis});
            %number of waveform points per image pixel
            
            %warning below should never be called bc another warning exist
            %in Imaging GUI
            if TPixel*obj.SampleRate<1
                warning(['Dwell time too short. The piezo samp rate is ',num2str(obj.SampleRate),...
                    ', so the dwell time must be at least ',num2str(1/obj.SampleRate),'sec.']);
                return;
            end
            
            n = ceil(TPixel*obj.SampleRate);
            
            %Total waveform points in the ramp
            nRamp = N*2*n;
            % points in the waveform to be written to NanoDrive
            nWaveform = obj.nFlat + obj.nOverRun + nRamp + obj.nOverRun;
            WaveformRead = ones(1,nWaveform);
            WaveformReadPtr = libpointer('doublePtr',WaveformRead);
            
            [err] = calllib(obj.LibraryName,'MCL_TriggerWaveformAcquisition',ramp_axis,nWaveform,WaveformReadPtr,obj.ID);
            if err ~= 0
                obj.TranslateError(err);
            end
            
            obj.realwaveform = WaveformReadPtr.Value((obj.nFlat+obj.nOverRun+1+obj.LagPts):2*n:(obj.nFlat+obj.nOverRun+nRamp+obj.LagPts));  %or NX*2*n
        end
        
    end
    
    methods (Static)
       
    function TranslateError(errCode)
        
           %CDA: This library of MCL errors compiled by CFA
           %people and never actually tested in our setup
        
            disp(['Nano-Drive error code ' num2str(errCode) ' :']);
            switch errCode
                case 0 %should not enter this
                    disp('Task has been completed successfully');
                case -1
                    disp('These errors generally occur due to an internal sanity check failing.');
                case -2
                    disp('A problem occured when transferring data to the Nano-Drive. It is likely that the Nano-Drive will have to be power cycled to correct theese issues.');
                case -3
                    disp('The Nano-Drive cannot complete the task becasue it is not attached.');
                case -4
                    disp('Using a function from the library which teh Nano-Drive does not support causes tehse errors.');
                case -5
                    disp('The Nano-Drive is currently completing or waiting to complete another task.');
                case -6
                    disp('An argumemnt is out of range or a required pointer is equal to null.');
                case -7
                    disp('Attempting an operation on an axis that does not exist in the Nano-Drive.');
                case -8
                    disp('The handle is not valid. Or at least is not valid in this instance of the DLL.');
            end
        end    
        
    end
end

