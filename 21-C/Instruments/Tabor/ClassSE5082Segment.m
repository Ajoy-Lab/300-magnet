classdef ClassSE5082Segment < handle
    % Created by Jean-Christophe Jaskula, MIT 2015
    properties
        segNb;
        AWF
        m1;
        m2;
        dt;
        renormed=0;
    end
    
    methods
        function obj = ClassSE5082Segment(segNb,dt, npoints)
            global debug
            obj.segNb = segNb;
            obj.dt = dt;
            
            % test npoints that must verify npoints-384 must be divisible by 32
            npoints_adjusted = round((npoints-384)/32)*32+384;
            if npoints_adjusted < 384
                npoints_adjusted = 384;
            end
            if ~isempty(debug) && debug >= 1 && (npoints_adjusted ~= npoints)
                disp(['Number of points needed to be adjusted to ' num2str(npoints_adjusted)]);
            end
            obj.AWF = zeros(1, npoints_adjusted);
            obj.m1  = zeros(1, npoints_adjusted);
            obj.m2  = zeros(1, npoints_adjusted);
        end
        
        function addSquarePulse(obj, starttime, pulseDuration, level)            
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts =  roundCheck(pulseDuration, obj.dt);
            
            if starttimeIdx > 0 && starttimeIdx + durationPts < npoints
                obj.AWF(starttimeIdx:starttimeIdx+durationPts) = level*ones(1,durationPts+1);
            else
                error('Pulse out of bounds');
            end
        end
        
        function addMarkerPulse(obj, starttime, pulseDuration, markers)            
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts =  roundCheck(pulseDuration, obj.dt);
            
            if starttimeIdx > 0 && starttimeIdx + durationPts < npoints
                obj.m1(starttimeIdx:starttimeIdx+durationPts) =  markers(1)*ones(1,durationPts+1);
                obj.m2(starttimeIdx:starttimeIdx+durationPts) =  markers(2)*ones(1,durationPts+1);
            else
                error('Pulse out of bounds');
            end
        end
        
%         function addPulse(obj, starttime, durationPulse, level, markers)
%             obj.addSquarePulse(starttime, durationPulse, level)
%             obj.addMarkerPulse(starttime, durationPulse, markers)
%             disp_debug('ClassSE5082Segment.addPulse() is for backward compatibilty, please use addSquarePulse()');
%         end
        
        function addSinePulse(obj, starttime, pulseDuration, amp, freq, phase)            
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts =  roundCheck(pulseDuration, obj.dt);
          
            if starttimeIdx > 0 && starttimeIdx + durationPts <= npoints
                obj.AWF(starttimeIdx:starttimeIdx+durationPts) = amp*sin(2*pi*freq*obj.dt*(0:durationPts) + 2*pi*freq*starttime + phase);
            else
                error('Pulse out of bounds');
            end
        end
        
        function addChirpPulse(obj, starttime, pulseDuration, amp, startfreq, stopfreq, phase)            
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts =  roundCheck(pulseDuration, obj.dt);
          
            if starttimeIdx > 0 && starttimeIdx + durationPts <= npoints
                inst_freq=startfreq + (stopfreq-startfreq)/2*[0:durationPts]*obj.dt/pulseDuration;
                obj.AWF(starttimeIdx:starttimeIdx+durationPts) = ...
                    amp*sin(2*pi.*inst_freq*obj.dt.*[0:durationPts] + 2*pi.*inst_freq*starttime +phase);
            else
                error('Pulse out of bounds');
            end
        end
        %%%%%%%%%%% Sweepers
        function addChirpPulseSweepers(obj, starttime, pulseDuration, amp, startfreq, stopfreq, phase)            
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts =  roundCheck(pulseDuration, obj.dt);
          
            if starttimeIdx > 0 && starttimeIdx + durationPts <= npoints
                inst_freq_1=startfreq + (stopfreq-startfreq)/2*[0:durationPts]*obj.dt/pulseDuration;
                inst_freq_2=circshift(inst_freq_1,[1 floor(durationPts/3)]);
                inst_freq_3=circshift(inst_freq_1,[1 floor(2*durationPts/3)]);
                obj.AWF(starttimeIdx:starttimeIdx+durationPts) = ...
                    amp/3*sin(2*pi.*inst_freq_1*obj.dt.*[0:durationPts] + 2*pi.*inst_freq_1*starttime +phase)...
                    + amp/3*sin(2*pi.*inst_freq_2*obj.dt.*[0:durationPts] + 2*pi.*inst_freq_2*starttime +phase)...
                    + amp/3*sin(2*pi.*inst_freq_3*obj.dt.*[0:durationPts] + 2*pi.*inst_freq_3*starttime +phase);
            else
                error('Pulse out of bounds');
            end
        end
        %%%%%%%%%%%
        
        function phase_next = addChirpPulse11(obj, starttime, pulseDuration, amp, startfreq, stopfreq, phase)            
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts =  roundCheck(pulseDuration, obj.dt);
          
            if starttimeIdx > 0 && starttimeIdx + durationPts <= npoints
                inst_freq=startfreq + (stopfreq-startfreq)/2*[0:durationPts]*obj.dt/pulseDuration;
                sin_arg = 2*pi.*inst_freq*obj.dt.*[0:durationPts] +phase;
                obj.AWF(starttimeIdx:starttimeIdx+durationPts) = ...
                    amp*sin(sin_arg);
            else
                error('Pulse out of bounds');
            end
            %phase_next = sin_arg(end);
            phase_next = 0;
        end
        
        function addCustomChirpPulse(obj, time_bins, amp, startfreq, stopfreq, phase)            
            freqs = linspace(startfreq, stopfreq, length(time_bins));
             phase_next = phase;
            for i = 1:(length(time_bins)-1)
                pulse_duration = time_bins(i+1)-time_bins(i);
                 phase_next = addChirpPulse11(obj, time_bins(i), pulse_duration, amp, freqs(i), freqs(i+1), phase_next);
