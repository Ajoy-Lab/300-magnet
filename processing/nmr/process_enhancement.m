function [enhancementFactor,fwhm3,spec2Scaled,spec3Scaled] = process_enhancement(spec2,spec3,num_avs)
%% Save phasing (Exit to save phase values) and Integrate

% phase_values2 = [1.301411880000000e+03,-0.3060,24969];
%phase_values = [45,-0.2876,26101]


% 
% fname2 = 'F:\FID_spectra\2017-06-22_18.21.19_carbon_ext_trig_shuttle\complete.fid\fid' %thermal
% %fname2 = 'F:\FID_spectra\2017-06-14_22.44.19_carbon_ext_trig_shuttle\complete.fid\fid' %thermal old
% fname3 = 'F:\FID_spectra\2017-07-04_13..27.44_carbon_ext_trig_shuttle\complete.fid\fid' %15shot
% %fname3 = 'F:\FID_spectra\2017-06-15_22.36.16_carbon_ext_trig_shuttle\complete.fid\fid' %15shot
% %fname3 = 'F:\FID_spectra\2017-06-17_14.22.12_carbon_ext_trig_shuttle\complete.fid\fid' %15shot



[spec20,pval,x2] = phase0(spec2); %PHASE 0
[spec20,pval,x2] = phase1(spec2,spec20,pval,2000); %PHASE 1
%figure(10);hold on;plot(x2,spec20,'b-')



[spec30,pval,x3] = phase0(spec3); %PHASE 0
 [spec30,pval,x3] = phase1(spec3,spec30,pval,2000); %PHASE 1
% [spec30,pval,x3] = phase0_symm(spec30); %PHASE 0 

[spec20,left_zero2,right_zero2] = baseline(spec20);
[spec30,left_zero3,right_zero3] = baseline(spec30);

[spec20,left_zero2,right_zero2] = baseline(spec20);
[spec30,left_zero3,right_zero3] = baseline(spec30);



[enhancementFactor,spec2Scaled,spec3Scaled,left_lim2,right_lim2,left_lim3,right_lim3,fwhm2,fwhm3] =calc_enhancement(spec20,spec30,x2,x3,num_avs);

%Scaled plot
figure(3); clf
hold on;
plot(x2,real(spec2Scaled),'r');
plot(x3,real(spec3Scaled),'b');
ax=linspace(0,70,100);
plot(ones(1,100)*x2(left_lim2),ax,'r--');
plot(ones(1,100)*x2(right_lim2),ax,'r--');

plot(ones(1,100)*x3(left_lim3),ax,'b--');
plot(ones(1,100)*x3(right_lim3),ax,'b--');


text(1e4, max(spec2Scaled/2),['$\varepsilon $= ' num2str(enhancementFactor,'%.0f')], 'FontSize', 16,'interpreter','latex')
ylabel('Signal [a.u.]');
box on;

export2base();
end



function [spec20,pval,x] = phase0(spec2)
[b,pivot]=max(abs(spec2));
x=linspace(1,size(spec2,2),size(spec2,2))-pivot;
ph0=[-180:1:180];pval=[0 0 pivot];
for j=1:size(ph0,2)
    pval(1)=ph0(j);pval(2)=0;
phi=pval(1)/180*pi+pval(2)*x/1000;
phas_vector=complex(cos(phi),-sin(phi));
spec20=spec2.*phas_vector;
F(j)=max(real(spec20));
end
[b,pval1_ind]=max(F);
pval(1)=ph0(pval1_ind);
phi=pval(1)/180*pi+pval(2)*x/1000;
phas_vector=complex(cos(phi),-sin(phi));
spec20=spec2.*phas_vector;

end

function [spec20,pval,x] = phase0_symm(spec2)
[b,pivot]=max(abs(spec2));
x=linspace(1,size(spec2,2),size(spec2,2))-pivot;
ph0=[-180:1:180];pval=[0 0 pivot];
for j=1:size(ph0,2)
    pval(1)=ph0(j);pval(2)=0;
phi=pval(1)/180*pi+pval(2)*x/1000;
phas_vector=complex(cos(phi),-sin(phi));
spec20=spec2.*phas_vector;
 F(j)=max(real(spec20))^2*min(abs(sum(real(spec20(1:pivot))) -sum(real(spec20(pivot:end))))) ;
%$F(j)=min(abs(sum(real(spec20(1:pivot-1000))) -sum(real(spec20(pivot+1000:end))))) ;

end
[b,pval1_ind]=max(F);
pval(1)=ph0(pval1_ind);
phi=pval(1)/180*pi+pval(2)*x/1000;
phas_vector=complex(cos(phi),-sin(phi));
spec20=spec2.*phas_vector;

end

function [spec20,pval,x] = phase1(spec2,spec20,pval,num_points)
ph1=linspace(-2,2,400);clear F;
[b,pivot]=max(abs(spec20));
x=linspace(1,size(spec20,2),size(spec20,2))-pivot;
[maxval,peak]=max(real(spec20));
for j=1:size(ph1,2)
   pval(2)=ph1(j);
