%% Processing of Varian data
% Ashok Ajoy 3/18 2017

function main
clear            

%1000
explimits1{1}='2017-03-19_15.03.46_carbon_ext_trig_shuttle';
explimits1{2}='2017-03-19_16.31.36_carbon_ext_trig_shuttle';
times1000=[21:-5:1 36 31 26];
[sorted_peak_1000,sorted_time_1000]= processT1 (explimits1,times1000);
[f,xvec_1000,fitted_1000,T2_1000]=fit_T2(sorted_time_1000,sorted_peak_1000);

%1200
explimits1{1}='2017-03-19_16.54.22_carbon_ext_trig_shuttle';
explimits1{2}='2017-03-19_18.18.07_carbon_ext_trig_shuttle';
times1200=[36:-5:1 2:4];
[sorted_peak_1200,sorted_time_1200]= processT1 (explimits1,times1200);
[f,xvec_1200,fitted_1200,T2_1200]=fit_T2(sorted_time_1200,sorted_peak_1200);

%1100
explimits1{1}='2017-03-19_18.57.08_carbon_ext_trig_shuttle';
explimits1{2}='2017-03-19_21.06.16_carbon_ext_trig_shuttle';
times1100=[1:5:31 2:5 8:5:18];
[sorted_peak_1100,sorted_time_1100]= processT1 (explimits1,times1100);
[f,xvec_1100,fitted_1100,T2_1100]=fit_T2(sorted_time_1100,sorted_peak_1100);

% %1300
explimits1{1}='2017-03-19_22.50.56_carbon_ext_trig_shuttle';
explimits1{2}='2017-03-19_23.54.32_carbon_ext_trig_shuttle';
times1300=[0.5:0.5:5];
[sorted_peak_1300,sorted_time_1300]= processT1 (explimits1,times1300);
[f,xvec_1300,fitted_1300,T2_1300]=fit_T2(sorted_time_1300,sorted_peak_1300);

%1250
explimits1{1}='2017-03-19_21.39.37_carbon_ext_trig_shuttle';
explimits1{2}='2017-03-19_22.50.56_carbon_ext_trig_shuttle';
times1250=[0.5:0.5:5];
[sorted_peak_1250,sorted_time_1250]= processT1 (explimits1,times1250);
[f,xvec_1250,fitted_1250,T2_1250]=fit_T2(sorted_time_1250,sorted_peak_1250);



%800
explimits1{1}='2017-03-20_08.03.33_carbon_ext_trig_shuttle';
explimits1{2}='2017-03-20_10.33.54_carbon_ext_trig_shuttle';
times800=[1:5:36 41:10:81];
[sorted_peak_800,sorted_time_800]= processT1 (explimits1,times800);
[f,xvec_800,fitted_800,T2_800]=fit_T2(sorted_time_800,sorted_peak_800);

%% Plot of decay curves
start_fig(2,[3 1.5]);
p3=plot_preliminaries(sorted_time_1100,sorted_peak_1100,3,'noline');
plot_preliminaries(xvec_1100,fitted_1100,3,'nomarker');

p4=plot_preliminaries(sorted_time_1000,sorted_peak_1000,4,'noline');
plot_preliminaries(xvec_1000,fitted_1000,4,'nomarker');

% p5=plot_preliminaries(sorted_time_1200,sorted_peak_1200,5,'noline');
% plot_preliminaries(xvec_1200,fitted_1200,5,'nomarker');

p5=plot_preliminaries(sorted_time_800,sorted_peak_800,5,'noline');
plot_preliminaries(xvec_800,fitted_800,5,'nomarker');

p1=plot_preliminaries(sorted_time_1250,sorted_peak_1250,1,'noline');
plot_preliminaries(xvec_1250,fitted_1250,1,'nomarker');

p2=plot_preliminaries(sorted_time_1300,sorted_peak_1300,2,'noline');
plot_preliminaries(xvec_1300,fitted_1300,2,'nomarker');

plot_labels('Delay time [s]','Signal [au]');
%hLegend=legend([p1 p2 p3 p4 p5],'1250','1300','1100','1000','1200','location','NorthEast');
hLegend=legend([p5 p4 p3 p1 p2],'7T','3.4 T','0.828 T','0.189 T','0.131 T','location','NorthEast');
set(hLegend,'FontName','MyriadPro-Regular','FontSize',13);
set(gca,'ylim',[0 2200]);
grid off;


%% Plot of T2s
start_fig(5,[1.5 1]);
T2=[T2_800 T2_1000 T2_1100 T2_1200 T2_1250 T2_1300];
%field=[7 5 3.5 1.5 1 0.3];
field=fliplr([0.131 0.189 0.285 0.828 3.4 7]);

p1=plot_preliminaries(field,T2,1);
plot_labels('Field [T]','T_1 [s]');
set(gca,'xdir','reverse');
grid on;

export2base();
end

function [sorted_peak,sorted_time]= processT1 (explimits1,times)
files_return1= agilent_read_dir(explimits1);
files_return=[files_return1];

%%mass_mail(files_return,'complete');

for j=1:size(files_return,2)
    
    MatrixOut{j}=process_varian(files_return{j},'complete');
    norm_data{j}= MatrixOut{j};
    freq{j}=linspace(1,6.25e3,size(norm_data{j},2));
    [peak(j),b]=max(abs(smooth(norm_data{j},500)));
end

% start_fig(1,[3 2]);
% for j=1:size(files_return,2)
%     p1=plot_preliminaries(freq{j},abs(norm_data{j}),j,'nomarker');
%     plotsize=length(freq{j});
%     p1=plot_preliminaries(freq{j}(1:floor(plotsize/80):end),abs(norm_data{j}(1:floor(plotsize/80):end)),j,'noline');
%     set(p1,'markersize',6);
% %     p1=plot_preliminaries(freq{j},fitted{j},j,'noline');
% %     set(p1,'linewidth',1.5);
% end
%  plot_labels('Frequency [kHz]','Signal [au]');
% %  legend_label = {'Coil','100,v=1000','100,v=2000','100,v=2000,max jerk'};
% %  legend(legend_label);
%  grid off;
%

%
[sorted_time, IX]=sort(times);
sorted_peak=peak(IX);
end

function [f,xvec,fitted_contrast,T2]= fit_T2(x,y,varargin)
lb=[0,max(x)/4,1,0];
ub=[0.3,max(x), 3,0];

x1=x;y1=y;
x1(isnan(y1))=[];y1(isnan(y1))=[];
a_ini=max(y1);
b_ini=max(x1);
c_ini=2;
d_ini=y1(end);
P_ini=[a_ini;b_ini;c_ini;d_ini]; %NOTE that they have to be ordered alphabetically!

f = ezfit(x1, y1, 'y =a*exp(-(x/b)^c) + d',P_ini,lb,ub);

xvec=linspace(x1(1),x1(end),1000);
fitted_contrast=f.m(1).*exp(-(xvec./f.m(2)).^f.m(3))+ f.m(4);
T2=f.m(2);

start_fig(11,[3 2]);
plot_preliminaries(x1,y1,2,'noline');
plot_preliminaries(xvec,fitted_contrast,2,'nomarker');
end


