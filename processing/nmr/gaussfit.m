
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                 FUNCTION GAUSSFIT
%
%   fits a Gaussian with variable parameter number to data.
%   The general Gauss-model is :
%
%                   f(x)= amplitude*exp(-(x-origin).^2*width)+offset
%
%
% call:  par = gaussfit(x,y);
%        [par,delta]=gaussfit(x,y);
%        [par,delta]=gaussfit(x,y,n);
%        [par,delta]=gaussfit(x,y,n,out);
% 
%  par   = fitted parameter [amplitude, width, origin, offset]
%  delta = error estimate (optional) in abs. values
%  n     = control on fit parameters (optional, default=4)
%          n = 2 : only width and amplitude are fitted
%          n = 3 : width, ampl. and origin are fitted
%          n = 4 : all fitted
%          n = 5 : width, ampl. and offset fitted
% out    = creates output plot for being different from 0 (optional, default =0)
%
% EXAMPLE:
% >> n=11;
% >> p=[10.23,5.44,0.123,2.344];
% >> x=linspace(-1,1,n);
% >> y=p(1)*exp(-(x-p(3)).^2*p(2))+p(4)+.4*randn(1,n);
% >> [ip,delta]=gaussfit(x,y,4,1)
%
%      (c) P. Blümler 8/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 17/8/03    (please change this when code is altered)
%----------------------------------------------------------------------------

function [ip,delta]=gaussfit(x,y,p,out)
  if nargin==2
      p=4;
      out=0;
  elseif nargin==3
      out=0;
  elseif nargin<2 |nargin >4
      disp('ERROR: Gaussfit called with wrong set of parameters');
      return
  end
  %estimating starting values
  ip=zeros(1,4);
  if p<2
      p=2;
  end
  if p==4 
      ip(4)=min(y);
  end
  
  index=find(y==max(y));
  ip(3)=index(1);
  ip(1)=y(ip(3))-ip(4);
  ip(3)=x(ip(3));
  [ip(1),ip(2)]=lgf1(x-ip(3),y-ip(4));        %linear regression

  switch p
  case 2
      [ip,res,J]=nlinfit(x,y,@gauss2,ip(1:2));
      cii = nlparci(ip,res,J);
      ip=[ip(1),ip(2),0,0];
      ci=zeros(4,2);
      ci(1:2,:)=cii(1:2,:);   
  case 3
      [ip,res,J]=nlinfit(x,y,@gauss3,ip(1:3));
      cii = nlparci(ip,res,J);
      ip=[ip(1),ip(2),ip(3),0];
      ci=zeros(4,2);
      ci(1:3,:)=cii(1:3,:);   
  case 4
      [ip,res,J]=nlinfit(x,y,@gauss4,ip);
      ci = nlparci(ip,res,J);
      ip=ip';
  case 5
      [ip,res,J]=nlinfit(x,y,@gauss5,[ip(1),ip(2),ip(4)]);
      cii = nlparci(ip,res,J);
      ip=[ip(1),ip(2),0,ip(3)];
      ci=zeros(4,2);
      ci(1:2,:)=cii(1:2,:);
      ci(4,:)=cii(3,:);
 end
 delta=abs(ci(:,2)-ci(:,1))/2;  %estimate error
 delta=delta';
 
 if out~=0 %make a plot of values, fit and confidence intervals
   plot(x,y,'bo');hold on;
   xi=linspace(min(x),max(x),length(x)*10);
   yi=ip(1)*exp(-(xi-ip(3)).^2*ip(2))+ip(4);
   plot(xi,yi,'r-');
   yi=ci(1,1)*exp(-(xi-ci(3,1)).^2*ci(2,1))+ci(4,1);
   plot(xi,yi,'g--');
   yi=ci(1,2)*exp(-(xi-ci(3,2)).^2*ci(2,2))+ci(4,2);
   plot(xi,yi,'g--');hold off
end
 


function estim=gauss2(beta,x)
estim=beta(1)*exp(-x.^2*beta(2));

function estim=gauss3(beta,x)
estim=beta(1)*exp(-(x-beta(3)).^2*beta(2));

function estim=gauss4(beta,x)
estim=beta(1)*exp(-(x-beta(3)).^2*beta(2))+beta(4);

function estim=gauss5(beta,x)
estim=beta(1)*exp(-x.^2*beta(2))+beta(3);

%linear regression of gaussian  (amp and width)
function [a,b]=lgf1(xi,yi)
  x=xi';
  
  N=length(x);
  y=zeros(1,N);
  for t=1:N
      if yi(t) >0 
          y(t)=log(yi(t));
      end
  end
  
  Sy=sum(y);
  Sxx=sum(x.^2);
  Sxxy=sum(x.^2.*y);
  Sx4=sum(x.^4);
  a=(Sy*Sx4-Sxxy*Sxx)/(N*Sx4-Sxx^2);
  b=(a*Sxx-Sxxy)/Sx4;
  a=exp(a);
