%############################################################################
%#
%#                          function STRETCH
%#
%#      interpolates data (up to 3D) to smaller and bigger sizes. 
%#
%#      usage: intdata=stretch(data,dims,method);
%#    
%#             data = data to interpolate   
%#             dims = vector with new dimensions (missing dimensions are set to
%#                    that of the original -- no interpolation)
%#             method = OPTIONAL see interp1-3 help files (default is linear)
%#    
%#      (c) P. Blümler 1/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.1 PB 21/1/03    (please change this when code is altered)
%----------------------------------------------------------------------------


function result=stretch(data,dims,method)
data=squeeze(data);
switch nargin
case 1, dims=size(data);
        method='linear';
case 2, method='linear';
end

dim=dimension(data);
switch dim
case 1, x=[1:length(data)];
        xi=linspace(1,length(data),dims(1));
        result=interp1(x,data,xi,method);
case 2, [nx,ny]=size(data);
        if length(dims)==1
            dims(2)=ny;
        end
        [x,y]=meshgrid([1:ny],[1:nx]);
        [xi,yi]=meshgrid(linspace(1,ny,dims(2)),linspace(1,nx,dims(1)));
        result=interp2(x,y,data,xi,yi,method);
case 3, [nx,ny,nz]=size(data);
        if length(dims)==1
            dims(2)=ny;
            dims(3)=nz;
        elseif length(dims)==2
            dims(3)=nz;
        end
        [x,y,z]=meshgrid([1:ny],[1:nx],[1:nz]); %MATLAB bug ought to be nx,ny,nz        
        [xi,yi,zi]=meshgrid(linspace(1,nx,dims(1)),linspace(1,ny,dims(2)),linspace(1,nz,dims(3)));
        result=interp3(x,y,z,data,xi,yi,zi,method);
                
        
end