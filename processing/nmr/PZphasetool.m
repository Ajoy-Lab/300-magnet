%############################################################################
%#
%#                           function PZphasetool
%#
%#      generates an interactive GUI to phase data
%#      data must be complex, Fourier-transformed and one-dimensional! 
%#      
%#      PH0 is zeroth order phase correction in degrees
%#      PH1 is first order phase correction in degrees/(number of points in the input data)*1000
%#      pivot is the origin for PH1 in points 
%#
%#      usage: PZphasetool(data,pval,base);
%#
%#      INPUT (calling):
%#      data  = input data (1D, complex)
%#      pval  = OPTIONAL predefined phase values (3x1 vector)
%#              [p1,p2,p3] with p1 = PH0 value in degrees
%#                              p2 = PH1 value in degrees/number of data points*1000
%#                              p3 = pivot in points
%#      base  = OPTIONAL baseline (vector of length of data)
%#
%#      OUTPUT (returning)
%#      when the function is called with pval, it contains the phase values (3x1 vector)
%#      after returning. Recursive calls will therefore reuse the last values!!!!
%#      If not specified (calling "PZphasetool(data)" only) will notify that the phase values
%#      can be found in the working place in the variable "phase_values".
%#      The same works with/without base (if not specified the values are returned in the
%#      variable "baseline".
%#
%#      (c) P. Blümler 1/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.2 PB 6/2/03    (please change this when code is altered) added fixed colors for UNIX
%  version 1.3 PZ 28/10/04  baseline correction (polynomial) now working
%----------------------------------------------------------------------------



function PZphasetool(indata,inpval1,inpval2)
global data data0 achs pval gui_handle out_var_name n_points bsdown bsval bs_curve bsappl
% data          processed spectrum
% data0         unchanged spectrum
% achs          plot axis
% pval          phase parameter
% gui_handle    user interface objects
% out_var_name  name of result varibles
% n_points      number of points of spectrum
% bsdown        x-pos of pressed Btn for defining baseline region (default 0)
% bsval         selected points for baseline correction (x-values)
% bs_curve      fitted baseline curve
% bsappl        flag, 1 if baseline correction applied, 0 if not

if (nargin == 0)
    disp('ERROR: No data specified!')
    return
elseif (nargin==1) & ~isstr(indata) 
    disp('After exiting the results will automatically be stored in the variables:')
    disp('"phase_values" and "baseline" (latter if accessed)')
    out_var_name={'phase_values','baseline'};
    action = 'start';
elseif (nargin==2) & ~isstr(indata)
    out_var_name={inputname(2),'baseline'};
    action = 'start';
elseif ~isstr(indata) 
    action = 'start';
    out_var_name={inputname(2),inputname(3)};
else
    action = indata;
end

%MAIN ACTION SWITCH (actions are the callbacks for function 'PZphasetool' defined in MAKEgui)
switch action
case 'start'   %initiallizing
    data=squeeze(indata);
    dim=size(data);
    if (ndims(data) >= 2) & (prod(dim) ~=length(data))
       disp('WARNING: data input array is NOT ONEDIMENSIONAL!');
       disp('take first slice');
       data=squeeze(data(:,1,1,1,1))';
       dim=size(data);
    end
    if sum(imag(data))==0
        disp('WARNING: data is not complex!')
    end
    if dim(1) ~= 1   %do eventually necessary transpose
        data=data';
        dim=size(data);
    end
    data0=data;
    n_points=dim(2);
    achs=zeros(16,1);    
    bs_curve=[];
    bsappl=0;
    if exist('inpval1') == 1
       pval=inpval1;
       if length(pval) ~= 3
            pval=zeros(3,1);
       end
       if pval(3)==0
           pval(3)=find(abs(data)==max(abs(data)));
       end
       achs(13)=pval(1)-90;
       achs(14)=pval(1)+90;
       achs(15)=pval(2)-12*pi/n_points*1000;
       achs(16)=pval(2)+12*pi/n_points*1000;
   else
       pval=zeros(3,1);
       pval(3)=find(abs(data)==max(abs(data)));
       achs(13)=-90;
       achs(14)=90;
       achs(15)=-12*pi/n_points*1000;
       achs(16)=12*pi/n_points*1000;
    end
    if exist('inpval2') == 1
       bs_curve=inpval2;
    end
    bsval=[];
    init_plot(' ');
    MAKEgui(' ');
    plot_data([]);
    
