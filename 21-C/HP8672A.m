classdef HP8672A < handle
    properties
        gpib_obj
    end
    methods
        function obj=MW_Open(obj)
            obj.gpib_obj=gpib('ni',0,19);
            fopen(obj.gpib_obj);
        end
        function Manual_Command(obj,String)
%             String='P02000000Z0K0L:M0N6O3';
%             String='P02000000Z0K0L:M0N6O0';
            fprintf(obj.gpib_obj,String);
        end
        function set_freq(obj,Freq_Set)
            Freq_Set_Mhz = round(Freq_Set/1000);
            FreqSetStr='P%08dZ0'; %Program code P is for range 
            fprintf(obj.gpib_obj,FreqSetStr,Freq_Set_Mhz);
        end
        function set_amp(obj,Amp_Set)
            if (Amp_Set<-120)|(Amp_Set>10)
                disp('HP8672 Amplitude is too high');
            else
                %Main Amp control
                %corresponds to 0, -10, -20 ...., -110 dbm
                K_codes = ['0','1','2','3','4','5','6','7','8','9',':',';'];
                %Vernier Amp control
                %corresponds to 0, -1, -2 ....,-10  dbm
                L_codes = ['3','4','5','6','7','8','9',':',';','<','='];
                %Calculate codes, RANGE switch of +10dbm is used: 'O3'
                Amp_val = Amp_Set-10;
                K_val = K_codes(floor(-Amp_val/10)+1);
                L_val = L_codes(mod(-Amp_val,10)+1);
                AmpSetStr=['K' K_val 'L' L_val 'O3'];
                %disp(AmpSetStr);
                fprintf(obj.gpib_obj,AmpSetStr);
            end
        end
        function MW_Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
            fclose(serialObj(i));
            end
        end
        function set_MWoff(obj)
            OffStr='O0';
            fprintf(obj.gpib_obj,OffStr);
        end
        
        function set_MWon(obj)
            OnStr='O3';
            fprintf(obj.gpib_obj,OnStr);
        end
        
        
        %----------test code
%         obj=HP8376();
%         obj.Open();
%         obj.gpib_obj;
%         obj.FreqRead;
%         obj.FreqSet(1e9);
        
    end
end