classdef HP8376 < handle
    properties
        gpib_obj
    end
    methods
        function obj=Open(obj)
            obj.gpib_obj=gpib('ni',0,19);
            fopen(obj.gpib_obj);
        end
        function FreqRead=FreqRead(obj)
            fprintf(obj.gpib_obj,'FR');
            FreqStr=fscanf(obj.gpib_obj);
            FreqRead=str2num(FreqStr(3:13));
        end
        function FreqSet(obj,Freq_Set)
            FreqSetStr=sprintf('FR%011dHZ',Freq_Set);
            fprintf(obj.gpib_obj,FreqSetStr);
        end
        function AmpRead(obj)
            fprintf(obj.gpib_obj,'PL');
            FreqStr=fscanf(obj.gpib_obj);
            FreqRead=str2num(FreqStr(3:13));
        end
        function AmpSet(obj)
            FreqSetStr=sprintf('PL%011dV',Freq_Set);
            fprintf(obj.gpib_obj,FreqSetStr);
        end
        function MW_Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
            fclose(serialObj(i));
            end
        end
        function MW_Off(obj)
            FreqSetStr=sprintf('RF0');
            fprintf(obj.gpib_obj,FreqSetStr);
        end
        
        function MW_On(obj)
            FreqSetStr=sprintf('RF1');
            fprintf(obj.gpib_obj,FreqSetStr);
        end
        
        function mod_off(obj)
            FreqSetStr=sprintf('A0');
            fprintf(obj.gpib_obj,FreqSetStr);
            
            FreqSetStr=sprintf('P0');
            fprintf(obj.gpib_obj,FreqSetStr);
            
            FreqSetStr=sprintf('D0');
            fprintf(obj.gpib_obj,FreqSetStr);
            
            FreqSetStr=sprintf('W0');
            fprintf(obj.gpib_obj,FreqSetStr);
        end
        
        %----------test code
%         obj=HP8376();
%         obj.Open();
%         obj.gpib_obj;
%         obj.FreqRead;
%         obj.FreqSet(1e9);
        
    end
end