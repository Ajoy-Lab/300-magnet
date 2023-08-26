classdef HP_arb4
    properties
        gpib_obj
    end
    methods
        function obj=MW_Open(obj)
            obj.gpib_obj=gpib('ni',2, 10);
            fopen(obj.gpib_obj);
             fprintf(obj.gpib_obj,'BM:STAT ON');
              %fprintf(obj.gpib_obj,'BURS:MODE GAT');
              fprintf(obj.gpib_obj,'TRIG:SOUR EXT');
            fprintf(obj.gpib_obj,'BM:SOUR INT');
                fprintf(obj.gpib_obj,'BM:NCYC INF');
                     %fprintf(obj.gpib_obj,'UNIT:ANGL DEG');
                  fprintf(obj.gpib_obj,'BM:PHAS 0');
                    %fprintf(obj.gpib_obj,'BURS:GAT:POL NORM');
%                 fprintf(obj.gpib_obj,'TRIG:SOUR EXT');
%                 fprintf(obj.gpib_obj,'TRIG:SLOP POS');
            
        end
       
        function define_ramp(obj,freq,Vpp,offset,symm)
%         '''Set the sweeper to perform an analog ramp sweep, the fastest kind
%         of sweep option. The analog ramp sweep varies the frequency 
%         continuously from a start and stop frequency specified. The time from
%         start frequency to stop frequency is designated by the sweep time. 
%         Max sweep rate for frequencies >3.2 GHz is 400 MHz/ms
%         Possible values for sweep time - 10 ms to 99 seconds, 1 ms resolution
%         Retracing is turned on so the sweeper resets to the start frequency
%         once the first sweep is completed.
%         '''


        fprintf(obj.gpib_obj,['APPL:RAMP ' num2str(freq) ', ' num2str(Vpp) ', ' num2str(offset)]);
         pause(0.1);
        %fprintf(obj.gpib_obj,['FUNC:RAMP:SYMM ' num2str(symm)]);
 pause(0.1);
        end
      
        function  set_burst(obj,phase)
            %         '''Accepts the values:
            %         'cont' for continuous sweep mode
            %         'single' arms the sweeper for a single sweep
            %         '''
           
             fprintf(obj.gpib_obj,'BM:STAT ON');
            %fprintf(obj.gpib_obj,'BURS:MODE GAT');
            fprintf(obj.gpib_obj,'TRIG:SOUR EXT');
            fprintf(obj.gpib_obj,'BM:SOUR INT');
                fprintf(obj.gpib_obj,'BM:NCYC INF');
                     %fprintf(obj.gpib_obj,'UNIT:ANGL DEG');
                 fprintf(obj.gpib_obj,['BM:PHAS ' num2str(phase)]);
        end
        
        function ise_mode(obj,freq,Vpp,offset,symm)
            %         '''Set the instrument in a sweeping mode with the sweep parameters
            %         defined using the "def_sweep" method. Ensures AM modulation is off,
            %         power levels are as desired, and the instrument is sweeping in analog
            %         ramp mode continously.
            %         '''
            obj.define_ramp(freq,Vpp,offset,symm)
          
        end
        
        function MW_Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
            fclose(serialObj(i));
            end
        end
        function MW_RFOn(obj)
            %fprintf(obj.gpib_obj, 'OUTP ON');
        end
        function MW_RFOff(obj)
            %fprintf(obj.gpib_obj,'OUTP OFF');
            fprintf(obj.gpib_obj, 'TRIG:SOUR EXT');
        end
        
    end
end