function result_seq =mod_rf_simul_pulse(seq,sample_rate,mod1,mod2,length_rf_pulse1,length_rf_pulse2,rf_freq1,rf_freq2,wait_time_after_rf,ch_on)

d=length_rf_pulse1-length_rf_pulse2; 
if d>=0;
seq = ttl_pulse(seq,5, length_rf_pulse1,0,0);
seq = ttl_pulse(seq,4, length_rf_pulse2);
seq = wait(seq,d);
else
seq = ttl_pulse(seq,5, length_rf_pulse2,0,0);
seq = ttl_pulse(seq,4, length_rf_pulse1);
seq = wait(seq,-d);
end
seq = wait(seq,wait_time_after_rf);

T=max(length_rf_pulse1,length_rf_pulse2)+wait_time_after_rf;

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*T))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*T))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*T))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*T))];

if ch_on(4)
t = (1/sample_rate/2):(1/sample_rate):length_rf_pulse1-(1/sample_rate/2);
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(T)))];
if d>=0;
seq.Channels(4).FreqmodI = [seq.Channels(5).FreqmodI mod1*sin(2*pi*t*rf_freq1) zeros(1,int64(sample_rate*wait_time_after_rf))];
else
seq.Channels(4).FreqmodI = [seq.Channels(5).FreqmodI mod1*sin(2*pi*t*rf_freq1) zeros(1,int64(sample_rate*(-d+wait_time_after_rf)))];
end
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(T)))];
end

if ch_on(5)
t = (1/sample_rate/2):(1/sample_rate):length_rf_pulse2-(1/sample_rate/2);
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(T)))];
if d>=0;
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI mod2*sin(2*pi*t*rf_freq2) zeros(1,int64(sample_rate*(d+wait_time_after_rf)))];
else
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI mod2*sin(2*pi*t*rf_freq2) zeros(1,int64(sample_rate*wait_time_after_rf))];
end
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(T)))];
end

result_seq = seq;
