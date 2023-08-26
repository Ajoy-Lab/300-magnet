%#########################################################################################
%#
%#                   function ROT_XYZ
%#
%#     returns the rotation matrix for successive rotation by an angle a around the x-axis,
%#     b around the y-axis and c around the z-axis. a,b,c have to be in RADIANS.
%#     Rx(a)Ry(b)Rz(c)  
%#    
%#     usage R=rot_xyz(a,b,c);
%#
%#            R  = resulting rotation matrix 
%#            a  = rotation angle around x-axis in radians 
%#            b  = rotation angle around y-axis in radians 
%#            c  = rotation angle around z-axis in radians 
%#            
%#       (c) P. Blümler 2/2003
%#########################################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 18/2/03    (please change this when code is altered)
%----------------------------------------------------------------------------
function r=rot_xyz(a,b,c)

r=[cos(b)*cos(c), sin(a)*sin(b)*cos(c)-cos(a)*sin(c), cos(a)*sin(b)*cos(c)+sin(a)*sin(c);...
   cos(b)*sin(c), sin(a)*sin(b)*sin(c)+cos(a)*cos(c), cos(a)*sin(b)*sin(c)-sin(a)*cos(c);...
   -sin(b), sin(a)*cos(b), cos(a)*cos(b)];
