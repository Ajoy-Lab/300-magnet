function  [spectra,mean_snr]=process_varian_muller(fn,avg_num)
 filename=['Z:\FID_spectra\' fn '\' avg_num '.fid'];
 [par,b,c1,d] = fidread(filename); 
%Diamond samples have extremely short T2 times, so if a long acquistion
%time was used in the data collection, make sure to apply a weighting
%function to the FID. You can do this by setting lb to something high. If
%you want to turn off the weighting, set lb to 0. 
lb = 128;
times=  1:1:size(c1,1);
%This creates an array of weights to be multiplied into the FID. 
weight = exp(-times*(1/lb));
c1w = c1.*weight';
fid = squeeze(c1w);

%The Fourier transform of the weighted FID is taken here
spectra = fft(fid);
spectra = fftshift(spectra);    %FT FID file
%Multiple integration ranges can be used. The best one will depend on the
%linewidth of your sample
intRange=1:1:10;
%This part finds the maximum value of the spectrum and its indices. The
%maximum value is assumed to be the peak you are looking for. 
[C,I] = max(abs(spectra(:,1)));
for i = 1:size(intRange,2)
    sfid(i)=sum(spectra((I-intRange(i)):(I+intRange(i))));    %Taking integral of peak
    noise(i) = sum(spectra(1:2*intRange(i)+1)); %This part integrates over an interval without a signal
    %Note, the noise calculation assumes that the sweep width of the
    %spectrum is much greater than the interval used. This calculation also
    %assumes that the peak is in the middle of the spectrum
    noise_mag(i) = abs(noise(i));
    magnitude(i) = abs(sfid(i));
    snr(i)  = magnitude(i)/noise_mag(i);
end
mean_snr=mean(snr);
%This plots the spectrum. Taking a look at the spectrum is a good way to
%check if you've applied enough weighting
%plot(abs(spectra));
end
            