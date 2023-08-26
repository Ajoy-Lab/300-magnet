function PostProcessing
 
   %  Create and then hide the GUI as it is being constructed.
    f = figure;
    t = uitable(f, 'CellEditCallback', @selection_CellEditCallback,'CellSelectionCallback', @rowselection_CellEditCallback );

    f.Visible = 'off';
   %  Construct the components.
  
   hedit1 = uicontrol(f, 'Style','edit','String','Enter Array','Position',[350 340 120 25]);
  
   hedit2 = uicontrol(f, 'Style','edit','String','Enter Label','Position',[350 280 120 25]);
   
   hedit3 = uicontrol(f, 'Style','edit','String','No. of files','Position',[350 100 120 25]);
   
   hedit4 = uicontrol(f, 'Style','edit','String','No. of averages','Position',[350 40 120 25]);

   hrefresh = uicontrol('Style','pushbutton','String','Populate',...
          'Position',[400,220,70,25],...
          'Callback',@refreshbutton_Callback);
      
   hplot = uicontrol('Style','pushbutton','String','Plot',...
          'Position',[400,180,70,25],...
          'Callback',@plotbutton_Callback);
  
   align([hedit1, hedit2,hedit3,hedit4, hrefresh,hplot],'Center','None');
   
   % Initialize the GUI.
   % Change units to normalized so components resize automatically.
   f.Units = 'normalized';
   hplot.Units = 'normalized';
 
   % Assign the GUI a name to appear in the window title.
   f.Name = 'Post-Processing';
   % Move the GUI to the center of the screen.
   movegui(f,'center')
   % Make the GUI visible.
   f.Visible = 'on';
 
   %  Callbacks for simple_gui. These callbacks automatically
   %  have access to component handles and initialized data 
   %  because they are nested at a lower level
  
   % Push button callbacks. Each callback plots current_data in
   % the specified plot type.
  
   function refreshbutton_Callback(source,eventdata) 
   
        % Populate a uitable with files of directory
        sorted_files= agilent_read_dir3_postprocess();
         
        set(t, 'ColumnFormat', { 'logical', [], [], [] } );
        numFiles = length(sorted_files);

        selection = num2cell(false(numFiles,1));
        d = [selection, sorted_files];
        t.Data = d;
        t.Position = [20 20 300 400];
        t.ColumnName = {'Selection','Directory'};
        t.ColumnEditable = [true false false];
        set(t, 'ColumnWidth', {75, 125})

   end
 
   function plotbutton_Callback(hObject, eventdata, handles) 
   % Display plot of the currently selected data.
      
      data = get(t,'Data');
      indicies = cell2mat(data(:,1))
      file_names = data(:,2);
      I = find(indicies == 1);
     
      if isempty(str2num(get(hedit3,'String')))
      selected_files = file_names(I);
      else
          I2=[min(I):1:min(I)+str2num(get(hedit3,'String'))-1];
           selected_files = file_names(I2);
      end
      
      if isempty(str2num(get(hedit4,'String')))
      num_avg=15;
      else
      num_avg=str2num(get(hedit4,'String'));
      end
      
      [enhancementFactor] = process_data(selected_files,num_avg);
           
        start_fig(4,[1.5 1.5]);

        inputArray= str2num(get(hedit1,'String'));
        set(hedit1,'String',num2str(inputArray));
        xSelected = fliplr(inputArray);
        
        inputLabel = get(hedit2,'String');
        set(hedit2,'String',num2str(inputLabel));
        
     [sorted_Array, IX]=sort(xSelected);
     sorted_y = enhancementFactor(IX);
     
     plot_preliminaries(sorted_Array,sorted_y,1);
     plot(sorted_Array,sorted_y);
     
     plot_labels(inputLabel,'Enhancement');
     box on;
     grid off;
     
   end 
function selection_CellEditCallback(hObject, eventdata, handles)
data=get(hObject,'Data'); % get the data cell array of the table
cols=get(hObject,'ColumnFormat'); % get the column formats
 
 
if strcmp(cols(eventdata.Indices(2)),'logical') % if the column of the edited cell is logical
    if eventdata.EditData % if the checkbox was set to true
        data{eventdata.Indices(1),eventdata.Indices(2)}=true % set the data value to true
    else % if the checkbox was set to false
        data{eventdata.Indices(1),eventdata.Indices(2)}=false % set the data value to false
    end
end
set(hObject,'Data',data) % now set the table's data to the updated data cell array
 
end
 
 
function rowselection_CellEditCallback(hObject, eventdata, handles)
    
    data=get(hObject,'Data') % get the data cell array of the table
    cols=get(hObject,'ColumnFormat') % get the column formats
    
    if isempty(eventdata.Indices)
        output = [];
    return
    else
        data{eventdata.Indices(1), 1}=true;
 
        set(hObject,'Data',data) % now set the table's data to the updated data cell array
 
    end
 
end
 
end 


