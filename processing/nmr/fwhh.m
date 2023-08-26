%############################################################################
%#
%#                          function FWHH
%#
%#      Estimates the FULL WIDTH at HAFT HEIGHT (or value) of a SINGLE PEAK  
%#      specified by input! The algorithm looks for the next neighbouring 
%#      points where the input data is less the value of the data at the 
%#      specified point and takes the average (if possible).
%#
%#      usage: width=fwhh(data,point,value);
%#    
%#             data = data to analyze
%#             point = specifies the point to analyze
%#             value = optional (default = 0.5) specify if not half (=0.5) height 
%#    
%#      (c) P. Blümler 2/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 17/2/03    (please change this when code is altered)
%----------------------------------------------------------------------------

function result=fwhh(data,point,value)

switch nargin
case 1
    disp('WARNING: no point specified, use first')
    point=1;
    value=0.5;
case 2
    value=0.5;
case 0
    disp('ERROR: This routine requests at least ONE input argument')
case 3
otherwise
    disp('ERROR: FWHH called with too many parameters');
end
  w=find(data>data(point)*value); %guess width by looking at half height to the left 
  wl=point-min(w);  %that's the width
  wr=max(w)-point;
  if wl*wr==0
      result=(wl+wr)*2+2;
  else
      result=wr+wl+2;
  end