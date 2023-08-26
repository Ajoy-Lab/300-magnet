function PostProcessing
 
   %  Create and then hide the GUI as it is being constructed.
    f = figure;
    t = uitable(f, 'CellEditCallback', @selection_CellEditCallback,'CellSelectionCallback', @rowselection_CellEditCallback );

    f.Visible = 'off';
   %  Construct the components.
  
   hedit1 = uicontrol(f, 'Style','edit','String','Enter Array','Position',[350 340 120 25]);
  
   hedit2 = uicontrol(f, 'Style','edit','String','Enter Label','Position',[350 280 120 25]);
   
   hedit3 = uicontrol(f, 'Style','edit','String','No. of files','Position',[350 100 120 25]);

   hrefresh = uicontrol('Style','pushbutton','String','Populate',...
          'Position',[400,220,70,25],...
          'Callback',@refreshbutton_Callback);
      
   hplot = uicontrol('Style','pushbutton','String','Plot',...
          'Position',[400,180,70,25],...
          'Callback',@plotbutton_Callback);
  
   align([hedit1, hedit2,hedit3, hrefresh,hplot],'Center','None');
   
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
 
%    function plotbutton_Callback(hObject, eventdata, handles) 
%    % Display plot of the currently selected data.
%       
%       data = get(t,'Data');
%       indicies = cell2mat(data(:,1))
%       file_names = data(:,2);
%       I = find(indicies == 1);
%      
%       if isempty(str2num(get(hedit3,'String')))
%       selected_files = file_names(I);
%       else
%           I2=[min(I):1:min(I)+str2num(get(hedit3,'String'))-1];
%            selected_files = file_names(I2);
%       end
%       
%       [freq,norm_data,peak,area,snr] = process_data(selected_files);
%       
%       start_fig(3,[3 2]);
%       hold on
% 
%       for j = 1:size(selected_files,1)
%         
%         p1=plot_preliminaries(freq{j},abs(norm_data{j}),j,'nomarker');
%                 
%         plotsize=length(freq{j});
%         p1=plot_preliminaries(freq{j}(1:floor(plotsize/80):end),abs(norm_data{j}(1:floor(plotsize/80):end)),j,'noline');
%                 
%         set(p1,'markersize',6);
%         %p(j)=plot_preliminaries(xvec{j},fitted_contrast{j},j,'nomarker');
%         %set(p(j),'linewidth',2);
%       end
%       
%      plot_labels('Frequency [kHz]','Signal [au]');
%      set(gca,'xlim',[2500 5500]);
%      box on;
%      grid off;
%      
%         start_fig(4,[1.5 1.5]);
% 
%         inputArray= str2num(get(hedit1,'String'));
%         set(hedit1,'String',num2str(inputArray));
%         xSelected = fliplr(inputArray);
%        %xSelected = (inputArray);
%         
%         inputLabel = get(hedit2,'String');
%         set(hedit2,'String',num2str(inputLabel));
%         
%     %Power=fliplr([-170 -130 -90 -50 -10 -210 -250 -290 -110 -150 -30 -70 110 10 30 50 70 90 130 150 170 210 250 290]);
%     %Power=fliplr(-1* [110 10 30 50 70 90 130 150 170 210 250 290]);
%     %Power = fliplr([10 20 30 50 75 100 150 200 300 500 1000]);
%     
%      [sorted_Array, IX]=sort(xSelected);
%      %sorted_y = peak(IX);
%      sorted_y = area(IX);
%      %sorted_y = snr(IX);
%      
%      plot_preliminaries(sorted_Array,sorted_y,1);
%      plot(sorted_Array,sorted_y);
%      
%      plot_labels(inputLabel,'Signal Area [au] ');
%      box on;
%      grid off;
%      
%      
% 
%      start_fig(5,[1.5 1.5]);     
%      sorted_y = peak(IX);
%      
%      plot_preliminaries(sorted_Array,sorted_y,1);
%      plot(sorted_Array,sorted_y);
%      
%      plot_labels(inputLabel,'Signal [au]');
%      box on;
%      grid off;
%      
%    end
   function plotbutton_Callback(hObject, eventdata, handles) 
   % Display plot of the currently selected data.
      
      data = get(t,'Data');
      indicies = cell2mat(data(:,1));
      file_names = data(:,2);
      I = find(indicies == 1);
     
      if isempty(str2num(get(hedit3,'String')))
      selected_files = file_names(I);
      else
          I2=[min(I):1:min(I)+str2num(get(hedit3,'String'))-1];
           selected_files = file_names(I2);
      end
      
      [enhancementFactor] = process_data(selected_files);
      
