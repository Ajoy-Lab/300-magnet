function [varargout] = TDS694cFunctionPool(command,inputs)
global scopebusy debug

varargout={[]};
if scopebusy
    return
else
    scopebusy=1;
end

vu=gpib('ni',0,19); % GBIP board 0, address 19
fopen(vu); %Open Visa Session for Rigol
% pause(.1)

try
    for br=1:1 % allow break in switch...
    switch lower(command), %all commands apply to CH1 on Rigol
        case 'getmeasurement'
            command=['MEASU:meas' num2str(inputs) ':val?'];
            varargout={read(vu,command)};
        
        case 'setmeasurementparam'
            listcmds = {'TYPE','SOURCE1', 'SOURCE2', 'DELAY:EDGE1','DELAY:EDGE2', 'DELAY:DIRE', 'STATE'};
            for i=1:length(listcmds)
                command=['MEASU:MEAS' num2str(inputs{1}) ':' listcmds{i}];
                writeread(vu,command, num2str(inputs{i+1}));
            end
%             command='SEL?';
%             selected=read(vu,command)
%             chn=str2double(inputs{3}(3:end));
%             if (~str2double(selected(2*chn-1)))
%                 disp(['Channel' num2str(inputs) ' not active']);
%             end
            
        case 'getmeasurementparam'
            if isempty(num2str(inputs))
                disp('Please specify a measurement number');
            end
            command=['MEASU:meas' num2str(inputs) '?'];
            varargout={read(vu,command)};
            
        case 'getscales'
            command='HOR:SCA?';
            varargout{1}=read(vu,command);
            varargout{2}=-1;
            if exist('inputs','var') && ~isempty(num2str(inputs))
                command='SEL?';
                selected=read(vu,command);         
                if ~(str2double(selected(2*inputs-1)))
                    if debug 
                        disp(['Channel' num2str(inputs) ' not active']);
                    end
                    break;
                end
                
                command=['CH' num2str(inputs) ':SCA?'];
                varargout{2}=read(vu,command);                
            end
        case 'init'
            command='DAT:ENC';
            writeread(vu,command, 'RIBinary');  % RIBinary specifies signed integer data-point representation with the most
                                                % significant byte transferred first. This format results in the fastest data transfer
                                                % rate when DATa:WIDth is set to 2.
            command='DAT:WID';
            writeread(vu,command, 1);
            
        case 'setchannel'
            command='DAT:SOU';
            writeread(vu,command, ['CH' num2str(inputs)]);
        case 'getchannel'
            command='DAT:SOU?';
            varargout={read(vu,command)};
            
        case 'getcurve'
            % test if channel is active
            command='DAT:SOU?';
            chn=read(vu,command);
            chn=str2double(chn(3:end));
            command='SEL?';
            selected=read(vu,command);
            
            if ~(str2double(selected(2*chn-1)))
                if debug
                    disp(['Channel' num2str(chn) ' not active']);
                end
                break;
            end
            
            command='CURV?';            
            if readBin(vu,command, 1) ~= 35
                disp('Did not read correct data');
                 break;
            end
            lol = str2double(char(readBin(vu,'', 1))); % lol: length of the length...
            lenData=str2double(char(readBin(vu,'', lol)'));
            if debug
                disp(['Received ' num2str(lenData) ' Bytes']);
            end
            varargout=mat2cell(readBin(vu,'', lenData)',1);            
            
        otherwise
            disp('Error: I do not know this command. Nothing send to Rigol.')
    end
    end
catch
    disp('Something wrong')
    %disp(['Could not execute ' lower(command)])
end

fclose(vu); %closes VISA session
scopebusy=0;
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

fprintf(visa,[visacommand ' ' num2str(inputs)]); %set value

% pause(.2);
fprintf(visa,[visacommand '?']);        %read value
% pause(.2);
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
