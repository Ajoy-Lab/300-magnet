% File to plot experimental LPF from Rigol data

function main
clear;clc;

fn='D:\code\SavedExperiments\';

explimits{1}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-06-125506';
explimits{2}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-07-020232';
explimits{3}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-07-125334';
[x_con_AC, norm_AC5, n5,field,Pfit5,xx5,yy5,Pvec5] = process_rigol_multi_exp(explimits);

turn5=mean(Pvec5{2});
err5=std(Pvec5{2});
 %% Calc of total time
n=n5;
Tcpmg=(35.5e-9*2+50e-9)*2;
Ttot=4*n*Tcpmg;
freq=x_con_AC;
filter=(sin(pi*freq.*Ttot)./(2*pi*freq)).^2;
filter=abs(filter./max(filter));

%% XY8-8 experiments
%dataset 1
clear explimits;
explimits{1}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-07-214836';
explimits{2}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-08-022540';
[x_con8, norm_AC8, n8,field,Pfit8,xx8,yy8,Pvec8] = process_rigol_multi_exp(explimits);

turn8=mean(Pvec8{2});
err8=std(Pvec8{2});

Ttot8=4*n8*Tcpmg;
%Ttot8=4*13*Tcpmg;
filter8=(sin(pi*freq.*Ttot8)./(2*pi*freq)).^2;
filter8=abs(filter8./max(filter8));

%% XY8-13 experiments
clear explimits;
explimits{1}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-09-201723';
explimits{2}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-09-234213';
explimits{3}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-10-030733'
%explimits{3}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-10-063258'
[x_con13, norm_AC13, n13,field,Pfit13,xx13,yy13,Pvec13] = process_rigol_multi_exp(explimits);

turn13=mean(Pvec13{2});
err13=std(Pvec13{2});

Ttot13=4*n13*Tcpmg;
filter13=(sin(pi*freq.*Ttot13)./(2*pi*freq)).^2;
filter13=abs(filter13./max(filter13));

% %% XY8-20 experiments
% clear explimits;
% explimits{1}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-10-162049';
% 
% %explimits{3}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-10-063258'
% [x_con20, norm_AC20, n20,field,Pfit20,xx20,yy20] = process_rigol_multi_exp(explimits);
% 
% Ttot20=4*n20*Tcpmg;
% filter20=(sin(pi*freq.*Ttot20)./(2*pi*freq)).^2;
% filter20=abs(filter20./max(filter20));

%% XY8-3 experiments
clear explimits;
explimits{1}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-11-012633';
explimits{2}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-11-054532';
explimits{3}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-11-100344';
explimits{4}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-11-142309';
explimits{5}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-11-184513';
explimits{6}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-11-230448';
explimits{7}='1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-05-12-032458';
[x_con3, norm_AC3, n3,field,Pfit3,xx3,yy3,Pvec3] = process_rigol_multi_exp(explimits);

turn3=mean(Pvec3{2});
err3=std(Pvec3{2});

Ttot3=4*n3*Tcpmg;
filter3=(sin(pi*freq.*Ttot3)./(2*pi*freq)).^2;
filter3=abs(filter3./max(filter3));

%% PLot
start_fig(1,[4 2]);
p1=plot_preliminaries(x_con_AC/1e3,1-norm_AC5,1,'noline');
set(p1,'Linewidth',0.5);
%plot_preliminaries(x_con_AC/1e3,filter,1,'nomarker');
plot_preliminaries(xx5/1e3,yy5,1,'nomarker');
p2=plot_preliminaries(x_con8/1e3,1-norm_AC8,2,'noline');
set(p2,'Linewidth',0.5);
%plot_preliminaries(x_con_AC/1e3,filter8,2,'nomarker');
plot_preliminaries(xx8/1e3,yy8,2,'nomarker');
p3=plot_preliminaries(x_con13/1e3,norm_AC13,3);
set(p3,'Linewidth',0.5);
%plot_preliminaries(x_con_AC/1e3,filter13,3,'nomarker');
plot_preliminaries(xx13/1e3,yy13,2,'nomarker');

p4=plot_preliminaries(x_con3/1e3,1-norm_AC3,4);
set(p4,'Linewidth',0.5);
%plot_preliminaries(x_con_AC/1e3,filter3,4,'nomarker');
plot_preliminaries(xx3/1e3,yy3,4,'nomarker');
set(gca,'xlim',[0 300]);

plot_labels('Frequency [kHz]','Normalized signal')


%% PLot now the turning points
cycle=([n3 n5 n8 n13]*8);
%turning_freq=1e-3./[Pfit3(2) Pfit5(2) Pfit8(2) Pfit13(2)];
turning_freq=1e-3./[turn3 turn5 turn8 turn13];
error_freq=(1e-3./[turn3-err3 turn5-err5 turn8-err8 turn13-err13]) - (1e-3./[turn3+err3 turn5+err5 turn8+err8 turn13+err13]);
cycle_extrapolated=[20:0.1:150];
%turning_freq=[Pfit5(2) Pfit8(2) Pfit13(2)]./cycle;
start_fig(2,[1.5 1]);
[f2,cycle_xvec,fitted]= fit_linear(1./cycle,turning_freq,1./cycle_extrapolated)
p1=plot_preliminaries(cycle,turning_freq,1,'noline');
set(p1,'Markersize',7.5);
plot_error(cycle,turning_freq,error_freq,1);
p1=plot_preliminaries(1./cycle_xvec,fitted,1,'nomarker');
set(p1,'Markersize',7.5);
plot_labels('Number of Pulses','Filter Cufoff [kHz]');
set(gca,'ylim',[0 400]);
set(gca,'xlim',[0 150]);
grid off;
%set(gca,'XDir','reverse');

