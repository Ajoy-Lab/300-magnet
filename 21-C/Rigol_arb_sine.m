classdef Rigol_arb_sine
    properties
        gpib_obj
        port_name
    end
    methods
        function obj=Rigol_arb_sine(port_name)
            obj.gpib_obj=visa('ni',port_name);            
            fopen(obj.gpib_obj);
%              fprintf(obj.gpib_obj,'BURS:STAT ON');
%             fprintf(obj.gpib_obj,'BURS:MODE GAT');
%                 fprintf(obj.gpib_obj,'BURS:NCYC INF');
%                 fprintf(obj.gpib_obj,'BURS:PHAS 0');
%                  fprintf(obj.gpib_obj,'BURS:GAT:POL NORM');
             %   fprintf(obj.gpib_obj,'TRIG:SOUR EXT');
              %  fprintf(obj.gpib_obj,'TRIG:SLOP POS');
        end
       
        function define_sine(obj,freq,Vpp,offset,phase)
        %Set the sine wave parameters
        
        %fprintf(obj.gpib_obj,['VOLT:UNIT VPP' num2str(freq) ',' num2str(Vpp) ',' num2str(offset)]);
        fprintf(obj.gpib_obj,'VOLT:UNIT VPP');
        pause(0.2);
        fprintf(obj.gpib_obj,['APPL:SIN ' num2str(freq) ',' num2str(Vpp) ',' num2str(offset)]);
        pause(0.1);
        fprintf(obj.gpib_obj,['PHAS ' num2str(phase)]);
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
         
         function  set_phase(obj, phase)
            %         '''Accepts the values:
            %         'cont' for continuous sweep mode
            %         'single' arms the sweeper for a single sweep
            %         '''
                     fprintf(obj.gpib_obj,['PHAS ' num2str(phase)]);
         end
       
        
        function ise_mode(obj,freq,Vpp,offset,symm)
            %         '''Set the sine wave parameters 
            obj.define_sine(freq,Vpp,offset,symm)
            pause(0.2);
          
        end
        
        function set_external_clock_source(obj)
            fprintf(obj.gpib_obj,'SYST:CLKSRC EXT');
            pause(0.2);
        end
        
        function set_sweep(obj,volt,offset,phase,start_freq, stop_freq,sweep_time)
        %Set the sine wave parameters for sweep
        
        fprintf(obj.gpib_obj,'FUNC SIN');
        pause(0.2);
        fprintf(obj.gpib_obj,'SWE:STAT ON');
        pause(0.2);
        fprintf(obj.gpib_obj,'SWE:SPAC LIN');
        pause(0.2);
        fprintf(obj.gpib_obj,'VOLT:UNIT VPP');
        pause(0.2);
        fprintf(obj.gpib_obj,['VOLT ' num2str(volt)] );
        pause(0.2);
        fprintf(obj.gpib_obj,['VOLT:OFFS ' num2str(offset)] );
        pause(0.2);
        fprintf(obj.gpib_obj,['PHAS ' num2str(phase)] );
        pause(0.2);
        fprintf(obj.gpib_obj,['FREQ:STAR ' num2str(start_freq)]);
        pause(0.2);
        fprintf(obj.gpib_obj,['FREQ:STOP ' num2str(stop_freq)]);
        pause(0.1);
        fprintf(obj.gpib_obj,['SWE:TIME ' num2str(sweep_time)]);
        pause(0.1);
            
        end
        
        function set_sweep_off(obj)
            fprintf(obj.gpib_obj,'SWE:STAT OFF');
            pause(0.2);
        end
       
        function set_ext_trigger(obj)
            fprintf(obj.gpib_obj,'TRIG:SOUR EXT');
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
        end
        
        
        
    end
end