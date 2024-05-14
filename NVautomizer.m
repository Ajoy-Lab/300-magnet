function varargout = NVautomizer(varargin)
% NVAUTOMIZER MATLAB code for NVautomizer.fig
%      NVAUTOMIZER, by itself, creates a new NVAUTOMIZER or raises the existing
%      singleton*.
%
%      H = NVAUTOMIZER returns the handle to a new NVAUTOMIZER or the handle to
%      the existing singleton*.
%
%      NVAUTOMIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NVAUTOMIZER.M with the given input arguments.
%
%      NVAUTOMIZER('Property','Value',...) creates a new NVAUTOMIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NVautomizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NVautomizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NVautomizer

% Last Modified by GUIDE v2.5 14-Feb-2017 15:18:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NVautomizer_OpeningFcn, ...
                   'gui_OutputFcn',  @NVautomizer_OutputFcn, ...
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


% --- Executes just before NVautomizer is made visible.
function NVautomizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NVautomizer (see VARARGIN)

gobj = findall(0,'Name','Imaging');
handles.Imaginghandles = guidata(gobj);
gobj = findall(0,'Name','Experiment');
handles.Experimenthandles = guidata(gobj);
% gobj = findall(0,'Name','stage');
% handles.Stagehandles = guidata(gobj);
% gobj = findall(0,'Name','magnet');
% handles.Magnethandles = guidata(gobj);

handles.Experimentlist = {};
handles.automizer_expt_data={};
handles.Regionlist = {};

%%%%%%%% Added on 09/11/2015 for multiple selection
handles.loaded_Experimentlist = {};
handles.Seq_vars = {};
handles.Sequence_code = {};
%handles.Data_float = {};
%handles.Data_bool = {};
handles.Sequencename = {};
%%%%%%%%

handles.reps={};
handles.avs={};
set(handles.send_mail,'Value',0);
set(handles.toggle_break,'Value',0);
set(handles.quench_scans,'String',num2str(1));



% Choose default command line output for NVautomizer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

clear_NV_Callback(hObject, eventdata, handles);
clear_expt_Callback(hObject, eventdata, handles);


% UIWAIT makes NVautomizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NVautomizer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_automizer.
function add_automizer_Callback(hObject, eventdata, handles)
% hObject    handle to add_automizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.automizer_data=get(handles.automizer,'Data');
handles.automizer_data{end+1,1} = 50;% str2num(get(handles.Imaginghandles.cursorX,'String'));
handles.automizer_data{end,2} =50;%str2num(get(handles.Imaginghandles.cursorY,'String'));
handles.automizer_data{end,3} =50;%str2num(get(handles.Imaginghandles.cursorZ,'String'));
handles.automizer_data{end,4} =false;
set(handles.automizer,'Data',handles.automizer_data);
guidata(hObject, handles);



% --- Executes on button press in remove_automizer.
function remove_automizer_Callback(hObject, eventdata, handles)
% hObject    handle to remove_automizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % OLD code -- removes just last entry
% % handles.automizer_data(end,:)=[]
% 
% % OLD code -- removes mask selected entry
% data=get(handles.automizer,'Data');
% mask=(1:size(data,1))';
% mask(handles.auto_selected_index)=[];
% handles.automizer_data=handles.automizer_data(mask,:);
% set(handles.automizer,'Data',handles.automizer_data);

% NEW code -- removes selected entries

tabledata=get(handles.automizer,'Data');
handles.automizer_data=get(handles.automizer,'Data');
for i=1:length([tabledata{:,4}]);
    if tabledata{i,4}==1;
        handles.automizer_data(i,:)=[];    
    end
end
set(handles.automizer,'Data',handles.automizer_data);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function automizer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to automizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.automizer_data = {};
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function automizer_file_Callback(hObject, eventdata, handles)
% hObject    handle to automizer_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of automizer_file as text
%        str2double(get(hObject,'String')) returns contents of automizer_file as a double


% --- Executes during object creation, after setting all properties.
function automizer_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to automizer_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in start_automizer.
function start_automizer_Callback(hObject, eventdata, handles)
% hObject    handle to start_automizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%fp = getpref('nv','SavedExpDirectory');
fp='C:\300-magnet\21-C\SavedExperiments\';
a = datestr(now,'yyyy-mm-dd-HHMMSS');
fn=['auto-' a];
set(handles.automizer_file,'String',fn);


%% Init scope
% global scopebusy
% scopebusy=0;
% TDS694cFunctionPool('Init');

