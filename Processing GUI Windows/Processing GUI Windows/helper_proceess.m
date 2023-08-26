function [] = helper_proceess()
%  files = {'2017-06-15_22.36.16_carbon_ext_trig_shuttle','2017-06-22_18.21.19_carbon_ext_trig_shuttle','2017-07-13_18.56.56_carbon_ext_trig_shuttle','2017-07-23_13.11.01_carbon_ext_trig_shuttle','2017-07-23_13.33.52_carbon_ext_trig_shuttle','2017-07-24_13.33.42_carbon_ext_trig_shuttle','2017-07-25_17.32.20_carbon_ext_trig_shuttle','2017-07-25_18.35.03_carbon_ext_trig_shuttle','2017-07-25_18.51.05_carbon_ext_trig_shuttle','2017-07-26_13.17.14_carbon_ext_trig_shuttle','2017-07-26_13.28.39_carbon_ext_trig_shuttle','2017-07-26_13.40.05_carbon_ext_trig_shuttle','2017-07-26_13.51.30_carbon_ext_trig_shuttle'};
directory = dir('C:\Users\Arthur Lin\Documents\Pines Lab\MATLAB\FID_spectra\Sweep Time\');
for ind = 1:numel(directory)
    all_files{ind} = directory(ind).name;
end
files = all_files(3:end);
 for i = 1:numel(files)
% for i = 3:3  
    disp(i);
    curr_file = [directory(i).folder, '\' files{i} '\complete.fid\fid'];
    [enhancementFactor, enhancementFactor_1, enhancementFactor_2,...
    therm_spec_scaled, dnp_spec_scaled, ...
    fwhm_dnp_0, fwhm_phased_dnp,fwhm_dnp_baselined, width, ...
    signal_bs, signal_raw, signal_phase0, signal_phase1,...
    area_summed_dnp(i),area_summed_dnp_1(i),area_summed_dnp_2(i),area_trapz_dnp(i),area_trapz_dnp2(i),muller_area(i), area_fwhm_dnp(i),area_fixed_fwhm_dnp(i)] = process_enhancement_expedite(curr_file);

    fwhm_0(i) = fwhm_dnp_0;
    fwhm_1(i) = fwhm_phased_dnp;
    fwhm_bs(i) = fwhm_dnp_baselined;
    summed_efactor(i) = enhancementFactor;
    fwhm_area_efactor(i) = enhancementFactor_1;
    fixed_fwhm_area_efactor(i) = enhancementFactor_2;
    [max_val_bs(i), max_val_bs_ind(i)] = max(dnp_spec_scaled);
    dnp_width(i) = width;
    max_val_raw(i) = signal_raw;
    max_val_bs(i) = signal_bs;
    max_val_ph0(i) = signal_phase0;
    max_val_ph1(i) = signal_phase1;
    
    
end
    load 'C:\Users\Arthur Lin\Documents\Pines Lab\MATLAB\sweep time areas.mat'
    yarea = fliplr(yarea);
    xaxis = 50:-1:1;
    ratios = summed_efactor./yarea;
    ratios2 = fixed_fwhm_area_efactor./yarea;
    figure(10); hold on;
    scaled_enh = mean(ratios)*yarea; 
    scaled_enh2 = mean(ratios2)*yarea; 
    [f,xvec,fitted_contrast]= fit_Sweeptime(1./xaxis, scaled_enh, 1./xaxis);
    highstd = mean(ratios2) + (std(ratios2)*2);
    lowstd = mean(ratios2) - (std(ratios2)*2);
    std_above = highstd*yarea;
    std_below=lowstd*yarea;
    figure(15)
    hold on
    plot(xaxis, scaled_enh, xaxis,std_above, xaxis,std_below, xaxis,max(ratios)*yarea,xaxis, min(ratios)*yarea)
end

function [f,xvec,fitted_contrast]= fit_Sweeptime(x,y,xaxis)
lb=[0,0, -10];
ub=[2000,2000, 10];

[v b1]=max(abs(y));
x1=x;y1=y;
a_ini=3185;
b_ini=17;
c_ini = 0;
P_ini=[a_ini;b_ini;c_ini]; %NOTE that they have to be ordered alphabetically!

f = ezfit(x1, y1, 'y =a*x*exp(-b*x)+c*x.^-0.3',P_ini,lb,ub);

xvec=linspace(xaxis(1),xaxis(end),1000);    
fitted_contrast=f.m(1).*xvec.*exp(-f.m(2)*xvec)+f.m(3)*xvec.^-0.3;

end