function [varargout] = SE5082FunctionPool(command,inputs)
global awgbusy debug mul2d chnCoupled

if isempty(mul2d)
    mul2d=0;
end
awgbusy=0;
varargout={[]};
if awgbusy
    disp_debug('SE5082 busy, aborting... ');
    return
else
    awgbusy=1;
end

% CHANGE THE IDs depending on the computer used!

vu=instrfind({'ManufacturerID', 'ModelCode', 'SerialNumber'}, {'0x168C', '0x5082', '0000217390'});
if isempty(vu)
    vu=visa('ni','USB0::0x168C::0x5082::0000219380::INSTR');
elseif length(vu)>1
    vu=vu(1);
end

% fclose(vu);
pause(0.2);
try
    fopen(vu); %Open Visa Session
catch    
    pause(1);
    try
     fopen(vu); %Open Visa Session
    catch
        disp ('open failed AWG');
    end
end
try
    for br=1:1 % allow break in switch...
    switch lower(command)
        case 'help'
            % Displays help for all functions of this file
            displayHelp();
        case 'reset'
            % Reset to factory settings
            % *CLS;*RST;*OPC?
            command = '*CLS;*RST;*OPC?\n';
            varargout={read(vu,command)};
        case 'checkerr'
            command = 'SYST:ERR?';
            varargout={read(vu,command)};   
            
        %%%%%%%%%%%%%%%%%% for chirp  %%%%%%%%%%%%  
        case 'mod_type'
            command = 'SOUR:MOD:TYPE';
            writeread(vu,command, inputs);  
            
        case 'mod_carrier_type'
            command = 'MOD:CARR:FUNC';
            writeread(vu,command, inputs);
           
        case 'chirp_width'
            command = 'SOUR:CHIR:WID';
            writeread(vu,command, inputs); 
           
        case 'chirp_start_freq'
            command = 'SOUR:CHIR:FREQ:STAR';
            writeread(vu,command, inputs); 
           
        case 'chirp_stop_freq'
            command = 'SOUR:CHIR:FREQ:STOP';
            writeread(vu,command, inputs); 
           
        case 'chirp_direction' %default up
            command = 'SOUR:CHIR:FREQ:DIR';
            writeread(vu,command, inputs); 
        
        case 'chirp_lin_log' %default lin
            command = 'SOUR:CHIR:FREQ:SPAC';
            writeread(vu,command, inputs); 
            
        case 'chirp_amp_ramp_depth' %default 50 percent
            command = 'SOUR:CHIR:DEPT';
            writeread(vu,command, inputs); 
            
        %%%%%%%%%%%%%%%%%%% end chirp %%%%%%%%
            
        case 'settimingmode'
            command = 'TRAC:SEL:TIM';
            writeread(vu,command, inputs);
            command = 'SEQ:SEL:TIM';
            writeread(vu,command, inputs);
        case 'gettimingmode'
            command = 'TRAC:SEL:TIM?';
            varargout={read(vu,command)};
        case 'selectsamplingmode' % allows for sampling in different Nyquist Zones
            command = 'OUTP:SAMP:FORM';
            writeread(vu, command, inputs);
        case 'selsegment'
            if chnCoupled
                command='TRAC:SEL:COUP';
                writeread(vu,command, [num2str(inputs+mul2d) ',' num2str(inputs+mul2d)]); % HACK JCJ 20150622
            else
                command='TRAC:SEL';
                writeread(vu,command, num2str(inputs+mul2d));
            end
        case 'selsegment2d'
            mul2d=inputs;
        case 'selsequence'
            if chnCoupled
                command='SEQ:SEL:COUP';
                writeread(vu,command, [num2str(inputs+mul2d) ',' num2str(inputs+mul2d)]); % HACK JCJ 20150622
            else
                command='SEQ:SEL';
                writeread(vu,command, num2str(inputs+mul2d));
            end
        case 'selsquence2d'
            mul2d=inputs;
        case 'getlengthseg'
            command = ['TRAC:DEF' num2str(inputs) '?\n'];
            response=read(vu,command);
            npoints=response(2:end);
            
            command='FREQ:RAST?';
            varargout={npoints/read(vu,command)}; %in seconds
        case 'couplechn'
            command='INST:COUP:STAT';
            writeread(vu,command, num2str(inputs));
            if isempty(chnCoupled) | strcmp(inputs, 'off') | inputs == 0
                chnCoupled = 0;
            elseif strcmp(inputs, 'on') | inputs == 1 
                chnCoupled = 1;
            end
        case 'setcoupling'
            command='OUTP:COUP';
            writeread(vu,command, num2str(inputs));
        case 'setdclevel_ch1'
            command='INST:SEL';
            writeread(vu,command, 1);
            
            command='DC';
            writeread(vu,command, inputs);
        case 'setdclevel_ch2'
            command='INST:SEL';
            writeread(vu,command, 2); 
            
            command='DC';
            writeread(vu,command, inputs);
        case 'setdclevel'            
            command='DC';
            writeread(vu,command, inputs);
        case 'getdclevel'
            command = 'DC?';
            varargout={read(vu,command)};
        case 'setamplitude'
            if inputs > 2
                disp('Amplitude too high, aborting JCJ')
            else
                command='VOLT';
                writeread(vu,command, inputs);
            end
        case 'getamplitude'
            command = 'VOLT?';
            varargout={read(vu,cofmmand)};
        case 'sethvamplitude'
            command='VOLT:HV';
            writeread(vu,command, inputs);
        case 'gethvamplitude'
            command = 'VOLT:HV?';
            varargout={read(vu,command)};
        case 'setchn'
            command='INST:SEL';
            writeread(vu,command, num2str(inputs));
        case 'getchn'
            command = 'INST:SEL?';
            varargout={read(vu,command)};
        case 'setmarker'            
            command='MARK:SEL';
            writeread(vu,command, num2str(inputs));
        case 'getmarker'
            command = 'MARK:SEL?';
            varargout={read(vu,command)};            
        case 'setmode'
            command='FUNC:MODE'; % inputs = FIX, USER, ...
            writeread(vu,command, inputs);
        case 'getmode'
            command = 'FUNC:MODE?';
            varargout={read(vu,command)};
        case 'settriggermode'
            command='INIT:CONT'; % inputs = FIX, USER, ...
            if strcmpi(inputs, 'cont')
                inputs=1;
                writeread(vu,command, inputs);
                break;
            else
                inputs=0;
                writeread(vu,command, inputs);
            end
            
            command='INIT:GATE'; % inputs = FIX, USER, ...
            if strcmpi(inputs, 'triggered')
                inputs=0;
            elseif strcmpi(inputs, 'gated')
                inputs=1;
            end
            writeread(vu,command, inputs);
        case 'setoutput'
            command='OUTP'; 
            writeread(vu,command, inputs);            
        case 'setmarkeroutput'
            command='MARK:STAT'; 
            writeread(vu,command, inputs);
        case 'settransfermode'
            command='TRAC:MODE'; 
            writeread(vu,command, inputs);
        case 'gettransfermode'
            command = 'TRAC:MODE?';
            varargout={read(vu,command)};
        case 'getactivechn'
            command = 'INST:SEL?';
            selchn=read(vu,command);
            
            outputs=zeros(1,4);
            for i=1:4
                command='INST:SEL';
                writeread(vu,command, i);
                
                command='OUTP?';
                if strcmpi(strtrim(read(vu,command)), 'on')
                    outputs(i)=1;
                else
                    outputs(i)=0;
                end
            end
            command='INST:SEL'; 
            writeread(vu,command, selchn);
            
            varargout={outputs};
        case 'eraseseg'
            if strcmp(num2str(inputs),'all')
                command = 'TRAC:DEL:ALL';
                writeread(vu,command);
                
                command = 'SEQ:DEL:ALL';
                writeread(vu,command);
            else
                command='TRAC:DEL'; % inputs = FIX, USER, ...
                writeread(vu,command, inputs);
            end
        case 'setmarkersource'
            command='MARK:SOUR';
            writeread(vu,command, inputs);
        case 'setjumpsource'
            command='SEQ:JUMP:EVENT';
            writeread(vu,command, inputs); %BUS or EVENt
        case 'setseqadvancemode'
            command='SEQ:ADV';
            writeread(vu,command, inputs); %AUTOmatic, ONCE or STEPped
        case 'transferawf'
            awf=inputs.AWF;
            npoints=length(awf);
            nbytes=2;
            
            fclose(vu);
            pause(0.2);
            buffer=npoints*nbytes;
            set(vu,'OutputBufferSize',buffer);
            %set(vu,'InputBufferSize',buffer);
            pause(0.2);
            fopen(vu);            
            
            % get the amplitude
            command = 'VOLT 1.2';
         writeread(vu,command);
            
             command = 'VOLT?';
            amp=read(vu,command);
