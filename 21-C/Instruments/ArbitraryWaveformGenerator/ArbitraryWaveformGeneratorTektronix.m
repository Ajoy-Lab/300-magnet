classdef ArbitraryWaveformGeneratorTektronix < handle
    
    properties
        
        SocketHandle  % handle associated with Protocol class
        IPAddress     % Device IP Address for TCP/IP control
        TCPPort       % Port for TCP/IP control
        Timeout       % TimeoutTime
        InputBufferSize 
        OutputBufferSize
        SampleRate
        
        Frequency     % in Hz; array of 4, 1 per channel output
        Amplitude     % in dBm; array of 4, 1 per channel output
        
        MinFreq       %Hz
        MaxFreq       %Hz
        MinAmp        %dBm
        MaxAmp        %dBm
        
        MinSampleRate %Samples per second
        MaxSampleRate %Samples per second
        
        %max_seq_length = 8000; % In sequence mode, seq has at most 8000 segments; currently not used
        max_number_of_reps  %max number of repetition loops per sequence segment
        
    end
    
    methods
        
        %%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [obj] = ArbitraryWaveformGeneratorTektronix(IPAddress,TCPPort,Timeout,InputBufferSize,OutputBufferSize)
            
            obj.IPAddress = IPAddress;
            obj.TCPPort = TCPPort;
            obj.SocketHandle = tcpip(obj.IPAddress,obj.TCPPort);
            
            set(obj.SocketHandle,'Timeout',Timeout);
            set(obj.SocketHandle,'InputBufferSize',InputBufferSize);
            set(obj.SocketHandle,'OutputBufferSize',OutputBufferSize);
            
        end
        
        function open(obj)
            
            try
                fopen(obj.SocketHandle);
            catch exception
                disp('error to open AWG');
            end
            
        end
        
        function close(obj)
            try
                fclose(obj.SocketHandle);
            catch exception
                disp('error to close AWG');
            end
        end
        
        function reset(obj)
            obj.writeToSocket('*RST');
        end
        
        function delete(obj)
            try
                delete(obj.SocketHandle);
            catch exception
                disp('error to delete AWG');
            end
        end
        
%         function writeToSocket(obj,string)
%             
%             % check if the socket is already open
%             if (strcmp(obj.SocketHandle.Status,'closed'))
%                 % open a socket connection
%                 try
%                     fopen(obj.SocketHandle);
%                     CloseOnDone = 1;
%                 catch exception
%                     disp('error to open AWG');
%                 end
%             else
%                 CloseOnDone = 0;
%             end
%             
%             % send the set frequency command
%             fprintf(obj.SocketHandle,string);
%             
%             if CloseOnDone,
%                 % close the socket
%                 try
%                     fclose(obj.SocketHandle);
%                 catch exception
%                     disp('error to close AWG');
%                 end
%             end
%             
%         end

 function writeToSocket(obj,string)
            % check if the socket is already open
            CloseOnDone=0;
            
            % open the socket if it is closed
            if (strcmp(obj.SocketHandle.Status,'closed'))
                obj.open();
            end
            
            % send the string command to execute
            if (strcmp(obj.SocketHandle.Status,'open'))
                fprintf(obj.SocketHandle,string);
            end
            
            % close the socket if it was initially closed
            if CloseOnDone
                obj.close();
            end
            