%% Actual good looking plot
start_fig(3,[3 1.2]);
p1=plot_preliminaries(x_con_AC/1e3,1-norm_AC5,1,'noline');
%plot_preliminaries(xx5/1e3,yy5,1,'nomarker');
plot_preliminaries(x_con_AC/1e3,filter,1,'nomarker');
p2=plot_preliminaries(x_con8/1e3,1-norm_AC8,2,'noline');
%plot_preliminaries(xx8/1e3,yy8,2,'nomarker');
plot_preliminaries(x_con_AC/1e3,filter8,2,'nomarker');
p3=plot_preliminaries(x_con3/1e3,1-norm_AC3,4,'noline');
%plot_preliminaries(xx3/1e3,yy3,4,'nomarker');
plot_preliminaries(x_con_AC/1e3,filter3,4,'nomarker');

plot_xline(0,1);
plot_xline(1,1);
set(gca,'xlim',[0 250]);
set(gca,'ylim',[-0.1 1.1]);

plot_labels('Frequency [kHz]','Normalized signal')
grid off;
hLegend = legend( ...
[p3,p1,p2],...
'XY8-3','XY8-5','XY8-8',...
'location', 'best' );
set(hLegend, ...
'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

 %% Retrieve and process scope data

 explimits1{1}='scope-2016-05-06-125433.mat'
explimits1{2}=explimits1{1};
[peakval1, contrast1]=process_scope_data(explimits1);

explimits2{1}='scope-2016-05-06-171503.mat'
explimits2{2}=explimits2{1};
[peakval2, contrast2]=process_scope_data(explimits2);

peakval=[peakval1 peakval2];
contrast=[contrast1 contrast2];

% start_fig(2,[3 2]);
% plot_preliminaries(peakval,(contrast)/max(contrast),1);
% set(gca,'xlim',[0 800e3]);

export2base();

end

function [x_con_AC, norm_AC_data, nvalue,field,P_fit,xx,yy,Pvec] = process_rigol_multi_exp(explimits,varargin)
for j=1:size(explimits,2)
    explimits1{1}=explimits{j};
     [x_con_AC, norm_AC_data, nvalue,field,bare_data(j,:),DC_data(j,:),AC_data(j,:)] = process_rigol_data(explimits1,1);
end
DC_level=mean(mean(DC_data));
bare_level=mean(mean(bare_data));

AC_level=mean(AC_data,1);
%bare_level=mean(AC_level(end-20:end));

contrast_level=abs(DC_level-bare_level);
mean_level=1/2*(DC_level+bare_level);
norm_AC_data=1/2+(AC_level-mean_level)/contrast_level;

Tcpmg=(35.5e-9*2+50e-9)*2;
Ttot=4*nvalue*Tcpmg;
% filter=(sin(pi*freq.*Ttot)./(2*pi*freq)).^2;
% filter=abs(filter./max(filter));

%attempt a fit
freq=x_con_AC;
if nvalue<10 || nvalue>=20
x1=freq;y1=1-norm_AC_data;
P_ini=[1,Ttot,mean(y1(end-20:end))];
else
    x1=freq;y1=norm_AC_data;
    x1=smooth(x1,4);y1=smooth(y1,4);
    x1=x1(9:end);y1=y1(9:end);
    P_ini=[y1(1),Ttot,mean(y1(end-20:end))];
end

[P_fit,xx,yy]=fit_filter(x1,y1,P_ini);
Pvec=fit_filter_with_error(x1,y1,P_fit);

end

function [x_con_AC, norm_AC_data, nvalue,field,bare_data,DC_data,AC_data] = process_rigol_data(explimits,varargin)
fn='D:\code\SavedExperiments\';


selected_expts{1}=explimits;
data{1}{1}= explimits{1};% '1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-04-16-112506';
Scan=load([fn explimits{1}]);
[x_con Y1_con Y1_std]=concatenate_qeg_set4_4(data);
datasize=size(Y1_con,1);
DC_vec=[10:10:datasize];
bare_vec=[11:11:datasize];
AC_vec=1:datasize;
AC_vec([DC_vec bare_vec])=[];



for k=1:size(Y1_con,2)
        DC_data_vec(:,k)=Y1_con(DC_vec,k);
        bare_data_vec(:,k)=Y1_con(bare_vec,k);
        AC_data_vec(:,k)=Y1_con(AC_vec,k);
end
x_con_AC=x_con(AC_vec);

 
if size(Y1_con,2) ~=1
bare_data=mean(bare_data_vec');
DC_data=mean(DC_data_vec');
AC_data=mean(AC_data_vec');

else
    bare_data=bare_data_vec;
DC_data=DC_data_vec;
AC_data=AC_data_vec;
end

if nargin>1
AC_data(1) = mean(DC_data);
end

nvalue=Scan.Scan.Variable_values{8}.value;
field=Scan.Scan.Variable_values{3}.value;

DC_level=mean(DC_data);
bare_level=mean(bare_data);
%bare_level=mean(AC_data(end-10:end));
% Now the AC data is supposed to lie between these two rails;
contrast_level=abs(DC_level-bare_level);
mean_level=1/2*(DC_level+bare_level);

%AC_data=DC_level*ones(1,size(AC_data,2)); % for checking the rails are OK
norm_AC_data=1/2+(AC_data-mean_level)/contrast_level;
end


function [peakval, contrast]=process_scope_data(explimits,varargin)
fn='D:\code\SavedExperiments\';


selected_expts{1}=explimits;
data{1}{1}= explimits{1};% '1DExp-seq-AWG_supersampling_rigol2-vary-rigol_freq-2016-04-16-112506';
Scan=load([fn explimits{1}]);

datasize=size(Scan.scope,2);
DC_vec=[10:10:datasize];
bare_vec=[11:11:datasize];
AC_vec=1:datasize;
AC_vec([DC_vec bare_vec])=[];


for j=1:size(AC_vec,2)
    trace(j,:)= Scan.scope{AC_vec(j)}.scaleYperPoint*Scan.scope{AC_vec(j)}.trace';
    trace_x(j,:)= 0:Scan.scope{AC_vec(j)}.scaleXperPoint:Scan.scope{AC_vec(j)}.scaleXperPoint*(size(Scan.scope{AC_vec(j)}.trace',2)-1);
    [DataX,DataY]= calc_fft(trace_x(j,:), trace(j,:));
    [contrast_temp,peakval_index]=max(DataY);
    peakval(j)=DataX(peakval_index);
    contrast(j)=4*sqrt(contrast_temp/pi);
 %[fvolt,DataXvec,fitted_FFT,peakval(j),contrast(j),peak(j),contrast(j)] =fit_FFT (DataX,DataY);
end
%contrast=contrast/max(contrast);
end

function [out,xx,yy]=fit_filter(varargin)
% x and y are input vectors of the noisy data
% this routine tries to find the optimal fit of a Lorentzian f(x)=a/ (pi * (1- [(x-x0)/b]^2) )) + c  to fit the data

x=varargin{1};
y=varargin{2};
P_ini=varargin{3};
x=x*1e-6; P_ini(2)=P_ini(2)*1e6;

P= fminsearch(@deviation_fct, P_ini);   %now look for the minimum of this deviation function defined below

str='P= fminsearch(@deviation_fct, P_ini);';
r=evalc(str)

    function out=deviation_fct(P)      %nested function to return the deviation for a given set of parameters P
        a=P(1);
        b=P(2);
        c=P(3);
        out=0;
        f =a*(sin(pi.*x*b)./(pi*x)).^2;
        f=f/max(f) +c;
        f=f/max(f);
       
          residual=(y- f ).^2;
        residual(isnan(residual))=[];
        out=sum(residual);
    end
x=x*1e6; P(2)=P(2)*1e-6;
start_fig(10,[3 2]);
plot_preliminaries(x,y,1,'noline');
xx=linspace(min(x),max(x),1000);
yy=P(1)*(sin(pi.*xx*P(2))./(pi.*xx)).^2;
yy=yy/max(yy) + P(3);
yy=yy/max(yy);
plot_preliminaries(xx,yy,1,'nomarker');

out=P;
deviation=deviation_fct(out);
end


function [out,xx,yy]=fit_filter_with_error(varargin)
x=varargin{1};
y=varargin{2};
P_ini=varargin{3};

P_best=fit_filter(x,y,P_ini);
F=f(x,P_best);
residual=(y- F);
residual(isnan(residual))=[];
sigma_y=std(residual);

runs=100;
for run=1:runs;
    %generate some noisy data with Gaussian noise of the same magnitude
    y_test=F+sigma_y*randn(size(x));   %assume equal errors in y for each data point
    P_rec=fit_filter(x,y_test, P_best);
    for cc=1:3;P_vec{cc}(run)=P_rec(cc);end
    %save P_vec P_vec
    %run
end
    
out=P_vec;

    function out3=f(X,P)
        yy=P(1)*(sin(pi.*X*P(2))./(pi.*X)).^2;
yy=yy/max(yy) + P(3);
yy=yy/max(yy);
out3=yy;
    end


end

function [f2,xvec,fitted]= fit_linear(x,y,varargin)
x(isnan(y))=[]; %to remove the NaNs
y(isnan(y))=[]; %to remove the NaNs
f2 = ezfit(x,y, 'z(v)=poly1');
if(nargin>2)
    xvec=varargin{1};
else
xvec=linspace(x(1),x(end),1000);
end
fitted=(f2.m(1) + f2.m(2).*xvec);

end
