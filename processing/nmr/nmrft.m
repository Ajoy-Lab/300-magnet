%############################################################################
%#
%#                          function NMRFT
%#
%#      does the NMR specific FFT on 3D-data (icluding zero-filling and shift   
%#      of zero-frequency to center). For correct phase, the data has to start
%#      at the left (FID type)...point 1 = time 0.
%#      The optional dimension parameter controls the size after the FT. If chosen
%#      bigger than the original, zero-filling is applied, if not specified the size
%#      is kept the same, if smaller the data is truncated.
%#
%#      usage: ftdata=nmrft(data,dims);
%#    
%#             data = data to do the FFT on
%#             dims = [OPTIONAL] resulting size after 
%#                    (if bigger than original, zero-filling is applied) 
%#             type = [OPTINOAL] = 'e' or 'f' 
%#                    'e' is filling zeros symmetrically around the center
%#                    as typical for echo-data (default)
%#                    'f' is filling zeros at the right end as typical for
%#                    FID-data
%#
%#      (c) P. Blümler 10/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 23/10/03    (please change this when code is altered)
%  version 2.0 PB 12/08/05   (added zerofilling because MATLAB made faults)
%----------------------------------------------------------------------------

function result=nmrft(data,n,type)
data=squeeze(data);
switch nargin
    case 0
       disp('ERROR: you called the NMRFT routine without data to transform!');
    case 1
        n=size(data);
        type='e';
    case 2
        type='e';
end
type=lower(type);
if (type ~= 'f') & (type ~= 'e') 
    disp('WARNING: you called the NMRFT routine with unknown type, type set to default');
end
ds=size(data);

%zero filling
switch dimension(data)
    case 1
        n=[1,n];
        zd=zeros(1,n(2));
        if type == 'e'
          zd((n(2)-ds(2))/2+1:(n(2)+ds(2))/2)=data;
          %zd((n(2)-ds(2))/2+1:(n(2)+ds(2))/2)=data;  
        else
          zd(1:ds(2))=data;            
        end
    case 2
        zd=zeros(n(1),n(2));
        if type == 'e'
          zd((n(1)-ds(1))/2+1:(n(1)+ds(1))/2, (n(2)-ds(2))/2+1:(n(2)+ds(2))/2)=data;            
        else
          zd(1:ds(1), 1:ds(2))=data;            
        end
    case 3
        zd=zeros(n(1),n(2),n(3));
        if type == 'e'
          zd((n(1)-ds(1))/2+1:(n(1)+ds(1))/2, (n(2)-ds(2))/2+1:(n(2)+ds(2))/2, (n(3)-ds(3))/2+1:(n(3)+ds(3))/2)=data;            
        else
          zd(1:ds(1), 1:ds(2), 1:ds(3))=data;            
        end
end
switch dimension(data)
case 1
    result=fftshift(fft(zd));
case 2
    result=fftshift(fft2(zd));
otherwise
    result=fftshift(fftn(data));
end

