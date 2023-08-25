function [handles] = button_SetScan_Callback(hObject, ~, handles)

%Initialize ExperimentalScan params
handles.ExperimentalScan = ExperimentalScan();
%clear handles.Array_PSeq;
handles.Array_PSeq = {};

set(handles.average_continuously,'Enable','on');

scan_var_nb = handles.Var_to_be_varied;

%Set name of sequence
handles.ExperimentalScan.SequenceName = handles.Sequencename;
handles.ExperimentalScan.vary_prop =  handles.Name_var_to_be_varied;

%Save sequence file in ExperimentalScan
fid = fopen(handles.Sequencename);
tline = fgets(fid);
while ischar(tline)
    handles.ExperimentalScan.Sequence = [handles.ExperimentalScan.Sequence tline];
    tline = fgets(fid);
end

%Set first scan dimension params
handles.scan_nonlinear=get(handles.checkbox18,'Value');
if handles.scan_nonlinear==0
for k=1:1:length(scan_var_nb)
handles.ExperimentalScan.vary_begin(k) = ParseInput(handles.Data_float{scan_var_nb(k), 4});
handles.ExperimentalScan.vary_step_size(k) = ParseInput(handles.Data_float{scan_var_nb(k), 5});
handles.ExperimentalScan.vary_end(k) = ParseInput(handles.Data_float{scan_var_nb(k), 6});
handles.nonlinear_data=[];
set(handles.text254,'String',['']);
end
elseif handles.scan_nonlinear==1 && length(scan_var_nb)==1
    handles.ExperimentalScan.vary_begin =handles.nonlinear_data.x(1);
    handles.ExperimentalScan.vary_end =handles.nonlinear_data.x(end);
    handles.ExperimentalScan.vary_step_size = ParseInput(handles.Data_float{scan_var_nb, 5});
end
    

if length(scan_var_nb) == 1
set(handles.average_continuously,'Enable','on');
else
set(handles.average_continuously,'Enable','off');
end

% initialize scan
clear scan;
for k=1:1:length(scan_var_nb)
    if handles.scan_nonlinear==0
    %%%%%%%Added by Masashi March,21,2011%%%
    if handles.ExperimentalScan.vary_begin(k)==handles.ExperimentalScan.vary_end(k);
        scan{k} = handles.ExperimentalScan.vary_begin(k)*ones(1,handles.ExperimentalScan.vary_step_size(k));
    else
        scan{k} = handles.ExperimentalScan.vary_begin(k):handles.ExperimentalScan.vary_step_size(k):handles.ExperimentalScan.vary_end(k);
    end
    else
         scan{k} = handles.nonlinear_data.x;
         set(handles.text254,'String',[num2str(handles.nonlinear_data.x,'%10.4e\t')]);
    end     
    %%%%%%%%%%%%%%%%%%%%%%%%%
    handles.ExperimentalScan.vary_points(k) = length(scan{k});
    if abs(scan{k}(end) - handles.ExperimentalScan.vary_end(k)) > 1e-12
        warndlg(sprintf('Note that end point in scan will be %d and not %d because of scan step size.', scan{k}(end),handles.ExperimentalScan.vary_end(k)))
    end
end



% randomizing is only for the first scan dimension
handles.rand_indices_1dscan = [];
if get(handles.checkbox_randomscan,'Value')
    
   handles.rand_indices_1dscan = randperm(length(scan{1}));
   scan{1} = scan{1}(handles.rand_indices_1dscan);
end

err_in_sequence_building = false;

if length(scan_var_nb) == 2
    aux2_end = length(scan{2});
else
    aux2_end = 1;
end

% toggle through all scanning points and make an array of sequences
handles.Array_PSeq = cell(aux2_end,length(scan{1}));

for aux2=1:1:aux2_end %var to the slider is variable from scan{2}
    
    if length(scan_var_nb) == 2
    handles.Data_float{scan_var_nb(2), 2} = scan{2}(aux2);
    end
    
for aux=1:1:length(scan{1}) % var that can be shuffled over
    
    % change the current value
    handles.Data_float{scan_var_nb(1), 2} = scan{1}(aux);
    
    [Current_PSeq,Variable_values,Bool_values,coerced_hlp] = make_pulse_sequence(handles);

	if coerced_hlp.value == true
        uiwait(warndlg({['Variable ' coerced_hlp.name ' out of range. Set Scan aborted.']}));        
        err_in_sequence_building = true;
        break;
    end
    
    if Current_PSeq.seq_error ~= 0
        uiwait(warndlg({sprintf('Error to build sequence at scan point %d. Error number %d. Set Scan aborted.', Current_PSeq.seq_error, aux)}));
        err_in_sequence_building = true;
        break;
    end
     
    handles.Array_PSeq{aux2,aux} = Current_PSeq;
    
end

end

handles.ExperimentalScan.Variable_values = Variable_values;
handles.ExperimentalScan.Bool_values = Bool_values;

if ~err_in_sequence_building
	set(handles.button_StartExp,'Enable','on');
else
    set(handles.button_StartExp,'Enable','off');
end

if get(handles.checkbox_randomscan,'Value')
    textrandom = 'random ';
else
    textrandom = ' ';
end

if get(handles.checkbox_tracking,'Value')
   
   handles.Imaginghandles.ImagingFunctions.SaveTrack(handles.Imaginghandles);
   set(handles.Imaginghandles.TrackingSave,'Enable','off');
   set(handles.Imaginghandles.TrackingStart,'Enable','off');
    
   if get(handles.button_track_per_avg,'Value')
      texttrack = 'track per avg '; 
   else
      texttrack = 'track per scan pt '; 
   end
else
    texttrack = '';
end

if get(handles.checkbox_power,'Value')
    if get(handles.button_power_per_avg,'Value')
      textpower = 'power per avg'; 
   else
      textpower = 'power per scan pt'; 
   end
else
    textpower = '';
end

set(handles.button_SetScan,'String',['Set Scan ' textrandom texttrack textpower]);

guidata(hObject,handles);