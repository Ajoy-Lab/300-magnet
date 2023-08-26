function noise_Ampmod = gaussian_static_noise(seq,sample_rate,total_pulse_length,correlation_time,st_dev,mean)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

N=floor(total_pulse_length/correlation_time);
m=total_pulse_length-N*correlation_time;

Amp=[];
if N>0;
for i=1:1:N
Amp=[Amp random('Normal',mean,st_dev)*ones(1,sample_rate*(correlation_time))];
end
Amp=[Amp random('Normal',mean,st_dev)*ones(1,sample_rate*m)];
end

if N==0;
   Amp=random('Normal',mean,st_dev)*ones(1,sample_rate*m);
end
    

noise_Ampmod=[seq.Channels(2).Ampmod Amp];



