classdef SignalGeneratorAgilent_simu < handle
   
    
    properties
        
         SocketHandle  % handle associated with Protocol class
         IPAddress     % Device IP Address for TCP/IP control
         TCPPort       % Port for TCP/IP control
         Timeout = 10; % TimeoutTime
         InputBufferSize = 1000000; % was 2^16, but this vaolue never passed on
         OutputBufferSize = 1000000; %2^16;
         
        Frequency
        FrequencyMode
        Amplitude
        SweepStart
        SweepStop
        SweepStep
        SweepPoints
        SweepMode
        SweepTrigger
        SweepPointTrigger
        SweepDirection
        DwellTime %h in s; how much time it stays in the same freq sweep point; resolution 0.001s; 
        Delay %in s; how long after receiving the trigger it starts the sweep; 
        
        MinFreq = 100*1e3; %Hz
        MaxFreq = 20*1e9; %Hz
        MinAmp = -20; %dBm
        MaxAmp = 15; %dBm
        MinDwellTime = 100*1e-6; %s
        MaxDwellTime = 1; %s
        MinDelay = 10*1e-9; %s
        MaxDelay = 10000; %s
        FreqRes = 0.01; %Hz
    end
    
    methods
        function [obj] = SignalGeneratorAgilent_simu(obj,a,b,c,d,f)
          
           
           % obj.IPAddress = varargin{1};
            %obj.TCPPort = varargin{2};
%            obj.SocketHandle = tcpip(obj.IPAddress,obj.TCPPort);
               
             
%            set(obj.SocketHandle,'Timeout',obj.Timeout);
%            set(obj.SocketHandle,'InputBufferSize',obj.InputBufferSize);
%            set(obj.SocketHandle,'OutputBufferSize',obj.OutputBufferSize);
   
        end
        function [obj] = SignalGeneratorAgilent(obj,a,b,c,d,f)
        end
        function [obj] = open(obj)
            
%            try
%                fopen(obj.SocketHandle);
%            catch exception
%                disp('error to open SG');
%            end
        end
        
        function [obj] = close(obj)
%            fclose(obj.SocketHandle);
        end
        
        function [err] = setAmplitude(obj)
            err = 0;
             if obj.Amplitude < obj.MinAmp || obj.Amplitude > obj.MaxAmp
                uiwait(warndlg({'SG Amplitude out of range. Aborted.'}));
                err=1;
                return;
            end 
            
            % send the set amplitude command
%            obj.writeToSocket(sprintf(':POW:LEV:IMM:AMPL %f DBM',obj.Amplitude));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
           
        end
        
        function [err] = setFrequency(obj)
            err= 0;
            if obj.Frequency < obj.MinFreq || obj.Frequency > obj.MaxFreq
                uiwait(warndlg({'SG Frequency out of range. Aborted.'}));
                err=1;
                return;
            end
            
            % send the set frequency command
%            obj.writeToSocket(sprintf(':FREQ %f',obj.Frequency));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
            
        end
         
        function [obj] = reset(obj)
%            obj.writeToSocket('*RST');
        end
         
         function [obj] = setRFOn(obj)
            
%            obj.writeToSocket(sprintf(':OUTP ON'));
            
             % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function [obj] = setRFOff(obj)
          
%            obj.writeToSocket(sprintf(':OUTP OFF'));
            
             % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        
        function writeToSocket(obj,string)
            
            % check if the socket is already open
%            if (strcmp(obj.SocketHandle.Status,'closed'))
%                % open a socket connection
%                fopen(obj.SocketHandle);
%                CloseOnDone = 1;
%            else
%                CloseOnDone = 0;
%            end
            
            % send the set frequency command
%            fprintf(obj.SocketHandle,string);
            
%            if CloseOnDone,
%                % close the socket
%                fclose(obj.SocketHandle);
%            end
            
        end
        
        function [output] = writeReadToSocket(obj,string)
            
            % check if the socket is already open
%            if (strcmp(obj.SocketHandle.Status,'closed'))
%                % open a socket connection
%                fopen(obj.SocketHandle);
%                CloseOnDone = 1;
%            else
%                CloseOnDone = 0;
%            end
%
%            
%            % send the set frequency command
%            fprintf(obj.SocketHandle,string)
%            
%            output = fscanf(obj.SocketHandle);
%            
%            if CloseOnDone
%                % close the socket
%                fclose(obj.SocketHandle);
%            end
        end
               
       
  function [err] = SetAll(obj,handles)
      err = 0;
      %obj.open();
      obj.reset();
      
      erra = obj.setAmplitude();
      errb = obj.setFrequency();
      
      if (erra || errb)
         err = 1; 
      end
      
      obj.setRFOn();
      %obj.close();
     
  end
  
% Methods not being used %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [obj] = setFrequencyMode(obj)

            % send the set frequency command
%            obj.writeToSocket(sprintf(':FREQ:MODE %s',obj.FrequencyMode));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
            
        end
        
         function [obj] = setDwellTime(obj)
             
             if obj.DwellTime < obj.MinDwellTime || obj.DwellTime > obj.MaxDwellTime
                uiwait(warndlg({'Dwell time out of range. Aborted.'}));
                return;
            end 

            % send the set frequency command
