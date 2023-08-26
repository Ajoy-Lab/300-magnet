function result_seq = echo_envelope_with_rf(seq,sample_rate,length_rf_pulse,wait_time_after_rf,mod,rf_freq,length_pi_over_2,s_pulse,mod_s_pulse,ch_on)

seq = ttl_pulse(seq,5, length_rf_pulse,0,0);

tau = (length_rf_pulse+wait_time_after_rf-3*length_pi_over_2- s_pulse)/2;
T = length_rf_pulse+wait_time_after_rf;
seq = ttl_pulse(seq, 2, length_pi_over_2);
seq = wait(seq, tau);
seq = ttl_pulse(seq,2, 2*length_pi_over_2);
seq = wait(seq,tau);
seq = ttl_pulse(seq, 2, s_pulse);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau))) ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau))) mod_s_pulse*ones(1,int64(sample_rate*(s_pulse)))];
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
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*T))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI mod*sin(2*pi*t*rf_freq) zeros(1,int64(sample_rate*(wait_time_after_rf)))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
end

result_seq = seq;