case 'piv_value' 
    pval(3)=str2num(get(gui_handle.piv_ed,'String'));
    if pval(3)<1, pval(3)=1; end
    if pval(3)>n_points, pval(3)=n_points; end    
    set(gui_handle.piv_ed,'String',num2str(pval(3)));
    plot_data([]);
 
case 'pivot_select' 
    set(gcf,'Pointer','crosshair');
    set(gui_handle.pivot_button,'String','Click HERE when done!','BackgroundColor',[1,1,0],'ForegroundColor',[0,0,0],'FontSize',8,'FontWeight','bold');
    while get(gui_handle.pivot_button,'Value')==1;
       set(gcf,'Pointer','crosshair');
       waitforbuttonpress;
       waitforbuttonpress; %stupid but only works this way
       if get(gui_handle.pivot_button,'Value')==0, break, end
       cursor_pos=get(gui_handle.out_win,'CurrentPoint');
       pval(3)=round(cursor_pos(1,1));
       if pval(3)<1, pval(3)=1; end
       if pval(3)>n_points, pval(3)=n_points; end    
       set(gui_handle.piv_ed,'String',num2str(pval(3)));
       plot_data([]);
    end
    set(gui_handle.pivot_button,'BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'FontWeight','normal','String','Select manually');
    set(gcf,'Pointer','arrow');
    
case 'ph0_slider' 
    pval(1)=get(gui_handle.ph0slider,'Value');
    set(gui_handle.ph0_ed,'String',num2str(pval(1)));
    plot_data([]);
     
case 'ph0double'
    del=(achs(14)-achs(13))*2;
    achs(13)=pval(1)-del/2;
    achs(14)=pval(1)+del/2;
    set(gui_handle.ph0min_ed,'String',num2str(achs(13)));
    set(gui_handle.ph0max_ed,'String',num2str(achs(14)));
    set(gui_handle.ph0slider,'max',achs(14),'min',achs(13),'Value',pval(1));

case 'ph0half'
    del=(achs(14)-achs(13))/2;
    achs(13)=pval(1)-del/2;
    achs(14)=pval(1)+del/2;
    set(gui_handle.ph0min_ed,'String',num2str(achs(13)));
    set(gui_handle.ph0max_ed,'String',num2str(achs(14)));
    set(gui_handle.ph0slider,'max',achs(14),'min',achs(13),'Value',pval(1));
     
case 'ph0_value'
    pval(1)=str2num(get(gui_handle.ph0_ed,'String'));
    if pval(1) < achs(13), pval(1)=achs(13);end
    if pval(1) > achs(14), pval(1)=achs(14);end
    set(gui_handle.ph0_ed,'String',num2str(pval(1)));
    set(gui_handle.ph0slider,'max',achs(14),'min',achs(13),'Value',pval(1));
    plot_data([]);
   
case 'ph0_max'
    achs(14)=str2num(get(gui_handle.ph0max_ed,'String'));
    if achs(14) < pval(1), achs(14)=pval(1);end    
    set(gui_handle.ph0max_ed,'String',num2str(achs(14)));
    set(gui_handle.ph0slider,'max',achs(14),'min',achs(13),'Value',pval(1));

case 'ph0_min'
    achs(13)=str2num(get(gui_handle.ph0min_ed,'String'));
    if achs(13) > pval(1), achs(13)=pval(1);end    
    set(gui_handle.ph0min_ed,'String',num2str(achs(13)));
    set(gui_handle.ph0slider,'max',achs(14),'min',achs(13),'Value',pval(1));

case 'ph1_slider' 
    pval(2)=get(gui_handle.ph1slider,'Value');
    set(gui_handle.ph1_ed,'String',num2str(pval(2)));
    plot_data([]);
    
case 'ph1double'
    del=(achs(16)-achs(15))*2;
    achs(15)=pval(2)-del/2;
    achs(16)=pval(2)+del/2;
    set(gui_handle.ph1min_ed,'String',num2str(achs(15)));
    set(gui_handle.ph1max_ed,'String',num2str(achs(16)));
    set(gui_handle.ph1slider,'max',achs(16),'min',achs(15),'Value',pval(2));

case 'ph1half'
    del=(achs(16)-achs(15))/2;
    achs(15)=pval(2)-del/2;
    achs(16)=pval(2)+del/2;
    set(gui_handle.ph1min_ed,'String',num2str(achs(15)));
    set(gui_handle.ph1max_ed,'String',num2str(achs(16)));
    set(gui_handle.ph1slider,'max',achs(16),'min',achs(15),'Value',pval(2));
     
case 'ph1_value'
    pval(2)=str2num(get(gui_handle.ph1_ed,'String'));
    if pval(2) < achs(15), pval(2)=achs(15);end
    if pval(2) > achs(16), pval(2)=achs(16);end
    set(gui_handle.ph1_ed,'String',num2str(pval(2)));
    set(gui_handle.ph1slider,'max',achs(16),'min',achs(15),'Value',pval(2));
    plot_data([]);
    
case 'ph1_max'
    achs(16)=str2num(get(gui_handle.ph1max_ed,'String'));
    if achs(16) < pval(2), achs(16)=pval(2);end    
    set(gui_handle.ph1max_ed,'String',num2str(achs(16)));
    set(gui_handle.ph1slider,'max',achs(16),'min',achs(15),'Value',pval(2));
     
case 'ph1_min'
    achs(15)=str2num(get(gui_handle.ph1min_ed,'String'));
    if achs(15) > pval(2), achs(15)=pval(2);end    
    set(gui_handle.ph1min_ed,'String',num2str(achs(15)));
    set(gui_handle.ph1slider,'max',achs(16),'min',achs(15),'Value',pval(2));
     
    
%PLOT CONTROLS
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

case {'realpart','imagpart','magpart','grid_plot','line_plot','point_plot'}
    plot_data([]);
    
case 'reset_plot'
    init_plot(' ');  
    set(gui_handle.hslider,'sliderstep',achs(9:10),'max',achs(2),'min',achs(1),'Value',achs(5));
    set(gui_handle.vslider,'sliderstep',achs(11:12),'max',achs(4),'min',achs(3),'Value',achs(7));
    plot_data([]);
    
case 'done'
    assignin('base',out_var_name{1},pval);
    assignin('base',out_var_name{2},bs_curve);    
    close(gcbf);
    return


%Handle Baseline Correction
case 'bs_active'
    if get(gui_handle.bs_active,'Value')==1 & length(bs_curve)==n_points
       set(gui_handle.bs_active,'String','click to accept BS values','ForegroundColor',[1,0,0],'FontWeight','bold');
    elseif get(gui_handle.bs_active,'Value')==0 & length(bs_curve)==n_points
       set(gui_handle.bs_active,'String','click to change BS values','ForegroundColor',[0,0.6,0],'FontWeight','bold')
    else
       set(gui_handle.bs_active,'String','activate Baseline Correction');
    end
    if get(gui_handle.bs_active,'Value')==1
       set(gui_handle.bs_txt,'Visible','On');  
       set(gui_handle.bspts_txt,'Visible','On'); 
       set(gui_handle.meth_txt,'Visible','On');
       set(gui_handle.bspts_lb,'Visible','On'); 
       set(gui_handle.bs_button,'Visible','On');  
       set(gui_handle.bs_delb,'Visible','On');
       set(gui_handle.bs_apply,'Visible','On');  
       set(gui_handle.bs_popm,'Visible','On');       
       if get(gui_handle.bs_popm,'Value')==1
           set(gui_handle.bs_poly,'Visible','On');
           set(gui_handle.bs_pdeg,'Visible','On');
       end
       bsappl=0;
    else
       set(gui_handle.bs_txt,'Visible','Off');  
       set(gui_handle.bspts_txt,'Visible','Off'); 
       set(gui_handle.meth_txt,'Visible','Off');
       set(gui_handle.bspts_lb,'Visible','Off'); 
       set(gui_handle.bs_button,'Visible','Off');  
       set(gui_handle.bs_delb,'Visible','Off');
       set(gui_handle.bs_apply,'Visible','Off');  
       set(gui_handle.bs_popm,'Visible','Off');
       set(gui_handle.bs_mark,'Visible','Off');
       set(gui_handle.bs_poly,'Visible','Off');
       set(gui_handle.bs_pdeg,'Visible','Off');
    end
    plot_data([]);
    
case 'bs_select'  %manually select BS points
    if get(gui_handle.bs_button,'Value')==1
        set(gcf,'Pointer','crosshair');
        set(gui_handle.bs_button,'String','DONE!','BackgroundColor',[1,1,0],'ForegroundColor',[0,0,0],'FontSize',12,'FontWeight','bold');
        set(gui_handle.bs_mark,'Visible','On');
        bsappl=0;
        plot_data([]);
    else
        set(gui_handle.bs_button,'String','Select points','BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'FontWeight','normal');
        set(gui_handle.bs_mark,'Visible','Off');
        set(gcf,'Pointer','arrow');                    
        PZphasetool('bs_method');
    end
     
% case 'bspts_lb'  %manage deleting singular BS points
%     kdel=get(gui_handle.bspts_lb,'Value');
%     if kdel==1
%         bsval=bsval(2:end);
%     elseif kdel==length(bsval)
%         bsval=bsval(1:length(bsval)-1);
%     else
%         bsval=[bsval(1:kdel-1),bsval(kdel+1:end)];
%     end
%     if length(bsval)~=0
%         outstr=num2str(bsval');
%         set(gui_handle.bspts_lb,'String',outstr,'Value',length(bsval));
%     else
%         set(gui_handle.bspts_lb,'String','no points');
%         set(gui_handle.bsdpnts,'Visible','Off');
%     end
%     plot_data([]);
  
case 'bs_delete'   % delete BS-points  
    bsval=[];
    bs_curve=[];
    set(gui_handle.bspts_lb,'String','no points','Value',1);
    bsappl=0;
    plot_data([]);

case 'bs_method'    
    if size(bsval,1)~=0
        xbs=linspace(1,n_points,n_points);
        if bsappl
            x=linspace(1,n_points,n_points)-pval(3);
            phi=pval(1)/180*pi+pval(2)*x/1000;
            data=data0.*complex(cos(phi),-sin(phi));
            bsappl=0;
        end
        set(gui_handle.bs_poly,'Visible','Off');
        set(gui_handle.bs_pdeg,'Visible','Off');
        switch get(gui_handle.bs_popm,'Value')
        case 1 % poly
            set(gui_handle.bs_poly,'Visible','On');
            set(gui_handle.bs_pdeg,'Visible','On');
            deg=str2num(get(gui_handle.bs_poly,'String'));
            deg=deg(get(gui_handle.bs_poly,'Value'));
            [p,S,mu]=polyfit(bsval,real(data(bsval)),deg);
            baser=[zeros(1,min(bsval)-1) polyval(p,min(bsval):max(bsval),S,mu) zeros(1,length(data)-max(bsval))];
            [p,S,mu]=polyfit(bsval,imag(data(bsval)),deg);
            basei=[zeros(1,min(bsval)-1) polyval(p,min(bsval):max(bsval),S,mu) zeros(1,length(data)-max(bsval))];
            bs_curve=complex(baser,basei);       
        case 2
            method='spline ';
            bs_curve=complex(interp1(bsval,real(data(bsval)),xbs,method),interp1(bsval,imag(data(bsval)),xbs,method));    
        case 3
            method='linear ';
            bs_curve=complex(interp1(bsval,real(data(bsval)),xbs,method),interp1(bsval,imag(data(bsval)),xbs,method));
        case 4
            method='pchip  ';
            bs_curve=complex(interp1(bsval,real(data(bsval)),xbs,method),interp1(bsval,imag(data(bsval)),xbs,method));
        case 5
            method='cubic  ';
            bs_curve=complex(interp1(bsval,real(data(bsval)),xbs,method),interp1(bsval,imag(data(bsval)),xbs,method));
        case 6
            method='v5cubic';
            bs_curve=complex(interp1(bsval,real(data(bsval)),xbs,method),interp1(bsval,imag(data(bsval)),xbs,method));    
        case 7
            method='nearest';
            bs_curve=complex(interp1(bsval,real(data(bsval)),xbs,method),interp1(bsval,imag(data(bsval)),xbs,method));
        end    % switch        
        plot_data([]);
    end    % if
    

case 'bs_apply'
    if length(bs_curve)~=n_points | length(bsval)== 0 %nothing to plot
       errordlg('ERROR: No points selected');
%        break
    else    
        bsappl=1;
        plot_data([]);
        set(gui_handle.bs_active,'String','click to accept BS values','ForegroundColor',[1,0,0],'FontWeight','bold','BackgroundColor',[0.83,0.81,0.78]);
    end
    
case 'btn_down'
    if get(gui_handle.bs_active,'Value')~=0 & get(gui_handle.bs_button,'Value')==1 
        cursor_pos=get(gui_handle.out_win,'CurrentPoint');        
        bsdown=round(cursor_pos(1,1));
        if bsdown<1 bsdown=1; end
        if bsdown>n_points bsdown=n_points; end
    else
        bsdown=0;        
    end
    
case 'btn_up'
    if get(gui_handle.bs_active,'Value')~=0 & bsdown~=0
        cursor_pos=get(gui_handle.out_win,'CurrentPoint');
        bsup=round(cursor_pos(1,1));
        if size(bsval,1)==0
            outstr='';
        else
            outstr=get(gui_handle.bspts_lb,'String');
        end
        if bsup<1 bsup=1; end
        if bsup>n_points bsup=n_points; end
        if bsup >= bsdown            
            bsval=[bsval linspace(bsdown,bsup,bsup-bsdown+1)];
            outstr(size(outstr,1)+1,1:length([num2str(bsdown) ':' num2str(bsup)]))=...
                [num2str(bsdown) ':' num2str(bsup)];            % only works like this
        else
            bsval=[bsval linspace(bsup,bsdown,bsdown-bsup+1)];
            outstr(size(outstr,1)+1,1:length([num2str(bsup) ':' num2str(bsdown)]))=...
                [num2str(bsup) ':' num2str(bsdown)];
        end
        set(gui_handle.bspts_lb,'String',outstr);        
        plot_data([]);
        bsdown=0;
    end   
    
end %of switch

%MOUSE BUTTON CALLBACKS____________________________________________________________________________
function btn_down(obj,eventdata)
PZphasetool('btn_down')

function btn_up(obj,eventdata)
PZphasetool('btn_up')

%CREATE GRAPH______________________________________________________________________________________
function plot_data(varargin)
global data data0 achs pval gui_handle out_var_name n_points bsdown bsval bs_curve bsappl
  newplot(gcf);
  hold on;
  x=linspace(1,n_points,n_points)-pval(3);
  phi=pval(1)/180*pi+pval(2)*x/1000;
  phas_vector=complex(cos(phi),-sin(phi));
  if length(bs_curve)==n_points & bsappl
      data=data0.*phas_vector-bs_curve;
  else  
      data=data0.*phas_vector;
  end
  achs(1)=achs(5)-achs(6)/2;
  achs(2)=achs(5)+achs(6)/2;
  achs(3)=achs(7)-achs(8)/2;
  achs(4)=achs(7)+achs(8)/2;
  if get(gui_handle.line_rb,'Value')==1
     lstyle='-';
  else
     lstyle='none';
  end
  if get(gui_handle.poin_rb,'Value')==1
     mstyle='.';
  else
     mstyle='none';
  end
  if get(gui_handle.real_rb,'Value')        % real part selected
     plot(real(data),'color','b','Linestyle',lstyle,'Marker',mstyle);axis(achs(1:4));   % spectrum  
     plot(pval(3),real(data(pval(3))),'b','Marker','s')                                 % pivot
     if get(gui_handle.bs_active,'Value')==1 & length(bsval)~=0
          plot(bsval,real(data(bsval)),'o','MarkerFaceColor','y','MarkerEdgeColor','none','MarkerSize',5)
     end
     if length(bs_curve)==n_points & get(gui_handle.bs_active,'Value')==1
         plot(real(bs_curve),'m--','LineWidth',2);axis(achs(1:4));
     end
  end
  if get(gui_handle.imag_rb,'Value')==1     % imaginary part selected   
     plot(imag(data),'color','r','Linestyle',lstyle,'Marker',mstyle);axis(achs(1:4));
     plot(pval(3),imag(data(pval(3))),'r','Marker','s')
     if get(gui_handle.bs_active,'Value')==1 & length(bsval)~=0
          plot(bsval,imag(data(bsval)),'o','MarkerFaceColor','y','MarkerEdgeColor','none','MarkerSize',5)
     end
     if length(bs_curve)==n_points & get(gui_handle.bs_active,'Value')==1
         plot(imag(bs_curve),'r--','LineWidth',2);axis(achs(1:4));
     end
  end
  if get(gui_handle.mag_rb,'Value')==1      % magnitude selected
     plot(abs(data),'color','g','Linestyle',lstyle,'Marker',mstyle);axis(achs(1:4));
     plot(pval(3),abs(data(pval(3))),'g','Marker','s')
     if get(gui_handle.bs_active,'Value')==1 & length(bsval)~=0
          plot(bsval,abs(data(bsval)),'o','MarkerFaceColor','y','MarkerEdgeColor','none','MarkerSize',5)
     end
     if length(bs_curve)==n_points & get(gui_handle.bs_active,'Value')==1
         plot(abs(bs_curve),'g--','LineWidth',2);axis(achs(1:4));          
     end
  end
  if get(gui_handle.grid_rb,'Value')==1
     grid on;
  else
     grid off;
  end
  hold off;


  
%INITIAL SETUP______________________________________________________________________________________  
function init_plot(varargin)
global data data0 achs pval gui_handle out_var_name n_points bsdown bsval bs_curve bsappl
    %achs registers the plot (axis+phase) properties
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
    %achs(13)= minimum of PH0
    %achs(14)= maximum of PH0
    %achs(15)= minimum of PH1
    %achs(16)= maximum of PH1  
    achs(1)=1;
    achs(2)=n_points;
    achs(4)=max(abs(data));
    achs(3)=min(real(data));
    if min(imag(data))<achs(3)
        achs(3)=min(imag(data));
    end
    achs(6)=achs(2)-achs(1);
    achs(5)=achs(6)/2;
    achs(8)=achs(4)-achs(3);
    achs(7)=achs(4)-achs(8)/2;
    achs(9) = 1; achs(10) = 1;
    achs(11) = 1; achs(12) = 1;

    
%This creates the GUI, the callbacks and object handles______________________________________________
function MAKEgui(varargin)
global data data0 achs pval gui_handle out_var_name n_points bsdown bsval bs_curve bsappl
   %create figure
   sz=get(0,'ScreenSize');
   gui_handle.phas_fig = figure('Units','pixel','Interruptible','off','Position',[10 sz(4)-580 800 550],...
       'Name','Phase Tool','Tag','phasfig','MenuBar','none','Color',[0.83,0.81,0.78],...
       'WindowButtonDownFcn',@btn_down,'WindowButtonUpFcn',@btn_up);
   set(gui_handle.phas_fig,'BusyAction','queue');
   gui_handle.out_win=axes('Units','pixel','Position',[195 137 552 411]);
   %create static text
   gui_handle.piv_txt=uicontrol('Style','text','Units','pixel','Position',[9,525,55,24],'BackgroundColor',[0.83,0.81,0.78],'FontSize',12,'FontWeight','bold','String','Pivot:');
   gui_handle.ph0_txt=uicontrol('Style','text','Units','pixel','Position',[9,461,60,26],'BackgroundColor',[0.83,0.81,0.78],'FontSize',12,'FontWeight','bold','String','PH0');
   gui_handle.ph1_txt=uicontrol('Style','text','Units','pixel','Position',[95,461,60,26],'BackgroundColor',[0.83,0.81,0.78], 'FontSize',12,'FontWeight','bold','String','PH1');
   gui_handle.id_txt=uicontrol('Style','text','Units','pixel','Position',[270,5,186,14],'BackgroundColor',[0.83,0.81,0.78], 'FontSize',8,'FontWeight','normal','String','(c) 2003 P.Blümler, MPIP');
   gui_handle.bs_txt=uicontrol('Style','text','Units','pixel','Position',[4,80,220,26],'BackgroundColor',[0.83,0.81,0.78], 'FontSize',12,'FontWeight','bold','HorizontalAlignment','left','String','Baseline Correction','Visible','Off');
   gui_handle.bspts_txt=uicontrol('Style','text','Units','pixel','Position',[12,70,80,14],'BackgroundColor',[0.83,0.81,0.78], 'FontSize',8,'FontWeight','normal','String','selected points','Visible','Off');
   gui_handle.meth_txt=uicontrol('Style','text','Units','pixel','Position',[200 70 90 14],'BackgroundColor',[0.83,0.81,0.78], 'FontSize',8,'FontWeight','normal','String','method','Visible','Off');
   gui_handle.bs_mark=uicontrol('Style','text','Units','pixel','Position',[96 58 200 28],'BackgroundColor',[0.83,0.81,0.78], 'FontSize',8,'FontWeight','bold','HorizontalAlignment','left','String','Mark regions for baseline fit!','Visible','Off','ForegroundColor',[1,1,0]);
   gui_handle.bs_pdeg=uicontrol('Style','text','Units','pixel','Position',[300 50 60 15],'BackgroundColor',[0.83,0.81,0.78], 'FontSize',8,'FontWeight','normal','HorizontalAlignment','left','String','degree','Visible','Off','ForegroundColor',[0 0 0]);
   %create editable text
   gui_handle.piv_ed=uicontrol('Style','edit','Units','pixel','Position',[69,526,60,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''piv_value'')','String',pval(3));
   gui_handle.ph0_ed=uicontrol('Style','edit','Units','pixel','Position',[33,289,40,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''ph0_value'')','String',pval(1));
   gui_handle.ph0max_ed=uicontrol('Style','edit','Units','pixel','Position',[33,432,40,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''ph0_max'')','String',achs(14));
   gui_handle.ph0min_ed=uicontrol('Style','edit','Units','pixel','Position',[33,146,40,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''ph0_min'')','String',achs(13));
   gui_handle.ph1_ed=uicontrol('Style','edit','Units','pixel','Position',[116,289,40,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''ph1_value'')','String',pval(2));
   gui_handle.ph1max_ed=uicontrol('Style','edit','Units','pixel','Position',[116,432,40,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''ph1_max'')','String',achs(16));
   gui_handle.ph1min_ed=uicontrol('Style','edit','Units','pixel','Position',[116,146,40,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''ph1_min'')','String',achs(15));
   gui_handle.bspts_lb=uicontrol('Style','listbox','Units','pixel','Position',[12,1,80,69],'BackgroundColor',[0.83,0.81,0.78],'String','no points','Visible','Off');
   %create radiobuttons
   gui_handle.real_rb=uicontrol('Style','radiobutton','Units','pixel','Position',[445,63,80,20],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''realpart'')','Value',1,'ForegroundColor',[0,0,1],'String','real part');
   gui_handle.imag_rb=uicontrol('Style','radiobutton','Units','pixel','Position',[445,45,80,20],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''imagpart'')','Value',0,'ForegroundColor',[1,0,0],'String','imag part');
   gui_handle.mag_rb=uicontrol('Style','radiobutton','Units','pixel','Position',[445,27,80,20],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''magpart'')','Value',0,'ForegroundColor',[0,1,0],'String','magnitude');
   gui_handle.grid_rb=uicontrol('Style','radiobutton','Units','pixel','Position',[557,63,80,20],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''grid_plot'')','Value',1,'String','grid');
   gui_handle.line_rb=uicontrol('Style','radiobutton','Units','pixel','Position',[557,45,80,20],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''line_plot'')','Value',1,'String','lines');
   gui_handle.poin_rb=uicontrol('Style','radiobutton','Units','pixel','Position',[557,27,80,20],'BackgroundColor',[0.83,0.81,0.78],'Callback','PZphasetool(''point_plot'')','Value',0,'String','points');
  %create buttons
   gui_handle.exit_button=uicontrol('Style','Pushbutton','Units','pixel','Position',[729 30 60 38],'Callback','PZphasetool(''done'')','BackgroundColor',[1,0,0],'ForegroundColor',[1,1,1],'FontSize',12,'FontWeight','bold','String','EXIT');
   gui_handle.reset_button=uicontrol('Style','Pushbutton','Units','pixel','Position',[648 30 75 38],'Callback','PZphasetool(''reset_plot'')','BackgroundColor',[0,1,0],'ForegroundColor',[0,0,0],'FontSize',12,'FontWeight','bold','String','RESET');
   gui_handle.pivot_button=uicontrol('Style','Togglebutton','Units','pixel','Position',[13 496 150 28],'Callback','PZphasetool(''pivot_select'')','String','Select manually','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vertdouble_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[770 525 20 20],'Callback','PZphasetool(''vertdouble'')','String','*2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.verthalf_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[770 145 20 20],'Callback','PZphasetool(''verthalf'')','String','/2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.hordouble_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[195 90 20 20],'Callback','PZphasetool(''hordouble'')','String','*2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.horhalf_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[730 90 20 20],'Callback','PZphasetool(''horhalf'')','String','/2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.ph0double_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[116 361 40 22],'Callback','PZphasetool(''ph1double'')','String','*2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.ph0half_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[116 219 40 22],'Callback','PZphasetool(''ph1half'')','String','/2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.ph1double_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[33 361 40 22],'Callback','PZphasetool(''ph0double'')','String','*2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.ph1half_b=uicontrol('Style','Pushbutton','Units','pixel','Position',[33 219 40 22],'Callback','PZphasetool(''ph0half'')','String','/2','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.bs_button=uicontrol('Style','Togglebutton','Units','pixel','Position',[96 42 90 28],'Callback','PZphasetool(''bs_select'')','String','Select points','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.bs_delb=uicontrol('Style','Pushbutton','Units','pixel','Position',[96 1 90 28],'Callback','PZphasetool(''bs_delete'')','String','Delete all','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.bs_apply=uicontrol('Style','Pushbutton','Units','pixel','Position',[200 1 90 28],'Callback','PZphasetool(''bs_apply'')','String','APPLY','Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   %create sliders
   gui_handle.hslider=uicontrol('Style','slider','Units','pixel','Position',[215 90 515 20],'Callback','PZphasetool(''hor_slider'')','sliderstep',achs(9:10),'max',achs(2),'min',achs(1),'Value',achs(5),'BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.vslider=uicontrol('Style','slider','Units','pixel','Position',[770 165 20 360],'Callback','PZphasetool(''ver_slider'')','sliderstep',achs(11:12),'max',achs(4),'min',achs(3),'Value',achs(7),'BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.ph0slider=uicontrol('Style','slider','Units','pixel','Position',[14 146 19 308],'Callback','PZphasetool(''ph0_slider'')','SliderStep',[0.01 1],'Min',achs(13),'Max',achs(14),'Value',pval(1),'BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.ph1slider=uicontrol('Style','slider','Units','pixel','Position',[97 146 19 308],'Callback','PZphasetool(''ph1_slider'')','SliderStep',[0.01 1],'Min',achs(15),'Max',achs(16),'Value',pval(2),'BackgroundColor',[0.83,0.81,0.78]);
   %create popupmenue
   gui_handle.bs_popm=uicontrol('Style','Popupmenu','Units','pixel','Position',[200 1 90 68],'Callback','PZphasetool(''bs_method'')',...
       'String',['poly   ';'spline ';'nearest';'linear ';'pchip  ';'cubic  ';'v5cubic'],'Value',1,'Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   gui_handle.bs_poly=uicontrol('Style','Popupmenu','Units','pixel','Position',[340 1 40 68],'Callback','PZphasetool(''bs_method'')',...
       'String',['1 ';'2 ';'3 ';'4 ';'5 ';'6 ';'8 ';'9 ';'10';'12';'14';'16'],'Value',5,'Visible','Off','BackgroundColor',[0.83,0.81,0.78]);
   if length(bs_curve)==n_points %baseline already exists   
       gui_handle.bs_active=uicontrol('Style','checkbox','Units','pixel','Position',[4,110,220,26],'Callback','PZphasetool(''bs_active'')','Value',0,'ForegroundColor',[0,0.6,0],'FontWeight','bold','String','click to change BS values','BackgroundColor',[0.83,0.81,0.78]);
   else
       gui_handle.bs_active=uicontrol('Style','checkbox','Units','pixel','Position',[4,110,220,26],'Callback','PZphasetool(''bs_active'')','Value',0,'String','activate Baseline Correction','BackgroundColor',[0.83,0.81,0.78]);
   end
