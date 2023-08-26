%############################################################################
%#
%#                           function READREAL
%#
%#      reads in data as max. 4D real arrays from typical BRUKER process files.
%#      If dimensions (n1...n4) are specified, the routine generates according dimensions.
%#      If the product of dimensions is smaller than the data length, the routine tries to
%#      estimate/generate the next higher dimension. Hence, if nothing but the filename 
%#      is specified the data are read in as 1D.
%#
%#      usage: data=readreal(filename,n1,n2,...);
%#
%#             n1...n4 = optional dimensions (estimated from data length if not present)
%#      (c) P. Blümler 2/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 3/2/03    (please change this when code is altered)
%----------------------------------------------------------------------------


function data=readreal(infile,n1,n2,n3)
    
fid=fopen(infile,'r','b');
if fid==-1
    disp('ERROR: file not found');
    data=[];
    return
end
data=fread(fid,'int32');
fclose(fid);
[fsize,c]=size(data);
if exist('n1')==0
    n1=fsize;
end
if exist('n2')==0
    n2=round(fsize/n1);
end 
if exist('n3')==0
    n3=round(fsize/n1/n2);
end
n4=round(fsize/n1/n2/n3); 
if n1*n2*n3*n4 ~= fsize
    disp('RESET to 1D: something wrong with dimensions!');
    n1=fsize; n2=1; n3=1; n4=1;
end
if n4 ~= 1
    disp(['Reading data as 4D real: Size ',num2str(n1),' x ',num2str(n2),' x ',num2str(n3),' x ',num2str(n4),' points']);
elseif n3 ~= 1
    disp(['Reading data as 3D real: Size ',num2str(n1),' x ',num2str(n2),' x ',num2str(n3),' points']);
elseif n2 ~= 1
    disp(['Reading data as 2D real: Size ',num2str(n1),' x ',num2str(n2),' points']);
elseif n1 == fsize
    disp(['Reading data as 1D real: Size ',num2str(n1),' points']);
end
data=reshape(data,n1,n2,n3,n4);
data=squeeze(data);
