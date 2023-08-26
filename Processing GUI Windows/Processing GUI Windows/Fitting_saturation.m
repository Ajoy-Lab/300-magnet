function [] = Fitting_saturation()
%%%%%%%%%%%%%%%load data Filename
data=loadXYdata('C:\Users\Arthur Lin\Documents\Pines Lab\MATLAB\2017.08.12 Fitting Routines\2017-08-12_15.56.03_carbon_ext_trig_shuttle.txt');
x0=data(:,1);
y0=data(:,2);
% loop_time=5;
% wait_time=max(x0);
figure(2);
hold on;
plot(x0,y0,'o','MarkerFaceColor',[0.6 0.8 0.8]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 1
i=1;
while i<(length(x0)+1)
    x1(i)=x0(i);
    y1(i)=y0(i);
    i=i+1;
end
myfunc=inline('beta(1)-beta(1)*exp(-x/beta(2))','beta','x'); 
beta=nlinfit(x1,y1,myfunc,[+80 0.5]); 
[beta,R1,J1,Cov1,MSE1]=nlinfit(x1,y1,myfunc,[+80 0.5]); 
ci1=nlparci(beta,R1,'covar',Cov1);
a1=beta(1);
t1=beta(2);
xx1=(min(x1)-1):0.01:max(x1); 
yy1=a1-a1*exp(-xx1/t1); 
hold on;
%% Part2
% i=i-1;
% while (i<length(x0)+1)&& x0(i)<(3*loop_time+0.5) 
%     x2(i-8)=x0(i);
%     y2(i-8)=y0(i);
%     i=i+1;
% end
% func2=sprintf('beta(1)+beta(3)*exp(-(x-%f)/beta(2))',loop_time);
% myfunc=inline(func2,'beta','x'); 
% beta=nlinfit(x2,y2,myfunc,[-80 4 160]); 
% a2=beta(1);t2=beta(2);c2=beta(3);
% %t2=t1;
% xx2=min(x2):0.01:max(x2); 
% yy2=a2+c2*exp(-(xx2-loop_time)/t2); 
% 
% hold on;
% %% Part 3
% if i<length(x0)
% i=i-1;
% while x0(i)<(5*loop_time+1) && i<(length(x0)+1)
%     x3(i-3*loop_time+1)=x0(i);
%     y3(i-3*loop_time+1)=y0(i);
%     i=i+1;
% end
% func3=sprintf('beta(1)+beta(3)*exp(-(x-%f)/beta(2))',3*loop_time);
% myfunc=inline(func3,'beta','x'); 
% beta=nlinfit(x3,y3,myfunc,[80 7 160]); 
% a3=beta(1),t3=beta(2),c3=beta(3);
% %t3=t2;
% xx3=min(x3):0.01:max(x3); 
% yy3=a3+c3*exp(-(xx3-3*loop_time)/t3); 
% hold on;
% end
% %% Part 4
% if i<length(x0)
%     i=i-1;   
% while i<(7*loop_time-10+1)&&(i<length(x0)+1)
%     x4(i-5*loop_time+1)=x0(i);
%     y4(i-5*loop_time+1)=y0(i);
%     i=i+1;
% end
% func4=sprintf('beta(1)+beta(3)*exp(-(x-%f)/beta(2))',5*loop_time);
% myfunc=inline(func4,'beta','x'); 
% beta=nlinfit(x4,y4,myfunc,[-80 4 160]); 
% a4=beta(1),t4=beta(2),c4=beta(3);
% %t4=t2;
% xx4=min(x4):0.01:max(x4); 
% yy4=a4+c4*exp(-(xx4-5*loop_time)/t4); 
% end
% %% Part 5
% if i<length(x0)
%     i=i-1;   
% while i<(9*loop_time-20+1)&& (i<(length(x0)+1))
%     x5(i-7*loop_time+10+1)=x0(i);
%     y5(i-7*loop_time+10+1)=y0(i);
%     i=i+1;
% end
% func5=sprintf('beta(1)+beta(3)*exp(-(x-%f)/beta(2))',7*loop_time);
% myfunc=inline(func5,'beta','x'); 
% [beta,l,m,n,o,p,q]=nlinfit(x5,y5,myfunc,[80 4 160]); 
% m,n,o,p;
% a5=beta(1),t5=beta(2),c5=beta(3);
% %t5=t2;
% xx5=min(x5):0.01:max(x5); 
% yy5=a5+c5*exp(-(xx5-7*loop_time)/t5); 
% end
%% Keeping them the same time constant
% % set default value
% x=0:0.01:3*loop_time;
% y=0:0.01:3*loop_time;
% % set parameter
% t0=t1;
% a0=a1;
% i=1;
% while (i<length(x)+1) && x(i)<loop_time 
%     y(i)=a0*(1-exp(-x(i)/t0));
%     i=i+1;
% end
% firstpoint=y(i-1);
% while (i<length(x)+1) && x(i)<3*loop_time
%     y(i)=firstpoint-(firstpoint+a0)*(1-exp(-(x(i)-loop_time)/t0));
%     i=i+1;
% end
% secondpoint=y(i-1);
% while x(i)<5*loop_time &&(i<length(x)+1)
%     y(i)=secondpoint+(a0-secondpoint)*(1-exp(-(x(i)-3*loop_time)/t0));
%     i=i+1;
% end
% thirdpoint=y(i-1);
% while x(i)<7*loop_time &&(i<length(x)+1)
%     y(i)=thirdpoint-(a0+thirdpoint)*(1-exp(-(x(i)-5*loop_time)/t0));
%     i=i+1;
% end
% fourthpoint=y(i-1);
% while i<(length(x)+1) &&(i<length(x)+1)
%     y(i)=fourthpoint+(a0-fourthpoint)*(1-exp(-(x(i)-7*loop_time)/t0));
%     i=i+1;
% end


plot(xx1,yy1,'r','linewidth',1);
legend1=['Fit result \tau_1=' sprintf('%.2f errorbar [%.2f %.2f]',t1,ci1(2,1),ci1(2,2))];
text(0.2*max(xx1),1.1*max(yy1),sprintf('a_1=%.2f errorbar [%.2f %.2f]',a1, ci1(1,1),ci1(1,2)));
% text(0.2*max(xx1),1.0*max(yy1),sprintf('\tau_1=%.2f errorbar [%.2f %.2f]',t1, ci1(2,1),ci1(2,2)));
hold on;
% plot(xx2,yy2,'r','linewidth',1);
% legend2=['Fit result \tau_2=' sprintf('%.2f',t2)];
% hold on;
% plot(xx3,yy3,'r','linewidth',1);
% legend3=['Fit result \tau_3=' sprintf('%.2f',t3)];
% hold on;
% plot(xx4,yy4,'r','linewidth',1);
% legend4=['Fit result \tau_4=' sprintf('%.2f',t4)];
% hold on;
% plot(xx5,yy5,'r','linewidth',1);
% legend5=['Fit result \tau_5=' sprintf('%.2f',t5)];
% hold on;
% plot(x,y,'r','linewidth',1,'color',[0 0.8 0]);
% legend6=['Kepping all the \tau =' sprintf('%.2f',t0) ];
% hold on;
%% 
grid on;
box on;
xlabel('Wait time (second)');
ylabel('Enhancement');
%legend('Experiment data',legend1,legend2,legend3,legend4,'Location','Best');
% legend('Experiment data',legend1,legend2,legend3,legend4,legend5,legend6,'Location','Best');
%legend('Experiment data',legend1,legend2,legend3,'Location','Best');
% legend('Experiment data',legend1,legend2,legend6,'Location','Best');
legend('Experiment data',legend1,'Location','Best');
hold on;

