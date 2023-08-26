classdef TaborPM8572 < handle
    properties
        gpib_obj
        port_name
    end
    methods
        function obj=TaborPM8572(port_name)
            obj.gpib_obj=serial(port_name);
            set(obj.gpib_obj, ...
                'BaudRate', 9600, ...
                'DataBits', 8, ...
                'FlowControl', 'none', ...
                'Parity', 'none', ...
                'StopBits', 1, ...
                'Terminator','CR/LF',...
                'OutputBufferSize',2*2048*16)
            fopen(obj.gpib_obj);
        end

        function set_sine_wave(obj,freq,Vpp,DCoff,pha,instno) %sets the normal sine mode

            fprintf(obj.gpib_obj, 'INIT:CONT ON');
            pause(0.2);
            fprintf(obj.gpib_obj, ['INST:SEL ' num2str(instno)]);
            pause(0.2);
            fprintf(obj.gpib_obj, 'SOUR:MOD:TYPE OFF');
            pause(0.2);
            fprintf(obj.gpib_obj,'FUNC:MODE FIX');
            pause(0.2);
            fprintf(obj.gpib_obj, 'FUNC:SHAP SIN');
            pause(0.2);
            fprintf(obj.gpib_obj,['SOUR:FREQ ' num2str(freq)]);
            pause(0.2);
            fprintf(obj.gpib_obj,['SOUR:VOLT:LEV:AMPL ' num2str(Vpp)]);
            pause(0.2);
            fprintf(obj.gpib_obj,['SOUR:VOLT:LEV:OFFS ' num2str(DCoff)]);
            pause(0.2);
            fprintf(obj.gpib_obj,['SIN:PHAS ' num2str(pha)]);
            pause(0.2);
            fprintf(obj.gpib_obj,'OUTP:LOAD 1e6'); %puts the load to high Z
            pause(0.2);
        end

        function set_square_wave(obj,freq,Vpp,DCoff,instno) %sets the normal sine mode

            fprintf(obj.gpib_obj, 'INIT:CONT ON');
            pause(0.1);
            fprintf(obj.gpib_obj, ['INST:SEL ' num2str(instno)]);
            pause(0.1);
            fprintf(obj.gpib_obj, 'SOUR:MOD:TYPE OFF');
            pause(0.1);
            fprintf(obj.gpib_obj,'FUNC:MODE FIX');
            pause(0.1);
            fprintf(obj.gpib_obj, 'FUNC:SHAP SQU');
            pause(0.1);
            fprintf(obj.gpib_obj,['SOUR:FREQ ' num2str(freq)]);
            pause(0.1);
            fprintf(obj.gpib_obj,['SOUR:VOLT:LEV:AMPL ' num2str(Vpp)]);
            pause(0.1);
            fprintf(obj.gpib_obj,['SOUR:VOLT:LEV:OFFS ' num2str(DCoff)]);
            pause(0.1);
            fprintf(obj.gpib_obj,['SQU:DCYC ' num2str(50)]);
            pause(0.1);
            fprintf(obj.gpib_obj,'OUTP:LOAD 1e6'); %puts the load to high Z
            pause(0.1);
        end

    function set_DC(obj,ampl,instno) %sets DC

            fprintf(obj.gpib_obj, 'INIT:CONT ON');
            pause(0.1);
            fprintf(obj.gpib_obj, ['INST:SEL ' num2str(instno)]);
            pause(0.1);
            fprintf(obj.gpib_obj, 'SOUR:MOD:TYPE OFF');
            pause(0.1);
            fprintf(obj.gpib_obj,'FUNC:MODE FIX');
            pause(0.1);
            fprintf(obj.gpib_obj, 'FUNC:SHAP DC');
            pause(0.1);
            %fprintf(obj.gpib_obj,['SOUR:VOLT:LEV:AMPL ' num2str(ampl)]);
            fprintf(obj.gpib_obj,['SOUR:DC:AMPL ' num2str(ampl)]);
            pause(0.1);
            fprintf(obj.gpib_obj,'OUTP:LOAD 1e6'); %puts the load to high Z
            pause(0.1);
    end

        function  set_burst(obj, phase)
            %         '''Accepts the values:
            %         'cont' for continuous sweep mode
            %         'single' arms the sweeper for a single sweep
            %         '''
            fprintf(obj.gpib_obj,'TRIG:BURS ON');
            pause(0.1);
            fprintf(obj.gpib_obj,['BURS:PHAS ' num2str(phase)]);
            pause(0.1);

        end

        function set_gate(obj) %sets the gated mode which waits for trigger from pulse blaster
            fprintf(obj.gpib_obj, 'INIT:CONT OFF');
            pause(0.1);
            fprintf(obj.gpib_obj, 'TRIG:SOUR EXT');
            pause(0.1);
            fprintf(obj.gpib_obj, 'TRIG:GATE ON');
            pause(0.1);
            fprintf(obj.gpib_obj, 'TRIG:SLOP NEG');
            pause(0.1);
            fprintf(obj.gpib_obj, 'TRIG:LEV 2');
            pause(0.1);
        end

        function set_sweep(lol,fstart,fstop,famp,Tchirp,instno)
            fprintf(lol.gpib_obj, ['INST:SEL ' num2str(instno)]);
            pause(0.1);
            fprintf(lol.gpib_obj,'FUNC:MODE MOD');
            pause(0.1);
            fprintf(lol.gpib_obj,'MOD:TYPE SWE');
            pause(0.1);
            fprintf(lol.gpib_obj,['SWE:START ' num2str(fstart)]);
            pause(0.1);
            fprintf(lol.gpib_obj,['SWE:STOP ' num2str(fstop)]);
            pause(0.1);
            fprintf(lol.gpib_obj,['SWE:TIME ' num2str(Tchirp)]);
            pause(0.1);
            fprintf(lol.gpib_obj,'SWE:DIR UP');
            pause(0.1);
            fprintf(lol.gpib_obj,'SWE:SPAC LIN');
            pause(0.1);
            fprintf(lol.gpib_obj,['SOUR:VOLT:LEV:AMPL ' num2str(famp)]);
            pause(0.1);
        end

        function set_arb(obj,Vpp,t1,Vpp2)
            %% The following script demonstrates how to create the sequence
            %  via ww257x IVI-C driver
            %
            %  Author: Irina Tseitlin
            %  email:  support@taborelec.com
            %
            %  Copyright (C) 2005-2021 Tabor Electronics Ltd
            %  $Revision: 3.0.0 $  $Date: 22/02/2021 15:07:00 $


            % Open connection to instrument with address
            fclose(obj.gpib_obj);
            dev = icdevice('ww257x_64.mdd', 'COM16');

            try
                connect(dev);

                % Reset device
                groupCnf = get(dev, 'Utility');
                invoke(groupCnf, 'reset')

                % Set the sample clock
                filedir='C:\Users\qegpi\Desktop\sound files\';
                seg=1;
                pha=[0,0];
                amp=[Vpp2/Vpp, 1];
                amp=amp/max(amp);
                amp=1;
                freq=1953.125; %square
                %freq=1801.8018; %pentagon
                cyc=floor(t1*freq);
                n=2048;
                for ind=1:seg
                    fn{ind}=[filedir 'arbwfm' num2str(floor(freq)) ' ' num2str(ind) '.asc'];
                    [Fs]=wfmgen(fn{ind},freq,n,pha(ind),amp(ind));
                end

                groupArb = get(dev, 'Configurationfunctionsarbitraryoutput');
                invoke(groupArb, 'configuresamplerate', Fs)

                % Create three segments in the channel A and load waves in them
                groupArb = get(dev, 'Configurationfunctionsarbitraryoutputarbitrarywaveform');

                %   wavesdir = 'C:\Program Files\IVI Foundation\IVI\Drivers\ww257x\examples\matlab\waves\';
                %   wavesdir = 'C:\Users\qegpi\Desktop\sound files\';
                for ind=1:seg
                    wfmHandle(ind) = invoke(groupArb, 'loadarbwfmfromfile', 'CHAN_A', fn{ind});
                end

                % Create the sequence in the active channel, currently the active
                % channel is A because the 'loadarbwfmfromfile' function used with 'CHAN_A'
                % parameter %% Sequence Description:
                %  Step #              Segment #               Repeats Count
                %  [ 1 ]    [ Segment 1 ( sine_1kpts.wav )]         [ 2 ]
                %  [ 2 ]    [ Segment 2 ( dc_256pts.wav ) ]         [ 3 ]
                %  [ 3 ]    [ Segment 3 ( am_ramp_2kpts.wav )]      [ 1 ]
                %
                groupArb = get(dev, 'Configurationfunctionsarbitraryoutputarbitrarysequence');
                seqHandle = invoke(groupArb, 'createarbsequence', seg , wfmHandle, cyc*ones(1,seg));

                % Create the sequence in the active channel, currently the active
                groupCnf = get(dev, 'Configuration');

                % Output Modes:
                %  0 - Standard waveform
                %  1 - Arbitrary
                %  2 - Sequence
                %  3 - Modulation
                invoke(groupCnf, 'configureoutputmode', 2)

                % Output enable
                %invoke(groupCnf, 'configureoutputenabled', 'CHAN_A', 1)

                % Output SYNC signal enable%% SYNC Types:
                %  0 - BIT
                %  1 - LCOM
                %   sync_type = 1;
                %   invoke(groupCnf, 'configuresyncsignal', wfmHandle1, sync_type, 1, 0)

                % Close the connection with instrument
                disconnect(dev);
                delete(dev);
            catch err
                % Close the connection with instrument
                fprintf(err.message);
                disconnect(dev);
                delete(dev);
            end
            
            fclose(obj.gpib_obj);
            %obj=TaborPM8572('COM16');
            fopen(obj.gpib_obj);
            obj.set_gate();
            obj.set_gate();
            obj.set_gate();
            fprintf(obj.gpib_obj,['SOUR:VOLT:LEV:AMPL ' num2str(Vpp)]);
            pause(0.1);
            fprintf(obj.gpib_obj,'OUTP:LOAD 1e6'); %puts the load to high Z
            pause(0.1);
            %obj.MW_RFOn(1);
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

        function set_AMmod(obj, CW_freq, modfreq,Vpp) %sets amplitude modulation mode with sinusoidal modulation on CH1
            fprintf(obj.gpib_obj, 'INIT:CONT ON');
            pause(0.1);
            fprintf(obj.gpib_obj, 'INST:SEL 1');
            pause(0.1);
            fprintf(obj.gpib_obj,'FUNC:MODE MOD');
            pause(0.1);
            fprintf(obj.gpib_obj, 'SOUR:MOD:TYPE AM');
            pause(0.1);
            fprintf(obj.gpib_obj, ['SOUR:MOD:CARR' num2str(CW_freq)]);
            pause(0.1);
            fprintf(obj.gpib_obj, 'AM:FUNC:SHAP SIN');
            pause(0.1);
            fprintf(obj.gpib_obj,['AM:MOD:FREQ' num2str(modfreq)]);
            pause(0.1);
            fprintf(obj.gpib_obj,['SOUR:VOLT:LEV:AMPL ' num2str(Vpp)]);
            pause(0.1);
        end

        function MW_Close(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
                fclose(serialObj(i));
            end
        end
        function MW_RFOn(obj,channo)
            fprintf(obj.gpib_obj, ['INST:SEL ' num2str(channo)]);
            pause(0.1);
            fprintf(obj.gpib_obj, 'OUTP ON');
            pause(0.1);
        end
        function MW_RFOff(obj,channo)
            fprintf(obj.gpib_obj, ['INST:SEL ' num2str(channo)]);
            pause(0.1);
            fprintf(obj.gpib_obj,'OUTP OFF');
            pause(0.1);
        end
        function delete(obj)
            fclose(obj.gpib_obj);
            fprintf('Object closed\n');
        end
    end
end