classdef SR830 < handle
    properties
        gpib_obj
    end
    methods
%         function [obj] = SR830()
%             obj.Init();
%         end
        
        function obj=Open(obj)
            obj.gpib_obj=gpib('ni',1,9);
            fopen(obj.gpib_obj);
        end
        function Data=SigRead(obj)
            fprintf(obj.gpib_obj,'OUTP? 1');
            VoltStr=fscanf(obj.gpib_obj);
            Data=str2num(VoltStr);
        end

        function Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
            fclose(serialObj(i));
            end
        end
    end
end