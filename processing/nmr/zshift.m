%############################################################################
%#
%#                           function ZSHIFT
%#
%#      shifts data (up to 3D) cyclically, shifts can be positive or 
%#      negative or zero. If a shift range is not specified, the routine
%#      applies the shifts to the first dimension(s) and assumes zero shift
%#      for the others.
%#
%#      usage: shdata=zshift(data,s1,s2,...);
%#
%#
%#      (c) R. Graf 01/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.1 RG 31/1/03    (please change this when code is altered)
%----------------------------------------------------------------------------



function data=shift(data,s1,s2,s3)
n=size(data);
d=dimension(data);
tdat=data;


%########################################################################
%#                                                                      #
%#      Separate requiered interpolation from shift and do it !!!       #
%#                                                                      #
%########################################################################

switch nargin
case 1
    s=[0,0,0];
case 2
    s=[s1,0,0];
    i=s-round(s);
    s=round(s);
    if (i~=0)
        x=1:n(1);
        xi=x+i(1);
        tdat=interp1(x,data,xi,'spline');
    end;
case 3
    s=[s1,s2,0];
    i=s-round(s);
    s=round(s);
    if (i~=0)
        x1=1:n(1);
        xi1=x1+i(1);
        x2=1:n(2);
        xi2=x2+i(2);
        tdat=interp1(x1,x2,data,xi1,xi2,'spline');
    end;
case 4
    s=[s1,s2,s3];
    i=s-round(s);
    s=round(s);
    if (i~=0)
        x1=1:n(1);
        xi1=x1+i(1);
        x2=1:n(2);
        xi2=x2+i(2);
        x3=1:n(3);
        xi3=x3+i(3);
        tdat=interp1(x1,x2,x3,data,xi1,xi2,xi3,'spline');
    end;
otherwise
    disp('ERROR: too many arguments!')
    return
end;

%########################################################################
%#                                                                      #
%#       shift interpolated data points !!!                             #
%#                                                                      #
%########################################################################

tdat=circshift(tdat,s);

%########################################################################
%#                                                                      #
%#      Set shifted data points to zero to prevent artefacts !!!        #
%#                                                                      #
%########################################################################

for j=1:d
    if(s(j)<0)
        z=(n(j)+s(j)):n(j);
    else
        z=1:s(j);
    end;
    switch d
        case 1
            tdat(z)=0;
        case 2
            tdat=shiftdim(tdat,j-1);
            tdat(z,:)=0;
            tdat=shiftdim(tdat,1-j); 
        case 3
            tdat=shiftdim(tdat,j-1);
            tdat(z,:,:)=0;
            tdat=shiftdim(tdat,1-j);
        otherwise
            disp('ERROR: too many dimensions!')
      
    end;
end;

data=tdat;
 