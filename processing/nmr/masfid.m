
function masfid(indata)
global gui_handle spect par fid time ppm

if (nargin == 0) | ~isstr(indata) 
    action = 'start';
else
    action = indata;
end

%MAIN ACTION SWITCH (actions are the callbacks for function 'masfid' defined in MAKEgui
switch action
case 'start'   %initiallizing
    par=[300,500,0,5,2048,100,4000];
    %the parameter vector is defined as
    %par(1) the Larmor frequency in MHz
    %par(2) the spectral width in ppm
    %par(3) the offset in ppm
    %par(4) the rotation frequency in kHz
    %par(5) the number of points
    %par(6) the number of scans
    %par(7) the carrier frequency for the audio output
    MAKEgui(' ');
    make_spectrum(' ');
    plot_spectrum(' ');
    

case 'par1'
    par(1)=str2num(get(gui_handle.par1,'String'));
    make_spectrum(' ');
    plot_spectrum(' ');
case 'par2'
    par(2)=str2num(get(gui_handle.par2,'String'));
    make_spectrum(' ');
    plot_spectrum(' ');
case 'par3'
    par(3)=str2num(get(gui_handle.par3,'String'));
    make_spectrum(' ');
    plot_spectrum(' ');
case 'par4'
    par(4)=str2num(get(gui_handle.par4,'String'));
    make_spectrum(' ');
    plot_spectrum(' ');
case 'par5'
    par(5)=str2num(get(gui_handle.par5,'String'));
    make_spectrum(' ');
    plot_spectrum(' ');
case 'par6'
    par(6)=str2num(get(gui_handle.par6,'String'));
    make_spectrum(' ');
    plot_spectrum(' ');
case 'par7'
    par(7)=str2num(get(gui_handle.par7,'String'));
    make_spectrum(' ');
    plot_spectrum(' ');

case 'substance'
    make_spectrum(' ');
    plot_spectrum(' ');
    
case 'audio'
    par(7)=str2num(get(gui_handle.par7,'String'));
    soundsc(fid,par(7))
    
case 'done'
    close(gcbf);
    return    
    
end %of switch


function make_spectrum(varargin)
global gui_handle spect par fid time ppm
    par(1)=str2num(get(gui_handle.par1,'String'));
    par(2)=str2num(get(gui_handle.par2,'String'));
    par(3)=str2num(get(gui_handle.par3,'String'));
    par(4)=str2num(get(gui_handle.par4,'String'));
    par(5)=str2num(get(gui_handle.par5,'String'));
    par(6)=str2num(get(gui_handle.par6,'String'));
    w0=par(1); %convert to readable units
    sw=par(2);
    o1=par(3);
    wr=par(4);
    n=par(5);
    ns=par(6);
    switch get(gui_handle.subst,'Value')
    case 1  %PE
        cs=[1.25];              %ppm
        amp=[8];                %ratio
        lw=40;                  %kHz
    case 2  %PMMA
        cs=[0.95,1.845,3.625];  %ppm
        amp=[3,2,3];            %ratio
        lw=35;                  %kHz
    case 3  %PS
        cs=[1.5,1.95,6.5,7.5];  %ppm
        amp=[2,1,2,3];          %ratio
        lw=40;                  %kHz
    case 4  %PC
        cs=[1.68,7.1,7.3];      %ppm
        amp=[3,2,2];            %ratio
        lw=20;                  %kHz
    case 5  %PAS
        cs=[1.7,2.5,11.2];      %ppm
        amp=[4,2,2];            %ratio
        lw=40;                  %kHz
    case 6  %PB
        cs=[2.1,5.44];          %ppm
        amp=[4,2];              %ratio
        lw=5;                   %kHz
    case 7  %PI
        cs=[1.75,2.15,2.3,5.2]; %ppm
        amp=[3,2,2,1];          %ratio
        lw=3;                   %kHz
     end
     
     %calc spectrum
     ppm=linspace(o1-sw/2,o1+sw/2,n);
     index=round(n/sw*(cs-o1+sw/2));
     index=mod(index,n);
     spect=zeros(1,n);
     for t=1:length(cs)
        spect(index(t))=amp(t);
     end
     lw=lw/w0*1e3;
     x=linspace(-sw/2,sw/2,n);
     y=fftshift(exp(-x.^2/(lw^2/log(2)/4)));
     spec0=abs(ifft(fft(spect).*fft(y)));
     li=0.0286*lw^2/wr*w0*1e-3;
     y=fftshift(exp(-x.^2/(li^2/log(2)/4)));
     rs=round(wr*1e3/w0*n/sw);
     rspec=zeros(1,n);
     rspec(1)=1;
     rspec(2:rs:n)=1;
     spect=abs(ifft(fft(spect).*fft(rspec).*fft(y))).*spec0+randn(1,n)/sqrt(ns)*10;
     time=linspace(0,1e-3/sw/w0,2*n);
     fid=real(fft(spect,n*2));
     time=time(1:n/2);
     fid=fid(1:n/2);

    
function plot_spectrum(varargin)
global gui_handle spect par fid time ppm
 
  axes(gui_handle.out_pulse);
  newplot(gca);
  plot(ppm,spect,'k-');
  axis tight;
  axes(gui_handle.out_fft);
  newplot(gca);
  plot(time,fid,'r-');
  axis tight;

%This creates the GUI, the callbacks and object handles______________________________________________
function MAKEgui(varargin)
global gui_handle spect par fid time ppm
   %create figure
   sz=get(0,'ScreenSize');
   gui_handle.phas_fig = figure('Units','pixel','Position',[10 sz(4)-580 800 550],'Name','Spektren Simulation','Tag','mainfig','MenuBar','none','Color',[0.83,0.81,0.78]);
   set(gui_handle.phas_fig,'BusyAction','queue');
   gui_handle.out_pulse=axes('Units','pixel','Position',[195 320 600 200]);
   gui_handle.out_fft=axes('Units','pixel','Position',[195 50 600 200]);
   %create static text
   gui_handle.title=uicontrol('Style','text','Units','pixel','Position',[10,500,120,34], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',12,'HorizontalAlignment','left','FontWeight','bold','String','NMR Spektren');
   gui_handle.wtitl1=uicontrol('Style','text','Units','pixel','Position',[195,525,200,18], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',10,'HorizontalAlignment','center','FontWeight','bold','String','NMR-Spektrum');
   gui_handle.wtitl2=uicontrol('Style','text','Units','pixel','Position',[195,255,200,18], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',10,'HorizontalAlignment','center','FontWeight','bold','String','Zeitsignal (FID)');
   gui_handle.id_txt=uicontrol('Style','text','Units','pixel','Position',[270,5,186,14], 'FontSize',8,'FontWeight','normal','String','(c) 2003 P.Blümler, MPI-P');
   gui_handle.ptyp=uicontrol('Style','text','Units','pixel','Position',[10,453,120,34], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',10,'HorizontalAlignment','center','FontWeight','bold','String','Substanz');
   gui_handle.par1_txt=uicontrol('Style','text','Units','pixel','Position',[10,400,120,34], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'HorizontalAlignment','center','FontWeight','normal','String','NMR-Frequenz [MHz]');
   gui_handle.par1=uicontrol('Style','edit','Units','pixel','Position',[10,395,120,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','masfid(''par1'')','String','300');
   gui_handle.par2_txt=uicontrol('Style','text','Units','pixel','Position',[10,350,120,34], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'HorizontalAlignment','center','FontWeight','normal','String','Spektrale Weite [ppm]');
   gui_handle.par2=uicontrol('Style','edit','Units','pixel','Position',[10,345,120,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','masfid(''par2'')','String','500');
   gui_handle.par3_txt=uicontrol('Style','text','Units','pixel','Position',[10,300,120,34], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'HorizontalAlignment','center','FontWeight','normal','String','Offset [ppm]');
   gui_handle.par3=uicontrol('Style','edit','Units','pixel','Position',[10,295,120,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','masfid(''par3'')','String','0');
   gui_handle.par4_txt=uicontrol('Style','text','Units','pixel','Position',[10,250,120,34], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'HorizontalAlignment','center','FontWeight','normal','String','MAS Frequenz [kHz]');
   gui_handle.par4=uicontrol('Style','edit','Units','pixel','Position',[10,245,120,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','masfid(''par4'')','String','5');
   gui_handle.par5_txt=uicontrol('Style','text','Units','pixel','Position',[10,200,120,34], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'HorizontalAlignment','center','FontWeight','normal','String','Anzahl der Punkte');
   gui_handle.par5=uicontrol('Style','edit','Units','pixel','Position',[10,195,120,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','masfid(''par5'')','String','2048');
   gui_handle.par6_txt=uicontrol('Style','text','Units','pixel','Position',[10,150,120,34], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'HorizontalAlignment','center','FontWeight','normal','String','Anzahl der Experimente');
   gui_handle.par6=uicontrol('Style','edit','Units','pixel','Position',[10,145,120,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','masfid(''par6'')','String','100');
   gui_handle.par7_txt=uicontrol('Style','text','Units','pixel','Position',[10,100,120,34], 'BackgroundColor',[0.83,0.81,0.78],'FontSize',8,'HorizontalAlignment','center','FontWeight','normal','String','Audio Frequenz [Hz]');
   gui_handle.par7=uicontrol('Style','edit','Units','pixel','Position',[10,95,120,22],'BackgroundColor',[0.83,0.81,0.78],'Callback','masfid(''par7'')','String','4000');

   %create buttons
   gui_handle.exit_button=uicontrol('Style','Pushbutton','Units','pixel','Position',[80 30 60 38],'Callback','masfid(''done'')','BackgroundColor',[1,0,0],'ForegroundColor',[1,1,1],'FontSize',12,'FontWeight','bold','String','EXIT');
   gui_handle.audio=uicontrol('Style','Pushbutton','Units','pixel','Position',[10 30 60 38],'Callback','masfid(''audio'')','BackgroundColor',[0.83,0.81,0.78],'FontSize',12,'FontWeight','bold','String','Audio');
   gui_handle.subst=uicontrol('Style','Popupmenu','Units','pixel','Position',[10 400 120 68],'Callback','masfid(''substance'')',...
       'String',{'Polyethylen' 'Polymethylmethacrylat' 'Polystyrol' 'Polycarbonat' 'Polyacrylsäure' 'Polybutadien' 'Polyisopren'},'BackgroundColor',[0.83,0.81,0.78]);
 
   