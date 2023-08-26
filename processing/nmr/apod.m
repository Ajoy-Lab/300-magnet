%############################################################################
%#
%#                          function APOD
%#
%#      generates apodization filter functions up to 3D
%#
%#      usage: ffunc=apod(type,size,center,width,mode)
%#    
%#             type   = filter functional (see below)
%#             size   = length of dimensions, also handels dimensionality in points
%#             center = center of filter functions (0 for FID, size/2 for echos) in points*
%#             width  = width of filter in points (typically full width at half height)*
%#             mode   = steepness of filter function (exponent of argument)*
%#                *   = optional (defaults: center = size/2, width=size/4; mode = 1);
%#    
%#    1D-example: >>plot(apod('gauss',256,128,100));
%#    2D-example: >>surf(apod('blackmann',[256,256],[128,128],[100,70]),'Edgecolor','none');camlight left
%#    
%#    
%#    Filter functionals (types): is not case-sensitive (abbrevaitions are allowed (see case at end)
%#    'Gauss'       = exp(-x^2)
%#    'Exponential' = exp(-x)
%#    'Lorentz'     = 1/(4x^2+1) 
%#    'Cosine'      = cos(x)
%#    'Sine'        = sin(x)
%#    'Lowpass'     = ideal lowpass (rectangular or Heaviside)
%#    'Highpass'    = 1- lowpass
%#    'Butterworth' = 1/sqrt(1+x^m)
%#    'Hanning'     = cos(x)^2
%#    'Hamming'     = 0.54+0.46*cos(x)
%#    'Barlett'     = 1-abs(x) = triangle
%#    'Blackmann'   = 0.42+0.5*cos(x)+0.08*cos(2x)
%#    'Welch'       = 1-x^2
%#    'Connes'      = (1-x^2)^2
%#    
%#      (c) P. Blümler 2/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 6/2/03    (please change this when code is altered)
%----------------------------------------------------------------------------



function filter=apod(type,n,c,w,m)
switch nargin
case 1, disp('ERROR: specifiy length'); return
case 2
  c=n/2;
  w=n/4;
  m=1;
case 3
  w=n/4;
  m=1;
case 4, m=1;
end
x=([1:n(1)]-c(1))/w(1);
switch length(n)
case 1, R=x;
case 2, y=([1:n(2)]-c(2))/w(2);
      [X,Y]=meshgrid(x,y);
      R=sqrt(X.^2+Y.^2);
case 3, y=([1:n(2)]-c(2))/w(2);
       z=([1:n(3)]-c(3))/w(3);
      [X,Y,Z]=meshgrid(y,x,z); %MATLAB bug
      R=sqrt(X.^2+Y.^2+Z.^2); 
end

switch lower(type)
case {'g','gauss','gauß'}, filter=exp(-R.^(2*m) *log(2)*4);
case {'l','lp','lowpass','rectangular'}, filter=exp(-R.^2 *log(2)*4)>=0.5;
case {'hp','highpass'}, filter=exp(-R.^2 *log(2)*4)<=0.5;
case {'lo','lorentz','lorentzian'}, filter=1./(4*R.^(2*m) +1);   
case {'e','ex','exp','exponential'}, filter=exp(-abs(R).^m/log(2));
case {'c','co','cos','cosine'}, filter=cos(R.^m*pi/3*2);
case {'s','si','sin','sine'}, filter=sin(R.^m*pi/3*2);
case {'h','han','hanning'}, filter=cos(pi*R.^m/2).^2;
case {'ham','hamming'}, filter=0.54+0.46*cos(pi*R.^m);
case {'b','barlett','t','triangle','cone'}, filter=1-abs(R.^m); filter=filter.*(filter>0);
case {'bl','blackmann'}, filter=0.42+0.5*cos(pi*R.^m)+0.08*cos(2*pi*R.^m);
case {'w','welch'}, filter=1-R.^(2*m);
case {'con','connes'}, filter=(1-R.^(2*m)).^2; filter=filter/max(filter);
case {'bu','butter','butterworth'}, filter=1./sqrt(1+R.^(2*m));filter=filter/gmax(filter);
otherwise
    disp('ERROR: unknown filter function')
    return
end
%filter=filter';   
    