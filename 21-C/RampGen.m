classdef RampGen
    properties
        gpib_obj
        port
    end
    methods
        function obj=Ramp_Open(obj)
            obj.port = serial('COM5');% Protoype I   
           %obj.port = serial('COM9');  % Protoype II
            %obj.port = serial('COM16');  % Protoype III
%             obj.port = serial('COM8');% New VCOs 5GHz   
            % Set default serial port properties for the ASCII protocol.
            set(obj.port, ...
                'BaudRate', 115200, ...
                'DataBits', 8, ...
                'FlowControl', 'none', ...
                'Parity', 'none', ...
                'StopBits', 1);
            set(obj.port, 'Timeout', 0.5)
            warning off MATLAB:serial:fgetl:unsuccessfulRead
            fopen(obj.port);    
        end
        
        function Set_RampFreq(obj, Freq)
            if Freq<50000
            %Freq=round(4095*Freq/5000);
            Freq=num2str(dec2hex(10*Freq,4));
            end
            command=[dec2hex( todecimal('F')); Freq(1,1:2); Freq(1,3:4)];
            
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8');
        end
        
        function Set_RampSymm(obj, RampSymm)
            if isempty(RampSymm)
            command=['63'; '01'; '00'];
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8'); 
            elseif RampSymm==0
                 command=['63'; '01'; '00'];
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8'); 
            elseif RampSymm==1
                 command=['63'; '00'; '01'];
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8'); 
            elseif RampSymm==2
                 command=['63'; '01'; '01'];
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8');
            pause(2);
            end
        end
        
        function Set_RampTime(obj, SymmTime1, SymmTime2)
            if isempty(SymmTime1)
            command=['63'; '01'; '00'];
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8'); 
            else
            command=['63'; dec2hex(SymmTime1,2); dec2hex(SymmTime2,2)];
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8');  
            end
        end
        
        function Set_RampGain(obj, Ramp_No, RampGain)
            if Ramp_No==1
                Ramp_No=dec2hex( todecimal('G'));
            end
            if Ramp_No==2
                Ramp_No=dec2hex( todecimal('H'));
            end
            if Ramp_No==3
                Ramp_No=dec2hex( todecimal('J'));
            end
            if Ramp_No==4
                Ramp_No=dec2hex( todecimal('K'));
            end
            if RampGain<=20 && RampGain>=0
            RampGain=round(4095*RampGain/10);
            RampGain=num2str(dec2hex(RampGain,4));
            end
            command=[Ramp_No; RampGain(1,1:2); RampGain(1,3:4)];
            
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8');            
            
        end
        
        function Set_RampOffset(obj, Ramp_No, RampOffset)
            if Ramp_No==1
                Ramp_No=dec2hex( todecimal('O'));
            end
            if Ramp_No==2
                Ramp_No=dec2hex( todecimal('P'));
            end
            if Ramp_No==3
                Ramp_No=dec2hex( todecimal('Q'));
            end
            if Ramp_No==4
                Ramp_No=dec2hex( todecimal('R'));
            end
            if RampOffset<20 && RampOffset>=0
            RampOffset=round(4095*RampOffset/20);
            RampOffset=num2str(dec2hex(RampOffset,4));
            end
            command=[Ramp_No; RampOffset(1,1:2); RampOffset(1,3:4)];
            
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8');            
            
        end
        
        function Start_RampGen(obj)
            command=[dec2hex( todecimal('S')); '01'; '00'];
            
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8');
            
%              command=['63'; '01'; '00'];
%             %Convert to decimal format
%             txdata_dec = hex2dec(command);
%             %Write using the UINT8 data format
%             fwrite(obj.port,txdata_dec,'uint8'); 
        end
        
        function Stop_RampGen(obj)
            command=[dec2hex( todecimal('S')); '00'; '00'];
            
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8');
        end
        
        %% Unsure
        function Set_RampPhase(obj, Ramp_No, RampPhase)
            
            if Ramp_No==2
                Ramp_No=dec2hex( todecimal('B'));
            end
            if Ramp_No==3
                Ramp_No=dec2hex( todecimal('C'));
            end
            if Ramp_No==4
                Ramp_No=dec2hex( todecimal('D'));
            end
            if RampPhase<360 &&  RampPhase>=0
            RampPhase=round(4095*RampPhase/360);
            RampPhase=num2str(dec2hex(RampPhase,4));
            end
            command=[Ramp_No; RampPhase(1,1:2); RampPhase(1,3:4)];
            
            %Convert to decimal format
            txdata_dec = hex2dec(command);
            %Write using the UINT8 data format
            fwrite(obj.port,txdata_dec,'uint8');            
            
        end
        
        function Set_RampVppVdc(obj, Ramp_No, Vpp, Vdc)

           obj.Set_RampOffset(Ramp_No, Vdc-Vpp/2);
           pause(0.1);
           obj.Set_RampGain(Ramp_No, Vpp);
        end
        
    end
end