%                  addChirpPulse(obj, time_bins(i), pulse_duration, amp, freqs(i), freqs(i+1), 0);
            end
        end
        
        %%%%%%%%%%% For multiple sweepers
        function phase_next = addChirpPulseSweepers2(obj, starttime, pulseDuration, amp, startfreq, stopfreq, phase)            
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts =  roundCheck(pulseDuration, obj.dt);
          
            if starttimeIdx > 0 && starttimeIdx + durationPts <= npoints
                inst_freq_1=startfreq + (stopfreq-startfreq)/2*[0:durationPts]*obj.dt/pulseDuration;
                inst_freq_2=rem(startfreq + (stopfreq-startfreq)/2 + (stopfreq-startfreq)/2*[0:durationPts]*obj.dt/pulseDuration,stopfreq);
                inst_freq_3=rem(startfreq + (stopfreq-startfreq) + (stopfreq-startfreq)/2*[0:durationPts]*obj.dt/pulseDuration,stopfreq);
                sin_arg_1 = 2*pi.*inst_freq_1*obj.dt.*[0:durationPts] +phase(1);
                sin_arg_2 = 2*pi.*inst_freq_2*obj.dt.*[0:durationPts] +phase(2);
                sin_arg_3 = 2*pi.*inst_freq_3*obj.dt.*[0:durationPts] +phase(3);
                obj.AWF(starttimeIdx:starttimeIdx+durationPts) = ...
                    amp*sin(sin_arg_1)/3+amp*sin(sin_arg_2)/3+amp*sin(sin_arg_3)/3;
            else
                error('Pulse out of bounds');
            end
            phase_next(1) = sin_arg_1(end);
            phase_next(2) = sin_arg_2(end);
            phase_next(3) = sin_arg_3(end);
            %phase_next = 0;
        end   
        
        function addCustomChirpPulseSweepers(obj, time_bins, amp, startfreq, stopfreq, phase)            
            freqs = linspace(startfreq, stopfreq, length(time_bins));
             phase_next = [phase,phase,phase];
            for i = 1:(length(time_bins)-1)
                pulse_duration = time_bins(i+1)-time_bins(i);
                 phase_next = addChirpPulseSweepers2(obj, time_bins(i), pulse_duration, amp, freqs(i), freqs(i+1), phase_next);