%       start_fig(3,[3 2]);
%       hold on
% 
%       for j = 1:size(selected_files,1)
%         
%         p1=plot_preliminaries(freq{j},abs(norm_data{j}),j,'nomarker');
%                 
%         plotsize=length(freq{j});
%         p1=plot_preliminaries(freq{j}(1:floor(plotsize/80):end),abs(norm_data{j}(1:floor(plotsize/80):end)),j,'noline');
%                 
%         set(p1,'markersize',6);
%         %p(j)=plot_preliminaries(xvec{j},fitted_contrast{j},j,'nomarker');
%         %set(p(j),'linewidth',2);
%       end
%       
%      plot_labels('Frequency [kHz]','Signal [au]');
%      set(gca,'xlim',[2500 5500]);
%      box on;
%      grid off;    
     
        start_fig(4,[1.5 1.5]);

        inputArray= str2num(get(hedit1,'String'));
        filenum= str2num(get(hedit3,'String'));
        set(hedit1,'String',num2str(inputArray));
        xSelected = fliplr(inputArray(1:filenum));
       %xSelected = (inputArray);
        
        inputLabel = get(hedit2,'String');
        set(hedit2,'String',num2str(inputLabel));
        
    %Power=fliplr([-170 -130 -90 -50 -10 -210 -250 -290 -110 -150 -30 -70 110 10 30 50 70 90 130 150 170 210 250 290]);
    %Power=fliplr(-1* [110 10 30 50 70 90 130 150 170 210 250 290]);
    %Power = fliplr([10 20 30 50 75 100 150 200 300 500 1000]);
    
     [sorted_Array, IX]=sort(xSelected);
     %sorted_y = peak(IX);
     sorted_y = enhancementFactor(IX);
     %sorted_y = snr(IX);
     
     plot_preliminaries(sorted_Array,abs(sorted_y),1);
     plot(sorted_Array,abs(sorted_y));
