%############################################################################
%#
%#                           function TPPI_FT
%#
%#      generates FT of sequential acquired complex data (Redfield-FT).
%#      data must be complex and acquired Re(t),Im(2t),Re(3t),Im(4t),..
%#      data must be one-dimensional
%#
%#      usage: ftdata=tppi_ft(data);
%#
%#
%#      (c) P. Blümler 12/02
%############################################################################
%----------------------------------------------------------------------------
%  version 1.3 PB 21/1/03    (included dimension, incl. length n!!!)
%----------------------------------------------------------------------------




function result=tppi_ft(data)

data=squeeze(data);
dim=dimension(data);

if dim ~= 1
    errordlg('ERROR: data input array is NOT ONEDIMENSIONAL!');
    return
end
n=length(data);
data(1)=data(1)/2;
v1=complex(zeros(2*n,1),zeros(2*n,1));

for k=1:4:2*n
    v1(k)=complex(real(data((k+1)/2)),0);
    v1(k+1)=complex(imag(data((k+1)/2)),0);
    v1(k+2)=complex(-real(data((k+1)/2+1)),0);
    v1(k+3)=complex(-imag(data((k+1)/2+1)),0);
end
v1=fft(v1);
result=v1(1:n);