phi=pval(1)/180*pi+pval(2)*x/1000;
phas_vector=complex(cos(phi),-sin(phi));
spec20=spec2.*phas_vector;
F(j)=(sum(abs(real([spec20(1:peak-num_points) spec20(peak+num_points:end)]))));
end
[b,pval1_ind]=min(F);
pval(2)=ph1(pval1_ind);
phi=pval(1)/180*pi+pval(2)*x/1000;
phas_vector=complex(cos(phi),-sin(phi));
spec20=spec2.*phas_vector;
end




function [area,fwhm_ind,fwhm, left_zero, right_zero] = fwhm_area(data)
    [maxval,peak]=max(data);
%     fwhm_ind_left=find(data(1:peak)==maxval/2); %width in # points
  %  fwhm_ind_right=find(data(peak:end)==maxval/2);
[~, left_zero, right_zero] = baseline(data);

freq=linspace(0,6.25e3,size(real(data),2));
[f,xvec,fitted_contrast]=make_fit_Lorentzian(freq,real(data));
[maxval,peak] = max(fitted_contrast);


    fwhm_ind=find(fitted_contrast>=maxval/2);
    fwhm=xvec(fwhm_ind(end))-xvec(fwhm_ind(1));
    fwhm=fwhm*62500/size(data,2);
%     area=integral(@(x) ((1/pi)*(0.5*fwhm))./((x-peak).^2+(0.5*fwhm).^2), -inf, inf)
    %sorted_fwhm_ind=sort(fwhm_ind);
%     [true_fwhm_ind,IX]=sort(abs(peak-fwhm_ind));
    %fwhm=fwhm_ind(end)-fwhm_inhm_ind(IX(1))); %width in # points
%      area=sum(real(data(peak-fwhm:peak+fwhm)));
%      area=sum(real(data(left_zero:right_zero)));

  % area= pi/2*maxval*fwhm*(x(2)-x(1))/(x(end)-x(1));
%    area=sum(abs(data(fwhm_ind)));
   area= pi/2*maxval*fwhm;
%    area = trapz(fitted_contrast);

%    area= pi/2*maxval;
end

function [scaleFactorPortion,left_lim,right_lim,fwhm] =  calc_noise(rspec,x2)
[maxval2,peak2]=max(rspec);
[area,fwhm_ind,fwhm, left_lim, right_lim] = fwhm_area(rspec);
% left_lim= 
% right_lim=peak2+6*(fwhm_ind(end)-fwhm_ind(1));

% left_int=left_lim/5;
% right_int=right_lim/5;
% for x=1:5
%     mean_left=mean(rspec2(round(left_int*(x-1))+1:floor(left_int*x)));
%     std_left(x)=std(rspec2(round(left_int*(x-1))+1:floor(left_int*x))-mean_left);
%     mean_right=mean(rspec2(round(right_int*(x-1))+1:floor(right_int*x)));
%     std_right(x)=std(rspec2(round(right_int*(x-1))+1:floor(right_int*x))-mean_right);
% end
% std_left=mean(std_left);
% std_right=mean(std_right);


mean_left=mean(rspec(1:left_lim));
std_left=std(rspec(1:left_lim) - mean_left);
mean_right=mean(rspec(right_lim:end));
std_right=std(rspec(right_lim:end) - mean_right);
scaleFactorPortion = mean([std_left std_right]);
%scaleFactorPortion = mean([std_left]);
end

function [enhancementFactor,spec2Scaled,spec3Scaled,left_lim2,right_lim2,left_lim3,right_lim3,fwhm2,fwhm3] = calc_enhancement(spec20,spec30,x2,x3,num_avs)
rspec2=real(spec20);
rspec3=real(spec30);
[scaleFactorPortion2,left_lim2,right_lim2,fwhm2]=calc_noise(rspec2,x2);
[scaleFactorPortion3,left_lim3,right_lim3,fwhm3]=calc_noise(rspec3,x3);

spec2Scaled=spec20/(scaleFactorPortion2);
spec3Scaled=spec30/scaleFactorPortion3;

% [scaleFactorPortion2test,left_lim2test,right_lim2tes,fwhm2test]=calc_noise(real(spec2Scaled),x2);
% [scaleFactorPortion3test,left_lim3test,right_lim3test,fwhm3test]=calc_noise(real(spec3Scaled),x3);

enhancementFactor = sqrt(120/num_avs)*fwhm_area(real(spec3Scaled))/fwhm_area(real(spec2Scaled));
% enhancementFactor = fwhm_area(real(spec3Scaled))/fwhm_area(real(spec2Scaled));

end

function [data,left_zero,right_zero] = baseline(data)
    [maxval,peak]=max(data);
    left_bs=find(data(1:peak)<=0);
    right_bs=find(data(peak:end)<=0);
    left_zero=left_bs(end);
    right_zero=right_bs(1)+peak;
    bsval = [1:left_bs(end),(right_bs(1)+peak):numel(data)];
%     bsval=1:numel(data);
    [p,S,mu]=polyfit(bsval,real(data(bsval)),12);
    baser=[zeros(1,min(bsval)-1) polyval(p,min(bsval):max(bsval),S,mu) zeros(1,length(data)-max(bsval))];
    [p,S,mu]=polyfit(bsval,imag(data(bsval)),12);
    basei=[zeros(1,min(bsval)-1) polyval(p,min(bsval):max(bsval),S,mu) zeros(1,length(data)-max(bsval))];
    bs_curve=complex(baser,basei);  
    data=data-bs_curve;
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
