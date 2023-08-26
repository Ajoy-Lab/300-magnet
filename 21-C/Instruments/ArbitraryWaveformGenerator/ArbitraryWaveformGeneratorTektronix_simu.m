classdef ArbitraryWaveformGeneratorTektronix_simu < handle
    
    properties
        
         SocketHandle  % handle associated with Protocol class
         IPAddress     % Device IP Address for TCP/IP control
         TCPPort       % Port for TCP/IP control
         Timeout = 10; % TimeoutTime
         InputBufferSize = 1e7;     %1000000; 
         OutputBufferSize = 1e7;       %1000000; 
         SampleRate 
         
        Frequency = [];    % in Hz; array of 4, 1 per channel
        Amplitude = [];    % in dBm; array of 4, 1 per channel
        
        MinFreq = 0;       %Hz    
        MaxFreq = 370*1e6; %Hz
        MinAmp = -30;      %dBm, or 20mVpp
        MaxAmp = 17;       %dBm, or 4.5Vpp
        MinSampleRate = 1e7;
        MaxSampleRate = 1.2e9;

        % unsure where those are used
        maxsamples = 32e6; % Maximum number of samples per channel
        maxsegments = 8e3;  % Maximum number of segments in sequence mode
        maxwaveforms = 32e3;  % Maximum number of waveforms
        minsegment_length = 250; % Minimum seqment length for hardware sequencer
        
        max_number_of_reps = 65000;

    end
    
    methods
        
         function [obj] = SetAllChannelsOn(obj)
            
           % obj.writeToSocket('OUTP1 ON; OUTP2 ON; OUTP3 ON; OUTP4 ON');
            
        end
        
        function [obj] = SetAllChannelsOff(obj)
            
           % obj.writeToSocket('OUTP1 OFF; OUTP2 OFF; OUTP3 OFF; OUTP4 OFF');
            
        end
        
        
        
        
        function [obj] = create_null(obj,NullShape,C_is_on,N_is_on)
            
%             obj.clear_waveforms();
%             
%             %channels 1 and 2 always used
%             obj.create_waveform('null',NullShape,NullShape,NullShape);
%             obj.setSourceWaveForm(1,'null');
%             obj.sequence_null_infloop_beginning(1,'null');
%             
%             
%             obj.setSourceWaveForm(2,'null');
%             obj.sequence_null_infloop_beginning(2,'null');
%             
%             %channels 3 and 4 only used if C, N control
%             if C_is_on
%                 obj.setSourceWaveForm(3,'null');
%                 obj.sequence_null_infloop_beginning(3,'null');
%             end
%             
%             if N_is_on
%                 obj.setSourceWaveForm(4,'null');
%                 obj.sequence_null_infloop_beginning(4,'null');
%             end
%             
%             obj.writeToSocket('SEQUENCE:ELEMENT1:GOTO:STATE 1');
%             obj.writeToSocket('SEQUENCE:ELEMENT1:GOTO:INDEX 2');
%             obj.writeToSocket('SEQUENCE:ELEMENT1:JTAR:TYPE NEXT');
%             
            
        end
        
        
        function [obj] = send_sequence(obj,IShape,AOMShape,MWShape,QShape,SPDShape,CShape,NShape,NullShape,aux,vary_pts,C_is_on,N_is_on,q,k)
