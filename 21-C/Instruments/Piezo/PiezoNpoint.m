classdef PiezoNpoint < handle
    
    properties
        LibraryName             % alias for library loaded
        LibraryFilePath         % path to Madlib.dll
        HeaderFilePath          % path to Madlib.h
        ID
        HighEndOfRange          % in mum
        LowEndOfRange           % in mum
        SampleRate = 1/24e-6  % Sample rate of the Piezo in Hz
        ADCtime                 % in ms
        DAQtime                 % in ms
        StabilizeTime           % Time to wait before starting each ramp for the piezo to stabilize.
        nFlat                   % A flat section at the start of ramp
        nOverRun                % Let the waveform over run the start and end
        
        pause_Time   = 5e-2     % internal waiting time of the Piezo
        Serial_Port  = 'COM10'    % Serial port where the USB is attached
        Piezo
        
        
        LagPts
        totWaveform;
        theorywaveform;
        realwaveform;
        precision %in mum; used for tracking
        
    end
    
    methods
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    BASIC FUNCTIONS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [obj] = PiezoNpoint(LibraryName,LibraryFilePath,HeaderFilePath,ADCtime,DAQtime)
            % instantiation function
            obj.LibraryName = LibraryName;
            obj.LibraryFilePath = LibraryFilePath;
            obj.HeaderFilePath = HeaderFilePath;
            obj.Initialization(ADCtime,DAQtime);
        end
        
        function Connect(obj)
            if strcmp(obj.Piezo.Status,'closed')== 1
                fopen(obj.Piezo);
                disp(['Now the NPOINT Piezo-electric device is ',obj.Piezo.Status,' .'])
            else disp(['The NPOINT Piezo-electric device is already ',obj.Piezo.Status,' .'])
            end
            
        end
        
        function Status(obj)
            %if strcmp(obj.Piezo.Status,'open')== 1
            disp(['The NPOINT Piezo-electric device is actually ',obj.Piezo.Status,' !'])
            return
            %end
            %else  disp(['The NPOINT Piezo-electric device is actually ',obj.Piezo.Status,' .'])
        end
        
        function CloseConnection(obj)
            %disp(['Now the NPOINT Piezo-electric device is ',obj.Piezo.Status,' .'])
            
            fclose(obj.Piezo);
            disp(['Now the NPOINT Piezo-electric device is ',obj.Piezo.Status,' .'])
        end
        
        function Initialization(obj,ADCtime,DAQtime)
            % instantiation function
            %obj.pause_Time = pause_Time;
            %obj.Serial_Port = Serial_Port;
            obj.Piezo= serial(obj.Serial_Port);
            USBTime=1e0; %factor
            obj.Piezo.BaudRate = 115200*USBTime;
            obj.Piezo.InputBufferSize = 4096;
          %  obj.CloseConnection();
       
            obj.Connect;
        end
        
        function p = Pos(obj,axis)
            %query and return position of axis (x=1, y=2, z=3)
            p= READ_axis(obj,axis);
            
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
            clear k_n s_n ret_str_n numBytes out m_n
            address_n=strcat('1183',num2str(axis),'334');
                      
            cmdstr_n=strcat('A0',address_n,'55');
            cmdstr_n = cmdstr_n([1 2 9 10 7 8 5 6 3 4 11 12]);
            l_n = length(cmdstr_n);
            c_n = hex2dec(reshape(cmdstr_n,2,l_n/2)');
            fwrite(obj.Piezo,c_n);
            pause(obj.pause_Time);  %%%%%%%%%%%%%%%%%% PAUSE
            numBytes = obj.Piezo.BytesAvailable;
            
            if numBytes==0
                numBytes=20;
            end
            
            ret_str_n = fread(obj.Piezo,numBytes);
           
            pause(obj.pause_Time);  %%%%%%%%%%%%%%%%%% PAUSE
            %pause(5e-1);
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
        
        function Mov(obj, Move_n, axis)
            %absolute change in position (pos) of axis (x=1, y=2, z=3)
            
            Flag_Error=0;
            switch(axis)
                case {1,2}
                    Move_n=Move_n-50;
                    if ((Move_n<=50)&&(Move_n>=-50)) Move_n= round(Move_n*1048574/100);
                    else
                        %warning('What the HELL do you think you are doing mate? You are exceeding the X or Y axis!');
                        Flag_Error=1;
                    end
                case 3
                    Move_n=Move_n-10;
                    if ((Move_n<=10)&&(Move_n>=-10)) Move_n= round(Move_n*1048574/20);
                    else
                        %warning('What the HELL do you think you are doing mate? You are exceeding the Z axis!');
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        
        
        
         
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    WAVEFORM     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
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
            
            address_INDEX=strcat('1183',num2str(axis),'1F8');
            Write_INDEX=num2str(dec2hex(INDEX,8));
            cmdstr_INDEX=strcat('A2',address_INDEX,Write_INDEX,'55');% -- reorder the bytes --
            cmdstr_INDEX = cmdstr_INDEX([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_INDEX = length(cmdstr_INDEX);
            c_INDEX = hex2dec(reshape(cmdstr_INDEX,2,L_INDEX/2)');
            fwrite(obj.Piezo,c_INDEX);
            % pause(obj.pause_Time);
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTL Functions   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
        function TTL_INPUT = TTL_INPUT(obj,pin_TTL_INPUT,axis)
            %
            %  Offsets
            %  Offset= 094 in case of x  axis, axis=1,
            %  Offset= 098 in case of y  axis, axis=2,
            %  Offset= 09C in case of z  axis, axis=3
            %
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
         
          switch(axis)
                case 1
                    add_TTL_INPUT=hex2dec(strcat('1183',num2str(axis),'094'));
                case 2
                    add_TTL_INPUT=hex2dec(strcat('1183',num2str(axis),'098'));
                case 3
                    add_TTL_INPUT=hex2dec(strcat('1183',num2str(axis),'09C'));
                otherwise
                    warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
          end
            
         address_TTL_INPUT= dec2hex(add_TTL_INPUT);
         Write_TTL_INPUT=num2str(dec2hex(pin_TTL_INPUT,8));
         cmdstr_TTL_INPUT=strcat('A2',address_TTL_INPUT,Write_TTL_INPUT,'55');
         cmdstr_TTL_INPUT = cmdstr_TTL_INPUT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_TTL_INPUT = length(cmdstr_TTL_INPUT);
         c_TTL_INPUT = hex2dec(reshape(cmdstr_TTL_INPUT,2,L_TTL_INPUT/2)');
         fwrite(obj.Piezo,c_TTL_INPUT);
        end
        
        function TTL_INPUT_POLARITY = TTL_INPUT_POLARITY(obj,pin_INPUT_POLARITY,axis)
            %
            % Offsets
            %  Offset= 0B4 in case of x  axis, axis=1,
            %  Offset= 0B8 in case of y  axis, axis=2,
            %  Offset= 0BC in case of z  axis, axis=3
            %
            % DataType= 32 Bit Integer
            %
            % Specifies the polarity for pin 1 of
            % the TTL I/O connector. Note that if the user wants multiple
            % channels to have a function for TTL Input Pin 1 with the same
            % polarity, the polarity must be programmed for each channel individually.
            % 0 = Rising Edge/Active High
            % 1 = Falling Edge/ Active Low
            %
            
            switch(axis)
                case 1
                    add_INPUT_POLARITY=hex2dec(strcat('1183',num2str(axis),'0B4'));
                case 2
                    add_INPUT_POLARITY=hex2dec(strcat('1183',num2str(axis),'0B8'));
                case 3
                    add_INPUT_POLARITY=hex2dec(strcat('1183',num2str(axis),'0BC'));
                otherwise
                    warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
            end
            
            address_INPUT_POLARITY= dec2hex(add_INPUT_POLARITY);
            %x=round(x*1048574/100)
            Write_INPUT_POLARITY=num2str(dec2hex(pin_INPUT_POLARITY,8));
            cmdstr_INPUT_POLARITY=strcat('A2',address_INPUT_POLARITY,Write_INPUT_POLARITY,'55');
            cmdstr_INPUT_POLARITY = cmdstr_INPUT_POLARITY([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_INPUT_POLARITY = length(cmdstr_INPUT_POLARITY);
            c_INPUT_POLARITY = hex2dec(reshape(cmdstr_INPUT_POLARITY,2,L_INPUT_POLARITY/2)');
            fwrite(obj.Piezo,c_INPUT_POLARITY);
        end
        
        function TTL_OUTPUT_POLARITY = TTL_OUTPUT_POLARITY(obj,pin_OUTPUT_POLARITY,axis)
            %
            %  Specifies the polarity for Pin 6-9
            % of the TTL I/O connector. Note that if the user wants multiple
            % channels to have a function for TTL Input Pin 1 with the same
            % polarity, the polarity must be programmed for each channel individually.
            % 0 = Rising Edge/Active High
            % 1 = Falling Edge/ Active Low
            %  Offsets
            %  Offset= 114 in case of x  axis, axis=1,
            %  Offset= 118 in case of y  axis, axis=2,
            %  Offset= 11C in case of z  axis, axis=3
            %  Offset= 120 in case of CLOCK,   axis=4
            % DataType= 32 Bit Integer
         
         switch(axis)
                case 1
                    add_OUTPUT=hex2dec(strcat('1183',num2str(axis),'114'));
                case 2
                    add_OUTPUT=hex2dec(strcat('1183',num2str(axis),'118'));
                case 3
                     add_OUTPUT=hex2dec(strcat('1183',num2str(axis),'11C'));
                case 4
                     add_OUTPUT=hex2dec(strcat('1183',num2str(axis),'120'));
                otherwise
                    warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
            end
            
         address_OUTPUT_POLARITY= dec2hex(add_OUTPUT);
         Write_OUTPUT_POLARITY=num2str(dec2hex(pin_OUTPUT_POLARITY,8));
         cmdstr_OUTPUT_POLARITY=strcat('A2',address_OUTPUT_POLARITY,Write_OUTPUT_POLARITY,'55');
         cmdstr_OUTPUT_POLARITY = cmdstr_OUTPUT_POLARITY([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_OUTPUT_POLARITY = length(cmdstr_OUTPUT_POLARITY);
         c_OUTPUT_POLARITY = hex2dec(reshape(cmdstr_OUTPUT_POLARITY,2,L_OUTPUT_POLARITY/2)');
         fwrite(obj.Piezo,c_OUTPUT_POLARITY);
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
         
        function TTL_OUTPUT = TTL_OUTPUT(obj,pin_OUTPUT,axis)
            % TTL Output Pin 6 Function 
            % Offsets
            %  Offset= 0F4 in case of x  axis, axis=1,
            %  Offset= 0F8 in case of y  axis, axis=2,
            %  Offset= 0FC in case of z  axis, axis=3,
            % DataType= 32 Bit Integer
            %
            % Specifies the output type for
            % pin 1 of the TTL I/O connector. An output pin should typically
            % only have a function other than None for one channel at a time.
            % 0 = None
            % 1 = Control Loop Error
            % 2 = Waveform Index Level
            % 3 = Waveform Index Pulse
            % 4 = General Fault
            % 5 = Waveform Index Clock
           
                 
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
         Write_OUTPUT=num2str(dec2hex(pin_OUTPUT,8));
         cmdstr_OUTPUT=strcat('A2',address_OUTPUT,Write_OUTPUT,'55');
         cmdstr_OUTPUT = cmdstr_OUTPUT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_OUTPUT = length(cmdstr_OUTPUT);
         c_OUTPUT = hex2dec(reshape(cmdstr_OUTPUT,2,L_OUTPUT/2)');
         fwrite(obj.Piezo,c_OUTPUT);   
        end
        
        function TTL_OUTPUT_CLOCK = TTL_OUTPUT_CLOCK(obj,pin_OUTPUT,axis)
            % TTL Output Pin 6 Function 
            % Offsets
            %  Offset= 100 in case of CLOCK,   
            % DataType= 32 Bit Integer
            %
            % Specifies the output type for
            % pin 9 of the TTL I/O connector. An output pin should typically
            % only have a function other than None for one channel at a time.
            % 0 = None
            % 1 = Control Loop Error
            % 2 = Waveform Index Level
            % 3 = Waveform Index Pulse
            % 4 = General Fault
            % 5 = Waveform Index Clock
       
         add_OUTPUT_CLOCK=hex2dec(strcat('1183',num2str(axis),'100'));
         address_OUTPUT_CLOCK= dec2hex(add_OUTPUT_CLOCK);
         Write_OUTPUT_CLOCK=num2str(dec2hex(pin_OUTPUT,8));
         cmdstr_OUTPUT_CLOCK=strcat('A2',address_OUTPUT_CLOCK,Write_OUTPUT_CLOCK,'55');
         cmdstr_OUTPUT_CLOCK = cmdstr_OUTPUT_CLOCK([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_OUTPUT_CLOCK = length(cmdstr_OUTPUT_CLOCK);
         c_OUTPUT_CLOCK = hex2dec(reshape(cmdstr_OUTPUT_CLOCK,2,L_OUTPUT_CLOCK/2)');
         fwrite(obj.Piezo,c_OUTPUT_CLOCK);   
        end
        
        function TTL_OUTPUT_POLARITY_CLOCK = TTL_OUTPUT_POLARITY_CLOCK(obj,pin_OUTPUT_POLARITY,axis)
            %
            %  Specifies the polarity for Pin 6-9
            % of the TTL I/O connector. Note that if the user wants multiple
            % channels to have a function for TTL Input Pin 1 with the same
            % polarity, the polarity must be programmed for each channel individually.
            % 0 = Rising Edge/Active High
            % 1 = Falling Edge/ Active Low
            %  Offset
            %  Offset= 120 in case of CLOCK
            % DataType= 32 Bit Integer
         
         add_OUTPUT_POLARITY_CLOCK=hex2dec(strcat('1183',num2str(axis),'120'));
         address_OUTPUT_POLARITY_CLOCK= dec2hex(add_OUTPUT_POLARITY_CLOCK);
         Write_OUTPUT_POLARITY_CLOCK=num2str(dec2hex(pin_OUTPUT_POLARITY,8));
         cmdstr_OUTPUT_POLARITY_CLOCK=strcat('A2',address_OUTPUT_POLARITY_CLOCK,Write_OUTPUT_POLARITY_CLOCK,'55');
         cmdstr_OUTPUT_POLARITY_CLOCK = cmdstr_OUTPUT_POLARITY_CLOCK([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_OUTPUT_POLARITY_CLOCK = length(cmdstr_OUTPUT_POLARITY_CLOCK);
         c_OUTPUT_POLARITY_CLOCK = hex2dec(reshape(cmdstr_OUTPUT_POLARITY_CLOCK,2,L_OUTPUT_POLARITY_CLOCK/2)');
         fwrite(obj.Piezo,c_OUTPUT_POLARITY_CLOCK);
        end
        
        function TTL_OUTPUT_LOW_INDEX_CLOCK = TTL_OUTPUT_LOW_INDEX_CLOCK(obj,x,axis)
            %
            % Offset= 0x19C
            % DataType= 32 Bit Integer
            % TTL Output Low Index Array Base Offset – The base offset
            % for an array of up to 16 waveform indexes. At the specified
            % indexes, an output set to type Waveform Index Level will transition
            % to level low. At the specified indexes an output function
            % set to type Waveform Index Pulse will output a single pulse.
         
         add_START=hex2dec(strcat('1183',num2str(axis),'19C'));
         address_START= dec2hex(add_START);
         Write_START=num2str(dec2hex(x,8));
         cmdstr_START=strcat('A2',address_START,Write_START,'55');
         cmdstr_START = cmdstr_START([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_START = length(cmdstr_START);
         c_START = hex2dec(reshape(cmdstr_START,2,L_START/2)');
         fwrite(obj.Piezo,c_START);
        end
        
        function TTL_OUTPUT_HIGH_INDEX_CLOCK = TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,x,axis)
            %
            % Offset= 0x15C
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SENSOR Functions  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function SENSOR_PULSE_SPACING = SENSOR_PULSE_SPACING(obj,x,axis)
            %
            % Offset= 0xC60
            % DataType= 32 Bit Integer
            % This specifies how far apart the pulses should be.  
            % Value is in 20 bit counts.  To scale from microns to counts 
            % use this equation:  counts = spacingInMicrons * countsPerMicron * DIScaleFactor
         
         add_SPACING=hex2dec(strcat('1183',num2str(axis),'C60'));
         address_SPACING= dec2hex(add_SPACING);
         Write_SPACING=num2str(dec2hex(x,8));
         cmdstr_SPACING=strcat('A2',address_SPACING,Write_SPACING,'55');
         cmdstr_SPACING = cmdstr_SPACING([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_SPACING = length(cmdstr_SPACING);
         c_SPACING = hex2dec(reshape(cmdstr_SPACING,2,L_SPACING/2)');
         fwrite(obj.Piezo,c_SPACING);
         end      
        
        function SENSOR_PULSE_OFFSET = SENSOR_PULSE_OFFSET(obj,x,axis)
            %
            % Offset= 0xC64
            % DataType= 32 Bit Integer
            % This specifies the offset when the pulses start.  
            % Value is in 20 bit counts.  To scale from microns to counts 
            % use this equation: 
            % counts = spacingInMicrons * countsPerMicron * DIScaleFactor
             
         add_OFFSET=hex2dec(strcat('1183',num2str(axis),'C64'));
         address_OFFSET= dec2hex(add_OFFSET);
         Write_OFFSET=num2str(dec2hex(x,8));
         cmdstr_OFFSET=strcat('A2',address_OFFSET,Write_OFFSET,'55');
         cmdstr_OFFSET = cmdstr_OFFSET([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_OFFSET = length(cmdstr_OFFSET);
         c_OFFSET = hex2dec(reshape(cmdstr_OFFSET,2,L_OFFSET/2)');
         fwrite(obj.Piezo,c_OFFSET);
        end      
       
        function SENSOR_PULSE_NUMBER = SENSOR_PULSE_NUMBER(obj,x,axis)
            %
            % Offset= 0xC68
            % DataType= 32 Bit Integer
            % This specifies the the total numbe rof pulses 
            
         add_NUMBER=hex2dec(strcat('1183',num2str(axis),'C68'));
         address_NUMBER= dec2hex(add_NUMBER);
         Write_NUMBER=num2str(dec2hex(x,8));
         cmdstr_NUMBER=strcat('A2',address_NUMBER,Write_NUMBER,'55');
         cmdstr_NUMBER = cmdstr_NUMBER([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_NUMBER = length(cmdstr_NUMBER);
         c_NUMBER = hex2dec(reshape(cmdstr_NUMBER,2,L_NUMBER/2)');
         fwrite(obj.Piezo,c_NUMBER);
        end    
        
        function SENSOR_PULSE_CALCULATION = SENSOR_PULSE_CALCULATION(obj,x,axis)
            %
            % Offset= 0xC6c
            % DataType= 32 Bit Integer
            % This value must be set to zero after 
            % any of the above parameters are changed (every time they are changed). 
            
         add_CALCULATION=hex2dec(strcat('1183',num2str(axis),'C6C'));
         address_CALCULATION= dec2hex(add_CALCULATION);
         Write_CALCULATION=num2str(dec2hex(x,8));
         cmdstr_CALCULATION=strcat('A2',address_CALCULATION,Write_CALCULATION,'55');
         cmdstr_CALCULATION = cmdstr_CALCULATION([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
         L_CALCULATION = length(cmdstr_CALCULATION);
         c_CALCULATION = hex2dec(reshape(cmdstr_CALCULATION,2,L_CALCULATION/2)');
         fwrite(obj.Piezo,c_CALCULATION);
        end    
        
        
        
        function COUNTS_PER_MICRON = COUNTS_PER_MICRON(obj,axis)
        
            %Counts per micron = 1048574/axis range in microns
                 
            if (axis==3) 
                COUNTS_PER_MICRON=1048574*20; % value rescaled for Z-axis
            else COUNTS_PER_MICRON=1048574*100;        % value rescaled for X & Y axis
            end
            return
        end
        
        
        function DI_SCALE_FACTOR = DI_SCALE_FACTOR(obj,axis)
        
            %
            % Offset= 0x22C
            % DataType= 32 bit floating point
            %
            % Value used to scale position input commands.  
            % Calibrated with a laser interferometer.  
            % Be sure to only ever read this value, 
            % it should not be written with a new value.
            
            address_FACTOR=strcat('1183',num2str(axis),'22C');
                      
            cmdstr_FACTOR=strcat('A0',address_FACTOR,'55');
            cmdstr_FACTOR = cmdstr_FACTOR([1 2 9 10 7 8 5 6 3 4 11 12]);
            l_FACTOR = length(cmdstr_FACTOR);
            c_FACTOR = hex2dec(reshape(cmdstr_FACTOR,2,l_FACTOR/2)');
            fwrite(obj.Piezo,c_FACTOR);
            pause(obj.pause_Time);  %%%%%%%%%%%%%%%%%% PAUSE
            numBytes = obj.Piezo.BytesAvailable;
            ret_str_FACTOR = fread(obj.Piezo,numBytes);
            pause(obj.pause_Time);  %%%%%%%%%%%%%%%%%% PAUSE
            %pause(5e-1);
            [m_FACTOR,n_FACTOR] = size(address_FACTOR);
            k_FACTOR = reshape(ret_str_FACTOR,10,m_FACTOR);
            s_FACTOR = k_FACTOR(:,1);
            s_FACTOR = dec2hex(s_FACTOR);
            s_FACTOR = reshape(s_FACTOR',1,20);
            s_FACTOR = s_FACTOR(11:18);
            s_FACTOR=s_FACTOR([7 8 5 6 3 4 1 2]);
            % we need to scale out the value and take in consideration the
            % negative values
            
            out_FACTOR=hex2dec(s_FACTOR);
            
            if (axis==3) DI_SCALE_FACTOR=(out_FACTOR/1048574*20)+10; % value rescaled for Z-axis
            else DI_SCALE_FACTOR=(out_FACTOR/1048574*100)+50;        % value rescaled for X & Y axis
            end
            return
        end
        
         
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SCAN Functions  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
        
        function Scan_original(obj, X,Y,Z, TPixel, ramp_axis) %1d scan
            % TPixel: Pixel time (set by user, in Imaging: it is the dwell)
            % X, Y, Z: arrays of the points that are scanned, only one should be an array (corresponding to the ramp_axis), the others should be constants single values
            % ramp_axis: values: 1,2,3, defines the direction of the scan
            % nFlat (nb of points): A flat section at the start of ramp
            % nOverRun (nb of points): Let the waveform over run the start and end
%             disp('SCAN')
%             tic
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
           % smooth_ramp = linspace(init_pos,fin_pos,416);
            
            
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
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % RESET
           
            n_points=size(obj.totWaveform,2);
            size(smooth_ramp,2);
            
            time_wave=n_points*24e-6;
            
            WAVETABLE_INDEX(obj,0,ramp_axis);
            WAVETABLE_CYCLE_DELAY(obj,0,ramp_axis);
%             WAVETABLE_ACTIVE(obj,0,ramp_axis);
%             WAVETABLE_ENABLE(obj,0,ramp_axis);        
            

            
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
                    
            switch(ramp_axis)
                case 1
                    NEXT_X(obj);
                case 2
                    NEXT_Y(obj);
                case 3
                    NEXT_Z(obj);
                otherwise
                    warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
            end
            
 
              
            %%%%%%% NEW TTL COMMANDS 
            %%%%%%% these commands allow you to control the waveforms, when
            %%%%%%% and where they are supposed to start and stop
            %%%%%%%
            
            TTL_INPUT(obj,7,ramp_axis);                % set level trigger pause/resume
            TTL_INPUT_POLARITY(obj,0,ramp_axis);       %set the waveform input polarity to rising edge
            TTL_OUTPUT(obj,2,ramp_axis);               %set the waveform index level to rising edge/active high
            TTL_OUTPUT_POLARITY(obj,0,ramp_axis);      %set the waveform output polarity to rising edge
            TTL_OUTPUT_ACTIVE_PAIRS(obj,1,ramp_axis);  %set output indexes on 1 active pairs
            TTL_START(obj,0,ramp_axis)                 % set the initial index value
            TTL_STOP(obj,n_points-3,ramp_axis)         % set the final index value, basically where you want the Piezo stops!
            
            
            WAVETABLE_END_INDEX(obj,n_points-1,ramp_axis);
            WAVETABLE_ENABLE(obj,1,ramp_axis);
            WAVETABLE_ACTIVE(obj,1,ramp_axis);
            pause(1e-2);
            WAVETABLE_ENABLE(obj,0,ramp_axis);
            
%             obj.theorywaveform = WaveformPtr.Value((obj.nFlat+obj.nOverRun+1):2*n:(obj.nFlat+obj.nOverRun+nRamp));  %or NX*2*n
%             obj.realwaveform = WaveformReadPtr.Value((obj.nFlat+obj.nOverRun+1+obj.LagPts):2*n:(obj.nFlat+obj.nOverRun+nRamp+obj.LagPts));  %or NX*2*n
% toc
        end
        
        function COOL_Scan(obj, X,Y,Z, time) %1d scan
           
            points{1} = X;
            points{2} = Y;
            points{3} = Z;
            
            
           
            obj.Mov(X(1),1);
            obj.Mov(Y(1),2);
            obj.Mov(Z(1),3);
            pause(time); 
%             
%             N = length(points{ramp_axis});
%             
%             piezo_sampletime=24e-6; %this is the sample rate of the piezo
%             
%             waveform_per_point=TPixel; %This is the amount of time to spend per spatial point. This is just the dwell time.
%             number_of_waveform_per_point = ceil(waveform_per_point/piezo_sampletime); %This is the number of points of the waveform per spatial point
%             spatial_ramp =  linspace(init_pos,fin_pos,N);
%             waveform=[];
%             for j=1:size(spatial_ramp,2)
%                 waveform =  [waveform spatial_ramp(j)*ones(1,number_of_waveform_per_point)];
%             end
%                    
%             obj.totWaveform =waveform;
%             
%             n_points=size(obj.totWaveform,2);
%             
            %%%%%%% Send to piezo
%             WAVETABLE_INDEX(obj,0,ramp_axis);
%             WAVETABLE_CYCLE_DELAY(obj,0,ramp_axis);
%         
%             switch(ramp_axis)
%                 case 1
%                     NEXT_X(obj);
%                 case 2
%                     NEXT_Y(obj);
%                 case 3
%                     NEXT_Z(obj);
%                 otherwise
%                     warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
%             end
%             
            %%%%%%% Send to piezo
            
%             TTL_INPUT(obj,7,ramp_axis);                % set level trigger pause/resume
%             TTL_INPUT_POLARITY(obj,0,ramp_axis);       %set the waveform input polarity to rising edge
%             TTL_OUTPUT(obj,2,ramp_axis);               %set the waveform index level to rising edge/active high
%             TTL_OUTPUT_POLARITY(obj,0,ramp_axis);      %set the waveform output polarity to rising edge
%             TTL_OUTPUT_ACTIVE_PAIRS(obj,1,ramp_axis);  %set output indexes on 1 active pairs
%             TTL_START(obj,0,ramp_axis)                 % set the initial index value
%             TTL_STOP(obj,n_points-3,ramp_axis)         % set the final index value, basically where you want the Piezo stops!
%             
%             
%             WAVETABLE_END_INDEX(obj,n_points-1,ramp_axis);
%             WAVETABLE_ENABLE(obj,1,ramp_axis);
%             WAVETABLE_ACTIVE(obj,1,ramp_axis);
%             pause(piezo_sampletime*n_points);
%             WAVETABLE_ENABLE(obj,0,ramp_axis);
            
        end
      
        function [n_points, piezo_sampletime]= Scan(obj, X,Y,Z, TPixel, axis) %1d scan
           
            points{1} = X;
            points{2} = Y;
            points{3} = Z;
            
            init_pos=points{axis}(1);
            fin_pos=points{axis}(end);
            delta=init_pos;
           
            obj.Mov(X(1),1);
            obj.Mov(Y(1),2);
            obj.Mov(Z(1),3);
            pause(obj.StabilizeTime); 
%             
            N = length(points{axis});
            
            piezo_sampletime=24e-6; %this is the sample rate of the piezo
            
            
            % ASHOK WAVEFORM
            %%%%%%%%%%%%%%%% 
            %
            waveform_per_point=TPixel; %This is the amount of time to spend per spatial point. This is just the dwell time.
            number_of_waveform_per_point = ceil(waveform_per_point/piezo_sampletime); %This is the number of points of the waveform per spatial point
            
            spatial_ramp =  linspace(init_pos,fin_pos,N);
            waveform=[];
            for j=1:size(spatial_ramp,2)
                waveform =  [waveform spatial_ramp(j)*ones(1,number_of_waveform_per_point)];
            end
                   
            obj.totWaveform =waveform;
            %obj.totWaveform =spatial_ramp;
            
            %%%END ASHOK WAVEFORM
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             
                     
            
%             
%             % CLARICE WAVEFORM
%             %%%%%%%%%%%%%%%% 
%             %
%             %As explained in ImagingFunctions' StartScan1D function, in
%             %the original code the function below was round, but this gave
%             %an error - changed to ceil
%             n = ceil(TPixel*obj.SampleRate);
%             %n=ceil(n/2);
%             % Total waveform points in the ramp
%             nRamp = N*2*n;
%             %PC: We acquire two points for every calculated/displayed point.
%             % Also, apparently, if we set a dwell time longer than 1/SampleRate we do not sit at the same point
%             % for all that time, but subdivide the interval in smaller steps.
%             % Not sure if this is a good solution.
%             % CDA: yes it is a good solution bc we want that the piezo be
%             % moving with a constant speed. It is *not* a good idea to
%             % program a "stair-like" waveform; if we increase the dwell
%             % time, what we are in fact doing is making the scan ramp less
%             % and less steep by acquiring more points (as pointed out
%             % above, by subdividing the interval in smaller steps).
%             
%             % points in the waveform to be written to piezo
%             nWaveform = obj.nFlat + obj.nOverRun + nRamp + obj.nOverRun;
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % New Ramping Mechanism
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             % take first two points and calculate the increment per point including the dwell time (n)
%             incr = (fin_pos-init_pos)/(nRamp-2*n);
%             % the initial smooth starting ramp
%             smooth_ramp=(init_pos-(2*n-1)*incr/2-incr*obj.nOverRun)+incr*obj.nOverRun*(1-cos(pi/4/(obj.nFlat+obj.nOverRun)*(0:obj.nFlat+obj.nOverRun-1)))/(1-cos(pi/4));
%             % the ramp over the scanning points including the overun points at the end
%             scan_ramp = (init_pos-(2*n-1)*incr/2):incr:(fin_pos + (2*n-1)*incr/2 + incr*obj.nOverRun);
%             % connect both ramps
%             smooth_ramp = [smooth_ramp scan_ramp];
%            % smooth_ramp = linspace(init_pos,fin_pos,416);
%             
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % Coerce Waveform
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             obj.totWaveform =smooth_ramp;
%             for k=1:1:length(obj.totWaveform)
%                 if obj.totWaveform(k) < obj.LowEndOfRange(1)
%                     obj.totWaveform(k) = obj.LowEndOfRange(1);
%                 elseif obj.totWaveform(k) > obj.HighEndOfRange(1)
%                     obj.totWaveform(k) = obj.HighEndOfRange(1);
%                 end
%             end
%             %%%END
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
            
            n_points=size(obj.totWaveform,2);
            
            
        
            switch(axis)
                case 1
                    NEXT_X(obj,delta);
                case 2
                    NEXT_Y(obj,delta);
                case 3
                    NEXT_Z(obj,delta);
                otherwise
                    warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
            end
            Trigg(obj, X,Y,Z, TPixel, axis,n_points) ;
%             
%             %%%%%%% Send to piezo
%             WAVETABLE_INDEX(obj,0,ramp_axis);
%             WAVETABLE_CYCLE_DELAY(obj,0,ramp_axis);
%             %%%%%%% Send to piezo
%             
%             TTL_INPUT(obj,7,ramp_axis);                      %set level trigger pause/resume
%             TTL_INPUT_POLARITY(obj,0,ramp_axis);             %set the waveform input polarity to rising edge
%             TTL_OUTPUT(obj,2,ramp_axis);                     %set the waveform index level to rising edge/active high
%             %%%%%%%%%  CLOCK
%             TTL_OUTPUT_CLOCK(obj,5,ramp_axis);               %set the pin 9 OUTPUT to  WAVEFORM INDEX CLOCK
%             TTL_OUTPUT_POLARITY_CLOCK(obj,0,ramp_axis);      %set the waveform CLOCK polarity to rising edge
%             %%%%%%%%
%             TTL_OUTPUT_POLARITY(obj,0,ramp_axis);            %set the waveform output polarity to rising edge
%             TTL_OUTPUT_ACTIVE_PAIRS(obj,1,ramp_axis);        %set output indexes on 1 active pairs
%             TTL_OUTPUT_LOW_INDEX_CLOCK(obj,0,ramp_axis)   %set the initial index value
%             TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,n_points-3,ramp_axis)  %set the final index value, basically where you want the Piezo stops!
%             
%             
%             WAVETABLE_END_INDEX(obj,n_points-1,ramp_axis);
% %             WAVETABLE_ENABLE(obj,1,ramp_axis);
% %             WAVETABLE_ACTIVE(obj,1,ramp_axis);
% %             pause(piezo_sampletime*n_points);
% %             WAVETABLE_ENABLE(obj,0,ramp_axis);
%             
        end
      
        function [n_points, piezo_sampletime]= Trigg(obj, X,Y,Z, TPixel, axis,n_points) %1d scan
           
            points{1} = X;
            points{2} = Y;
            points{3} = Z;
            
%             init_pos=points{ramp_axis}(1);
%             fin_pos=points{ramp_axis}(end);
%            
            obj.Mov(X(1),1);
            obj.Mov(Y(1),2);
            obj.Mov(Z(1),3);
            pause(obj.StabilizeTime); 
            
%             N = length(points{ramp_axis});
%             
            
%             waveform_per_point=TPixel; %This is the amount of time to spend per spatial point. This is just the dwell time.
%             number_of_waveform_per_point = ceil(waveform_per_point/piezo_sampletime); %This is the number of points of the waveform per spatial point
%             spatial_ramp =  linspace(init_pos,fin_pos,N);
%             waveform=[];
%             for j=1:size(spatial_ramp,2)
%                 waveform =  [waveform spatial_ramp(j)*ones(1,number_of_waveform_per_point)];
%             end
%                    
%             obj.totWaveform =waveform;
            
            %n_points=size(obj.totWaveform,2);
            
            %C=obj.COUNTS_PER_MICRON(axis);
            %D=DI_SCALE_FACTOR(obj,axis);
             piezo_sampletime=24e-6; %this is the sample rate of the piezo
            %%%%%%% Send to piezo
            WAVETABLE_INDEX(obj,0,axis);
            
            WAVETABLE_CYCLE_DELAY(obj,0,axis);
%         
%             switch(ramp_axis)
%                 case 1
%                     NEXT_X(obj);
%                 case 2
%                     NEXT_Y(obj);
%                 case 3
%                     NEXT_Z(obj);
%                 otherwise
%                     warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
%             end
            
            %%%%%%% Send to piezo
            
            TTL_INPUT(obj,7,axis);                      %set level trigger pause/resume
            TTL_INPUT_POLARITY(obj,0,axis);             %set the waveform input polarity to rising edge
            TTL_OUTPUT(obj,2,axis);                     %set the waveform index level to rising edge/active high
            %%%%%%%%%  CLOCK
            TTL_OUTPUT_CLOCK(obj,5,axis);               %set the pin 9 OUTPUT to  WAVEFORM INDEX CLOCK
            TTL_OUTPUT_POLARITY_CLOCK(obj,0,axis);      %set the waveform CLOCK polarity to rising edge
            %%%%%%%%
            TTL_OUTPUT_POLARITY(obj,0,axis);            %set the waveform output polarity to rising edge
            TTL_OUTPUT_ACTIVE_PAIRS(obj,1,axis);        %set output indexes on 1 active pairs
            %TTL_OUTPUT_ACTIVE_PAIRS(obj,2,ramp_axis);        %set output indexes on 1 active pairs
            
            %TTL_OUTPUT_LOW_INDEX_CLOCK(obj,ceil(n_points*0.2),ramp_axis)   %set the initial index value 
            TTL_OUTPUT_LOW_INDEX_CLOCK(obj,0,axis)   %set the initial index value
            TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,n_points-3,axis)  %set the final index value, basically where you want the Piezo stops!
           
         %   TTL_OUTPUT_LOW_INDEX_CLOCK(obj,200,ramp_axis)   %set the initial index value
          % TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,1000,ramp_axis)  %set the final index value, basically where you want the Piezo stops!
            %TTL_OUTPUT_LOW_INDEX_CLOCK(obj,10,ramp_axis)   %set the initial index value
            %TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,n_points-3,ramp_axis)  %set the final index value, basically where you want the Piezo stops!
            
           %TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,n_points,ramp_axis)  %set the final index value, basically where you want the Piezo stops!
            
            
           WAVETABLE_END_INDEX(obj,n_points-1,axis); %2/19
%             WAVETABLE_ENABLE(obj,1,ramp_axis);
%             WAVETABLE_ACTIVE(obj,1,ramp_axis);
%             pause(piezo_sampletime*n_points);
%             WAVETABLE_ENABLE(obj,0,ramp_axis);
            
        end
      
        
        
        
         function [n_points, piezo_sampletime]= Scan_act(obj, X,Y,Z, TPixel, axis) %1d scan
           
            points{1} = X;
            points{2} = Y;
            points{3} = Z;
            
            init_pos=points{axis}(1);
            fin_pos=points{axis}(end);
            delta=init_pos;
           
            obj.Mov(X(1),1);
            obj.Mov(Y(1),2);
          %  obj.Mov(Z(1),3);
            pause(obj.StabilizeTime); 
%             
            N = length(points{axis});
            
            piezo_sampletime=24e-6; %this is the sample rate of the piezo
            
            
            % ASHOK WAVEFORM
            %%%%%%%%%%%%%%%% 
            %
            waveform_per_point=TPixel; %This is the amount of time to spend per spatial point. This is just the dwell time.
            number_of_waveform_per_point = ceil(waveform_per_point/piezo_sampletime); %This is the number of points of the waveform per spatial point
            
            spatial_ramp =  linspace(init_pos,fin_pos,N);
            waveform=[];
            for j=1:size(spatial_ramp,2)
                waveform =  [waveform spatial_ramp(j)*ones(1,number_of_waveform_per_point)];
            end
                   
            obj.totWaveform =waveform;
            %obj.totWaveform =spatial_ramp;
            
            %%%END ASHOK WAVEFORM
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             
                     
            
%             
%             % CLARICE WAVEFORM
%             %%%%%%%%%%%%%%%% 
%             %
%             %As explained in ImagingFunctions' StartScan1D function, in
%             %the original code the function below was round, but this gave
%             %an error - changed to ceil
%             n = ceil(TPixel*obj.SampleRate);
%             %n=ceil(n/2);
%             % Total waveform points in the ramp
%             nRamp = N*2*n;
%             %PC: We acquire two points for every calculated/displayed point.
%             % Also, apparently, if we set a dwell time longer than 1/SampleRate we do not sit at the same point
%             % for all that time, but subdivide the interval in smaller steps.
%             % Not sure if this is a good solution.
%             % CDA: yes it is a good solution bc we want that the piezo be
%             % moving with a constant speed. It is *not* a good idea to
%             % program a "stair-like" waveform; if we increase the dwell
%             % time, what we are in fact doing is making the scan ramp less
%             % and less steep by acquiring more points (as pointed out
%             % above, by subdividing the interval in smaller steps).
%             
%             % points in the waveform to be written to piezo
%             nWaveform = obj.nFlat + obj.nOverRun + nRamp + obj.nOverRun;
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % New Ramping Mechanism
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             % take first two points and calculate the increment per point including the dwell time (n)
%             incr = (fin_pos-init_pos)/(nRamp-2*n);
%             % the initial smooth starting ramp
%             smooth_ramp=(init_pos-(2*n-1)*incr/2-incr*obj.nOverRun)+incr*obj.nOverRun*(1-cos(pi/4/(obj.nFlat+obj.nOverRun)*(0:obj.nFlat+obj.nOverRun-1)))/(1-cos(pi/4));
%             % the ramp over the scanning points including the overun points at the end
%             scan_ramp = (init_pos-(2*n-1)*incr/2):incr:(fin_pos + (2*n-1)*incr/2 + incr*obj.nOverRun);
%             % connect both ramps
%             smooth_ramp = [smooth_ramp scan_ramp];
%            % smooth_ramp = linspace(init_pos,fin_pos,416);
%             
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % Coerce Waveform
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             obj.totWaveform =smooth_ramp;
%             for k=1:1:length(obj.totWaveform)
%                 if obj.totWaveform(k) < obj.LowEndOfRange(1)
%                     obj.totWaveform(k) = obj.LowEndOfRange(1);
%                 elseif obj.totWaveform(k) > obj.HighEndOfRange(1)
%                     obj.totWaveform(k) = obj.HighEndOfRange(1);
%                 end
%             end
%             %%%END
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
            
            n_points=size(obj.totWaveform,2);
            
            
        
            switch(axis)
                case 1
                    NEXT_X(obj,delta);
                case 2
                    NEXT_Y(obj,delta);
                case 3
                    NEXT_Z(obj,delta);
                otherwise
                    warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
            end
            Trigg(obj, X,Y,Z, TPixel, axis,n_points) ;
%             
%             %%%%%%% Send to piezo
%             WAVETABLE_INDEX(obj,0,ramp_axis);
%             WAVETABLE_CYCLE_DELAY(obj,0,ramp_axis);
%             %%%%%%% Send to piezo
%             
%             TTL_INPUT(obj,7,ramp_axis);                      %set level trigger pause/resume
%             TTL_INPUT_POLARITY(obj,0,ramp_axis);             %set the waveform input polarity to rising edge
%             TTL_OUTPUT(obj,2,ramp_axis);                     %set the waveform index level to rising edge/active high
%             %%%%%%%%%  CLOCK
%             TTL_OUTPUT_CLOCK(obj,5,ramp_axis);               %set the pin 9 OUTPUT to  WAVEFORM INDEX CLOCK
%             TTL_OUTPUT_POLARITY_CLOCK(obj,0,ramp_axis);      %set the waveform CLOCK polarity to rising edge
%             %%%%%%%%
%             TTL_OUTPUT_POLARITY(obj,0,ramp_axis);            %set the waveform output polarity to rising edge
%             TTL_OUTPUT_ACTIVE_PAIRS(obj,1,ramp_axis);        %set output indexes on 1 active pairs
%             TTL_OUTPUT_LOW_INDEX_CLOCK(obj,0,ramp_axis)   %set the initial index value
%             TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,n_points-3,ramp_axis)  %set the final index value, basically where you want the Piezo stops!
%             
%             
%             WAVETABLE_END_INDEX(obj,n_points-1,ramp_axis);
% %             WAVETABLE_ENABLE(obj,1,ramp_axis);
% %             WAVETABLE_ACTIVE(obj,1,ramp_axis);
% %             pause(piezo_sampletime*n_points);
% %             WAVETABLE_ENABLE(obj,0,ramp_axis);
%             
        end
      
        function [n_points, piezo_sampletime]= Trigg_act(obj, X,Y,Z, TPixel, axis,n_points) %actuator scan
           
            points{1} = X;
            points{2} = Y;
            points{3} = Z;
            
            obj.Mov(X(1),1);
            obj.Mov(Y(1),2);
            %obj.Mov(Z(1),3); %don't move in the Z direction
            pause(obj.StabilizeTime); 
            
%             N = length(points{ramp_axis});
%             
            
%             waveform_per_point=TPixel; %This is the amount of time to spend per spatial point. This is just the dwell time.
%             number_of_waveform_per_point = ceil(waveform_per_point/piezo_sampletime); %This is the number of points of the waveform per spatial point
%             spatial_ramp =  linspace(init_pos,fin_pos,N);
%             waveform=[];
%             for j=1:size(spatial_ramp,2)
%                 waveform =  [waveform spatial_ramp(j)*ones(1,number_of_waveform_per_point)];
%             end
%                    
%             obj.totWaveform =waveform;
            
            %n_points=size(obj.totWaveform,2);
            
            %C=obj.COUNTS_PER_MICRON(axis);
            %D=DI_SCALE_FACTOR(obj,axis);
             piezo_sampletime=24e-6; %this is the sample rate of the piezo
            %%%%%%% Send to piezo
            WAVETABLE_INDEX(obj,0,axis);
            
            WAVETABLE_CYCLE_DELAY(obj,0,axis);
%         
%             switch(ramp_axis)
%                 case 1
%                     NEXT_X(obj);
%                 case 2
%                     NEXT_Y(obj);
%                 case 3
%                     NEXT_Z(obj);
%                 otherwise
%                     warning('What the HELL do you think you are doing mate? You gave the wrong axis number!');
%             end
            
            %%%%%%% Send to piezo
            
            TTL_INPUT(obj,7,axis);                      %set level trigger pause/resume
            TTL_INPUT_POLARITY(obj,0,axis);             %set the waveform input polarity to rising edge
            TTL_OUTPUT(obj,2,axis);                     %set the waveform index level to rising edge/active high
            %%%%%%%%%  CLOCK
            TTL_OUTPUT_CLOCK(obj,5,axis);               %set the pin 9 OUTPUT to  WAVEFORM INDEX CLOCK
            TTL_OUTPUT_POLARITY_CLOCK(obj,0,axis);      %set the waveform CLOCK polarity to rising edge
            %%%%%%%%
            TTL_OUTPUT_POLARITY(obj,0,axis);            %set the waveform output polarity to rising edge
            TTL_OUTPUT_ACTIVE_PAIRS(obj,1,axis);        %set output indexes on 1 active pairs
            %TTL_OUTPUT_ACTIVE_PAIRS(obj,2,ramp_axis);        %set output indexes on 1 active pairs
            
            %TTL_OUTPUT_LOW_INDEX_CLOCK(obj,ceil(n_points*0.2),ramp_axis)   %set the initial index value 
            TTL_OUTPUT_LOW_INDEX_CLOCK(obj,0,axis)   %set the initial index value
            TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,n_points-3,axis)  %set the final index value, basically where you want the Piezo stops!
           
         %   TTL_OUTPUT_LOW_INDEX_CLOCK(obj,200,ramp_axis)   %set the initial index value
          % TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,1000,ramp_axis)  %set the final index value, basically where you want the Piezo stops!
            %TTL_OUTPUT_LOW_INDEX_CLOCK(obj,10,ramp_axis)   %set the initial index value
            %TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,n_points-3,ramp_axis)  %set the final index value, basically where you want the Piezo stops!
            
           %TTL_OUTPUT_HIGH_INDEX_CLOCK(obj,n_points,ramp_axis)  %set the final index value, basically where you want the Piezo stops!
            
            
           WAVETABLE_END_INDEX(obj,n_points-1,axis); %2/19
%             WAVETABLE_ENABLE(obj,1,ramp_axis);
%             WAVETABLE_ACTIVE(obj,1,ramp_axis);
%             pause(piezo_sampletime*n_points);
%             WAVETABLE_ENABLE(obj,0,ramp_axis);
            
        end
        
        
        function NEXT_X(obj,delta)
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
                     
           %READ_axis_out=(out/1048574*100)+50;
            %Total_Point_array=(obj.totWaveform)*1048574/100; 
            Total_Point_array= (obj.totWaveform-delta)*1048574/100; 
            Point_target=Total_Point_array(1);
            %clear TARGET;
            if Point_target < 0
            Point_target = (2^32 + Point_target);
            end
            TARGET=dec2hex(round(Point_target),8);
            address_NEXT='C0000000';
            cmdstr_NEXT=strcat('A2',address_NEXT,TARGET,'55');
            % -- reorder the bytes --
            cmdstr_NEXT = cmdstr_NEXT([1 2 9 10 7 8 5 6 3 4 17 18 15 16 13 14 11 12 19 20]);
            L_NEXT = length(cmdstr_NEXT);
            c_NEXT = hex2dec(reshape(cmdstr_NEXT,2,L_NEXT/2)');
            fwrite(obj.Piezo,c_NEXT);
            
            add_NEXT=hex2dec('C0000000');
            for j=2:size(Total_Point_array,2)
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
             
        end
        
        function NEXT_Y(obj,delta)
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
           
           Total_Point_array= (obj.totWaveform-delta)*1048574/100; 
            Point_target=Total_Point_array(1);
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
        end
        
        function NEXT_Z(obj,delta)
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
            Total_Point_array=(obj.totWaveform-delta)*1048574/20;
            Point_target=Total_Point_array(1);
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
        end
        
        function RESET_FLASH_MEMORY_X = RESET_FLASH_MEMORY_X(obj)
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
        end
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        %
%         function Trigg_original(obj, X,Y,Z, TPixel, ramp_axis) %1d scan
%             % TPixel: Pixel time (set by user, in Imaging: it is the dwell)
%             % X, Y, Z: arrays of the points that are scanned, only one should be an array (corresponding to the ramp_axis), the others should be constants single values
%             % ramp_axis: values: 1,2,3, defines the direction of the scan
%             % nFlat (nb of points): A flat section at the start of ramp
%             % nOverRun (nb of points): Let the waveform over run the start and end
% %             disp('SCAN')
% %             tic
%             points{1} = X;
%             points{2} = Y;
%             points{3} = Z;
%             
%             %PC: Initial and final position
%             init_pos=points{ramp_axis}(1);
%             fin_pos=points{ramp_axis}(end);
%             %Move to first point in the scan
%             obj.Mov(X(1),1);
%             obj.Mov(Y(1),2);
%             obj.Mov(Z(1),3);
%             pause(obj.StabilizeTime); %  means: piezo needs at most Stabilize time in sec to go to any scan starting point
%             % PC: From tests, it seems that 50ms is enough for the piezo to move and stabilize
%             
%             N = length(points{ramp_axis});
%             
%             %warning below should never be called bc another warning exist
%             %in Imaging GUI
%             if TPixel*obj.SampleRate<1
%                 warning(['Dwell time too short. The piezo samp rate is ',num2str(obj.SampleRate),...
%                     ', so the dwell time must be at least ',num2str(1/obj.SampleRate),'sec.']);
%                 return;
%             end
%             
%             %As explained in ImagingFunctions' StartScan1D function, in
%             %the original code the function below was round, but this gave
%             %an error - changed to ceil
%             n = ceil(TPixel*obj.SampleRate);
%             % Total waveform points in the ramp
%             nRamp = N*2*n;
%             %PC: We acquire two points for every calculated/displayed point.
%             % Also, apparently, if we set a dwell time longer than 1/SampleRate we do not sit at the same point
%             % for all that time, but subdivide the interval in smaller steps.
%             % Not sure if this is a good solution.
%             % CDA: yes it is a good solution bc we want that the piezo be
%             % moving with a constant speed. It is *not* a good idea to
%             % program a "stair-like" waveform; if we increase the dwell
%             % time, what we are in fact doing is making the scan ramp less
%             % and less steep by acquiring more points (as pointed out
%             % above, by subdividing the interval in smaller steps).
%             
%             % points in the waveform to be written to piezo
%             nWaveform = obj.nFlat + obj.nOverRun + nRamp + obj.nOverRun;
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % New Ramping Mechanism
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             % take first two points and calculate the increment per point including the dwell time (n)
%             incr = (fin_pos-init_pos)/(nRamp-2*n);
%             % the initial smooth starting ramp
%             smooth_ramp=(init_pos-(2*n-1)*incr/2-incr*obj.nOverRun)+incr*obj.nOverRun*(1-cos(pi/4/(obj.nFlat+obj.nOverRun)*(0:obj.nFlat+obj.nOverRun-1)))/(1-cos(pi/4));
%             % the ramp over the scanning points including the overun points at the end
%             scan_ramp = (init_pos-(2*n-1)*incr/2):incr:(fin_pos + (2*n-1)*incr/2 + incr*obj.nOverRun);
%             % connect both ramps
%             smooth_ramp = [smooth_ramp scan_ramp];
%             %smooth_ramp = linspace(init_pos,fin_pos,416);
%             
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % Coerce Waveform
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             obj.totWaveform =smooth_ramp;
%             for k=1:1:length(obj.totWaveform)
%                 if obj.totWaveform(k) < obj.LowEndOfRange(1)
%                     obj.totWaveform(k) = obj.LowEndOfRange(1);
%                 elseif obj.totWaveform(k) > obj.HighEndOfRange(1)
%                     obj.totWaveform(k) = obj.HighEndOfRange(1);
%                 end
%             end
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % Send Waveform to Piezo
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             WaveformTime=max(obj.ADCtime,obj.DAQtime);
%             WaveformPtr = libpointer('doublePtr',obj.totWaveform);
%             WaveformRead = obj.totWaveform; %WaveformRead will record the actual movement of the piezo;
%             WaveformReadPtr = libpointer('doublePtr',WaveformRead);
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % RESET
%            
%             n_points=size(obj.totWaveform,2);
%             size(smooth_ramp,2);
%             
%             time_wave=n_points*24e-6;
%             
%             
%            % WAVETABLE_CYCLE_DELAY(obj,0,ramp_axis);
% %             WAVETABLE_ACTIVE(obj,0,ramp_axis);
% %             WAVETABLE_ENABLE(obj,0,ramp_axis);        
%             
% 
%             
% %             Initial = round(Pos(obj,ramp_axis));
% %             
% %             for j=round(points{ramp_axis}(1)):round(points{ramp_axis}(end))
% %                     %pause(time_wave);
% %                     %pause(TPixel);
% %                     pause(5e-1);
% %                     %disp(round(points{ramp_axis}(j)))
% %                     %disp(j)
% %                     %obj.Mov(round(points{ramp_axis}(j)),ramp_axis);
% %                     obj.Mov(j,ramp_axis);
% %                     
% %             end    
%              
%             
%  
%             %%%%%%% NEW TTL COMMANDS 
%             %%%%%%% these commands allow you to control the waveforms, when
%             %%%%%%% and where they are supposed to start and stop
%             %%%%%%%
%             
%             TTL_INPUT(obj,7,ramp_axis);                % set level trigger pause/resume
%             TTL_INPUT_POLARITY(obj,0,ramp_axis);       %set the waveform input polarity to rising edge
%             TTL_OUTPUT(obj,2,ramp_axis);               %set the waveform index level to rising edge/active high
%             TTL_OUTPUT_POLARITY(obj,0,ramp_axis);      %set the waveform output polarity to rising edge
%             TTL_OUTPUT_ACTIVE_PAIRS(obj,1,ramp_axis);  %set output indexes on 1 active pairs
%             TTL_START(obj,0,ramp_axis)                 % set the initial index value
%             TTL_STOP(obj,n_points-3,ramp_axis)         % set the final index value, basically where you want the Piezo stops!
%             
%             
%             WAVETABLE_END_INDEX(obj,n_points-1,ramp_axis);
%  
%             WAVETABLE_INDEX(obj,0,ramp_axis);  
%             WAVETABLE_ENABLE(obj,1,ramp_axis);
%             WAVETABLE_ACTIVE(obj,1,ramp_axis);
%             pause(1e-2);
%             WAVETABLE_ENABLE(obj,0,ramp_axis);
%             
%             obj.theorywaveform = WaveformPtr.Value((obj.nFlat+obj.nOverRun+1):2*n:(obj.nFlat+obj.nOverRun+nRamp));  %or NX*2*n
%             obj.realwaveform = WaveformReadPtr.Value((obj.nFlat+obj.nOverRun+1+obj.LagPts):2*n:(obj.nFlat+obj.nOverRun+nRamp+obj.LagPts));  %or NX*2*n
% %toc
%         end
%     
%        
%          function Trigg_old(obj, X,Y,Z, TPixel, ramp_axis) %1d scan
% 
%             points{1} = X;
%             points{2} = Y;
%             points{3} = Z;
%             
%             init_pos=points{ramp_axis}(1);
%             fin_pos=points{ramp_axis}(end);
% 
%             obj.Mov(X(1),1);
%             obj.Mov(Y(1),2);
%             obj.Mov(Z(1),3);
%             pause(obj.StabilizeTime);
%             
%             N = length(points{ramp_axis});
%             
%             piezo_sampletime=24e-6; %this is the sample rate of the piezo
%             waveform_per_point=TPixel; %This is the amount of time to spend per spatial point. This is just the dwell time.
%             number_of_waveform_per_point = ceil(TPixel/piezo_sampletime); %This is the number of points of the waveform per spatial point
%             spatial_ramp =  linspace(init_pos,fin_pos,N);
%             waveform=[];
%             for j=1:size(spatial_ramp,2)
%                 waveform =  [waveform spatial_ramp(j)*ones(1,number_of_waveform_per_point)];
%             end
%           
%             obj.totWaveform =waveform;
%             
%             n_points=size(obj.totWaveform,2);
%             
%             %%%%%%% Activate waveform at the piezo
%             
%             TTL_INPUT(obj,7,ramp_axis);                % set level trigger pause/resume
%             TTL_INPUT_POLARITY(obj,0,ramp_axis);       %set the waveform input polarity to rising edge
%             TTL_OUTPUT(obj,2,ramp_axis);               %set the waveform index level to rising edge/active high
%             TTL_OUTPUT_POLARITY(obj,0,ramp_axis);      %set the waveform output polarity to rising edge
%             TTL_OUTPUT_ACTIVE_PAIRS(obj,1,ramp_axis);  %set output indexes on 1 active pairs
%             TTL_START(obj,0,ramp_axis)                 % set the initial index value
%             TTL_STOP(obj,n_points-3,ramp_axis)         % set the final index value, basically where you want the Piezo stops!
%             
%             
%             WAVETABLE_END_INDEX(obj,n_points-1,ramp_axis);
%  
%             WAVETABLE_INDEX(obj,0,ramp_axis);  
%             WAVETABLE_ENABLE(obj,1,ramp_axis);
%             WAVETABLE_ACTIVE(obj,1,ramp_axis);
%             pause(piezo_sampletime*n_points);
%             WAVETABLE_ENABLE(obj,0,ramp_axis);
%          end
%         
%         function Trigg_attempt(obj, X,Y,Z, TPixel,ramp_axis) %1d scan
%        
%            
%           
%             obj.Mov(X(1),1);
%             obj.Mov(Y(1),2);
%             obj.Mov(Z(1),3);
%             
%             % time_wave=n_points*24e-6;
% 
%             WAVETABLE_INDEX(obj,0,ramp_axis);  
%             WAVETABLE_ENABLE(obj,1,ramp_axis);
%             WAVETABLE_ACTIVE(obj,1,ramp_axis);
%             %pause(time_wave*2);
%             pause(200e-3);
%             WAVETABLE_ENABLE(obj,0,ramp_axis);
%            
% %             obj.theorywaveform = WaveformPtr.Value((obj.nFlat+obj.nOverRun+1):2*n:(obj.nFlat+obj.nOverRun+nRamp));  %or NX*2*n
% %             obj.realwaveform = WaveformReadPtr.Value((obj.nFlat+obj.nOverRun+1+obj.LagPts):2*n:(obj.nFlat+obj.nOverRun+nRamp+obj.LagPts));  %or NX*2*n
% 
%         end
%      
% %         
%     function Trigg(obj, X, Y, Z, TPixel,ramp_axis) %2d scan, looping over some axis 'm'
%     % setup the scan ramp for the ramped axis with Scan for the first point of the looped direction 'm', Trig to repeat
%     % the same ramp-scan for each 'm'-column.
%     % ramp_axis: values: 1,2,3, defines the direction of the scan
%     
%     points{1} = X;
%     points{2} = Y;
%     points{3} = Z;
%     
% %     Move to first point in the scan
%     obj.Mov(X(1),1);
%     obj.Mov(Y(1),2);
%     obj.Mov(Z(1),3);
%     pause(obj.StabilizeTime);
%     % PC: From tests, it seems that 50ms is enough for the piezo to move and stabilize
%      %PC: Initial and final position
%             init_pos=points{ramp_axis}(1);
%             fin_pos=points{ramp_axis}(end);
%             
%     N = length(points{ramp_axis});
%     %number of waveform points per image pixel
%     
%     %warning below should never be called bc another warning exist
%     %in Imaging GUI
%     if TPixel*obj.SampleRate<1
%         warning(['Dwell time too short. The piezo samp rate is ',num2str(obj.SampleRate),...
%             ', so the dwell time must be at least ',num2str(1/obj.SampleRate),'sec.']);
%         return;
%     end
%     
%     n = ceil(TPixel*obj.SampleRate);
%     
%     %Total waveform points in the ramp
%     nRamp = N*2*n;
% %     % points in the waveform to be written to NanoDrive
% %     nWaveform = obj.nFlat + obj.nOverRun + nRamp + obj.nOverRun;
% %     WaveformRead = ones(1,nWaveform);
% %     WaveformReadPtr = libpointer('doublePtr',WaveformRead);
% %     
%     % points in the waveform to be written to piezo
%             nWaveform = obj.nFlat + obj.nOverRun + nRamp + obj.nOverRun;
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % New Ramping Mechanism
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             % take first two points and calculate the increment per point including the dwell time (n)
%             incr = (fin_pos-init_pos)/(nRamp-2*n);
%             % the initial smooth starting ramp
%             smooth_ramp=(init_pos-(2*n-1)*incr/2-incr*obj.nOverRun)+incr*obj.nOverRun*(1-cos(pi/4/(obj.nFlat+obj.nOverRun)*(0:obj.nFlat+obj.nOverRun-1)))/(1-cos(pi/4));
%             % the ramp over the scanning points including the overun points at the end
%             scan_ramp = (init_pos-(2*n-1)*incr/2):incr:(fin_pos + (2*n-1)*incr/2 + incr*obj.nOverRun);
%             % connect both ramps
%             smooth_ramp = [smooth_ramp scan_ramp];
%             %smooth_ramp = linspace(init_pos,fin_pos,4166);
%             
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % Coerce Waveform
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             obj.totWaveform =smooth_ramp;
%             for k=1:1:length(obj.totWaveform)
%                 if obj.totWaveform(k) < obj.LowEndOfRange(1)
%                     obj.totWaveform(k) = obj.LowEndOfRange(1);
%                 elseif obj.totWaveform(k) > obj.HighEndOfRange(1)
%                     obj.totWaveform(k) = obj.HighEndOfRange(1);
%                 end
%             end
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % Send Waveform to Piezo
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             WaveformTime=max(obj.ADCtime,obj.DAQtime);
%             WaveformPtr = libpointer('doublePtr',obj.totWaveform);
%             WaveformRead = obj.totWaveform; %WaveformRead will record the actual movement of the piezo;
%             WaveformReadPtr = libpointer('doublePtr',WaveformRead);
%             
%     
% %      
% %     WAVETABLE_ENABLE(obj,1,ramp_axis);
% %     WAVETABLE_ACTIVE(obj,1,ramp_axis);
% % %     
% %     WAVETABLE_ACTIVE(obj,0,ramp_axis);
% %     WAVETABLE_ENABLE(obj,0,ramp_axis);
% %     
% %     WAVETABLE_INDEX(obj,0,ramp_axis);
% %     
% %     obj.realwaveform = WaveformReadPtr.Value((obj.nFlat+obj.nOverRun+1+obj.LagPts):2*n:(obj.nFlat+obj.nOverRun+nRamp+obj.LagPts));  %or NX*2*n
% %     
% 
% n_points=size(obj.totWaveform,2);
%             size(smooth_ramp,2);
%             time_wave=n_points*24e-6;
%     TTL_INPUT(obj,7,ramp_axis);                % set level trigger pause/resume
%             TTL_INPUT_POLARITY(obj,0,ramp_axis);       %set the waveform input polarity to rising edge
%             TTL_OUTPUT(obj,2,ramp_axis);               %set the waveform index level to rising edge/active high
%             TTL_OUTPUT_POLARITY(obj,0,ramp_axis);      %set the waveform output polarity to rising edge
%             TTL_OUTPUT_ACTIVE_PAIRS(obj,1,ramp_axis);  %set output indexes on 1 active pairs
%             TTL_START(obj,0,ramp_axis)                 % set the initial index value
%             TTL_STOP(obj,n_points-3,ramp_axis)         % set the final index value, basically where you want the Piezo stops!
%             
%             
%             WAVETABLE_END_INDEX(obj,n_points-1,ramp_axis);
%             WAVETABLE_ENABLE(obj,1,ramp_axis);
%             WAVETABLE_ACTIVE(obj,1,ramp_axis);
%             pause(time_wave*2);
%             WAVETABLE_ENABLE(obj,0,ramp_axis);
%             
%             obj.theorywaveform = WaveformPtr.Value((obj.nFlat+obj.nOverRun+1):2*n:(obj.nFlat+obj.nOverRun+nRamp));  %or NX*2*n
%             obj.realwaveform = WaveformReadPtr.Value((obj.nFlat+obj.nOverRun+1+obj.LagPts):2*n:(obj.nFlat+obj.nOverRun+nRamp+obj.LagPts));  %or NX*2*n
% 
%     end
%     
  
end

methods (Static)
    
end
end

