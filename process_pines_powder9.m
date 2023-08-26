%% Enhancements as proportion of powder pattern at different fields


function main
clear            
% 100 MHz bandwidth at 320G
explimits1{1}='2017-05-28_14.08.07_carbon_ext_trig_shuttle';
explimits1{2}='2017-05-28_17.19.31_carbon_ext_trig_shuttle';

% 100 MHz bandwidth at 135G
explimits2{1}='2017-05-26_19.03.27_carbon_ext_trig_shuttle';
explimits2{2}='2017-05-26_21.58.51_carbon_ext_trig_shuttle';



% Experiments at 30G
explimits5{1}='2017-05-24_11.46.22_carbon_ext_trig_shuttle';
explimits5{2}='2017-05-24_18.46.19_carbon_ext_trig_shuttle';



% Thermal at 7T done to compare with 135G
explimits3{1}='2017-05-25_21.39.15_carbon_ext_trig_shuttle';
explimits3{2}='2017-05-25_21.39.15_carbon_ext_trig_shuttle';

% Thermal at 7T done to compare with 320G
explimits4{1}='2017-05-27_16.58.17_carbon_ext_trig_shuttle';
explimits4{2}='2017-05-27_16.58.17_carbon_ext_trig_shuttle';


% Thermal at 7T done to compare with 20G
explimits6{1}='2017-05-25_04.54.08_carbon_ext_trig_shuttle';
explimits6{2}='2017-05-25_04.54.08_carbon_ext_trig_shuttle';

[freq{1},norm_data{1},xvec{1},fitted_contrast{1},area1,peakmax1]= process_data (explimits1);
[freq{2},norm_data{2},xvec{2},fitted_contrast{2},area2,peakmax2]= process_data (explimits2);
[freq{5},norm_data{5},xvec{5},fitted_contrast{5},area5,peakmax5]= process_data (explimits5);
[freq{3},norm_data{3},xvec{3},fitted_contrast{3},area_th,peakmax_th]= process_data (explimits3);
[freq{4},norm_data{4},xvec{4},fitted_contrast{4},area_th2,peakmax_th2]= process_data (explimits4);
[freq{6},norm_data{6},xvec{6},fitted_contrast{6},area_th3,peakmax_th3]= process_data (explimits6);

%enhancement = (300/42.577) * peakmax(1)/peakmax_th / (13.5e-3);

