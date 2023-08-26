function PostProcessingv2
 
   %  Create and then hide the GUI as it is being constructed.
    f = figure;
    
    tgroup = uitabgroup(f,'Position', [0.05 .05 0.5 0.95], 'SelectionChangedFcn', @tabChangedCB);
    tab1 = uitab(tgroup,'Title','Plot Group 1');
    tab2 = uitab(tgroup,'Title','Plot Group 2');
    tab3 = uitab(tgroup,'Title','Plot Group 3');
    tab4 = uitab(tgroup,'Title','Plot Group 4');
    
    t1 = uitable(tab1,'CellEditCallback', @selection_CellEditCallback,'CellSelectionCallback', @rowselection_CellEditCallback , 'Position',[20 20 100 100]);
    t2 = uitable(tab2,'CellEditCallback', @selection_CellEditCallback,'CellSelectionCallback', @rowselection_CellEditCallback , 'Position',[20 20 100 100]);
    t3 = uitable(tab3,'CellEditCallback', @selection_CellEditCallback,'CellSelectionCallback', @rowselection_CellEditCallback , 'Position',[20 20 100 100]);
    t4 = uitable(tab4,'CellEditCallback', @selection_CellEditCallback,'CellSelectionCallback', @rowselection_CellEditCallback , 'Position',[20 20 100 100]);

    
    f.Visible = 'off';
   %  Construct the components.
   
   
 
  
   hedit1 = uicontrol(tab1, 'Style','edit','String','','Position',[350 340 120 25], 'Visible', 'off');
   
   hedit2 = uicontrol(tab2, 'Style','edit','String','','Position',[350 340 120 25], 'Visible', 'off');
   
   hedit3 = uicontrol(tab3, 'Style','edit','String','','Position',[350 340 120 25], 'Visible', 'off');
      
   hedit4 = uicontrol(tab4, 'Style','edit','String','','Position',[350 340 120 25], 'Visible', 'off');

   %-------
   
   heditArray = uicontrol(f, 'Style','edit','String','','Position',[350 340 120 25]);
 
 
   heditlabel = uicontrol(f, 'Style','edit','String','Enter Dependent Variable','Position',[350 280 120 25]);
   
  
   
%    button2 = uicontrol('Style','PushButton','String','Set Array',...
%     'Position',[470 280 70 25], 'Callback', @edit2_Callback);
   
   hrefresh = uicontrol('Style','pushbutton','String','Populate',...
          'Position',[400,220,70,25],...
          'Callback',@refreshbutton_Callback);
      
   hplot = uicontrol('Style','pushbutton','String','Plot',...
          'Position',[400,180,70,25],...
          'Callback',@plotbutton_Callback);
      
   hreport = uicontrol('Style','pushbutton','String','Report',...
      'Position',[400,140,70,25],...
      'Callback',@reportbutton_Callback);
  
 
   align([heditArray, heditlabel, hrefresh,hplot, hreport],'Center','None');
   
   % Initialize the GUI.
   % Change units to normalized so components resize automatically.
   f.Units = 'normalized';
   hplot.Units = 'normalized';
   hreport.Units = 'normalized';
   hrefresh.Units = 'normalized';
   heditArray.Units = 'normalized';
   %button2.Units = 'normalized';
   heditlabel.Units = 'normalized';
 
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
   function tabChangedCB(hObject, eventdata, handles)
 
    % Get the Title of the previous tab
    %tabName = eventdata.OldValue.Title;
 
    %get(eventdata.NewValue)
    get(tgroup)
    tgroup.SelectedTab
    get(tgroup.SelectedTab)
    
    setArray = get(heditArray,'String')
    set(eventdata.OldValue.Children(1), 'String', setArray)
    
    %tabName = get(eventdata.OldValue.Children(1), 'String')
    numberArray = tgroup.SelectedTab.Children(1).String
    %get(tgroup)
    %get(t)
    
    
    %t = tgroup.SelectedTab.Children
    %data=get(t,'Data')
    
% cols=get(hObject,'ColumnFormat'); % get the column formats
% 
% 
% if strcmp(cols(eventdata.Indices(2)),'logical') % if the column of the edited cell is logical
%     if eventdata.EditData % if the checkbox was set to true
%         data{eventdata.Indices(1),eventdata.Indices(2)}=true % set the data value to true
%     else % if the checkbox was set to false
%         data{eventdata.Indices(1),eventdata.Indices(2)}=false % set the data value to false
%     end
% end
% set(hObject,'Data',data) % now set the table's data to the updated data cell array
    
    
    
    
%             stringArray = str2num(get(hedit1,'String'));
 
        set(heditArray,'String',numberArray);
