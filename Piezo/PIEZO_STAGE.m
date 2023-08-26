classdef PIEZO_STAGE < handle
    
    properties
        ID                      % name
        pause_Time   = 5e-2     % internal waiting time of the Piezo
        Serial_Port  = 'COM3'    % Serial port where the USB is attached
        SampleRate = 1/24e-6       % Sample rate of the Piezo in Hz
        Piezo
%         handles.ImagingFunctions.interfaceScanning = PiezoMadCityLabs(LibraryName,LibraryFilePath,HeaderFilePath,ADCtime,DAQtime);
%     handles.ImagingFunctions.interfaceScanning.ADCtime = ADCtime;
%     handles.ImagingFunctions.interfaceScanning.DAQtime = DAQtime;
    HighEndOfRange = [200 200 200]; %in mum
    LowEndOfRange = [0 0 0]; %in mum
    StabilizeTime=0.05; %sec
    nFlat = 100;           
    nOverRun = 75;      
    LagPts = 5; % PC
    precision = [0.0001,0.0001,0.0001]; %in mum
    end
  
    methods
        
        function [obj] = PIEZO_STAGE()
            % instantiation function
            %obj.pause_Time = pause_Time;
            %obj.Serial_Port = Serial_Port;
            obj.Piezo= serial(obj.Serial_Port);
            USBTime=1e0; %factor
            obj.Piezo.BaudRate = 115200*USBTime;
            obj.Piezo.InputBufferSize = 4096;
        end
        
        function p = Pos(obj,axis)
            %query and return position of axis (x=1, y=2, z=3)
            %p = calllib(obj.LibraryName,'MCL_SingleReadN',axis,obj.ID);
            
            p= READ_axis(obj,axis);
            %disp(['The position of the stage at ',num2str(axis),' axis is ',num2str(p),' :']);
