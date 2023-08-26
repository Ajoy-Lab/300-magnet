%############################################################################
%#
%#                           function READ_SIEMENS
%#
%#      reads in data stored in the IMA-format as used by SIEMENS MRI-Scanners
%#
%#      usage: data=read_siemens(filename, flag);
%#
%#      optional parameters:
%#
%#          filename = name of file to be read in, if not specified an input
%#                     box appears for manual selection
%#              flag = plot flag. If = 0 no output is generated, default and 
%#                     else the image is shown
%#
%#      (c) P. Blümler 09/04
%############################################################################
%----------------------------------------------------------------------------
%  version 1.1 PB 1/9/04    (please change this when code is altered)
%----------------------------------------------------------------------------
function data=read_siemens(varargin)
if nargin~=0
  [s,d]=size(varargin); 
  if exist(varargin{:,1},'file')==2
     fname = varargin{:,1};
  else
      disp('ERROR: file not found..please select now!');  
      [filename,dirname]=uigetfile('*.*','Open IMA file');
      fname=[dirname,filename];
      cd(dirname);
  end
  if d>1
      flag=varargin{:,2};
  else
      flag =1;
  end
else
  [filename,dirname]=uigetfile('*.*','Open IMA file');
  fname=[dirname,filename];
  cd(dirname);
end

fid = fopen(fname,'r','b');
header=fread(fid,6144,'int8', 'ieee-le');
%header=fread(fid,28640,'int8', 'ieee-le');
%fseek(fid, 6144, 'bof');
data=fread(fid,'int16', 'b');
fclose(fid);

[fsize,c]=size(data);
if fsize == 256*256
   data=reshape(data,256,256);
   imagesc(data);
   colormap gray
   axis equal
   axis off
end
%dim=fsize/8;
%aw_data=reshape(raw_data,dim,8);
%data=zeros(dim,1);
%byte_vex=0:8:7*8;
%byte_vex=7*8:-8:0;
%byte_vex=2.^byte_vex;
%for t=1:dim
%    data(t)=sum(raw_data(t,:).*byte_vex);
%end
%real_d=zeros(dim/2,1);
%imag_d=zeros(dim/2,1);
%for t=1:dim/2
%    real_d(t)=data(t*2-1);
%    imag_d(t)=data(t*2);
%end
%data=complex(real_d,imag_d);
%plot(real_d,'r')
%oplot(imag_d,'g')
%data=data(3521:end);
%xdim=128;
%ydim=512;
%data=reshape(data,xdim,ydim);
%if flag ~=0
%   imagesc(data);colormap gray;axis equal;axis off
%end