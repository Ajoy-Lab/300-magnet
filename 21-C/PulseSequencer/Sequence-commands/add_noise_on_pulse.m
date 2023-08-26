function result_seq = add_noise_on_pulse(seq,sample_rate,correlation_time,st_dev,mean,Aux)

L=length(seq.Channels(2).Ampmod);

pulse_length=L-Aux;
aux1=correlation_time*sample_rate;
N=floor(pulse_length/aux1);
m=pulse_length-N*aux1;

Amp=[];
if N>0;
    %if pulse_length==aux1;
     %   Amp=random('Normal',mean,st_dev)*ones(1,m);
    %end
%else
for i=1:N;
Amp=[Amp random('Normal',mean,st_dev)*ones(1,aux1)];
end
Amp=[Amp random('Normal',mean,st_dev)*ones(1,m)];
end


if N==0;
   Amp=random('Normal',mean,st_dev)*ones(1,m);
end

aux2=zeros(1,Aux);
noise_Ampmod=[aux2 Amp];

a=length(seq.Channels(2).Ampmod);
b=length(noise_Ampmod);

if a==b;
aux3 = seq.Channels(2).Ampmod+noise_Ampmod;
seq.Channels(2).Ampmod =  min(max(aux3,-1),1);

else
    return
end
result_seq = seq;

end