% start_fig(1,[3 2]);
% for j=1:2
%     p1=plot_preliminaries(freq{j}{1},abs(norm_data{j}{1}),j,'nomarker');
%     plotsize=length(freq{j}{1});
%     p1=plot_preliminaries(freq{j}{1}(1:floor(plotsize/80):end),(norm_data{j}{1}(1:floor(plotsize/80):end)),j,'noline');
%     set(p1,'markersize',6);
%     p{j}=plot_preliminaries(xvec{j}{1},fitted_contrast{j}{1},j,'nomarker');
%     set(p{j},'linewidth',2);
% end
%  plot_labels('Frequency [kHz]','Signal [au]');
%  set(gca,'xlim',[1000 4200]);
%  %th=annotation('textarrow',[.3,.6],[.7,.4],'\epsilon=',num2str(enhancement));
%  
% % %  legend_label = {'Thermal at 7T', 'Hyperpolarized at 13.5mT'};
% % %  legend(legend_label);
%  
%  hLegend = legend( ...
% [p{1}, p{2}],...
% 'Hyperpol. at 13.5mT', 'Thermal at 7T',...
% 'location', 'best' );
% set(hLegend, ...
% 'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

 grid off;

 array1=[1.85 1.95 2.05 2.15 2.25 2.35 2.45 2.55 2.65 2.75 2.85 2.95 3.05 3.15 3.05 3.1 3.075 3.125 2.8 2.875];
 [sorted_array1,IX1]=sort(array1);
 sorted_peak1=peakmax1(IX1)/peakmax_th2;
 sorted_area1=area1(IX1)/area_th2;
 
 array2=[2.95 3 3.05 3.1 3.15 3.2 3.25 2.55 2.65 2.75 2.85 3.35 3.45 3.15 2.45 2.35 2.5  3.3 2.9 3 2.875 3.275];
 [sorted_array2,IX2]=sort(array2);
 sorted_peak2=peakmax2(IX2)/peakmax_th;
 sorted_area2=area2(IX2)/area_th;
 
 array5=2.87 + 1e-3*[-170 -130 -90 -50 -10 -210 -250 -290 -110 -150 -30 -70 110 10 30 50 70 90 130 150 170 210 250 290]/2;
 [sorted_array5,IX5]=sort(array5);
 sorted_peak5=peakmax5(IX5)/peakmax_th3;
 sorted_area5=area5(IX5)/area_th3;
 
  %[f,xvec,fitted_contrast]= fit_exp(sorted_array,sorted_peak,sorted_array)
  
 start_fig(2,[3 2]);
 p1=plot_preliminaries(sorted_array1,sorted_peak1,2);
 set(p1,'markersize',9);
  set(p1,'MarkerEdgeColor' , [.2 .2 .2]);
set(p1,'linewidth',1.5);

 p2=plot_preliminaries(sorted_array2,sorted_peak2,1);
 set(p2,'markersize',9);
 set(p2,'MarkerEdgeColor' , [.2 .2 .2]);
set(p2,'linewidth',1.5);

 p3=plot_preliminaries(sorted_array5,sorted_peak5,3);
 set(p3,'markersize',9);
 set(p3,'MarkerEdgeColor' , [.2 .2 .2]);
set(p3,'linewidth',1.5);


 grid off;
  plot_labels('Frequency center [GHz]','Enhancement over 7T');
 set(gca,'xlim',[1.8 3.5]);
  
 hLegend = legend( ...
[p1, p2,p3],...
'32 mT','13.5mT','3 mT',...
'location', 'NorthWest' );
set(hLegend, ...
'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

%% Normalized to compare the three fields
start_fig(3,[3 2]);
 p1=plot_preliminaries(sorted_array1,sorted_peak1/max(sorted_peak1),2);
 set(p1,'markersize',9);
  set(p1,'MarkerEdgeColor' , [.2 .2 .2]);
set(p1,'linewidth',1.5);

 p2=plot_preliminaries(sorted_array2,sorted_peak2/max(sorted_peak2),1);
 set(p2,'markersize',9);
 set(p2,'MarkerEdgeColor' , [.2 .2 .2]);
set(p2,'linewidth',1.5);

 p3=plot_preliminaries(sorted_array5,sorted_peak5/max(sorted_peak5),3);
 set(p3,'markersize',9);
 set(p3,'MarkerEdgeColor' , [.2 .2 .2]);
set(p3,'linewidth',1.5);


 grid off;
  plot_labels('Frequency center [GHz]',' Normalized Enhancement');
 set(gca,'xlim',[1.8 3.5]);
  
 hLegend = legend( ...
[ p3,p2,p1],...
'3 mT','13.5mT','32 mT',...
'location', 'NorthWest' );
set(hLegend, ...
'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

%% Three separate figs
fh=figure(4);clf;
set(fh, 'color', 'white');
set(1,'Units', 'pixels', ...
'Position', [100 100 500 * 4 250 * 2]);clf;
gap=[0.05 0.05];
marg_h=0.15;
marg_v=0.1;
NAxis=3;
subtightplot(1,NAxis,1,gap,marg_h,marg_v);
 p3=plot_preliminaries(sorted_array5,sorted_peak5,3);
 set(p3,'markersize',9);
 set(p3,'MarkerEdgeColor' , [.2 .2 .2]);
set(p3,'linewidth',1.5);
set(gca,'xlim',[1.8 3.5]);
 grid off;
  hLegend = legend( ...
[ p3],...
'3 mT',...
'location', 'NorthWest' );
set(hLegend, ...
'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend
 
 subtightplot(1,NAxis,2,gap,marg_h,marg_v);
 p2=plot_preliminaries(sorted_array2,sorted_peak2,1);
 set(p2,'markersize',9);
 set(p2,'MarkerEdgeColor' , [.2 .2 .2]);
set(p2,'linewidth',1.5);
set(gca,'xlim',[1.8 3.5]);
 grid off;
   hLegend = legend( ...
[ p2],...
'13.5 mT',...
'location', 'NorthWest' );
set(hLegend, ...
'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

 subtightplot(1,NAxis,3,gap,marg_h,marg_v);
p1=plot_preliminaries(sorted_array1,sorted_peak1,2);
 set(p1,'markersize',9);
  set(p1,'MarkerEdgeColor' , [.2 .2 .2]);
set(p1,'linewidth',1.5);
set(gca,'xlim',[1.8 3.5]);
 grid off;
   hLegend = legend( ...
[ p1],...
'35 mT',...
'location', 'NorthWest' );
set(hLegend, ...
'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend
 
 [ax,l1]=suplabel('Frequency center [GHz]');
[ax,l2]=suplabel('Enhancement over 7T','y');
set(l1,'FontName' ,'MyriadPro-Regular','FontSize',15); %Font size of labels
set(l2,'FontName' , 'MyriadPro-Regular','FontSize',15); %Font size of labels

export2base();
end

function [freq,norm_data,xvec,fitted_contrast,area,peakmax]= process_data (explimits1)
files_return1= agilent_read_dir2(explimits1);
files_return=[files_return1];

for j=1:size(files_return,2)
    
    MatrixOut{j}=process_varian2(files_return{j},'complete');
    norm_data{j}= abs(MatrixOut{j});
    freq{j}=linspace(0,6.25e3,size(norm_data{j},2));
    IX=find(freq{j}>1.5e3 & freq{j}<3.5e3);
    IX2=find(freq{j}>2.2e3 & freq{j}<2.8e3);
    
    [f{j},xvec{j},fitted_contrast{j}] = fit_Lorentzian(freq{j}(IX),((norm_data{j}(IX)/max(abs(norm_data{j})))),freq{j});
    fitted_contrast{j}=fitted_contrast{j}*max(abs(norm_data{j}));
    peakmax(j)=max(abs(norm_data{j}));
    area(j)= trapz(freq{j}(IX2),abs(norm_data{j}(IX2)),2);
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

start_fig(11,[4 2]);
plot_preliminaries(x1,y1,2,'nomarker');
plot_preliminaries(xvec,fitted_contrast,2,'nomarker');
end

function [f,xvec,fitted_contrast]= fit_Lorentzian(x,y,xaxis)
lb=[0,2e3,0.1e3,0];
ub=[1,3e3, 1.5e3,1.5];

[v b1]=max(abs(y));
x1=x;y1=y;
a_ini=max(y1);
b_ini=2.5e3;
c_ini=0.75e3;
d_ini=0;
P_ini=[a_ini;b_ini;c_ini;d_ini]; %NOTE that they have to be ordered alphabetically!

f = ezfit(x1, y1, 'y =a/(pi*(1+( (x-b) / c)^2))+d',P_ini,lb,ub);

xvec=linspace(xaxis(1),xaxis(end),1000);
fitted_contrast=f.m(1)./(pi*(1+( (xvec-f.m(2)) ./ f.m(3)).^2))+f.m(4);
% 
% start_fig(11,[4 2]);
% plot_preliminaries(x1,y1,2,'nomarker');
% plot_preliminaries(xvec,fitted_contrast,2,'nomarker');
end

function [f,xvec,fitted_contrast]= fit_exp(x,y,xaxis)
lb=[0,0.1,0];
ub=[1,6,1.5];

[v b1]=max(abs(y));
x1=x;y1=y;
a_ini=max(y1);
b_ini=1;
d_ini=0;
P_ini=[a_ini;b_ini;d_ini]; %NOTE that they have to be ordered alphabetically!

f = ezfit(x1, y1, 'y =a*(1 - exp(-x/b)) + d',P_ini,lb,ub);

xvec=linspace(xaxis(1),xaxis(end),1000);
fitted_contrast=f.m(1).*(1 - exp(-xvec./f.m(2))) + f.m(3);

start_fig(11,[4 2]);
plot_preliminaries(x1,y1,2,'nomarker');
plot_preliminaries(xvec,fitted_contrast,2,'nomarker');
end