% fn=get(handles.automizer_file,'String');
ppt_path=[fp '\' fn '.pptx'];
mat_path=[fp '\' fn '.mat'];
% h = actxserver('PowerPoint.Application');
% try
%     h.ActivePresentation.Close;
% catch exception
% end
% 
% %h.Quit
% 
% isOpen  = exportToPPTX();
% if ~isempty(isOpen),
%     exportToPPTX('close');
% end
% 
% 
% 
% exportToPPTX('new','Dimensions',[10 8], ...
%     'Title','Example Presentation', ...
%     'Author','MatLab', ...
%     'Subject','Automatically generated PPTX file', ...
%     'Comments','This file has been automatically generated by exportToPPTX');
% 
% newFile = exportToPPTX('save',ppt_path);
% exportToPPTX('close');


% Now move to positions in automizer table
handles.automizer_data_updated=get(handles.automizer,'Data');

save_auto_Callback(hObject, eventdata, handles); %NOW save automizer data;
%send_email(ppt_path,'',mat_path); %send data
%stopwatch(-60)
%% LOOP OVER NVs
for automizer_loop=1:1
    
    if get(handles.StopAllExperiment,'Value')==1;
      break;
    end
    
    
    xpos=handles.automizer_data_updated{automizer_loop,1};
    ypos=handles.automizer_data_updated{automizer_loop,2};
    zpos=handles.automizer_data_updated{automizer_loop,3};
    set(handles.Imaginghandles.cursorX,'String',num2str(xpos));
    set(handles.Imaginghandles.cursorY,'String',num2str(ypos));
    set(handles.Imaginghandles.cursorZ,'String',num2str(zpos));
     handles.Imaginghandles.ImagingFunctions.CursorPosition = [xpos,ypos,zpos];
    %handles.Imaginghandles.ImagingFunctions.SetCursor(handles.Imaginghandles);
    %pause(1);
%    handles.Imaginghandles.ImagingFunctions.QueryPos(handles.Imaginghandles);
%    pause(1);
%    
   

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    % Set up the experiment parameters


set(handles.Experimenthandles.checkbox_tracking,'Value',0);
set(handles.Experimenthandles.checkbox18,'Value',0);
set(handles.Experimenthandles.panel_tracking_method,'Visible', 'on');
set(handles.Experimenthandles.button_track_per_avg,'Value',1);
set(handles.Experimenthandles.tracking_period,'String',num2str(1));
%% LOOP OVER EXPERIMENTS


remaining_expt_abort=0;
for automizer_expt_loop=1:size(handles.Experimentlist,2)
%     
    if remaining_expt_abort==1 && get(handles.toggle_break,'Value')==1;
        break;
    end
    
    if get(handles.StopAllExperiment,'Value')==1;
      break;
    end
%     

%handles.pi_pulse=52e-9;
% fp = getpref('nv','SavedSequenceDirectory');
fp='C:\300-magnet\21-C\SavedSequences\SavedSequences-PB';

handles.automizer_expt_data=get(handles.automizer_expt,'Data');
file=handles.automizer_expt_data{automizer_expt_loop};
[vars_cell, sequence_code, shaped_pulses_cmds] = get_sequence(file);
    set(handles.Experimenthandles.text_SequenceName,'String',file);
    set(handles.Experimenthandles.table_float,'Enable','On');
    set(handles.Experimenthandles.table_bool,'Enable','On');
    
handles.Experimenthandles.Seq_vars = vars_cell;
handles.Experimenthandles.Sequence_code = sequence_code;
handles.Experimenthandles.Sequencename = file;
handles.Experimenthandles.Data_bool={};
handles.Experimenthandles.Data_float = {};



if strcmp(file,'AWG_power_calibration_xy8_2.xml') ||strcmp(file,'AWG_power_calibration_xy8_8.xml')
    handles.Experimentlist{automizer_expt_loop}{2,2}=handles.frequency*1e6;
elseif strcmp(file,'AWG_power_calibration_xy8_2_with_voltage.xml') ||strcmp(file,'AWG_power_calibration_xy8_8_with_voltage.xml')
    handles.Experimentlist{automizer_expt_loop}{2,2}=handles.frequency*1e6;
elseif strcmp(file,'AWG_optimal_construction_with_BNC_xy8_4.xml')
    handles.Experimentlist{automizer_expt_loop}{3,2}=handles.frequency*1e6;
    handles.Experimentlist{automizer_expt_loop}{4,2}=handles.pi_power;
    handles.Experimentlist{automizer_expt_loop}{2,2}=handles.pi_power;
end

S=size(handles.Experimentlist{1});
if S(1)>=43 &  strcmp(file,'laser_loop_All_Nine_TWO_NMR.xml')
if handles.Experimentlist{1}{43,2} == 0
    if handles.Experimentlist{1}{40,3} == 0
        pw = handles.Experimentlist{1}{40,2};
    elseif handles.Experimentlist{1}{40,3} == 1
        pw = str2num(handles.Experimentlist{1}{40,4});
    end
    if handles.Experimentlist{1}{41,3} == 0
        d3 = handles.Experimentlist{1}{41,2};
    elseif handles.Experimentlist{1}{41,3} == 1
        d3 = str2num(handles.Experimentlist{1}{41,4});
    end
    if handles.Experimentlist{1}{42,3} == 0
        loop_number = handles.Experimentlist{1}{42,2};
    elseif handles.Experimentlist{1}{42,3} == 1
        loop_number = str2num(handles.Experimentlist{1}{42,4});
    end
    make_pw_nmr(pw,d3,loop_number);
elseif handles.Experimentlist{1}{43,2} == 1
    make_pw_nmr_2();
end
end


set(handles.Experimenthandles.table_float,'Data',handles.Experimentlist{automizer_expt_loop});
handles.Experimenthandles.Sequencename=handles.automizer_expt_data{automizer_expt_loop};

hObject_Experiment = findall(0,'Name','Experiment');
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBReset();
%handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBZero();

% Please uncomment these two lines and comments the +4 lines below as well
% as lines 32/32 in  button_SetScan_Callback.m
% to transfer the number of repetitions
% set(handles.Experimenthandles.edit_Repetitions, 'String', num2str(handles.reps{automizer_expt_loop}));
% set(handles.Experimenthandles.edit_Averages, 'String', num2str(handles.avs{automizer_expt_loop}));
handles.Experimenthandles = table_float_CellEditCallback(hObject_Experiment,eventdata,handles.Experimenthandles);
handles.Experimenthandles = button_SetScan_Callback(hObject_Experiment,eventdata,handles.Experimenthandles);
set(handles.Experimenthandles.edit_Repetitions, 'String', num2str(handles.reps{automizer_expt_loop}));
set(handles.Experimenthandles.edit_Averages, 'String', num2str(handles.avs{automizer_expt_loop}));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform experiment
handles.Experimenthandles.ExperimentFinished=0;
    


handles.Experimenthandles.ExperimentFunctions.RunExperiment(handles.Experimenthandles); %RUN THE EXPERIMENT!!
% pause(2);
%    
% % bring in image
% cImage = handles.Imaginghandles.ConfocalScanDisplayed;
% cutoff=str2num(get(handles.Imaginghandles.cutoffEdit,'String'));
% if cutoff==0
%     cutoff=30;
% end
% cImage.ImageData(cImage.ImageData>cutoff) = cutoff;
% 
% xpos=str2num(get(handles.Imaginghandles.cursorX,'String'));
% ypos=str2num(get(handles.Imaginghandles.cursorY,'String'));
% 
% 
% argData = cImage.ImageData;
% argX=cImage.RangeX;
% argY=cImage.RangeY;
% textxlabel='x (\mum)';
% textylabel='y (\mum)';
% figF=1;
% figure(figF);clf;
% set(figF, 'color', 'white');
% 
% 
% MR=[0,0;
%     0.02,0.3; %this is the important extra point
%     0.3,1;
%     1,1];
% MG=[0,0;
%     0.3,0;
%     0.7,1;
%     1,1];
% MB=[0,0;
%     0.7,0;
%     1,1];
% hot2 = colormapRGBmatrices(500,MR,MG,MB);
% 
% opengl software
% pcolor(argX,argY,argData);
% hold on;rectangle('Curvature', [1 1],'Position', [xpos-1 ypos-1 2 2],'Linewidth',3); hold off;%create a circle at the position of the NV
% shading ('interp');
% colormap(hot2);
% set(gca,'YDir','normal');
% daspect([1 1 1]);
% set(gca,'ticklength',[0.02 0.02]);
% set(gca,'tickdir','out');
% xlabel(textxlabel);
% ylabel(textylabel);
% axis([min(argX), max(argX), min(argY), max(argY)]);
% grid();
% set(gca,'layer','top');
% set(gca,'LineWidth',2);
% rectangle('Curvature', [1 1],'Position', [xpos-1 ypos-1 2 2],'Linewidth',3); %create a circle at the position of the NV
% 
% 
% h = colorbar('EastOutside');
% set(get(h,'ylabel'),'String','kcps');
% drawnow();
% 
% h = actxserver('PowerPoint.Application');
% try
%     h.ActivePresentation.Close;
% catch exception
% end
% 
% 
% 
% % get parameters
% Pos_motorX=str2num(get(handles.Stagehandles.Pos_x,'String'));
% Pos_motorY=str2num(get(handles.Stagehandles.Pos_y,'String'));
% 
% Pos_obj=str2num(get(handles.Imaginghandles.Pos_obj,'String'));
% cursorX=str2num(get(handles.Imaginghandles.cursorX,'String'));
% cursorY=str2num(get(handles.Imaginghandles.cursorY,'String'));
% cursorZ=str2num(get(handles.Imaginghandles.cursorZ,'String'));
% 
% % exportToPPTX('addtext',sprintf('Actuators: X %2.4f  Y %2.4f  Z %2.4f\nPiezo: X %2.4f  Y %2.4f  Z %2.4f',...
% %     Pos_motorX,Pos_motorY,Pos_obj,cursorX,cursorY,cursorZ),'Position',[1 0 10 1.5],'FontSize',20);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Now save the experiment plot!. This is a variant of the ExpPlot function
% exps = get(handles.Experimenthandles.popup_experiments,'String');
% selectedExp= exps{get(handles.Experimenthandles.popup_experiments,'Value')+1};
% fp = getpref('nv','SavedExpDirectory');
% SavedExp = load(fullfile(fp,selectedExp));
% handles.ExperimentalScanDisplayed = SavedExp.Scan;
% scan=handles.ExperimentalScanDisplayed;
% sliderValue=1;
% 
% 
% exportToPPTX('open',ppt_path);
% if ~(strcmp(scan.SequenceName,'PBODMR20ms.xml')||strcmp(scan.SequenceName,'PBODMR20ms_WF.xml'))  %IF NOT ODMR make a new slide. If ODMR make slide only if satisfies not abort
% slideNum = exportToPPTX('addslide');
% fprintf('Added slide %d\n',slideNum);
% end
% 
% 
% figH=2;
% figure(figH);clf;
% set(figH, 'color', 'white');
% 
% colors = ['k' 'r' 'b' 'g' 'm' 'y']; % enough for 6 rises of SPD Acq
% 
% handles.AnalysisFunctions.Ex=zeros(1,scan.Averages);
% clear x y;
% x = linspace(scan.vary_begin(1),scan.vary_end(1),scan.vary_points(1));
% for j=1:1:length(scan.ExperimentData{sliderValue})
%     y = scan.ExperimentData{sliderValue}{j};
%     figure(figH);
%     plot(x,y,['.-' colors(j)]);
%     hold on;
%     grid on;
% end
% 
% a = {'Rise 1', 'Rise 2', 'Rise 3', 'Rise 4', 'Rise 5', 'Rise 6'};
% legend(a(1:1:length(scan.ExperimentData{sliderValue})));
% xlabel(scan.vary_prop{1});
% ylabel('kcps');
% title([scan.SequenceName ' ' scan.DateTime]);
% drawnow();

%email_recent;
end
% if get(handles.send_mail,'Value')==1
%     send_email(ppt_path,'',ppt_path); %SEND EMAIL after every NV
% end
end
%send_email(ppt_path,'',ppt_path);

% --- Executes on button press in stop_automizer.
function stop_automizer_Callback(hObject, eventdata, handles)
% hObject    handle to stop_automizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Experimenthandles.ExperimentFunctions.AbortRun(handles.Experimenthandles); %STOP THE EXPERIMENT!!

% --- Executes on button press in load_expt.
function load_expt_Callback(hObject, eventdata, handles)
% hObject    handle to load_expt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%fp = getpref('nv','SavedSequenceDirectory');
fp='C:\300-magnet\21-C\SavedSequences\SavedSequences-PB';
[file] = uigetfile('*.xml', 'Choose existing sequence file to load','MultiSelect','on',fp);
file = cellstr(file)

handles.Seq_vars = {};
handles.Sequence_code = {};
handles.Data_float = {};
handles.Data_bool = {};
handles.Sequencename = {};
handles.loaded_Experimentlist = {};

for index = 1:length(file)
    
if file{index} ~= 0
    [vars_cell, sequence_code, shaped_pulses_cmds] =get_sequence(file{index});
    set(handles.automizer_expt_detail,'Enable','On');
else
    uiwait(warndlg({'Sequence file not loaded. Aborted.'}));
    return;
end

handles.Seq_vars{end+1} = vars_cell;
handles.Sequence_code{end+1} = sequence_code;
handles.Data_float = {};
handles.Data_bool = {};
handles.Data_AWGparam = {};
handles.Sequencename{end+1} = file{index};

for aux=1:1:length(vars_cell)
    
    if strcmp(vars_cell{aux}.variable_type, 'float')
        handles.Data_float{end+1,1} = vars_cell{aux}.name;
        handles.Data_float{end,2} = vars_cell{aux}.default_value;
        handles.Data_float{end,3} = false;
        handles.Data_float{end,4} = '';
        handles.Data_float{end,5} = '';
        handles.Data_float{end,6} = '';
        handles.Data_float{end,7} = 'float';
        
    elseif strcmp(vars_cell{aux}.variable_type, 'AWGparam')
        handles.Data_float{end+1,1} = vars_cell{aux}.name;
        handles.Data_float{end,2} = vars_cell{aux}.default_value;
        handles.Data_float{end,3} = false;
        handles.Data_float{end,4} = '';
        handles.Data_float{end,5} = '';
        handles.Data_float{end,6} = '';
        handles.Data_float{end,7} = 'AWGparam';
        
    elseif strcmp(vars_cell{aux}.variable_type, 'ProtectedPar')
        handles.Data_float{end+1,1} = vars_cell{aux}.name;
        handles.Data_float{end,2} = vars_cell{aux}.default_value;
        handles.Data_float{end,3} = false;
        handles.Data_float{end,4} = '';
        handles.Data_float{end,5} = '';
        handles.Data_float{end,6} = '';
        handles.Data_float{end,7} = 'ProtectedPar';
        
    elseif strcmp(vars_cell{aux}.variable_type, 'boolean')
        handles.Data_bool{end+1,1} = logical(vars_cell{aux}.default_value);
        handles.Data_bool{end,2} = vars_cell{aux}.name;
        
    end
    
end

set(handles.automizer_expt_detail,'Data',handles.Data_float);
handles.loaded_Experimentlist{end+1} = get(handles.automizer_expt_detail,'Data');
end
% Update handles structure
guidata(hObject, handles);

% % --- Executes on button press in load_expt.
% function load_expt_Callback(hObject, eventdata, handles)
% % hObject    handle to load_expt (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% fp = getpref('nv','SavedSequenceDirectory');
% [file] = uigetfile('*.xml', 'Choose existing sequence file to load',fp);
% 
%     
% if file ~= 0
%     [vars_cell, sequence_code, shaped_pulses_cmds] =get_sequence(file);
%     set(handles.automizer_expt_detail,'Enable','On');
% else
%     uiwait(warndlg({'Sequence file not loaded. Aborted.'}));
%     return;
% end
% 
% handles.Seq_vars = vars_cell;
% handles.Sequence_code = sequence_code;
% handles.Data_float = {};
% handles.Data_bool = {};
% handles.Sequencename = file;
% 
% for aux=1:1:length(vars_cell)
%     
%     if strcmp(vars_cell{aux}.variable_type, 'float')
%         handles.Data_float{end+1,1} = vars_cell{aux}.name;
%         handles.Data_float{end,2} = vars_cell{aux}.default_value;
%         handles.Data_float{end,3} = false;
%         handles.Data_float{end,4} = '';
%         handles.Data_float{end,5} = '';
%         handles.Data_float{end,6} = '';
%         
%     elseif strcmp(vars_cell{aux}.variable_type, 'boolean')
%         handles.Data_bool{end+1,1} = logical(vars_cell{aux}.default_value);
%         handles.Data_bool{end,2} = vars_cell{aux}.name;
%         
%     end
%     
% end
% 
% set(handles.automizer_expt_detail,'Data',handles.Data_float);
% 
% % Update handles structure
% guidata(hObject, handles);


% --- Executes on button press in add_expt.
function add_expt_Callback(hObject, eventdata, handles)
% hObject    handle to add_expt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for index2 = 1:length(handles.Sequencename)
    
handles.automizer_expt_data=get(handles.automizer_expt,'Data');
%handles.Experimentlist{end+1} = get(handles.automizer_expt_detail,'Data');
%%%%% 09/11/2015 
handles.Experimentlist{end+1} =  handles.loaded_Experimentlist{index2};
handles.automizer_expt_data{end+1,1} = handles.Sequencename{index2};
%%%%%
%%%%%
handles.automizer_expt_data{end,2}=false;
handles.automizer_expt_data{end,3}=false;
set(handles.automizer_expt,'Data',handles.automizer_expt_data);
handles.reps{end+1}=str2num(get(handles.automizer_reps,'String'));
handles.avs{end+1}=str2num(get(handles.automizer_avs,'String'));
guidata(hObject, handles);

end
clear handles.loaded_Experimentlist;


% % --- Executes on button press in add_expt.
% function add_expt_Callback(hObject, eventdata, handles)
% % hObject    handle to add_expt (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
%     
% handles.automizer_expt_data=get(handles.automizer_expt,'Data');
% handles.Experimentlist{end+1} = get(handles.automizer_expt_detail,'Data');
% handles.automizer_expt_data{end+1,1} = handles.Sequencename;
% handles.automizer_expt_data{end,2}=false;
% handles.automizer_expt_data{end,3}=false;
% set(handles.automizer_expt,'Data',handles.automizer_expt_data);
% handles.reps{end+1}=str2num(get(handles.automizer_reps,'String'));
% handles.avs{end+1}=str2num(get(handles.automizer_avs,'String'));
% guidata(hObject, handles);



% --- Executes on button press in remove_expt.
function remove_expt_Callback(hObject, eventdata, handles)
% hObject    handle to remove_expt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 

% % % old code -- just removes last entry
% % 
% handles.Experimentlist(end)=[];
%  handles.reps(end)=[];
%  handles.avs(end)=[];
%   handles.automizer_expt_data(end,:)=[];
% set(handles.automizer_expt,'Data',handles.automizer_expt_data);
% guidata(hObject, handles);

% new code -- removes selected rows
% mask=(1:size(handles.Experimentlist,2))';
% mask(handles.expt_selected_index)=[];
% handles.automizer_expt_data=handles.automizer_expt_data(mask,:);
% handles.Experimentlist=handles.Experimentlist{mask};
% handles.reps=handles.reps{mask};
% handles.avs=handles.avs{mask};
% 
% set(handles.automizer_expt,'Data',handles.automizer_expt_data);
% guidata(hObject, handles);

% Here remove according to the logical selection
tabledata=get(handles.automizer_expt,'Data');
 handles.automizer_expt_data=get(handles.automizer_expt,'Data');
for i=1:length([tabledata{:,3}]);
    if tabledata{i,3}==1;
         handles.Experimentlist(i)=[];
        handles.reps(i)=[];
        handles.avs(i)=[];
        handles.automizer_expt_data(i,:)=[];    
    end
end
set(handles.automizer_expt,'Data',handles.automizer_expt_data);
guidata(hObject, handles);



function automizer_reps_Callback(hObject, eventdata, handles)
% hObject    handle to automizer_reps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of automizer_reps as text
%        str2double(get(hObject,'String')) returns contents of automizer_reps as a double


% --- Executes during object creation, after setting all properties.
function automizer_reps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to automizer_reps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function automizer_avs_Callback(hObject, eventdata, handles)
% hObject    handle to automizer_avs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of automizer_avs as text
%        str2double(get(hObject,'String')) returns contents of automizer_avs as a double


% --- Executes during object creation, after setting all properties.
function automizer_avs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to automizer_avs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pull_NV.
function pull_NV_Callback(hObject, eventdata, handles)
% hObject    handle to pull_NV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gobj = findall(0,'Name','Imaging');
handles.Imaginghandles = guidata(gobj);

for j=1:size(handles.Imaginghandles.nv_pos_x,2)
handles.automizer_data{end+1,1} = handles.Imaginghandles.nv_pos_x(j);
handles.automizer_data{end,2} =handles.Imaginghandles.nv_pos_y(j);
handles.automizer_data{end,3} =handles.Imaginghandles.nv_pos_z;
handles.automizer_data{end,4} =false;
set(handles.automizer,'Data',handles.automizer_data);
end
guidata(hObject, handles);


% --- Executes on button press in clear_NV.
function clear_NV_Callback(hObject, eventdata, handles)
% hObject    handle to clear_NV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 handles.automizer_data(:,:)=[];
set(handles.automizer,'Data',handles.automizer_data);
guidata(hObject, handles);


% --- Executes on button press in filter_NV.
function filter_NV_Callback(hObject, eventdata, handles)
% hObject    handle to filter_NV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.automizer_data_updated=get(handles.automizer,'Data');

%TURN ON LASER
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StartProgramming();
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_CONTINUE,...
    0, 750,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_BRANCH,...
    0, 150,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StopProgramming();
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart();
set(handles.Imaginghandles.toggle_LaserOnOff,'String','Laser On');
set(handles.Imaginghandles.toggle_LaserOnOff,'ForegroundColor',[0.847 0.161 0]);


%% LOOP OVER NVs
s=size(handles.automizer_data_updated,1);
automizer_loop=1;
while automizer_loop<=s
    xpos=handles.automizer_data_updated{automizer_loop,1};
    ypos=handles.automizer_data_updated{automizer_loop,2};
    zpos=handles.automizer_data_updated{automizer_loop,3};
    set(handles.Imaginghandles.cursorX,'String',num2str(xpos));
    set(handles.Imaginghandles.cursorY,'String',num2str(ypos));
    set(handles.Imaginghandles.cursorZ,'String',num2str(zpos));
     handles.Imaginghandles.ImagingFunctions.CursorPosition = [xpos,ypos,zpos];
    handles.Imaginghandles.ImagingFunctions.SetCursor(handles.Imaginghandles);
    pause(0.1);
   
   ReferenceCounts1 = handles.Imaginghandles.ImagingFunctions.kCountsPerSecond()
   filter_val=str2num(get(handles.filter_val,'String'));
   if isempty(filter_val)
       filter_val=7;
   end    
   if ReferenceCounts1<=filter_val
       handles.automizer_data_updated(automizer_loop,:)=[];
       s=s-1;
       automizer_loop=automizer_loop-1;
   elseif ReferenceCounts1>filter_val
       pause(6);
       ReferenceCounts2 = handles.Imaginghandles.ImagingFunctions.kCountsPerSecond()
       % Check if NV
       if ReferenceCounts1-ReferenceCounts2>=0.25*ReferenceCounts1 || ReferenceCounts2<5
           handles.automizer_data_updated(automizer_loop,:)=[];
           s=s-1;
           automizer_loop=automizer_loop-1;
       end
   end
   automizer_loop=automizer_loop+1;
   set(handles.automizer,'Data',handles.automizer_data_updated);
end

% now push back into imaging
handles.Imaginghandles.nv_pos_x=[];
handles.Imaginghandles.nv_pos_y=[];
for j=1:size(handles.automizer_data_updated,1)
   handles.Imaginghandles.nv_pos_x(j)= handles.automizer_data_updated{j,1};
   handles.Imaginghandles.nv_pos_y(j)= handles.automizer_data_updated{j,2};
end

handles.Imaginghandles.ImagingFunctions.LoadImagesFromScan(handles.Imaginghandles);
%handles.Imaginghandles.filterButton_Callback(1,2,handles.Imaginghandles);
hold (handles.Imaginghandles.imageAxes,'on');
scatter(handles.Imaginghandles.imageAxes,handles.Imaginghandles.nv_pos_x,handles.Imaginghandles.nv_pos_y,'k');
hold (handles.Imaginghandles.imageAxes,'off');

guidata(hObject, handles);


% --- Executes on button press in pull_region.
function pull_region_Callback(hObject, eventdata, handles)
% hObject    handle to pull_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% gobj = findall(0,'Name','Imaging');
% handles.Imaginghandles = guidata(gobj);
% 
% gobj = findall(0,'Name','stage');
% handles.Stagehandles = guidata(gobj);

% handles.Imaginghandles.ImagingFunctions.refresh_motorX_Callback(handles.Imaginghandles);
% handles.Imaginghandles.ImagingFunctions.refresh_motorY_Callback(handles.Imaginghandles);

handles.Stagehandles.stagefunctions.refresh_stage(handles.Stagehandles);

handles.Regionlist{end+1,1} =str2num(get(handles.Imaginghandles.minX,'String'));
handles.Regionlist{end,2} =str2num(get(handles.Imaginghandles.maxX,'String'));
handles.Regionlist{end,3} =str2num(get(handles.Imaginghandles.minY,'String'));
handles.Regionlist{end,4} =str2num(get(handles.Imaginghandles.maxY,'String'));
handles.Regionlist{end,5} =str2num(get(handles.Stagehandles.Pos_x,'String'));
handles.Regionlist{end,6} =str2num(get(handles.Stagehandles.Pos_y,'String'));
handles.Regionlist{end,7} =false;

set(handles.automizer_region,'Data',handles.Regionlist);

guidata(hObject, handles);



function points_x_Callback(hObject, eventdata, handles)
% hObject    handle to points_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of points_x as text
%        str2double(get(hObject,'String')) returns contents of points_x as a double


% --- Executes during object creation, after setting all properties.
function points_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to points_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function points_y_Callback(hObject, eventdata, handles)
% hObject    handle to points_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of points_y as text
%        str2double(get(hObject,'String')) returns contents of points_y as a double


% --- Executes during object creation, after setting all properties.
function points_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to points_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in remove_region.
function remove_region_Callback(hObject, eventdata, handles)
% hObject    handle to remove_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% OLD CODE -- just remove the last one
% handles.Regionlist(end,:)=[];
% set(handles.automizer_region,'Data',handles.Regionlist);
% guidata(hObject, handles);

% NEW CODE -- remove the selected
tabledata=get(handles.automizer_region,'Data');

for i=1:length([tabledata{:,7}]);
    if tabledata{i,7}==1;
        handles.Regionlist(i,:)=[]; 
    end
end
set(handles.automizer_region,'Data',handles.Regionlist);
guidata(hObject, handles);

% --- Executes on button press in clear_region.
function clear_region_Callback(hObject, eventdata, handles)
% hObject    handle to clear_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Regionlist(:,:)=[];
set(handles.automizer_region,'Data',handles.Regionlist);
guidata(hObject, handles);


% --- Executes on button press in start_autoT2.
function start_autoT2_Callback(hObject, eventdata, handles)
% hObject    handle to start_autoT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% gobj = findall(0,'Name','Imaging');
% handles.Imaginghandles = guidata(gobj);
% 
% gobj = findall(0,'Name','Stage');
% handles.Stagehandles = guidata(gobj);

handles.Regionlist=get(handles.automizer_region,'Data');

for ind=1:size(handles.Regionlist,1)
set(handles.Imaginghandles.minX,'String', handles.Regionlist{ind,1});
set(handles.Imaginghandles.maxX,'String', handles.Regionlist{ind,2});
set(handles.Imaginghandles.minY,'String', handles.Regionlist{ind,3});
set(handles.Imaginghandles.maxY,'String', handles.Regionlist{ind,4});
set(handles.Imaginghandles.pointsX,'String', floor(handles.Regionlist{ind,2}-handles.Regionlist{ind,1})*10);
set(handles.Imaginghandles.pointsY,'String', floor(handles.Regionlist{ind,4}-handles.Regionlist{ind,3})*10);
set(handles.Imaginghandles.enableX,'Value',1);
set(handles.Imaginghandles.enableY,'Value',1);
set(handles.Imaginghandles.enableZ,'Value',0);
set(handles.Imaginghandles.cutoffEdit,'String',num2str(40));
set(handles.Imaginghandles.DwellScanValue,'String',num2str(0.0048));


% set(handles.Imaginghandles.Pos_motorX, 'String', handles.Regionlist{ind,5});
% set(handles.Imaginghandles.Pos_motorY, 'String', handles.Regionlist{ind,6});

set(handles.Stagehandles.Pos_x, 'String', handles.Regionlist{ind,5});
set(handles.Stagehandles.Pos_y, 'String', handles.Regionlist{ind,6});

%move to region
% handles.Imaginghandles.ImagingFunctions.move_motorX_Callback(handles.Imaginghandles);
% handles.Imaginghandles.ImagingFunctions.move_motorY_Callback(handles.Imaginghandles);

handles.Stagehandles.stagefunctions.move_stage_x(handles.Stagehandles);
handles.Stagehandles.stagefunctions.move_stage_y(handles.Stagehandles);

%TURN ON LASER
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StartProgramming();
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_CONTINUE,...
    0, 750,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_BRANCH,...
    0, 150,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StopProgramming();
handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart();
set(handles.Imaginghandles.toggle_LaserOnOff,'String','Laser On');
set(handles.Imaginghandles.toggle_LaserOnOff,'ForegroundColor',[0.847 0.161 0]);

%SCAN
hObject_Imaging = findall(0,'Name','Imaging');
%handles.Imaginghandles =  buttonSaveScan_Callback(hObject_Imaging,eventdata,handles.Imaginghandles);
quench_scans=str2num(get(handles.quench_scans,'String'));
for jscan=1:quench_scans
    if jscan~=quench_scans 
    set(handles.Imaginghandles.DwellScanValue,'String',num2str(0.00096));
    else
        set(handles.Imaginghandles.DwellScanValue,'String',num2str(0.0048));
    end
    handles.Imaginghandles =  buttonSaveScan_Callback(hObject_Imaging,eventdata,handles.Imaginghandles);
handles.Imaginghandles =  buttonScan_Callback(hObject_Imaging, eventdata,handles.Imaginghandles);
pause(1);
end

% FIND NVs
handles.Imaginghandles =  findNV_Callback(hObject_Imaging, eventdata,handles.Imaginghandles);
clear_NV_Callback(hObject, eventdata, handles)
pull_NV_Callback(hObject, eventdata, handles);
filter_NV_Callback(hObject, eventdata, handles);
% filter_NV_Callback(hObject, eventdata, handles);

%filter_NV_Callback(hObject, eventdata, handles);

% DO EXPT
set(handles.automizer_file,'String', ['automizer' '_' date '_' num2str(ind)]);

start_automizer_Callback(hObject, eventdata, handles);
end
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in automizer.
function automizer_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to automizer (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.auto_selected_index=[];
rows_selected=[];
auto_selected_index=eventdata.Indices;
if any(auto_selected_index)
    rows_selected=auto_selected_index(:,1);
end
handles.auto_selected_index=rows_selected;
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in automizer_expt.
function automizer_expt_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to automizer_expt (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.expt_selected_index=[];
expt_rows_selected=[];
auto_expt_selected_index=eventdata.Indices;
if any(auto_expt_selected_index)
    expt_rows_selected=auto_expt_selected_index(:,1);
end
handles.expt_selected_index=expt_rows_selected;
guidata(hObject, handles);


% --- Executes on button press in edit_expt.
function edit_expt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_expt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% OLD CODE -- uses mask selection
% selected=handles.expt_selected_index(end);
% set(handles.automizer_expt_detail,'Data',handles.Experimentlist{selected});
% set(handles.automizer_reps,'String',num2str(handles.reps{selected}));
% set(handles.automizer_avs,'String',num2str(handles.avs{selected}));
% guidata(hObject, handles);

% NEW CODE -- uses selection
tabledata=get(handles.automizer_expt,'Data')

for i=1:size(tabledata,1)
    if tabledata{i,2}==1
       % tabledata{i,2}=0;
        set(handles.automizer_expt_detail,'Data',handles.Experimentlist{i});
        set(handles.automizer_reps,'String',num2str(handles.reps{i}))
        set(handles.automizer_avs,'String',num2str(handles.avs{i}));
        handles.Sequencename=tabledata{i,1};
        break;
    end
end
guidata(hObject, handles);




% --- Executes on button press in push_expt.
function push_expt_Callback(hObject, eventdata, handles)
% hObject    handle to push_expt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% OLD CODE -- uses mask selection

% selected=handles.expt_selected_index(end);
% handles.Experimentlist{selected} = get(handles.automizer_expt_detail,'Data');
% handles.automizer_expt_data{selected,1} = handles.Sequencename;
% set(handles.automizer_expt,'Data',handles.automizer_expt_data);
% handles.reps{selected}=str2num(get(handles.automizer_reps,'String'));
% handles.avs{selected}=str2num(get(handles.automizer_avs,'String'));
% guidata(hObject, handles);

% NEW CODE -- uses selection
tabledata=get(handles.automizer_expt,'Data');
handles.automizer_expt_data=get(handles.automizer_expt,'Data');
for i=1:length([tabledata{:,2}])
    if tabledata{i,2}==1;
       selected=i;
        break;
    end
end

handles.Experimentlist{selected} = get(handles.automizer_expt_detail,'Data');
handles.automizer_expt_data{selected,2} = false;
set(handles.automizer_expt,'Data',handles.automizer_expt_data);
handles.reps{selected}=str2num(get(handles.automizer_reps,'String'));
handles.avs{selected}=str2num(get(handles.automizer_avs,'String'));

guidata(hObject, handles);



% --- Executes on button press in clear_expt.
function clear_expt_Callback(hObject, eventdata, handles)
% hObject    handle to clear_expt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Experimentlist={};
 handles.reps={};
 handles.avs={};
  handles.automizer_expt_data={};
set(handles.automizer_expt,'Data',handles.automizer_expt_data);
guidata(hObject, handles);



function filter_val_Callback(hObject, eventdata, handles)
% hObject    handle to filter_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_val as text
%        str2double(get(hObject,'String')) returns contents of filter_val as a double


% --- Executes during object creation, after setting all properties.
function filter_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_auto.
function save_auto_Callback(hObject, eventdata, handles)
% hObject    handle to save_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% fp = getpref('nv','SavedExpDirectory');
% fn=get(handles.automizer_file,'String');
% save_path=[fp '\' fn '.mat'];
% save(save_path,'handles');

fp='C:\300-magnet\21-C\SavedExperiments\';
% fp = getpref('nv','SavedExpDirectory');
fn=get(handles.automizer_file,'String');
save_path=[fp '\' fn '.mat'];
automizer_expt_save=get(handles.automizer_expt,'Data');
automizer_region_save=get(handles.automizer_region,'Data');
automizer_save=get(handles.automizer,'Data');
Experimentlist_save=handles.Experimentlist;
reps_save=handles.reps;
avs_save=handles.avs;

%save(save_path,'handles');
save(save_path,'automizer_expt_save','automizer_region_save','automizer_save','Experimentlist_save','reps_save','avs_save');



% --- Executes on button press in load_auto.
function load_auto_Callback(hObject, eventdata, handles)
% hObject    handle to load_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% gobj = findall(0,'Name','NVautomizer');
% %handles = guidata(gobj);
% 
% fp = getpref('nv','SavedExpDirectory');
% handles.Arg_x=[];handles.Arg_y=[];handles.Arg_z=[];handles.file=[];
% [file] = uigetfile('*.mat', 'Choose existing sequence file to load',fp);
% h=load(file);
% handles2=h.handles;
% set(handles.automizer,'Data',handles2.automizer_data);
% set(handles.automizer_region,'Data',handles2.Regionlist);
% set(handles.automizer_expt,'Data',handles2.automizer_expt_data);
% handles.Experimentlist=handles2.Experimentlist;
% handles.reps=handles2.reps;
% handles.avs=handles2.avs;
% 
% guidata(hObject, handles);

gobj = findall(0,'Name','NVautomizer');
%handles = guidata(gobj);

%fp = getpref('nv','SavedExpDirectory');
fp='C:\300-magnet\21-C\SavedExperiments';
handles.Arg_x=[];handles.Arg_y=[];handles.Arg_z=[];handles.file=[];
[file] = uigetfile('*.mat', 'Choose existing sequence file to load',fp);
load([fp '\' file]);

set(handles.automizer,'Data',automizer_save);

set(handles.automizer_region,'Data',automizer_region_save);
set(handles.automizer_expt,'Data',automizer_expt_save);
handles.Experimentlist=Experimentlist_save;
handles.reps=reps_save;
handles.avs=avs_save;

guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in automizer_expt.
function automizer_expt_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to automizer_expt (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
tabledata = get(hObject, 'data');
guidata(hObject, handles);


% --- Executes on button press in StopAllExperiment.
function StopAllExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to StopAllExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StopAllExperiment


% --- Executes on button press in send_mail.
function send_mail_Callback(hObject, eventdata, handles)
% hObject    handle to send_mail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of send_mail



function quench_scans_Callback(hObject, eventdata, handles)
% hObject    handle to quench_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quench_scans as text
%        str2double(get(hObject,'String')) returns contents of quench_scans as a double


% --- Executes during object creation, after setting all properties.
function quench_scans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quench_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frequency_Callback(hObject, eventdata, handles)
% hObject    handle to frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frequency as text
%        str2double(get(hObject,'String')) returns contents of frequency as a double


% --- Executes during object creation, after setting all properties.
function frequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in toggle_break.
function toggle_break_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_break (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_break


% --- Executes when entered data in editable cell(s) in automizer_region.
function automizer_region_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to automizer_region (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

handles.Regionlist=get(handles.automizer_region,'Data');
guidata(hObject, handles);


% --- Executes on button press in clone.
function clone_Callback(hObject, eventdata, handles)
% hObject    handle to clone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tabledata=get(handles.automizer_expt,'Data');
handles.automizer_expt_data=get(handles.automizer_expt,'Data');
for i=2:length([tabledata{:,2}])
    for j=1:size(handles.Experimentlist{1},1)
        if ~strcmp(handles.Experimentlist{1}(j,end),'ProtectedPar')
        handles.Experimentlist{i}(j,2:end) = handles.Experimentlist{1}(j,2:end);
        end
    end
    handles.reps{i}=handles.reps{1};
    handles.avs{i}=handles.avs{1};
end    
guidata(hObject, handles);

% --- Executes on button press in bulk clone.
function bulk_clone_Callback(hObject, eventdata, handles)
% hObject    handle to clone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tabledata=get(handles.automizer_expt,'Data');
handles.automizer_expt_data=get(handles.automizer_expt,'Data');

ind=[];count=0;
for j=1:length([tabledata{:,2}])
    if tabledata{j,2}==1
        count=count+1;
        ind(count)=j;
    end
end

L=length([tabledata{:,2}]);
for i=1:count
    handles.Experimentlist{L+i}=[];
    handles.automizer_expt_data{L+i}=[];
    handles.Experimentlist{L+i} = handles.Experimentlist{ind(i)};
    for j=1:3
        handles.automizer_expt_data{L+i,1}=handles.automizer_expt_data{ind(i),1};
        handles.automizer_expt_data{L+i,2}=false;handles.automizer_expt_data{L+i,3}=false;
        handles.automizer_expt_data{ind(i),2}=false;handles.automizer_expt_data{ind(i),3}=false;
    end
    handles.reps{L+i}=handles.reps{ind(i)};
    handles.avs{L+i}=handles.avs{ind(i)};
end    
set(handles.automizer_expt,'Data',handles.automizer_expt_data);
guidata(hObject, handles);

% --- Executes when selected cell(s) is changed in automizer_expt_detail.
function automizer_expt_detail_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to automizer_expt_detail (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in automizer_expt_detail.
function automizer_expt_detail_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to automizer_expt_detail (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in auto_magnet.
function auto_magnet_Callback(hObject, eventdata, handles)
% hObject    handle to auto_magnet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fp = getpref('nv','SavedExpDirectory');
a = datestr(now,'yyyy-mm-dd-HHMMSS');
fn=['auto-magnet-' a];
filename=[fp '\' fn '.mat'];

magnet_positions_x=[];magnet_positions_y=[];magnet_positions_z=[];
handles.Magnethandles.magnetfunctions.refresh_magnet(handles.Magnethandles);

if get(handles.Magnethandles.check_scanz,'Value')==1 && get(handles.Magnethandles.check_scanx,'Value')==0 && get(handles.Magnethandles.check_scany,'Value')==0
    zmin = str2num(get(handles.Magnethandles.scan_zmin, 'String'));
    zmax = str2num(get(handles.Magnethandles.scan_zmax, 'String'));
    
    points = str2num(get(handles.Magnethandles.points_z, 'String'));
    Arg=linspace(zmin,zmax,points);
    
    for ind=1:points
        if get(handles.StopAllExperiment,'Value')==1;
            break;
        end
        
        %TURN ON LASER
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StartProgramming();
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_CONTINUE,...
            0, 750,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_BRANCH,...
            0, 150,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StopProgramming();
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart();
        set(handles.Imaginghandles.toggle_LaserOnOff,'String','Laser On');
        set(handles.Imaginghandles.toggle_LaserOnOff,'ForegroundColor',[0.847 0.161 0]);
        
        
        set(handles.Magnethandles.Pos_z, 'String', num2str(Arg(ind)));
        handles.Magnethandles.magnetfunctions.move_magnet_z(handles.Magnethandles);
        handles.Magnethandles.magnetfunctions.magnet_track(handles.Magnethandles);
        handles.Magnethandles.magnetfunctions.refresh_magnet(handles.Magnethandles);
        magnet_positions_x(ind)= str2num(get(handles.Magnethandles.Pos_x, 'String'));
        magnet_positions_y(ind)= str2num(get(handles.Magnethandles.Pos_y, 'String'));
        magnet_positions_z(ind)= str2num(get(handles.Magnethandles.Pos_z, 'String'));
        save(filename,'magnet_positions_x','magnet_positions_y','magnet_positions_z','fn');
        
        if get(handles.StopAllExperiment,'Value')==1;
            send_email(fn,' ',filename);
            break;
        end
        
        
        clear_NV_Callback(hObject, eventdata, handles);
        add_automizer_Callback(hObject, eventdata, handles);
       start_automizer_Callback(hObject, eventdata, handles);
        
    end
     send_email(fn,' ',filename);
     
elseif get(handles.Magnethandles.check_scanz,'Value')==0 && get(handles.Magnethandles.check_scanx,'Value')==1 && get(handles.Magnethandles.check_scany,'Value')==0
    xmin = str2num(get(handles.Magnethandles.scan_xmin, 'String'));
    xmax = str2num(get(handles.Magnethandles.scan_xmax, 'String'));
    
    points = str2num(get(handles.Magnethandles.points_x, 'String'));
    Arg=linspace(xmin,xmax,points);
    
    for ind=1:points
        if get(handles.StopAllExperiment,'Value')==1;
            break;
        end
        
        %TURN ON LASER
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StartProgramming();
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_CONTINUE,...
            0, 750,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBInstruction(1,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.INST_BRANCH,...
            0, 150,handles.Imaginghandles.ImagingFunctions.interfacePulseGen.ON);
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.StopProgramming();
        handles.Imaginghandles.ImagingFunctions.interfacePulseGen.PBStart();
        set(handles.Imaginghandles.toggle_LaserOnOff,'String','Laser On');
        set(handles.Imaginghandles.toggle_LaserOnOff,'ForegroundColor',[0.847 0.161 0]);
        
        
        set(handles.Magnethandles.Pos_x, 'String', num2str(Arg(ind)));
        handles.Magnethandles.magnetfunctions.move_magnet_x(handles.Magnethandles);
        
        handles.Magnethandles.magnetfunctions.refresh_magnet(handles.Magnethandles);
         magnet_positions_x(ind)= str2num(get(handles.Magnethandles.Pos_x, 'String'));
        magnet_positions_y(ind)= str2num(get(handles.Magnethandles.Pos_y, 'String'));
        magnet_positions_z(ind)= str2num(get(handles.Magnethandles.Pos_z, 'String'));
        save(filename,'magnet_positions_x','magnet_positions_y','magnet_positions_z','fn');
        
        if get(handles.StopAllExperiment,'Value')==1;
            send_email(fn,' ',filename);
            break;
        end
        
        
        clear_NV_Callback(hObject, eventdata, handles);
        add_automizer_Callback(hObject, eventdata, handles);
        start_automizer_Callback(hObject, eventdata, handles);
        
    end
     
    send_email(fn,' ',filename);
   
end
guidata(hObject, handles);
