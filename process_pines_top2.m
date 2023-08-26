%% Enhancements as proportion of powder pattern at different fields
%use process_pines_top2 to calculate enhancements of complete fids.

function main
clear            
path='Z:\FID_spectra\';
thermal= make_fn_thermal('2017-06-22_18.21.19_carbon_ext_trig_shuttle',path);
%dnp=make_fn('2017-06-15_22.36.16_carbon_ext_trig_shuttle',path);
x_axis=[1:1:20];



%process_enhancement(thermal,dnp)

% %sweep time
% explimits{1}='2017-06-15_19.59.37';
% explimits{2}='2017-06-15_22.54.07';

%wait time
explimits{1}='2017-07-12_13.04.06';
explimits{2}='2017-07-12_13.04.06';

% explimits{1}='2017-06-15_22.36.16';
% explimits{2}='2017-06-15_22.36.16';

files=get_files(explimits);

for j=1:numel(files)
    j
       spec2 = process_spectrum(thermal, 0, true);
    for k=1:5
        k
        if k==5
            dnp_2=make_fn(files{j},path,'complete');
            dnp_1 = make_fn(files{j}, path,k-1);

        else
            dnp_2=make_fn(files{j},path,k);
            dnp_1 = make_fn(files{j}, path,k-1);
            
        end
    if k == 1
        spec3 = process_spectrum(dnp_2, 0, true);
    else
        spec3 = process_spectrum(dnp_1, dnp_2, false);
    end
    [enhancementFactor(k),fwhm3,spec20{k},spec30{k}]=process_enhancement(spec2,spec3,1);
        %use below code to graph complete (summed) fid only.
%       [enhancementFactor(k),fwhm3,spec20{j},spec30{j}]=process_enhancement(spec2,spec3,15);

    end
    plot(1:15, enhancementFactor)

% dnp_2=make_fn(files{j},path,'complete');
% spec3 = process_spectrum(dnp_2, 0, true);
% k=1;
% 
% %      [enhancementFactor(j),fwhm3,spec20{j},spec30{j}]=process_enhancement(spec2,spec3,0,15);
%      [enhancementFactor(j),fwhm3,spec20{j},spec30{j}]=process_enhancement_freq(spec2,spec3,0,15);

    
    
%     freq20=linspace(0,6.25e3,size(real(spec20{j}),2));
%     freq30=linspace(0,6.25e3,size(real(spec30{j}),2));
%     [f,xvec20,fitted_contrast20]=make_fit_Lorentzian(freq20,real(spec20{j}));
%     [f,xvec30,fitted_contrast30]=make_fit_Lorentzian(freq30,real(spec30{j}));
%     
%     start_fig(10,0.75*[2.25 2]);
%     p1=plot_preliminaries(freq20/1e3,real(spec20{j}),2,'nomarker');
%     set(p1,'linewidth',1);
%  
%        p1=plot_preliminaries(freq30/1e3,real(spec30{j}),1,'nomarker');
%     set(p1,'linewidth',1);
%         p1=plot_preliminaries(xvec20/1e3,fitted_contrast20,2,'nomarker');
%     set(p1,'linewidth',1.125);
%     p1=plot_preliminaries(xvec30/1e3,fitted_contrast30,1,'nomarker');
%     set(p1,'linewidth',1.125);
%     set(gca,'ylim',[-10 140]);
%     set(gca,'xlim',[1000 4000]/1e3);
%     plot_labels('Frequency [kHz]','Signal [au]');
%     legend({'Thermal at 7T ', 'Hyp. at 8 mT '}...
%         ,'FontSize', 9, 'Position', [0.645 0.64 .08 .08])
%     set(gca,'tickdir','in');
%     text(2.65 ,max(real(spec20{j})),['x120'], 'FontSize', 12,'FontName' , 'MyriadPro-Regular');
%     text(2.65, 50, max(real(spec20{j})),['x15'], 'FontSize', 12,'FontName' , 'MyriadPro-Regular');
%     text(1.5, 100,['\epsilon = ' num2str(ceil(enhancementFactor(k)))], 'FontSize', 15,'FontName' , 'MyriadPro-Regular');
% box on;
         
%     load mean_enhancement
    x_axis=[1000:-25:25];



    mean_enhancementFactor(j)=mean(enhancementFactor);
     max_enhancementFactor(j)=max(enhancementFactor);
     min_enhancementFactor(j)=min(enhancementFactor);
    err_enhancementFactor(j)=std(enhancementFactor);

end

std_err_enhancementFactor = err_enhancementFactor./sqrt(15);
%MAKE SURE TO CHANGE LATER CHANGE
x_axis = 1:1:20
start_fig(3,[2 2]);
 gap=[0.05 0.05];
marg_h=0.15;
marg_v=0.18;
subtightplot(1,1,1,gap,marg_h,marg_v);
% for graphing complete fid only
p1 = plot_preliminaries(x_axis,enhancementFactor,3);
set(p1, 'MarkerSize', 9)
plot_preliminaries(x_axis, smooth(enhancementFactor, 6), 3, 'nomarker');
plot_labels('Sweep Frequency [Hz]','Enhancement over 7T')
set(gca,'tickdir','in')
set(gca, 'ticklength', [.01; .01]);
set(p1, 'Linewidth', .5);
plot(ones(1,31)*175,[0:30],'k--');
text(600,10,['Not adiabatic'], 'FontSize', 11,'FontName' , 'MyriadPro-Regular', 'FontAngle', 'italic');
box on

plot_preliminaries(x_axis,mean_enhancementFactor,3);
%plot_preliminaries(x_axis,max_enhancementFactor,2);
%plot_preliminaries(x_axis,min_enhancementFactor,1);


export2base();
end

function new_fn= make_fn(fn,path,exp_number)
new_fn=[path fn '\' num2str(exp_number) '.fid\fid'];
end

function new_fn= make_fn_thermal(fn,path)
new_fn=[path fn '\complete.fid\fid']
end

function files=get_files(explimits)
explimits2{1}=[explimits{1} '_carbon_ext_trig_shuttle'];
explimits2{2}=[explimits{2} '_carbon_ext_trig_shuttle'];
files= agilent_read_dir2(explimits2);
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
start_fig(11,[4 2]);
plot_preliminaries(x1,y1,2,'nomarker');
plot_preliminaries(xvec,fitted_contrast,2,'nomarker');
end

function [f,xvec,fitted_contrast]= fit_exp2(x,y,xaxis)
lb=[20,20,5];
ub=[27,60,8];

[v b1]=max(abs(y));
x1=x;y1=y;
a_ini=max(y1);
b_ini=36;
d_ini=min(y1);
P_ini=[a_ini;b_ini;d_ini]; %NOTE that they have to be ordered alphabetically!

f = ezfit(x1, y1, 'y =a*(1 - exp(-x/b)) + d',P_ini,lb,ub);

xvec=linspace(xaxis(1),xaxis(end),1000);
fitted_contrast=f.m(1).*(1 - exp(-xvec./f.m(2))) + f.m(3);

% start_fig(11,[4 2]);
% plot_preliminaries(x1,y1,2,'nomarker');
% plot_preliminaries(xvec,fitted_contrast,2,'nomarker');
end

function  [f,xvec,fitted_contrast]=make_fit_Lorentzian(x,spec20)
[maxval,pivot]=max(abs(spec20));
y=spec20/maxval;
xaxis=x;
 [f,xvec,fitted_contrast]= fit_Lorentzian(x,y,xaxis);
 fitted_contrast=fitted_contrast*maxval;
end