function [varargout] = RigolDG1022FunctionPool(command,inputs, channel)

% This is a Matlab script to control the Rigol DG1022 Function Generator via VISA. You need
% to install Agilents IO Library Suite or NI VISA Driver - either can be used as a
% driver. The VISA commands are described in detail in the Rigol DG1022 Programming
% Guide.
if ~exist('channel','var'), channel=1; end

vu=visa('ni','USB0::0x0400::0x09C4::DG1G170400122::INSTR'); % usb address for Rigol, us 'agilent' or 'ni' as driver
fopen(vu); %Open Visa Session for Rigol

pause(.1)

switch lower(command), %all commands apply to CH1 on Rigol
    
    
    case 'setamplitudeunits' 
     command='VOLT:UNIT:CH2 VPP';
     writeread(vu,command,inputs);
    case 'setamplitude' 
        command='VOLT';
        if channel == 2
            command=[command ':CH2'];
        end
        
        currentPhase=read(vu,'BURS:PHAS?');
        if (inputs>=0)
            if currentPhase <= 0
                writeread(vu,'BURS:PHAS',currentPhase+180);
            end
%            writeread(vu,'BURS:PHAS',0);
            writeread(vu,command,inputs);
        else
            if currentPhase > 0
                writeread(vu,'BURS:PHAS',currentPhase-180);
            end
            writeread(vu,command,abs(inputs));
%            writeread(vu,'BURS:PHAS',180);
        end
    case 'setoffset'
        
        command='VOLT:OFFS';
        if channel == 2
            command=[command ':CH2'];
        end
        
        currentPhase=read(vu,'BURS:PHAS?');
        if (inputs>=0)
            if currentPhase <= 0
                writeread(vu,'BURS:PHAS',currentPhase+180);
            end
            %            writeread(vu,'BURS:PHAS',0);
            writeread(vu,command,inputs);
        else
            if currentPhase > 0
                writeread(vu,'BURS:PHAS',currentPhase-180);
            end
            writeread(vu,command,abs(inputs));
            %            writeread(vu,'BURS:PHAS',180);
        end
        
    case 'getamplitude'
        command='VOLT';
        if channel == 2
            command=[command ':CH2'];
        end
        command = [command '?'];
        varargout={read(vu,command)};  
    case 'setphase'
        writeread(vu,'BURS:PHAS',inputs);
    case 'setchphase'
        command='PHAS';
        if channel == 2
            command=[command ':CH2'];
        end
        writeread(vu,command,inputs);
    case 'set2chphase'  % Change the phase of ch1 to inputs and ch2 to input +90°
        command='PHAS';
        writeread(vu,command,inputs);
        command=[command ':CH2'];
        writeread(vu,command,inputs+90);
    case 'getchphase'
        command='PHAS';
        if channel == 2
            command=[command ':CH2'];
        end
        command = [command '?'];
        varargout={read(vu,command)}; 
    case 'getphase'
        varargout={read(vu,'BURS:PHAS?')};          
    case 'setfrequency'
        command='FREQ';
        if channel == 2
            command=[command ':CH2'];
        end
        writeread(vu,command,inputs);
    case 'setload'
        command='OUTP:LOAD';
        if channel == 2
            command=[command ':CH2'];
        end
        writeread(vu,command,inputs);
    case 'getfrequency'
        command='FREQ';
        if channel == 2
            command=[command ':CH2'];
        end
        command = [command '?'];
        varargout={read(vu,command)}; 
    case 'setncycles'    
        writeread(vu,'BURS:NCYC',inputs);
    case 'getncycles'    
        varargout={read(vu,'BURS:NCYC?')};         
    case 'output'                 %turn the output on or off: inputs = 'ON' or 'OFF'
        fprintf(vu,['OUTP ' inputs]);      
    otherwise
        disp('Error: I do not know this command. Nothing send to Rigol.')
end

fclose(vu); %closes VISA session
                
end

function response = read(visa,visacommand)
% this function reads a value from the Rigol device and returns the value
        fprintf(visa,[visacommand]); %read value
        pause(.2);
        response=str2num(strrep(fscanf(visa),'CH2:',''));
end

function writeread(visa,visacommand,inputs)
% this function writes a visa command to the Rigol device. It reads 
% it out right away to ensure it is set correctly.
        global debug;

        fprintf(visa,[visacommand ' ' num2str(inputs)]); %set value
        pause(.2);
        fprintf(visa,[visacommand '?']);        %read value
        pause(.2);
        response=str2num(fscanf(visa));              
%         response
%         inputs
         if debug >= 2
            if response-inputs < 0.1 % everything is okay, print the set value
                disp(['Rigol ' visacommand ' set to ' num2str(inputs)]);
            else %set value is not get value, there is something wrong
                disp(['Error while sending ' visacommand '...']);
            end
         end    
end