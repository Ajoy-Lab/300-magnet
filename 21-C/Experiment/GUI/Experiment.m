%%%%% INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = Experiment(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Experiment_OpeningFcn, ...
    'gui_OutputFcn',  @Experiment_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before Experiment is made visible.
function Experiment_OpeningFcn(hObject, ~, handles, varargin)

% Pass on handles from Imaging
gobj = findall(0,'Name','Imaging');
handles.Imaginghandles = guidata(gobj);
%call QEG handles by handles.Imaginghandles.QEGhandles
%call ImagingFunctions handles by handles.Imaginghandles.ImagingFunctions
%call graphical elements in Imaging by handles.Imaginghandles.(name of graphical element)

handles.Imaginghandles.QEGhandles.flag_experiment = 1;

handles.ExperimentFunctions = ExperimentFunctions();
% Choose default command line output for Experiment
handles.output = hObject;

handles.PulseSequence = PulseSequence();

LaserOn=get(handles.Imaginghandles.toggle_LaserOnOff,'Value');
if LaserOn
    set(handles.Imaginghandles.toggle_LaserOnOff,'Value',0);
    
    if handles.Imaginghandles.QEGhandles.pulse_mode == 1 || handles.Imaginghandles.QEGhandles.pulse_mode == 2
        
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStop();
        
    else
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.open();
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SetChannelOff(1);
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.close();
        
    end
    set(handles.Imaginghandles.toggle_LaserOnOff,'String','Laser Off')
    set(handles.Imaginghandles.toggle_LaserOnOff,'ForegroundColor',[0.0 0.487 0])
    hwd=warndlg('Turning off the laser');
    pause(1);
    close(hwd);
end

[hObject,handles] = InitDevices(hObject,handles);

% load exps
handles.ExperimentFunctions.UpdateExpScanList(handles);

%if using PB, display Sample Rate (fixed)
if handles.Imaginghandles.QEGhandles.pulse_mode == 1 || handles.Imaginghandles.QEGhandles.pulse_mode == 2 %use PB or simu PB
    set(handles.PB_sample_rate,'Visible','on');
    set(handles.PB_sample_rate,'String',['PB Sample Rate = ' sprintf('%d',handles.Imaginghandles.ImagingFunctions.interfacePulseGen.SampleRate)]);
end

% Update handles structure
guidata(hObject, handles);

function [hObject,handles] = InitDevices(hObject,handles)

fp = 'C:\300-magnet\21-C\Initialization';
current_path = pwd;
cd(fp);
script = 'Experiment_InitScript.m';
[hObject,handles] = feval(script(1:end-2),hObject,handles);
cd(current_path);

%maybe make a fct out of it?
set(handles.text_ExpStatus,'String','Init script has been run');

% --- Outputs from this function are returned to the command line.
function varargout = Experiment_OutputFcn(~, ~, handles)

varargout{1} = handles.output;

function figure1_CloseRequestFcn(hObject, ~, handles)

handles.Imaginghandles.QEGhandles.flag_experiment = 0;
set(handles.Imaginghandles.QEGhandles.button_experiment,'Enable', 'on');
set(handles.Imaginghandles.QEGhandles.button_imaging,'Enable','off');

gobj = findall(0, 'Name', 'QEG');
guidata(gobj,handles.Imaginghandles.QEGhandles);

delete(hObject);

%%%%% END INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% TOOLBARS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function menuFile_Callback(~, ~, ~)

function menuTools_Callback(~, ~, ~)

function menuPopoutImageExp_Callback(~, ~, handles)

exps = get(handles.popup_experiments,'String');
selectedExp = exps{get(handles.popup_experiments,'Value')};
if strcmp(selectedExp,'Current Experiment')
    selectedExp = exps{get(handles.popup_experiments,'Value')+1};
end
fp = getpref('nv','SavedExpDirectory');
SavedExp = load(fullfile(fp,selectedExp));

hF = figure();
copyobj(handles.axes_AvgData,hF);
A = get(hF,'Children');
P = get(A,'OuterPosition');
%set(A,'OuterPosition',[-4 -2 P(3) P(4)]);
set(A,'OuterPosition',[.2 .2 P(3) P(4)]);
title_line(1)={selectedExp};

if length(SavedExp.Scan.vary_prop) == 2 % 2d scan
    slider_pos = get(handles.sliderExpScan,'Value');
    title_line(2) = {[SavedExp.Scan.vary_prop{2} ' = ' num2str(SavedExp.Scan.vary_begin(2) + (slider_pos-1)*SavedExp.Scan.vary_step_size(2))]};
end
    title(title_line);
    
function menuExportImageExp_Callback(~, ~, handles)

exps = get(handles.popup_experiments,'String');
selectedExp = exps{get(handles.popup_experiments,'Value')};
if strcmp(selectedExp,'Current Experiment')
    selectedExp = exps{get(handles.popup_experiments,'Value')+1};
end
fp = getpref('nv','SavedExpDirectory');
SavedExp = load(fullfile(fp,selectedExp));

[fn,fp] = uiputfile({'*.jpg','*.jpeg'},'Save Image...',fullfile(fp,'ExportedImages'));

hF = figure('Visible','off');
copyobj(handles.axes_AvgData,hF);
A = get(hF,'Children');
P = get(A,'OuterPosition');
set(A,'OuterPosition',[.2 .2 P(3) P(4)]);
title_line(1) ={selectedExp};


if length(SavedExp.Scan.vary_prop) == 2 % 2d scan
    slider_pos = get(handles.sliderExpScan,'Value');
    title_line(2) = {[SavedExp.Scan.vary_prop{2} ' = ' num2str(SavedExp.Scan.vary_begin(2) + (slider_pos-1)*SavedExp.Scan.vary_step_size(2))]};
end
    title(title_line);


saveas(hF,fullfile(fp,fn));

function uitoggletool1_OnCallback(~, ~, ~)
datacursormode on;

function uitoggletool1_OffCallback(~, ~, ~)
datacursormode off;

function menuAutoSaveExp_Callback(hObject, ~, ~)

% toggle the state of the AutoSave check box
switch get(hObject,'checked');
    case 'on'
        set(hObject,'checked','off');
    case 'off'
        set(hObject,'checked','on');
end

function menuSavedExpDir_Callback(~, ~, ~)

d = getpref('nv','SavedExpDirectory');

a = uigetdir(d,'Choose Default Saved Experiment Directory');
setpref('nv','SavedExpDirectory',a);

%%%%% END TOOLBARS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% SEQUENCE PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function button_EditSeq_CreateFcn(~, ~, ~)

function button_EditSeq_Callback(~, ~, handles)
if isfield(handles, 'Sequencename')
    open(handles.Sequencename)
end

function button_LoadSeq_Callback(hObject, ~, handles)

if isfield(handles,'shaped_pulses')
   handles = rmfield(handles,'shaped_pulses'); 
end

fp = getpref('nv','SavedSequenceDirectory');
[file] = uigetfile('*.xml', 'Choose existing sequence file to load',fp);

if file ~= 0
    [vars_cell, sequence_code, shaped_pulses_cmds] = get_sequence(file);
    set(handles.text_SequenceName,'String',file);
    set(handles.table_float,'Enable','On');
    set(handles.table_bool,'Enable','On');
else
    uiwait(warndlg({'Sequence file not loaded. Aborted.'}));
    return;
end

handles.Seq_vars = vars_cell;
handles.Sequence_code = sequence_code;
handles.Data_float = {};
handles.Data_bool = {};
handles.Sequencename = file;
set(handles.checkbox18,'Value',0);

% load shaped pulses from files into the variables as
% handles.shaped_pulses{1} = load('pulsefile1.mat');
for k = 1:length(shaped_pulses_cmds)
    eval(['handles.' shaped_pulses_cmds{k}.command]);
    if length(handles.shaped_pulses{k}.Amplitude) ~= length(handles.shaped_pulses{k}.Phase) 
        uiwait(warndlg({sprintf('Shaped pulse %d has different lengths for amplitude and phase. Aborted.',k)}));
        return;
    end
    if ~isempty(find(abs(handles.shaped_pulses{k}.Amplitude)>1,1))
        uiwait(warndlg({sprintf('Shaped pulse %d has amplitudes out of [-1,1] bounds. Aborted.',k)}));
        return;
    end
end

for aux=1:1:length(vars_cell)
   
    if strcmp(vars_cell{aux}.variable_type, 'float')
        handles.Data_float{end+1,1} = vars_cell{aux}.name;
        handles.Data_float{end,2} = vars_cell{aux}.default_value;
        handles.Data_float{end,3} = false;
        handles.Data_float{end,4} = '';
        handles.Data_float{end,5} = '';
        handles.Data_float{end,6} = '';
        
%         JCJ 20150923
%     if strcmp(vars_cell{aux}.variable_type, 'AWGparam')
%         handles.Data_float{end+1,1} = vars_cell{aux}.name;
%         handles.Data_float{end,2} = vars_cell{aux}.default_value;
%         handles.Data_float{end,3} = false;
%         handles.Data_float{end,4} = '';
%         handles.Data_float{end,5} = '';
%         handles.Data_float{end,6} = '';


        
    elseif strcmp(vars_cell{aux}.variable_type, 'boolean')
        handles.Data_bool{end+1,1} = logical(vars_cell{aux}.default_value);
        handles.Data_bool{end,2} = vars_cell{aux}.name;
        
    end
    
end


% %%% LYX 20150924
% for aux=1:1:length(vars_cell)
%     %%% Use name as a switch. Once there exist a parameter named 'AWGswtich', the code goes to the AWG branch
% 
%     if strcmp(vars_cell{aux}.name, 'AWGswitch')
%         table_AWGparam{:,1} = handles.Data_float{:1};
%         table_AWGparam{:,1} = handles.Data_float{:1};
%        transferXY8n_WX1284C(n, Transfer, table_AWGparam)  
%     end
%     if handles.Data_float{aux,3} 
%        Param_to_var 
%     end
% end
% %%% LYX 20150924


set(handles.table_float,'Data',handles.Data_float);
set(handles.table_bool,'Data', handles.Data_bool);

%         JCJ 20150923
% transferXY8n_WX1284C(n, Transfer, table_AWGparam)

% Update handles structure
guidata(hObject, handles);

% function [handles] = button_SetScan_Callback(hObject, ~, handles)
% 
% %Initialize ExperimentalScan params
% handles.ExperimentalScan = ExperimentalScan();
% handles.Array_PSeq = {};
% 
% set(handles.average_continuously,'Enable','on');
% 
% scan_var_nb = handles.Var_to_be_varied;
% 
% %Set name of sequence
% handles.ExperimentalScan.SequenceName = handles.Sequencename;
% handles.ExperimentalScan.vary_prop =  handles.Name_var_to_be_varied;
% 
% %Save sequence file in ExperimentalScan
% fid = fopen(handles.Sequencename);
% tline = fgets(fid);
% while ischar(tline)
%     handles.ExperimentalScan.Sequence = [handles.ExperimentalScan.Sequence tline];
%     tline = fgets(fid);
% end
% 
% %Set first scan dimension params
% for k=1:1:length(scan_var_nb)
% handles.ExperimentalScan.vary_begin(k) = ParseInput(handles.Data_float{scan_var_nb(k), 4});
% handles.ExperimentalScan.vary_step_size(k) = ParseInput(handles.Data_float{scan_var_nb(k), 5});
% handles.ExperimentalScan.vary_end(k) = ParseInput(handles.Data_float{scan_var_nb(k), 6});
% end
% 
% if length(scan_var_nb) == 1
% set(handles.average_continuously,'Enable','on');
% else
% set(handles.average_continuously,'Enable','off');
% end
% 
% % initialize scan
% clear scan;
% for k=1:1:length(scan_var_nb)
%     
%     %%%%%%%Added by Masashi March,21,2011%%%
% if handles.ExperimentalScan.vary_begin(k)==handles.ExperimentalScan.vary_end(k);
%     %%%%%%This is original%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scan{k} = handles.ExperimentalScan.vary_begin(k)*ones(1,handles.ExperimentalScan.vary_step_size(k));    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% else
%     %%%%%%%%%%%%%%%%%%%%%%
% scan{k} = handles.ExperimentalScan.vary_begin(k):handles.ExperimentalScan.vary_step_size(k):handles.ExperimentalScan.vary_end(k);
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%
% handles.ExperimentalScan.vary_points(k) = length(scan{k});
% if abs(scan{k}(end) - handles.ExperimentalScan.vary_end(k)) > 1e-12 
%     warndlg(sprintf('Note that end point in scan will be %d and not %d because of scan step size.', scan{k}(end),handles.ExperimentalScan.vary_end(k)))
% end
% end
% 
% % randomizing is only for the first scan dimension
% handles.rand_indices_1dscan = [];
% if get(handles.checkbox_randomscan,'Value')
%    handles.rand_indices_1dscan = randperm(length(scan{1}));
%    scan{1} = scan{1}(handles.rand_indices_1dscan);
% end
% 
% err_in_sequence_building = false;
% 
% if length(scan_var_nb) == 2
%     aux2_end = length(scan{2});
% else
%     aux2_end = 1;
% end
% 
% % toggle through all scanning points and make an array of sequences
% handles.Array_PSeq = cell(aux2_end,length(scan{1}));
% 
% for aux2=1:1:aux2_end %var to the slider is variable from scan{2}
%     
%     if length(scan_var_nb) == 2
%     handles.Data_float{scan_var_nb(2), 2} = scan{2}(aux2);
%     end
%     
% for aux=1:1:length(scan{1}) % var that can be shuffled over
%     
%     % change the current value
%     handles.Data_float{scan_var_nb(1), 2} = scan{1}(aux);
%     
%     [Current_PSeq,Variable_values,Bool_values,coerced_hlp] = make_pulse_sequence(handles);
% 
% 	if coerced_hlp.value == true
%         uiwait(warndlg({['Variable ' coerced_hlp.name ' out of range. Set Scan aborted.']}));        
%         err_in_sequence_building = true;
%         break;
%     end
%     
%     if Current_PSeq.seq_error ~= 0
%         uiwait(warndlg({sprintf('Error to build sequence at scan point %d. Error number %d. Set Scan aborted.', Current_PSeq.seq_error, aux)}));
%         err_in_sequence_building = true;
%         break;
%     end
%      
%     handles.Array_PSeq{aux2,aux} = Current_PSeq;
%     
% end
% 
% end
% 
% handles.ExperimentalScan.Variable_values = Variable_values;
% handles.ExperimentalScan.Bool_values = Bool_values;
% 
% if ~err_in_sequence_building
% 	set(handles.button_StartExp,'Enable','on');
% else
%     set(handles.button_StartExp,'Enable','off');
% end
% 
% if get(handles.checkbox_randomscan,'Value')
%     textrandom = 'random ';
% else
%     textrandom = ' ';
% end
% 
% if get(handles.checkbox_tracking,'Value')
%    
%    handles.Imaginghandles.ImagingFunctions.SaveTrack(handles.Imaginghandles);
%    set(handles.Imaginghandles.TrackingSave,'Enable','off');
%    set(handles.Imaginghandles.TrackingStart,'Enable','off');
%     
%    if get(handles.button_track_per_avg,'Value')
%       texttrack = 'track per avg '; 
%    else
%       texttrack = 'track per scan pt '; 
%    end
% else
%     texttrack = '';
% end
% 
% if get(handles.checkbox_power,'Value')
%     if get(handles.button_power_per_avg,'Value')
%       textpower = 'power per avg'; 
%    else
%       textpower = 'power per scan pt'; 
%    end
% else
%     textpower = '';
% end
% 
% set(hObject,'String',['Set Scan ' textrandom texttrack textpower]);
% 
% guidata(hObject,handles);

% function table_float_CellEditCallback(hObject, ~, handles)
% 
% %tabledata = get(hObject, 'data');
% tabledata = get(handles.table_float, 'Data');
% handles.Data_float = tabledata;
% a = size(tabledata);
% 
% vary_on = 0;
% handles.Var_to_be_varied = [];
% handles.Name_var_to_be_varied = {};
% for p=1:1:a(1)  %number of lines in matrix
%     if tabledata{p,3} == true
%         handles.Var_to_be_varied = [handles.Var_to_be_varied p];
%         handles.Name_var_to_be_varied = [handles.Name_var_to_be_varied tabledata{p,1}];
%         vary_on = 1;
%     end
% end
% 
% if length(handles.Var_to_be_varied) > 2
%     uiwait(warndlg('You cannot scan more than two variables. Aborted.'));
%     set(handles.button_SetScan,'Enable', 'off');
%     return;
% end
% 
% scan_ok = 1;
% for k=1:1:length(handles.Var_to_be_varied)
% if ~(vary_on && ~isempty(handles.Data_float{handles.Var_to_be_varied(k),4}) && ~isempty(handles.Data_float{handles.Var_to_be_varied(k),5}) && ~isempty(handles.Data_float{handles.Var_to_be_varied(k),6}))
%     scan_ok = 0;
%     break;
% end
% end
% 
% if scan_ok
%     set(handles.button_SetScan,'Enable', 'on');
% else
%     set(handles.button_SetScan,'Enable', 'off');
% end
% 
% %set(hObject,'Data',handles.Data_float);
% set(handles.table_float,'Data',handles.Data_float);
% 
% % Update handles structure
% guidata(hObject, handles);
% 
% function table_bool_CellEditCallback(hObject, ~, handles)
% 
% handles.Data_bool = get(hObject,'data');
% 
% % Update handles structure
% guidata(hObject, handles);

function checkbox_randomscan_Callback(~, ~, ~)

function checkbox_power_Callback(hObject, ~, handles)
EnablePower=get(hObject,'Value');
if EnablePower
    set(handles.panel_power_method,'Visible', 'on');
else
    set(handles.panel_power_method,'Visible', 'off');
end

function checkbox_tracking_Callback(hObject, ~, handles)
EnableTrack=get(hObject,'Value');
if EnableTrack
    set(handles.panel_tracking_method,'Visible', 'on');
else
    set(handles.panel_tracking_method,'Visible', 'off');
    set(handles.Imaginghandles.TrackingSave,'Enable','on');
    set(handles.Imaginghandles.TrackingStart,'Enable','on');
end

%%%%% END SEQUENCE PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% EXPERIMENT PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function button_StartExp_ButtonDownFcn(~, ~, ~)

function button_StartExp_Callback(~, ~, handles)
handles.ExperimentFunctions.RunExperiment(handles);

function button_StopExp_Callback(~, eventdata, handles)
handles.ExperimentFunctions.AbortRun(handles);

function edit_Averages_Callback(~, ~, ~)

function edit_Averages_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_Repetitions_Callback(~, ~, ~)

function edit_Repetitions_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function average_continuously_Callback(hObject, ~, handles)

if get(hObject,'Value')
    set(handles.edit_Averages,'Enable','off');
else
    set(handles.edit_Averages,'Enable','on');
end

%%%%% END EXPERIMENT PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% RESULT HANDLING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popup_experiments_Callback(hObject, eventdata, handles)

handles.ExperimentFunctions.LoadExpFromScan(handles);

handles.ExperimentFunctions.UpdateExpScanList(handles);

function slider_each_avg_Callback(hObject, eventdata, handles)

scans = get(handles.popup_experiments,'String');
selectedExp = scans{get(handles.popup_experiments,'Value')};

if strcmp(selectedExp,'Current Experiment')
    selectedExp = scans{get(handles.popup_experiments,'Value')+1};
end

% load up images from saved file
fp = getpref('nv','SavedExpDirectory');
SavedExp = load(fullfile(fp,selectedExp));

val = int32((get(handles.slider_each_avg,'Value')));
set(handles.slider_each_avg,'Value',val);
set(handles.avg_nb,'String',val);

%if it's a 2D exp, get value from other slider
if strcmp(get(handles.sliderExpScan, 'Visible'),'on')
val2Dslider = int32((get(handles.sliderExpScan,'Value')));
else 
val2Dslider = 1;    
end

handles.ExperimentFunctions.EachAvgPlot(handles,SavedExp.Scan,val,val2Dslider);

guidata(hObject, handles);

function slider_each_avg_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function popup_experiments_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_NoteExp_Callback(~, ~, ~)

function edit_NoteExp_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function button_NoteExp_Callback(hObject, ~, handles)

exps = get(handles.popup_experiments,'String');
selectedExp = exps{get(handles.popup_experiments,'Value')};

if strcmp(selectedExp,'Current Experiment')
    selectedExp = exps{get(handles.popup_experiments,'Value')+1};
end
   
    fp = getpref('nv','SavedExpDirectory');
    load(fullfile(fp,selectedExp));
    Scan.Notes = get(handles.edit_NoteExp, 'String');
    save(fullfile(fp,selectedExp),'Scan');

% Update handles structure
guidata(hObject, handles);

function text_sequence_Callback(~, ~, ~)

function text_sequence_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sliderExpScan_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderExpScan_Callback(hObject, ~, handles)

exps = get(handles.popup_experiments,'String');
selectedExp = exps{get(handles.popup_experiments,'Value')};

if strcmp(selectedExp,'Current Experiment')
    selectedExp = exps{get(handles.popup_experiments,'Value')+1};
end

% load up images from saved file
fp = getpref('nv','SavedExpDirectory');
SavedExp = load(fullfile(fp,selectedExp));
   
val = int32((get(handles.sliderExpScan,'Value')));
set(handles.sliderExpScan,'Value',val);
set(handles.text_vary2_param,'String',sprintf('%s = %s',SavedExp.Scan.vary_prop{2},num2str(double(SavedExp.Scan.vary_begin(2)) +double((val-1))*double((SavedExp.Scan.vary_end(2)-SavedExp.Scan.vary_begin(2)))/double((SavedExp.Scan.vary_points(2)-1)))));

handles.ExperimentFunctions.ExpPlot(handles,SavedExp.Scan,val);

guidata(hObject, handles);

function button_fit_data_Callback(~, ~, ~)

function curveSelect_Callback(~, ~, ~)

function curveSelect_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fitButton_Callback(~, ~, handles)
%wrote by Jon Schneider April 2011

threshold = 0.5;

curveType = get(handles.curveSelect, 'Value');

fp = getpref('nv','SavedExpDirectory');
exps = get(handles.popup_experiments,'String');
selectedExp= exps{get(handles.popup_experiments,'Value')};

if strcmp(selectedExp,'Current Experiment')
    selectedExp= exps{get(handles.popup_experiments,'Value')+1}; %loads the first exp in the list, that corresponds to the displayed 'Current Experiment'
end

SavedExp = load(fullfile(fp,selectedExp));
data = SavedExp.Scan;

xData = linspace(data.vary_begin,data.vary_end,data.vary_points);

twoCurves = get(handles.twoCurveCheck, 'Value');

if twoCurves
    yData = data.ExperimentData{1}{2}./data.ExperimentData{1}{1}; %normalize the two curves
    
    yDataOr = yData;
    
else
    yData = data.ExperimentData{1}{1};
end

xData = linspace(1, 10, data.vary_points);

yOffset = median(yData);
yData = yData - median(yData);
yAmplitude = max(abs(yData));
ySign = sign(max(yData) + min(yData));

sample = find(abs(yData) > threshold*yAmplitude);
sampleStart = max(min(sample) - 5, 1);
sampleEnd = min(max(sample) + 5, length(xData));

yDataMod = yData(sampleStart:sampleEnd);
xDataMod = xData(sampleStart:sampleEnd);

hold(handles.axes_AvgData,'on');

coeffs = curvefit(xDataMod, yDataMod, curveType);

yModel = modelFunction(coeffs, xData, curveType);
yModel = yModel + yOffset;
xData = linspace(data.vary_begin,data.vary_end,data.vary_points);

if twoCurves
    figure(100);
    hold on;
    plot(xData, yDataOr, 'g-');
    plot(xData, yModel, 'r-');
    hold off;
else
    plot(handles.axes_AvgData, xData, yModel, 'r-','LineWidth',3);
end

hold(handles.axes_AvgData,'off');

if curveType == 1 || curveType == 3
    coeffsPr = [0 0 0];
elseif curveType == 7 || curveType == 8
    coeffsPr = [0 0 0 0 0 0];
end


if curveType == 1 || curveType == 3 || curveType == 7 || curveType == 8
    coeffsPr(1) = ((coeffs(1) - 1)/9)*(data.vary_end - data.vary_begin) + data.vary_begin;
    coeffsPr(2) = 9*coeffs(2)/(data.vary_end - data.vary_begin);
    coeffsPr(3) = coeffs(3);
    if curveType == 7 || curveType ==8
        coeffsPr(4) = ((coeffs(4) - 1)/9)*(data.vary_end - data.vary_begin) + data.vary_begin;
        coeffsPr(5) = 9*coeffs(5)/(data.vary_end - data.vary_begin);
        coeffsPr(6) = coeffs(6);
    end
end

set(handles.paramsOutput,'String',num2str(coeffsPr, '%10.3e, '));

function paramsOutput_Callback(~, ~, ~)

function paramsOutput_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function twoCurveCheck_Callback(~, ~, ~)

function checkbox_errorbar_Callback(~, ~, handles)

handles.ExperimentFunctions.LoadExpFromScan(handles);

function checkbox_errorbar_each_avg_Callback(~, ~, handles)

handles.ExperimentFunctions.LoadExpFromScan(handles);

%%%%% END RESULT HANDLING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function tracking_period_Callback(hObject, eventdata, handles)
% hObject    handle to tracking_period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tracking_period as text
%        str2double(get(hObject,'String')) returns contents of tracking_period as a double


% --- Executes during object creation, after setting all properties.
function tracking_period_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tracking_period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton70.
function pushbutton70_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fp = getpref('nv','SavedSequenceDirectory');
[file] = uigetfile('*.mat', 'Choose existing sequence file to load',fp);
handles.nonlinear_data=load (file,'x');
guidata(hObject,handles);


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18
handles.scan_nonlinear_value=get(handles.checkbox18,'Value');
guidata(hObject,handles);


% --- Executes on slider movement.
function phase_slider_Callback(hObject, eventdata, handles)
% hObject    handle to phase_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.phase_box, 'String', get(hObject, 'Value'));
set_phase_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function phase_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phase_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function phase_box_Callback(hObject, eventdata, handles)
% hObject    handle to phase_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phase_box as text
%        str2double(get(hObject,'String')) returns contents of phase_box as a double
%set(handles.phase_slider, 'Value', str2num(get(handles.phase_box, 'String')));