%         xSelected = fliplr(inputArray);
%         
%         inputLabel = get(heditlabel,'String');
%         set(heditlabel,'String',num2str(inputLabel));
    
 
 
 
 
 
 
 
 
 
 
    end
  
   function refreshbutton_Callback(source,eventdata) 
   
         t = tgroup.SelectedTab.Children(2)
        % Populate a uitable with files of directory
        sorted_files= agilent_read_dir3();
         
        set(t, 'ColumnFormat', { 'logical', [], [], [] } );
        numFiles = length(sorted_files);

        selection = num2cell(false(numFiles,1));
        d = [selection, sorted_files];
        t.Data = d;
        t.Position = [20 20 300 500];
        t.ColumnName = {'Selection','Directory'};
        t.ColumnEditable = [true false false];
        set(t, 'ColumnWidth', {75, 125})

   end
 
   function plotbutton_Callback(hObject, eventdata, handles) 
   % Display plot of the currently selected data.
        t = tgroup.SelectedTab.Children(2)
      data = get(t,'Data');
      indicies = cell2mat(data(:,1))
      file_names = data(:,2);
      I = find(indicies == 1);
     
      selected_files = file_names(I);
     
      [freq,norm_data,xvec,fitted_contrast,peak,area] = process_data(selected_files);
      
      start_fig2(3,[3 2]);
      hold on;

      for j = 1:size(selected_files,1)
        
        p1=plot_preliminaries(freq{j},abs(norm_data{j}),j,'nomarker');
                
        plotsize=length(freq{j});
        p1=plot_preliminaries(freq{j}(1:floor(plotsize/80):end),abs(norm_data{j}(1:floor(plotsize/80):end)),j,'noline');
                
        set(p1,'markersize',6);
        %p(j)=plot_preliminaries(xvec{j},fitted_contrast{j},j,'nomarker');
        %set(p(j),'linewidth',2);
      end
      
     plot_labels('Frequency [kHz]','Signal [au]');
     set(gca,'xlim',[1000 4200]);
     box on;
     grid off;
     
     randNum = floor(10*rand(1,1)) +1 ;
     
        %start_fig2(4,[1.5 1.5]);
        figure(4);
        hold on;

 inputArray= str2num(get(heditArray,'String'));
        set(heditArray,'String',num2str(inputArray));
        xSelected = fliplr(inputArray);
        
        inputLabel = get(heditlabel,'String');
        set(heditlabel,'String',num2str(inputLabel));
        

    
     [sorted_Array, IX]=sort(xSelected);
     %sorted_y = peak(IX);
     sorted_y = area(IX);
     
     plot_preliminaries(sorted_Array,sorted_y,randNum);
     %plot(sorted_Array,sorted_y);
     
     
     %plot_labels2(figure(4),inputLabel,'Signal [au]');
     ylabel('Signal [au]');
     xlabel(inputLabel);
     box on;
     grid off;
     
     
    figure(5);
     %start_fig2(5,[1.5 1.5]);
     hold on;
     sorted_y = peak(IX);
     
     plot_preliminaries(sorted_Array,sorted_y,randNum);
     %plot(sorted_Array,sorted_y);
     
     ylabel('Signal [au]');
     xlabel(inputLabel);
     %plot_labels2(figure(5),inputLabel,'Signal [au]');
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
%set(hObject,'Data',data) % now set the table's data to the updated data cell array
 
% hObject = tgroup.SelectedTab.Children(2)
%     t = findjobj(hObject); 
%  jScrollPane = t.getComponent(0);
%  javaObjectEDT(jScrollPane); 
%  currentViewPos = jScrollPane.getViewPosition; % save current position
%  
%  set(hObject,'Data',data); % now set the table's data to the updated data cell array 
%  
%  drawnow; 
%  jScrollPane.setViewPosition(currentViewPos);% reset the scroll bar to original position
 
end
 
 
function rowselection_CellEditCallback(hObject, eventdata, handles)
    
    pause(2);
    data=get(hObject,'Data') % get the data cell array of the table
    cols=get(hObject,'ColumnFormat') % get the column formats
    
        %hObject = tgroup.SelectedTab.Children(2)
    t = findjobj(hObject); 
     jScrollPane = t.getComponent(0);
     javaObjectEDT(jScrollPane); 
     currentViewPos = jScrollPane.getViewPosition; % save current position
%     drawnow; 
%     jScrollPane.setViewPosition(currentViewPos);% reset the scroll bar to original position
%     
    
    if isempty(eventdata.Indices)
        output = [];
    return
    else
        data{eventdata.Indices(1), 1}=true;
 
        set(hObject,'Data',data) % now set the table's data to the updated data cell array
        drawnow; 
    jScrollPane.setViewPosition(currentViewPos);% reset the scroll bar to original position
 
    end
 
end
 
end 



function [freq,norm_data,xvec,fitted_contrast,peak,area]= process_data(files_return,handles)

for j=1:size(files_return,1)
    MatrixOut{j}=process_varian3(files_return{j},'complete');
    norm_data{j}= abs(MatrixOut{j});
    freq{j}=linspace(0,6.25e3,size(norm_data{j},2));
    [f{j},xvec{j},fitted_contrast{j}] = fit_gaussian(freq{j},abs(norm_data{j}/max(abs(norm_data{j}))));
    fitted_contrast{j}=fitted_contrast{j}*max(abs(norm_data{j}));
    [peak(j),b]=  max(abs(smooth(norm_data{j},500)));
    %peak(j)=(f{j}.m(1) - f{j}.m(4))*max(abs(norm_data{j}));
    
    IX=find(freq{j}>2e3& freq{j}<3e3);
    area(j)= trapz(freq{j}(IX),norm_data{j}(IX),2);
end

end


function [f,xvec,fitted_contrast]= fit_gaussian(x,y,varargin)
lb=[0,1e3,0.5e3,0];
ub=[1,4e3, 3e3,1];

[v b1]=max(abs(y));
x1=x;y1=y;
a_ini=max(y1);
b_ini=2.5e3;
c_ini=0.75e3;
d_ini=0;
P_ini=[a_ini;b_ini;c_ini;d_ini]; %NOTE that they have to be ordered alphabetically!

f = ezfit(x1, y1, 'y =a*exp(-(x-b).^2/(2*c^2)) + d',P_ini,lb,ub);

xvec=linspace(x1(1),x1(end),1000);
fitted_contrast=f.m(1).*exp(-(xvec-f.m(2)).^2./(2*f.m(3)^2)) + f.m(4);

fun = @(x) f.m(1)*exp(-(x-f.m(2)).^2/(2*f.m(3)^2)) + f.m(4);
area = integral(fun, min(xvec),max(xvec));

% start_fig2(11,[4 2]);
% plot_preliminaries(x1,y1,2,'nomarker');
% plot(x1,y1);
end