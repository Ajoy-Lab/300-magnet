%% Initiate Read

clc
clear all

fname2000 = 'F:\FID_spectra\2017-06-15_22.36.16_carbon_ext_trig_shuttle\complete.fid\fid'
%fname = '/Users/raffinazaryan/Desktop/FID/2017-06-22_18.21.19_carbon_ext_trig_shuttle/10.fid/fid'
fname = 'F:\FID_spectra\2017-06-16_07.10.58_carbon_ext_trig_shuttle\complete.fid\fid';


%data=readcomplex2(fname,1);
[data, SizeTD2, SizeTD1] = Qfidread(fname, 17000 ,1, 5, 1);
 
%% Real and Imaginary

plot(data); % Real and Imaginary
plot(real(data)); % Real

%% Real and Imaginary Beginning

plot(real(data(1:128)),'k');
oplot(imag(data(1:128)),'r');


%% Apodization

dataSize = length(data);

%f=apod('gauss',dataSize,1,10^4)
%f=apod('gauss',dataSize,dataSize/2,dataSize/4)
f=apod('gauss',dataSize,0,10^2);
plot(real(data),'k');

oplot(f*gmax(real(data)),'--r','LineWidth',2);

%% Apply Filter function

odata=data; % Save old data
data=odata.*f; % Apply Filter function
plot(real(data),'k');

%spec=nmrft(readcomplex2(fname),2^17);

spec=nmrft(odata.*f,2^16,f);
plot(real(spec),'k')
oplot(imag(spec),'r')
PZphasetool(spec)

% Center Signal (OPTIONAL)
%plot(real(spec(2e4:3e4)),'k')
%oplot(imag(data(1:128)),'r')



%% Peak-picking (OPTIONAL)
% peaks=peakpick(rspec,30,0.1*max(spec))
% rspec(peaks)
% plot(rspec,'k')
% oplot(peaks,rspec(peaks),'ro')

%% Peak-tool (Gaussian Fit) (OPTIONAL)

% peaktool(spec);


