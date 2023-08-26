classdef Rigol_arb_mag
    properties
        gpib_obj
        port_name
    end
    methods
        function obj=Rigol_arb_mag(port_name)
             obj.gpib_obj=visa('ni',port_name);            
            %obj.gpib_obj=visa('ni','USB0::0x0400::0x09C4::DG1D191701816::INSTR');
            fopen(obj.gpib_obj);
              fprintf(obj.gpib_obj,'BURS:STAT ON');
             fprintf(obj.gpib_obj,'BURS:MODE GAT');
                 fprintf(obj.gpib_obj,'BURS:NCYC INF');
                 fprintf(obj.gpib_obj,'BURS:PHAS 0');
                  fprintf(obj.gpib_obj,'BURS:GAT:POL NORM');
              fprintf(obj.gpib_obj,'TRIG:SOUR EXT');
                fprintf(obj.gpib_obj,'TRIG:SLOP POS');
        end
       
        function set_sine_wave(obj,freq,Vpp,DCoff)
           %fprintf(obj.gpib_obj,['APPL:SIN ' num2str(freq) ',' num2str(Vpp) ',' num2str(0)]);
           fprintf(obj.gpib_obj, 'FUNC SIN');
           pause(0.1);
           fprintf(obj.gpib_obj,['FREQ ' num2str(freq)]);
           pause(0.1);
           fprintf(obj.gpib_obj,['VOLT ' num2str(Vpp)]);
           pause(0.1);
           fprintf(obj.gpib_obj,['VOLT:OFFS ' num2str(DCoff)]);
           pause(0.1);
           fprintf(obj.gpib_obj,'OUTP:LOAD INF'); %puts the load to high Z
           pause(0.1);
        end
        
        function set_square_wave(obj,freq,Vpp)
            fprintf(obj.gpib_obj,['APPL:SQU ' num2str(freq) ',' num2str(Vpp) ',' num2str(0)]);
            pause(0.1);
        end
        
        function set_sweep(obj,start,stop,T,Vpp)
            fprintf(obj.gpib_obj,['SWE:TIME ' num2str(T)]);
            pause(0.1);
            fprintf(obj.gpib_obj,['SWE:STAT ON']);
            pause(0.1);
            fprintf(obj.gpib_obj,['FREQ:STAR ' num2str(start)]);
            pause(0.1);
            fprintf(obj.gpib_obj,['FREQ:STOP ' num2str(stop)]);
            pause(0.1);
            fprintf(obj.gpib_obj,['VOLT ' num2str(Vpp)]);
            pause(0.1);
            fprintf(obj.gpib_obj,'OUTP:LOAD INF'); %puts the load to high Z
            pause(0.1);
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


        fprintf(obj.gpib_obj,['APPL:RAMP ' num2str(freq) ',' num2str(Vpp) ',' num2str(offset)]);
        pause(0.1);
        fprintf(obj.gpib_obj,['FUNC:RAMP:SYMM ' num2str(symm)]);
 pause(0.1);
        end
      
        function  set_burst(obj, phase)
            %         '''Accepts the values:
            %         'cont' for continuous sweep mode
            %         'single' arms the sweeper for a single sweep
            %         '''
                     fprintf(obj.gpib_obj,'BURS:STAT ON');
                     pause(0.1);
            fprintf(obj.gpib_obj,'BURS:MODE GAT');
            pause(0.1);
                fprintf(obj.gpib_obj,'BURS:NCYC 49999');
                pause(0.1);
                fprintf(obj.gpib_obj,'BURS:GAT:POL NORM');
                pause(0.1);
                fprintf(obj.gpib_obj,['BURS:PHAS ' num2str(phase)]);
                pause(0.1);
                 
        end
        
        function  set_burst_cyc(obj, phase, N_cyc)
            %         '''Accepts the values:
            %         'cont' for continuous sweep mode
            %         'single' arms the sweeper for a single sweep
            %         '''
                     fprintf(obj.gpib_obj,'BURS:STAT ON');
                     pause(0.1); 
            fprintf(obj.gpib_obj,'BURS:MODE GAT');
            pause(0.1);
                fprintf(obj.gpib_obj,['BURS:NCYC ' num2str(N_cyc)]);
                pause(0.1);
                fprintf(obj.gpib_obj,'BURS:GAT:POL NORM');
                pause(0.1);
                fprintf(obj.gpib_obj,['BURS:PHAS ' num2str(phase)]);
                pause(0.1);
                 
        end
        
         function  set_burst_off(obj, phase)
            %         '''Accepts the values:
            %         'cont' for continuous sweep mode
            %         'single' arms the sweeper for a single sweep
            %         '''
                     fprintf(obj.gpib_obj,'BURS:STAT OFF');
         end

         function set_mod(obj,modfreq)
                fprintf(obj.gpib_obj,'AM:SOUR INT');
                pause(0.1);
                fprintf(obj.gpib_obj, 'AM:INT:FUNC SIN');
                pause(0.1);
                fprintf(obj.gpib_obj, ['AM:INT:FREQ ', num2str(modfreq)]);
                pause(0.1);
                fprintf(obj.gpib_obj, 'AM:STATE ON');
                pause(0.1);
         end
       
        
        function ise_mode(obj,freq,Vpp,offset,symm)
            %         '''Set the instrument in a sweeping mode with the sweep parameters
            %         defined using the "def_sweep" method. Ensures AM modulation is off,
            %         power levels are as desired, and the instrument is sweeping in analog
            %         ramp mode continously.
            %         '''
            obj.define_ramp(freq,Vpp,offset,symm)
            pause(0.2);
          
        end
        
        function MW_Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
            fclose(serialObj(i));
            end
        end
        function MW_RFOn(obj)
            fprintf(obj.gpib_obj, 'OUTP ON');
            pause(0.1);
        end
        function MW_RFOff(obj)
            fprintf(obj.gpib_obj,'OUTP OFF');
            pause(0.1);
            fprintf(obj.gpib_obj,'swe:stat off'); 
            pause(0.1);
            fprintf(obj.gpib_obj,'burs:stat off'); 
            pause(0.1);
            fprintf(obj.gpib_obj,'am:stat off');
            pause(0.1)
        end
        
    end
end