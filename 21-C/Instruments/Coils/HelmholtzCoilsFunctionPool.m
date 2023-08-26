function [varargout] = HelmholtzCoilsFunctionPool(what,hObject,eventdata,handles,channel)

switch what,
    case 'Initialize',
        Initialize(hObject,eventdata,handles);
    case 'UpdateDevice',
       UpdateDevice(hObject,eventdata,handles,channel);
    case 'TurnLaserOff',
        TurnLaserOff(hObject,eventdata,handles,channel);
    case 'TurnLaserOn',
        TurnLaserOn(hObject,eventdata,handles,channel);
end

function [] = UpdateDevice(hObject,eventdata,handles,channel);

% Get the value of the current
Current = get(eval(['handles.current',num2str(channel)]),'String');

try,
    Current = str2double(Current);
catch,
% Check to make sure it's a number
    warndlg('Current Value is not valid. Number required');
end

handles.LD340Device{channel}.Current = Current;

LD340FunctionPool('SetCurrent',handles.LD340Device{channel});

% update the handles object
guidata(hObject,handles);

function [] = TurnLaserOff(hObject,eventdata,handles,channel);
handles.LD340Device{channel}.LaserState = 0;
set(hObject,'String','Current Off');
LD340FunctionPool('LaserOff',handles.LD340Device{channel});
guidata(hObject,handles);

function [] = TurnLaserOn(hObject,eventdata,handles,channel);
handles.LD340Device{channel}.LaserState = 1;
set(hObject,'String','Current On');
LD340FunctionPool('LaserOn',handles.LD340Device{channel});
guidata(hObject,handles);

function [] = Initialize(hObject,eventdata,handles);

for k=1:length(handles.LD340Device),
    
    OnOffStatus = LD340FunctionPool('GetOnOffStatus',...
        handles.LD340Device{k});
    Current = LD340FunctionPool('GetCurrent',handles.LD340Device{k});

    % try to get the current value from the GPIB comm. string
    temp = regexp(Current,':ILD:SET(.*?)$','tokens');

    % if no current found, this indicates an error communicating with
    % the device
    if length(temp),
        handles.LD340Device{k}.Current = str2num(temp{1}{1});
        set(eval(['handles.current',num2str(k)]),...
            'String',handles.LD340Device{k}.Current);
    else,
        % disable the channel that is giving an error
        set(eval(['handles.',handles.LD340Device{k}.GUIButtonID]),...
            'Enable','off');
    end
    if strfind(OnOffStatus,'OFF'),
        handles.LD340Device{k}.LaserState = 0;
        set(eval(['handles.toggleOnOff',num2str(k)])...
            ,'Value',0);
    elseif strfind(OnOffStatus,'ON')
        handles.LD340Device{k}.LaserState = 1;
        set(eval(['handles.toggleOnOff',num2str(k)])...
            ,'Value',1);
    end
end

guidata(hObject,handles);