%             amp=0.5;
            
            if inputs.renormed
                awgsig=(awf-min(awf))*4/(max(awf)-min(awf))-2; % rescaled  between -2 and 2                
            else
                awgsig = awf;
                if min(awf) < -amp/2 || max(awf) > amp/2 
                    % if min(awf) < -2 || max(awf) > 2 
                    % stop
                    % else
                    % change amplitude to match the max
                    disp('Waveform out of bounds, please reupload.')
                    error('Waveform out of bounds, please reupload.')
                end
            end
            
            awgsig=(awgsig+amp/2)*4095/(amp); % -amp/2: 0 -> amp/2:4095
           
            % Markers are programmed differently in the memory, see Manuals
            % p 274 or 4-65
            [m1, m2]=reorderMarker(inputs.m1, inputs.m2);
            
            %Create a block of data in IEEE 488.2 format            

            datablock=zeros(1,nbytes*npoints,'uint8');
            for k=1:npoints
                %datablock((k-1)*nbytes+1:(k-1)*nbytes+nbytes) = typecast(uint16(awgsig(k)+ 2^14*m1(k) + 2^15*m2(k)),'uint8');
                datablock((k-1)*nbytes+1:(k-1)*nbytes+nbytes) = typecast(uint16(awgsig(k)+ 2^12*m1(k) + 2^13*m2(k)),'uint8');
            end   
            
            bytes = num2str(length(datablock));
            header = ['#' num2str(length(bytes)) bytes];            
            
            command='TRAC:DEF';
            writeread(vu,command, [num2str(inputs.segNb) ',' num2str(npoints)]);
            
            command='TRAC:SEL';
            writeread(vu,command, num2str(inputs.segNb)); 

            fprintf(vu,['TRAC:DATA' header]);

            fwrite(vu,datablock);
            pause(0.2);
            
            M=[inputs.AWF; inputs.m1; inputs.m2];
            %dlmwrite('Waverform.txt', M');
            %dlmwrite('awgData.txt', datablock);
            
            % helps for transfering large segments, somehow...
%             command = 'SYST:ERR?';
%             err= strsplit(read(vu,command),',');
%             if str2double(err{1})
%                 disp(err{2});
%             end 
            
            command='FREQ:RAST';
            writeread(vu,command, num2str(1/inputs.dt))

        case 'createseq'
            
            %Create a block of data in IEEE 488.2 format            
            nbytes=8;            
            
            steps=inputs.steps;
            npoints=length(steps);            
            fclose(vu);        
            buffer=npoints*nbytes;
            set(vu,'OutputBufferSize',buffer);
            set(vu,'InputBufferSize',buffer);            
            fopen(vu); 
            
            datablock=zeros(1,nbytes*npoints,'uint8');
            for k=1:npoints
                datablock((k-1)*nbytes+1:(k-1)*nbytes+nbytes) = [typecast(uint32(steps{k}(1)),'uint8') ...
                    typecast(uint16(steps{k}(2)),'uint8') ...
                    typecast(uint16(steps{k}(3)),'uint8') ...
                ];
            end
            
            bytes = num2str(length(datablock));
            header = ['#' num2str(length(bytes)) bytes];
            
%             command='TRAC:DEF';
%             writeread(vu,command, [num2str(inputs.segNb) ',' num2str(npoints)]);
%             
            command='SEQ:SEL';
            writeread(vu,command, num2str(inputs.seqNb)); 
            
            command='SEQ:DATA';
            fprintf(vu,['SEQ:DATA' header]);
            fwrite(vu,datablock);
            

            
            command = 'SYST:ERR?';
            err= strsplit(read(vu,command),',');
            if str2double(err{1})
                disp(err{2});
            end 
        otherwise
            disp('Error: I do not know this command. Nothing send to SE5082.')
    end
    end
catch
    disp_debug('Something wrong')
    fclose(vu); %closes VISA session
    awgbusy=0;
    error(['Could not execute ' lower(command)])
end

fclose(vu); %closes VISA session
awgbusy=0;
clear vu;
end

function response = read(visa,visacommand)
% this function reads a value from the Rigol device and returns the value
fprintf(visa,[visacommand]); %read value
%         pause(.2);
response=fscanf(visa);
if ~isempty(str2num(response))
    response=str2num(response);
end
end

function response = readBin(visa,visacommand, len)
% this function reads a value from the Rigol device and returns the value
if ~isempty(visacommand)
    fprintf(visa,[visacommand]); %read value
end
response=double(typecast(uint8(fread(visa, len)),'int8'));
end

function writeread(visa,visacommand,inputs)
% this function writes a visa command to the Rigol device. It reads
% it out right away to ensure it is set correctly.
global debug;
if nargin < 3
    inputs = '';
end
fprintf(visa,[visacommand ' ' num2str(inputs)]); %set value

if debug >= 2
    % pause(.2);
    fprintf(visa,[visacommand '?']);        %read value
    % pause(.2);
    response=str2num(fscanf(visa));
    
    if isempty(response)
        return
    end
    
    if response-inputs < 0.1 % everything is okay, print the set value
        disp(['SE5082 ' visacommand ' set to ' num2str(inputs)]);
    else %set value is not get value, there is something wrong
        disp(['Error while sending ' visacommand '...']);
    end
end

end

function [om1,om2] = reorderMarker(m1, m2)
    % Adapt markers to the memory arrangement
    % Example:
    % 0010101000100111  1011010011101000
    % to
    % 00000000 01110111  00000000 11101110
    om1=[];
    om2=[];
    
    lenWd=16; % 16 bits
    for j = 1:length(m1)/lenWd
        a1=m1(lenWd*(j-1)+1:lenWd*j);
        a2=m2(lenWd*(j-1)+1:lenWd*j);
        b1=a1(1:end/2);
        b2=a2(1:end/2);
        
        for i=1:length(a1)/2
            b1(i) = a1(2*i-1) | a1(2*i);
            b2(i) = a2(2*i-1) | a2(2*i);
        end
        om1=[om1 zeros(1,length(b1)) b1];
        om2=[om2 zeros(1,length(b2)) b2];
    end
end

function displayHelp()
%read this file
mfn = which(mfilename);
fid = fopen(mfn);

tline = fgets(fid);
disphelp=0;
while ischar(tline)
    if disphelp && isempty(strfind(tline,'%'))
        disphelp = 0;
        fprintf('\n');
    end
    if disphelp
        tline=strsplit(tline, '%');
        disp(['    ' strtrim(tline{2})]);
        tline = fgets(fid);
        continue;
    end
    if strfind(tline,'case')
        s1 = strsplit(tline, 'case ');
        fun = strtrim(s1{2});
        disp(fun(2:end-1));
        disphelp=1;
    end
    if strfind(tline,'catch')
        fclose(fid);
        break;
    end
    tline = fgets(fid);
end

end

function disp_debug(s)
disp(s)
end