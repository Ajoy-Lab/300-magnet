%% Processing of Varian data
% Ashok Ajoy 3/18 2017


clear            


explimits{1}='2017-03-16_17.44.26_carbon_ext_trig_shuttle';
explimits{2}='2017-03-16_20.35.26_carbon_ext_trig_shuttle';

avg{1}='107';
avg{2}='complete';


files_return= agilent_read_dir(explimits);

%mass_mail(files_return,'complete');

%% Get and process data
for j=1:size(files_return,2)
    MatrixOut{j}=process_varian(files_return{j},avg{j});
    norm_data{j}= MatrixOut{j};
    freq{j}=linspace(1,6.25e3,size(norm_data{j},2));
  [peak(j),b]=max(abs(smooth(norm_data{j},500)));
%    [P,r]=fit_Lorentzian_peak(freq{j}, norm_data{j});
%    xx=freq{j};
%    fitted{j}=P(1)./ (pi * ( 1+  ((xx-P(4))/P(2) ).^2) ) + P(3);
end
  

enhancement=peak(2)/peak(1);
%% Plot data
start_fig(1,[3.5 1]);
for j=1:size(files_return,2)
    p1(j)=plot_preliminaries(freq{j}/1e3,norm_data{j},j,'nomarker');
%     p1=plot_preliminaries(freq{j},fitted{j},j,'noline');
%      set(p1,'lw',1.5);
    plotsize=length(freq{j});
    p2=plot_preliminaries(freq{j}(1:floor(plotsize/90):end)/1e3,norm_data{j}(1:floor(plotsize/90):end),j,'noline');
    set(p2,'markersize',7);
end
plot_labels('Frequency [kHz]','Signal [au]');
hLegend=legend([p1(1) p1(2)],'Thermal','Pumped','location','NorthEast');
set(hLegend,'FontName','MyriadPro-Regular','FontSize',13);
set(gca,'ylim',[0 8e4]);
set(gca,'xlim',[0 5]);
grid off;