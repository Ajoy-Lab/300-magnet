function main
clear all;

fn='D:\code\SavedExperiments\';

explimits{1}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-02-12-000214.mat';
explimits{2}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-02-12-231633.mat';
selected_expts1=qeg_read_dir2_4(explimits);


explimits{1}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-02-19-175559.mat';
explimits{2}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-02-20-004537.mat';
selected_expts3=qeg_read_dir2_4(explimits);

explimits{1}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-03-16-132632.mat'
explimits{2}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-03-17-180122.mat'
selected_expts6=qeg_read_dir2_4(explimits);

explimits{1}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-04-01-204332.mat'
explimits{2}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-04-02-152419.mat'
selected_expts7=qeg_read_dir2_4(explimits);


%% We just want the data near 133MHz so that we can compare the contrast with Ramsey

explimits{1}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-02-14-140546.mat';
explimits{2}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-02-14-185300.mat';
selected_expts2=qeg_read_dir2_4(explimits);


%% This is probably the most sensitive data we have

explimits{1}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-03-09-190106.mat'
explimits{2}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-03-11-005727.mat'
selected_expts5=qeg_read_dir2_4(explimits);

%% Another in between data

explimits{1}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-02-23-152631.mat'
explimits{2}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-BNC_ampl-2016-02-23-233256.mat'
selected_expts4=qeg_read_dir2_4(explimits);
%% Measurement of the correspodning intrinsic misalignments
intrinsic_expts{1}='1DExp-seq-AWG_optimal_construction_with_BNC-vary-n-2016-02-14-204936';

[nsweep,norm_data_bare1_int,norm_data_volt1_int, DataX1_int, DataY1_int, DataXvec1_int, fitted1_int,...
    sorted_nvalue1_int, sorted_nvalue_index_int, peak_int,field_int] =get_data (intrinsic_expts);
% This is the calculation of intrinsic misalignment
Bint = 1e-6.*tan(1/2*peak_int*1/4).*field_int.*(4.95-2.16/2)/2.62; %add the fact that XY8 number to divide by 1/4 the frequency

[voltage2,norm_data_bare2,norm_data_volt2, DataX2, DataY2, DataXvec2, fitted2, sorted_nvalue2,sorted_nvalue_index2, sorted_peakval2,sorted_peakerr2,sorted_peakwidth2,sorted_contrast2,sorted_contrasterr2,field2] =get_data (selected_expts2);
make_plot (401,voltage2,norm_data_bare2,norm_data_volt2, DataX2, DataY2, DataXvec2, fitted2, sorted_nvalue2, sorted_nvalue_index2, sorted_peakval2,sorted_peakerr2);

[voltage5,norm_data_bare5,norm_data_volt5, DataX5, DataY5, DataXvec5, fitted5, sorted_nvalue5,sorted_nvalue_index5, sorted_peakval5,sorted_peakerr5,sorted_peakwidth5,sorted_contrast5,sorted_contrasterr5,field5] =get_data (selected_expts5);
[voltage4,norm_data_bare4,norm_data_volt4, DataX4, DataY4, DataXvec4, fitted4, sorted_nvalue4,sorted_nvalue_index4, sorted_peakval4,sorted_peakerr4,sorted_peakwidth4,sorted_contrast4,sorted_contrasterr4,field4] =get_data (selected_expts4);
[voltage1,norm_data_bare1,norm_data_volt1, DataX1, DataY1, DataXvec1, fitted1, sorted_nvalue1,sorted_nvalue_index1, sorted_peakval1,sorted_peakerr1,sorted_peakwidth1,sorted_contrast1,sorted_contrasterr1,field1] =get_data (selected_expts1);
[voltage3,norm_data_bare3,norm_data_volt3, DataX3, DataY3, DataXvec3, fitted3, sorted_nvalue3,sorted_nvalue_index3, sorted_peakval3,sorted_peakerr3,sorted_peakwidth3,sorted_contrast3,sorted_contrasterr3,field3] =get_data (selected_expts3);
[voltage6,norm_data_bare6,norm_data_volt6, DataX6, DataY6, DataXvec6, fitted6, sorted_nvalue6,sorted_nvalue_index6, sorted_peakval6,sorted_peakerr6,sorted_peakwidth6,sorted_contrast6,sorted_contrasterr6,field6] =get_data (selected_expts6);
[voltage7,norm_data_bare7,norm_data_volt7, DataX7, DataY7, DataXvec7, fitted7, sorted_nvalue7,sorted_nvalue_index7, sorted_peakval7,sorted_peakerr7,sorted_peakwidth7,sorted_contrast7,sorted_contrasterr7,field7] =get_data (selected_expts7);

%% Calculation of bare contrasts
 bare_contrast_xy8_2= calc_bare_contrast(norm_data_bare2);
 bare_contrast_xy8_4= calc_bare_contrast(norm_data_bare4);
 bare_contrast_xy8_5= calc_bare_contrast(norm_data_bare5);
 bare_contrast_xy8_1= calc_bare_contrast(norm_data_bare1);
 bare_contrast_xy8_3= calc_bare_contrast(norm_data_bare3);
 bare_contrast_xy8_6= calc_bare_contrast(norm_data_bare6);
 bare_contrast_xy8_7= calc_bare_contrast(norm_data_bare7);
%% Now this is the corresponding Ramsey data
% Ramsey sweeping length
explimits_ramsey1{1}='1DExp-seq-AWG_ramsey_with_BNC-vary-BNC_ampl-2016-03-29-204320.mat';
explimits_ramsey1{2}='1DExp-seq-AWG_ramsey_with_BNC-vary-BNC_ampl-2016-03-30-031118.mat';
[voltage_ramsey1,norm_data_bare_ramsey1,norm_data_volt_ramsey1,tau1,ramsey_field1] =process_mag_data_ramsey (explimits_ramsey1,fn);
 [fvolt_field1,DataXvec_field1,fitted_field1,peakval1,contrast1,peakerr1,contrasterr1] = process_FFT(voltage_ramsey1,norm_data_volt_ramsey1,tau1);
 bare_contrast1= calc_bare_contrast(norm_data_bare_ramsey1);

  
% Ramsey sweeping length 2
explimits_ramsey2{1}='1DExp-seq-AWG_ramsey_with_BNC-vary-BNC_ampl-2016-03-28-235637.mat';
explimits_ramsey2{2}='1DExp-seq-AWG_ramsey_with_BNC-vary-BNC_ampl-2016-03-28-235637.mat';
[voltage_ramsey2,norm_data_bare_ramsey2,norm_data_volt_ramsey2,tau2] =process_mag_data_ramsey (explimits_ramsey2,fn);
 [fvolt_field2,DataXvec_field2,fitted_field2,peakval2,contrast2,peakerr2,contrasterr2] = process_FFT(voltage_ramsey2,norm_data_volt_ramsey2,tau2);
 bare_contrast2= calc_bare_contrast(norm_data_bare_ramsey2);

