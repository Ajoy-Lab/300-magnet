%% Processing of Varian data
% Ashok Ajoy 3/18 2017

function main
clear            

%718
% explimits1{1}='2017-04-27_13.16.33_carbon_ext_trig_shuttle';
% explimits1{2}='2017-04-27_16.02.04_carbon_ext_trig_shuttle';
% times718=[5:10:55 75:30:135];
% [sorted_peak_718,sorted_time_718]= processT1 (explimits1,times718);
% [f,xvec_718,fitted_718,T2_718]=fit_T2(sorted_time_718,sorted_peak_718);

explimits1{1}='2017-04-27_16.48.18_carbon_ext_trig_shuttle';
explimits1{2}='2017-04-27_20.07.22_carbon_ext_trig_shuttle';
times1325=[1:2:5 2:2:10]
[sorted_peak_1325,sorted_time_1325]= processT1 (explimits1,times1325);
[f,xvec_1325,fitted_1325,T2_1325]=fit_T2(sorted_time_1325,sorted_peak_1325);


explimits1{1}='2017-04-28_18.41.31_carbon_ext_trig_shuttle';
explimits1{2}='2017-04-29_02.49.38_carbon_ext_trig_shuttle';
times1425=[1:10]
[sorted_peak_1425,sorted_time_1425]= processT1 (explimits1,times1425);
[f,xvec_1425,fitted_1425,T2_1425]=fit_T2(sorted_time_1425,sorted_peak_1425);

explimits1{1}='2017-04-29_09.40.51_carbon_ext_trig_shuttle';
explimits1{2}='2017-04-29_15.57.45_carbon_ext_trig_shuttle';
times1525=[1:8];
[sorted_peak_1525,sorted_time_1525]= processT1 (explimits1,times1525);
[f,xvec_1525,fitted_1525,T2_1525]=fit_T2(sorted_time_1525,sorted_peak_1525);

explimits1{1}='2017-04-29_16.56.45_carbon_ext_trig_shuttle';
explimits1{2}='2017-04-30_01.03.02_carbon_ext_trig_shuttle';
times1225=[1:10]
[sorted_peak_1225,sorted_time_1225]= processT1 (explimits1,times1225);
[f,xvec_1225,fitted_1225,T2_1225]=fit_T2(sorted_time_1225,sorted_peak_1225);

%% Plot of decay curves
start_fig(2,[3 1.5]);
p3=plot_preliminaries(sorted_time_1325,sorted_peak_1325,1,'noline');
plot_preliminaries(xvec_1325,fitted_1325,1,'nomarker');
p3=plot_preliminaries(sorted_time_1425,sorted_peak_1425,2,'noline');
plot_preliminaries(xvec_1425,fitted_1425,2,'nomarker');

plot_labels('Delay time [s]','Signal [au]');
%hLegend=legend([p1 p2 p3 p4 p5],'1250','1300','1100','1000','1200','location','NorthEast');
%hLegend=legend([p5 p4 p3 p1 p2],'7T','3.4 T','0.828 T','0.189 T','0.131 T','location','NorthEast');
%set(hLegend,'FontName','MyriadPro-Regular','FontSize',13);
%set(gca,'ylim',[0 2200]);
grid off;


% %% Plot of T2s
% start_fig(5,[1.5 1]);
% T2=[T2_800 T2_1000 T2_1100 T2_1200 T2_1250 T2_1300];
% %field=[7 5 3.5 1.5 1 0.3];
% field=fliplr([0.131 0.189 0.285 0.828 3.4 7]);
% 
% p1=plot_preliminaries(field,T2,1);
% plot_labels('Field [T]','T_1 [s]');
% set(gca,'xdir','reverse');
% grid on;

export2base();
end

function [sorted_peak,sorted_time]= processT1 (explimits1,times)
files_return1= agilent_read_dir2(explimits1);
files_return=[files_return1];

for j=1:size(files_return,2)
    
    MatrixOut{j}=process_varian2(files_return{j},'complete');
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


