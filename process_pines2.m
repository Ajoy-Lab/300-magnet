%% Processing of Varian data
% Ashok Ajoy 3/18 2017


clear            


explimits{1}='2017-03-18_10.39.22_carbon_ext_trig_shuttle';
explimits{2}='2017-03-18_12.56.19_carbon_ext_trig_shuttle';

avg=[5 5 5 5 5 5];
times=[75 12.5:12.5:50 5:5:50 5:2:19 60:5:70 100];


files_return= agilent_read_dir(explimits);

%mass_mail(files_return,'complete');

for j=1:size(files_return,2)
    
    MatrixOut{j}=process_varian(files_return{j},'complete');
    norm_data{j}= MatrixOut{j};
    freq{j}=linspace(1,3e3,size(norm_data{j},2));
 [peak(j),b]=max(abs(smooth(norm_data{j},500)));
   
end
  
% start_fig(1,[3 2]);
% for j=1:size(files_return,2)
%     p1=plot_preliminaries(freq{j},real(norm_data{j}),j,'nomarker');
%     plotsize=length(freq{j});
%     p1=plot_preliminaries(freq{j}(1:floor(plotsize/60):end),real(norm_data{j}(1:floor(plotsize/60):end)),j,'noline');
%     set(p1,'markersize',6);
% end



% 
% legend_label = strread(num2str(sorted_time),'%s')
% 
% plot_labels('Frequency [kHz]','Signal [au]');
% legend(legend_label);
% grid off;

[sorted_time, IX]=sort(times);
sorted_peak=peak(IX);
start_fig(2,[1.5 1]);
p1=plot_preliminaries(sorted_time,sorted_peak,1);
plot_labels('Pumping time [s]','Signal [au]');
set(gca,'ylim',[200 1500]);

grid off;