%      fm=fopen(['D:\QEG2\T1measure\' char(selected_files(1)) '.txt'],'wt');
%      fprintf(fm,'%f ',sorted_Array);
%      fprintf(fm,'\n');
%      fprintf(fm,'%f ',sorted_y);
%      fclose(fm);
     fm=fopen(['D:\New folder\xdlv\datafrom_pps14' char(selected_files(1)) '.txt'],'wt');
    for i=1:length(sorted_Array)
       fprintf(fm,'%f %f \n',sorted_Array(i),sorted_y(i));
    end
    fclose(fm);
     
%      resultpoint=[sorted_Array;sorted_y]';
%      fm2=fopen(['D:\QEG2\T1measure\' char(selected_files(1)) '-2.dat'],'w');
%      fprintf(fm2,'%f ',resultpoint);
%      fclose(fm2);
     
     plot_labels(inputLabel,'Enhancement');
     box on;
     grid off;
     
     

%      start_fig(5,[1.5 1.5]);     
%      sorted_y = peak(IX);
%      
%      plot_preliminaries(sorted_Array,sorted_y,1);
%      plot(sorted_Array,sorted_y);
%      
%      plot_labels(inputLabel,'Signal [au]');
%      box on;
%      grid off;
     
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
set(hObject,'Data',data); % now set the table's data to the updated data cell array
 
end
 
 
function rowselection_CellEditCallback(hObject, eventdata, handles)
    
    data=get(hObject,'Data'); % get the data cell array of the table
    cols=get(hObject,'ColumnFormat'); % get the column formats
    
    if isempty(eventdata.Indices)
        output = [];
    return
    else
        data{eventdata.Indices(1), 1}=true;
 
        set(hObject,'Data',data); % now set the table's data to the updated data cell array
 
    end
 
end
 
end 



function [enhancementFactor]= process_data(files_return,handles)
 path='Z:\FID_spectra\';
% path = 'C:\Users\Arthur Lin\Documents\Pines Lab\MATLAB\FID_spectra\Sweep
% Time\';
%path = 'C:\Users\Arthur Lin\Documents\Pines Lab\MATLAB\FID_spectra\2 VCO Sweep Symm\';
% thermal= make_fn_thermal('2017-06-22_18.21.19_carbon_ext_trig_shuttle',path);
% thermal= make_fn_thermal('2017-06-14_22.44.19_carbon_ext_trig_shuttle',path);

% thermal= make_fn_thermal('2017-07-09_18.38.48_carbon_ext_trig_shuttle',path);

%e6 sample 2
% thermal= make_fn_thermal('2017-07-12_20.59.46_carbon_ext_trig_shuttle',path);
% thermal= make_fn_thermal('2017-07-13_18.56.56_carbon_ext_trig_shuttle',path);
% thermal= make_fn_thermal('2017-07-22_22.48.45_carbon_ext_trig_shuttle',path);

%2shot comparison
% thermal= make_fn_thermal('2017-07-23_14.58.23_carbon_ext_trig_shuttle',path);
% thermal= make_fn_thermal('2017-07-23_20.14.02_carbon_ext_trig_shuttle',path);
%1shot comparison

% spec2 = process_spectrum(thermal, 0, true); %spec2 is thermal
for j=1:size(files_return,1)
    if j == 1
        ph0_val_in = nan;
    end
    dnp_2=make_fn(files_return{j},path,'complete');
%     spec3 = process_spectrum(dnp_2, 0, true);
%     num_avg = numel(dir([path, files_return{j}]))-2;
    [summed_efactor(j), enhancementFactor_1(j), enhancementFactor_2(j),...
    therm_spec_scaled, dnp_spec_scaled{j}, ...
    width, ...
    signal_bs, signal_raw, signal_phase0, signal_phase1,...
    area_summed_dnp,area_summed_dnp_1,area_summed_dnp_2,area_trapz_dnp,area_trapz_dnp2,muller_area(j), area_fwhm_dnp,area_fixed_fwhm_dnp, ph0_val_out(j)] = process_enhancement_expedite(dnp_2, ph0_val_in);
    ph0_val_in = mean(ph0_val_out);
%     [MatrixOut{j},snr(j)]=process_varian_muller(files_return{j},'complete');
%     norm_data{j}= abs(MatrixOut{j});
%     freq{j}=linspace(0,6.25e3,size(norm_data{j},1));
%     %[f{j},xvec{j},fitted_contrast{j}] = fit_gaussian(freq{j},abs(norm_data{j}/max(abs(norm_data{j}))));
%    % fitted_contrast{j}=fitted_contrast{j}*max(abs(norm_data{j}));
%     [peak(j),b]=  max(norm_data{j})
%     %peak(j)=(f{j}.m(1) - f{j}.m(4))*max(abs(norm_data{j}));
%     
%     lw_min= freq{j}(b)-0.75e3;lw_max= freq{j}(b)+0.75e3;
%     IX=find(freq{j}>lw_min& freq{j}<lw_max);
%     area(j)= trapz(freq{j}(IX),norm_data{j}(IX)',2);
    
%     int{j} = integrate(norm_data{j});
%     area(j) = int{j}(end);

%  enhancementFactor(j)=max( dnp_spec_scaled{j});    
    
end
muller_area = muller_area.*sign(summed_efactor);
ratios = summed_efactor./muller_area;
% ratios2 = fixed_fwhm_area_efactor./muller_area;
enhancementFactor = mean(ratios)*muller_area; 


end


function [f,xvec,fitted_contrast]= fit_gaussian(x,y,varargin)
lb=[0,3e3,0.5e3,0];
ub=[1,5e3, 3e3,1];

[v b1]=max(abs(y));
x1=x;y1=y;
a_ini=max(y1);
b_ini=3745;
c_ini=0.75e3;
d_ini=0;
P_ini=[a_ini;b_ini;c_ini;d_ini]; %NOTE that they have to be ordered alphabetically!

f = ezfit(x1, y1, 'y =a*exp(-(x-b).^2/(2*c^2)) + d',P_ini,lb,ub);

xvec=x1;%linspace(x1(1),x1(end),1000);
fitted_contrast=f.m(1).*exp(-(xvec-f.m(2)).^2./(2*f.m(3)^2)) + f.m(4);

fun = @(x) f.m(1)*exp(-(x-f.m(2)).^2/(2*f.m(3)^2)) + f.m(4);
area = integral(fun, min(xvec),max(xvec));

start_fig(11,[4 2]);
plot_preliminaries(x1,y1,2,'nomarker');
plot_preliminaries(xvec,fitted_contrast,2,'nomarker');
end
function new_fn= make_fn(fn,path,exp_number)
new_fn=[path fn '\' num2str(exp_number) '.fid\fid'];
end

function new_fn= make_fn_thermal(fn,path)
new_fn=[path fn '\complete.fid\fid']
end