% Ramsey sweeping length 3
explimits_ramsey3{1}='1DExp-seq-AWG_ramsey_with_BNC-vary-BNC_ampl-2016-03-30-105745.mat';
explimits_ramsey3{2}=explimits_ramsey3{1};
%explimits_ramsey3{2}='1DExp-seq-AWG_ramsey_with_BNC-vary-BNC_ampl-2016-03-30-134913.mat';
[voltage_ramsey3,norm_data_bare_ramsey3,norm_data_volt_ramsey3,tau3] =process_mag_data_ramsey (explimits_ramsey3,fn);
 [fvolt_field3,DataXvec_field3,fitted_field3,peakval3,contrast3,peakerr3,contrasterr3] = process_FFT(voltage_ramsey3,norm_data_volt_ramsey3,tau3);
bare_contrast3= calc_bare_contrast(norm_data_bare_ramsey3);
 
 tau_combined=[tau1 tau2 tau3];
 peakval_combined=[peakval1 peakval2 peakval3];
 peakerr_combined=[peakerr1 peakerr2 peakerr3];
 contrast_combined=[contrast1 contrast2 contrast3];
 bare_contrast_combined= [bare_contrast1 bare_contrast2 bare_contrast3];
 contrasterr_combined=[contrasterr1 contrasterr2 contrasterr3];
 
 [tau,IX]=sort(tau_combined);
 peakval=peakval_combined(IX);
 peakerr=peakerr_combined(IX);
 contrast=contrast_combined(IX);
 bare_contrast_ramsey=bare_contrast_combined(IX);
 contrasterr=contrasterr_combined(IX);
 
 %[f2,tau_fitted,fitted]= fit_linear(tau,peakval,[200e-9:10e-9:2e-6]);
 [f2,tau_fitted,fitted]= fit_linear(tau,peakval);
 slope_value_Ramsey=[f2.m(2)];
% slope_value_Ramsey=slope_value_Ramsey*cotd(39.3258); %IMPORTANT ANGLE information
 %slope_value_Ramsey=slope_value_Ramsey*cotd(47.8813); %IMPORTANT ANGLE information
 
 
%%
colors={'salmon','skyblue','palegreen','orange','violet','grey','grey','orange','salmon','skyblue','violet','salmon','skyblue','grey','violet','palegreen','gold','orange'};
colors2={'darkred','blue','darkgreen','orangered','magenta','black','black','orangered','darkred','blue','magenta','darkred','blue','black','magenta','darkgreen','goldenrod','orangered'};

%% Fit XY8 data linear
[f2,xvec_linear,fitted_linear] = fit_linear(sorted_nvalue2,sorted_peakval2);
[f4,xvec_linear4,fitted_linear4] = fit_linear(sorted_nvalue4,sorted_peakval4);
[f5,xvec_linear5,fitted_linear5] = fit_linear(sorted_nvalue5(1:3),sorted_peakval5(1:3),linspace(min(sorted_nvalue5),max(sorted_nvalue5),1000));
[f1,xvec_linear1,fitted_linear1] = fit_linear(sorted_nvalue1,sorted_peakval1);
[f3,xvec_linear3,fitted_linear3] = fit_linear(sorted_nvalue3,sorted_peakval3);
[f6,xvec_linear6,fitted_linear6] = fit_linear(sorted_nvalue6,sorted_peakval6);
[f7,xvec_linear7,fitted_linear7] = fit_linear(sorted_nvalue7(1:4),sorted_peakval7(1:4));
%% Calc of time
Tcpmg=(35.5e-9*2+50e-9)*2; %time for one CPMG block
Tn=4*sorted_nvalue2*Tcpmg;
Tn_fitted=4*xvec_linear*Tcpmg;

Tn5=4*sorted_nvalue5*Tcpmg;
Tn_fitted5=4*xvec_linear5*Tcpmg;

Tn4=4*sorted_nvalue4*Tcpmg;
Tn_fitted4=4*xvec_linear4*Tcpmg;

Tn1=4*sorted_nvalue1*Tcpmg;
Tn_fitted1=4*xvec_linear1*Tcpmg;

Tn3=4*sorted_nvalue3*Tcpmg;
Tn_fitted3=4*xvec_linear3*Tcpmg;

Tn6=4*sorted_nvalue6*Tcpmg;
Tn_fitted6=4*xvec_linear6*Tcpmg;

Tn7=4*sorted_nvalue7*Tcpmg;
Tn_fitted7=4*xvec_linear7*Tcpmg;

%% Plot slopes for XY8 mag
start_fig(1,[3 2]);
plot_preliminaries(sorted_nvalue2,sorted_peakval2,1,'noline');
plot_preliminaries(xvec_linear,fitted_linear,1,'nomarker');

%% Fit gaussian contrast for XY8 mag
[f2,xvec_contrast,fitted_contrast,T2_xy8]= fit_T2(Tn,sorted_contrast2);
[f5,xvec_contrast5,fitted_contrast5,T2_xy8_5]= fit_T2(Tn5(1:3),sorted_contrast5(1:3));
[f2,xvec_contrast4,fitted_contrast4,T2_xy8_4]= fit_T2(Tn4,sorted_contrast4);
[f1,xvec_contrast1,fitted_contrast1,T2_xy8_1]= fit_T2(Tn1,sorted_contrast1);
[f3,xvec_contrast3,fitted_contrast3,T2_xy8_3]= fit_T2(Tn3,sorted_contrast3);
[f6,xvec_contrast6,fitted_contrast6,T2_xy8_6]= fit_T2(Tn6,sorted_contrast6);
[f7,xvec_contrast7,fitted_contrast7,T2_xy8_7]= fit_T2(Tn7,sorted_contrast7);

start_fig(4,[3 2]);
plot_preliminaries(sorted_nvalue2,sorted_contrast2,1,'noline');
plot_labels('XY8-L Number','Contrast')

%% Plot slopes for Ramsey
start_fig(2,[3 2]);
plot_preliminaries(tau,peakval,1,'noline');
plot_preliminaries(tau_fitted,fitted,1,'nomarker');


%% Fit Ramsey contrast to gaussian and plot

 [f2,xvec,fitted_contrast_ramsey,T2_ramsey]=fit_T2(tau,contrast);
start_fig(5,[3 2]);
plot_preliminaries(tau,contrast,1,'noline');
plot_preliminaries(xvec,fitted_contrast,1,'nomarker');
plot_error(tau,contrast,contrasterr,1);
plot_labels('Time (ns)','Contrast');

%% Combine T2 values and plot with Ramsey
field_combined=[0 field2(1) field4(1) field5(1) field1(1) field3(1) field6(1) field7(1)];
T2_combined=[T2_ramsey T2_xy8 T2_xy8_4 T2_xy8_5 T2_xy8_1 T2_xy8_3 T2_xy8_6 T2_xy8_7];

%% Combined plots; UNCOMMENT TO GET ALL DATA

