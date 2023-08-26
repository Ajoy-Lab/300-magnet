classdef PulseGeneratorSpinCorePulseBlaster < handle

	properties
		LibraryFile % spinapi.dll file
		LibraryHeader % path to spinapi.h file
		LibraryName % alias of loaded library
        
        SampleRate  % in Hz
        
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
       OFF				= hex2dec('000000');
       
    end
    
    
    
	methods
		function [obj] = PulseGeneratorSpinCorePulseBlaster(LibraryFile,LibraryHeader,LibraryName)
            obj.LibraryFile = LibraryFile;
            obj.LibraryHeader = LibraryHeader;
            obj.LibraryName = LibraryName;
            obj.Initialize();
        end
		
		function [obj] = Initialize(obj)
			if ~libisloaded(obj.LibraryName)
				loadlibrary(obj.LibraryFile,obj.LibraryHeader,'alias',obj.LibraryName);
			end
        end
		
        function [obj] = PBInit(obj)
            [err] = calllib(obj.LibraryName,'pb_init');
            PBReset(obj);
            if err ~= 0,
                error('Error Loading PulseBlaster Board');
            end
        end
        
        function [obj] = PBClose(obj)
            [err] = calllib(obj.LibraryName,'pb_close');
             if err ~= 0,
                error('Error Closing PulseBlaster Board');
            end
        end
        
        function [obj] = SetClock(obj,SampleRate)

            % NOTE!!!
            % Spin Core sets the clock in units of MHz, but controlling
            % software gives the clock in Hz, so must convert
            SampleRate = double(SampleRate/1e6);
            calllib(obj.LibraryName,'pb_core_clock',SampleRate);
            % this function returns void, so that no check possible
        end
        
		function [obj] = PBStart(obj)
			[err] = calllib(obj.LibraryName,'pb_start');
			
             if err ~= 0,
                error('Error Starting PulseBlaster Board');
            end
           
		end
		
		function [obj] = PBStop(obj)
            [err] = calllib(obj.LibraryName,'pb_stop');
            
             if err ~= 0,
                error('Error Stopping PulseBlaster Board');
            end
        end
        
        function [obj] = PBReset(obj)
            
            
              obj.StartProgramming();
        obj.PBInstruction(0,obj.INST_CONTINUE, 0, 750,obj.ON);
        obj.PBInstruction(0,obj.INST_BRANCH, 0, 150,obj.ON);
%           obj.PBInstruction(0,obj.INST_CONTINUE, 0,100,obj.ON);
%         obj.PBInstruction(0,obj.INST_BRANCH, 0,40,obj.ON);
%         obj.PBInstruction(0,obj.INST_STOP, 0,100,obj.ON);
        obj.StopProgramming();
        obj.PBStart();
        obj.PBStop();
            [err] = calllib(obj.LibraryName,'pb_reset');
        
        end
        % for the time being, it is not clear how pb_reset is different
        % from pb_stop
		
        function [obj]=PBZero(obj)
            calllib(obj.LibraryName,'pb_inst_pbonly',0,0,0,1000000);
            calllib(obj.LibraryName,'pb_inst_pbonly',0,1,0,1000000);
        end
                           
        
        function [obj] = StartProgramming(obj)
            [err] = calllib(obj.LibraryName,'pb_start_programming',obj.PULSE_PROGRAM);
            
             if err ~= 0,
                error('Error Start Programming PulseBlaster Board');
            end
        end

        
        function [obj] = StopProgramming(obj)
            [err] = calllib(obj.LibraryName,'pb_stop_programming');
            
             if err ~= 0,
                error('Error Stop Programming PulseBlaster Board');
            end
        end

        function [status] = PBInstruction(varargin)
           
            %%%length in ns
            
            if nargin == 5,
                obj = varargin{1};
                flags = varargin{2};
                inst = varargin{3};
                inst_data = varargin{4};
                length = varargin{5};
                flagopt = obj.ON;
            elseif nargin == 6,
                obj = varargin{1};
                flags = varargin{2};
                inst = varargin{3};
                inst_data = varargin{4};
                length = varargin{5};
                flagopt = varargin{6};
            end
            flags = int32(bitor(flags,flagopt));
            inst = int32(inst);
            inst_data = int32(inst_data);
            length = double(length);
            [status] = calllib(obj.LibraryName,'pb_inst_pbonly',flags,inst,inst_data,length);
            % status returns a negative number on an error, or the instuction number upon success
            if status < 0,
                warning('Spin Core Pulse Blaster Error: Code %d',status);
            end
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
            
           
            duration = round(duration*1e11)/100; %PulseBlaster instruction takes ns
            
            
            obj.StartProgramming();
            
             [instruction_num] = obj.PBInstruction(0,obj.INST_LOOP,repetitions,100); %40ns in the manual, to be seen
          
            for k=1:1:length(states)
          if duration(k)<30000000000
          obj.PBInstruction(states(k), obj.INST_CONTINUE, 0, duration(k));
          else
          obj.PBInstruction(states(k), obj.INST_LONG_DELAY, 100, duration(k)/100);
          end
            end
           
            obj.PBInstruction(0,obj.INST_END_LOOP,instruction_num,100); %40ns in the manual, change
        
            obj.PBInstruction(0,obj.INST_STOP,0,100); %FREAKING NECESSARY BUT YOU WON'T FIND IN THE MANUAL
            obj.StopProgramming();
            
           
            
        end
        function [status] = getstatus(obj)
           status = calllib(obj.LibraryName,'pb_read_status');
            
            
        end
    end
        
end