classdef Siglent_Supply
    properties
        gpib_obj
        port_name
    end
    methods
        function obj=Siglent_Supply(port_name)
            obj.gpib_obj=visa('ni',port_name);
            fopen(obj.gpib_obj);
            pause(0.1);
           % fprintf(obj.gpib_obj,'INST CH1');
  
        end
        function VoltRead=PS_VoltRead(obj)
            fprintf(obj.gpib_obj,'VOLT?');
            VoltStr=fscanf(obj.gpib_obj);
            VoltRead=str2num(VoltStr);
        end
        function PS_VoltSet(obj,Volt_Set)
            VoltSetStr=sprintf(['CH1:VOLT ' num2str(Volt_Set)]);
            fprintf(obj.gpib_obj,VoltSetStr);
        end
        function CurrRead=PS_CurrRead(obj)
            fprintf(obj.gpib_obj,'CURR?');
            CurrStr=fscanf(obj.gpib_obj);
            CurrRead=str2num(CurrStr);
        end
        function PS_CurrSet(obj,Curr_Set)
            CurrSetStr=sprintf(['CH1:CURR ' num2str(Curr_Set)]);
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
            fprintf(obj.gpib_obj,'OUTP CH1, ON');
            fprintf(obj.gpib_obj,'OUTP CH2, ON');
        end
        function PS_OUTOff(obj)
            fprintf(obj.gpib_obj,'OUTP CH1, OFF');
            fprintf(obj.gpib_obj,'OUTP CH2, OFF');
        end
        
    end
end