peakval=peakval*cotd(39.3258); %IMPORTANT ANGLE information
fitted=fitted*cotd(39.3258); %IMPORTANT ANGLE information

gamma_v=0.115; %G/V
% this is plot of slope
start_fig(6,2*[1.5 1]);
pRamsey=plot_preliminaries(tau*1e6,peakval,1,'noline');
plot_error(tau*1e6,peakval,peakerr,1);
plot_preliminaries(tau_fitted*1e6,fitted,1,'nomarker');

p=plot_preliminaries(Tn*1e6,sorted_peakval2,2,'noline');
plot_error(Tn*1e6,sorted_peakval2,sorted_peakerr2,2);
plot_preliminaries(Tn_fitted*1e6,fitted_linear,2,'nomarker');
% 
% p5=plot_preliminaries(Tn5*1e6,sorted_peakval5,5,'noline');
% plot_error(Tn5*1e6,sorted_peakval5,sorted_peakerr5,5);
% plot_preliminaries(Tn_fitted5*1e6,fitted_linear5,5,'nomarker');


p4=plot_preliminaries(Tn4*1e6,sorted_peakval4,3,'noline');
plot_error(Tn4*1e6,sorted_peakval4,sorted_peakerr4,3);
plot_preliminaries(Tn_fitted4*1e6,fitted_linear4,3,'nomarker');
% 
% p1=plot_preliminaries(Tn1*1e6,sorted_peakval1,1,'noline');
% plot_error(Tn1*1e6,sorted_peakval1,sorted_peakerr1,1);
% plot_preliminaries(Tn_fitted1*1e6,fitted_linear1,1,'nomarker');

p3=plot_preliminaries(Tn3*1e6,sorted_peakval3,4,'noline');
plot_error(Tn3*1e6,sorted_peakval3,sorted_peakerr3,4);
plot_preliminaries(Tn_fitted3*1e6,fitted_linear3,4,'nomarker');
% 
% p6=plot_preliminaries(Tn6*1e6,sorted_peakval6,6,'noline');
% plot_error(Tn6*1e6,sorted_peakval6,sorted_peakerr6,6);
% plot_preliminaries(Tn_fitted6*1e6,fitted_linear6,6,'nomarker');

p7=plot_preliminaries(Tn7*1e6,sorted_peakval7,7,'noline');
plot_error(Tn7*1e6,sorted_peakval7,sorted_peakerr7,7);
plot_preliminaries(Tn_fitted7*1e6,fitted_linear7,7,'nomarker');

set(gca,'ylim',[0 1.1]);
set(gca,'yTick',[0:0.25:1]);
set(gca,'xlim',[0 60]);

plot_labels('Time [\mu s]','Signal Slope [V^{-1}]');
%grid off;

