%############################################################################
%#
%#                           function readbruker
%#
%#      reads brukers data into a structure.
%#      
%#      
%#       
%#
%#      usage: datastruc=readbruker(filename,n1,n2,...);
%#             
%#             if no arguments are given the programm launches a file open dialog
%#
%#             filename: (optional) can either be the name of a file or a directory.
%#                       if a diectory is given the programm looks for a fid o ser
%#                       file in that directory
%#             n1...n3 = (optional) dimensions 
%#
%#
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 AH 13/2/03    (please change this when code is altered)
%----------------------------------------------------------------------------

function result=readbruker(direc,n1,n2,n3)
if nargin==0
    [fname,pname] = uigetfile('*.*', 'Open Bruker fid/ser file');
    direc = [pname fname];
    if ~direc
        return
    end    
end
switch exist(direc) %direc must be a file or a directory containing fid or ser. 
    case(7)    %direc is the directory
        if exist([direc,filesep,'ser'])==2 %the file ser exists in the directory
            dfile=[direc,filesep,'ser'];
        elseif exist([direc,filesep,'fid'])==2 %the file fid exists in the directory
            dfile=[direc,filesep,'fid'];
        else
            disp('ERROR: could not find "ser" or fid" in the specified directory...');
            disp('...please select now!"');
            cd(direc)
            [fname,pname] = uigetfile('*.*', 'Open Bruker fid/ser file');
            dfile = [pname fname];
            if ~dfile
                return
            end             
        end   
    case(2) %direc is file
        dfile=direc;
    otherwise
       disp('ERROR: file or directory not found...');
       disp('...please select now!');
       [fname,pname] = uigetfile('*.*', 'Open Bruker fid/ser file');
       dfile = [pname fname];
       if ~dfile
            return
       end    
end

[path,name,ext,ver]= fileparts(dfile);

while ~(strcmp(name, 'fid') | strcmp(name, 'ser'))
    disp('ERROR: file is not fid/ser file...');
    disp('...please select now!');
    cd(path)
    [fname,pname] = uigetfile('*.*', 'Open Bruker fid/ser file');
    dfile = [pname fname];
    [path,name,ext,ver]= fileparts(dfile);
     if ~dfile
          return
     end    
end    

acqs = readacqu(path); % read acquisition parameters
if (acqs.error)
    disp('ERROR while reading Aquisition Parameters')
    return
end

if nargin < 2
    dim=acqs.parmode +1;
    disp(['Data is ',num2str(dim),'-dimensional']);   
    disp(['Dimension 1: ',num2str(acqs.td(1))]);
    disp(['Dimension 2: ',num2str(acqs.td(2))]);
    disp(['Dimension 3: ',num2str(acqs.td(3))]);
    disp(['Dimension 4: ',num2str(acqs.td(4))]);
end

%reading offset from proc files if possible:
if(exist([path,filesep,'pdata',filesep, '1',filesep,'procs'])==2)
    head0=textread([path,filesep,'pdata',filesep, '1',filesep,'procs'],'%s');
    os1=str2num(char(head0(strmatch('##$OFFSET=',head0')+1)));
else
    os1=acqs.sw(1)/2;
end
result.os(1) = os1;
result.ppm_axis1 = os1 - acqs.sw(1) + acqs.sw(1)*[1:(acqs.td(1))]/(acqs.td(1));
result.sw_axis1 = result.ppm_axis1*acqs.sfo1;
result.time = [0:(acqs.td(1)-1)]/acqs.sw_h(1);

if acqs.parmode>0
  if(exist([path,filesep,'pdata',filesep, '1',filesep,'proc2s'])==2)
    head0=textread([path,filesep,'pdata',filesep, '1',filesep,'proc2s'],'%s');
    os2=str2num(char(head0(strmatch('##$OFFSET=',head0')+1)));
  else
    os2=acqs.sw(2)/2;
  end
  result.os(2)=os2;
  result.ppm_axis2 =  os2 - acqs.sw(2)+acqs.sw(2)*[1:(acqs.td(2))]/(acqs.td(2));
  result.sw_axis2 = result.ppm_axis2*acqs.sfo1;
  
end 

if acqs.parmode>1
  if(exist([path,filesep,'pdata',filesep, '1',filesep,'proc3s'])==2)
    head0=textread([path,filesep,'pdata',filesep, '1',filesep,'proc3s'],'%s');
    os3=str2num(char(head0(strmatch('##$OFFSET=',head0')+1)));
  else
    os3=acqs.sw(3)/2;
  end 
  result.os(3)
  result.ppm_axis3 = os3 - acqs.sw(3)+acqs.sw(3)*[1:(acqs.td(3))]/(acqs.td(3));
  result.sw_axis3 = result.ppm_axis3*acqs.sfo1;
  
end 

if acqs.parmode>2
   if(exist([path,filesep,'pdata',filesep, '1',filesep,'proc4s'])==2)
    head0=textread([path,filesep,'pdata',filesep, '1',filesep,'proc4s'],'%s');
    os4=str2num(char(head0(strmatch('##$OFFSET=',head0')+1)));
  else
    os4=acqs.sw(4)/2;
  end 
  result.os(4)=os4;
  result.ppm_axis4 = os4 - acqs.sw(4) + acqs.sw(4)*[1:(acqs.td(4))]/(acqs.td(4));
  result.sw_axis4 = result.ppm_axis4*acqs.sfo1;
  
end 


result.spec_type = 'BRUK';
result.acq = acqs;
result.odata = readcomplex(dfile, result.acq.td(1), result.acq.td(2), result.acq.td(3));
result.data = result.odata;
cdate=clock;
time_tag=[num2str(cdate(3)),'.',num2str(cdate(2)),'.',num2str(cdate(1)),' # ',num2str(cdate(4)),':',num2str(cdate(5))];
result.history = ['data read @ ',time_tag];


cd(path)
