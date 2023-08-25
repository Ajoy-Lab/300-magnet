function table_bool_CellEditCallback(hObject, ~, handles)

handles.Data_bool = get(hObject,'data');

% Update handles structure
guidata(hObject, handles);