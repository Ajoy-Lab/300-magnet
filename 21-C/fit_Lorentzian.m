function [out,xx,func]=fit_Lorentzian(x,y)
% x and y are input vectors of the noisy data
% this routine tries to find the optimal fit of a Lorentzian f(x)=a/ (pi * (1- [(x-x0)/b]^2) )) + c  to fit the data

%initial guess of parameters
[max_val,max_pos]=max(abs(y-mean(y)));
x0_ini=x(max_pos);
c_ini=mean(y);
b_ini=(max(x)-min(x))/10;
a_ini=-max_val;
P_ini=[a_ini;b_ini;c_ini;x0_ini];
%P_ini=rand(4,1)
%P_ini(4)=2.3E9
%P_ini(2)=2.3E7

P= fminsearch(@deviation_fct, P_ini);   %now look for the minimum of this deviation function defined below

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

xx=linspace(min(x),max(x),1000);
func=P(1)./ (pi * ( 1+  ((xx-P(4))/P(2) ).^2) ) + P(3);

% figure(5);clf;
% hold on
% plot(x,y,'*')
% plot(xx, P(1)./ (pi * ( 1+  ((xx-P(4))/P(2) ).^2) ) + P(3), 'r' );

out=P;
end