%                  addChirpPulse(obj, time_bins(i), pulse_duration, amp, freqs(i), freqs(i+1), 0);
            end
        end
         %%%%%%%%%%%%%%%%%%%%%%%%%%
        

        
        function addTwoChirpPulse(obj, starttime,pulseDuration, amp, startfreq, stopfreq, phase1, phase2)
            % Adds two chirp pulses at specified phases
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts =  roundCheck(pulseDuration, obj.dt);
          
            if starttimeIdx > 0 && starttimeIdx + durationPts < npoints
                inst_freq=startfreq + (stopfreq-startfreq)/2*[0:durationPts]*obj.dt/pulseDuration;
                obj.AWF(starttimeIdx:starttimeIdx+durationPts) = ...
                    amp*sin(2*pi.*inst_freq*obj.dt.*[0:durationPts] + 2*pi.*inst_freq*starttime +phase1) + ...
                    amp*sin(2*pi.*inst_freq*obj.dt.*[0:durationPts] + 2*pi.*inst_freq*starttime +phase2);
            else
                error('Pulse out of bounds');
            end
        end  
        
        function addNChirpPulse(obj, starttime, pulseDuration, amp, startfreq, stopfreq, N, phase)
            % Adds N chirp pulses, with equal spacing of phase shifts throughout one period
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts = roundCheck(pulseDuration, obj.dt);
          
            if starttimeIdx > 0 && starttimeIdx + durationPts < npoints
                inst_freq=startfreq + (stopfreq-startfreq)*[0:durationPts]*obj.dt/pulseDuration;
%                 initial = amp*sin(2*pi.*inst_freq*obj.dt.*[0:durationPts] + 2*pi.*inst_freq*starttime +startphase);
                initial = 0;
                for i = 1:N
                    initial = initial + amp*sin(2*pi.*inst_freq*obj.dt.*[0:durationPts] + 2*pi.*inst_freq*starttime + phase+(2*pi/i));
                end
                obj.AWF(starttimeIdx:starttimeIdx+durationPts) = initial;
            else
                error('Pulse out of bounds');
            end
        end
    
        function addTreePulse(obj, starttime, pulseDuration, amp, startfreq, deltafreq, phase)
            % Chirp pulse with up-chirp and down-chirp added together
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt)+1;
            durationPts =  roundCheck(pulseDuration, obj.dt);
            downfreq = startfreq - (deltafreq - startfreq);
          
            if starttimeIdx > 0 && starttimeIdx + durationPts < npoints && downfreq > 0
                inst_freq1=startfreq + (deltafreq-startfreq)/2*(0:durationPts)*obj.dt/pulseDuration;
                inst_freq2=startfreq + (downfreq-startfreq)/2*(0:durationPts)*obj.dt/pulseDuration;
                obj.AWF(starttimeIdx:starttimeIdx+durationPts) = ...
                    amp*sin(2*pi.*inst_freq1*obj.dt.*[0:durationPts] + 2*pi.*inst_freq1*starttime +phase) + ...
                    amp*sin(2*pi.*inst_freq2*obj.dt.*[0:durationPts] + 2*pi.*inst_freq2*starttime +phase);
            else
                error('Pulse out of bounds');
            end
        end
        
        function addGaussianSinePulse(obj, starttime, pulseDuration, amp, freq, phase)
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt);
            durationPts =  roundCheck(pulseDuration, obj.dt);
            if starttimeIdx >= 0 && starttimeIdx + durationPts < npoints
                obj.AWF = obj.AWF + amp*exp(-18*((0:npoints-1)-starttimeIdx-0.5*durationPts).^2/(durationPts).^2).*sin(2*pi*freq*obj.dt*(0:npoints-1) + phase);
            else
                error('Pulse out of bounds');
            end
        end
        
        function plot(obj, figNb)
            if nargin < 2
                figure
            else
                figure(figNb)                
            end        
            hold on;
            plot((0:length(obj.AWF)-1)*obj.dt ,obj.AWF);
            plot((0:length(obj.AWF)-1)*obj.dt ,obj.m1 + 1.5);
            plot((0:length(obj.AWF)-1)*obj.dt ,obj.m2 + 3);  
            ylim([min(obj.AWF)-.5 max(obj.m2)+ 3.5]);
            hold off;
        end
        
        function upload(obj)
            try
            SE5082FunctionPool('transferAWF',obj);
            catch
                pause(1);
                SE5082FunctionPool('transferAWF',obj);
            end
        end
    end
end

function rNb = roundCheck(nb, units)
    global debug
    rNb = round(nb/units);
    if ~isempty(debug) && debug > 1 && abs(rNb*units - nb) > units/100
       disp([inputname(1) ' = ' num2str(nb/units) ' rounded to ' num2str(rNb)]);
    end
end
