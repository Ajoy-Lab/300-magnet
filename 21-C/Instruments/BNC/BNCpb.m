classdef BNCpb < handle   
    properties        
        
        SocketHandle;
        
        Width=1e-6;
        Amplitude=2; 
        Delay=0;
        MinWidth=10e-9; %Hz for N-type Output (p.8 Operation Manual SRS)
        MaxWidth=1000; %Hz for N-type Output (p.8 Operation Manual SRS)
        MinAmp=1; %dBm for N-type Output (p.22 Operation Manual SRS)
        MaxAmp=20; %dBm for N-type Outpur (p.22 Operation Manual SRS)
    end
    
    methods      
        function [obj] = BNCpb()        
            obj.init();
           % obj.stop();
            obj.setPeriod(3e-6);
            obj.setBurst(1);
            obj.setNormalChannel(4);
            obj.setTrigger(0.75);
            obj.setWidth(4,1.5e-6);
            obj.setDelay(4,0);
            obj.setAmplitude(4,5);
            obj.start(); 
        end
        
        function init(obj)
            try
               
                obj.SocketHandle = instrfind('Type', 'serial', 'Port', 'COM18', 'Tag', '');
                
                
                if isempty(obj.SocketHandle)
                    obj.SocketHandle = serial('COM18', 'BaudRate',38400,'Terminator','CR/LF' );
                else
                    fclose(obj.SocketHandle);
                     obj.SocketHandle =  obj.SocketHandle(1);
                end
                fopen(obj.SocketHandle);
                disp('BNC pulse generator initialized'); 

            catch exception
                disp('Error to initialize BNC pulse generator');
            end
        end
        
        % Open connection to the socket
        function [err]=open(obj)            
            try
                err = 0;
                fopen(obj.SocketHandle);
               % obj.reset(); --------- ashok 12/4 UNCOMMENT!
                disp('BNC pulse generator closed.');                
            catch exception
                disp('Error to close BNC');
                err=1;
            end
        end
        
        % Close connection to the socket
        function close(obj)
            try
                fclose(obj.SocketHandle);
                
                disp('BNC pulse generator closed');
                %delete(obj.SocketHandle);
                %clear obj.SocketHandle;
            catch exception
                disp('Error to close BNC');
            end
        end
        
        % Reset properties of the SG
              
        % Set the width
        function [err] = setWidth(obj,channel, width)
            err = 0;
            if width < obj.MinWidth || width > obj.MaxWidth
                uiwait(warndlg({'Width out of range. Execution Aborted.'}));
                err = 1;
                return;
            end
                      
            % set the frequency
            try
            query(obj.SocketHandle, [':PULSE' num2str(channel) ':WIDT ' num2str(width)])
            catch exception
                disp('error to set Width');
            end
        end
        
           % Set the delay
        function [err] = setDelay(obj,channel, delay)
            err = 0;
            
                     
            % set the frequency
            try
            query(obj.SocketHandle, [':PULSE' num2str(channel) ':DEL ' num2str(delay)])
            catch exception
                disp('error to set Delay');
            end
        end
        
             % Set the channel on
        function [err] = setStateON(obj,channel)
            err = 0;
            
                     
            % set the frequency
            try
            query(obj.SocketHandle, [':PULSE' num2str(channel) ':STATE ON'])
            catch exception
                disp('error to set Delay');
            end
        end
        
              % Set the channel off
        function [err] = setStateOFF(obj,channel)
            err = 0;
            
                     
            % set the frequency
            try
            query(obj.SocketHandle, [':PULSE' num2str(channel) ':STATE OFF'])
            catch exception
                disp('error to set Delay');
            end
        end
        
        function [err] = setPeriod(obj,period)
            err = 0;
            if period < obj.MinWidth || period  > obj.MaxWidth
                uiwait(warndlg({'Width out of range. Execution Aborted.'}));
                err = 1;
                return;
            end
            
            % set the frequency
            try
                query(obj.SocketHandle, [':PULSE0' ':PER ' num2str(period)])
            catch exception
                disp('error to set Period');
            end
        end
        
         function [err] = setBurst(obj,burst)
            err = 0;
            
            % set the frequency
            try
                query(obj.SocketHandle, [':PULSE0:MODE BURS']);
                query(obj.SocketHandle, [':PULSE0:BCO ' num2str(burst)]);
            catch exception
                disp('error to set Burst');
            end
         end
        
         function [err] = setNormalChannel(obj,channel)
            err = 0;
            
            % set the frequency
            try
                query(obj.SocketHandle, [':PULSE' num2str(channel) ':CMODE NORM']);
            catch exception
                disp('error to set Burst');
            end
        end
        
        
        function [err] = setAmplitude(obj,channel, amp)
            err = 0;
            if amp < obj.MinAmp || amp  > obj.MaxAmp
                uiwait(warndlg({'Amplitude out of range. Execution Aborted.'}));
                err = 1;
                return;
            end
            
            % set the frequency
            try
                query(obj.SocketHandle, [':PULSE' num2str(channel) ':OUTPUT:MOD ADJ']);
                query(obj.SocketHandle, [':PULSE' num2str(channel) ':OUTPUT:AMPL ' num2str(amp)]);
            catch exception
                disp('error to set Period');
            end
        end
        
         function [err] = setTrigger(obj,level)
            try
                query(obj.SocketHandle, [':PULSE0:TRIG:MODE TRIG']);
                query(obj.SocketHandle, [':PULSE0:TRIG:LEV ' num2str(level)]);
                query(obj.SocketHandle, [':PULSE0:TRIG:EDGE RIS']);
            catch exception
                disp('error to set Period');
            end
        end
        
        function [err] = start(obj)
            
            try
                query(obj.SocketHandle, [':PULSE0' ':STATE ON']);
            catch exception
                disp('error to set Period');
            end
        end
        
        function [err] = stop(obj)
            
            try
                query(obj.SocketHandle, [':PULSE0' ':STATE OFF']);
            catch exception
                disp('error to set Period');
            end
        end
        
        
        % Read the width
        function [output] = readWidth(obj,channel)
       
            % set the frequency
            try
            output= query(obj.SocketHandle, [':PULSE' channel ':WIDT? '])
            catch exception
                disp('error to read Width');
            end
        end
        
        
        
    end
    
end