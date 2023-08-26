classdef SignalGeneratorAgilent < handle
    
    
    properties
        
        SocketHandle  % handle associated with Protocol class
        IPAddress     % Device IP Address for TCP/IP control
        TCPPort       % Port for TCP/IP control
        Timeout       % TimeoutTime in s
        InputBufferSize 
        OutputBufferSize 
        
        Frequency
        Amplitude 
        MinFreq %Hz
        MaxFreq %Hz
        MinAmp %dBm
        MaxAmp %dBm
        
    end
    
    methods
        
        function [obj] = SignalGeneratorAgilent(IPAddress,TCPPort,Timeout,InputBufferSize,OutputBufferSize)
            
            
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
                disp('error to open SG');
            end
        end
        
        function close(obj)
            try
                fclose(obj.SocketHandle);
            catch exception
                disp('error to close SG');
            end
        end
        
        function [err] = setAmplitude(obj)
            
            err = 0;
            
            if obj.Amplitude < obj.MinAmp || obj.Amplitude > obj.MaxAmp
                uiwait(warndlg({'Amplitude out of range. Aborted.'}));
                err = 1;
                return;
            end
            
            % send the set amplitude command
            obj.writeToSocket(sprintf(':POW:LEV:IMM:AMPL %f DBM',obj.Amplitude));
            
        end
        
        function [err] = setFrequency(obj)
            
            err = 0;
            
            if obj.Frequency < obj.MinFreq || obj.Frequency > obj.MaxFreq
                uiwait(warndlg({'Frequency out of range. Aborted.'}));
                err = 1;
                return;
            end
            
            % send the set frequency command
            obj.writeToSocket(sprintf(':FREQ %f',obj.Frequency));
            
        end
        
        function reset(obj)
            obj.writeToSocket('*RST');
        end
        
        function setRFOn(obj)
            
            obj.writeToSocket(sprintf(':OUTP ON'));
            
        end
        
        function setRFOff(obj)
            
            obj.writeToSocket(sprintf(':OUTP OFF'));
            
        end
        
        function writeToSocket(obj,string)
            
            % check if the socket is already open
            if (strcmp(obj.SocketHandle.Status,'closed'))
                % open a socket connection
                try
                    fopen(obj.SocketHandle);
                catch exception
                    disp('error to open SG');
                end
                CloseOnDone = 1;
            else
                CloseOnDone = 0;
            end
            
            % send the set frequency command
            fprintf(obj.SocketHandle,string);
            
            if CloseOnDone,
                % close the socket
                try
                    fclose(obj.SocketHandle);
                catch exception
                    disp('error to close SG');
                end
            end
            
        end
        
        function [output] = writeReadToSocket(obj,string)
            
            % check if the socket is already open
            if (strcmp(obj.SocketHandle.Status,'closed'))
                % open a socket connection
                fopen(obj.SocketHandle);
                CloseOnDone = 1;
            else
                CloseOnDone = 0;
            end
            
            
            % send the set frequency command
            fprintf(obj.SocketHandle,string)
            
            output = fscanf(obj.SocketHandle);
            
            if CloseOnDone
                % close the socket
                fclose(obj.SocketHandle);
            end
        end
        
        function [err] = SetAll(obj,~)
            
            err = 0;
            
            obj.reset();
            
            errA = obj.setAmplitude();
            errB = obj.setFrequency();
            
            if errA || errB
            
                err = 1;
                return;
                
            end
            
            obj.setRFOn();
            
        end
        
    end
    
end