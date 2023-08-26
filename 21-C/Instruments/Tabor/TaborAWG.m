classdef TaborAWG < handle   
    properties            
        SocketHandle;
        samprate=4.5e9;
        starttime=100e-9;
        TotalSegNb=1;
        percentage=10;
        iseg=1;
        seg;
    end
    
    methods      
        function [obj] = TaborAWG()    
          try
            amp=0.1;
            obj.prepareSE5082(amp);
            
            obj.samprate=4e9; % at least 10 times faster than the highest frequency of the sequence, arbitrary
            dt=1/ obj.samprate;
            obj.starttime=100e-9; % 100ns
            
            Pio2PulsePhase = 0;
             obj.percentage=10;
             obj.TotalSegNb=1;
             obj.iseg=1;
             obj.awg_stop();
             
          catch
              disp('Error to initialize Tabor AWG');
          end
        end
        
        function [obj] = awg_reset(obj)      
            amp=0.1;
           obj.prepareSE5082(amp);
        end
        
        
        function [obj] = awg_sine(obj,freq,amp,phase,T)           
            dt=1/ obj.samprate;
            %CONSTRAINt: number of points div by 32, and min 384    
%             npoints=bufferBeg + round(T/dt) + bufferEnd; % number of points
            npoints=round2(T/dt,32)-1; % number of points
            if npoints<384
                npoints=384;
            end
            T_modif=npoints*dt; %override T with the constraints of number of points
            obj.seg = ClassSE5082Segment(obj.iseg, dt, npoints); % create a segment with size npoints
            obj.starttime=0;
            obj.seg.addSinePulse(obj.starttime, T_modif, amp,freq, phase);
            start_fig(1,[3 2]);
            plot_preliminaries(1:size(obj.seg.AWF,2),obj.seg.AWF,2,'nomarker'); % plot the pulse sequence
            plot_labels('Points','Amplitude');
        end
        
          function [obj] = awg_chirp(obj,start_freq,stop_freq,amp,phase,T,sweepers_en)           
            dt=1/ obj.samprate;
            %CONSTRAINt: number of points div by 32, and min 384    
%             npoints=bufferBeg + round(T/dt) + bufferEnd; % number of points
            npoints=round2(T/dt,32)-1; % number of points
            if npoints<384
                npoints=384;
            end
            T_modif=npoints*dt; %override T with the constraints of number of points
            obj.seg = ClassSE5082Segment(obj.iseg, dt, npoints); % create a segment with size npoints
            obj.starttime=0;
            
            if sweepers_en == 0
                obj.seg.addChirpPulse(obj.starttime, T_modif, amp, start_freq, stop_freq, phase);
            else
                obj.seg.addChirpPulseSweepers(obj.starttime, T_modif, amp, start_freq, stop_freq, phase);
            end
%             start_fig(1,[3 2]);
%             plot_preliminaries(1:size(obj.seg.AWF,2),obj.seg.AWF,2,'nomarker'); % plot the pulse sequence
%             plot_labels('Points','Amplitude');
          end
        
      function [obj] = awg_custom_chirp(obj,start_freq,stop_freq,amp,phase,T,num_bins,sweep_sigma,sweepers_en)           
            dt=1/ obj.samprate;
            %CONSTRAINt: number of points div by 32, and min 384    
%             npoints=bufferBeg + round(T/dt) + bufferEnd; % number of points
            npoints=round2(T/dt,32)-1; % number of points
            if npoints<384
                npoints=384;
            end
            T_modif=npoints*dt; %override T with the constraints of number of points
            
            % strange cdf
            freqs = linspace(start_freq, stop_freq, num_bins);
            
            ts_lin = linspace(0, 1, num_bins); %linear ramp
            
            %func_cdf = @(a) (a/6e9).^2;ts = func_cdf(freqs);
            %time_bins_func = T_modif.*ts./func_cdf(stop_freq);

            ts_norm = normcdf(freqs, (start_freq + stop_freq)/2, (stop_freq - start_freq)/sweep_sigma);
            ts_bias = linspace(ts_lin(1)-ts_norm(1),ts_lin(end)-ts_norm(end),num_bins);
            
            artb = load('single_crystal_ESR.mat');
            raw_time_dwell_array = abs(artb.enhancementFactor42);
            rtb_size = sum(raw_time_dwell_array);
            
            raw_time_bins_array = cumsum(raw_time_dwell_array);
            time_bins_array = raw_time_bins_array.*(T_modif/rtb_size);
%             disp(rtb_size);
%             disp(time_bins_array(end));
            time_bins_lin = T_modif*(ts_lin);
            time_bins_norm = T_modif*(ts_norm+ts_bias);
            
            %***************************************
            % Gaussian sweep, uncomment to select. for linear sweep choose
            % sigma to be smallest (0.1)
            time_bins = time_bins_norm;
            % Array sweep, uncomment to select
%             time_bins = time_bins_array;
            %***************************************
            

            %%%%%%%%%% Plot frequency sweep distribution
