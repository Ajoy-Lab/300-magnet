classdef ClassWX1284CSequence < handle
    %Created by Jean-Christophe Jaskula, MIT 2015
    properties
        seqNb;
        steps;
    end
    
    methods
        function obj = ClassWX1284CSequence(seqNb)
            obj.seqNb = seqNb;
            
            obj.steps = {};
        end
        
        function addStep(obj, segNb, loops, jflg, idx)
            if nargin < 5
                obj.steps{end+1}=[loops, segNb, jflg];
            else
                obj.steps= {obj.steps{1:idx-1} [loops, segNb, jflg] obj.steps{idx:end}};
            end
        end
        
        function removeStep(obj, idx)
            obj.steps= {obj.steps{1:idx-1} obj.steps{idx+1:end}} ;
        end
        
        function plot(obj, figNb)
%             if nargin < 2
%                 figure
%             else
%                 figure(figNb)                
%             end
%             
%             hold on;
%             plot((1:length(obj.AWF))*obj.dt ,obj.AWF);
%             plot((1:length(obj.AWF))*obj.dt ,obj.m1 + 1.5);
%             plot((1:length(obj.AWF))*obj.dt ,obj.m2 + 3);
%             
%             ylim([min(obj.AWF)-.5 max(obj.m2)+ 3.5]);
%             hold off;
        end
        
        function upload(obj)
            WX1284CFunctionPool('createSEQ',obj);
        end
    end
end