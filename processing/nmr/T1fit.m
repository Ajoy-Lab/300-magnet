
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                 FUNCTION T1FIT
%
%    fit of rising exponentials (up to 3rd order) to the data.
%    The order of problem is determined by the number of guess-values 
%    specified. A flag controls the plot output.
%
%    call:  par = T2fit(x,y);
%        [par,delta]=gaussfit(x,y);
%        [par,delta]=gaussfit(x,y,p);
%        [par,delta]=gaussfit(x,y,p,out);
%
%  par   = fitted parameters like p
%  delta = error estimate (optional) in abs. values
%  p     = (optional) starting values for fit and control on fitting order (default =3)
%          see below
%  out   = creates output plot for being different from 0 (optional, default =0)
%          1 = linear plot, 2 = logarithmic y-axis
%
% length of p:
%  0-3	monoexponential = A-(A-B)*exp(-t/T1)
%  6	biexponential = Aa-(Aa-Ba)*exp(-t/T1a)+ Ab-(Ab-Bb)*exp(-t/T1b)
%  9	triiexponential = Aa-(Aa-Ba)*exp(-t/T1a)+ Ab-(Ab-Bb)*
%                         exp(-t/T1b)+ )+ Ac-(Ac-Bc)*exp(-t/T1c)
%   p has to have the form [Aa,Ba,T1a,Ab,BbT1b,...]
%     with Aa as the contribution of species a to the magnetization at infinite time
%     with Ba as the contribution of species a to the magnetization at zero time
%
% EXAMPLE:
% >> x=linspace(0,1000,100);
% >> y=10*(1-exp(-x/100))+randn(1,100)*.1;  %saturation recovery
% >> [ip,delta]=T2fit(x,y)
%
%      (c) P. Blümler 10/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 26/10/03    (please change this when code is altered)
%----------------------------------------------------------------------------

function [ip,delta]=T1fit(x,y,p,out)

  if nargin==2
      p=0;
      out=0;
  elseif nargin==3
      out=0;
  elseif nargin<2 |nargin >4
      disp('ERROR: Gaussfit called with wrong set of parameters');
      return
  end
    
  %estimating starting values for monoexponential
  if length(p)<=3
    minf=y(end);
    m0=y(1);
    lin=1-y/minf;
    pg=polyfit(x,log(lin+eps),1);
    intercept=exp(pg(2))+1;
    p(1)=minf;
    p(2)=abs(intercept*minf);
    p(3)=abs(-1/pg(1));
  end
  
  xi=linspace(min(x),max(x),length(x)*10); %for eventual plot

  switch length(p)
   case 3
      [ip,res,J]=nlinfit(x,y,@T1_1,p);
      ci= nlparci(ip,res,J);
      yi=T1_1(ip,xi);          %fitted curve
      yuci=T1_1(ci(:,1),xi);   %upper confidence interval
      ylci=T1_1(ci(:,2),xi);   %lower confidence interval
   case 6
      [ip,res,J]=nlinfit(x,y,@T1_2,p);
      ci= nlparci(ip,res,J);
      yi=T1_2(ip,xi);          %fitted curve
      yuci=T1_2(ci(:,1),xi);   %upper confidence interval
      ylci=T1_2(ci(:,2),xi);   %lower confidence interval
   case 9
      [ip,res,J]=nlinfit(x,y,@T1_3,p);
      ci= nlparci(ip,res,J);
      yi=T1_3(ip,xi);          %fitted curve
      yuci=T1_3(ci(:,1),xi);   %upper confidence interval
      ylci=T1_3(ci(:,2),xi);   %lower confidence interval
  otherwise
      
      disp('ERROR: you have to specify 3,6 or 9 starting values');
      return
 end
 delta=abs(ci(:,2)-ci(:,1))/2;  %estimate error
 delta=delta';
 ip=ip';
 
 if out~=0 %make a plot of values, fit and confidence intervals
   plot(x,y,'bo');hold on;
   plot(xi,yi,'r-'); 
   plot(xi,yuci,'g--');
   plot(xi,ylci,'g--');hold off;
   if out>=2  
      set(gca,'yscale','log');
   end
   axis tight;
end
 


function estim=T1_1(beta,x) %monoexponential
estim=beta(1)- (beta(1)-beta(2))*exp(-x/beta(3));

function estim=T1_2(beta,x) %monoexponential
estim=beta(1)- (beta(1)-beta(2))*exp(-x/beta(3))+...
      beta(4)- (beta(4)-beta(5))*exp(-x/beta(6));

function estim=T1_3(beta,x) %monoexponential
estim=beta(1)- (beta(1)-beta(2))*exp(-x/beta(3))+...
      beta(4)- (beta(4)-beta(5))*exp(-x/beta(6))+...
      beta(7)- (beta(7)-beta(8))*exp(-x/beta(9));
