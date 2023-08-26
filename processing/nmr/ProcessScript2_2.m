function process_data(thermal,dnp)
%% Save phasing (Exit to save phase values) and Integrate

% phase_values2 = [1.301411880000000e+03,-0.3060,24969];
%phase_values = [45,-0.2876,26101]



fname2 = 'F:\FID_spectra\2017-06-22_18.21.19_carbon_ext_trig_shuttle\complete.fid\fid' %thermal
%fname2 = 'F:\FID_spectra\2017-06-14_22.44.19_carbon_ext_trig_shuttle\complete.fid\fid' %thermal old
fname3 = 'F:\FID_spectra\2017-06-16_07.10.58_carbon_ext_trig_shuttle\complete.fid\fid' %15shot
%fname3 = 'F:\FID_spectra\2017-06-15_22.36.16_carbon_ext_trig_shuttle\complete.fid\fid' %15shot
%fname3 = 'F:\FID_spectra\2017-06-17_14.22.12_carbon_ext_trig_shuttle\complete.fid\fid' %15shot

%data=readcomplex2(fname,1);

[data2, SizeTD2, SizeTD1] = Qfidread(fname2, 17000 ,1, 5, 1);
[data3, SizeTD2, SizeTD1] = Qfidread(fname3, 17000 ,1, 5, 1);

%MatrixOut1 = matNMRApodize1D(y, 4, 75,75, 6.25);
odata2=data2;
dataSize2 = length(data2);
f2=apod('lorentz',dataSize2,0,300);  %retrieve data2 and apodize

odata3=data3;
dataSize3 = length(data3);
f3=apod('lorentz',dataSize3,0,300);  %retrieve data3 and apodize

spec2=nmrft(odata2.*f2,2^14,'f');
spec3=nmrft(odata3.*f3,2^14,'f');

[spec20,pval,x2] = phase0(spec2); %PHASE 0
[spec20,pval,x2] = phase1(spec2,spec20,pval,2000); %PHASE 1
%figure(10);hold on;plot(x2,spec20,'b-')



[spec30,pval,x3] = phase0(spec3); %PHASE 0
[spec30,pval,x3] = phase1(spec3,spec30,pval,2000); %PHASE 1


[enhancementFactor,spec2Scaled,spec3Scaled,left_lim2,right_lim2,left_lim3,right_lim3] =calc_enhancement(spec20,spec30,x2,x3);

%Scaled plot
figure(2);clf;
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

function [area,fwhm_ind] = fwhm_area(data,x)
    [maxval,peak]=max(data);
    fwhm_ind=find(data>=maxval/2);
    fwhm=fwhm_ind(end)-fwhm_ind(1); %width in # points
    area=sum(real(data(peak-fwhm:peak+fwhm)));
  % area= pi/2*maxval*fwhm*(x(2)-x(1))/(x(end)-x(1));
   %area=sum(abs(data(fwhm_ind)));
  % area= pi/2*maxval*fwhm;
end

function [scaleFactorPortion,left_lim,right_lim] =  calc_noise(rspec2,x2)
[maxval2,peak2]=max(rspec2);
[area,fwhm_ind] = fwhm_area(rspec2,x2);
left_lim=peak2-6*(fwhm_ind(end)-fwhm_ind(1));
right_lim=peak2+6*(fwhm_ind(end)-fwhm_ind(1));

mean_left=mean(rspec2(1:left_lim));
std_left=std(rspec2(1:left_lim) - mean_left);
mean_right=mean(rspec2(right_lim:end));
std_right=std(rspec2(right_lim:end) - mean_right);
scaleFactorPortion = mean([std_left std_right]);
%scaleFactorPortion = mean([std_left]);
end

function [enhancementFactor,spec2Scaled,spec3Scaled,left_lim2,right_lim2,left_lim3,right_lim3] = calc_enhancement(spec20,spec30,x2,x3)
rspec2=real(spec20);
rspec3=real(spec30);
[scaleFactorPortion2,left_lim2,right_lim2]=calc_noise(rspec2,x2);
[scaleFactorPortion3,left_lim3,right_lim3]=calc_noise(rspec3,x3);

spec2Scaled=spec20/(1*scaleFactorPortion2);
spec3Scaled=spec30/scaleFactorPortion3;

enhancementFactor = sqrt(120/15)*fwhm_area(real(spec3Scaled),x3)/fwhm_area(real(spec2Scaled),x2)

end