end
        
        function [output] = writeReadToSocket(obj,string)
            
            % check if the socket is already open
            if (strcmp(obj.SocketHandle.Status,'closed'))
                % open a socket connection
                try
                    fopen(obj.SocketHandle);
                    CloseOnDone = 1;
                catch exception
                    disp('error to open AWG')
                end
            else
                CloseOnDone = 0;
            end
            
            
            % send the set frequency command
            fprintf(obj.SocketHandle,string)
            
            output = fscanf(obj.SocketHandle);
            
            if CloseOnDone
                % close the socket
                try
                    fclose(obj.SocketHandle);
                catch exception
                    disp('error to close AWG');
                end
            end
        end
        
        function AWGStart(obj)
            obj.writeToSocket('AWGC:RUN:IMM');
            
        end
        
        function AWGStop(obj)
            obj.writeToSocket('AWGC:STOP');
            
        end
        
        function Set(obj)
            
            
            obj.reset();
            obj.SetExtRefClock();
            obj.SetSampleRate();
            
        end
        
        function SetExtRefClock(obj)
            
            % Reference clock coming from MW Signal Generator
            obj.writeToSocket(sprintf('SOUR1:ROSC:SOUR EXT'));
            
        end
        
        function [err] = SetSampleRate(obj)
            
            err = 0;
            
            if obj.SampleRate < obj.MinSampleRate || obj.SampleRate > obj.MaxSampleRate
                uiwait(warndlg({'AWG Sample Rate out of range. Aborted.'}));
                err = 1;
                return;
            end
            
            obj.writeToSocket(sprintf('SOUR1:FREQ %f', obj.SampleRate));
            
        end
        
        %%%%% Channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function SetChannelOn(obj,channel)
            
            obj.writeToSocket(sprintf('OUTP%d ON',uint32(channel)));
            
        end
        
        function SetAllChannelsOn(obj)
            
            obj.writeToSocket('OUTP1 ON; OUTP2 ON; OUTP3 ON; OUTP4 ON');
            
        end
        
        function SetAllChannelsOff(obj)
            
            obj.writeToSocket('OUTP1 OFF; OUTP2 OFF; OUTP3 OFF; OUTP4 OFF');
            
        end
        
        function SetChannelOff(obj,channel)
            obj.writeToSocket(sprintf('OUTP%d OFF',uint32(channel)));
            
        end
        
        function setmarker(obj,channelnum,markernum,low,high)
            
            obj.writeToSocket(sprintf('SOUR%d:MARK%d:VOLT:LOW %d;HIGH %d',channelnum,markernum,low,high));
            
        end
        
        %%%%% Waveforms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function create_waveform(obj,name,shape,marker1,marker2)
            
            %Expects column vectors for shape,marker1,marker2
            
            %Delete the old wavefrom if it was there
            obj.writeToSocket(sprintf('WLISt:WAV:DEL "%s"',name));
            %Create the new waveform
            
            % using format INT, apparently no need to use REAL
            obj.writeToSocket(sprintf('WLISt:WAV:NEW "%s", %d, INT',name,length(shape)));
            
            %Load the actual waveform
            binblockwrite(obj.SocketHandle,obj.shapeToAWGInt(shape,marker1,marker2),'uint16',sprintf('WLISt:WAVeform:DATA "%s", ',name));
            
            % need to send LF to finish bbw
            obj.writeToSocket('');
        end
        
        function create_null(obj,NullShape,C_is_on,N_is_on)
            
            obj.clear_waveforms();
            
            %channels 1 and 2 always used
            obj.create_waveform('null',NullShape,NullShape,NullShape);
            obj.setSourceWaveForm(1,'null');
            obj.sequence_null_infloop_beginning(1,'null');
            
            
            obj.setSourceWaveForm(2,'null');
            obj.sequence_null_infloop_beginning(2,'null');
            
            %channels 3 and 4 only used if C, N control
            if C_is_on
                obj.setSourceWaveForm(3,'null');
                obj.sequence_null_infloop_beginning(3,'null');
            end
            
            if N_is_on
                obj.setSourceWaveForm(4,'null');
                obj.sequence_null_infloop_beginning(4,'null');
            end
            
            obj.writeToSocket('SEQUENCE:ELEMENT1:GOTO:STATE 1');
            obj.writeToSocket('SEQUENCE:ELEMENT1:GOTO:INDEX 2');
            obj.writeToSocket('SEQUENCE:ELEMENT1:JTAR:TYPE NEXT');
            
            
        end
        
        % currently not used
        function setWaveFormPhase(obj,channel,angle)
            obj.writeToSocket(sprintf('SOURCE%d:PHASE %d',channel,angle));
            %angle in degrees
        end
        
        function [err] = setAmplitude(obj,channel)
            
            err = 0;
            
            if obj.Amplitude(channel) < obj.MinAmp || obj.Amplitude(channel) > obj.MaxAmp
                uiwait(warndlg({'AWG Amplitude out of range. Aborted.'}));
                err = 1;
                return;
            end
            
            Amp_Volt = dBm2Voltpp(obj.Amplitude(channel));
            
            % send the set amplitude command
            %Masashi commented 2013 July 21
            if channel==5;
                channel=channel-1;
            end
            if channel==4;
                channel=channel-1;
            end
            %%%%%%%
            obj.writeToSocket(sprintf('SOUR%d:VOLT %f',channel,Amp_Volt));
            
        end
        
        function setSourceWaveForm(obj,channel,WaveName)
            obj.writeToSocket(sprintf('SOURCE%d:WAV "%s"',channel,WaveName));
        end
        
        function clear_waveforms(obj)
            
            obj.writeToSocket('SOUR1:WAV ""');
            obj.writeToSocket('SOUR2:WAV ""');
            obj.writeToSocket('SOUR3:WAV ""');
            obj.writeToSocket('SOUR4:WAV ""');
            obj.writeToSocket('WLIS:WAV:DEL');
            
            
        end
        
        %%%%% Sequencing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function init_element_sequence(obj,length)
            
            obj.writeToSocket(sprintf('SEQUENCE:LENGTH %d;LENGTH %d',0,length));
        end
        
        function sequence(obj,rep, segnum, channel, WaveName)
            
            obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:WAVEFORM%d "%s"',segnum,channel,WaveName));
            obj.writeToSocket(sprintf('SEQ:ELEM%d:LOOP:COUN %d',segnum,rep));
            
        end
        
        function sequence_null_infloop_beginning(obj,channel, WaveNull)
            
            obj.writeToSocket(sprintf('SEQUENCE:ELEMENT1:WAVEFORM%d "%s"',channel,WaveNull));
            obj.writeToSocket('SEQ:ELEM1:LOOP:INF 1');
            
            
        end
        
        function force_event(obj)
            obj.writeToSocket('EVENT:IMMEDIATE');
        end
        
        function send_sequence(obj,IShape,AOMShape,MWShape,QShape,SPDShape,CShape,NShape,NullShape,aux,vary_pts,C_is_on,N_is_on,q,k)
            
            %Total number of segments is
            %(q+1)*vary_pts+1

            % k = mod(rep,max_number_of_reps);
            % q = floor(rep/max_number_of_reps);
            % so that q*max_number_of_reps + k = rep;
            
            %%%For reps < max_number_of_reps
            
            %Channel 1 // ALWAYS NEEDS TO BE CREATED
            obj.create_waveform(sprintf('CH1-nb%d',aux),IShape,AOMShape,MWShape);
            obj.setSourceWaveForm(1,sprintf('CH1-nb%d',aux));
            obj.sequence(k,aux+1+q*(aux-1),1,sprintf('CH1-nb%d',aux));
            
            %Channel 2 // ALWAYS NEEDS TO BE CREATED
            obj.create_waveform(sprintf('CH2-nb%d',aux),QShape,SPDShape,NullShape);
            obj.setSourceWaveForm(2,sprintf('CH2-nb%d',aux));
            obj.sequence(k,aux+1+q*(aux-1),2,sprintf('CH2-nb%d',aux));
            
            %Channel 3 // ONLY CREATED IF C CONTROL
            if C_is_on
                obj.create_waveform(sprintf('CH3-nb%d',aux),CShape,NullShape,NullShape);
                obj.setSourceWaveForm(3,sprintf('CH3-nb%d',aux));
                obj.sequence(k,aux+1+q*(aux-1),3,sprintf('CH3-nb%d',aux));
            end
            
            %Channel 4 // ONLY CREATED IF N CONTROL
            if N_is_on
                obj.create_waveform(sprintf('CH4-nb%d',aux),NShape,NullShape,NullShape);
                obj.setSourceWaveForm(4,sprintf('CH4-nb%d',aux));
                obj.sequence(k,aux+1+q*(aux-1),4,sprintf('CH4-nb%d',aux));
            end
            
            
            if (aux ~= vary_pts  && q == 0)
                obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:STATE 1',aux+1));
                obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:INDEX %d',aux+1,aux+2));
                obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:JTAR:TYPE NEXT',aux+1));
            end
            
            if q>0
                obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:STATE 1',aux+1+q*(aux-1)));
                obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:INDEX %d',aux+1+q*(aux-1),aux+2+q*(aux-1)));
                obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:JTAR:TYPE NEXT',aux+1+q*(aux-1)));
                
                for helper=1:1:q
                    obj.sequence(obj.max_number_of_reps,aux+1+q*(aux-1)+helper,1,sprintf('CH1-nb%d',aux));
                    obj.sequence(obj.max_number_of_reps,aux+1+q*(aux-1)+helper,2,sprintf('CH2-nb%d',aux));
                    
                    if C_is_on
                        obj.sequence(obj.max_number_of_reps,aux+1+q*(aux-1)+helper,3,sprintf('CH3-nb%d',aux));
                    end
                    
                    if N_is_on
                        obj.sequence(obj.max_number_of_reps,aux+1+q*(aux-1)+helper,4,sprintf('CH4-nb%d',aux));
                    end
                    
                    if ~(helper == q && aux == vary_pts)
                        obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:STATE 1',aux+1+q*(aux-1)+helper));
                        obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:GOTO:INDEX %d',aux+1+q*(aux-1)+helper,aux+1+q*(aux-1)+helper+1));
                        obj.writeToSocket(sprintf('SEQUENCE:ELEMENT%d:JTAR:TYPE NEXT',aux+1+q*(aux-1)+helper));
                    end
                    
                    
                end
                
            end
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
    
end