%             
%             %Total number of segments is
%             %(q+1)*vary_pts+1
% 
%             % k = mod(rep,max_number_of_reps);
%             % q = floor(rep/max_number_of_reps);
%             % so that q*max_number_of_reps + k = rep;
%             
%             %%%For reps < max_number_of_reps
%             
%             %Channel 1 // ALWAYS NEEDS TO BE CREATED
%             obj.create_waveform(sprintf('CH1-nb%d',aux),IShape,AOMShape,MWShape);
%             obj.setSourceWaveForm(1,sprintf('CH1-nb%d',aux));
%             obj.sequence(k,aux+1+q*(aux-1),1,sprintf('CH1-nb%d',aux));
%             
%             %Channel 2 // ALWAYS NEEDS TO BE CREATED
%             obj.create_waveform(sprintf('CH2-nb%d',aux),QShape,SPDShape,NullShape);
%             obj.setSourceWaveForm(2,sprintf('CH2-nb%d',aux));
%             obj.sequence(k,aux+1+q*(aux-1),2,sprintf('CH2-nb%d',aux));
%             
%             %Channel 3 // ONLY CREATED IF C CONTROL
%             if C_is_on
%                 obj.create_waveform(sprintf('CH3-nb%d',aux),CShape,NullShape,NullShape);
%                 obj.setSourceWaveForm(3,sprintf('CH3-nb%d',aux));
%                 obj.sequence(k,aux+1+q*(aux-1),3,sprintf('CH3-nb%d',aux));
%             end
%             
%             %Channel 4 // ONLY CREATED IF N CONTROL
%             if N_is_on
%                 obj.create_waveform(sprintf('CH4-nb%d',aux),NShape,NullShape,NullShape);
%                 obj.setSourceWaveForm(4,sprintf('CH4-nb%d',aux));
%                 obj.sequence(k,aux+1+q*(aux-1),4,sprintf('CH4-nb%d',aux));
%             end
%             
%             
%             if (aux ~= vary_pts  && q == 0)
%                 obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:STATE 1',aux+1));
%                 obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:INDEX %d',aux+1,aux+2));
%                 obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:JTAR:TYPE NEXT',aux+1));
%             end
%             
%             if q>0
%                 obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:STATE 1',aux+1+q*(aux-1)));
%                 obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:INDEX %d',aux+1+q*(aux-1),aux+2+q*(aux-1)));
%                 obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:JTAR:TYPE NEXT',aux+1+q*(aux-1)));
%                 
%                 for helper=1:1:q
%                     obj.sequence(obj.max_number_of_reps,aux+1+q*(aux-1)+helper,1,sprintf('CH1-nb%d',aux));
%                     obj.sequence(obj.max_number_of_reps,aux+1+q*(aux-1)+helper,2,sprintf('CH2-nb%d',aux));
%                     
%                     if C_is_on
%                         obj.sequence(obj.max_number_of_reps,aux+1+q*(aux-1)+helper,3,sprintf('CH3-nb%d',aux));
%                     end
%                     
%                     if N_is_on
%                         obj.sequence(obj.max_number_of_reps,aux+1+q*(aux-1)+helper,4,sprintf('CH4-nb%d',aux));
%                     end
%                     
%                     if ~(helper == q && aux == vary_pts)
%                         obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:STATE 1',aux+1+q*(aux-1)+helper));
%                         obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:INDEX %d',aux+1+q*(aux-1)+helper,aux+1+q*(aux-1)+helper+1));
%                         obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:JTAR:TYPE NEXT',aux+1+q*(aux-1)+helper));
%                     end
%                     
%                     
%                 end
%                 
%             end
        end
        
        function [obj] = ArbitraryWaveformGeneratorTektronix_simu(obj)
          
          % obj.IPAddress = varargin{1};
           %obj.TCPPort = varargin{2};
          % obj.SocketHandle = tcpip(obj.IPAddress,obj.TCPPort);
               
          % set(obj.SocketHandle,'Timeout',obj.Timeout);
           %set(obj.SocketHandle,'InputBufferSize',obj.InputBufferSize);
           %set(obj.SocketHandle,'OutputBufferSize',obj.OutputBufferSize);
   
        end
        
        function [obj] = init_element_sequence(obj,length)
            
            %obj.writeToSocket(sprintf('SEQUENCE:LENGTH %d;LENGTH %d',0,length));
        end
        
         function [obj] = clear_waveforms(obj)
             
         end
        
        function [obj] = open(obj)
            
          %  try
              %  fopen(obj.SocketHandle);
          %  catch exception
          %      disp('error to open AWG');
          %  end
            
        end
        
        function [obj] = close(obj)
          %  fclose(obj.SocketHandle);
        end
        
        function [obj] = delete(obj)
            %delete(obj.SocketHandle);
        end
        
        function [err] = setAmplitude(obj,channel)
        
            err = 0;
            
             if obj.Amplitude(channel) < obj.MinAmp || obj.Amplitude(channel) > obj.MaxAmp
                uiwait(warndlg({'AWG Amplitude out of range. Aborted.'}));
                err = 1;
                return;
             end
            
             Amp_Volt = dBm2Volt(obj.Amplitude(channel));
            
            % send the set amplitude command
           % obj.writeToSocket(sprintf('SOUR%d:VOLT %f',channel,Amp_Volt));
            
            % notify of the state change
            notify(obj,'AWGChangedState');
           
        end
        
        function [obj] = SetExtRefClock(obj)
           
             % Reference clock coming from MW Signal Generator
             obj.writeToSocket(sprintf('SOUR1:ROSC:SOUR EXT'));
            
        end
        
        function [err] = SetSampleRate(obj)
            err= 0;
            if obj.SampleRate < obj.MinSampleRate || obj.SampleRate > obj.MaxSampleRate
                uiwait(warndlg({'AWG Sample Rate out of range. Aborted.'}));
                err = 1;
                return;
            end
            obj.writeToSocket(sprintf('SOUR1:FREQ %f', obj.SampleRate));
        end
        
        function [obj] = SetExtTrigger(obj)
           
            % obj.writeToSocket(sprintf('AWGC:RMOD TRIG'));
             %obj.writeToSocket(sprintf(':TRIG:SEQ:SOUR EXT'));
             % obj.writeToSocket(sprintf(':TRIG:SOUR EXT'));
             
            % notify of the state change
            notify(obj,'AWGChangedState');
            
        end
        
        function [obj] = setSourceWaveForm(obj,channel,WaveName)
           % obj.writeToSocket(sprintf('SOURCE%d:WAV "%s"',channel,WaveName));
        end
        
        
        function [obj] = create_waveform(obj,name,shape,marker1,marker2)
                
                %Expects column vectors for shape,marker1,marker2
                
                %Delete the old wavefrom if it was there
                obj.writeToSocket(sprintf('WLISt:WAV:DEL "%s"',name));
                %Create the new waveform
                
                % using format INT, apparently no need to use REAL
                %line below was working, using INT
                %obj.writeToSocket(sprintf('WLISt:WAV:NEW "%s", %d, INT',name,length(shape)));
                obj.writeToSocket(sprintf('WLISt:WAV:NEW "%s", %d, REAL',name,length(shape)));
                
                %Load the actual waveform                               
