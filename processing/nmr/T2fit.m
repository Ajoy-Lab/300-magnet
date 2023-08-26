
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                 FUNCTION T2FIT
%
%    fit of decaying exponentials (up to 4th order) to the data.
%    The order of problem is determined by the number of guess-values 
%    specified. A flag controls the plot output.
%
%    call:  par = T2fit(x,y);
%        [par,delta]=T2fit(x,y);
%        [par,delta]=T2fit(x,y,p);
%        [par,delta]=T2fit(x,y,p,out);
%
%  par   = fitted parameters like p
%  delta = error estimate (optional) in abs. values
%  p     = (optional) starting values for fit and control on fitting order (default =2)
%          see below
%  out   = creates output plot for being different from 0 (optional, default =0)
%          1 = linear plot, 2 = logarithmic y-axis
%
%   number of specified p - values: 
%   0-2	monoexponential without offset = A*exp(-t/T2)
%   3	monoexponential with offset = A*exp(-t/T2)+c
%   4	biexponential without offset = Aa*exp(-t/T2a)+ Ab*exp(-t/T2b)
%   5	biexponential with offset = Aa*exp(-t/T2a)+ Ab*exp(-t/T2b) + c 
%   ...
%   9	4 exponentials with offset = Aa*exp(-t/T2a)+ Ab*exp(-t/T2b)+ 
%                                    Ac*exp(-t/T2c)+ Ad*exp(-t/T2d)+c
%
%   the p has to have the form [Aa,T2a,Ab,T2b,...,c]
%
% EXAMPLE:
% >> x=linspace(0,1000,100);
% >> y=10*exp(-x/100)+4*exp(-x/10)+2*exp(-x/1000)+.5+randn(1,100)*.1;
% >> [ip,delta]=T2fit(x,y,[9,90,5,12,0.5],1)
%
%      (c) P. Blümler 10/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 26/10/03    (please change this when code is altered)
%----------------------------------------------------------------------------

function [ip,delta]=T2fit(x,y,p,out)

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
  if length(p)<=2
    pg=polyfit(x,log(y),1);
    p(1)=exp(pg(2));
    p(2)=-1/pg(1);
  elseif length(p)<=3
    pg=polyfit(x,log(y),1);
    p(1)=exp(pg(2))-y(end);
    p(2)=-1/pg(1);
    p(3)=y(end);
  end
  
  xi=linspace(min(x),max(x),length(x)*10); %for eventual plot

  switch length(p)
   case 2
      [ip,res,J]=nlinfit(x,y,@T2_1a,p);
      ci= nlparci(ip,res,J);
      yi=T2_1a(ip,xi);          %fitted curve
      yuci=T2_1a(ci(:,1),xi);   %upper confidence interval
      ylci=T2_1a(ci(:,2),xi);   %lower confidence interval
   case 3
      [ip,res,J]=nlinfit(x,y,@T2_1b,p);
      ci = nlparci(ip,res,J);
      yi=T2_1b(ip,xi);          %fitted curve
      yuci=T2_1b(ci(:,1),xi);   %upper confidence interval
      ylci=T2_1b(ci(:,2),xi);   %lower confidence interval
   case 4
      [ip,res,J]=nlinfit(x,y,@T2_2a,p);
      ci = nlparci(ip,res,J);
      yi=T2_2a(ip,xi);          %fitted curve
      yuci=T2_2a(ci(:,1),xi);   %upper confidence interval
      ylci=T2_2a(ci(:,2),xi);   %lower confidence interval
   case 5
      [ip,res,J]=nlinfit(x,y,@T2_2b,p);
      ci = nlparci(ip,res,J);
      yi=T2_2b(ip,xi);          %fitted curve
      yuci=T2_2b(ci(:,1),xi);   %upper confidence interval
      ylci=T2_2b(ci(:,2),xi);   %lower confidence interval
   case 6
      [ip,res,J]=nlinfit(x,y,@T2_3a,p);
      ci = nlparci(ip,res,J);
      yi=T2_3a(ip,xi);          %fitted curve
      yuci=T2_3a(ci(:,1),xi);   %upper confidence interval
      ylci=T2_3a(ci(:,2),xi);   %lower confidence interval
   case 7
      [ip,res,J]=nlinfit(x,y,@T2_3b,p);
      ci = nlparci(ip,res,J);
      yi=T2_3b(ip,xi);          %fitted curve
      yuci=T2_3b(ci(:,1),xi);   %upper confidence interval
      ylci=T2_3b(ci(:,2),xi);   %lower confidence interval
   case 8
      [ip,res,J]=nlinfit(x,y,@T2_4a,p);
      ci = nlparci(ip,res,J);
      yi=T2_4a(ip,xi);          %fitted curve
      yuci=T2_4a(ci(:,1),xi);   %upper confidence interval
      ylci=T2_4a(ci(:,2),xi);   %lower confidence interval
   otherwise
      [ip,res,J]=nlinfit(x,y,@T2_4b,p(1:9));
      ci = nlparci(ip,res,J);
      yi=T2_4b(ip,xi);          %fitted curve
      yuci=T2_4b(ci(:,1),xi);   %upper confidence interval
      ylci=T2_4b(ci(:,2),xi);   %lower confidence interval 
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
 


function estim=T2_1a(beta,x) %monoexponential
estim=beta(1)*exp(-x/beta(2));

function estim=T2_1b(beta,x) %monoexponential + offset
estim=beta(1)*exp(-x/beta(2)) + beta(3);

function estim=T2_2a(beta,x) %biexponential
estim=beta(1)*exp(-x/beta(2)) + beta(3)*exp(-x/beta(4));

function estim=T2_2b(beta,x) %biexponential + offset
estim=beta(1)*exp(-x/beta(2)) + beta(3)*exp(-x/beta(4)) + beta(5);

function estim=T2_3a(beta,x) %triexponential
estim=beta(1)*exp(-x/beta(2)) + beta(3)*exp(-x/beta(4)) + beta(5)*exp(-x/beta(6));

function estim=T2_3b(beta,x) %triexponential + offset
estim=beta(1)*exp(-x/beta(2)) + beta(3)*exp(-x/beta(4)) + beta(5)*exp(-x/beta(6)) + beta(7);

function estim=T2_4a(beta,x) %4 exponentials
estim=beta(1)*exp(-x/beta(2)) + beta(3)*exp(-x/beta(4)) + beta(5)*exp(-x/beta(6)) + beta(7)*exp(-x/beta(8));

function estim=T2_4b(beta,x) %4 exponentials + offset
estim=beta(1)*exp(-x/beta(2)) + beta(3)*exp(-x/beta(4)) + beta(5)*exp(-x/beta(6)) + beta(7)*exp(-x/beta(8)) + beta(9);
