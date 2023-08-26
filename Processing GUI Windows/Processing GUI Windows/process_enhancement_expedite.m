function [enhancementFactor, enhancementFactor_1, enhancementFactor_2,...
    therm_spec_scaled, dnp_spec_scaled, ...
    fwhm_dnp_0, fwhm_phased_dnp,fwhm_dnp_baselined, width, ...
    signal_bs, signal_raw, signal_phase0, signal_phase1,...
    area_summed_dnp,area_summed_dnp_1,area_summed_dnp_2,area_trapz_dnp,area_trapz_dnp2,muller_area, area_fwhm_dnp,area_fixed_fwhm_dnp,ph0_val_dnp] = process_enhancement_expedite(dnp_spec,num_avg)
w = warning ('off','all');
%% USE process_enhancement_expedite if you have a processed thermal mat file saved.

[MatrixOut,snr ]=process_varian_muller(dnp_spec);
norm_data = abs(MatrixOut );
freq =linspace(0,6.25e3,size(norm_data ,1));

[peak ,b]=  max(norm_data );

[left_lim,right_lim] = peak_limits(norm_data, 0.8);

lw_min= freq (b)-0.75e3;lw_max= freq (b)+0.75e3;
IX=find(freq >lw_min& freq <lw_max);
% muller_area = trapz(freq (IX),norm_data (IX)',2);
muller_area = trapz(freq (left_lim:right_lim),norm_data (left_lim:right_lim)',2);
    
[data3, SizeTD2, SizeTD1] = Qfidread(dnp_spec, 17000 ,1, 5, 1);


odata3=data3;
dataSize3 = length(data3);
f3=apod('exp',dataSize3,0,128);  %retrieve data3 and apodize

spec_dnp=nmrft(odata3.*f3,2^14,'f');

% [spec_therm_0, ph0_val_therm] = phase0(spec_therm); %PHASE 0
[spec_dnp_0, ph0_val_dnp] = phase0(spec_dnp); %PHASE 0

% phased_spec_therm = phase1(spec_therm_0,  spec_therm, ph0_val_therm); %PHASE 1
% phased_spec_dnp = phase1(spec_dnp_0,  spec_dnp, ph0_val_dnp); %PHASE 1
phased_spec_dnp = spec_dnp_0;


%Change your directory to match the loaded mat file.
load 'C:\Users\Grace\Documents\Pines Lab 2017\Processing GUI Windows\Thermal Data\2017-07-29_20.57.39 thermal invert baseline_4.mat\'
bs_spec_dnp = baseline_4(real(phased_spec_dnp));
area_trapz_dnp2 = trapz(1:numel(spec_dnp),abs(spec_dnp),2);

%figure 3 plots fwhm spread after phase 0.
%figure 4 plots fwhm spread after phase 1.
%figure 5 plots fwhm spread after baselining.

fwhm_ind_dnp_0 = find(real(spec_dnp_0)>=max(real(spec_dnp_0))/2);
fwhm_dnp_0 = fwhm_ind_dnp_0(end)-fwhm_ind_dnp_0(1);

fwhm_ind_phased_dnp = find(real(phased_spec_dnp)>=max(real(phased_spec_dnp))/2);
fwhm_phased_dnp = fwhm_ind_phased_dnp(end)-fwhm_ind_phased_dnp(1);

fwhm_ind_dnp_baselined = find(real(bs_spec_dnp)>=max(real(bs_spec_dnp))/2);
fwhm_dnp_baselined = fwhm_ind_dnp_baselined(end)-fwhm_ind_dnp_baselined(1);



%fig 1 plots baselined spec. fig 2 plots scaled baselined specs and
%peaklims
% figure(1)
% plot(1:numel(bs_spec_therm), bs_spec_therm, 1:numel(bs_spec_dnp), bs_spec_dnp)
% figure(2)
% clf
% hold on
[scale_factor] =  calc_noise(bs_spec_therm, bs_spec_dnp);
therm_spec_scaled = bs_spec_therm;
dnp_spec_scaled = bs_spec_dnp*scale_factor;
% plot((1:numel(bs_spec_therm))/10e2, bs_spec_therm, (1:numel(bs_spec_dnp))/10e2, bs_spec_dnp*scale_factor, 'b')
[left_lim_therm, right_lim_therm] = peak_limits(bs_spec_therm, 0.8);
[left_lim_dnp, right_lim_dnp] = peak_limits(bs_spec_dnp, 0.9);
% plot(left_lim_therm*ones(1, 100)/10e2, linspace(-10000, 70000, 100), 'r--')
% plot(right_lim_therm*ones(1, 100)/10e2, linspace(-10000, 70000, 100), 'r--')
% plot(right_lim_dnp*ones(1, 100)/10e2, linspace(-10000, 70000, 100), 'b--')
% plot(left_lim_dnp*ones(1, 100)/10e2, linspace(-10000, 70000, 100), 'b--')

width = right_lim_dnp-left_lim_dnp;

area_summed_dnp = sum(dnp_spec_scaled(left_lim_dnp:right_lim_dnp));
area_summed_dnp_1 = sum(dnp_spec_scaled);
area_summed_dnp_2 =sum(abs(dnp_spec_scaled));
area_trapz_dnp = trapz(1:numel(dnp_spec_scaled), abs(dnp_spec_scaled), 2);
area_fwhm_dnp = fwhm_area(dnp_spec_scaled, left_lim_dnp, right_lim_dnp);
area_fixed_fwhm_dnp = fixed_fwhm_area(therm_spec_scaled, 1162, left_lim_therm, right_lim_therm);

%enhancement factor outputs.
enhancementFactor = sqrt(120/num_avg)* sum(dnp_spec_scaled(left_lim_dnp:right_lim_dnp))/...
    sum(therm_spec_scaled(left_lim_therm:right_lim_therm));

enhancementFactor_1 = sqrt(120/num_avg)*area_fwhm_dnp/area_fixed_fwhm_dnp;
 
enhancementFactor_2 = sqrt(120/num_avg)*fixed_fwhm_area(dnp_spec_scaled, 1162,left_lim_dnp,...
    right_lim_dnp)/area_fixed_fwhm_dnp;

%peak height outputs.
signal_bs = max(real(bs_spec_dnp));
signal_raw = max(real(spec_dnp));
signal_phase0 = max(real(spec_dnp_0));
signal_phase1 = max(real(phased_spec_dnp));


end

function [phased_spec, ph_val] = phase0(spec)
%% phase0 = frequency independent scaling

ph0 = linspace(-pi, pi, 360);
[maxval, pivot] = max(abs(real(spec)));
maxval2=real(spec(pivot));
x = 1:size(spec, 2)-pivot;
phased_spec = complex(cos(-pi), -sin(-pi)).*spec;
ph_val = -pi;
for j = 1:size(ph0, 2)
    phi = ph0(j);
    phas_vector = complex(cos(phi), -sin(phi));
   
    if max(real(phas_vector*spec)) >= max(real(phased_spec))
        phased_spec = phas_vector*spec;
        ph_val = ph0(j);
    end    
  
end

end

function [spec_1,ph2_val,x] = phase1(spec_0,  spec, ph0_val)
%% Phase1 = frequency dependent phasing. 
%% phi is a sum of ph0+ph1*freq. We wanna find ph1_val that averages noise to zero
%% i.e has minimum absolute noise.

%also uses a new function called peak limits, which finds the limits of the peak.
[left_lim, right_lim] = peak_limits(spec_0, 0.9);
ph1=linspace(-2,2,400);
[b,pivot]=max(abs(spec_0));
left_lim = left_lim-pivot; right_lim = right_lim-pivot;
x=linspace(1,size(spec_0,2),size(spec_0,2))-pivot;
phi=ph0_val+ph1(1)*x/1000;
phas_vector=complex(cos(phi),-sin(phi));
spec_1=spec.*phas_vector;

for j=1:size(ph1,2)
    phi=ph0_val+ph1(j)*x/1000;
    phas_vector=complex(cos(phi),-sin(phi));
    test_spec_1=spec.*phas_vector;
    if (sum(abs(real([test_spec_1(1:left_lim) test_spec_1(right_lim:end)]))))<...
           sum(abs(real([spec_1(1:left_lim) spec_1(right_lim:end)])))
       spec_1 = test_spec_1;
       ph2_val = ph1(j);

    end

end
end


function [baselined_spec] = baseline(spec)
    baselined_spec=spec;
    [left_lim, right_lim] = peak_limits(spec);
    bs_coeff_left = polyfit(1:left_lim, real(spec(1:left_lim)), 12);
    bs_coeff_right = polyfit(right_lim:size(spec, 2), real(spec(right_lim:end)), 12);
    left_bs_val = polyval(bs_coeff_left, 1:numel(spec(1:left_lim)));
    right_bs_val = polyval(bs_coeff_right, right_lim:numel(spec));
    baselined_spec(1:left_lim) = baselined_spec(1:left_lim)-left_bs_val;
    baselined_spec(right_lim:end) = baselined_spec(right_lim:end)-right_bs_val;
    
    
end

function [baselined_spec] = baseline_1(spec)
    baselined_spec=spec;
    [left_lim, right_lim] = peak_limits(spec);
    baselined_spec = [spec(1:left_lim), zeros(1, right_lim-left_lim), spec(right_lim:end)];
    bs_coeff = polyfit(1:numel(baselined_spec), real(baselined_spec), 12);
    bs_val = polyval(bs_coeff, 1:numel(spec));
    baselined_spec = spec-bs_val;
    
end

function [baselined_spec] = baseline_2(spec)
    [z,a,it,ord,s,fct]=backcor(1:numel(spec),real(spec), 12, 0.01, 'atq');
    baselined_spec = real(spec)-z';
end

function [baselined_spec] = baseline_3(spec)
    [left_lim, right_lim] = peak_limits(spec);

    baselined_spec = matNMRBaselineCorrection1D(real(spec), 1:numel(spec), [1, left_lim, right_lim, numel(spec)], 1, 12, 0);
end

function [baselined_spec] = baseline_4(spec)
    [left_lim, right_lim] = peak_limits(spec, 0.9);
    bs_coeff = polyfit([1:left_lim, right_lim:size(spec, 2)], [real(spec(1:left_lim)), real(spec(right_lim:end))], 12);
    bs_val = polyval(bs_coeff, 1:numel(spec));
    baselined_spec=spec-bs_val;
end

function [scale_factor] =  calc_noise(bs_spec_therm, bs_spec_dnp)
%% calculates the scale factor to scale the dnp to match the noise.
    [left_lim_therm, right_lim_therm] = peak_limits(bs_spec_therm, 0.8);
    [left_lim_dnp, right_lim_dnp] = peak_limits(bs_spec_dnp, 0.9);
    std_left_therm = std(bs_spec_therm(1:left_lim_therm));
    std_right_therm = std(bs_spec_therm(right_lim_therm:end));
    std_left_dnp = std(bs_spec_dnp(1:left_lim_dnp));
    std_right_dnp = std(bs_spec_dnp(right_lim_dnp:end));
    mean_std_therm = mean([std_left_therm, std_right_therm]);
    mean_std_dnp = mean([std_left_dnp, std_right_dnp]);
    scale_factor = mean_std_therm/mean_std_dnp;
    
end

function [left_lim, right_lim] = peak_limits(spec, thresh)
    %% Fits a lorentzian through the curve based on fwhm and peak height
    %% and finds points to the left and right of peak up until it reaches a
    %% area threshold.
    [maxval, x0] = max(real(spec));
    fwhm = find_fwhm(real(spec)); 
    I = maxval/(2/fwhm);
    fitted_points = (0.5*fwhm)./(((1:numel(spec))-x0).^2 + (0.5*fwhm)^2);    
    area = (atan((numel(spec)-x0)/(0.5*fwhm))*I/fwhm)-(atan((-x0)/(0.5*fwhm))*I/fwhm);
    x = 0.5*fwhm*tan(fwhm*0.5*(thresh*area)/I);
    left_lim = ceil(x0-x);
    right_lim = ceil(x0+x);

    

    
end

function area = fwhm_area(spec, left_lim, right_lim)
    %% integrates from left_lim to right_lim, using a fitted lorentzian.
    [maxval, x0] = max(real(spec));
    fwhm_ind = find(real(spec)>=max(real(spec))/2);
    fwhm = fwhm_ind(end)-fwhm_ind(1);
    I = maxval/(2/fwhm);
    area = (atan((right_lim-x0)/(0.5*fwhm))*I/fwhm)-(atan((left_lim-x0)/(0.5*fwhm))*I/fwhm);
end

function area = fixed_fwhm_area(spec, fwhm, left_lim, right_lim)
    %% integrates using a mean fwhm (Hardcoded)
    [maxval, x0] = max(real(spec));
    I = maxval/(2/fwhm);
    area = (atan((right_lim-x0)/(0.5*fwhm))*I/fwhm)-(atan((left_lim-x0)/(0.5*fwhm))*I/fwhm);

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

function  [f,xvec,fitted_contrast]=make_fit_Lorentzian(x,spec20)
[maxval,pivot]=max(abs(spec20));
y=spec20/maxval;
xaxis=x;
 [f,xvec,fitted_contrast]= fit_Lorentzian(x,y,xaxis);
 fitted_contrast=fitted_contrast*maxval;
end

function fwhm = find_fwhm(spec)
    %% outputs the fwhm of a peak.
    [maxval,peak]=max(spec);
    left_midpoints=find(spec(1:peak)<=maxval/2);
    right_midpoints=find(spec(peak:end)<=maxval/2);
    left_ind=left_midpoints(end);
    right_ind=right_midpoints(1)+peak;
    fwhm = right_ind-left_ind;
end