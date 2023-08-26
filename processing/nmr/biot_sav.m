%############################################################################
%#
%#                           function BIOT_SAV
%#
%#      
%#      
%#      
%#      
%#      
%#
%#      usage: 
%#
%#
%#      (c) P. Blümler 12/06
%############################################################################
%----------------------------------------------------------------------------
%  version 1.1 PB 1/12/06    (please change this when code is altered)
%----------------------------------------------------------------------------
function B=biot_sav(coil,r,I);

[n]=size(r);
[m,dummy]=size(coil);
if n~=3
    disp('ERROR: r is not a 3D vector');
end
if dummy~=3
    disp('ERROR: coil is not a 3D vector');
end

B=zeros(1,3);


for j=1:m-1
  dl=coil(j,:)-coil(j+1,:);
  dr=coil(j,:)-r;
  rm=abs(sqrt(sum(dr.^2)).^3);
  B=B+cross(dl,dr)/rm;
end
B=B*1.2566e-6*I/4/pi;