
%############################################################################
%#
%#                           function READACQU
%#
%#      reads parameters from the 'acqus'-file in the specified directory
%#      into a structure.
%#      takes name of the directory as input argument and returns the structure
%#
%#      usage: acqu = readacqu(dirname);
%#
%#      if no input argument is given a file open Dialog is displayed
%#      
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 AH 6/1/03    (please change this when code is altered)
%--------------------------------------------------------------------------
function acqu = readacqu(dirname)
if nargin==0
    [fname,pname] = uigetfile('*.*', 'Open 1r data set');
    if pname
        dirname = pname;
    else
        return
    end    
end
if exist(dirname)==2
   [path,name,ext,ver] = fileparts(dirname);
   dirname = path;
   if ~strcmp(name,'acqus')
       display('specified file is not an acqus file, the acqus file in the same directory is read instead')
   end    
end
acqu.error=0;
if exist([dirname,filesep,'acqus'])==2 
    
    head0=textread([dirname,filesep,'acqus'],'%s');
    n = 2:33;
    
    position = strmatch('$$',head0');
    acqu.file       = char(head0(position(2)+1));
    
    acqu.aq_mod     = str2num(char(head0(strmatch('##$AQ_mod=',head0')+1)));
    acqu.bytorda    = str2num(char(head0(strmatch('##$BYTORDA=',head0')+1)));
    acqu.cnst       = str2num(char(head0(strmatch('##$CNST=',head0')+n)));       
    acqu.d          = str2num(char(head0(strmatch('##$D=',head0')+n))); 
    acqu.de         = str2num(char(head0(strmatch('##$DE=',head0')+1)));
    acqu.decim      = str2num(char(head0(strmatch('##$DECIM=',head0')+1)));
    acqu.digmod     = str2num(char(head0(strmatch('##$DIGMOD=',head0')+1)));
    acqu.ds         = str2num(char(head0(strmatch('##$DS=',head0')+1)));
    acqu.dspfvs     = str2num(char(head0(strmatch('##$DSPFVS=',head0')+1)));
    acqu.fw         = str2num(char(head0(strmatch('##$FW=',head0')+1)));
    acqu.gpx        = str2num(char(head0(strmatch('##$GPX=',head0')+n))); 
    acqu.gpy        = str2num(char(head0(strmatch('##$GPY=',head0')+n)));
    acqu.gpz        = str2num(char(head0(strmatch('##$GPZ=',head0')+n)));
    acqu.in         = str2num(char(head0(strmatch('##$IN=',head0')+n)));
    acqu.inp        = str2num(char(head0(strmatch('##$INP=',head0')+n)));
    acqu.l          = str2num(char(head0(strmatch('##$L=',head0')+n)));
    acqu.nbl        = str2num(char(head0(strmatch('##$NBL=',head0')+1)));
    acqu.ns         = str2num(char(head0(strmatch('##$NS=',head0')+1)));
    acqu.o1         = str2num(char(head0(strmatch('##$O1=',head0')+1)));
    acqu.parmode    = str2num(char(head0(strmatch('##$PARMODE=',head0')+1)));
    acqu.pl         = str2num(char(head0(strmatch('##$PL=',head0')+n)));
    acqu.l          = str2num(char(head0(strmatch('##$L=',head0')+n)));
    acqu.pulprog    = char(head0(strmatch('##$PULPROG=',head0')+1));
        acqu.pulprog = acqu.pulprog(2:(end-1));
    acqu.rg         = str2num(char(head0(strmatch('##$RG=',head0')+1)));
    acqu.sfo1       = str2num(char(head0(strmatch('##$SFO1=',head0')+1)));
    acqu.sw         = str2num(char(head0(strmatch('##$SW=',head0')+1)));
    acqu.sw_h       = str2num(char(head0(strmatch('##$SW_h=',head0')+1)));
    acqu.td         = str2num(char(head0(strmatch('##$TD=',head0')+1)))/2;
        acqu.td(2) = 1;
        acqu.td(3) = 1;
        acqu.td(4) = 1;
    acqu.te         = str2num(char(head0(strmatch('##$TE=',head0')+1)));
    acqu.vdlist    = char(head0(strmatch('##$VDLIST=',head0')+1));
        acqu.vdlist = acqu.vdlist(2:(end-1));
    acqu.vplist    = char(head0(strmatch('##$VPLIST=',head0')+1));
        acqu.vplist = acqu.vplist(2:(end-1));
    acqu.vtlist    = char(head0(strmatch('##$VTLIST=',head0')+1));
        acqu.vtlist = acqu.vtlist(2:(end-1));
 
       
else
    display('ERROR: Could not find "acqus" in');
    disp(dirname);
    acqu.error=1;
end

if acqu.parmode > 0 % 2 or more dimensional
    if exist([dirname,filesep,'acqu2s'])==2 
		
		head0=textread([dirname,filesep,'acqu2s'],'%s');

		acqu.sw(2)         = str2num(char(head0(strmatch('##$SW=',head0')+1)));
		acqu.sw_h(2)       = str2num(char(head0(strmatch('##$SW_h=',head0')+1)));
		acqu.td(2)         = str2num(char(head0(strmatch('##$TD=',head0')+1)));
	    
        if acqu.parmode > 1 % 3 or more dimensional
          if exist([dirname,filesep,'acqu3s'])==2 
		    head0=textread([dirname,filesep,'acqu3s'],'%s');
		    acqu.sw(3)         = str2num(char(head0(strmatch('##$SW=',head0')+1)));
		    acqu.sw_h(3)       = str2num(char(head0(strmatch('##$SW_h=',head0')+1)));
		    acqu.td(3)         = str2num(char(head0(strmatch('##$TD=',head0')+1)));           
         
            if acqu.parmode > 2 % 4 or more dimensional
                if exist([dirname,filesep,'acqu4s'])==2 
			    head0=textread([dirname,filesep,'acqu4s'],'%s');
			    acqu.sw(4)         = str2num(char(head0(strmatch('##$SW=',head0')+1)));
			    acqu.sw_h(4)       = str2num(char(head0(strmatch('##$SW_h=',head0')+1)));
			    acqu.td(4)         = str2num(char(head0(strmatch('##$TD=',head0')+1)));
              else
		        disp('ERROR: Could not find "acqu4s" in');
                disp(dirname);
                acqu.error=1;
              end  
            end		  
           
          else
	        disp('ERROR: Could not find "acqu3s" in');
            disp(dirname);
            acqu.error=1;
          end  
        end		  
    else
        disp('ERROR: Could not find "acqu2s" in');
        disp(dirname);
        acqu.error=1;
    end
end    
    