% --- Executes during object creation, after setting all properties.
function phase_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phase_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_phase.
function set_phase_Callback(hObject, eventdata, handles)
% hObject    handle to set_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.phase_val = str2num(get(handles.phase_box, 'String'));
set(handles.phase_slider, 'Value', str2num(get(handles.phase_box, 'String')));
handles.ExperimentFunctions.PhaseSet(handles);
guidata(hObject, handles);


% --- Executes on slider movement.
function amplitude_slider_Callback(hObject, eventdata, handles)
% hObject    handle to amplitude_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.amp_box, 'String', get(hObject, 'Value'));
set_amp_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function amplitude_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amplitude_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function amp_box_Callback(hObject, eventdata, handles)
% hObject    handle to amp_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp_box as text
%        str2double(get(hObject,'String')) returns contents of amp_box as a double
set(handles.amplitude_slider, 'Value', str2num(get(handles.amp_box, 'String')));


% --- Executes during object creation, after setting all properties.
function amp_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_amp.
function set_amp_Callback(hObject, eventdata, handles)
% hObject    handle to set_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.amp_val = str2num(get(handles.amp_box, 'String'));
handles.ExperimentFunctions.AmpSet(handles);
guidata(hObject, handles);



function freq_lock_val_Callback(hObject, eventdata, handles)
% hObject    handle to freq_lock_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq_lock_val as text
%        str2double(get(hObject,'String')) returns contents of freq_lock_val as a double


% --- Executes during object creation, after setting all properties.
function freq_lock_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq_lock_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in freq_lock.
function freq_lock_Callback(hObject, eventdata, handles)
% hObject    handle to freq_lock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.lock_val = str2num(get(handles.freq_lock_val, 'String'));
handles.ExperimentFunctions.FreqSet(handles);
guidata(hObject, handles);


% --- Executes on button press in sweep_phase.
function sweep_phase_Callback(hObject, eventdata, handles)
% hObject    handle to sweep_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for j=-360:5:360
    set(handles.phase_box, 'String', j);
set_phase_Callback(hObject, eventdata, handles);
pause(0.3);
end


% --- Executes on button press in read_phase.
function read_phase_Callback(hObject, eventdata, handles)
% hObject    handle to read_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.phase_val = handles.ExperimentFunctions.PhaseRead(handles);
set(handles.phase_box, 'String', num2str(handles.phase_val));
drawnow();
set(handles.phase_slider, 'Value', str2num(get(handles.phase_box, 'String')));
guidata(hObject, handles);


% --- Executes on button press in button_SetScan.
% function button_SetScan_Callback(hObject, eventdata, handles)
% % hObject    handle to button_SetScan (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% a=1;
