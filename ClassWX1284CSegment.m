classdef ClassWX1284CSegment < handle
    %Created by Jean-Christophe Jaskula, MIT 2015
    properties
        segNb;
        AWF
        m1;
        m2;
        dt;
        renormed=0;
    end
    
    methods
        function obj = ClassWX1284CSegment(segNb,dt, npoints)
            global debug
            obj.segNb = segNb;
            obj.dt = dt;
            
            % test npoints that must verify npoints-192 must be divisible by 16
            
            npoints_adjusted = round((npoints-192)/16)*16+192;
            if npoints_adjusted < 192
                npoints_adjusted = 192;
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
        
        function addPulse(obj, starttime, durationPulse, level, markers)
            obj.addSquarePulse(starttime, durationPulse, level)
            obj.addMarkerPulse(starttime, durationPulse, markers)
            disp_debug('ClassWX12084CSegment.addPulse() is for backward compatibilty, please use addSquarePulse()');
        end
        
%         function addSinePulse(obj, starttime, pulseDuration, amp, freq, phase)            
%             npoints=length(obj.AWF);
%             starttimeIdx = roundCheck(starttime, obj.dt)+1;
%             durationPts =  roundCheck(pulseDuration, obj.dt);
%           
%             if starttimeIdx > 0 && starttimeIdx + durationPts < npoints0
%                 obj.AWF(starttimeIdx:starttimeIdx+durationPts) = amp*sin(2*pi*freq*obj.dt*(0:durationPts) + 2*pi*freq*starttime + phase);
%             else
%                 error('Pulse out of bounds');
%             end
%         end
        
        function addSinePulse(obj, starttime, pulseDuration, amp, freq, phase)
            npoints=length(obj.AWF);
            starttimeIdx = roundCheck(starttime, obj.dt);
            durationPts =  roundCheck(pulseDuration, obj.dt);
            
            if starttimeIdx >= 0 && starttimeIdx + durationPts < npoints
                obj.AWF = obj.AWF + amp*exp(-18*((0:npoints-1)-starttimeIdx-0.5*durationPts).^2/(durationPts).^2).*sin(2*pi*freq*obj.dt*(0:npoints-1) + phase);
            else
                error('Pulse out of bounds');
            end
        end

%         function addGaussianSinePulse(obj, starttime, pulseDuration, amp, freq, phase)
%             npoints=length(obj.AWF);
%             starttimeIdx = roundCheck(starttime, obj.dt)+1;
%             durationPts =  roundCheck(pulseDuration, obj.dt);
%             
%             c = starttimeIdx + durationPts/2;
%             d = durationPts;
%             
%             if starttimeIdx > 0 && starttimeIdx + durationPts < npoints
%                 obj.AWF = obj.AWF + amp*[exp(2-8*((1:(c-d/2))-c).^2/d^2) ...
%                     ones(1,d) ...
%                     exp(2-8*(((c+d/2+1):npoints)-c).^2/d^2)].*sin(2*pi*freq*obj.dt*(0:npoints-1) + 2*pi*freq*starttime + phase);
%             else
%                 disp('Pulse out of bounds');
%             end
%         end

        
        
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
            WX1284CFunctionPool('transferAWF',obj);
%             err=strsplit(WX1284CFunctionPool('checkErr'),',');
%             if str2double(err{1})
%                 disp(err{2});
%             end
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
