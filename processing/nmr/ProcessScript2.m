%% Save phasing (Exit to save phase values) and Integrate

spec = phase(spec,phase_values);
phase_values2 = [1.301411880000000e+03,-0.3060,24969];
%phase_values = [45,-0.2876,26101]


fname2 = 'F:\FID_spectra\2017-06-22_18.21.19_carbon_ext_trig_shuttle\complete.fid\fid'

%data=readcomplex2(fname,1);

[data2, SizeTD2, SizeTD1] = Qfidread(fname2, 17000 ,1, 5, 1);
%MatrixOut1 = matNMRApodize1D(y, 4, 75,75, 6.25);
odata2=data2;
dataSize2 = length(data2);
f2=apod('gauss',dataSize2,0,10^2);

spec2=nmrft(odata2.*f2,2^14,f);

%PZphasetool(spec2)


spec2=phase(spec2,phase_values2);
plot(real(spec2),'b');

% Un-scaled plot
figure(1)
hold on;

rspec2=abs(spec2);
int2=integrate(rspec2);
plot(rspec2,'b');
plot(int2*10,'r', 'LineWidth',2);

rspec=abs(spec);
int=integrate(rspec);
plot(rspec,'k');
plot(int*10,'g', 'LineWidth',2);


%% Account for Scaling

%First portion
mean1 = mean(rspec(4e4:6e4))
mean2 = mean(rspec2(4e4:6e4))
std1 = std(rspec(4e4:6e4))
std2 = std(rspec2(4e4:6e4))

scale1 = sqrt(mean(rspec(4e4:6e4).^2))
scale2 = sqrt(mean(rspec2(4e4:6e4).^2))
scaleFactorPortion1 = scale1/scale2

%Second portion
scale1 = sqrt(mean(rspec(1:1.5e4).^2))
scale2 = sqrt(mean(rspec2(1:1.5e4).^2))
scaleFactorPortion2 = scale1/scale2

averageScaleFactor = mean([scaleFactorPortion1 scaleFactorPortion2])

%Scaled plot
figure(2)
hold on;

rspecScaled=real(spec)/averageScaleFactor;
int=integrate(rspecScaled);
plot(rspecScaled,'k');
plot(int*10,'g', 'LineWidth',2);

rspec2Scaled=real(spec2);
int2=integrate(rspec2Scaled);
plot(rspec2Scaled,'b');
plot(int2*10,'r', 'LineWidth',2);

scale1 = sqrt(mean(rspecScaled(4e4:6e4).^2))
scale2 = sqrt(mean(rspec2Scaled(4e4:6e4).^2))

enhancementFactor = (int(end)*sqrt(120))/(int2(end)*sqrt(15))

text(1e4, max(rspecScaled/2),['$\varepsilon $= ' num2str(enhancementFactor,'%.0f')], 'FontSize', 16,'interpreter','latex')
ylabel('Signal [a.u.]');
box on;

function area = fwhm_area(data)
    
end
