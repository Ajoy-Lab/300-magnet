function [out,r]=fit_Lorentzian_peak(varargin)
% x and y are input vectors of the noisy data
% this routine tries to find the optimal fit of a Lorentzian f(x)=a/ (pi * (1- [(x-x0)/b]^2) )) + c  to fit the data

x=varargin{1};
y=varargin{2};
if(nargin>2)
    P_ini=varargin{3};
else
    
%initial guess of parameters
[max_val,max_pos]=max(abs(y-mean(y)))
x0_ini=x(max_pos);
c_ini=mean(y);
b_ini=(max(x)-min(x))/10;
a_ini=max_val;
P_ini=[a_ini;b_ini;c_ini;x0_ini]
%P_ini=rand(4,1)
%P_ini(4)=2.3E9
%P_ini(2)=2.3E7
end

P= fminsearch(@deviation_fct, P_ini);   %now look for the minimum of this deviation function defined below

str='P= fminsearch(@deviation_fct, P_ini);';
r=evalc(str)

if ~isempty(r)
    P=NaN*ones(1,4);
end


    function out=deviation_fct(P)      %nested function to return the deviation for a given set of parameters P
        a=P(1);
        b=P(2);
        c=P(3);
        x0=P(4);
        out=0;
        for ct=1:length(x)
        out=out+ (y(ct)- (a/(pi*(1+( (x(ct)-x0) / b)^2))+c) )^2;
        end        
    end

%plot the result: compare data with fitted function
if(nargin<=2)
figure(10);clf;
hold on
plot(x,y,'*')
xx=linspace(min(x),max(x),1000);
plot(xx, P(1)./ (pi * ( 1+  ((xx-P(4))/P(2) ).^2) ) + P(3), 'r' )
end

out=P;
deviation=deviation_fct(out);
end