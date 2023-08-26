%############################################################################
%#
%#                          function GETPPM
%#
%#      generates a ppm-scale from a BRUKER procs-file  
%#
%#      usage: ppm=getppm('procs');
%#    
%#    
%#      (c) P. Blümler 2/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 17/2/03    (please change this when code is altered)
%----------------------------------------------------------------------------

function ppmscale=getppm(file);

if exist(file)==0
    disp('ERROR: File does not exist');
    return
end
head0=textread(file,'%s');
sf=str2num(char(head0(strmatch('##$SF=',head0')+1)));
sw=str2num(char(head0(strmatch('##$SW_p=',head0')+1)));
os=str2num(char(head0(strmatch('##$OFFSET=',head0')+1)));
np=str2num(char(head0(strmatch('##$SI=',head0')+1)));

ppmscale=os-[1:np]/np/sf*sw;
