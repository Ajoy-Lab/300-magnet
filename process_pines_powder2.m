%% PJust hitting with a single tone MW irradiation at 20G


function main
clear       

explimits1{1}='2017-05-13_16.28.21_carbon_ext_trig_shuttle';
explimits1{2}='2017-05-13_17.36.01_carbon_ext_trig_shuttle';

% % 
% explimits1{1}='2017-05-14_11.16.09_carbon_ext_trig_shuttle';
% explimits1{2}='2017-05-14_13.39.57_carbon_ext_trig_shuttle';
% 
% % explimits1{1}='2017-05-14_17.23.25_carbon_ext_trig_shuttle';
% % explimits1{2}='2017-05-14_19.34.21_carbon_ext_trig_shuttle';
% % % 
% % 
% % explimits1{1}='2017-05-14_22.57.25_carbon_ext_trig_shuttle';
% % explimits1{2}='2017-05-15_01.09.00_carbon_ext_trig_shuttle';
% 
% 
% explimits1{1}='2017-05-15_18.44.49_carbon_ext_trig_shuttle';
% explimits1{2}='2017-05-15_20.15.50_carbon_ext_trig_shuttle';

% 
% explimits1{1}='2017-05-16_08.42.57_carbon_ext_trig_shuttle';
% explimits1{2}='2017-05-16_08.59.37_carbon_ext_trig_shuttle';
% 


% explimits1{1}='2017-05-16_13.01.05_carbon_ext_trig_shuttle';
% explimits1{2}='2017-05-16_13.05.43_carbon_ext_trig_shuttle';

%thermal, 2.81GHz 0 DbM, 2.83 GHz 0 DbM, 2.85 GHz 0 DbM, 2.79 GHz 0 DbM, 5 averages
explimits1{1}='2017-05-19_12.25.04_carbon_ext_trig_shuttle';
% explimits1{2}='2017-05-16_13.43.01_carbon_ext_trig_shuttle';
% explimits1{3}='2017-05-16_14.03.53_carbon_ext_trig_shuttle';
% explimits1{4}='2017-05-16_14.40.19_carbon_ext_trig_shuttle';
explimits1{2}='2017-05-19_18.44.05_carbon_ext_trig_shuttle';

explimits1{1}='2017-05-20_18.12.03_carbon_ext_trig_shuttle';
explimits1{2}='2017-05-20_19.19.14_carbon_ext_trig_shuttle';



explimits1{1}='2017-05-24_11.46.22_carbon_ext_trig_shuttle';
explimits1{2}='2017-05-24_13.49.25_carbon_ext_trig_shuttle';



%thermal, 2.79GHz 0 DbM, 10 averages
% explimits1{1}='2017-05-16_16.37.06_carbon_ext_trig_shuttle';
% explimits1{2}='2017-05-16_17.21.01_carbon_ext_trig_shuttle';

% %Sweep 2.7 -2.78 GHz -10 DbM, Thermal 10 averages
% explimits1{1}='2017-05-17_10.02.30_carbon_ext_trig_shuttle';
% % explimits1{2}='2017-05-17_10.47.27_carbon_ext_trig_shuttle';
% explimits1{2}='2017-05-17_18.55.07_carbon_ext_trig_shuttle';

% %Sample 2, Thermal, Sweep 2.76 -2.87 GHz 8 DbM
% explimits1{1}='2017-05-18_15.26.42_carbon_ext_trig_shuttle';
% % explimits1{2}='2017-05-17_10.47.27_carbon_ext_trig_shuttle';
% explimits1{2}='2017-05-18_18.47.04_carbon_ext_trig_shuttle';



%explimits1{2}='2017-05-14_07.33.15_carbon_ext_trig_shuttle';
[freq,norm_data,xvec,fitted_contrast,peak]= process_data (explimits1);


Power=[170 130 90 50 10 210 250 290];
[sorted_power, IX]=sort(Power);
sorted_peak=peak(IX);

N=size(freq,2);

p = [];

start_fig(1,[3 2]);
% for j=1:N
expt_array=[1:4];

for j1 = 1:size(expt_array,2)
    j=expt_array(j1);
    p1=plot_preliminaries(freq{j},abs(norm_data{j}),j,'nomarker');
    plotsize=length(freq{j});
    p1=plot_preliminaries(freq{j}(1:floor(plotsize/80):end),abs(norm_data{j}(1:floor(plotsize/80):end)),j,'noline');
    set(p1,'markersize',6);
%     p(j)=plot_preliminaries(xvec{j},fitted_contrast{j},j,'nomarker');
%     set(p(j),'linewidth',2);
end
 plot_labels('Frequency [kHz]','Signal [au]');
 set(gca,'xlim',[1000 4200]);
 
%  legend_label = {'Coil','100,v=1000','100,v=2000','100,v=2000,max jerk'};
%  legend(legend_label);


% str = {'Thermal No shuttling','2 watts Sweep 2.76 -2.87 GHz 8 DbM', 'Thermal with shuttling','3 watts Sweep 2.76 -2.87 GHz 8 DbM 3W','3 watts .2 s Sweep 2.76 -2.87 GHz 8 DbM 3W','3 watts .2 s Sweep 2.87 -2.87 GHz 8 DbM 3W'};
% leg = legend(p(expt_array),str(expt_array));


box on;
grid off;

 start_fig(2,[3 2]);
 plot_preliminaries(sorted_power,sorted_peak,1);
 
 
export2base();
end

function [freq,norm_data,xvec,fitted_contrast,peak]= process_data (explimits1)
files_return1= agilent_read_dir2(explimits1);
files_return=[files_return1];

for j=1:size(files_return,2)
   
    MatrixOut{j}=process_varian2(files_return{j},'complete');
    norm_data{j}= abs(MatrixOut{j});
    freq{j}=linspace(0,6.25e3,size(norm_data{j},2));
    [f{j},xvec{j},fitted_contrast{j}] = fit_gaussian(freq{j},abs(norm_data{j}/max(abs(norm_data{j}))));
    fitted_contrast{j}=fitted_contrast{j}*max(abs(norm_data{j}));
    [peak(j),b]=  max(abs(smooth(norm_data{j},500)));
    %peak(j)=(f{j}.m(1) - f{j}.m(4))*max(abs(norm_data{j}));
end

end



function [f,xvec,fitted_contrast]= fit_gaussian(x,y,varargin)
lb=[0,1e3,0.5e3,0];
ub=[1,4e3, 3e3,1];

[v b1]=max(abs(y));
x1=x;y1=y;
a_ini=max(y1);
b_ini=2.5e3;
c_ini=0.75e3;
d_ini=0;
P_ini=[a_ini;b_ini;c_ini;d_ini]; %NOTE that they have to be ordered alphabetically!

f = ezfit(x1, y1, 'y =a*exp(-(x-b).^2/(2*c^2)) + d',P_ini,lb,ub);

xvec=linspace(x1(1),x1(end),1000);
fitted_contrast=f.m(1).*exp(-(xvec-f.m(2)).^2./(2*f.m(3)^2)) + f.m(4);

fun = @(x) f.m(1)*exp(-(x-f.m(2)).^2/(2*f.m(3)^2)) + f.m(4);
area = integral(fun, min(xvec),max(xvec))

start_fig(11,[4 2]);
plot_preliminaries(x1,y1,2,'nomarker');
end

