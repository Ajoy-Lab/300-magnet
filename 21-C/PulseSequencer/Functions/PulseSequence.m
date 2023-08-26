classdef PulseSequence < handle
    
    properties
        
        Channels = [];
        
        % Software channels
        %Channels(1): Laser AOM; (PB channel 1 OR AWG channel 1 mk 1)
        %Channels(2): Electron MW controlled via switch;  (PB channel 2 OR AWG channel 1 mk 2)
        %Channels(3): SPD gate signaling when to acquire; (PB channel 3 OR AWG channel 2 mk 1)
        
        %Channels(4): 13C RF; needs AWG (AWG channel 3 output)
        %Channels(5): N RF; needs AWG (AWG channel 4 output)
        
        time_pointer = 0; % this is only a helper for the construction of the sequence
        
        SequenceName
        
        SampleRate % SampleRate with which sequence was built
        
        ShapedPulses % cell
        
        seq_error = 0; % this is the param that checks if sequence can be constructed
        % error = 1: length of shaped pulsed cannot be adapted to sequence
    end
    
    properties (Transient = true)
        Listeners
    end
    
    methods
        
        function [obj] = PulseSequence(varargin)
            
            if nargin == 3,
                obj.Channels = varargin{1};
                obj.SequenceName = varargin{2};
                obj.Listeners = varargin{3};
                
                % change the callbacks of the listners,
                for k=1:numel(obj.Listeners),
                    if isa(obj.Listeners{k},'event.listener'),
                        obj.Listeners{1,k}.Callback = @(src,evnt)obj.throwEvent();
                    end
                end
                
            elseif nargin == 2,
                
                obj.Channels = varargin{1};
                obj.SequenceName = varargin{2};
                
                % loop over channels, adding listeners
                for k=1:length(obj.Channels),
                    obj.Listeners{1,k} = ...
                        addlistener(obj.Channels(k),'PulseSequenceChangedState',@(src,evnt)obj.throwEvent());
                end
                
            end
        end
        
        function [minTime] = GetMinRiseTime(obj)
            
            minTime = 1e15; % initialize to something big
            
            for j = 1:1:length(obj.Channels)
                
                if obj.Channels(j).Enable
                    temp = min(obj.Channels(j).RiseTimes);
                    if temp < minTime
                        minTime = temp;
                    end
                end
            end
            
        end
        
%         function [maxTime] = GetMaxTime(obj)
%             
%             maxTime = 0; %initialize to something small
%             
%             for n = 1:1:length(obj.Channels)
%                 if obj.Channels(n).Enable
%                     temp = max(obj.Channels(n).RiseTimes + obj.Channels(n).RiseDurations);
%                     if temp > maxTime
%                         maxTime = temp;
%                     end
%                 end
%             end
%         end
        
        function [] = throwEvent(obj)
            
            notify(obj,'PulseSequenceChangedState');
            
        end
        
        function [] = copy_seq(obj, obj2) %makes a copy of channel obj2
            
            for k=1:1:length(obj2.Channels)
                obj.Channels = [obj.Channels PulseChannel()];
                obj.Channels(k).copy_values(obj2.Channels(k));
            end
            obj.SequenceName = obj2.SequenceName;
            obj.Subsequences = obj2.Subsequences;
            
        end
        
    end
    
    methods (Static = true)
        
        function [obj] = loadobj(a)
            
            % add in the listeners, which should not be saved
            
            for k=1:numel(a.Channels),
                a.Listeners{1,k} = ...
                    addlistener(a.Channels(k),'PulseSequenceChangedState',@(src,evnt)a.throwEvent());
            end
            
            if  sum(strcmp(fieldnames(a),'Listeners')),
                obj = PulseSequence(a.Channels,a.SequenceName,a.Listeners);
            else
                obj = PulseSequence(a.Channels,a.SequenceName);
            end
        end
        
    end
    
    events
        
        PulseSequenceChangedState
        
    end
    
end
