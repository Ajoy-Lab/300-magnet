%% Processing of Varian data
% Ashok Ajoy 3/18 2017


clear            


explimits1{1}='2017-03-18_17.19.07_carbon_ext_trig_shuttle';
explimits1{2}='2017-03-18_17.32.04_carbon_ext_trig_shuttle';


avg=[5 5 5 5 5 5];
times=[75 75 75 75 75];

position=[796 798 802 804 800];

files_return1= agilent_read_dir(explimits1);

files_return=[files_return1];

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