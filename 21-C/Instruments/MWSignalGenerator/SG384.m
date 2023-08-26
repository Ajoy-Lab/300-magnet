classdef SG384 < handle   
    properties        
        SocketHandle             % handle associated with Protocol class [tcpip()]
        IPAddress                % Device IP Address for TCP/IP control
        TCPPort                  % Port for TCP/IP control
        Timeout                  % Timeout time in s
        InputBufferSize 
        OutputBufferSize 

        Frequency=3e9;
        Amplitude=-33; 
        MinFreq=950e3 %Hz for N-type Output (p.8 Operation Manual SRS)
        MaxFreq=4.05e9 %Hz for N-type Output (p.8 Operation Manual SRS)
        MinAmp=-110 %dBm for N-type Output (p.22 Operation Manual SRS)
        MaxAmp=+13 %dBm for N-type Outpur (p.22 Operation Manual SRS)
    end
    
    methods      
        function [obj] = SG384(IPAddress,TCPPort,Timeout,InputBufferSize,OutputBufferSize)        
            obj.IPAddress = IPAddress;
            obj.TCPPort = TCPPort;
            obj.Timeout=Timeout;
            obj.InputBufferSize=InputBufferSize;
            obj.OutputBufferSize=OutputBufferSize;
            obj.init();
        end
        
        function init(obj)
            try
                % TCP/IP Protocol MATLAB
                %delete(obj.SocketHandle);
                %clear obj.SocketHandle
                %echotcpip('on',obj.TCPPort);
                obj.SocketHandle = tcpip(obj.IPAddress,obj.TCPPort);
                set(obj.SocketHandle,'Timeout',obj.Timeout);
                set(obj.SocketHandle,'InputBufferSize',obj.InputBufferSize);
                set(obj.SocketHandle,'OutputBufferSize',obj.OutputBufferSize);
                disp('TCP/IP Protocol Initialized');
            catch exception
                disp('Error to init TCP/IP Protocol');
            end
        end
        
        % Open connection to the socket
        function [err]=open(obj)            
            try
                err = 0;
                fopen(obj.SocketHandle);
                obj.reset();
                disp('TCP/IP connection to SG opened.');                
            catch exception
                disp('Error to open TCP/IP connection to SG. Make sure the SG is switched on. Try again after few minutes.');
                err=1;
            end
        end
        
        % Close connection to the socket
        function close(obj)
            try
                fclose(obj.SocketHandle);
                echotcpip('off');
                disp('SG connection closed');
                %delete(obj.SocketHandle);
                %clear obj.SocketHandle;
            catch exception
                disp('Error to close SG');
            end
        end
        
        % Reset properties of the SG
        function reset(obj)
            try
                obj.writeToSocket('*rst\n');
                disp('SG reset');
            catch exception
                disp('Error to reset SG');
            end
        end
        
        % Write a string to the socket
        function writeToSocket(obj,string)
            CloseOnDone = 0;

            % open the socket if it is closed
            if (strcmp(obj.SocketHandle.Status,'closed'))
                obj.open();      % open a socket connection
                %CloseOnDone = 1; % close open executing the function                
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

        % Write a string to the socket and read the buffer
        function [output] = writeReadToSocket(obj,string)
            CloseOnDone = 0;
            
            % open the socket if it is closed
            if (strcmp(obj.SocketHandle.Status,'closed'))
                obj.open();      % open a socket connection
                CloseOnDone = 1; % close open executing the function                
            end
            
            % send the string command to execute
            fprintf(obj.SocketHandle,string)            
            output = fscanf(obj.SocketHandle);
            
            % close the socket if it was initially closed
            if CloseOnDone
                obj.close();
            end
         
        end
        
        % Set the Frequency of the N-type output
        function [err] = setFrequency(obj)
            
            err = 0;
            
            if obj.Frequency < obj.MinFreq || obj.Frequency > obj.MaxFreq
                uiwait(warndlg({'Frequency out of range. Execution Aborted.'}));
                err = 1;
                return;
            end
                      
            % set the frequency
            try
              obj.writeToSocket(['freq ', num2str(obj.Frequency),'\n']);
              %obj.writeToSocket(['freq ', num2str(obj.Frequency,'%10.6e\n')]);
              % num2str(obj.Frequency,'%10.6e\n')
              %disp('Frequency set');
            catch exception
                disp('error to set Frequency');
            end
            
            
        end
        
        % Set the Amplitude of the N-type output
        function [err] = setAmplitude(obj)
            
            err = 0;
            
            if obj.Amplitude < obj.MinAmp || obj.Amplitude > obj.MaxAmp
                uiwait(warndlg({'Amplitude out of range. Execution Aborted.'}));
                err = 1;
                return;
            end
          
            % set the amplitude
            %obj.writeToSocket(sprintf(':POW:LEV:IMM:AMPL %f DBM',obj.Amplitude));
            try
                obj.writeToSocket(['ampr ', num2str(obj.Amplitude),'\n']);
                %disp('Amplitude set');
            catch exception
                disp('error to set Amplitude');
            end
            
        end
            
        % turn N-type output ON
        function setRFOn(obj)
            try
                obj.writeToSocket('enbr 1\n');
                %disp('RF turned on');
            catch exception
                disp('error to turn on RF');
            end
            
                       
        end
        
        % turn N-type output OFF
        function setRFOff(obj)
            try
                obj.writeToSocket('enbr 0\n')
                %disp('RF turned off');
            catch exception
                disp('error to turn off RF');
            end
        end
        
        % reset device, set amp & freq and turn on RF
        function [err] = SetAll(obj)  
            err = 0;
            %obj.reset();
            errA = obj.setAmplitude();
            errB = obj.setFrequency();            
            if errA || errB      
                err = 1;
            else
            %    obj.setRFOn();    
            end
             
        end
        
    end
    
end