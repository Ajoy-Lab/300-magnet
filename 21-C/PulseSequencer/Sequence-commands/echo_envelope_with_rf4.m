function result_seq = echo_envelope_with_rf4(seq,sample_rate,length_rf_pulse,wait_time_before_rf,wait_time_after_rf,mod,rf_freq,length_pi_over_2,s_pulse,mod_s_pulse,ch_on)

% relaxation time + rf_pulse + relaxation time
tau = (length_rf_pulse+wait_time_after_rf)/2;
T = length_rf_pulse+wait_time_after_rf+3*length_pi_over_2+s_pulse+2*wait_time_before_rf;

seq = ttl_pulse(seq,2,length_pi_over_2);
seq = wait(seq, wait_time_before_rf);
seq = ttl_pulse(seq,5,length_rf_pulse/2,0,0);
seq = wait(seq, tau);
seq = ttl_pulse(seq,2, 2*length_pi_over_2);
seq = wait(seq, wait_time_before_rf);
seq = ttl_pulse(seq,5,length_rf_pulse/2,0,0);
seq = wait(seq, tau);
seq = ttl_pulse(seq, 2, s_pulse);


seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau+wait_time_before_rf))) ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau+wait_time_before_rf))) mod_s_pulse*ones(1,int64(sample_rate*(s_pulse)))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*T))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(T)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(T)))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*T))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*T))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*T))];
end

if ch_on(5)
t = (1/sample_rate/2):(1/sample_rate):length_rf_pulse-(1/sample_rate/2);
n=int64(length(t)/2);
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*T))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(length_pi_over_2+wait_time_before_rf))) mod*sin(2*pi*t(1:n)*rf_freq) zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(2*sample_rate*length_pi_over_2+sample_rate*wait_time_before_rf)) mod*sin(2*pi*t(n+1:end)*rf_freq) zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(sample_rate*s_pulse))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
end

result_seq = seq;