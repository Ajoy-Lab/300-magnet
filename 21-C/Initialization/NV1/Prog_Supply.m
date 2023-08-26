classdef Prog_Supply
    properties
        gpib_obj
        port_name
    end
    methods
        function obj=Prog_Supply(port_name)
            obj.gpib_obj=serial(port_name);
            set(obj.gpib_obj, ...
     'BaudRate', 9600, ...
     'DataBits', 8, ...
     'FlowControl', 'none', ...
     'Parity', 'none', ...
     'StopBits', 1, ...
     'Terminator','CR/LF')
 fopen(obj.gpib_obj);
            
        end
        function VoltRead=PS_VoltRead(obj)
            fprintf(obj.gpib_obj,'VOLT?');
            VoltStr=fscanf(obj.gpib_obj);
            VoltRead=str2num(VoltStr);
        end
        function PS_VoltSet(obj,Volt_Set)
            Voltset=round2(Volt_Set*100,1);
            VoltSetStr=sprintf('su%04d',Voltset);
            fprintf(obj.gpib_obj,VoltSetStr);
        end
        function CurrRead=PS_CurrRead(obj)
            fprintf(obj.gpib_obj,'CURR?');
            CurrStr=fscanf(obj.gpib_obj);
            CurrRead=str2num(CurrStr);
        end
        function PS_CurrSet(obj,Curr_Set)
            CurrSetStr=sprintf('si%04d',Curr_Set*1000);
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
           % fprintf(obj.gpib_obj,'o1');
           fprintf(obj.gpib_obj,'OUT1');
        end
        function PS_OUTOff(obj)
            %fprintf(obj.gpib_obj,'o0');
            fprintf(obj.gpib_obj,'OUT0');
        end
        
    end
end