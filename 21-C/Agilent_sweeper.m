classdef Agilent_sweeper
    properties
        gpib_obj
    end
    methods
        function obj=MW_Open(obj)
            obj.gpib_obj=gpib('ni',2,19);
            fopen(obj.gpib_obj);
        end
        function FreqRead=MW_FreqRead(obj)
            fprintf(obj.gpib_obj,'FREQ?');
            FreqStr=fscanf(obj.gpib_obj);
            FreqRead=str2num(FreqStr);
        end
        function MW_FreqSet(obj,Freq_Set)
            FreqSetStr=sprintf(['FREQ ' num2str(Freq_Set) 'HZ']);
            fprintf(obj.gpib_obj,FreqSetStr);
        end
        function AmpRead=MW_AmpRead(obj)
            fprintf(obj.gpib_obj,'POW?');
            AmpStr=fscanf(obj.gpib_obj);
            AmpRead=str2num(AmpStr);
        end
        function MW_AmpSet(obj,Amp_Set)
            AmpSetStr=sprintf(['POW ' num2str(Amp_Set) 'DBM']);
            fprintf(obj.gpib_obj,AmpSetStr);
        end
        
        function define_ramp_sweep(obj, f_start, f_stop, sweep_time)
%         '''Set the sweeper to perform an analog ramp sweep, the fastest kind
%         of sweep option. The analog ramp sweep varies the frequency 
%         continuously from a start and stop frequency specified. The time from
%         start frequency to stop frequency is designated by the sweep time. 
%         Max sweep rate for frequencies >3.2 GHz is 400 MHz/ms
%         Possible values for sweep time - 10 ms to 99 seconds, 1 ms resolution
%         Retracing is turned on so the sweeper resets to the start frequency
%         once the first sweep is completed.
%         '''

        fprintf(obj.gpib_obj,'SWE:GEN ANAL');
        fprintf(obj.gpib_obj,'FREQ:MODE SWE');
        fprintf(obj.gpib_obj,['FREQ:START ' num2str(f_start) 'HZ']);
        fprintf(obj.gpib_obj,['FREQ:STOP ' num2str(f_stop) 'HZ']);
        fprintf(obj.gpib_obj,['SWE:TIME ' num2str(sweep_time,'%.3f')]);
       % fprintf(obj.gpib_obj,'SWE:TIME {:.3f}'.format(self.sweep_time))
        fprintf(obj.gpib_obj,'LIST:RETR ON');
        end
      
        function  set_trigger_mode(obj, mode)
            %         '''Accepts the values:
            %         'cont' for continuous sweep mode
            %         'single' arms the sweeper for a single sweep
            %         '''
            if mode == 'cont'
                fprintf(obj.gpib_obj,'INIT:CONT ON')
            elseif mode == 'single'
                fprintf(obj.gpib_obj,'INIT:CONT OFF')
            end
        end
        
        function ise_mode(obj, amp, f_start, f_stop, sweep_time)
            %         '''Set the instrument in a sweeping mode with the sweep parameters
            %         defined using the "def_sweep" method. Ensures AM modulation is off,
            %         power levels are as desired, and the instrument is sweeping in analog
            %         ramp mode continously.
            %         '''
            obj.define_ramp_sweep(f_start, f_stop, sweep_time)
            % obj.set_am_modulation('off')
            obj.MW_AmpSet(amp)
            obj.set_trigger_mode('cont')
%             if~obj.inst.query('OUTPUT:STAT?')
%                 print('MW power output off')
%             end
        end
        
        function MW_Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
            fclose(serialObj(i));
            end
        end
        function MW_RFOn(obj)
            fprintf(obj.gpib_obj,'OUTPUT:STAT ON');
        end
        function MW_RFOff(obj)
            fprintf(obj.gpib_obj,'OUTPUT:STAT OFF');
        end
        
    end
end