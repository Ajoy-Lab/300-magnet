classdef PiezoMadCityLabs_simu < handle
     
    properties
        LibraryName             % alias for library loaded
        LibraryFilePath         % path to Madlib.dll 
        HeaderFilePath          % path to Madlib.h 
        HighEndOfRange = [200 200 200]; %in mum
        LowEndOfRange = [0 0 0]; %in mum
        MinDwellTime = 1e-3; %in s
        ID
        SampleRate;
        % PC: let's set here the ADC and DAQ times if we want to change them later on, without changing all the code
        ADCtime=5; %ms
        DAQtime=1; %ms
        StabilizeTime=0.05; % Time to wait before starting each ramp for the piezo to stabilize.
        %A flat section at the start of ramp
        nFlat = 100;
        %Let the waveform over run the start and end
        nOverRun = 75;
        % the scan is done in the following way: say you want to scan from A to
        % B; first nFlat points are scanned, then nOverRun, then the points of interest 
        % from A to B, then other nOverRun points.
        %The sensor reading lags the written value by approximately 15pts. 
        %This was determined by running MCL_TriggerWaveformAcquisition and 
        %comparing the written and read waveforms for a range of different "ramps"
        LagPts =5; % for the time being, unused
        %PC
        totWaveform;
        theorywaveform;
        realwaveform;
        precision = [0.0001,0.0001,0.0001]; %in mum; used for tracking
    end
    
    methods
        % instantiation function
        function obj=PiezoMadCityLabs_simu()
        %    obj.LibraryName = LibraryName;
         %   obj.LibraryFilePath = LibraryFilePath;
          %  obj.HeaderFilePath = HeaderFilePath;
           obj.Initialization();
        end
        
        function Connect(obj)
%            obj.ID = calllib(obj.LibraryName,'MCL_InitHandleOrGetExisting');
 %           if obj.ID == 0
  %              disp('Failed to attain control of device');
   %         
   %         end
        end
        
        function CloseConnection(obj)
%            calllib(obj.LibraryName,'MCL_ReleaseAllHandles');
            disp('All handles to MCL Piezo released');
        end
        
        function Initialization(obj) 
%            if ~libisloaded(obj.LibraryName)
%                disp(['Loading ',obj.LibraryName]);
%                [pOk,warnings] = loadlibrary(obj.LibraryFilePath,obj.HeaderFilePath,'alias',obj.LibraryName);
%            end
            disp([obj.LibraryName,' library loaded']);
            obj.Connect;
  
            adcPtr=libpointer('doublePtr',0);
            daqPtr=libpointer('doublePtr',0);
%            calllib(obj.LibraryName,'MCL_ChangeClock',obj.ADCtime,0,obj.ID); %this is ADC (reading data) clock, set to 5ms
 %           calllib(obj.LibraryName,'MCL_ChangeClock',obj.DAQtime,1,obj.ID); %this is DAQ (writing data) clock, set to 1ms
  %          calllib(obj.LibraryName,'MCL_GetClockFrequency',adcPtr,daqPtr,obj.ID);
            obj.SampleRate = 1/(adcPtr.Value*1e-3); %display that it is not the real one
            disp(['piezo sample rate set to: ' num2str(obj.SampleRate) 'Hz']);
            disp(['piezo adc rate set to: ' num2str(adcPtr.Value) 'ms']);   % This should be 5ms, as above
%            daqPtr.Value;
            disp(['piezo daq rate set to: ' num2str(daqPtr.Value) 'ms']);   % This should be 1ms, as above
%            calllib(obj.LibraryName,'MCL_IssConfigurePolarity',1,3,obj.ID);
%            calllib(obj.LibraryName,'MCL_PixelClock',obj.ID);
%            calllib(obj.LibraryName,'MCL_IssBindClockToAxis',1,3,5,obj.ID);
            % Allows an external clock pulse to be bound to the read of a particular axis.  
            % clock=1 -> pixel clock, mode=3 high to low pulse axis=5 : Waveform Read
            obj.SampleRate = 200; %use this value to complete fake scans
        end
        
        function p = Pos(obj,axis)            
            %query and return position of axis (x=1, y=2, z=3)
%            p = calllib(obj.LibraryName,'MCL_SingleReadN',axis,obj.ID);
			p = 100*rand;
        end
        
        function p = Mov(obj, Pos, Axis)
            %absolute change in position (pos) of axis (x=1, y=2, z=3), return success or
            %error code
%            p = calllib(obj.LibraryName,'MCL_SingleWriteN',Pos,Axis,obj.ID);
           p = 100*rand; 
            %%%%% THERE SHOULD BE A WARNIGN HERE about not good to move
          
        end
        
        function TranslateError(obj, errCode)
            disp(['Nano-Drive error code ' num2str(errCode) ' :']);
            switch errCode
                case 0
                    disp('Task has been completed successfully');
                case -1
                    disp('These errors generally occur due to an internal sanity check failing.');
                case -2
                    disp('A problem occured when transferring data to the Nano-Drive. It is likely that the Nano-Drive will have to be power cycled to ciorrect theese issues.');
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
        
         function Scan(obj, X,Y,Z, TPixel,ramp_axis) %1d scan
         %TPixel: Pixel time (set by user, in ImageAcquire: it is the dwell) 
         %nFlat (nb of points): A flat section at the start of ramp
         %nOverRun (nb of points): Let the waveform over run the start and end
          
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
            pause(obj.StabilizeTime); %  means: piezo needs at most 0.05sec to go to any scan starting point
            % PC: Changed this to be a shorter time. From tests, it seems that 50ms is enough for the piezo to move and stabilize
            
            N = length(points{ramp_axis});
