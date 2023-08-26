classdef Power_Supply
    properties
        gpib_obj
    end
    methods
        function obj=PS_Open(obj)
            obj.gpib_obj=gpib('ni',0,5);
            fopen(obj.gpib_obj);
        end
        function VoltRead=PS_VoltRead(obj)
            fprintf(obj.gpib_obj,'VOLT?');
            VoltStr=fscanf(obj.gpib_obj);
            VoltRead=str2num(VoltStr);
        end
        function PS_VoltSet(obj,Volt_Set)
            VoltSetStr=sprintf('VOLT %d V',Volt_Set);
            fprintf(obj.gpib_obj,VoltSetStr);
        end
        function CurrRead=PS_CurrRead(obj)
            fprintf(obj.gpib_obj,'CURR?');
            CurrStr=fscanf(obj.gpib_obj);
            CurrRead=str2num(CurrStr);
        end
        function PS_CurrSet(obj,Curr_Set)
            CurrSetStr=sprintf('CURR %d A',Curr_Set);
            fprintf(obj.gpib_obj,CurrSetStr);
        end
        function PS_Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
            fclose(serialObj(i));
            end
        end
        function PS_OUTOn(obj)
            fprintf(obj.gpib_obj,'OUTP ON');
        end
        function PS_OUTOff(obj)
            fprintf(obj.gpib_obj,'OUTP OFF');
        end
        
    end
end