%############################################################################
%#
%#                           function PEAKTOOL
%#
%#      a GUI to fit an arbitrary number of peaks (Gauss/Lorentz) to an input
%#      spectrum (real/1D). DETAILS IN SEPARATE INSTRUCTION FILE (peaktool.pdf)
%#
%#      usage: peaktool(data)
%#
%#
%#      (c) P. Blümler 1/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.2 PB 14/1/06 taken resizeable out   (please change this when code is altered)
%----------------------------------------------------------------------------

function peaktool(indata)
global data achs gui_handle n_points peakh
%     DEFINITION OF GLOBAL VARIABLES:
%
%     data = original data (only altered initially, see 'start'
%     achs = definition as in plottool (see init_plot)
%     guihandle = the handle on the uicontrols (see MAKEgui)
%     n_points = length(data)
%
%     STRUCTURE OF PEAK PROPERTIES
%     peakh.iv: [np x3 double]   the actual peak parameters (position, amplitude, width)
%   peakh.vary: [np x3 double]   the status for varying parameters during fit (=1 do so)
%   peakh.area: [np x1 double]   the peak area in %
% peakh.select: scalar           the number (in list) of the actual peak
%     peakh.pp: [np x1 double]   the initial position by peak picking
%    peakh.ppv: [2 x1 double]    the parameters for the peakpicker (width, threshold)
%     peakh.np: np               the number of peaks
%   peakh.ptyp: [np x1 double]   the type of peak (1= Gauss, 0=Lorentz)
%   peakh.chi2: scalar           chi^2
%   peakh.fitp: [3 x1 double]    the settings for the fit (parameter tolerance, residual tol., maximum number of iterations)



%Initial check or callback
if (nargin == 0)   %uups, no data 
    disp('ERROR: No data specified!')
    return
elseif ~isstr(indata)  %input is no string, hence initial call with data
    data=squeeze(indata);
    action = 'start';
else
    action = indata;   %that must be a callback
end


%MAIN ACTION SWITCH (actions are the callbacks for function 'peaktool' defined in MAKEgui

switch action
case 'start'   %initiallizing  ###################################################    
    data=real(data);
    data=data/max(data)*100; %scale data max to 100
    dim=dimension(data);     %check dimension of data
    siz=size(data);
    if dim~=1                %not 1D!
       disp('WARNING: data input array is NOT ONEDIMENSIONAL!');
       disp('take first slice');
       data=squeeze(data(:,1,1,1,1))';
       dim=size(data);
    end
    if siz(1) ~= 1   %do eventually necessary transpose
        data=data';
        siz=size(data);
    end
    n_points=siz(2);  %determine number of points
    achs=zeros(12,1); %define achs 
    init_plot(' ');   %figure initial plot parameters
    peakh.iv=[];      %reset initial conditions of the peak properties
    peakh.vary=[];
    peakh.area=[];
    peakh.select=0;
    peakh.pp=[];
    peakh.ppv=[20,0.01*achs(4)]; %default peakpicker parameters
    peakh.fitp=[1e-2,1e-2,200];  %default fit parameters
    MAKEgui(' ');    %create GUI
    plot_data([]);   %plot the data

%------------------ INITIAL PEAK PICKING ---------------------------------------------------     
    
case 'pplw_value' %change damping for peakpicker ############################################# 
    peakh.ppv(1)=str2num(get(gui_handle.pp_lw,'String'));
    if peakh.ppv(1)<=0, peakh.ppv(1)=1; end
    set(gui_handle.pp_lw,'String',num2str(peakh.ppv(1)));
    peakh.pp=peakpick(real(data),peakh.ppv(1),peakh.ppv(2)); %call peakpick for positions
    plot_data([]);
    
case 'ppth_value' %change threshold for peakpicker ##########################################
    peakh.ppv(2)=str2num(get(gui_handle.pp_th,'String'));
    set(gui_handle.pp_th,'String',num2str(peakh.ppv(2)));
    peakh.pp=peakpick(real(data),peakh.ppv(1),peakh.ppv(2)); %call peakpick for positions
    plot_data([]);
    
case 'peakp'     % peak picker ###############################################################
    peakh.pp=peakpick(real(data),peakh.ppv(1),peakh.ppv(2)); %call peakpick for positions
    n_points=length(data);
    peakh.np=length(peakh.pp);       %number of peaks found
    plot_data([]);
    set(gui_handle.pp_acc,'Visible','On'); %switch accept button on

case 'pp_Accept' %accept peaks found -> PEAK field ###########################################
    get_peaks([]); %get init values
    set(gui_handle.pp_lw,'Visible','Off'); %switch Peakpicker field OFF
    set(gui_handle.pp_th,'Visible','Off');
    set(gui_handle.shlw,'Visible','Off');
    set(gui_handle.shth,'Visible','Off');
    set(gui_handle.pp_but,'Visible','Off');
    set(gui_handle.pp_txt,'Visible','Off');
    set(gui_handle.pl_txt,'Visible','Off');
    set(gui_handle.pt_txt,'Visible','Off');
    set(gui_handle.pp_acc,'Visible','Off');
    set(gui_handle.fit_txt,'Visible','On'); %switch PEAK field ON
    set(gui_handle.pp_back,'Visible','On');
    set(gui_handle.peaklist,'Visible','On');
    set(gui_handle.pos,'Visible','On');
    set(gui_handle.amp,'Visible','On');
    set(gui_handle.wid,'Visible','On');
    set(gui_handle.pos_txt,'Visible','On');
    set(gui_handle.amp_txt,'Visible','On');
    set(gui_handle.wid_txt,'Visible','On');
    set(gui_handle.p_sum,'Visible','On');
    set(gui_handle.p_ind,'Visible','On');
    set(gui_handle.p_res,'Visible','On');
    set(gui_handle.vpos,'Visible','On');
    set(gui_handle.vamp,'Visible','On');
    set(gui_handle.vwid,'Visible','On');
    set(gui_handle.vposall,'Visible','On');
    set(gui_handle.vampall,'Visible','On');
    set(gui_handle.vwidall,'Visible','On');
    set(gui_handle.vall,'Visible','On');
    set(gui_handle.gaulo,'Visible','On');
    set(gui_handle.alllo,'Visible','On');
    set(gui_handle.insp,'Visible','On');
    set(gui_handle.delp,'Visible','On');
    set(gui_handle.chi2,'Visible','On');
    set(gui_handle.chi_txt,'Visible','On');
    set(gui_handle.chi2_txt,'Visible','On');
    set(gui_handle.save,'Visible','On');
    set(gui_handle.savex,'Visible','On');
    update_peaklist([]);
    plot_data([]);

case 'pp_back' % RESTART with peak picker ##################################################
    close(gcbf);
    peaktool('start');
    
    
    
%-----------------PEAK field----------------------------------------------------------------

case 'peaklist'  %check which peak is selected #############################################
    peakh.select=get(gui_handle.peaklist,'Value');
    update_peaklist([]);
    plot_data([]);
    
case 'toggle_gl' %toggle peak type between Gauss <-> Lorentz ##############################
    if peakh.ptyp(peakh.select)==1
        peakh.ptyp(peakh.select)=0;
        set(gui_handle.gaulo,'String','Lorentz -> Gauss');
    else
        peakh.ptyp(peakh.select)=1;
        set(gui_handle.gaulo,'String','Gauss -> Lorentz');
    end
    update_peaklist([]);
    plot_data([]);
    
case 'all_lorentz' %set all peak types to Lorentz/Gauss ########################################
    if sum(peakh.ptyp)~=0    %not all are Lorentz (starting cond)
        peakh.ptyp=zeros(1,peakh.np); %set all to Lorentz
        set(gui_handle.alllo,'String','all Gauss'); %switch text
    else
        peakh.ptyp=ones(1,peakh.np); %set all to Gauss
        set(gui_handle.alllo,'String','all Lorentz'); %switch text 
    end
    update_peaklist([]);
    plot_data([]);
   
case 'change_pos' %manually change position of selected peak #############################
    peakh.iv(peakh.select,1)=str2num(get(gui_handle.pos,'String'));
    update_peaklist([]);
    plot_data([]);

case 'change_amp' %manually change amplitude of selected peak #############################
    peakh.iv(peakh.select,2)=str2num(get(gui_handle.amp,'String'));
    update_peaklist([]);
    plot_data([]);

case 'change_wid' %manually change width of selected peak #############################
    peakh.iv(peakh.select,3)=str2num(get(gui_handle.wid,'String'));
    update_peaklist([]);
    plot_data([]);
    
case 'vary_pos' %alter status of vary the position during fit ######################### 
    peakh.vary(peakh.select,1)=get(gui_handle.vpos,'Value');
    update_peaklist([]);

case 'vary_amp' %alter status of vary the amplitude during fit ######################## 
    peakh.vary(peakh.select,2)=get(gui_handle.vamp,'Value');
    update_peaklist([]);
    
case 'vary_wid' %alter status of vary the width during fit ######################### 
    peakh.vary(peakh.select,3)=get(gui_handle.vwid,'Value');
    update_peaklist([]);
    
case 'vary_pos_all' %toggle between all/non pos. parameters to vary###################
     if get(gui_handle.vposall,'Value')==1
        peakh.vary(:,1)=ones(peakh.np,1);  %set all to vary
        set(gui_handle.vposall,'String','none') %change text of checkbox
     else
        peakh.vary(:,1)=zeros(peakh.np,1); %set all to not vary
        set(gui_handle.vposall,'String','all') %change text of checkbox
     end
     update_peaklist([]);
     plot_data([]);
     
case 'vary_amp_all' %toggle between all/non amp. parameters to vary###################
     if get(gui_handle.vampall,'Value')==1
        peakh.vary(:,2)=ones(peakh.np,1);  %set all to vary
        set(gui_handle.vampall,'String','none') %change text of checkbox
     else
        peakh.vary(:,2)=zeros(peakh.np,1); %set all to not vary
        set(gui_handle.vampall,'String','all') %change text of checkbox
     end
     update_peaklist([]);
     plot_data([]);
     
case 'vary_wid_all' %toggle between all/non wid. parameters to vary###################
     if get(gui_handle.vwidall,'Value')==1
        peakh.vary(:,3)=ones(peakh.np,1);  %set all to vary
        set(gui_handle.vwidall,'String','none') %change text of checkbox
     else
        peakh.vary(:,3)=zeros(peakh.np,1); %set all to not vary
        set(gui_handle.vwidall,'String','all') %change text of checkbox
     end
     update_peaklist([]);
     plot_data([]);
     
case 'vary_all' %toggle between all/non parameters to vary###########################
     if get(gui_handle.vall,'Value')==1
        peakh.vary=ones(peakh.np,3);  %set all to vary
        set(gui_handle.vall,'String','vary none parameter') %change text of checkbox
     else
        peakh.vary=zeros(peakh.np,3); %set all to not vary
        set(gui_handle.vall,'String','vary all parameters') %change text of checkbox
     end
     update_peaklist([]);
     plot_data([]);

case 'delete_peak' %delete the selected peak #########################################
    if peakh.np>0  %check if there are peaks left
       peakh.iv(peakh.select,:)=[];   %delete all entries for the selected peak
       peakh.vary(peakh.select,:)=[];
       peakh.area(peakh.select)=[];
       peakh.pp(peakh.select)=[];
       peakh.ptyp(peakh.select)=[];
       peakh.np=peakh.np-1;
     end
     update_peaklist([]);
     plot_data([]);
      
case 'insert_peak' %insert a new peak (last in list)###################################
    set(gcf,'Pointer','crosshair');
    set(gui_handle.insp,'String','DONE!','BackgroundColor',[1,1,0],'ForegroundColor',[0,0,0],'FontSize',12,'FontWeight','bold');
    while get(gui_handle.insp,'Value')==1;
       set(gcf,'Pointer','crosshair');
       waitforbuttonpress;
       if get(gui_handle.insp,'Value')==0, break, end
       waitforbuttonpress; %stupid but only works this way
       if get(gui_handle.insp,'Value')==0, break, end
       peakh.np=peakh.np+1;
       cursor_pos=round(get(gui_handle.out_win,'CurrentPoint'));
       cursor_pos=cursor_pos(1);
       if cursor_pos<1, cursor_pos=1; end
       if cursor_pos>n_points, cursor_pos=n_points; end  
       peakh.select=peakh.np;
       peakh.iv(peakh.np,1)=cursor_pos;
       peakh.iv(peakh.np,2)=data(cursor_pos);
       wid=find(data<data(cursor_pos)/2)-cursor_pos;
       peakh.iv(peakh.np,3)=min(nonzeros(-(wid.*(wid<0))))*2;
       peakh.vary(peakh.np,:)=[0 0 0];
       peakh.pp(peakh.np)=cursor_pos;
       if sum(peakh.ptyp)==0 %all the others are Lorentz...
          peakh.ptyp(peakh.np)=0;  %...then new one is also Lorentz
       else
          peakh.ptyp(peakh.np)=1;  %if not Gauss
       end
       if get(gui_handle.vall,'Value')==1   %check overall vary status
          peakh.vary=ones(peakh.np,3);  %set all to vary
       end
       if get(gui_handle.vposall,'Value')==1   %check overall pos. vary status
          peakh.vary(:,1)=ones(peakh.np,1);  %set all to vary
       end
       if get(gui_handle.vampall,'Value')==1   %check overall amp. vary status
          peakh.vary(:,2)=ones(peakh.np,1);  %set all to vary
       end
       if get(gui_handle.vwidall,'Value')==1   %check overall amp. vary status
          peakh.vary(:,3)=ones(peakh.np,1);  %set all to vary
       end
       %sort peaks via position
       [dummy,index]=sort(peakh.iv(:,1)); %sort the position to get index
       peakh.iv=peakh.iv(index,:);
       peakh.ptyp=peakh.ptyp(index);
       peakh.pp=peakh.pp(index);
       peakh.vary=peakh.vary(index,:);
       peakh.select=find(index==peakh.np); %check where the last one moved to
       update_peaklist([]);
       plot_data([]);
    end
    set(gui_handle.insp,'String','Insert Peak','BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'FontWeight','bold');
    set(gcf,'Pointer','arrow'); 



    
%--------------------------FIT field-------------------------------------------------------- 

case 'change_ptol'  %change the parameter tolerance of the fit ############################
    peakh.fitp(1)=str2num(get(gui_handle.ptol,'String'));

case 'change_rtol'  %change the residual tolerance of the fit ############################
    peakh.fitp(2)=str2num(get(gui_handle.rtol,'String'));
    
case 'change_mitr'  %change the number of max. iterations of the fit ######################
    peakh.fitp(3)=str2num(get(gui_handle.mitr,'String'));

case 'fit_peak'     %do the fit ###########################################################
    dummy=nlinfit_p([]);
    update_peaklist([]);
    plot_data([]);

    
%-----------------SAVE & LOAD parameters----------------------------------------------------    
case 'save_param'
    [fname,pname] = uiputfile('*.*','Save peak parameters (select only name not extension)'); %open GUI to select filename/directory
    if fname~=0 %ensure something was specified
      %if user already typed in extension remove it, therefore...
      str_compare=(fname=='.'); %...check if filename containes '.' (to eliminate extensions)
      if sum(str_compare)==1  %if so find location of '.'
          index=find(str_compare==1);
          fname=fname(1:end-index+1);
      end
      mname=[fname,'.mat']; %create 'secret' output file to store peakh cell array
      fname=[fname,'.txt'];
      %write results to a text file
      fid=fopen([pname,fname],'w');
      cdate=clock;
      fprintf(fid,'%s\n','_____________________________________________________________');
      fprintf(fid,'%s\n',' ');
      fprintf(fid,'%s\n',['    Results from PEAKTOOL   date: ',num2str(cdate(3)),'.',num2str(cdate(2)),'.',num2str(cdate(1)),'  time: ',num2str(cdate(4)),':',num2str(cdate(4),'%.2i')]);
      fprintf(fid,'%s\n','_____________________________________________________________');
      fprintf(fid,'%s\n',' ');
      fprintf(fid,'%s\n',[' Number of peaks fitted: ',num2str(peakh.np)]);
      fprintf(fid,'%s\n',[' Quality of fit:  chi^2= ',num2str(peakh.chi2)]);
      fprintf(fid,'%s\n',[' length of data:      n= ',num2str(n_points)]);
      fprintf(fid,'%s\n',' ');
      fprintf(fid,'%s\n','T#*    pos.[pts]  area [%]   amp. [%]    width [pts]');
      fprintf(fid,'%s\n','_____________________________________________________________');
      for t=1:peakh.np   %loop through all peaks
        if peakh.ptyp(t)==0
            p_s='L';
        else
            p_s='G';
        end
        %ensure correct table structure by controlled length
        num=num2str(t,'%3.3d');
        pos=num2str(peakh.iv(t,1),'%5.8f');
        are=num2str(peakh.area(t),'%5.8f');
        amp=num2str(peakh.iv(t,2),'%5.8f');
        wid=num2str(peakh.iv(t,3),'%5.8f');        
        fprintf(fid,'%s\n',[p_s,' ',num,'  ',pos(1:8),'   ',are(1:8),'   ',amp(1:8),'    ',wid(1:8)]);
      end
      fprintf(fid,'%s\n',' ');
      fprintf(fid,'%s\n',' ');
      fprintf(fid,'%s\n','* G = Gaussian, L = Lorentzian');
      fprintf(fid,'%s\n',' ');
      fprintf(fid,'%s\n',' Gaussian  : g(x)=amp*exp[-(x-pos)^2 *ln(2)*4 /width^2]   with area=amp*width*pi/2');
      fprintf(fid,'%s\n',' Lorentzian: l(x)=amp*width^2/[4*(x-pos)^2 +width^2]      with area=amp*width*sqrt(pi/ln(2))/2');
      fprintf(fid,'%s\n',' ');
      fprintf(fid,'%s\n','             for x=linspace(1,n,n) with n=length of data');
      fclose(fid);  %close text file
      save([pname,mname],'peakh'); %save peak parameter in the MATLAB fashion
    end
    
case 'exp_excel' %exports the data to MS-Excel via ActiveX #########################################
    Excel = actxserver('Excel.Application');   % First, open an Excel Server
    set(Excel, 'Visible', 1);                  %switch on
    Workbook = invoke(Excel.Workbooks, 'Add');         % Insert a new workbook
    Range = get(Excel.Activesheet,'Range','A1',['F',num2str(peakh.np+1)]);  %get the range of columns
    outv=cell(peakh.np+1,6); %store values for Excel in cell, because mix of numbers & text
    outv(1,:)={'peak','type','pos.[pts]','area [%]','amp. [%]','width [pts]'}; %header of columns
    for t=1:peakh.np   %loop through all peaks to extract stuff
      outv(t+1,1)={t};
      if peakh.ptyp(t)==0
         outv{t+1,2}='Lorentz';
      else
         outv{t+1,2}='Gauss';
      end
       outv(t+1,3)=num2cell(peakh.iv(t,1));
       outv(t+1,4)={peakh.area(t)};
       outv(t+1,5)={peakh.iv(t,2)};
       outv(t+1,6)={peakh.iv(t,3)};
    end
    set(Range, 'Value',outv); %transfer to Excel

case 'load_param'
    [fname,pname] = uigetfile('*.mat','Load peak parameters'); %open GUI to select filename/directory
    if fname~=0 %ensure something was specified
      peakh0=peakh;
      peakh=[];
      load([pname,fname]); %load data
      if isstruct(peakh)  %check if actually the structure peakh was loaded
        peakh0=[];
        peaktool('pp_Accept'); %restart with loaded parameters
      else
        errordlg('ERROR: this file was not stored by this routine. Keep old values!'); %display error message
        peakh=peakh0; %reset to old values in peakh0
        peakh0=[];
      end
    end
    
%--------------------------------------PLOT CONTROLS as in plottool----------------------------
case 'hor_slider'  
    achs(5)=get(gui_handle.hslider,'Value');
    plot_data([]);      
    
case 'hordouble'
    achs(6)=achs(6)/2;
    achs(10) = achs(10)/2;
    achs(9) = achs(10)/10;
    if achs(9)>1, achs(9)=1;end
    set(gui_handle.hslider,'sliderstep',achs(9:10),'max',achs(2),'min',achs(1),'Value',achs(5));
    plot_data([]);
    
case 'horhalf'
    achs(6)=achs(6)*2;
    achs(10) = achs(10)*2;
    achs(9) = achs(10)/10;
    if achs(9)>1, achs(9)=1;end
    set(gui_handle.hslider,'sliderstep',achs(9:10),'max',achs(2),'min',achs(1),'Value',achs(5));
    plot_data([]);
    
case 'ver_slider' 
    achs(7)=get(gui_handle.vslider,'Value');
    plot_data([]);      
      
case 'vertdouble'
    achs(8)=achs(8)/2;
    achs(12) = achs(12)/2;
    achs(11) = achs(12)/10;
    if achs(11)>1, achs(11)=1;end
    set(gui_handle.vslider,'sliderstep',achs(11:12),'max',achs(4),'min',achs(3),'Value',achs(7));
    plot_data([]);
   
case 'verthalf'
    achs(8)=achs(8)*2;
    achs(12) = achs(12)*2;
    achs(11) = achs(12)/10;
    if achs(11)>1, achs(11)=1;end
    set(gui_handle.vslider,'sliderstep',achs(11:12),'max',achs(4),'min',achs(3),'Value',achs(7));
    plot_data([]);

case {'plot_sum','plot_ind','plot_res','grid_plot','line_plot','point_plot','show_damp','show_thres'}
    plot_data([]);
    
case 'sep_win'
    sz=get(0,'ScreenSize');
    figure('Units','pixel','Position',[185 sz(4)-490 624 410],'name','Peak tool: separate plot window');
    gui_handle.sep_win=axes; 
    plot_data([]);
    
case 'reset_plot'
    init_plot(' ');  
    set(gui_handle.hslider,'sliderstep',achs(9:10),'max',achs(2),'min',achs(1),'Value',achs(5));
    set(gui_handle.vslider,'sliderstep',achs(11:12),'max',achs(4),'min',achs(3),'Value',achs(7));
    plot_data([]);
    
case 'done'
    if length(peakh.iv)~=0 %case someone exits from the start
    x=linspace(1,n_points,n_points);
    y=zeros(1,n_points);
    for t=1:peakh.np        %loop through all peaks to calc. the sum of the peak
       if peakh.ptyp(t)==1 %Gauss
          y=y+peakh.iv(t,2)*exp(-(x-peakh.iv(t,1)).^2*log(2)*4/peakh.iv(t,3)^2);
       else                 %Lorentz
          y=y+peakh.iv(t,2)*peakh.iv(t,3)^2./(4*(x-peakh.iv(t,1)).^2+peakh.iv(t,3)^2);
       end
    end
    assignin('base','peak_values',peakh); %save peakh structure to the workplace as variable 'peak_values'
    assignin('base','fit_curve',y);    %save fitted curve to the workplace as variable 'fit_curve'
    end
    close(gcbf);
    return    
    
end %of switch





%##########################################################################################
%    separate functions
%##########################################################################################


%GET_PEAKS: inital peak values+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function get_peaks(varargin)
global data achs gui_handle n_points peakh
    n_points=length(data);
    peakh.np=length(peakh.pp);       %number of peaks found
    peakh.ptyp=ones(1,peakh.np);     %define structure sizes
    peakh.iv=zeros(peakh.np,3);
    peakh.vary=zeros(peakh.np,3);
    for t=1:peakh.np                 %loop through peaks
      peakh.iv(t,1)=peakh.pp(t);     %that's the position
      wid=find(data<data(peakh.pp(t))/2)-peakh.pp(t);  %guess width by looking at half height to the left 
      peakh.iv(t,3)=min(nonzeros(-(wid.*(wid<0))))*2;  %that's the width
      peakh.iv(t,2)=data(peakh.pp(t));  %that's the amplitude
    end
    plot_data([]);      

    
%UPDATE_PEAKLIST: update the listbox display (with new values)++++++++++++++++++++++++++++++++
function update_peaklist(varargin)
global data achs gui_handle n_points peakh
peakh.iv(:,3)=abs(peakh.iv(:,3));    %avoid negative widths
if sum(sum(peakh.vary(:,:)))~=0      %check if any vary-box is checked
   set(gui_handle.fitb,'Visible','On');  %switch FIT-field on
   set(gui_handle.ptol_txt,'Visible','On');
   set(gui_handle.rtol_txt,'Visible','On');
   set(gui_handle.mitr_txt,'Visible','On');
   set(gui_handle.ptol,'Visible','On');
   set(gui_handle.rtol,'Visible','On');
   set(gui_handle.mitr,'Visible','On');
else
   set(gui_handle.fitb,'Visible','Off');  %switch FIT-field off
   set(gui_handle.ptol_txt,'Visible','Off');
   set(gui_handle.rtol_txt,'Visible','Off');
   set(gui_handle.mitr_txt,'Visible','Off');
   set(gui_handle.ptol,'Visible','Off');
   set(gui_handle.rtol,'Visible','Off');
   set(gui_handle.mitr,'Visible','Off');
end
if peakh.np<=0        %in case there are no peaks
    set(gui_handle.peaklist,'String','no peaks');
    set(gui_handle.pos,'String','--');    
    set(gui_handle.amp,'String','--');
    set(gui_handle.wid,'String','--');
    set(gui_handle.vpos,'Value',0);
    set(gui_handle.vamp,'Value',0);
    set(gui_handle.vwid,'Value',0);
  return
end
p_s=[];             %reset output string for peak type
peakh.area=zeros(peakh.np,1);  %reset areas
t_area=0;                      %reset total area
for t=1:peakh.np               %loop through all peaks to calc. areas
  if peakh.ptyp(t)==0          %is Lorentzian
     peakh.area(t)=abs(0.5*peakh.iv(t,2)*peakh.iv(t,3)*pi);  %calc. area of Lorentzian (-inf..inf) abs, because amps can be negative
     t_area=t_area+peakh.area(t);   %add to total area
  else                        %must be Gaussian
     peakh.area(t)=abs(0.5*peakh.iv(t,2)*peakh.iv(t,3)*sqrt(pi/log(2))); %calc. area of Gaussian (-inf..inf)
     t_area=t_area+peakh.area(t);   %add to total area
  end
end
for t=1:peakh.np              %loop through all peaks to create output and norm. area
   if peakh.ptyp(t)==0        %in case of Lorentzian     
     pts='Lorentz  ';
   else                       %in case of Lorentzian  
     pts='Gauss    ';
   end
   peakh.area(t)=peakh.area(t)/t_area*100; %norm. area to %
   p_s{t}=[num2str(t),': ',pts,'area: ',num2str(peakh.area(t)),' %']; %compose output string cell for listbox
end
set(gui_handle.peaklist,'String',p_s); %update list in listbox
if  peakh.select<1 | peakh.select>peakh.np %in case the selected peak isn't defined (can happen by successive delete)
    peakh.select=1;  %than chose 1st
end
set(gui_handle.peaklist,'Value',peakh.select);          %update all the boxes with peak parameters
set(gui_handle.pos,'String',num2str( peakh.iv(peakh.select,1)));
set(gui_handle.amp,'String',num2str( peakh.iv(peakh.select,2)));
set(gui_handle.wid,'String',num2str( peakh.iv(peakh.select,3)));
set(gui_handle.vpos,'Value',peakh.vary(peakh.select,1));
set(gui_handle.vamp,'Value',peakh.vary(peakh.select,2));
set(gui_handle.vwid,'Value',peakh.vary(peakh.select,3));
%update summaric check boxes in case conditions are changed manually
if prod(prod(peakh.vary(:,:)))==1 %all vary boxes checked
   set(gui_handle.vall,'Value',1);
   set(gui_handle.vall,'String','vary none parameter') %change text of checkbox
else
   set(gui_handle.vall,'Value',0);
   set(gui_handle.vall,'String','vary all parameter') %change text of checkbox
end
if prod(prod(peakh.vary(:,1)))==1 %all pos vary boxes checked
   set(gui_handle.vposall,'Value',1);
   set(gui_handle.vposall,'String','none') %change text of checkbox
else
   set(gui_handle.vposall,'Value',0);
   set(gui_handle.vposall,'String','all') %change text of checkbox
end
if prod(prod(peakh.vary(:,2)))==1 %all amp vary boxes checked
   set(gui_handle.vampall,'Value',1);
   set(gui_handle.vampall,'String','none') %change text of checkbox
else
   set(gui_handle.vampall,'Value',0);
   set(gui_handle.vampall,'String','all') %change text of checkbox
end
if prod(prod(peakh.vary(:,3)))==1 %all wid vary boxes checked
   set(gui_handle.vwidall,'Value',1);
   set(gui_handle.vwidall,'String','none') %change text of checkbox
else
   set(gui_handle.vwidall,'Value',0);
   set(gui_handle.vwidall,'String','all') %change text of checkbox
end
if peakh.ptyp(peakh.select)==1                     %update toggle of Lorentz if Gauss etc.
   set(gui_handle.gaulo,'String','Gauss -> Lorentz');
else
   set(gui_handle.gaulo,'String','Lorentz -> Gauss');
end
if prod(peakh.ptyp)==1  %all Gaussian
     set(gui_handle.alllo,'String','all Lorentz'); %switch text 
end
if sum(peakh.ptyp)==0  %all Lorentz
     set(gui_handle.alllo,'String','all Gauss'); %switch text 
end
%finally calc. chi^2
x=linspace(1,n_points,n_points); 
y=zeros(1,n_points);
for t=1:peakh.np      %loop through all peaks to calc the fitted spectrum
  if peakh.ptyp(t)==1
     y=y+peakh.iv(t,2)*exp(-(x-peakh.iv(t,1)).^2*log(2)*4/peakh.iv(t,3)^2);
  else
     y=y+peakh.iv(t,2)*peakh.iv(t,3)^2./(4*(x-peakh.iv(t,1)).^2+peakh.iv(t,3)^2);
  end
end
peakh.chi2=sum(abs(data-y).^2); %calc the residuals, square and sum = chi^2
set(gui_handle.chi2,'String',num2str(peakh.chi2));



%PLOT_DATA: create/update output window ++++++++++++++++++++++++++++++++++++++++++++++++++++++
function plot_data(varargin)
global data achs gui_handle n_points peakh
  newplot(gcf);
  hold on;      %one plot!
  achs(1)=achs(5)-achs(6)/2; %update axis
  achs(2)=achs(5)+achs(6)/2;
  achs(3)=achs(7)-achs(8)/2;
  achs(4)=achs(7)+achs(8)/2;
  if get(gui_handle.line_rb,'Value')==1 %in case of line plot is wished
     lstyle='-';
  else
     lstyle='none';
  end
  if get(gui_handle.poin_rb,'Value')==1 %in case of point plot is wished
     mstyle='.';
  else
     mstyle='none';
  end
  %plot the data
  plot(data,'color','b','Linestyle',lstyle,'Marker',mstyle,'LineWidth',2);axis(achs(1:4));
  
  %if the SUM OF ALL PEAKS should be displayed (check if already available=visible)
  if get(gui_handle.p_sum,'Value')==1 & strcmp(get(gui_handle.p_sum,'Visible'),'on')==1
     x=linspace(1,n_points,n_points);
     y=zeros(1,n_points);
     for t=1:peakh.np        %loop through all peaks to calc. the sum of the peaks
          if peakh.ptyp(t)==1 %Gauss
           y=y+peakh.iv(t,2)*exp(-(x-peakh.iv(t,1)).^2*log(2)*4/peakh.iv(t,3)^2);
         else                 %Lorentz
           y=y+peakh.iv(t,2)*peakh.iv(t,3)^2./(4*(x-peakh.iv(t,1)).^2+peakh.iv(t,3)^2);
         end
     end
     plot(y,'k');axis(achs(1:4)); %plot the sum of all peaks
  end
  %if the INDIVIDUAL PEAKS should be displayed (check if already available=visible)
  if get(gui_handle.p_ind,'Value')==1 & strcmp(get(gui_handle.p_ind,'Visible'),'on')==1
     x=linspace(1,n_points,n_points);
     y=zeros(1,n_points);
     for t=1:peakh.np        %loop through all peaks to calc. and plot each peak
         if peakh.ptyp(t)==1 %Gauss
           y=peakh.iv(t,2)*exp(-(x-peakh.iv(t,1)).^2*log(2)*4/peakh.iv(t,3)^2);
           plot(y,'r');axis(achs(1:4));
         else                %Lorentz
           y=peakh.iv(t,2)*peakh.iv(t,3)^2./(4*(x-peakh.iv(t,1)).^2+peakh.iv(t,3)^2);
           plot(y,'r');axis(achs(1:4)); %plot each peak in red
         end
     end
  end
  %if the RESIDUAL should be displayed (check if already available=visible)
  if get(gui_handle.p_res,'Value')==1 & strcmp(get(gui_handle.p_res,'Visible'),'on')==1
     x=linspace(1,n_points,n_points);
     y=zeros(1,n_points);
     for t=1:peakh.np     %loop through all peaks to calc. residual
          if peakh.ptyp(t)==1 %Gauss
           y=y+peakh.iv(t,2)*exp(-(x-peakh.iv(t,1)).^2*log(2)*4/peakh.iv(t,3)^2);
         else                 %Lorentz
           y=y+peakh.iv(t,2)*peakh.iv(t,3)^2./(4*(x-peakh.iv(t,1)).^2+peakh.iv(t,3)^2);
         end
     end
     plot(data-y,'g');axis(achs(1:4)); %subtract from data and display in green
  end 
  %PLOT THE MARKERS
  if length(peakh.iv)~=0 %check if positions exist
    for t=1:peakh.np      %loop through all peaks to see how many parameters are to vary
       if sum(peakh.vary(t,:))~=0  %if there are any to vary... 
          col=[sum(peakh.vary(t,:))/3,0,0]; %...calc the color (dark red=1, medium red=2, bright red=3) dependent on the number of parameters to vary
       else
          col=[1 1 1];   %if nothing to vary...make them white
       end
       ppos=round(peakh.iv(t,1)); %make sure position is integer (otherwise warning by Matlab)
       plot(ppos,real(data(ppos)),'bo','MarkerFaceColor',col,'LineWidth',2)%plot the makers on each peak position
    end
  end
  if length(peakh.pp)~=0  & length(peakh.iv)==0 %in early stage (peakpick only) make sure points are plotted
     ppos=round(peakh.pp(:)); %make sure position is integer (otherwise warning by Matlab)
     plot(ppos,data(ppos),'bo','LineWidth',2,'MarkerFaceColor','w') %plot the makers
  end
  if peakh.select~=0   %highlight the selected peak in yellow
     ppos=round(peakh.iv(peakh.select,1)); %make sure position is integer (otherwise warning by Matlab)
     plot(ppos,real(data(ppos)),'ko','MarkerFaceColor','y','LineWidth',2)
  end
 
  %show the curve/threshold of the peakpicker (check if selected and still available=visible)
  if get(gui_handle.shth,'Value')==1 & strcmp(get(gui_handle.shth,'Visible'),'on')==1 
     plot([1:n_points],peakh.ppv(2),'Color',[.5,.5,0.5],'Linestyle',':');axis(achs(1:4)); %plot the threshold
  end
  if get(gui_handle.shlw,'Value')==1 & strcmp(get(gui_handle.shlw,'Visible'),'on')==1
       x=linspace(-1,1,n_points);
       filter=exp(-x.^2*peakh.ppv(1)); %calc. filter function as in peakpick
       temp_data=fftshift(fft(data)).*filter; 
       temp_data=real(ifft(ifftshift(temp_data)));
       plot(temp_data,'Color',[.3,.3,0.3],'Linestyle',':');axis(achs(1:4)); %display filter
  end
  %plot GRID if selected
  if get(gui_handle.grid_rb,'Value')==1
     grid on;
  else
     grid off;
  end
  hold off; %finish plot

  
%INIT_PLOT: initial setup/reset of plot ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function init_plot(varargin)
global data achs gui_handle n_points peakh
    %achs(1) = minimum of x-axis
    %achs(2) = maximum of x-axis
    %achs(3) = minimum of y-axis
    %achs(4) = maximum of y-axis
    %achs(5) = center of x-axis
    %achs(6) = range of x-axis
    %achs(7) = center of y-axis
    %achs(8) = range of y-axis
    %achs(9) = step size of horizontal slider arrow
    %achs(10)= step size of horizontal slider bar
    %achs(11)= step size of vertical slider arrow 
    %achs(12)= step size of vertical slider bar 
    achs(1)=1;
    achs(2)=n_points;
    achs(4)=max(abs(data));
    achs(3)=min(real(data));
    if min(imag(data))<achs(3)
        achs(3)=min(imag(data));
    end
    achs(6)=achs(2)-achs(1);
    achs(5)=achs(2)-achs(6)/2;
    achs(8)=achs(4)-achs(3);
    achs(7)=achs(4)-achs(8)/2;
    achs(9) = 1; achs(10) = 1;
    achs(11) = 1; achs(12) = 1;

    
%MAKEgui: define initial uicontrols++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function MAKEgui(varargin)
global data achs gui_handle n_points peakh
   %create figure
   sz=get(0,'ScreenSize');
   gui_handle.phas_fig = figure('Units','pixel','Interruptible','off','Position',[10 sz(4)-580 800 550],'Name','Peak Tool','Tag','mainfig','MenuBar','none','Color',[0.83,0.81,0.78]);
   set(gui_handle.phas_fig,'BusyAction','queue');
   gui_handle.out_win=axes('Units','pixel','Position',[195 137 552 411]);
   %create static text
   gui_handle.id_txt=uicontrol('Style','text','Units','pixel','Position',[270,5,186,14], 'FontSize',8,'FontWeight','normal','String','(c) 2003 P.Blümler, MPIP','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.pp_txt=uicontrol('Style','text','Units','pixel','Position',[10,530,120,20], 'FontSize',10,'FontWeight','bold','HorizontalAlignment','left','String','1. peak picking','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.fit_txt=uicontrol('Style','text','Units','pixel','Position',[10,530,120,20], 'FontSize',10,'FontWeight','bold','HorizontalAlignment','left','String','2. peak fitting','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.pl_txt=uicontrol('Style','text','Units','pixel','Position',[10,500,60,20], 'FontSize',8,'FontWeight','normal','HorizontalAlignment','left','String','damping','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.pt_txt=uicontrol('Style','text','Units','pixel','Position',[10,480,60,20], 'FontSize',8,'FontWeight','normal','HorizontalAlignment','left','String','threshold','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.pos_txt=uicontrol('Style','text','Units','pixel','Position',[2,330,60,20], 'FontSize',8,'FontWeight','normal','HorizontalAlignment','left','String','position [pts]','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.amp_txt=uicontrol('Style','text','Units','pixel','Position',[2,280,80,20], 'FontSize',8,'FontWeight','normal','HorizontalAlignment','left','String','amplitude [%]','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.wid_txt=uicontrol('Style','text','Units','pixel','Position',[2,230,60,20], 'FontSize',8,'FontWeight','normal','HorizontalAlignment','left','String','width [pts]','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.ptol_txt=uicontrol('Style','text','Units','pixel','Position',[10,60,100,20], 'FontSize',8,'FontWeight','normal','HorizontalAlignment','left','String','parameter tol.','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.rtol_txt=uicontrol('Style','text','Units','pixel','Position',[100,60,100,20], 'FontSize',8,'FontWeight','normal','HorizontalAlignment','left','String','residual tol.','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.mitr_txt=uicontrol('Style','text','Units','pixel','Position',[10,20,100,20], 'FontSize',8,'FontWeight','normal','HorizontalAlignment','left','String','max. iteration','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.chi_txt=uicontrol('Style','text','Units','pixel','Position',[20,130,100,20], 'FontSize',12,'FontWeight','bold','FontName','Symbol','HorizontalAlignment','left','String','c    = ','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.chi2_txt=uicontrol('Style','text','Units','pixel','Position',[29,142,10,12], 'FontSize',8,'FontWeight','bold','HorizontalAlignment','left','String','2','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.chi2=uicontrol('Style','text','Units','pixel','Position',[70,125,100,22],'String','--','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   %create dynamic text
   gui_handle.pp_lw=uicontrol('Style','edit','Units','pixel','Position',[55,500,60,22],'Callback','peaktool(''pplw_value'')','String',peakh.ppv(1),'BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.pp_th=uicontrol('Style','edit','Units','pixel','Position',[55,480,60,22],'Callback','peaktool(''ppth_value'')','String',peakh.ppv(2),'BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.pos=uicontrol('Style','edit','Units','pixel','Position',[2,310,170,22],'Callback','peaktool(''change_pos'')','String','--','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.amp=uicontrol('Style','edit','Units','pixel','Position',[2,260,170,22],'Callback','peaktool(''change_amp'')','String','--','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.wid=uicontrol('Style','edit','Units','pixel','Position',[2,210,170,22],'Callback','peaktool(''change_wid'')','String','--','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.ptol=uicontrol('Style','edit','Units','pixel','Position',[10,45,60,22],'Callback','peaktool(''change_ptol'')','String',num2str(peakh.fitp(1)),'Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.rtol=uicontrol('Style','edit','Units','pixel','Position',[100,45,60,22],'Callback','peaktool(''change_rtol'')','String',num2str(peakh.fitp(2)),'Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.mitr=uicontrol('Style','edit','Units','pixel','Position',[10,5,60,22],'Callback','peaktool(''change_mitr'')','String',num2str(peakh.fitp(3)),'Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   %create radiobuttons
   gui_handle.grid_rb=uicontrol('Style','radiobutton','Units','pixel','Position',[575,63,80,20],'Callback','peaktool(''grid_plot'')','Value',1,'String','grid','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.line_rb=uicontrol('Style','radiobutton','Units','pixel','Position',[575,45,80,20],'Callback','peaktool(''line_plot'')','Value',1,'String','lines','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.poin_rb=uicontrol('Style','radiobutton','Units','pixel','Position',[575,27,80,20],'Callback','peaktool(''point_plot'')','Value',0,'String','points','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.shlw=uicontrol('Style','radiobutton','Units','pixel','Position',[116,504,45,20],'Callback','peaktool(''show_damp'')','Value',0,'HorizontalAlignment','left','String','show','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.shth=uicontrol('Style','radiobutton','Units','pixel','Position',[116,484,45,20],'Callback','peaktool(''show_thres'')','Value',0,'HorizontalAlignment','left','String','show','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.p_sum=uicontrol('Style','radiobutton','Units','pixel','Position',[450,63,100,20],'Callback','peaktool(''plot_sum'')','Value',1,'ForegroundColor',[0,0,0],'String','sum of peaks','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.p_ind=uicontrol('Style','radiobutton','Units','pixel','Position',[450,45,100,20],'Callback','peaktool(''plot_ind'')','Value',0,'ForegroundColor',[1,0,0],'String','individual peaks','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.p_res=uicontrol('Style','radiobutton','Units','pixel','Position',[450,27,100,20],'Callback','peaktool(''plot_res'')','Value',0,'ForegroundColor',[0,1,0],'String','residuals','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vpos=uicontrol('Style','checkbox','Units','pixel','Position',[72,336,40,20],'Callback','peaktool(''vary_pos'')','Value',0,'String','vary','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vamp=uicontrol('Style','checkbox','Units','pixel','Position',[72,286,40,20],'Callback','peaktool(''vary_amp'')','Value',0,'String','vary','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vwid=uicontrol('Style','checkbox','Units','pixel','Position',[72,236,40,20],'Callback','peaktool(''vary_wid'')','Value',0,'String','vary','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vposall=uicontrol('Style','checkbox','Units','pixel','Position',[125,336,45,20],'Callback','peaktool(''vary_pos_all'')','Value',0,'String','all','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vampall=uicontrol('Style','checkbox','Units','pixel','Position',[125,286,45,20],'Callback','peaktool(''vary_amp_all'')','Value',0,'String','all','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vwidall=uicontrol('Style','checkbox','Units','pixel','Position',[125,236,45,20],'Callback','peaktool(''vary_wid_all'')','Value',0,'String','all','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vall=uicontrol('Style','checkbox','Units','pixel','Position',[30,190,120,20],'Callback','peaktool(''vary_all'')','Value',0,'String','vary all parameters','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   %create buttons
   gui_handle.exit_button=uicontrol('Style','Pushbutton','Units','pixel','Position',[729 30 60 38],'Callback','peaktool(''done'')','BackgroundColor',[1,0,0],'ForegroundColor',[1,1,1],'FontSize',12,'FontWeight','bold','String','EXIT');
   gui_handle.reset_button=uicontrol('Style','Pushbutton','Units','pixel','Position',[648 30 75 38],'Callback','peaktool(''reset_plot'')','BackgroundColor',[0,1,0],'ForegroundColor',[0,0,0],'FontSize',9,'FontWeight','bold','String','Reset Plot');
   gui_handle.vertdouble_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[770 525 20 20],'Callback','peaktool(''vertdouble'')','String','*2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.verthalf_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[770 145 20 20],'Callback','peaktool(''verthalf'')','String','/2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.hordouble_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[195 90 20 20],'Callback','peaktool(''hordouble'')','String','*2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.horhalf_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[730 90 20 20],'Callback','peaktool(''horhalf'')','String','/2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.pp_but=uicontrol('Style','Pushbutton','Units','pixel','Position',[10 450 90 20],'FontWeight','bold','Callback','peaktool(''peakp'')','String','pick peaks','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.pp_acc=uicontrol('Style','Pushbutton','Units','pixel','Position',[102 450 58 20],'FontWeight','bold','Callback','peaktool(''pp_Accept'')','String','ACCEPT','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.pp_back=uicontrol('Style','Pushbutton','Units','pixel','Position',[106 532 60 20],'FontWeight','bold','Callback','peaktool(''pp_back'')','String','< UNDO','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.gaulo=uicontrol('Style','Pushbutton','Units','pixel','Position',[2 355 90 20],'FontWeight','normal','Callback','peaktool(''toggle_gl'')','String','Gauss -> Lorentz','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.alllo=uicontrol('Style','Pushbutton','Units','pixel','Position',[97,355,70,20],'Callback','peaktool(''all_lorentz'')','Value',0,'String','all Lorentz','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.insp=uicontrol('Style','Togglebutton','Units','pixel','Position',[2 155 80 30],'FontWeight','bold','Callback','peaktool(''insert_peak'')','String','Insert Peak','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.delp=uicontrol('Style','Pushbutton','Units','pixel','Position',[90 155 80 30],'FontWeight','bold','Callback','peaktool(''delete_peak'')','String','Delete Peak','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.fitb=uicontrol('Style','Pushbutton','Units','pixel','Position',[2 95 170 30],'FontWeight','bold','FontSize',12,'Callback','peaktool(''fit_peak'')','String','FIT !','ForegroundColor',[1,0,0],'Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.save=uicontrol('Style','Pushbutton','Units','pixel','Position',[195 30 70 30],'FontWeight','bold','FontSize',12,'Callback','peaktool(''save_param'')','String','Save','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.savex=uicontrol('Style','Pushbutton','Units','pixel','Position',[275 30 70 30],'FontWeight','bold','FontSize',12,'Callback','peaktool(''exp_excel'')','String','>Excel','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.load=uicontrol('Style','Pushbutton','Units','pixel','Position',[355 30 70 30],'FontWeight','bold','FontSize',12,'Callback','peaktool(''load_param'')','String','Load','Visible','On','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.sepw=uicontrol('Style','Pushbutton','Units','pixel','Position',[195,72,130,15],'Callback','peaktool(''sep_win'')','Value',0,'String','seperate plot window','Visible','On','BackgroundColor',[0.83,0.81,0.78]);
   %create sliders
   gui_handle.hslider=uicontrol('Style','slider','Units','pixel','Position',[215 90 515 20],'Callback','peaktool(''hor_slider'')','sliderstep',achs(9:10),'max',achs(2),'min',achs(1),'Value',achs(5),'BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vslider=uicontrol('Style','slider','Units','pixel','Position',[770 165 20 360],'Callback','peaktool(''ver_slider'')','sliderstep',achs(11:12),'max',achs(4),'min',achs(3),'Value',achs(7),'BackgroundColor',[0.83,0.81,0.78]);
   %create listbox
   gui_handle.peaklist=uicontrol('Style','listbox','Units','pixel','Position',[2 380 170 140],'Callback','peaktool(''peaklist'')','String','no peaks','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);

%NLINFIT_P: modified copy of nlinfit to do the fitting+++++++++++++++++++++++++++++++++++++++++  
function [beta,r,J] = nlinfit_p(varargin)
global data achs gui_handle n_points peakh
  y = data(:);
  X=linspace(1,n_points,n_points);
  if size(X,1) == 1 % turn a row vector into a column vector.
     X = X(:);
  end
  beta0=reshape(peakh.iv,peakh.np*3,1); %reshape peakvalues to a vector
  p = length(beta0);
  beta0 = beta0(:);
  J = zeros(n_points,p);
  beta = beta0;
  betanew = beta + 1;
  maxiter = peakh.fitp(3);
  iter = 0;
  betatol = peakh.fitp(1);
  rtol = peakh.fitp(2);
  sse = 1;
  sseold = sse;
  seps = sqrt(eps);
  zbeta = zeros(size(beta));
  s10 = sqrt(10);
  eyep = eye(p);
  zerosp = zeros(p,1);
  while (norm((betanew-beta)./(beta+seps)) > betatol | abs(sseold-sse)/(sse+seps) > rtol) & iter < maxiter
     if iter > 0, 
        beta = betanew;
     end
     iter = iter + 1;
     yfit = peakfit(beta);
     r = y - yfit;
     sseold = r'*r;
     for k = 1:p,
        delta = zbeta;
        if (beta(k) == 0)
           nb = sqrt(norm(beta));
           delta(k) = seps * (nb + (nb==0));
        else
           delta(k) = seps*beta(k);
        end
        yplus = peakfit(beta+delta);
        J(:,k) = (yplus - yfit)/delta(k);
      end
      Jplus = [J;(1.0E-2)*eyep];
      rplus = [r;zerosp];
      step = Jplus\rplus;
      betanew = beta + step;
      yfitnew = peakfit(betanew);
      rnew = y - yfitnew;
      sse = rnew'*rnew;
      iter1 = 0;
      while sse > sseold & iter1 < 12
          step = step/s10;
          betanew = beta + step;
          yfitnew = peakfit(betanew);;
          rnew = y - yfitnew;
          sse = rnew'*rnew;
          iter1 = iter1 + 1;
       end
   end
if iter == maxiter
    %in case of an error/reaching max. iter. alter FIT-button
   set(gui_handle.fitb,'BackgroundColor',[1,0,0],'ForegroundColor',[1,1,1],'FontSize',10,'FontWeight','bold','String','change parameters');
else
   set(gui_handle.fitb,'BackgroundColor',[0.83,0.81,0.78],'ForegroundColor',[0,0.8,0],'FontSize',12,'FontWeight','bold','String','FIT !');

end
peakh.iv=reshape(beta,peakh.np,3);

%PEAKFIT: create the model function for nlinfit_p ++++++++++++++++++++++++++++++++++++++++++++++++
function estim=peakfit(beta)
global data achs gui_handle n_points peakh
   x=linspace(1,n_points,n_points)';
   btemp=reshape(beta,peakh.np,3); %reshape values from nlinfit_p to compare with peakh.iv
   estim=zeros(n_points,1);
   for t=1:peakh.np    %loop through all peaks to check vary-status
       for k=1:3
           if peakh.vary(t,k)==0 %if not to vary set to old value
               pp(t,k)=peakh.iv(t,k);
           else
               pp(t,k)=btemp(t,k); %if to vary set to guessed value from nlinfit_p
           end
       end
   end
   for t=1:peakh.np   %loop through all peaks to create new estimated function
      if peakh.ptyp(t)==1 %Gauss
         estim=estim+pp(t,2)*exp(-(x-pp(t,1)).^2*log(2)*4/pp(t,3)^2);
      else                %LOrentz
         estim=estim+pp(t,2)*pp(t,3)^2./(4*(x-pp(t,1)).^2+pp(t,3)^2);
     end
   end