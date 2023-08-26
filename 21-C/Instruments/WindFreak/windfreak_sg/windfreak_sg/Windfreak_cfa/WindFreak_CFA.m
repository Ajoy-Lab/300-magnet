classdef WindFreak_CFA < handle
    %WINDFREAK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        freq=350 %Hz
        pwrLevel=1
        pwrDown=0
        amp=-15 %dBm
        %refClock=1 %internal
        refClock=0 %external
        port
        serialObj
    end
    
    methods
        function [obj] = WindFreak_CFA(port,freq,amp)        
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
            obj.setClockRef(obj.refClock);
            obj.setFreq(obj.freq);
            obj.setAmp(obj.amp);
            obj.close;
        end

        function [err]=init(obj)
            try
                % Serial protocol
                err=0;
                %obj.serialObj = serial({obj.port},'baudrate',115200,'databits',8,'parity','none','stopbits',1,'flowcontrol','none');
                obj.serialObj = serial(obj.port);
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
                err = 0;
                fopen(obj.serialObj);
                disp('Serial connection to WindFreak opened.');                
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
            try
                %obj.setFreq(obj.freq,0);
                fclose(obj.serialObj);
                disp('Serial connection to WindFreak closed.');                
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
        
        function [] = setFreq(obj,freq,pwrLevel,pwrDown)
        % freq - frequency in Hz
        % pwrLevel - sets the power range to low (0) or (1)
        % pwrDown - ???
        
        freq=freq*1e-6; %Hz->MHz

        if (nargin<4)
        pwrDown = 0; %default: off
        end
        if (nargin<3)
        pwrLevel = 1; %default: high   
        end
        
        if (pwrLevel)
        pwrLevel = 1;
        end
        if (pwrDown)
        pwrDown = 1;
        end
        
        obj.freq=freq;
        obj.pwrLevel=pwrLevel;
        obj.pwrDown=pwrDown;
        
        freqbuf = WFGenerateBufferNV(freq,3,15,pwrLevel,pwrDown);
        fwrite(obj.serialObj,freqbuf);
        end
        
        function [] = setAmp(obj,amp)
            % amp in dBm specified by user [-16.5,15]
            % amp set by choosing pdB in dB below maximal output power, which is ~15dBm
            obj.amp=amp;
            %pdB=obj.amp-15;
            pdB=obj.amp-21;
            
            % hardware limitations
            if (pdB<-31.5)
                pdB = -31.5; %-16.5dBm
            end
            if (pdB>0)
                pdB = 0; %15dBm
            end
            
%             % amplifier protection (-3dBm)
%             if (pdB>-18)
%                 pdB = -18; %-3dBm
%             end
%             
            % amplifier protection (+8.5dBm)
            if (pdB>-12.5)
                pdB = -12.5; %-3dBm
            end
            
            
            pwrbyte = dec2bin(pdB*2+63);
            filler = strrep(blanks(8-length(pwrbyte)),' ','0');
            pwrBuf = fliplr([filler pwrbyte]);
            pwrBuf(7:8) = '11';
            pwrBuf = [3 uint8(bin2dec(fliplr(pwrBuf)))];
            
            fwrite(obj.serialObj,pwrBuf);           
        end

        
        function [] = setClockRef(obj,refClock)
            % Control whether the device operates on internal ('1') or
            % external ('0') reference clock
            obj.refClock=refClock;
            refBuf = [uint8(6) uint8(obj.refClock)];
            
            if strcmp(get(obj.serialObj,'Status'),'closed')
                obj.open;
                fwrite(obj.serialObj,refBuf);
                obj.close;
            else
                fwrite(obj.serialObj,refBuf);
            end
            
            if refClock==0
            disp('RefClock set to external.'); 
            else
            disp('RefClock set to internal.'); 
            end  
        end
    end
end

