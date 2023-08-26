%############################################################################
%#
%#                           function READCOMPLEX
%#
%#      reads in data as max. 4D complex arrays from typical BRUKER SER or FID files.
%#      If dimensions (n(1)...n(4)) are specified, the routine generates according dimensions.
%#      If the product of dimensions is smaller than the data length, the routine tries to
%#      estimate/generate the next higher dimension. Hence, if nothing but the filename 
%#      is specified the data are read in as 1D.
%#
%#      usage: data=readcomplex(filename,n(1),n(2),...);
%#             filename = optional, browser opens if nothing is specified
%#             n(1)...n(4) = optional dimensions (estimated from data length if not present)
%#
%#      (c) P. Blümler 10/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.2 PB 25/10/03    added browser mode
%----------------------------------------------------------------------------


function data=readcomplex(varargin)

if nargin~=0
  if exist(varargin{1},'file')==2
     infile = varargin{1};
  else
      disp('ERROR: file not found..please select now!');  
      [filename,dirname]=uigetfile('*.*','Open file');
      infile=[dirname,filename];
      cd dirname;
  end
else
  [filename,dirname]=uigetfile('*.*','Open file');
  infile=[dirname,filename];
  cd(dirname);
end

n=[varargin{2:end}];

fid=fopen(infile,'r','b');
data=fread(fid,'int32');
fclose(fid);
[fsize,c]=size(data);
data=reshape(data,2,(fsize/2)+0.5);
data=complex(data(1,:),data(2,:));
if length(n)==0
    n=ones(4,1);
    n(1)=fsize/2;
end
if length(n)==1
    n(2)=round(fsize/2/n(1));
end 
if length(n)==2
    n(3)=round(fsize/2/n(1)/n(2));
end
n(4)=round(fsize/2/n(1)/n(2)/n(3)); 
if prod(n)~= fsize/2
    disp('RESET to 1D: something wrong with dimensions!');
    n(1)=fsize/2; n(2)=1; n(3)=1; n(4)=1;
end
if n(4) ~= 1
    disp(['Reading data as 4D complex: Size ',num2str(n(1)),' x ',num2str(n(2)),' x ',num2str(n(3)),' x ',num2str(n(4)),' points']);
elseif n(3) ~= 1
    disp(['Reading data as 3D complex: Size ',num2str(n(1)),' x ',num2str(n(2)),' x ',num2str(n(3)),' points']);
elseif n(2) ~= 1
    disp(['Reading data as 2D complex: Size ',num2str(n(1)),' x ',num2str(n(2)),' points']);
elseif n(1) == fsize/2
    disp(['Reading data as 1D complex: Size ',num2str(n(1)),' points']);
end
data=reshape(data,n(1),n(2),n(3),n(4));
data=squeeze(data);