%             if p < 0
%                 obj.TranslateError(p);
%             end
            
        end
        
        function READ_axis_out = READ_axis(obj,axis)
            %
            % Offset= 0x218
            % DataType= 32 Bit Integer
            %
            % The A0 command reads one 32 bit value from the specified address. In this sample the
            % address used is 0x11831218 and the return data value is 0x64, or 100 in decimal. The
            % address and data bytes are both 32 bit values, and are transmitted with significance increasing
            % (LSB transmitted first and MSB transmitted last).
            %
            % zero=218
            % query and return position of axis
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            address_n=strcat('1183',num2str(axis),'334');
            %address_n=strcat('1183',num2str(axis),'218');
            
            cmdstr_n=strcat('A0',address_n,'55');
            cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 11 12]);
            l_n = length(cmdstr_n);
            c_n = hex2dec(reshape(cmdstr_n,2,l_n/2)');
            fwrite(obj.Piezo,c_n);
            pause(obj.pause_Time);  %%%%%%%%%%%%%%%%%% PAUSE
            numBytes = obj.Piezo.BytesAvailable;
            ret_str_n = fread(obj.Piezo,numBytes);
            pause(obj.pause_Time);  %%%%%%%%%%%%%%%%%% PAUSE
            [m_n,n_n] = size(address_n);
            k_n = reshape(ret_str_n,10,m_n);
            s_n = k_n(:,1);
            s_n = dec2hex(s_n);
            s_n = reshape(s_n',1,20);
            s_n = s_n(11:18);
            s_n=s_n([7 8 5 6 3 4 1 2]);
            % we need to scale out the value and take in consideration the
            % negative values
            
            out=hex2dec(s_n);
            if (out > 2^31) %negative HEX
                out =- (2^32 - out);
             end
             if (axis==3) READ_axis_out=(out/1048574*20)+10; % value rescaled for Z-axis
              else READ_axis_out=(out/1048574*100)+50;        % value rescaled for X & Y axis
             
             end
             
            return
        end
        
        function MOVE_axis(obj,Move_n,axis)
            %
            % Offset= 0x208
            % DataType= 32 Bit Integer
            %
            % The A2 command writes one 32 bit value to the specified address. In this sample the address
            % used is 0x11831218 and the data value written is 0x3E8, or 1000 in decimal. The
            % address and data are 32 bit values. Bytes are transmitted with significance increasing
            % (LSB transmitted first and MSB transmitted last).
            %
            % micron  - Range X [-50,50] Microns
            % micron  - Range Y [-50,50] Microns
            % micron  - Range Z [-10,10] Microns
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            Flag_Error=0;
            switch(axis)
                case {1,2} 
                    Move_n=Move_n-50;
                    if ((Move_n<=50)&&(Move_n>=-50)) Move_n= round(Move_n*1048574/100);
                    else warning('What the HELL do you think you are doing mate? You are exceeding the axis!');
                         Flag_Error=1;
                    end
                case 3 
                    Move_n=Move_n-10;
                    if ((Move_n<=10)&&(Move_n>=-10)) Move_n= round(Move_n*1048574/20);
                    else warning('What the HELL do you think you are doing mate? You are exceeding the axis!');
                         Flag_Error=1;
                    end
                otherwise
                    warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
                    Flag_Error=1;
            end    
            
%             if (axis==3) Move_n= round(Move_n*1048574/20); % value rescaled for Z-axis
%              else Move_n= round(Move_n*1048574/100);        % value rescaled for X & Y axis
%             end
            
            if (Flag_Error==0) % in order to assure that we do not move in case of error 
            %in order to write negative HEX in matlab 32 bit
            if Move_n < 0
            Move_n = (2^32 + Move_n);
            end
                        
            address_n=strcat('1183',num2str(axis),'218');
            Write_n=num2str(dec2hex(Move_n,8));
            cmdstr_n=strcat('A2',address_n,Write_n,'55');
            % -- reorder the bytes --
            cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_n = length(cmdstr_n);
            c_n = hex2dec(reshape(cmdstr_n,2,L_n/2)');
            fwrite(obj.Piezo,c_n);
            end
            %pause(obj.pause_Time);   %%%%%%%%%%%%%%%%%%%%%%% PAUSE
        end
        
        function CONNECTED_axis(obj,axis)
            %
            % Offset= 0x3A0
            % DataType= 32 Bit Integer
            %
            % Channel Boards Connected – Shows how many channels are
            % physically present in the controller. The least significant six bits
            % each represent a channel of the controller, with the least significant
            % representing channel 1, and the third bit representing channel
            % 3. If a channel board is physically present the bit will have a
            % value of zero, if a board is not present it will have a value of 1.
            % For example, if a controller had the first three channels populated
            % with channel boards, the value at this memory address would
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            address_CON=strcat('1183',num2str(axis),'3A0');
            cmdstr_CON=strcat('A0',address_CON,'55');
            cmdstr_CON = cmdstr_CON([1 2 9 10 7 8 5 6 3 4 11 12]);
            l_CON = length(cmdstr_CON);
            c_CON = hex2dec(reshape(cmdstr_CON,2,l_CON/2)');
            fwrite(obj.Piezo,c_CON);
            
            pause(obj.pause_Time);
            
            numBytes = obj.Piezo.BytesAvailable;
            ret_str_CON = fread(obj.Piezo,numBytes);
            
            pause(obj.pause_Time);
            
            [m_CON,n_n] = size(address_CON);
            k_CON = reshape(ret_str_CON,10,m_CON);
            s_CON = k_CON(:,1);
            s_CON = dec2hex(s_CON);
            s_CON = reshape(s_CON',1,20);
            s_CON = s_CON(11:18);
            s_CON=s_CON([7 8 5 6 3 4 1 2]);
            out_CON=hex2dec(s_CON);
            if  (out_CON==0)
                disp([num2str(axis),' is available.'])
            else disp(['What the HELL do you think you are doing mate? You gave the wrong axis number! ',num2str(axis),' is NOT available.'])   
            end
        end
        
        function PROP_GAIN_axis(obj,axis)
            %
            % Offset= 0x720
            % DataType= 64 Bit Float
            %
            % Proportional Gain – Sets the proportional gain of the control loop
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            address_GAIN=strcat('1183',num2str(axis),'720');
            cmdstr_GAIN=strcat('A0',address_GAIN,'55');
            cmdstr_GAIN = cmdstr_GAIN([1 2 9 10 7 8 5 6 3 4 11 12]);
            l_GAIN = length(cmdstr_GAIN);
            c_GAIN = hex2dec(reshape(cmdstr_GAIN,2,l_GAIN/2)');
            fwrite(obj.Piezo,c_GAIN);
            
            pause(obj.pause_Time);
            numBytes = obj.Piezo.BytesAvailable;
            ret_str_GAIN = fread(obj.Piezo,numBytes);
            pause(obj.pause_Time);
            
            [m_GAIN,n_n] = size(address_GAIN);
            k_GAIN = reshape(ret_str_GAIN,10,m_GAIN);
            s_GAIN = k_GAIN(:,1);
            s_GAIN = dec2hex(s_GAIN);
            s_GAIN = reshape(s_GAIN',1,20);
            s_GAIN = s_GAIN(11:18);
            s_GAIN=s_GAIN([7 8 5 6 3 4 1 2]);
            out_GAIN=hex2dec(s_GAIN);
        end
        
        function INTEGRAL_GAIN_axis(obj,axis)
            %
            %Integral Gain – Sets the integral gain of the control loop.
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            address_INTEGRAL=strcat('1183',num2str(axis),'728');
            cmdstr_INTEGRAL=strcat('A0',address_INTEGRAL,'55');
            cmdstr_INTEGRAL = cmdstr_INTEGRAL([1 2 9 10 7 8 5 6 3 4 11 12]);
            l_INTEGRAL = length(cmdstr_INTEGRAL);
            c_INTEGRAL = hex2dec(reshape(cmdstr_INTEGRAL,2,l_INTEGRAL/2)');
            fwrite(obj.Piezo,c_INTEGRAL);
            
            pause(obj.pause_Time);
            numBytes = obj.Piezo.BytesAvailable;
            ret_str_INTEGRAL = fread(obj.Piezo,numBytes);
            pause(obj.pause_Time);
            
            [m_INTEGRAL,n_n] = size(address_INTEGRAL);
            k_INTEGRAL = reshape(ret_str_INTEGRAL,10,m_INTEGRAL);
            s_INTEGRAL = k_INTEGRAL(:,1);
            s_INTEGRAL = dec2hex(s_INTEGRAL);
            s_INTEGRAL = reshape(s_INTEGRAL',1,20);
            s_INTEGRAL = s_INTEGRAL(11:18);
            s_INTEGRAL=s_INTEGRAL([7 8 5 6 3 4 1 2]);
            out_INTEGRAL=hex2dec(s_INTEGRAL);
        end
        
        function DERIVATIVE_GAIN_axis(obj,axis)
            %
            % Derivative Gain – Sets the derivative gain of the control loop.
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            address_DERIVATIVE=strcat('1183',num2str(axis),'730');
            cmdstr_DERIVATIVE=strcat('A0',address_DERIVATIVE,'55');
            cmdstr_DERIVATIVE = cmdstr_DERIVATIVE([1 2 9 10 7 8 5 6 3 4 11 12]);
            l_DERIVATIVE = length(cmdstr_DERIVATIVE);
            c_DERIVATIVE = hex2dec(reshape(cmdstr_DERIVATIVE,2,l_DERIVATIVE/2)');
            fwrite(obj.Piezo,c_DERIVATIVE);
            
            pause(obj.pause_Time);
            numBytes = obj.Piezo.BytesAvailable;
            ret_str_DERIVATIVE = fread(obj.Piezo,numBytes);
            pause(obj.pause_Time);
            
            [m_DERIVATIVE,n_n] = size(address_DERIVATIVE);
            k_DERIVATIVE = reshape(ret_str_DERIVATIVE,10,m_DERIVATIVE);
            s_DERIVATIVE = k_DERIVATIVE(:,1);
            s_DERIVATIVE = dec2hex(s_DERIVATIVE);
            s_DERIVATIVE = reshape(s_DERIVATIVE',1,20);
            s_DERIVATIVE = s_DERIVATIVE(11:18);
            s_DERIVATIVE=s_DERIVATIVE([7 8 5 6 3 4 1 2]);
            out_DERIVATIVE=hex2dec(s_DERIVATIVE);
        end
        
        function SERVO_LOOP_axis(obj,SERVO_INDEX,axis)
            %
            % Servo State – A value of 1 enables the servo loop, a value of 0
            % disables the servo (sets the channel to open loop).
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            %address_SERVO=strcat('1183',num2str(axis),'084');
            
            address_SERVO=strcat('1183',num2str(axis),'084');
            Write_SERVO=num2str(dec2hex(SERVO_INDEX,8));
            cmdstr_SERVO=strcat('A2',address_SERVO,Write_SERVO,'55');
            % -- reorder the bytes --
            cmdstr_SERVO = cmdstr_SERVO([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_SERVO = length(cmdstr_SERVO);
            c_SERVO = hex2dec(reshape(cmdstr_SERVO,2,L_SERVO/2)');
            fwrite(obj.Piezo,c_SERVO);
%             
%             cmdstr_SERVO=strcat('A0',address_SERVO,'55');
%             cmdstr_SERVO = cmdstr_SERVO([1 2 9 10 7 8 5 6 3 4 11 12]);
%             l_SERVO = length(cmdstr_SERVO);
%             c_SERVO = hex2dec(reshape(cmdstr_SERVO,2,l_SERVO/2)');
%             fwrite(obj.Piezo,c_SERVO);
%             
%             pause(obj.pause_Time);
%             numBytes = obj.Piezo.BytesAvailable;
%             ret_str_SERVO = fread(obj.Piezo,numBytes);
%             pause(obj.pause_Time);
%             
%             [m_SERVO,n_n] = size(address_SERVO);
%             k_SERVO = reshape(ret_str_SERVO,10,m_SERVO);
%             s_SERVO = k_SERVO(:,1);
%             s_SERVO = dec2hex(s_SERVO);
%             s_SERVO = reshape(s_SERVO',1,20);
%             s_SERVO = s_SERVO(11:18);
%             s_SERVO=s_SERVO([7 8 5 6 3 4 1 2]);
%             out_SERVO=hex2dec(s_SERVO);
        end
        
        function RANGE_axis(obj,axis)
            %
            % Range  = 078
            % Range - Stage axis range. For example, a 100 micron axis has a
            % value of 0x64.
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            address_Range=strcat('1183',num2str(axis),'078');
            
            cmdstr_Range=strcat('A0',address_Range,'55');
            cmdstr_Range = cmdstr_Range([1 2 9 10 7 8 5 6 3 4 11 12]);
            l_Range = length(cmdstr_Range);
            c_Range = hex2dec(reshape(cmdstr_Range,2,l_Range/2)');
            fwrite(obj.Piezo,c_Range);
            pause(obj.pause_Time);
            numBytes = obj.Piezo.BytesAvailable;
            ret_str_RANGE = fread(obj.Piezo,numBytes);
            pause(obj.pause_Time);
            [m_range,n_range] = size(address_Range);
            k_RANGE = reshape(ret_str_RANGE,10,m_range);
            s_RANGE = k_RANGE(:,1);
            s_RANGE = dec2hex(s_RANGE);
            s_RANGE = reshape(s_RANGE',1,20);
            s_RANGE = s_RANGE(11:18);
            s_RANGE=s_RANGE([7 8 5 6 3 4 1 2]);
            out_RANGE=hex2dec(s_RANGE);
            if  (out_RANGE~=0)
                disp(['The range of axis ',num2str(axis),' is ',num2str(out_RANGE),' um.'])
            end
        end    
        
        function RANGE_TYPE_n(obj,axis)
        %Pause_Time=5e-4; % seconds


        % Range type =044
        %
        % n gives the axis 
        % query and return position of axis 
        %  x  axis in case n=1, 
        %  y  axis in case n=2, 
        %  z  axis  in case n=3

        address_RangeType_n=strcat('1183',num2str(axis),'044');

        cmdstr_RangeType_n=strcat('A0',address_RangeType_n,'55');
        cmdstr_RangeType_n = cmdstr_RangeType_n([1 2 9 10 7 8 5 6 3 4 11 12]);
        l_RangeType_n = length(cmdstr_RangeType_n);
        c_RangeType_n = hex2dec(reshape(cmdstr_RangeType_n,2,l_RangeType_n/2)');
        fwrite(obj.Piezo,c_RangeType_n);
        pause(obj.pause_Time);
        numBytes = obj.Piezo.BytesAvailable;
        ret_str_RangeType_n = fread(obj.Piezo,numBytes);
        pause(obj.pause_Time);
        [m_RangeType_n,n_RangeType_n] = size(address_RangeType_n);
        k_RangeType_n = reshape(ret_str_RangeType_n,10,m_RangeType_n);
        s_RangeType_n = k_RangeType_n(:,1);
        s_RangeType_n = dec2hex(s_RangeType_n);
        s_RangeType_n = reshape(s_RangeType_n',1,20);
        s_RangeType_n = s_RangeType_n(11:18);
        s_RangeType_n=s_RangeType_n([7 8 5 6 3 4 1 2]);
        RANGE_TYPE_OUT=hex2dec(s_RangeType_n);
        switch(RANGE_TYPE_OUT)
            case 0
               disp('The type of units used for the Range parameter is in microns');
            case 1
               disp('The type of units used for the Range parameter is in millimeters');
            case 2 
               disp('The type of units used for the Range parameter is in ?radians');
            otherwise
               warning('What the Hell do you think you are doing mate? You gave the wrong axis number!');
        end
       
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%% WAVEFORM
        
        function WAVETABLE_INDEX(obj,INDEX,axis)
            %
            % Offset= 0x1F8
            % DataType= 32 Bit Integer
            %
            % Wavetable Index – The index of the wavetable point that will
            % be output during the current clock cycle if the waveform is
            % running. Users will typically want to set this to 0 before starting
            % a waveform.
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
              
            Flag_Error=0;
            switch(axis)
                case {1,2} 
                    INDEX=INDEX-50;
                    if ((INDEX<=50)&&(INDEX>=-50)) INDEX= round(INDEX*1048574/100);
                    else warning('What the HELL do you think you are doing mate? You are exceeding the axis!');
                         Flag_Error=1;
                    end
                case 3 
                    INDEX=INDEX-10;
                    if ((INDEX<=10)&&(INDEX>=-10)) INDEX= round(INDEX*1048574/20);
                    else warning('What the HELL do you think you are doing mate? You are exceeding the axis!');
                         Flag_Error=1;
                    end
                otherwise
                    warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
                    Flag_Error=1;
            end    
            if (Flag_Error==0) % in order to assure that we do not move in case of error 
            %in order to write negative HEX in matlab 32 bit
            if INDEX < 0
            INDEX = (2^32 + INDEX);
            end
            
            address_INDEX=strcat('1183',num2str(axis),'1F8');
            Write_INDEX=num2str(dec2hex(INDEX,8));
            cmdstr_INDEX=strcat('A2',address_INDEX,Write_INDEX,'55');% -- reorder the bytes --
            cmdstr_INDEX = cmdstr_INDEX([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_INDEX = length(cmdstr_INDEX);
            c_INDEX = hex2dec(reshape(cmdstr_INDEX,2,L_INDEX/2)');
            fwrite(obj.Piezo,c_INDEX);
           % pause(obj.pause_Time);
            end
        end
        
        function WAVETABLE_END_INDEX(obj,INDEX,axis)
            %
            % Offset= 0x204
            % DataType= 32 Bit Integer
            %
            % End of Wavetable Index – Specifies the waveform point index
            % at which the controller will return to the first point of the
            % waveform. This value should be set to the number of points in
            % the buffer minus one (the first point is index zero). For example
            % a 100 point waveform for channel 1 would have memory
            % 0x11831204 set to a value of 99, and the last point would be
            % located at memory address 0xC000018C. The maximum buffer
            % size is 83,333 points, 2 seconds of data at full loop speed (1
            % clock cycle every 24 ?sec).
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            address_INDEX=strcat('1183',num2str(axis),'204');
            Write_INDEX=num2str(dec2hex(round(INDEX),8));
            cmdstr_INDEX=strcat('A2',address_INDEX,Write_INDEX,'55');% -- reorder the bytes --
            cmdstr_INDEX = cmdstr_INDEX([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_INDEX = length(cmdstr_INDEX);
            c_INDEX = hex2dec(reshape(cmdstr_INDEX,2,L_INDEX/2)');
            fwrite(obj.Piezo,c_INDEX);
            pause(obj.pause_Time);
        end
        
        function WAVETABLE_CYCLE_DELAY(obj,DELAY,axis)
            %
            % Offset= 0x200
            % DataType= 32 Bit Integer
            %
            % Wavetable Cycle Delay – The number of clock cycles to wait
            % before the next wavetable point is output. This can be used to
            % achieve waveform shapes that are longer than two seconds.
            % For example a Wavetable Buffer Size of 83,333 with a Wavetable
            % Cycle Delay of 1 will have a period of 4 seconds.
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            address_DELAY=strcat('1183',num2str(axis),'200');
            Write_DELAY=num2str(dec2hex(DELAY,8));
            cmdstr_DELAY=strcat('A2',address_DELAY,Write_DELAY,'55');% -- reorder the bytes --
            cmdstr_DELAY = cmdstr_DELAY([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_DELAY = length(cmdstr_DELAY);
            c_DELAY = hex2dec(reshape(cmdstr_DELAY,2,L_DELAY/2)');
            fwrite(obj.Piezo,c_DELAY);
            pause(obj.pause_Time);
        end
               
        function WAVETABLE_ACTIVE(obj,ACTIVE,axis)
            %
            % Offset= 0x208
            % DataType= 32 Bit Integer
            %
            % Wavetable Active – Set the value to 1 as a software trigger to
            % start the wavetable output (if Wavetable Enable is also 1), a
            % value of 0 will stop the wavetable output. This value will also
            % be set to 1 or 0 by TTL I/O triggers if they are configured to
            % start or stop the waveform.
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            address_ACTIVE=strcat('1183',num2str(axis),'208');
            Write_ACTIVE=num2str(dec2hex(ACTIVE,8));
            cmdstr_ACTIVE=strcat('A2',address_ACTIVE,Write_ACTIVE,'55');
            % -- reorder the bytes --
            cmdstr_ACTIVE = cmdstr_ACTIVE([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_ACTIVE = length(cmdstr_ACTIVE);
            c_ACTIVE = hex2dec(reshape(cmdstr_ACTIVE,2,L_ACTIVE/2)');
            fwrite(obj.Piezo,c_ACTIVE);
            %pause(obj.pause_Time);
        end
        
        function WAVETABLE_ENABLE(obj,ENABLE,axis)
            %
            % Offset= 0x1F4
            % DataType= 32 Bit Integer
            %
            % Wavetable Enable – A value of 1 enables wavetable scanning
            % for the channel, a value of 0 disables wavetable scanning.
            % When wavetable scanning is enabled, the BNC analog input is
            % automatically disabled.
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
%             if (axis==3) ENABLE= round(ENABLE*1048574/20); % value rescaled for Z-axis
%              else ENABLE= round(ENABLE*1048574/100);        % value rescaled for X & Y axis
%             end
            address_ENABLE=strcat('1183',num2str(axis),'1F4');
            Write_ENABLE=num2str(dec2hex(ENABLE,8));
            cmdstr_ENABLE=strcat('A2',address_ENABLE,Write_ENABLE,'55');
            % -- reorder the bytes --
            cmdstr_ENABLE = cmdstr_ENABLE([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_ENABLE = length(cmdstr_ENABLE);
            c_ENABLE = hex2dec(reshape(cmdstr_ENABLE,2,L_ENABLE/2)');
            fwrite(obj.Piezo,c_ENABLE);
            %pause(obj.pause_Time);
        end
        
        function SCAN(obj,Initial_Point,Final_Point,TPixel,ramp_axis)
        %Scan(obj, X,Y,Z, TPixel, ramp_axis) 
%                
         MOVE_axis(obj,Initial_Point,ramp_axis);
         pause(obj.pause_Time);
       
        % RESET    
%         WAVETABLE_INDEX(obj,0,ramp_axis);
        WAVETABLE_CYCLE_DELAY(obj,0,ramp_axis);
        WAVETABLE_ENABLE(obj,0,ramp_axis);
        WAVETABLE_ACTIVE(obj,0,ramp_axis);
       
        time_wave=48e-3; 
        n_points=time_wave/24e-6;
       
        WAVETABLE_END_INDEX(obj,n_points-1,ramp_axis);
        
        %Initial = round(Pos(obj,ramp_axis))
         
        %READ_axis_out(obj,axis);
        switch(ramp_axis)
            case 1
               NEXT_X(obj,Initial_Point,Final_Point,n_points);
               for j=round(Initial_Point):round(Final_Point)
                   pause(1)
               MOVE_axis(obj,j,ramp_axis);
               end    
            case 2
               NEXT_Y(obj,Initial_Point,Final_Point,n_points);
            case 3 
               NEXT_Z(obj,Initial_Point,Final_Point,n_points);
            otherwise
               warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
        end
            
         
            %%%%%%% NEW TTL COMMANDS 
            %%%%%%% these commands allow you to control the waveforms, when
            %%%%%%% and where they are supposed to start and stop
            %%%%%%%
            TTL(obj,7,ramp_axis);  % set level trigger pause/resume
            TTL_OUTPUT(obj,2,ramp_axis); %set the waveform index level to rising edge/active high
            TTL_OUTPUT_ACTIVE_PAIRS(obj,1,ramp_axis); %set output indexes on 1 active pairs
            TTL_START(obj,0,ramp_axis) % set the initial index value
            TTL_STOP(obj,n_points-1,ramp_axis) % set the final index value, basically where you want the Piezo stops!
            
%            
%             
%             WAVETABLE_END_INDEX(obj,n_points-1,ramp_axis);
%             Initial = round(Pos(obj,ramp_axis));
%             
%             for j=round(points{ramp_axis}(1)):round(points{ramp_axis}(end))
%                     %pause(time_wave);
%                     %pause(TPixel);
%                     pause(5e-1);
%                     %disp(round(points{ramp_axis}(j)))
%                     %disp(j)
%                     %obj.Mov(round(points{ramp_axis}(j)),ramp_axis);
%                     obj.Mov(j,ramp_axis);
%                     
%             end    
            
% %             
%            % if (Initial == round(Pos(obj,ramp_axis)))
                 WAVETABLE_ENABLE(obj,1,ramp_axis);
                 WAVETABLE_ACTIVE(obj,1,ramp_axis);
            %else warning('What the HELL do you think you are doing mate? You are starting from the wrong place!');
            %end
            %time_wave
%             pause(obj.StabilizeTime);
%              pause(5e-2); 

%               WAVETABLE_ACTIVE(obj,0,ramp_axis);
%               WAVETABLE_ENABLE(obj,0,ramp_axis);
%               WAVETABLE_INDEX(obj,fin_pos,ramp_axis);
%               


%              switch(ramp_axis)
%                 case 1
%                     obj.Mov(X(length(X)),1);
%                 case 2
%                     obj.Mov(Y(length(Y)),2);
%                 case 3
%                     obj.Mov(Z(length(Z)),3);
%                 otherwise
%                     warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
%             end
           
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        end    
        
        
        function SCAN2D(obj,Initial_Point_1,Final_Point_1,Initial_Point_2,Final_Point_2,TPixel,ramp_axis1,ramp_axis2,resolution)
       %Scan(obj, X,Y,Z, TPixel, ramp_axis) 
%                
         
%         pause(obj.pause_Time);
%        
        % RESET    
%         WAVETABLE_INDEX(obj,0,ramp_axis1);
%         WAVETABLE_CYCLE_DELAY(obj,0,ramp_axis1);
%         WAVETABLE_ENABLE(obj,0,ramp_axis1);
%         WAVETABLE_ACTIVE(obj,0,ramp_axis1);
%        
        time_wave_2=48e-2; 
        n_points_2=time_wave_2/24e-6;
       
        time_wave_1=48e-3; 
        n_points_1=time_wave_1/24e-6;
        
        MOVE_axis(obj,Initial_Point_2,ramp_axis2);   
        MOVE_axis(obj,Initial_Point_1,ramp_axis1);
        pause(obj.pause_Time);
       
        % RESET    
        WAVETABLE_INDEX(obj,0,ramp_axis1);
        WAVETABLE_CYCLE_DELAY(obj,0,ramp_axis1);
        WAVETABLE_ENABLE(obj,0,ramp_axis1);
        WAVETABLE_ACTIVE(obj,0,ramp_axis1);
       
       
        WAVETABLE_END_INDEX(obj,n_points_1-1,ramp_axis1);
        
        %Initial = round(Pos(obj,ramp_axis))
        %READ_axis_out(obj,axis);
        switch(ramp_axis1)
            case 1
               NEXT_X(obj,Initial_Point_1,Final_Point_1,n_points_1);
            case 2
               NEXT_Y(obj,Initial_Point_1,Final_Point_1,n_points_1);
            case 3 
               NEXT_Z(obj,Initial_Point_1,Final_Point_1,n_points_1);
            otherwise
               warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
        end
            
        
         Number_Scan_Points=2000;
            Starting_Point_Array=linspace(round(Initial_Point_2),round(Initial_Point_2),round((n_points_2-Number_Scan_Points)/2));
            Point_array1= linspace(round(Initial_Point_2),round(Final_Point_2),Number_Scan_Points);  
            Point_array2= linspace(round(Final_Point_2),round(Final_Point_2),round((n_points_2-Number_Scan_Points)/2));
            
            Total_Point_array=horzcat(Starting_Point_Array,Point_array1,Point_array2);
            
%             lun=size(nexts,2);
%             for i=1:lun
%             nexts(lun+i)=round(Final_Point*1048574/100);
%             end
%             
            
            
            Point_Y=round((Final_Point_2-Initial_Point_2)/resolution)
%             Point_target=linspace(Initial_Point_2,Final_Point_2,Point_Y);
%             
%             if Point_target < 0
%             Point_target = (2^32 + Point_target);
%             end
            
            %for j=1:size(Total_Point_array,2)
            for j=1:Point_Y    
                j
%                 Point_target=Total_Point_array(j)
%                 if Point_target < 0
%                 Point_target = (2^32 + Point_target);
%                 end                
%            WAVETABLE_ENABLE(obj,1,ramp_axis1);
%            WAVETABLE_ACTIVE(obj,1,ramp_axis1);
%        
%         
%             WAVETABLE_ACTIVE(obj,0,ramp_axis1);
%             WAVETABLE_ENABLE(obj,0,ramp_axis1);
%             WAVETABLE_INDEX(obj,0,ramp_axis1);
                 pause(1);
                %MOVE_axis(obj,Point_target,ramp_axis2)
                MOVE_axis(obj,j,ramp_axis2)
             end
              pause(obj.pause_Time);
%              
        

        end    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTL Functions
        
        function TTL = TTL(obj,x,axis)
            %
            % Offset= 0x94
            % DataType= 32 Bit Integer
            %
            % TTL Input Pin 1 Function – Specifies the trigger type for pin
            % 1 of the TTL I/O connector. It is recommended that the user
            % does not program different functions (other than None) for different
            %  channels on the same pin.
            %             0 = None
            %             1 = Edge Triggered Start
            %             2 = Level Triggered Start
            %             3 = Edge Triggered Stop
            %             4 = Level Triggered Stop
            %             5 = Level Triggered Start and Stop
            %             6 = Edge Triggered Pause and Resume
            %             7 = Level Triggered Pause and Resume
            % zero=218
            % query and return position of axis
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
         
         add_NEXT=hex2dec(strcat('1183',num2str(axis),'094'));
         address_NEXT= dec2hex(add_NEXT);
         Write_n=num2str(dec2hex(x,8));
         cmdstr_NEXT=strcat('A2',address_NEXT,Write_n,'55');
         cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
                L_NEXT = length(cmdstr_NEXT);
                c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
                fwrite(obj.Piezo,c_NEXT);
        end
        
        
        function TTL_OUTPUT_ACTIVE_PAIRS = TTL_OUTPUT_ACTIVE_PAIRS(obj,x,axis)
            %
            % Offset= 0x158
            % DataType= 32 Bit Integer
            % TTL Output Waveform Index Count – Specifies the number
            % of low and high index pairs. For example, if two low indexes
            % are specified and two high indexes are specified, the Index
            % Count value should be 2 (not 4).
         
         add_PAIRS=hex2dec(strcat('1183',num2str(axis),'158'));
         address_NEXT= dec2hex(add_PAIRS);
         Write_PAIRS=num2str(dec2hex(x,8));
         cmdstr_PAIRS=strcat('A2',address_NEXT,Write_PAIRS,'55');
         cmdstr_PAIRS = cmdstr_PAIRS([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_PAIRS = length(cmdstr_PAIRS);
         c_PAIRS = hex2dec(reshape(cmdstr_PAIRS,2,L_PAIRS/2)');
         fwrite(obj.Piezo,c_PAIRS);
        end
        
         
        function TTL_OUTPUT = TTL_OUTPUT(obj,x,axis)
            %
            % Offsets
            %  Offset= 0F4 in case of x  axis, axis=1,
            %  Offset= 0F8 in case of y  axis, axis=2,
            %  Offset= 0FC in case of z  axis, axis=3
            %
            % DataType= 32 Bit Integer
            %
            % Specifies the output type for
            % pin 1 of the TTL I/O connector. An output pin should typically
            % only have a function other than None for one channel at a time.
            % 0 = None
            % 1 = Control Loop Error
            % 2 = Waveform Index Level
            %
           
                 
            switch(axis)
                case 1
                    add_OUTPUT=hex2dec(strcat('1183',num2str(axis),'0F4'));
                case 2
                    add_OUTPUT=hex2dec(strcat('1183',num2str(axis),'0F8'));
                case 3
                     add_OUTPUT=hex2dec(strcat('1183',num2str(axis),'0FC'));
                otherwise
                    warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
            end
            
         %add_OUTPUT=hex2dec(strcat('1183',num2str(axis),'0F4'));
         address_OUTPUT= dec2hex(add_OUTPUT);
         %x=round(x*1048574/100)
         Write_OUTPUT=num2str(dec2hex(x,8));
         cmdstr_OUTPUT=strcat('A2',address_OUTPUT,Write_OUTPUT,'55')
         cmdstr_OUTPUT = cmdstr_OUTPUT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_OUTPUT = length(cmdstr_OUTPUT);
         c_OUTPUT = hex2dec(reshape(cmdstr_OUTPUT,2,L_OUTPUT/2)');
         fwrite(obj.Piezo,c_OUTPUT);   
        end
        
        function TTL_START = TTL_START(obj,x,axis)
            %
            % Offset= 0x15C
            % DataType= 32 Bit Integer
            % TTL Output Low Index Array Base Offset – The base offset
            % for an array of up to 16 waveform indexes. At the specified
            % indexes, an output set to type Waveform Index Level will transition
            % to level low. At the specified indexes an output function
            % set to type Waveform Index Pulse will output a single pulse.
         
         add_START=hex2dec(strcat('1183',num2str(axis),'15C'));
         address_START= dec2hex(add_START);
         Write_START=num2str(dec2hex(x,8));
         cmdstr_START=strcat('A2',address_START,Write_START,'55');
         cmdstr_START = cmdstr_START([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_START = length(cmdstr_START);
         c_START = hex2dec(reshape(cmdstr_START,2,L_START/2)');
         fwrite(obj.Piezo,c_START);
        end
        
        
        function TTL_STOP = TTL_STOP(obj,x,axis)
            %
            % Offset= 0x19C
            % TTL Output High Index Array Base Offset – The base offset
            % for an array of up to 16 waveform indexes. At the specified
            % indexes, an output set to type Waveform Index Level will transition
            % to level high. At the specified indexes an output function
            % set to type Waveform Index Pulse will output a single pulse.

         add_STOP=hex2dec(strcat('1183',num2str(axis),'15C'));
         address_STOP= dec2hex(add_STOP);
         Write_STOP=num2str(dec2hex(x,8));
         cmdstr_STOP=strcat('A2',address_STOP,Write_STOP,'55');
         cmdstr_STOP = cmdstr_STOP([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_STOP = length(cmdstr_STOP);
         c_STOP = hex2dec(reshape(cmdstr_STOP,2,L_STOP/2)');
         fwrite(obj.Piezo,c_STOP);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        function READ_c1 = READ_c1(address_n,obj)
            %
            % Offset= 0x218
            % DataType= 32 Bit Integer
            %
            % The A0 command reads one 32 bit value from the specified address. In this sample the
            % address used is 0x11831218 and the return data value is 0x64, or 100 in decimal. The
            % address and data bytes are both 32 bit values, and are transmitted with significance increasing
            % (LSB transmitted first and MSB transmitted last).
            %
            % zero=218
            % query and return position of axis
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            
            %address_n=strcat('1183',num2str(axis),'334');
            %address_n=strcat('1183',num2str(axis),'218');
            %address_n='C0000004'
            cmdstr_n=strcat('A0',address_n,'55');
            cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 11 12]);
            l_n = length(cmdstr_n);
            c_n = hex2dec(reshape(cmdstr_n,2,l_n/2)');
            fwrite(obj.Piezo,c_n);
            pause(obj.pause_Time);  %%%%%%%%%%%%%%%%%% PAUSE
            numBytes = obj.Piezo.BytesAvailable;
            ret_str_n = fread(obj.Piezo,numBytes);
            pause(obj.pause_Time);  %%%%%%%%%%%%%%%%%% PAUSE
            [m_n,n_n] = size(address_n);
            k_n = reshape(ret_str_n,10,m_n);
            s_n = k_n(:,1);
            s_n = dec2hex(s_n);
            s_n = reshape(s_n',1,20);
            s_n = s_n(11:18);
            s_n=s_n([7 8 5 6 3 4 1 2]);
            % we need to scale out the value and take in consideration the
            % negative values
            
            out=hex2dec(s_n);
            if (out > 2^31) %negative HEX
                out =- (2^32 - out);
            end
              No_scaled= out
              READ_c1=out/1048574*100        % value rescaled for X & Y axis
                          
            
         end
         
        function CLEAN_c1 = CLEAN_c1(obj)
            %
            % Offset= 0x218
            % DataType= 32 Bit Integer
            %
            % The A0 command reads one 32 bit value from the specified address. In this sample the
            % address used is 0x11831218 and the return data value is 0x64, or 100 in decimal. The
            % address and data bytes are both 32 bit values, and are transmitted with significance increasing
            % (LSB transmitted first and MSB transmitted last).
            %
            % zero=218
            % query and return position of axis
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
         tic 
         add_NEXT=hex2dec('C0000000');
            %disp(['Size is ']);
            %size(nexts,2);
            for j=1:54000
                add_NEXT=add_NEXT+1;
                address_NEXT= dec2hex(add_NEXT);
                cmdstr_NEXT=strcat('A2',address_NEXT,'00000000','55');
                cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
                L_NEXT = length(cmdstr_NEXT);
                c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
                fwrite(obj.Piezo,c_NEXT);
            end
           toc
        end

 
        function RESET_FLASH(obj)
            
            INDEX=0;
            address_INDEX='11829010';
            Write_INDEX=num2str(dec2hex(round(INDEX),8));
            cmdstr_INDEX=strcat('A2',address_INDEX,'00000000','55');% -- reorder the bytes --
            cmdstr_INDEX = cmdstr_INDEX([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_INDEX = length(cmdstr_INDEX);
            c_INDEX = hex2dec(reshape(cmdstr_INDEX,2,L_INDEX/2)');
            fwrite(obj.Piezo,c_INDEX);
            pause(obj.pause_Time);
        end

         
        function NEXT_X(obj,Initial_Point,Final_Point,n_points)
            %
            % Offset= 0x208
            % DataType= 32 Bit Integer
            %
            % The A3 command increments the memory address pointer by 4 bytes after issuing a Write
            % Single Location Command (described in section 4.2.2) to set the initial address, and then
            % writes a 32 bit value to the new memory location. After the initial address is set, you can
            % use multiple Write Next commands to continue incrementing the memory address. Care
            % must be taken to not use a read command in between multiple Write Next commands.
            % Read commands will also set the initial memory location. In this sample the data value
            % written is 0x3E8, or 1000 in decimal. Bytes are transmitted with significance increasing
            % (LSB transmitted first and MSB transmitted last).
            %
            % micron  - Range X [0-100] Microns
            % micron  - Range Y [0-100] Microns
            % micron  - Range Z [0-20] Microns
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            %obj.MOVE_axis(Move_NEXT,axis);
            
            %
            %             addr_buffer = ['C0000000';'C0054000';'C00A8000';'C00FC000';'C0150000';'C01A4000'] % WaveBuffer1,2,3,4,5,6
            %             ch = obj.Piezo.channel;
            %
            %             writeDspAddr(addr_buffer(ch,:),round(obj.auxWave(1)),'i',obj);
            %                 for i = 2:numPoints
            %                 val = round(obj.Wave(i))
            %                 if val<0
            %                     val = (2^32 + val); % because matlab cant convert neg numbers to hex
            %                 end
            
%              n_points=2000;
%               Point_array= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),n_points);  
% % %           

%             init=1;
%             tot=4;
%             Starting_Point_Array=linspace(round(Initial_Point*1048574/100),round(Initial_Point*1048574/100),round((1/5)*n_points));
%             Point_array1= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),round((1/5)*n_points));  
%             Point_array2= linspace(round(Final_Point*1048574/100),round(Final_Point*1048574/100),round((3/5)*n_points));
% %           
            Number_Scan_Points=2000;
            Starting_Point_Array=linspace(round(Initial_Point*1048574/100),round(Initial_Point*1048574/100),round(n_points/5));
            Point_array1= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),round(3*n_points/5));  
            Point_array2= linspace(round(Final_Point*1048574/100),round(Final_Point*1048574/100),round(n_points/5));
            
           Total_Point_array=horzcat(Starting_Point_Array,Point_array1,Point_array2);
%            Total_Point_array=linspace(0,100,2000);
%             Total_Point_array=Point_array
%             lun=size(nexts,2);
%             for i=1:lun
%             nexts(lun+i)=round(Final_Point*1048574/100);
%             end
%             
            
            Point_target=Total_Point_array(1);
            %clear TARGET;
            if Point_target < 0
            Point_target = (2^32 + Point_target);
            end
            TARGET=dec2hex(round(Point_target),8);
%             address_NEXT='C0000000';
%             cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
%             % -- reorder the bytes --
%             cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
%             L_NEXT = length(cmdstr_NEXT);
%             c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
%             fwrite(obj.Piezo,c_NEXT);
            
            add_NEXT=hex2dec('C0000000');
            for j=1:size(Total_Point_array,2)
                %clear TARGET;
                Point_target=Total_Point_array(j);
                if Point_target < 0
                Point_target = (2^32 + Point_target);
                end
                TARGET=dec2hex(round(Point_target),8);
                add_NEXT=add_NEXT+4;
                address_NEXT= dec2hex(add_NEXT);
                cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
                cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
                L_NEXT = length(cmdstr_NEXT);
                c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
                fwrite(obj.Piezo,c_NEXT);
             end
              pause(obj.pause_Time);
%              
%                 TARGET = TARGET([7 8 5 6 3 4 1 2]);
%                 TARGET=dec2hex(round(Point_target),8);
%                 cmd_str_NEXT = ['A3',TARGET,'55']
%                 L = length(cmd_str_NEXT);
%                 c = hex2dec(reshape(cmd_str_NEXT,2,L/2)');
%                 fwrite(obj.Piezo,c);

            %disp(['NEXT is just stop at ']);
            %Fin_LOOP = Pos(obj,1)
        end
          
          
        function NEXT_XY(obj,Initial_Point1,Final_Point1,Initial_Point2,Final_Point2,n_points)
            %
            % Offset= 0x208
            % DataType= 32 Bit Integer
            %
            % The A3 command increments the memory address pointer by 4 bytes after issuing a Write
            % Single Location Command (described in section 4.2.2) to set the initial address, and then
            % writes a 32 bit value to the new memory location. After the initial address is set, you can
            % use multiple Write Next commands to continue incrementing the memory address. Care
            % must be taken to not use a read command in between multiple Write Next commands.
            % Read commands will also set the initial memory location. In this sample the data value
            % written is 0x3E8, or 1000 in decimal. Bytes are transmitted with significance increasing
            % (LSB transmitted first and MSB transmitted last).
            %
            % micron  - Range X [0-100] Microns
            % micron  - Range Y [0-100] Microns
            % micron  - Range Z [0-20] Microns
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            %obj.MOVE_axis(Move_NEXT,axis);
            
            %
            %             addr_buffer = ['C0000000';'C0054000';'C00A8000';'C00FC000';'C0150000';'C01A4000'] % WaveBuffer1,2,3,4,5,6
            %             ch = obj.Piezo.channel;
            %
            %             writeDspAddr(addr_buffer(ch,:),round(obj.auxWave(1)),'i',obj);
            %                 for i = 2:numPoints
            %                 val = round(obj.Wave(i))
            %                 if val<0
            %                     val = (2^32 + val); % because matlab cant convert neg numbers to hex
            %                 end
            
            %n_points=time_wave/24e-6
%              Point_array= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),n_points);  
% %           

%             init=1;
%             tot=4;
%             Starting_Point_Array=linspace(round(Initial_Point*1048574/100),round(Initial_Point*1048574/100),round((1/5)*n_points));
%             Point_array1= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),round((1/5)*n_points));  
%             Point_array2= linspace(round(Final_Point*1048574/100),round(Final_Point*1048574/100),round((3/5)*n_points));
%           
            Number_Scan_Points=2000;
            Starting_Point_Array_X=linspace(round(Initial_Point1*1048574/100),round(Initial_Point1*1048574/100),round((n_points-Number_Scan_Points)/2));
            Point_array1_X= linspace(round(Initial_Point1*1048574/100),round(Final_Point1*1048574/100),Number_Scan_Points);  
            Point_array2_X= linspace(round(Final_Point1*1048574/100),round(Final_Point1*1048574/100),round((n_points-Number_Scan_Points)/2));
            
            Total_Point_array_X=horzcat(Starting_Point_Array_X,Point_array1_X,Point_array2_X);
            
            
            Starting_Point_Array_Y=linspace(round(Initial_Point2*1048574/100),round(Initial_Point2*1048574/100),round((n_points-Number_Scan_Points)/2));
            Point_array1_Y= linspace(round(Initial_Point2*1048574/100),round(Final_Point2*1048574/100),Number_Scan_Points);  
            Point_array2_Y= linspace(round(Final_Point2*1048574/100),round(Final_Point2*1048574/100),round((n_points-Number_Scan_Points)/2));
            
            Total_Point_array_Y=horzcat(Starting_Point_Array_Y,Point_array1_Y,Point_array2_Y);
            
%             lun=size(nexts,2);
%             for i=1:lun
%             nexts(lun+i)=round(Final_Point*1048574/100);
%             end
%             
            
            Point_target_Y=Total_Point_array_Y(1);
            %clear TARGET;
            if Point_target_Y < 0
            Point_target_Y = (2^32 + Point_target_Y);
            end
            TARGET=dec2hex(round(Point_target_Y),8);
%             address_NEXT='C0000000';
%             cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
%             % -- reorder the bytes --
%             cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
%             L_NEXT = length(cmdstr_NEXT);
%             c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
%             fwrite(obj.Piezo,c_NEXT);
            
            add_NEXT_X=hex2dec('C0000000');
            for j=1:size(Total_Point_array_X,2)
                %clear TARGET;
                Point_target_Y=Total_Point_array_X(j);
                if Point_target_Y < 0
                Point_target_Y = (2^32 + Point_target_Y);
                end
                TARGET=dec2hex(round(Point_target_Y),8);
                add_NEXT_X=add_NEXT_X+4;
                address_NEXT= dec2hex(add_NEXT_X);
                cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
                cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
                L_NEXT = length(cmdstr_NEXT);
                c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
                fwrite(obj.Piezo,c_NEXT);
             end
              pause(obj.pause_Time);
%              
%                 TARGET = TARGET([7 8 5 6 3 4 1 2]);
%                 TARGET=dec2hex(round(Point_target),8);
%                 cmd_str_NEXT = ['A3',TARGET,'55']
%                 L = length(cmd_str_NEXT);
%                 c = hex2dec(reshape(cmd_str_NEXT,2,L/2)');
%                 fwrite(obj.Piezo,c);

            %disp(['NEXT is just stop at ']);
            %Fin_LOOP = Pos(obj,1)
        end
          
        function NEXT_Y(obj,Initial_Point,Final_Point,n_points)
            %
            % Offset= 0x208
            % DataType= 32 Bit Integer
            %
            % The A3 command increments the memory address pointer by 4 bytes after issuing a Write
            % Single Location Command (described in section 4.2.2) to set the initial address, and then
            % writes a 32 bit value to the new memory location. After the initial address is set, you can
            % use multiple Write Next commands to continue incrementing the memory address. Care
            % must be taken to not use a read command in between multiple Write Next commands.
            % Read commands will also set the initial memory location. In this sample the data value
            % written is 0x3E8, or 1000 in decimal. Bytes are transmitted with significance increasing
            % (LSB transmitted first and MSB transmitted last).
            %
            % micron  - Range X [0-100] Microns
            % micron  - Range Y [0-100] Microns
            % micron  - Range Z [0-20] Microns
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            %obj.MOVE_axis(Move_NEXT,axis);
            
            %
            %             addr_buffer = ['C0000000';'C0054000';'C00A8000';'C00FC000';'C0150000';'C01A4000'] % WaveBuffer1,2,3,4,5,6
            %             ch = obj.Piezo.channel;
            %
            %             writeDspAddr(addr_buffer(ch,:),round(obj.auxWave(1)),'i',obj);
            %                 for i = 2:numPoints
            %                 val = round(obj.Wave(i))
            %                 if val<0
            %                     val = (2^32 + val); % because matlab cant convert neg numbers to hex
            %                 end
            
            %n_points=time_wave/24e-6
%              Point_array= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),n_points);  
% %           

%             init=1;
%             tot=4;
%             Starting_Point_Array=linspace(round(Initial_Point*1048574/100),round(Initial_Point*1048574/100),round((1/5)*n_points));
%             Point_array1= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),round((1/5)*n_points));  
%             Point_array2= linspace(round(Final_Point*1048574/100),round(Final_Point*1048574/100),round((3/5)*n_points));
%           
            Number_Scan_Points=2000;
            Starting_Point_Array=linspace(round(Initial_Point*1048574/100),round(Initial_Point*1048574/100),round((n_points-Number_Scan_Points)/2));
            Point_array1= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),Number_Scan_Points);  
            Point_array2= linspace(round(Final_Point*1048574/100),round(Final_Point*1048574/100),round((n_points-Number_Scan_Points)/2));
            
            Total_Point_array=horzcat(Starting_Point_Array,Point_array1,Point_array2);
            
%             lun=size(nexts,2);
%             for i=1:lun
%             nexts(lun+i)=round(Final_Point*1048574/100);
%             end
%             
            
            Point_target=Total_Point_array(1);
            %clear TARGET;
            if Point_target < 0
            Point_target = (2^32 + Point_target);
            end
            TARGET=dec2hex(round(Point_target),8);
            address_NEXT='C0054000';
            cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
            % -- reorder the bytes --
            cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_NEXT = length(cmdstr_NEXT);
            c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
            fwrite(obj.Piezo,c_NEXT);
            
            add_NEXT=hex2dec('C0054000');
            for j=2:size(Total_Point_array,2)
                %clear TARGET;
                Point_target=Total_Point_array(j);
                if Point_target < 0
                Point_target = (2^32 + Point_target);
                end
                TARGET=dec2hex(round(Point_target),8);
                add_NEXT=add_NEXT+4;
                address_NEXT= dec2hex(add_NEXT);
                cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
                cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
                L_NEXT = length(cmdstr_NEXT);
                c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
                fwrite(obj.Piezo,c_NEXT);
             end
              pause(obj.pause_Time);
%              
%                 TARGET = TARGET([7 8 5 6 3 4 1 2]);
%                 TARGET=dec2hex(round(Point_target),8);
%                 cmd_str_NEXT = ['A3',TARGET,'55']
%                 L = length(cmd_str_NEXT);
%                 c = hex2dec(reshape(cmd_str_NEXT,2,L/2)');
%                 fwrite(obj.Piezo,c);

            %disp(['NEXT is just stop at ']);
            %Fin_LOOP = Pos(obj,1)
        end
             
        function NEXT_Z(obj,Initial_Point,Final_Point,n_points)
            %
            % Offset= 0x208
            % DataType= 32 Bit Integer
            %
            % The A3 command increments the memory address pointer by 4 bytes after issuing a Write
            % Single Location Command (described in section 4.2.2) to set the initial address, and then
            % writes a 32 bit value to the new memory location. After the initial address is set, you can
            % use multiple Write Next commands to continue incrementing the memory address. Care
            % must be taken to not use a read command in between multiple Write Next commands.
            % Read commands will also set the initial memory location. In this sample the data value
            % written is 0x3E8, or 1000 in decimal. Bytes are transmitted with significance increasing
            % (LSB transmitted first and MSB transmitted last).
            %
            % micron  - Range X [0-100] Microns
            % micron  - Range Y [0-100] Microns
            % micron  - Range Z [0-20] Microns
            %
            %  x  axis in case axis=1,
            %  y  axis in case axis=2,
            %  z  axis in case axis=3
            %obj.MOVE_axis(Move_NEXT,axis);
            
            %
            %             addr_buffer = ['C0000000';'C0054000';'C00A8000';'C00FC000';'C0150000';'C01A4000'] % WaveBuffer1,2,3,4,5,6
            %             ch = obj.Piezo.channel;
            %
            %             writeDspAddr(addr_buffer(ch,:),round(obj.auxWave(1)),'i',obj);
            %                 for i = 2:numPoints
            %                 val = round(obj.Wave(i))
            %                 if val<0
            %                     val = (2^32 + val); % because matlab cant convert neg numbers to hex
            %                 end
            
            %n_points=time_wave/24e-6
%              Point_array= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),n_points);  
% %           

%             init=1;
%             tot=4;
%             Starting_Point_Array=linspace(round(Initial_Point*1048574/100),round(Initial_Point*1048574/100),round((1/5)*n_points));
%             Point_array1= linspace(round(Initial_Point*1048574/100),round(Final_Point*1048574/100),round((1/5)*n_points));  
%             Point_array2= linspace(round(Final_Point*1048574/100),round(Final_Point*1048574/100),round((3/5)*n_points));
%           
            Number_Scan_Points=2000;
            Starting_Point_Array=linspace(round(Initial_Point*1048574/20),round(Initial_Point*1048574/20),round((n_points-Number_Scan_Points)/2));
            Point_array1= linspace(round(Initial_Point*1048574/20),round(Final_Point*1048574/20),Number_Scan_Points);  
            Point_array2= linspace(round(Final_Point*1048574/20),round(Final_Point*1048574/20),round((n_points-Number_Scan_Points)/2));
            
            Total_Point_array=horzcat(Starting_Point_Array,Point_array1,Point_array2);
            
%             lun=size(nexts,2);
%             for i=1:lun
%             nexts(lun+i)=round(Final_Point*1048574/20);
%             end
%             
            
            Point_target=Total_Point_array(1);
            %clear TARGET;
            if Point_target < 0
            Point_target = (2^32 + Point_target);
            end
            TARGET=dec2hex(round(Point_target),8);
            address_NEXT='C00A8000';
            cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
            % -- reorder the bytes --
            cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_NEXT = length(cmdstr_NEXT);
            c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
            fwrite(obj.Piezo,c_NEXT);
            
            add_NEXT=hex2dec('C00A8000');
            for j=2:size(Total_Point_array,2)
                %clear TARGET;
                Point_target=Total_Point_array(j);
                if Point_target < 0
                Point_target = (2^32 + Point_target);
                end
                TARGET=dec2hex(round(Point_target),8);
                add_NEXT=add_NEXT+4;
                address_NEXT= dec2hex(add_NEXT);
                cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
                cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
                L_NEXT = length(cmdstr_NEXT);
                c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
                fwrite(obj.Piezo,c_NEXT);
             end
              pause(obj.pause_Time);
%              
%                 TARGET = TARGET([7 8 5 6 3 4 1 2]);
%                 TARGET=dec2hex(round(Point_target),8);
%                 cmd_str_NEXT = ['A3',TARGET,'55']
%                 L = length(cmd_str_NEXT);
%                 c = hex2dec(reshape(cmd_str_NEXT,2,L/2)');
%                 fwrite(obj.Piezo,c);

            %disp(['NEXT is just stop at ']);
            %Fin_LOOP = Pos(obj,1)
        end
         
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% SCAN 2D
         
        function NEXT_YX(obj,Initial_Point_X,Final_Point_X,Initial_Point_Y,Final_Point_Y,n_points_X,n_points_Y,ramp_axis1)
            
            Number_Scan_Points=2000;
            Starting_Point_Array=linspace(round(Initial_Point_Y*1048574/100),round(Initial_Point_Y*1048574/100),round((n_points_Y-Number_Scan_Points)/2));
            Point_array1= linspace(round(Initial_Point_Y*1048574/100),round(Final_Point_Y*1048574/100),Number_Scan_Points);  
            Point_array2= linspace(round(Final_Point_Y*1048574/100),round(Final_Point_Y*1048574/100),round((n_points_Y-Number_Scan_Points)/2));
            
            Total_Point_array=horzcat(Starting_Point_Array,Point_array1,Point_array2);
            
            Point_target=Total_Point_array(1);
            %clear TARGET;
            if Point_target < 0
            Point_target = (2^32 + Point_target);
            end
            TARGET=dec2hex(round(Point_target),8);
            address_NEXT='C0054000';
            cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
            % -- reorder the bytes --
            cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_NEXT = length(cmdstr_NEXT);
            c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
            fwrite(obj.Piezo,c_NEXT);
            
            add_NEXT=hex2dec('C0054000');
            for j=2:size(Total_Point_array,2)
                %clear TARGET;
                SCAN(obj,Initial_Point_X,Final_Point_X,n_points_X,ramp_axis1);
                Point_target=Total_Point_array(j)
                if Point_target < 0
                Point_target = (2^32 + Point_target);
                end
                TARGET=dec2hex(round(Point_target),8);
                add_NEXT=add_NEXT+4;
                address_NEXT= dec2hex(add_NEXT);
                cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
                cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
                L_NEXT = length(cmdstr_NEXT);
                c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
                fwrite(obj.Piezo,c_NEXT);
             end
              pause(obj.pause_Time);
%              
%                 TARGET = TARGET([7 8 5 6 3 4 1 2]);
%                 TARGET=dec2hex(round(Point_target),8);
%                 cmd_str_NEXT = ['A3',TARGET,'55']
%                 L = length(cmd_str_NEXT);
%                 c = hex2dec(reshape(cmd_str_NEXT,2,L/2)');
%                 fwrite(obj.Piezo,c);

            %disp(['NEXT is just stop at ']);
            %Fin_LOOP = Pos(obj,1)
        end
          
    end
  
   methods (Static)

        function Initialize(obj)
        %obj.Piezo = serial(obj.Serial_Port);
        %disp(['Now the NPOINT Piezo-electric device is ',obj.Piezo.Status,' .'])
        if strcmp(obj.Piezo.Status,'closed')== 1
            fopen(obj.Piezo);
            disp(['Now the NPOINT Piezo-electric device is ',obj.Piezo.Status,' .'])
        else disp(['The NPOINT Piezo-electric device is already ',obj.Piezo.Status,' .'])
        end
        end

        function RESET_PIEZO(obj)
        address_n=strcat('11831218');
        Write_n=num2str(dec2hex(0,8));
        cmdstr_n=strcat('A2',address_n,Write_n,'55');
        % -- reorder the bytes --
        cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
        L_n = length(cmdstr_n);
        c_n = hex2dec(reshape(cmdstr_n,2,L_n/2)');
        fwrite(obj.Piezo,c_n);
        address_n=strcat('11832218');
        Write_n=num2str(dec2hex(0,8));
        cmdstr_n=strcat('A2',address_n,Write_n,'55');
        % -- reorder the bytes --
        cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
        L_n = length(cmdstr_n);
        c_n = hex2dec(reshape(cmdstr_n,2,L_n/2)');
        fwrite(obj.Piezo,c_n);
        address_n=strcat('11833218');
        Write_n=num2str(dec2hex(0,8));
        cmdstr_n=strcat('A2',address_n,Write_n,'55');
        % -- reorder the bytes --
        cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
        L_n = length(cmdstr_n);
        c_n = hex2dec(reshape(cmdstr_n,2,L_n/2)');
        fwrite(obj.Piezo,c_n);
        end
  
        function Close_Piezo(obj)
        %disp(['Now the NPOINT Piezo-electric device is ',obj.Piezo.Status,' .'])

        fclose(obj.Piezo);
        disp(['Now the NPOINT Piezo-electric device is ',obj.Piezo.Status,' .'])
        end

        function Status(obj)
        %if strcmp(obj.Piezo.Status,'open')== 1
        disp(['The NPOINT Piezo-electric device is actually ',obj.Piezo.Status,' !'])
        return
        %end
        %else  disp(['The NPOINT Piezo-electric device is actually ',obj.Piezo.Status,' .'])
        end


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
