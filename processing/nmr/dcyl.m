function sign=dcyl(D, delta, Delta, R, gamma, Gmax, gx, m)

G=linspace(-Gmax,Gmax,gx)';


sign=zeros(gx,1);
sum=0;
alpha=besselmodzero(R,m);
for j=1:m
   sum=sum+(2*delta/alpha(j)^2/D-(2+exp(-alpha(j)^2*D*(Delta-delta))-2*exp(-alpha(j)^2*D*delta)-2*exp(-alpha(j)^2*D*Delta)+exp(-alpha(j)^2*D*(Delta+delta)))/alpha(j)^4/D^2)/alpha(j)^2/(alpha(j)^2*R^2-1);
end
sign=exp(-2*gamma^2*G.^2*sum);