%             start_fig(1,[2 2]);
%             %plot_preliminaries(freqs(1:end)/1e6,time_bins_norm,2,'nomarker');
%             %p1=plot_preliminaries(freqs(1:end)/1e6,time_bins_lin,1,'nomarker');set(p1,'linestyle','--');
%             plot_preliminaries(freqs(1:end-1)/1e6,diff(time_bins),2,'nomarker');
%             p1=plot_preliminaries(freqs(1:end-1)/1e6,diff(time_bins_lin),1,'nomarker');set(p1,'linestyle','--');
%             plot_labels('Frequency [MHz]','Dwell Time [s]');
%             set(gca,'xlim',[200 400]);
%             set(gca,'ylim',[0 200e-6]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            
            %normal distribution  
%             freqs = linspace(start_freq, stop_freq, num_bins);
%             ts = normcdf(freqs, (start_freq + stop_freq)/2, (stop_freq - start_freq)/4);
%             time_bins = T_modif*ts;
%             start_fig(1,[3 2]);
%             plot_preliminaries(freqs,time_bins,2,'nomarker');
%             plot_labels('frequency','time');
            
            %linear sweep
%             time_bins = linspace(0, T_modif, num_bins);

            obj.seg = ClassSE5082Segment(obj.iseg, dt, npoints); % create a segment with size npoints
            obj.starttime=0;
            if sweepers_en == 0
                obj.seg.addCustomChirpPulse(time_bins, amp, start_freq,stop_freq, phase);
            else
                obj.seg.addCustomChirpPulseSweepers(time_bins, amp, start_freq,stop_freq, phase);
            end
            %start_fig(1,[3 2]);
            %plot_preliminaries(1:size(obj.seg.AWF,2),obj.seg.AWF,2,'nomarker'); % plot the pulse sequence
            %plot_labels('Points','Amplitude');
            
%             disp(obj.seg.AWF);
        end
        
        
        function obj=awg_transfer(obj)
            disp('Transferring data to AWG...');
            try
            obj.seg.upload();
            catch
                obj.awg_reset();
                pause(1);
                obj.seg.upload();
            end
            
            s = warning('off','MATLAB:structOnObject');
            segstruct=struct(obj.seg);
            CHs{obj.seg.segNb}=segstruct;
            warning(s);
        end
        
         function obj=awg_start(obj)
             SE5082FunctionPool('setchn',2);
             SE5082FunctionPool('setoutput','on');
         end
        
         function obj=awg_stop(obj)
             SE5082FunctionPool('setchn',2);
             SE5082FunctionPool('setoutput','off');
         end
         
         function awg_hw_chirp(obj, start_freq, stop_freq, sweep_rate, direction, lin_log)
                fprintf('Setting up chirp modulation ');
                %Set modulation type: CHIRp
                SE5082FunctionPool('mod_type','chir');
                %Set Function to sin (default)
                SE5082FunctionPool('mod_carrier_type','sin');
                %Set all chirp parameters:
                %Set chirp start
                SE5082FunctionPool('chirp_start_freq',start_freq);
                %Set chirp stop
                SE5082FunctionPool('chirp_stop_freq',stop_freq);
                %Set chirp width; and check product of
                    %max(start,stop)*width between 10-4e4
                time_sweep = 1/(sweep_rate);
                if ~(40e3>max(start_freq,stop_freq)*time_sweep>10)
                    fprintf('Width * max(start,stop) should be between 10 and 40e3');
                    return;
                end
                SE5082FunctionPool('chirp_width',time_sweep);
                %Direction
                SE5082FunctionPool('chirp_direction',direction);
                %Lin Log
                SE5082FunctionPool('chirp_lin_log',lin_log);
                %No amplitude modulation/sweep
                SE5082FunctionPool('chirp_amp_ramp_depth',0);
                fprintf('done.\n');
         end        
        
        function prepareSE5082(obj, amp)
                fprintf('Preparing SE5082... ');
                SE5082FunctionPool('reset');
                SE5082FunctionPool('setchn',2);
                SE5082FunctionPool('eraseSeg','all');
                SE5082FunctionPool('setAmplitude',2*amp+.01);
                SE5082FunctionPool('setmode','user');
                SE5082FunctionPool('setTriggermode','cont'); % changed to continuous for testing purposes
                %     SE5082FunctionPool('setsamplingmode', 'RTZ');
                SE5082FunctionPool('setmarkersource','user');
                fprintf('done.\n');
        end
        function awg_chirp_center_span(obj,obj2,amp_awg,amp_lo, center_freq, bw, lo_freq,scan_freq)
                obj.awg_stop();
                obj.awg_chirp(lo_freq-(center_freq+bw/2),lo_freq-(center_freq-bw/2),amp_awg,0,1/scan_freq);
                obj2.set_freq(lo_freq);
                obj2.set_amp(amp_lo);
                tic; obj.awg_transfer();toc;
                pause(0.2);
                obj.awg_start();
        end
        

        
        
        function example_code(obj)
%             obj=TaborAWG();
%             obj.awg_sine(100e6,0.05,0,1e-6);
%             obj.awg_chirp(100e6,110e6,0.1,0,1e-4);       
% obj.awg_chirp(4e9-3.826e9,4e9-3.786e9,0.1,0,1/600);
%             tic; obj.awg_transfer();toc;
%             obj.awg_start();
%             obj.awg_stop();
%start_freq,stop_freq,amp,phase,T,num_bins
% obj.awg_custom_chirp(0,1000,0.1,0,1e-2, 10)



%               awg_chirp_center_span(obj,obj2,0.2,-3, 3.8015e9, 455e6, 4.1e9,20e3)
%   awg_chirp_center_span(obj,obj2,0.1,-3, 3.755e9, 440e6, 4.5e9,20e3)
%   awg_chirp_center_span(obj,obj2,0.1,-3, 3.55e9, 1e6, 4.5e9,5e3)
        end
    
    end
    
   
end

