classdef WindFreak < handle
    %WINDFREAK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        deviceName
        boolOnOff=0
        freq=350e6 %Hz
        amp=-15 %dBm
        refClock=1 %internal
        port='com16'
        serialObj
    end
    
    methods
        function [obj] = WindFreak(port,freq,amp)        
            if nargin>2
                obj.amp=amp;
            end
            if nargin>1
                obj.freq=freq;
            end
            if nargin>0
                obj.port=port;
            end

            obj.init;
            obj.open;
            obj.setAmp(obj.amp);
            obj.setFreq(obj.freq);
            obj.setClockRef(obj.refClock);
            obj.setOnOff(obj.boolOnOff);
            obj.close;
        end

        function [err]=init(obj)
            try
                % Serial protocol
                err=0;
                obj.serialObj = serial({obj.port},'baudrate',115200,'databits',8,'parity','none','stopbits',1,'flowcontrol','none');
                %obj.serialObj = serial(obj.port);
                disp('Serial protocol initialized.');
            catch exception
                err=1;
                %evalin('base','sobj = instrfindall(''Type'',''serial'',''port'',''COM5'');');
                %evalin('base','delete(sobj);');
                disp('Error to init serial protocol.');
            end
        end
        
        function [err]=open(obj)            
            try
                err=0;
                if strcmp(get(obj.serialObj,'status'),'closed')
                    fopen(obj.serialObj);
                    disp('Serial connection to WindFreak opened.');
                end
            catch exception
                try
                    evalin('base','sobj = instrfindall(''Type'',''serial'',''port'',obj.port);');
                    evalin('base','delete(sobj);');
                    evalin('base','clear sobj;');
                    disp('Previous serial connection to WindFreak deleted.'); 
                    obj.init;
                    fopen(obj.serialObj);
                    disp('Serial connection to WindFreak opened.');                
                catch exception
                    err=1;
                    disp('Error to open serial connection to WindFreak.');
                end
            end
        end
        
        function [err]=close(obj)            
            err=0;
            try
                %obj.setFreq(obj.freq,0);
                if strcmp(get(obj.serialObj,'status'),'open')
                    fclose(obj.serialObj);
                    disp('Serial connection to WindFreak closed.');                
                end
            catch exception
                disp('Error to close serial connection to WindFreak.');
                err=1;
            end
        end
        
        function [err]=delete(obj)            
            try
                delete(obj.serialObj);
                obj.serialObj=[];
                %evalin('base','sobj = instrfindall(''Type'',''serial'',''port'',obj.port);');
                %evalin('base','delete(sobj);');
                %evalin('base','clear sobj;');
                disp('Serial connection to WindFreak deleted.');                
            catch exception
                disp('Error to delete serial connection to WindFreak.');
                err=1;
            end
        end
        
        function [] = setOnOff(obj,boolOnOff)
        obj.boolOnOff=boolOnOff;
            if strcmp(get(obj.serialObj,'status'),'closed')
                obj.open;
                fprintf(obj.serialObj,'%s',['o',num2str(boolOnOff)])
                obj.close;
            else
                fprintf(obj.serialObj,'%s',['o',num2str(boolOnOff)])
            end
        end
        
        function [] = setFreq(obj,freq)
        % freq - frequency in Hz
        obj.freq=freq;
        
        bool_close=0;
        if strcmp(get(obj.serialObj,'status'),'closed')
                obj.open;
                bool_close=1;
        end
        
        freq=freq*1e-6; %Hz->MHz
        if length(regexp(num2str(freq),'\.','split'))==1
            fprintf(obj.serialObj,'%s',['f',num2str(freq),'.0']);
        else
            fprintf(obj.serialObj,'%s',['f',num2str(freq)]);
        end
                
        if bool_close
                obj.close;
        end
        end
        
        function [] = setAmp(obj,amp)
            % amp in dBm specified by user [-16.5,15]
            % amp set by choosing pdB in dB below maximal output power, which is ~15dBm
                       
            % hardware limitations
            if (amp>15)
                amp=15; %15dBm
            end
            if (amp<-16.5)
                amp=-16.5; %-16.5dBm
            end
            

            %calibration factor to match SG2 after power combiner
            %amp=amp+5;

            %amplifier protection (-3dBm), with isolation loss
%             if (amp>-3)
%                 amp=-3;
%             end
            
            %amp by steps of 0.5
            pNorm = floor(2*amp+33); %in [0,63]
            obj.amp=(pNorm-33)/2; %real amp
                        
            if strcmp(get(obj.serialObj,'status'),'closed')
                obj.open;
                fprintf(obj.serialObj,'%s',['a',num2str(pNorm)]);
                obj.close;
            else
                fprintf(obj.serialObj,'%s',['a',num2str(pNorm)]);
            end
        end

        
        function [] = setClockRef(obj,refClock)
            % Control whether the device operates on internal ('1') or
            % external ('0') reference clock
            obj.refClock=refClock;
           
            if strcmp(get(obj.serialObj,'Status'),'closed')
                obj.open;
                fprintf(obj.serialObj,'%s',['x',num2str(refClock)]);
                obj.close;
            else
                fprintf(obj.serialObj,'%s',['x',num2str(refClock)]);
            end

            if refClock==0
            disp('RefClock set to external.'); 
            else
            disp('RefClock set to internal.'); 
            end  
        end
    end
end

