%% Processing of Varian data
% Ashok Ajoy 3/18 2017


clear            


explimits1{1}='2017-03-18_10.39.22_carbon_ext_trig_shuttle';
explimits1{2}='2017-03-18_10.39.22_carbon_ext_trig_shuttle';

explimits2{1}='2017-03-18_14.05.14_carbon_ext_trig_shuttle';
explimits2{2}='2017-03-18_14.05.14_carbon_ext_trig_shuttle';

explimits3{1}='2017-03-18_14.32.55_carbon_ext_trig_shuttle';
explimits3{2}='2017-03-18_15.19.31_carbon_ext_trig_shuttle';


avg=[5 5 5 5 5 5];
times=[75 75 75 75 75];
positions=[800 900 1000 1100 950 975];


files_return1= agilent_read_dir(explimits1);
files_return2= agilent_read_dir(explimits2);
files_return3= agilent_read_dir(explimits3);

files_return=[files_return1 files_return2 files_return3];

mass_mail(files_return,'complete');

for j=1:size(files_return,2)
    
    MatrixOut{j}=process_varian(files_return{j},'complete');
    norm_data{j}= MatrixOut{j};
    freq{j}=linspace(1,3e3,size(norm_data{j},2));
   peak(j)=max(abs(norm_data{j}));
   
end
  
start_fig(1,[3 2]);
for j=1:size(files_return,2)
    p1=plot_preliminaries(freq{j},abs(norm_data{j}),j,'nomarker');
    plotsize=length(freq{j});
    p1=plot_preliminaries(freq{j}(1:floor(plotsize/60):end),abs(norm_data{j}(1:floor(plotsize/60):end)),j,'noline');
    set(p1,'markersize',6);
end
 plot_labels('Frequency [kHz]','Signal [au]');
%  legend_label = {'Coil','100,v=1000','100,v=2000','100,v=2000,max jerk'};
%  legend(legend_label);
 grid off;
% 

% 

% [sorted_time, IX]=sort(times);
% sorted_peak=peak(IX);
% 

% grid off;
% 
% start_fig(2,[3 2]);
% p1=plot_preliminaries(sorted_time,sorted_peak,1);
% plot_labels('Pumping time [s]','Signal [au]');
% 
% grid off;