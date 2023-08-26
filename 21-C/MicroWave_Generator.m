classdef MicroWave_Generator
    properties
        gpib_obj
    end
    methods
        function obj=MW_Open(obj)
            obj.gpib_obj=gpib('ni',0,19);
            fopen(obj.gpib_obj);
        end
        function FreqRead=MW_FreqRead(obj)
            fprintf(obj.gpib_obj,'FR');
            FreqStr=fscanf(obj.gpib_obj);
            FreqRead=str2num(FreqStr(3:13));
        end
        function MW_FreqSet(obj,Freq_Set)
            FreqSetStr=sprintf('FR%011dHZ',Freq_Set);
            fprintf(obj.gpib_obj,FreqSetStr);
        end
        function AmpRead=MW_AmpRead(obj)
            fprintf(obj.gpib_obj,'AP');
            AmpStr=fscanf(obj.gpib_obj);
            AmpRead=str2num(AmpStr(3:13));
        end
        function MW_AmpSet(obj,Amp_Set)
            AmpSetStr=sprintf('PL %d DM',Amp_Set);
            fprintf(obj.gpib_obj,AmpSetStr);
        end
        function AM100(obj)
            fprintf(obj.gpib_obj,'A3');
        end
        function AM0(obj)
            fprintf(obj.gpib_obj,'A0');
        end
        function MW_Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
            fclose(serialObj(i));
            end
        end
        function MW_RFOn(obj)
            fprintf(obj.gpib_obj,'RF1');
        end
        function MW_RFOff(obj)
            fprintf(obj.gpib_obj,'RF0');
        end
        
    end
end