%            obj.writeToSocket(sprintf(':SWE:DWELl %f',obj.DwellTime));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
            
         end
  
 % Sweep in our signal generator is LIST
        
        function [obj] = setSweepStart(obj)
              
              if obj.SweepStart < obj.MinFreq || obj.SweepStart > obj.MaxFreq
                uiwait(warndlg({'Sweep start frequency out of range. Aborted.'}));
                return;
              end
            %may give a pb if the sweep direction is not up but down
            
            % send the set frequency command
%            obj.writeToSocket(sprintf(':FREQ:STAR %f',obj.SweepStart));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
            
        end
        
        function [obj] = setSweepStop(obj)
                                    
         if obj.SweepStop < obj.MinFreq || obj.SweepStop > obj.MaxFreq
                uiwait(warndlg({'Sweep stop frequency out of range. Aborted.'}));
                return;
         end
            %may give a pb if the sweep direction is not up but down
            
            % send the set frequency command
%            obj.writeToSocket(sprintf(':FREQ:STOP %f',obj.SweepStop));
            
      
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        
        function [obj] = setSweepPoints(obj)
            
%            obj.writeToSocket(sprintf('SWE:POIN %d',obj.SweepPoints));
              
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        
        function [obj] = setSweepMode(obj)
            if strcmp(obj.SweepMode,'LIST')
               
%                    obj.writeToSocket(sprintf(':LIST:TYPE %s',obj.SweepMode));

                    % sets to frequency sweep (not power sweep mode)
%                     obj.writeToSocket(sprintf(':FREQ:MODE LIST'));
%                     obj.writeToSocket(sprintf(':POW:MODE FIX'));
                    
                    
            else % case STEP (??????????????????) NOT SURE WHAT SHOULD HAPPEN HERE
%                    obj.writeToSocket(sprintf(':FREQ:MODE CW'));
%                    obj.writeToSocket(sprintf(':POW:MODE FIX'));
            end
             % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function [obj] = setSweepTrigger(obj)
            
%            obj.writeToSocket(sprintf(':TRIG:SEQ:SOUR %s',obj.SweepTrigger));
             % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
            
        end 
      
        
        function [obj] = setSweepDirection(obj)
            
%            obj.writeToSocket(sprintf(':SOUR:LIST:DIR %s',obj.SweepDirection));
            
             % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end 
        
        
        function [obj] = setSweepContinuous(obj)
            % set to single sweep
            %obj.writeToSocket(':INIT:CONT:ALL 0');
            
              % set to continuous sweep
%           obj.writeToSocket(':INIT:CONT:ALL 1');
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function [obj] = armSweep(obj)
%            obj.writeToSocket(':INIT:IMM:ALL');
             notify(obj,'SignalGeneratorChangedState');
            
        end
        
        function [obj] = SetDelay(obj)
            
            if strcmp(obj.Delay, 'IMM')
%                obj.writeToSocket('TRIG:SEQ:IMM');
                %start immediately after trigger
                
            else
            
           if obj.Delay < obj.MinDelay || obj.Delay > obj.MaxDelay
                uiwait(warndlg({'Delay out of range. Aborted.'}));
                return;
           end   
            
%            obj.writeToSocket(sprintf('TRIG:SOUR:EXT:DEL %f',obj.Delay)); 
           
            
            end
            
             notify(obj,'SignalGeneratorChangedState');
        end
        
        % QUERY FUNCTIONS
        function [obj] = getFrequency(obj)
%            s = obj.writeReadToSocket(sprintf(':FREQ?'));
%            obj.Frequency = str2num(s);
        end
        
        function [obj] = getFrequencyMode(obj)
%            s = obj.writeReadToSocket(sprintf(':FREQ:MODE?'));
%            obj.FrequencyMode = deblank(s);
        end
        
        function [obj] = getAmplitude(obj)
%            s = obj.writeReadToSocket(sprintf(':POW:LEV:IMM:AMPL?'));
%            obj.Amplitude = str2num(s);
            
        end
        
        function [obj] = getSweepStart(obj)
%            s = obj.writeReadToSocket(sprintf(':FREQ:STAR?'));
%            obj.SweepStart = str2num(s);
        end
        
        function [obj] = getSweepStop(obj)
%            s = obj.writeReadToSocket(sprintf(':FREQ:STOP?'));
%            obj.SweepStop = str2num(s);
        end
    
        function [obj] = getSweepPoints(obj)
%            s = obj.writeReadToSocket(sprintf(':SWE:POIN?'));
%            obj.SweepPoints = str2num(s);
        end
        
        function [obj] = getSweepMode(obj)
%            s = obj.writeReadToSocket(sprintf(':LIST:TYPE?'));
%            obj.SweepMode = deblank(s);
        end
        
        function [obj] = getSweepTrigger(obj)
%            s = obj.writeReadToSocket(sprintf(':TRIG:SEQ:SOUR?'));
%            obj.SweepTrigger = deblank(s);
        end 
        
        function [obj] = getSweepDirection(obj)
%            s = obj.writeReadToSocket(sprintf(':SOUR:LIST:DIR?'));
%            obj.SweepDirection = deblank(s);
        end 
        
         function [obj] = getDwellTime(obj)
             
            % send the set frequency command
%            s = obj.writeReadToSocket(sprintf(':SWE:DWELl?'));
%            obj.DwellTime =  str2num(s);
        end
        
         function [obj] = setModulationOff(obj)
%            obj.writeToSocket(':OUTP:MOD:STAT OFF');
        end
         
            
    end
    
    
    
    events
       SignalGeneratorChangedState
    end
end
