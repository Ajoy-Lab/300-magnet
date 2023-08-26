classdef PulseChannel < handle
    
    properties
        
        Enable         % Binary: true if in always on or pulsed mode; false if always off
        RiseTimes      % Array: times when a pulse turns on
        RiseDurations  % Array: duration of pulses
        NumberOfRises = 0;  % Scalar
        Frequency
        Amplitude      % in dBm
        Ampmod
        Phasemod
        FreqmodI % for channels that not MW, usual Freqmod; also used for I channel of MW if using AWG
        FreqmodQ % used exclusively for MW channel if using AWG
        AmpIQ
        FreqIQ
        Phase
        PhaseQ
        SymmTime1
        SymmTime2
        Parameter1
        Parameter2
        Parameter3
        Parameter4
        Parameter5
    end
    
    methods
        
        function [obj] = PulseChannel()
            % Instantiation function
            
        end
        
        function [obj] = addRise(obj,VecT,VecDT) % add rise parametrized by T of turn on, DT of duration; channel indicated whether shift is enabled
            
            [obj.RiseTimes, indices] = sort([obj.RiseTimes, VecT]);
            a = [obj.RiseDurations, VecDT];
            obj.RiseDurations = a(indices);
            obj.NumberOfRises = obj.NumberOfRises + length(VecT);
            obj.combine_rises();
            
        end
        
        function [] = combine_rises(obj)
            
            % checks if rises can be combined, i.e. if a fall happens at the same time as a rise
            
            [obj.RiseTimes, indices] = sort(obj.RiseTimes);
            obj.RiseDurations = obj.RiseDurations(indices);
            
            fall_times = obj.RiseTimes + obj.RiseDurations;
            
            combine_indices = [];
            for k = 2:length(obj.RiseTimes)
                if (obj.RiseTimes(k) == fall_times(k-1))
                    combine_indices = [combine_indices k];
                end
            end
            
            if ~isempty(combine_indices)
                
                combine_indices = sort(combine_indices, 'descend');
                
                % combine the rises by prolonging the previous rise and deletin the next rise
                for k = combine_indices
                    obj.RiseDurations(k-1) = obj.RiseDurations(k-1) + obj.RiseDurations(k);
                end
                obj.RiseTimes(combine_indices) = [];
                obj.RiseDurations(combine_indices) = [];
                
                obj.NumberOfRises = obj.NumberOfRises - length(combine_indices);
            end
        end
        
        function [] = copy_values(obj, obj2) %makes a copy of a channel obj2
            
            obj.Enable = obj2.Enable;
            obj.RiseTimes = obj2.RiseTimes;
            obj.RiseDurations = obj2.RiseDurations;
            obj.NumberOfRises = obj2.NumberOfRises;
            obj.ChannelType = obj2.ChannelType;
            obj.ChannelNumber = obj2.ChannelNumber;
            obj.Frequency = obj2.Frequency;
            obj.Amplitude = obj2.Amplitude;
        end
        
    end
    
    events
        PulseSequenceChangedState
    end
end
