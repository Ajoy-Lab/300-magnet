classdef PulseGeneratorSpinCorePulseBlaster_simu < handle

	properties
		LibraryFile % spinapi.dll file
		LibraryHeader % path to spinapi.h file
		LibraryName % alias of loaded library
        
        SampleRate = 500e6; % in Hz
          LONG_DELAY_TIMESTEP = 500e-9; %%%from where????????
          
    end	
	
    properties (Constant = true)
       INST_CONTINUE    = 0
       INST_STOP        = 1
       INST_LOOP        = 2
       INST_END_LOOP    = 3
       INST_JSR         = 4
       INST_RTS         = 5
       INST_BRANCH      = 6
       INST_LONG_DELAY  = 7
       INST_WAIT        = 8
       PULSE_PROGRAM    = 0
       
       %flag_option map. string-to-bits
        ALL_FLAGS_ON	= hex2dec('1FFFFF');
        ONE_PERIOD		= hex2dec('200000');
        TWO_PERIOD		= hex2dec('400000');
        THREE_PERIOD	= hex2dec('600000');
        FOUR_PERIOD		= hex2dec('800000');
        FIVE_PERIOD		= hex2dec('A00000');
        SIX_PERIOD      = hex2dec('C00000');
        ON				= hex2dec('E00000');
       
       
    end
    
    
    
	methods
		function [obj] = PulseGeneratorSpinCorePulseBlaster_simu(obj)
%             obj.LibraryFile = LibraryFile;
%             obj.LibraryHeader = LibraryHeader;
%             obj.LibraryName = LibraryName;
%             obj.Initialize();
        end
		
		function [obj] = Initialize(obj)
%			if ~libisloaded(obj.LibraryName)
%				loadlibrary(obj.LibraryFile,obj.LibraryHeader,'alias',obj.LibraryName);
%			end
        end
		
        function [obj] = PBInit(obj)
%           [err] = calllib(obj.LibraryName,'pb_init');
            
%            if err ~= 0,
%               error('Error Loading PulseBlaster Board');
%            end
        end
        
        function [obj] = PBClose(obj)
%            [err] = calllib(obj.LibraryName,'pb_close');
        end
        
        function [obj] = SetClock(obj)

            % NOTE!!!
            % Spin Core sets the clock in units of MHz, but controlling
            % software gives the clock in Hz, so must convert
            %SampleRate = double(SampleRate/1e6);
%            calllib(obj.LibraryName,'pb_set_clock',ClockRate);
        end
        
		function [obj] = PBStart(obj)
%			[err] = calllib(obj.LibraryName,'pb_start');
			%obj.CheckError();
		end
		
		function [obj] = PBStop(obj)
%           [err] = calllib(obj.LibraryName,'pb_stop');
        end
        
        function [obj] = PBReset(obj)
%            [err] = calllib(obj.LibraryName,'pb_reset');
        end
        % for the time being, it is not clear how pb_reset is different
        % from pb_stop
		
        function [obj] = StartProgramming(obj)
%            [err] = calllib(obj.LibraryName,'pb_start_programming',obj.PULSE_PROGRAM);
        end

        
        function [obj] = StopProgramming(obj)
%            [err] = calllib(obj.LibraryName,'pb_stop_programming');
        end

        function [status] = PBInstruction(varargin)
			status = 0;
        end
        
        %PC Added Oct 4, 2010
        function [obj] = setLines(obj,bHigh,controlLine)
            % setLines(bHigh,controlLine)
            %
            % bHigh = boolean value for line (0/1)
            % controlLine = line to set
            
            FlagInstr = bHigh*(2.^controlLine);
            
            obj.StartProgramming();
            % SET LINE FOR 500ns
            % instruction 0
            obj.PBInstruction(FlagInstr,obj.INST_CONTINUE,0,500);
            % BRANCH FOR 500ns
            % instrunction 1
            obj.PBInstruction(FlagInstr,obj.INST_BRANCH,0,500);
            
            obj.StopProgramming();
        end
        
        function [obj] = sendSequence(obj,states,duration,repetitions)
            
           
            duration = round(duration*1e9); %PulseBlaster instruction takes ns
            
            
             obj.StartProgramming();
            
             [instruction_num] = obj.PBInstruction(0,obj.INST_LOOP,repetitions,40); %40ns in the manual, to be seen
          
            for k=1:1:length(states)
       
          obj.PBInstruction(states(k), obj.INST_CONTINUE, 0, duration(k));
          
            end
           
            obj.PBInstruction(0,obj.INST_END_LOOP,instruction_num,40); %40ns in the manual, change
        
            obj.PBInstruction(0,obj.INST_STOP,0,40); %FREAKING NECESSARY BUT YOU WON'T FIND IN THE MANUAL
            obj.StopProgramming();
            
           
            
        end
    end
    
end