% 
% hLegend = legend( ...
% [pRamsey,p5, p4,p,p1,p3,p6,p7],...
% 'Ramsey','58 MHz','87 MHz','138 MHz', '133 MHz','109 MHz','190 MHz','45 MHz' ,...
% 'location', 'best' );
% set(hLegend, ...
% 'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

hLegend = legend( ...
[pRamsey,p7,p4,p3,p],...
'Ramsey','46 MHz','87 MHz','109 MHz','139 MHz',...
'location', 'best' );
set(hLegend, ...
'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

%% Plot of slope in Gauss; UNCOMMENT TO GET ALL DATA
start_fig(62,2*[1.5 1]);
pRamsey=plot_preliminaries(tau*1e6,(1/gamma_v)*peakval,1,'noline');
plot_error(tau*1e6,(1/gamma_v)*peakval,(1/gamma_v)*peakerr,1);
plot_preliminaries(tau_fitted*1e6,(1/gamma_v)*fitted,1,'nomarker');

p=plot_preliminaries(Tn*1e6,(1/gamma_v)*sorted_peakval2,2,'noline');
plot_error(Tn*1e6,(1/gamma_v)*sorted_peakval2,(1/gamma_v)*sorted_peakerr2,2);
plot_preliminaries(Tn_fitted*1e6,(1/gamma_v)*fitted_linear,2,'nomarker');
% 
% p5=plot_preliminaries(Tn5*1e6,(1/gamma_v)*sorted_peakval5,5,'noline');
% plot_error(Tn5*1e6,(1/gamma_v)*sorted_peakval5,(1/gamma_v)*sorted_peakerr5,5);
% plot_preliminaries(Tn_fitted5*1e6,(1/gamma_v)*fitted_linear5,5,'nomarker');


p4=plot_preliminaries(Tn4*1e6,(1/gamma_v)*sorted_peakval4,3,'noline');
plot_error(Tn4*1e6,(1/gamma_v)*sorted_peakval4,(1/gamma_v)*sorted_peakerr4,3);
plot_preliminaries(Tn_fitted4*1e6,(1/gamma_v)*fitted_linear4,3,'nomarker');
% 
% p1=plot_preliminaries(Tn1*1e6,(1/gamma_v)*sorted_peakval1,1,'noline');
% plot_error(Tn1*1e6,(1/gamma_v)*sorted_peakval1,(1/gamma_v)*sorted_peakerr1,1);
% plot_preliminaries(Tn_fitted1*1e6,(1/gamma_v)*fitted_linear1,1,'nomarker');

p3=plot_preliminaries(Tn3*1e6,(1/gamma_v)*sorted_peakval3,4,'noline');
plot_error(Tn3*1e6,(1/gamma_v)*sorted_peakval3,(1/gamma_v)*sorted_peakerr3,4);
plot_preliminaries(Tn_fitted3*1e6,(1/gamma_v)*fitted_linear3,4,'nomarker');
% 
% p6=plot_preliminaries(Tn6*1e6,(1/gamma_v)*sorted_peakval6,6,'noline');
% plot_error(Tn6*1e6,(1/gamma_v)*sorted_peakval6,(1/gamma_v)*sorted_peakerr6,6);
% plot_preliminaries(Tn_fitted6*1e6,(1/gamma_v)*fitted_linear6,6,'nomarker');

p7=plot_preliminaries(Tn7*1e6,(1/gamma_v)*sorted_peakval7,7,'noline');
plot_error(Tn7*1e6,(1/gamma_v)*sorted_peakval7,(1/gamma_v)*sorted_peakerr7,7);
plot_preliminaries(Tn_fitted7*1e6,(1/gamma_v)*fitted_linear7,7,'nomarker');

 set(gca,'ylim',[0 10]);
 set(gca,'yTick',[0:2:10]);
set(gca,'xlim',[0 60]);

plot_labels('Time [\mu s]','Signal Slope [G^{-1}]');
%grid off;


hLegend = legend( ...
[pRamsey,p7,p4,p3,p],...
'Ramsey','46 MHz','87 MHz','109 MHz','139 MHz',...
'location', 'southeast' );
set(hLegend, ...
'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

%% this is plot of contrast
start_fig(7,2*[1.5 1]);
pRamsey=plot_preliminaries(tau*1e6,contrast,1,'noline');
plot_error(tau*1e6,contrast,contrasterr,1)
plot_preliminaries(xvec*1e6,fitted_contrast_ramsey,1,'nomarker');
% p=plot_preliminaries(tau*1e6,bare_contrast_ramsey,1,'noline');
% set(p,'marker','d');

plot_preliminaries(Tn*1e6,sorted_contrast2,2,'noline');
plot_error(Tn*1e6,sorted_contrast2,sorted_contrasterr2,2);
p=plot_preliminaries(xvec_contrast*1e6,fitted_contrast,2,'nomarker');
% 
% plot_preliminaries(Tn5*1e6,sorted_contrast5,5,'noline');
% plot_error(Tn5*1e6,sorted_contrast5,sorted_contrasterr5,5);
% p5=plot_preliminaries(xvec_contrast5*1e6,fitted_contrast5,5,'nomarker');

plot_preliminaries(Tn4*1e6,sorted_contrast4,3,'noline');
plot_error(Tn4*1e6,sorted_contrast4,sorted_contrasterr4,3);
p4=plot_preliminaries(xvec_contrast4*1e6,fitted_contrast4,3,'nomarker');
% 
% plot_preliminaries(Tn1*1e6,sorted_contrast1,1,'noline');
% plot_error(Tn1*1e6,sorted_contrast1,sorted_contrasterr1,1);
% p1=plot_preliminaries(xvec_contrast1*1e6,fitted_contrast1,1,'nomarker');

plot_preliminaries(Tn3*1e6,sorted_contrast3,4,'noline');
plot_error(Tn3*1e6,sorted_contrast3,sorted_contrasterr3,4);
p3=plot_preliminaries(xvec_contrast3*1e6,fitted_contrast3,4,'nomarker');
% 
% plot_preliminaries(Tn6*1e6,sorted_contrast6,6,'noline');
% plot_error(Tn6*1e6,sorted_contrast6,sorted_contrasterr6,6);
% p6=plot_preliminaries(xvec_contrast6*1e6,fitted_contrast6,6,'nomarker');

plot_preliminaries(Tn7*1e6,sorted_contrast7,7,'noline');
plot_error(Tn7*1e6,sorted_contrast7,sorted_contrasterr7,7);
p7=plot_preliminaries(xvec_contrast7*1e6,fitted_contrast7,7,'nomarker');

set(gca,'ylim',[0 0.25]);
set(gca,'xlim',[-0.5 60]);
set(gca,'yTick',[0:0.1:0.3]);
plot_labels('Time [\mu s]','Contrast');
%grid off;


% %% this is plot of bare contrast, a measure of the T2* and T2
% start_fig(8,2*[1.5 1]);
% plot_preliminaries(tau*1e6,bare_contrast_ramsey,1);
% 
% plot_preliminaries(Tn*1e6,bare_contrast_xy8_2,2);
% 
% plot_preliminaries(Tn5*1e6,bare_contrast_xy8_5,5);
% 
% plot_preliminaries(Tn4*1e6,bare_contrast_xy8_4,3);
% 
% plot_preliminaries(Tn1*1e6,bare_contrast_xy8_1,1);
% 
% set(gca,'ylim',[0 0.25]);
% set(gca,'xlim',[-0.5 60]);
% set(gca,'yTick',[0:0.1:0.3]);
% plot_labels('Time [\mu s]','Contrast');
% %grid off;

%% Plot now T2 values of xy8 and Ramsey
start_fig(12,2*[1.5 1]);
plot_preliminaries(field_combined*1e-6,T2_combined*1e6,1,'noline');
plot_labels('Field [MHz]','Coherence time [\mu s]');
grid off;



%% PLot inverse slope and compare with Ramsey
compare_with_xy8(slope_value_Ramsey);
compare_with_xy8_time(slope_value_Ramsey);

%% To calculate sensitivity now use the logic that xD S/slope in voltage is related to sens


[xvec,sensitivity_Ramsey]=calc_sens(xvec,fitted,fitted_contrast_ramsey);
[tau,sensitivity_Ramsey_point,sens_Ramsey_err]=calc_sens(tau,peakval,contrast,peakerr,contrasterr);

[Tn_fitted,sensitivity]=calc_sens(Tn_fitted,fitted_linear,fitted_contrast);
[Tn,sensitivity_point,sens_err2]=calc_sens(Tn,sorted_peakval2,sorted_contrast2,sorted_peakerr2,sorted_contrasterr2);

[Tn_fitted5,sensitivity5]=calc_sens(Tn_fitted5,fitted_linear5,fitted_contrast5);
[Tn5,sensitivity_point5,sens_err5]=calc_sens(Tn5,sorted_peakval5,sorted_contrast5,sorted_peakerr5,sorted_contrasterr5);

[Tn_fitted4,sensitivity4]=calc_sens(Tn_fitted4,fitted_linear4,fitted_contrast4);
[Tn4,sensitivity_point4,sens_err4]=calc_sens(Tn4,sorted_peakval4,sorted_contrast4,sorted_peakerr4,sorted_contrasterr4);

[Tn_fitted1,sensitivity1]=calc_sens(Tn_fitted1,fitted_linear1,fitted_contrast1);
[Tn1,sensitivity_point1,sens_err1]=calc_sens(Tn1,sorted_peakval1,sorted_contrast1,sorted_peakerr1,sorted_contrasterr1);

[Tn_fitted3,sensitivity3]=calc_sens(Tn_fitted3,fitted_linear3,fitted_contrast3);
[Tn3,sensitivity_point3,sens_err3]=calc_sens(Tn3,sorted_peakval3,sorted_contrast3,sorted_peakerr3,sorted_contrasterr3);

[Tn_fitted6,sensitivity6]=calc_sens(Tn_fitted6,fitted_linear6,fitted_contrast6);
[Tn6,sensitivity_point6,sens_err6]=calc_sens(Tn6,sorted_peakval6,sorted_contrast6,sorted_peakerr6,sorted_contrasterr6);

[Tn_fitted7,sensitivity7]=calc_sens(Tn_fitted7,fitted_linear7,fitted_contrast7);
[Tn7,sensitivity_point7,sens_err7]=calc_sens(Tn7,sorted_peakval7,sorted_contrast7,sorted_peakerr7,sorted_contrasterr7);

%% PLOT Of sensitivity; UNCOMMENT TO GET ALL DATA
start_fig(9,2*[1.5 1]);

plot_preliminaries(xvec*1e6,sensitivity_Ramsey*1e6,1,'nomarker');
pRamsey=plot_preliminaries(tau*1e6,sensitivity_Ramsey_point*1e6,1,'noline');
plot_error(tau*1e6,sensitivity_Ramsey_point*1e6,sens_Ramsey_err*1e6,1);


plot_preliminaries(Tn_fitted*1e6,sensitivity*1e6,2,'nomarker');
p=plot_preliminaries(Tn*1e6,sensitivity_point*1e6,2,'noline');
plot_error(Tn*1e6,sensitivity_point*1e6,sens_err2*1e6,2);
% 
% plot_preliminaries(Tn_fitted5*1e6,sensitivity5*1e6,5,'nomarker');
% p5=plot_preliminaries(Tn5*1e6,sensitivity_point5*1e6,5,'noline');
% plot_error(Tn5*1e6,sensitivity_point5*1e6,sens_err5*1e6,5);

plot_preliminaries(Tn_fitted4*1e6,sensitivity4*1e6,3,'nomarker');
p4=plot_preliminaries(Tn4*1e6,sensitivity_point4*1e6,3,'noline');
plot_error(Tn4*1e6,sensitivity_point4*1e6,sens_err4*1e6,3);
% 
% plot_preliminaries(Tn_fitted1*1e6,sensitivity1*1e6,1,'nomarker');
% p1=plot_preliminaries(Tn1*1e6,sensitivity_point1*1e6,1,'noline');
% plot_error(Tn1*1e6,sensitivity_point1*1e6,sens_err1*1e6,1);

plot_preliminaries(Tn_fitted3*1e6,sensitivity3*1e6,4,'nomarker');
p3=plot_preliminaries(Tn3*1e6,sensitivity_point3*1e6,4,'noline');
plot_error(Tn3*1e6,sensitivity_point3*1e6,sens_err3*1e6,4);

% plot_preliminaries(Tn_fitted6*1e6,sensitivity6*1e6,6,'nomarker');
% p6=plot_preliminaries(Tn6*1e6,sensitivity_point6*1e6,6,'noline');
% plot_error(Tn6*1e6,sensitivity_point6*1e6,sens_err6*1e6,6);

plot_preliminaries(Tn_fitted7*1e6,sensitivity7*1e6,7,'nomarker');
p7=plot_preliminaries(Tn7*1e6,sensitivity_point7*1e6,7,'noline');
plot_error(Tn7*1e6,sensitivity_point7*1e6,sens_err7*1e6,7);


plot_labels('Time [\mu s]','Sensitivity (\mu T/vHz)');

set(gca,'ylim',[0 50]);
set(gca,'yTick',[0:10:50]);
%h = breakxaxis([2 10]);

% set(gca,'ylim',[0 0.7]);
% set(gca,'yTick',[0:0.35:0.7]);

% 
% hLegend = legend( ...
% [pRamsey,p5, p4,p],...
% 'Ramsey','58 MHz','87 MHz','138 MHz',...
% 'location', 'northeast' );
% set(hLegend, ...
% 'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

field_combined=[0 field2(1) field4(1) field5(1) field1(1) field3(1) field6(1) field7(1)];
sens_combined=[min(sensitivity_Ramsey_point*1e6) min(sensitivity_point*1e6) min(sensitivity_point4*1e6) min(sensitivity_point5*1e6) ....
    min(sensitivity_point1*1e6) min(sensitivity_point3*1e6) min(sensitivity_point6*1e6) min(sensitivity_point7*1e6)];
[c,ind_ram]=min(sensitivity_Ramsey_point*1e6);
[c,ind2]=min(sensitivity_point*1e6);
[c,ind4]=min(sensitivity_point4*1e6);
[c,ind5]=min(sensitivity_point5*1e6);
[c,ind1]=min(sensitivity_point1*1e6);
[c,ind3]=min(sensitivity_point3*1e6);
[c,ind6]=min(sensitivity_point6*1e6);
[c,ind7]=min(sensitivity_point7*1e6);
sens_err_combined=[sens_Ramsey_err(ind_ram)*1e6 sens_err2(ind2)*1e6 sens_err4(ind4)*1e6 ...
    sens_err5(ind5)*1e6 sens_err1(ind1)*1e6 sens_err3(ind3)*1e6 sens_err6(ind6)*1e6 sens_err7(ind7)*1e6];

[sort_field_combined,IX1]=sort(field_combined);
sort_sens_combined=sens_combined(IX1);
start_fig(13,[1.5 1]);
p1=plot_preliminaries(sort_field_combined*1e-6,sort_sens_combined,1,'noline');
%plot_preliminaries(sort_field_combined*1e-6,smooth(sort_sens_combined,4),1,'nomarker');
plot_error(field_combined*1e-6,sens_combined,sens_err_combined,1);
set(p1,'Markersize',8);
plot_xline(sens_combined(1))
plot_labels('Field \Delta [MHz]','Min. Sensitivity (\mu T/vHz)');
set(gca,'ylim',[0 50]);
set(gca,'xlim',[0 200]);
set(gca,'yTick',[0 10 20 50]);
export2base()
end 

function  make_plot (fig,voltage,norm_data_bare,norm_data_volt, DataX, DataY, DataXvec, fitted, sorted_nvalue,sorted_nvalue_index, sorted_peakval,sorted_peakerr)
colors={'salmon','skyblue','grey','violet','palegreen','gold','orange','salmon','skyblue','violet','salmon','skyblue','grey','violet','palegreen','gold','orange'};
colors2={'darkred','blue','black','magenta','darkgreen','goldenrod','orangered','darkred','blue','magenta','darkred','blue','black','magenta','darkgreen','goldenrod','orangered'};

%% PLot Ramsey signal
fh=figure(fig);clf;set(fh, 'color', 'white');
set(fig,'Units', 'pixels', ...
'Position', [100 100 300 * 6 300*1.5]);clf;
gap=[0.05 0.05];
marg_h=0.15;
marg_v=0.15;
subtightplot(1,3,1,gap,marg_h,marg_v);
plot(voltage{sorted_nvalue_index(end)},norm_data_volt{sorted_nvalue_index(end)},'Marker', 'o', ...
    'Color',rgb(colors2{1}), ...
    'Linewidth',1.5, ...
    'MarkerSize' ,8 , ...
    'MarkerEdgeColor' , [.2 .2 .2] , ...
    'MarkerFaceColor' , rgb(colors{1})); hold on;


grid on;

set(gca,'fontsize',15,'FontName','MyriadPro-Regular');
set(gca, ...
    'Box' , 'off' , ...
    'TickDir' , 'out' , ...
    'TickLength' , [.02 .02] , ...
    'XMinorTick' , 'on' , ...
    'YMinorTick' , 'on' , ...
    'YGrid' , 'on' , ...
    'XGrid', 'on',...
    'LineWidth' , 1 );
[ax,l1]=suplabel('Voltage [V]'); 
[ax,l2]=suplabel('Signal','y'); 
set(l1,'FontName' , 'MyriadPro-Regular','FontSize',15); %Font size of labels
set(l2,'FontName' , 'MyriadPro-Regular','FontSize',15); %Font size of labels

subtightplot(1,3,2,gap,marg_h,marg_v);
for j=1:size(DataX,2)
p1=plot(DataX{j},DataY{j},'Marker', 'o', ...
    'Color',rgb(colors2{j}), ...,
    'Linestyle','none', ...
    'Linewidth',1.5, ...
    'MarkerSize' ,8 , ...
    'MarkerEdgeColor' , [.2 .2 .2] , ...
    'MarkerFaceColor' , rgb(colors{j})); hold on;
p1=plot(DataXvec{j},fitted{j},'Marker', 'none', ...
    'Color',rgb(colors2{j}), ...,
    'Linestyle','-', ...
    'Linewidth',1.5, ...
    'MarkerSize' ,8 , ...
    'MarkerEdgeColor' , [.2 .2 .2] , ...
    'MarkerFaceColor' , rgb(colors{j})); hold on;
grid on;

set(gca,'fontsize',15,'FontName','MyriadPro-Regular');
set(gca, ...
    'Box' , 'off' , ...
    'TickDir' , 'out' , ...
    'TickLength' , [.02 .02] , ...
    'XMinorTick' , 'on' , ...
    'YMinorTick' , 'on' , ...
    'YGrid' , 'on' , ...
    'XGrid', 'on',...
    'LineWidth' , 1 );
xlabel('Frequency', 'FontName' , 'MyriadPro-Regular','FontSize',15); 
ylabel('FFT','FontName' , 'MyriadPro-Regular','FontSize',15); 

set(gca,'xlim',[0 1]);
end
% hLegend = legend( ...
% [p1, p2, p3,p4,p5],...
% ['L=' num2str(nvalue1)],['L=' num2str(nvalue2)],['L=' num2str(nvalue3)],['L=' num2str(nvalue4)],['L=' num2str(nvalue5)], ...
% 'location', 'best' );
% set(hLegend, ...
% 'FontName' , 'MyriadPro-Regular','FontSize',13); %Font size of legend

subtightplot(1,3,3,gap,marg_h,marg_v);
p1=plot(sorted_nvalue,sorted_peakval,'Marker', 'o', ...
    'Color',rgb(colors2{1}), ...
    'Linewidth',1.5, ...
    'MarkerSize' ,8 , ...
    'MarkerEdgeColor' , [.2 .2 .2] , ...
    'MarkerFaceColor' , rgb(colors{1})); hold on;
errorbar(sorted_nvalue,sorted_peakval,sorted_peakerr, ...
    'Color',rgb(colors2{1}), ...
    'Linewidth',1,'LineStyle', 'none');
% p1=plot(Bint,Freq_contrast*max(peakval)./max(Freq_contrast),'Marker', 'o', ...
%     'Color',rgb(colors2{2}), ...
%     'Linewidth',1.5, ...
%     'MarkerSize' ,8 , ...
%     'MarkerEdgeColor' , [.2 .2 .2] , ...
%     'MarkerFaceColor' , rgb(colors{2})); hold on;

grid on;

set(gca,'fontsize',15,'FontName','MyriadPro-Regular');
set(gca, ...
    'Box' , 'off' , ...
    'TickDir' , 'out' , ...
    'TickLength' , [.02 .02] , ...
    'XMinorTick' , 'on' , ...
    'YMinorTick' , 'on' , ...
    'YGrid' , 'on' , ...
    'XGrid', 'on',...
    'LineWidth' , 1 );
xlabel('XY8-L Number', 'FontName' , 'MyriadPro-Regular','FontSize',15); 
ylabel('FFT Frequency','FontName' , 'MyriadPro-Regular','FontSize',15);



end

function   [voltage,norm_data_bare,norm_data_volt, DataX, DataY, DataXvec, fitted, sorted_nvalue,sorted_nvalue_index, sorted_peakval,sorted_peakerr,sorted_peakwidth,sorted_contrast,sorted_contrasterr,field] =get_data (selected_expts)
fn='D:\code\SavedExperiments\';
N=size(selected_expts,2);
for j=1:N
count=j;
explimits_ramsey{1}=selected_expts{count};explimits_ramsey{2}=selected_expts{count};
[voltage{j},norm_data_bare{j},norm_data_volt{j},nvalue(j),field(j)] =process_mag_data (explimits_ramsey,fn);
[DataX{j},DataY{j}]= calc_fft(voltage{j},norm_data_volt{j});

[fvolt{j},DataXvec{j},fitted{j},peakval(j),peakwidth(j),Freq_contrast(j),peak_err(j),contrast_err(j)] =fit_FFT (DataX{j},DataY{j});

if field(j)<70e6 && nvalue(j)==16
    [fvolt{j},DataXvec{j},fitted{j},peakval(j),peakwidth(j),Freq_contrast(j),peak_err(j),contrast_err(j)] =fit_FFT (DataX{j},DataY{j},1);
elseif field(j)<70e6 && nvalue(j)>16
    [fvolt{j},DataXvec{j},fitted{j},peakval(j),peakwidth(j),Freq_contrast(j),peak_err(j),contrast_err(j)] =fit_FFT (DataX{j},DataY{j},2);
end

end

[sorted_nvalue,IX]=sort(nvalue);
sorted_nvalue_index=IX;
sorted_peakval=peakval(IX);
sorted_peakwidth=peakwidth(IX);
sorted_peakerr=peak_err(IX);
sorted_contrast = Freq_contrast(IX);
sorted_contrasterr = contrast_err(IX);
end

function   [voltage_ramsey,norm_data_bare_ramsey,norm_data_volt_ramsey, nvalue, field] =process_mag_data (explimits_ramsey,fn)

selected_expts_ramsey{1}=explimits_ramsey;
data_ramsey{1}{1}(1,1)=selected_expts_ramsey(1);
Scan_ramsey=load([fn explimits_ramsey{1}]);
[x_con_ramsey Y1_con_ramsey Y1_std_ramsey]=concatenate_qeg_set4_4(data_ramsey{1}{1});
for k=1:size(Y1_con_ramsey,2)
        norm_data_bare_vec_ramsey(:,k)=Y1_con_ramsey(1:2:end-1,k);
        norm_data_volt_vec_ramsey(:,k)=Y1_con_ramsey(2:2:end,k);
end
if size(Y1_con_ramsey,2) ~=1
norm_data_bare_ramsey=mean(norm_data_bare_vec_ramsey');
norm_data_volt_ramsey=mean(norm_data_volt_vec_ramsey');
else
    norm_data_bare_ramsey=norm_data_bare_vec_ramsey;
    norm_data_volt_ramsey=norm_data_volt_vec_ramsey;
end
voffset=diff(x_con_ramsey);
voltage_ramsey=x_con_ramsey(2:2:end)-voffset(1);
nvalue=Scan_ramsey.Scan.Variable_values{8}.value;
field=Scan_ramsey.Scan.Variable_values{3}.value;
end

function   [voltage_ramsey,norm_data_bare_ramsey,norm_data_volt_ramsey,tau,field] =process_mag_data_ramsey (explimits_ramsey,fn)
selected_expts_ramsey{1}=qeg_read_dir2_4(explimits_ramsey);
for j=1:size(selected_expts_ramsey{1},2)
    data_ramsey{1}{1}=selected_expts_ramsey{1}{j};
    Scan_ramsey=load([fn  data_ramsey{1}{1}]);
     tau(j)=Scan_ramsey.Scan.Variable_values{6}.value;
     field(j)=Scan_ramsey.Scan.Variable_values{3}.value;
    [x_con_ramsey Y1_con_ramsey Y1_std_ramsey]=concatenate_qeg_set4_4(data_ramsey);
    for k=1:size(Y1_con_ramsey,2)
        norm_data_bare_vec_ramsey(:,k)=Y1_con_ramsey(1:2:end-1,k);
        norm_data_volt_vec_ramsey(:,k)=Y1_con_ramsey(2:2:end,k);
    end
    norm_data_bare_ramsey{j}=mean(norm_data_bare_vec_ramsey');
    norm_data_volt_ramsey{j}=mean(norm_data_volt_vec_ramsey');
    voffset=diff(x_con_ramsey);
    voltage_ramsey{j}=x_con_ramsey(2:2:end)-voffset(1);
end
end


function   [fvolt,DataXvec,fitted,peakval,peakwidth,contrast,peak_err,contrast_err] =fit_FFT (DataX,DataY,varargin)
if size(DataY,1)~=1
     DataY=DataY';
end
 
if nargin>=3
    if varargin{1}==1
    [v1,b1]=min(abs(DataX-0.4));
    else
        [v1,b1]=min(abs(DataX-0.7));
    end
  [v,b]=max(DataY(b1:b1+15));  
  lim1=b1+b; lim2=b+ min(size(DataY,2),abs(b+10));
else
  [v,b]=max(DataY);
   lim1=min(1,abs(b-10)+1); lim2=min(size(DataY,2),abs(b+10));
end

 
[fvolt,r]=fit_Lorentzian_peak(DataX(lim1:lim2),DataY(lim1:lim2));
H=fit_Lorentzian_with_errors(DataX(lim1:lim2),DataY(lim1:lim2));

peakdata=H{4};
peakdata(isnan(peakdata))=[]; %to remove the NaNs
peak_err = std(peakdata); 
peakval=mean(peakdata);
 
contrastdata=4*sqrt(H{1}/pi);
contrastdata(isnan(contrastdata))=[]; %to remove the NaNs
contrast=mean(contrastdata);
contrast_err=std(contrastdata);

if contrast>0.3
    contrast=0.3;
    contrast=NaN;
    contrast_err=NaN;
end

peakwidth=mean(H{2});

DataXvec=linspace(min(DataX),max(DataX),1000);
fitted=fvolt(1)./(pi.*(1+( (DataXvec-fvolt(4)) / fvolt(2)).^2))+fvolt(3);

end

function [fvolt_field,DataXvec_field,fitted_field,peakval_field,contrast_field,peakerr_field,contrasterr_field] = process_FFT(voltage_ramsey1,norm_data_volt_ramsey1,tau)
for j=1:size(voltage_ramsey1,2)
    [v,b]=min(abs(voltage_ramsey1{j}-6));
[DataX1{j},DataY1{j}]= calc_fft(voltage_ramsey1{j}(b:end),norm_data_volt_ramsey1{j}(b:end)); %have to shift so that you start with 6V
if tau(j)==800e-9
[fvolt_field{j},DataXvec_field{j},fitted_field{j},peakval_field(j),contrast_field(j),peakerr_field(j),contrasterr_field(j)] =fit_FFT_Ramsey (DataX1{j},DataY1{j},0.2);
else
    [fvolt_field{j},DataXvec_field{j},fitted_field{j},peakval_field(j),contrast_field(j),peakerr_field(j),contrasterr_field(j)] =fit_FFT_Ramsey (DataX1{j},DataY1{j});
end
end

end

function   [fvolt,DataXvec,fitted,peakval,contrast,peak_err,contrast_err] =fit_FFT_Ramsey (DataX,DataY,varargin)
% This is in order to fit properly 800ns point that is not fitting
if nargin>2
    b= find(abs(DataX-varargin{1})<0.025);
    b=b(1);
     lim1=min(1,abs(b-4)+1); lim2=min(size(DataY,2),abs(b+4));
else
[v,b]=max(DataY);
 lim1=min(1,abs(b-10)+1); lim2=min(size(DataY,2),abs(b+10));
end

 
[fvolt,r]=fit_Lorentzian_peak(DataX(lim1:lim2),DataY(lim1:lim2));
H=fit_Lorentzian_with_errors(DataX(lim1:lim2),DataY(lim1:lim2));
peakdata=H{4};
peakdata(isnan(peakdata))=[]; %to remove the NaNs
peak_err = std(peakdata); 
peakval=mean(peakdata);
 
contrastdata=4*sqrt(H{1}/pi);
contrastdata(isnan(contrastdata))=[]; %to remove the NaNs
contrast=mean(contrastdata);
contrast_err=std(contrastdata);


DataXvec=linspace(min(DataX),max(DataX),1000);
fitted=fvolt(1)./(pi.*(1+( (DataXvec-fvolt(4)) / fvolt(2)).^2))+fvolt(3);
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

function [f,xvec,fitted_contrast]= fit_gaussian(x,y,varargin)
lb=[0,-max(x),0,0];
ub=[1,max(x), 3*max(x),1];

x1=x;y1=y;
a_ini=max(y1);
b_ini=0;
c_ini=max(x1)/2;
d_ini=0;
P_ini=[a_ini;b_ini;c_ini;d_ini]; %NOTE that they have to be ordered alphabetically!

f = ezfit(x1, y1, 'y =a*exp(-(x-b).^2/(2*c^2)) + d',P_ini,lb,ub);

xvec=linspace(x1(1),x1(end),1000);
fitted_contrast=f.m(1).*exp(-(xvec-f.m(2)).^2./(2*f.m(3)^2)) + f.m(4);

start_fig(11,[3 2]);
plot_preliminaries(x1,y1,2,'noline');
plot_preliminaries(xvec,fitted_contrast,2,'nomarker');
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

function compare_with_xy8(slope_value_Ramsey)
load xy8_voltage_data_complete;


%% Plot inverse slope values
start_fig(3,1.25*[1.5 1]);
extended_field_values=[35:1:300]*1e6;

 [f_slope_time,xvec_slope_time,fitted_slope_time]= fit_linear(1./(sorted_field_values*1e-6),...
     sorted_slope_values_time,1./(extended_field_values*1e-6));

plot_preliminaries(1./(sorted_field_values*1e-6),sorted_slope_values_time./slope_value_Ramsey,2,'noline');
plot_error(1./(sorted_field_values*1e-6),sorted_slope_values_time./slope_value_Ramsey,d_time./slope_value_Ramsey,2);
p1=plot_preliminaries(xvec_slope_time,fitted_slope_time./slope_value_Ramsey,2,'nomarker');
set(p1,'Linewidth',1);

%plot(get(gca,'xlim'),[slope_value_Ramsey slope_value_Ramsey],'Color',rgb('DarkGreen'),'LineStyle','--','Linewidth',2);hold on;
plot(get(gca,'xlim'),[1 1],'Color',rgb('DarkGreen'),'LineStyle','--','Linewidth',2);hold on;

set(gca,'xlim',[1/300 1/35]);
set(gca,'XDir','reverse');
tick_val=[1 2 5];
set(gca,'XTick',1./(fliplr(sorted_field_values(tick_val)*1e-6)));
[hx,hy] = format_ticks(gca,fliplr(XTicklabel(tick_val)));

set(gca,'XTick',1./(fliplr(sorted_field_values(tick_val)*1e-6)));
plot_labels('1/Field [MHz]','Normalized Slope')
set(gca,'YTick',[0:0.25:1]);
set(gca,'ylim',[0 1.1]);

grid off;

end


function compare_with_xy8_time(slope_value_Ramsey)
load xy8_voltage_data_complete;

%% Plot inverse slope values
start_fig(4,2*[1.5 1]);
extended_field_values=[40:1:300]*1e6;

 [f_slope_time,xvec_slope_time,fitted_slope_time]= fit_linear(1./(sorted_field_values*1e-6),...
     sorted_slope_values_time,1./(extended_field_values*1e-6));

plot_preliminaries(1./(sorted_field_values*1e-6),sorted_slope_values_time,2,'noline');
plot_error(1./(sorted_field_values*1e-6),sorted_slope_values_time,d_time,2);
p1=plot_preliminaries(xvec_slope_time,fitted_slope_time,2,'nomarker');
set(p1,'Linewidth',1);

%plot(get(gca,'xlim'),[slope_value_Ramsey slope_value_Ramsey],'Color',rgb('DarkGreen'),'LineStyle','--','Linewidth',2);hold on;
%plot(get(gca,'xlim'),[1 1],'Color',rgb('DarkGreen'),'LineStyle','--','Linewidth',2);hold on;

set(gca,'xlim',[1/300 1/35]);
set(gca,'XDir','reverse');
tick_val=[1 2 5];
set(gca,'XTick',1./(fliplr(sorted_field_values(tick_val)*1e-6)));
[hx,hy] = format_ticks(gca,fliplr(XTicklabel(tick_val)));

set(gca,'XTick',1./(fliplr(sorted_field_values(tick_val)*1e-6)));
plot_labels('1/Field [MHz]','Slope [V^{-1}s^{-1}]')
set(gca,'YTick',[0:2e4:6e4]);
 set(gca,'ylim',[0 6e4]);
 
 %% Plot inverse slope values in GAUSS
 gamma_v=0.115; %G/V
start_fig(42,2*[1.5 1]);clf;
extended_field_values=[40:1:300]*1e6;

 [f_slope_time,xvec_slope_time,fitted_slope_time]= fit_linear(1./(sorted_field_values*1e-6),...
     sorted_slope_values_time,1./(extended_field_values*1e-6));

p1=plot_preliminaries(1./(sorted_field_values*1e-6),1e-6*(1./gamma_v)*sorted_slope_values_time,2,'noline');
plot_error(1./(sorted_field_values*1e-6),1e-6*(1./gamma_v)*sorted_slope_values_time,1e-6*(1./gamma_v)*d_time,2);
set(p1,'markersize',7);
p1=plot_preliminaries(xvec_slope_time,1e-6*(1./gamma_v)*fitted_slope_time,2,'nomarker');
set(p1,'Linewidth',1);

%plot(get(gca,'xlim'),[slope_value_Ramsey slope_value_Ramsey],'Color',rgb('DarkGreen'),'LineStyle','--','Linewidth',2);hold on;
%plot(get(gca,'xlim'),[1 1],'Color',rgb('DarkGreen'),'LineStyle','--','Linewidth',2);hold on;
 set(gca,'YTick',[0:0.1:0.4]);
 set(gca,'ylim',[0 0.4]);
set(gca,'xlim',[1/300 1/35]);
set(gca,'XDir','reverse');
tick_val=[1 3 5];
set(gca,'XTick',1./(fliplr(sorted_field_values(tick_val)*1e-6)));

set(gca,'XTick',1./(fliplr(sorted_field_values(tick_val)*1e-6)));
[hx,hy] = format_ticks(gca,fliplr(XTicklabel(tick_val)));
plot_labels('1/Field \Delta [MHz]^{-1}','Slope [G^{-1}\mu s^{-1}]')

%% Plot coherence times
T2_ramsey =1.1552e-06; %this is got from ramsey_comparison3.m
start_fig(12,[1.5 1]);
p1=plot_preliminaries(sorted_field_values*1e-6,sorted_T2_values*1e6,1,'noline');
set(p1,'Markersize',8);
plot_preliminaries(sorted_field_values*1e-6,smooth(sorted_T2_values*1e6,2),1,'nomarker');
plot_error(sorted_field_values*1e-6,sorted_T2_values*1e6,sorted_err_T2_values*1e6,1);
%plot_preliminaries(xvec,fitted,1,'nomarker');
plot_xline(T2_ramsey*1e6,1);
plot_labels('Field \Delta [MHz]','Coherence time [\mu s]')
set(gca,'ylim',[-5,70]);
set(gca,'xlim',[40,220]);
grid off;

end

function [Tn_fitted,sensitivity,sensitivity_err]=calc_sens(Tn_fitted,fitted_linear,fitted_contrast,varargin)

gamma_v=0.115e-4; %T/V
slope_voltage=(1/gamma_v)*fitted_linear;
t_dead=1.3e-6;
%t_dead=600e-9;
number_cycles=1./(Tn_fitted+t_dead); %number of cycles in 1sec
%including faling contrast
sensitivity = (17.2687./(fitted_contrast.*slope_voltage)).*1./sqrt(number_cycles);
% for the DS value use deltaS_measurement.m

%without falling contrast
%sensitivity = (20./(slope_voltage)).*1./sqrt(number_cycles);
sensitivity_err=0;
if nargin>3
peakerr=1/gamma_v*varargin{1};
contrasterr=varargin{2};
 sensitivity_err1 = (17.2687./((fitted_contrast+contrasterr).*(slope_voltage+peakerr))).*1./sqrt(number_cycles);
 sensitivity_err2 = (17.2687./((fitted_contrast-contrasterr).*(slope_voltage-peakerr))).*1./sqrt(number_cycles);
 sensitivity_err=0.5*abs(sensitivity_err1-sensitivity_err2);
end

end

% function to plot bare contrast T2, T2* decays later
function bare_contrast= calc_bare_contrast(norm_data_bare_ramsey1)

for j=1:size(norm_data_bare_ramsey1,2)
    bare_contrast(j)=2*abs(mean(norm_data_bare_ramsey1{j})-0.85);
    
end
end