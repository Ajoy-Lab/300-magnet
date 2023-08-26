classdef SG386gpib < handle 
    properties
        gpib_obj
    end
    methods
        function obj=MW_Open(obj)
            obj.gpib_obj=gpib('ni',0,27);
            fopen(obj.gpib_obj);
            obj.set_modoff();
            obj.set_amp(0);
            obj.set_MWoff();
        end
        function set_freq(obj,freq)
            fprintf(obj.gpib_obj,['FREQ ' num2str(freq)]);
        end
        
         function set_amp(obj,amp)
            %amplitude in dBm
            fprintf(obj.gpib_obj,['AMPR ' num2str(amp)]);
         end
        
        function set_phase(obj,phase)
            fprintf(obj.gpib_obj,['PHAS ' num2str(phase)]);
        end
        
        function MW_Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
            fclose(serialObj(i));
            end
        end
        function set_MWon(obj)
            fprintf(obj.gpib_obj, 'ENBR 1');
        end
        function set_MWoff(obj)
            fprintf(obj.gpib_obj,'ENBR 0');
        end
        
        function set_modoff(obj)
            fprintf(obj.gpib_obj,'MODL 0');
        end
        
        function example_code(obj)
%          obj2=SG386gpib();
%          obj2.MW_Open();
%         obj2.set_freq(4e9);
%         obj2.set_amp(3);
%         obj2.set_MWon();
%         obj2.set_MWoff();
%           obj2.MW_Close();
        end
    
        
    end
end