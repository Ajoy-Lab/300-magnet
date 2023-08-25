function [handles] = table_float_CellEditCallback(hObject, ~, handles)

%tabledata = get(hObject, 'data');
tabledata = get(handles.table_float, 'Data');
handles.Data_float = tabledata;
a = size(tabledata);

vary_on = 0;
handles.Var_to_be_varied = [];
handles.Name_var_to_be_varied = {};
for p=1:1:a(1)  %number of lines in matrix
    if tabledata{p,3} == true
        handles.Var_to_be_varied = [handles.Var_to_be_varied p];
        handles.Name_var_to_be_varied = [handles.Name_var_to_be_varied tabledata{p,1}];
        vary_on = 1;
    end
end

if length(handles.Var_to_be_varied) > 2
    uiwait(warndlg('You cannot scan more than two variables. Aborted.'));
    set(handles.button_SetScan,'Enable', 'off');
    return;
end

scan_ok = 1;
for k=1:1:length(handles.Var_to_be_varied)
if ~(vary_on && ~isempty(handles.Data_float{handles.Var_to_be_varied(k),4}) && ~isempty(handles.Data_float{handles.Var_to_be_varied(k),5}) && ~isempty(handles.Data_float{handles.Var_to_be_varied(k),6}))
    scan_ok = 0;
    break;
end
end

if scan_ok
    set(handles.button_SetScan,'Enable', 'on');
else
    set(handles.button_SetScan,'Enable', 'off');
end

%set(hObject,'Data',handles.Data_float);
set(handles.table_float,'Data',handles.Data_float);

% Update handles structure
guidata(hObject, handles);