%                binblockwrite(obj.SocketHandle,obj.shapeToAWGInt(shape,marker1,marker2),'uint16',sprintf('WLISt:WAVeform:DATA "%s", ',name));
                
                % need to send LF to finish bbw
                obj.writeToSocket('');
        end
        
         
        function [obj] = SetChannelOn(obj,channel)
            
          obj.writeToSocket(sprintf('OUTP%d ON',uint32(channel)));
             notify(obj,'AWGChangedState');
            
        end
        
        function [obj] = SetChannelOff(obj,channel)
          obj.writeToSocket(sprintf('OUTP%d OFF',uint32(channel)));
             notify(obj,'AWGChangedState');
            
        end
        
        function [obj] = AWGStart(obj)
           obj.writeToSocket('AWGC:RUN');
             notify(obj,'AWGChangedState');
            
        end
        
        function [obj] = AWGStop(obj)
           obj.writeToSocket('AWGC:STOP');
             notify(obj,'AWGChangedState');
            
        end
        
       
        function [obj] = armSweep(obj)
            obj.writeToSocket(':INIT:IMM:ALL');
             notify(obj,'AWGChangedState');
            
        end

        
      
        
        
        
        
         
        
        
      
        
       
        

         
        function [obj] = reset(obj)
            obj.writeToSocket('*RST');
        end
        
        function writeToSocket(obj,string)
            
            % check if the socket is already open
           % if (strcmp(obj.SocketHandle.Status,'closed'))
                % open a socket connection
             %   fopen(obj.SocketHandle);
            %    CloseOnDone = 1;
           % else
            %    CloseOnDone = 0;
           % end
            
            % send the set frequency command
           % fprintf(obj.SocketHandle,string);
            
           % if CloseOnDone,
                % close the socket
             %   fclose(obj.SocketHandle);
           % end
            
        end
        
        function [output] = writeReadToSocket(obj,string)
            
            % check if the socket is already open
           % if (strcmp(obj.SocketHandle.Status,'closed'))
                % open a socket connection
               % fopen(obj.SocketHandle);
               % CloseOnDone = 1;
           % else
            %    CloseOnDone = 0;
          %  end

            
            % send the set frequency command
           % fprintf(obj.SocketHandle,string)
            
           % output = fscanf(obj.SocketHandle);
            output = 1;
          %  if CloseOnDone
                % close the socket
             %   fclose(obj.SocketHandle);
           % end
        end
        
        
        
        function [] = Set(obj)
            
            %obj.open();
            obj.reset();
            
            obj.SetExtRefClock();
            obj.SetSampleRate();
            obj.SetExtTrigger();
            %obj.close();
           
        end
        
       
  function [] = SetChannel(obj,handles,channel)
      
      %probably wrong
      
      obj.open();
      
      
      obj.Amplitude(channel) = ParseInput(get(handles.edit_AmplitudeMW,'String')); 
      obj.setAmplitude(channel);


   obj.Frequency = ParseInput(get(handles.edit_FixedFreqMW,'String')); 
   obj.setFrequency();
     

    obj.close();
      
  end
  
% Methods not used %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    function [obj] = getAmplitude(obj,channel)
            s = obj.writeReadToSocket(sprintf('SOUR%d:VOLT?',channel));
            obj.Amplitude(channel) = str2num(s);
            
    end
  
    function setmarker(obj,channelnum,markernum,low,high)
          
      obj.writeToSocket(sprintf('SOUR%d:MARK%d:VOLT:LOW %d;HIGH %d',channelnum,markernum,low,high));
           
    end

            
    end
    
     methods(Static)
        
        function binData = shapeToAWGInt(shape,marker1,marker2)
                
            %Check pulse-in to make sure it is between -1 and 1
            if(max(abs(shape)) > 1)
                errordlg('Pulse is outside the range [-1, 1].');
                binData = 0;
                return;
            end
            
            % Convert decimal shape on [-1,1] to binary on [0,2^14 (16383)] 
            binData = uint16( 8191.5*shape + 8191.5 );

            % Set markers - bits 14 and 15 of each point
            binData = bitset(binData,15,marker1);
            binData = bitset(binData,16,marker2);
            
            % TEK AWG5014B requires the binary block data in little endian
            % (LSB first) byte ordering, but binblockwrite seems to ignore 
            % the byte ordering so manually swap it
            binData = swapbytes(binData);            
            
        end            
        
        end %Static methods
   
        events
       AWGChangedState
        end
end
