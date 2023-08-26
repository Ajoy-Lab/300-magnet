clear all;
close all;
%%%%%%%%%%%%%%%load data Filename
data=loadXYdata('D:\Matlab\Experiment data\2017-08-10_23.24.13_carbon_ext_trig_shuttle.txt');
x0=data(:,1);
y0=data(:,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 1
i=1;
while x0(i)<16
    x1(i)=x0(i);
    y1(i)=y0(i);
    i=i+1;
end
myfunc=inline('beta(1)-beta(1)*exp(-x/beta(2))','beta','x'); 
beta=nlinfit(x1,y1,myfunc,[-80 0.5]); 
a1=beta(1);
t1=beta(2);
xx1=(min(x1)-1):0.01:max(x1); 
yy1=a1-a1*exp(-xx1/t1); 
figure;
plot(x0,y0,'o');
hold on;
plot(xx1,yy1,'r','linewidth',1);
legend1=['Fit result \tau=' sprintf('%.2f',t1)];
hold on;
%% Part2
i=i-1;
while x0(i)<46
    x2(i-14)=x0(i);
    y2(i-14)=y0(i);
    i=i+1;
end
myfunc=inline('beta(1)+beta(3)*exp(-(x-15)/beta(2))','beta','x'); 
beta=nlinfit(x2,y2,myfunc,[80 4 160]); 
a2=beta(1),t2=beta(2),c2=beta(3);

xx2=min(x2):0.01:max(x2); 
yy2=a2+c2*exp(-(xx2-15)/t2); 

plot(xx2,yy2,'r','linewidth',1);
legend2=['Fit result \tau=' sprintf('%.2f',t2)];
hold on;
%% Part 3
if i<length(x0)
i=i-1;
while x0(i)<76 && i<length(x0)
    x3(i-44)=x0(i);
    y3(i-44)=y0(i);
    i=i+1;
end
myfunc=inline('beta(1)-beta(3)*exp(-(x-45)/beta(2))','beta','x'); 
beta=nlinfit(x3,y3,myfunc,[-80 7 160]); 
a3=beta(1),t3=beta(2),c3=beta(3);

xx3=min(x3):0.01:max(x3); 
yy3=a3-c3*exp(-(xx3-45)/t3); 
plot(xx3,yy3,'r','linewidth',1);
legend3=['Fit result \tau=' sprintf('%.2f',t3)];
hold on;
end
%% Part 4
if i<length(x0)
    i=i-1;   
while i<(length(x0)+1)
    x4(i-74)=x0(i);
    y4(i-74)=y0(i);
    i=i+1;
end
myfunc=inline('beta(1)+beta(3)*exp(-(x-75)/beta(2))','beta','x'); 
beta=nlinfit(x4,y4,myfunc,[80 7 160]); 
a4=beta(1),t4=beta(2),c4=beta(3);

xx4=min(x4):0.01:max(x4); 
yy4=a4+c4*exp(-(xx4-75)/t4); 
plot(xx4,yy4,'r','linewidth',1);
legend4=['Fit result \tau=' sprintf('%.2f',t4)];
end

grid on;
box on;
legend('Experiment data',legend1,legend2,legend3,legend4,'Location','Best');
%legend('Experiment data',legend1,legend2,legend3,'Location','Best');
hold on;