%             
%             %As explained in ImageAcquireFunctions' StartScan1D function, in
%             %the original code the function below was round, but this gave
%             %an error - changed to ceil
            n = ceil(TPixel*obj.SampleRate);
%             %PC: right now the dwell is fixed (WHY?) so that n=1. 
%             % In any case we would not want to have n<1
%             if n<1
%                 warning(['Dwell time too short. The piezo samp rate is ',num2str(obj.SampleRate),...
%                     ', so the dwell time must be at least ',num2str(1/obj.SampleRate),'sec.']);
%                 return;
%             end
%             % SampleRate is set by the MCL clock frequency in the
%             % initialization of the class: see above:
%             % calllib(obj.LibraryName,'MCL_GetClockFrequency',adcPtr,daqPtr,obj.ID);
%             
%             % Total waveform points in the ramp
             nRamp = N*2*n; 
%             %PC: We acquire two points for every calculated/displayed point. 
%             % Also, apparently, if we set a dwell time longer than 1/SampleRate we do not sit at the same point
%             % for all that time, but subdivide the interval in smaller steps.
%             % Not sure if this is a good solution.
%             
%             
%             % points in the waveform to be written to piezo
             nWaveform = obj.nFlat + obj.nOverRun + nRamp + obj.nOverRun;
%             size(fin_pos)
%             size(init_pos)
%             size(nRamp)
%             incr = (fin_pos-init_pos)/nRamp;
%             ramp = (init_pos-incr*obj.nOverRun):incr:(fin_pos+incr*obj.nOverRun);
%             smooth_ramp=(init_pos-incr*obj.nOverRun)+incr*obj.nOverRun*(1-cos(pi/4/(obj.nFlat+obj.nOverRun)*(0:obj.nFlat+obj.nOverRun-1)))/(1-cos(pi/4));
%             smooth_ramp=[smooth_ramp init_pos:incr:(fin_pos+incr*obj.nOverRun)];
%             %obj.totWaveform = [ones(1,obj.nFlat)*ramp(1) ramp ];

			
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

 %            WaveformTime=max(obj.ADCtime,obj.DAQtime);
             WaveformPtr = libpointer('doublePtr',obj.totWaveform); 
            WaveformRead = obj.totWaveform; %WaveformRead will record the actual movement of the piezo; 
             WaveformReadPtr = libpointer('doublePtr',WaveformRead);
% %            calllib(obj.LibraryName,'MCL_Setup_LoadWaveFormN',ramp_axis,nWaveform,WaveformTime,WaveformPtr,obj.ID); %here
% %            calllib(obj.LibraryName,'MCL_Setup_ReadWaveFormN',ramp_axis,nWaveform,WaveformTime,obj.ID);%here
% %            calllib(obj.LibraryName,'MCL_TriggerWaveformAcquisition',ramp_axis,nWaveform,WaveformReadPtr,obj.ID);
%             % The pixel clock fires one pulse per waveform point now that
%             % both "time interval"  in ms in the two functions marked %here
%             % above are the same (set to 5ms, which is the longest time
%             % between the piezo adc rate and the piezo daq rate)
%             % PC: changed so that this is really what it is done, irrespective of what time we fix.
%             
        obj.theorywaveform = WaveformPtr.Value((obj.nFlat+obj.nOverRun+1):2*n:(obj.nFlat+obj.nOverRun+nRamp));  %or NX*2*n
        %obj.realwaveform = WaveformReadPtr.Value((obj.nFlat+obj.nOverRun+1+obj.LagPts):2*n:(obj.nFlat+obj.nOverRun+nRamp+obj.LagPts)); %or NX*2*n
        obj.realwaveform = 1000*rand(1,length(obj.theorywaveform));
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
            
            points{1} = X;
            points{2} = Y;
            points{3} = Z;
            
            %Move to first point in the scan   
            obj.Mov(X(1),1);
            obj.Mov(Y(1),2);
            obj.Mov(Z(1),3);
            pause(obj.StabilizeTime);
            % PC: Changed this to be a shorter time. From tests, it seems that 50ms is enough for the piezo to move and stabilize
            
            N = length(points{ramp_axis});
            %number of waveform points per image pixel
            n = ceil(TPixel*obj.SampleRate);
            %PC: right now the dwell is fixed (WHY?) so that n=1. 
            % In any case we would not want to have n<1
            if n<1
                warning(['Dwell time too short. The piezo samp rate is ',num2str(obj.SampleRate),...
                    ', so the dwell time must be at least ',num2str(1/obj.SampleRate),'sec.']);
                return;
            end
            
            %Total waveform points in the ramp
            nRamp = N*2*n;            
            % points in the waveform to be written to NanoDrive
            nWaveform = obj.nFlat + obj.nOverRun + nRamp + obj.nOverRun;
            WaveformRead = ones(1,nWaveform);
            WaveformReadPtr = libpointer('doublePtr',WaveformRead);
            
 %           calllib(obj.LibraryName,'MCL_TriggerWaveformAcquisition',ramp_axis,nWaveform,WaveformReadPtr,obj.ID);
            
            obj.realwaveform = WaveformReadPtr.Value((obj.nFlat+obj.nOverRun+1+obj.LagPts):2*n:(obj.nFlat+obj.nOverRun+nRamp+obj.LagPts));  %or NX*2*n
         end
        

          
        
        
    end
end

