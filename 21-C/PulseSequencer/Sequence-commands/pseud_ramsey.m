function result_seq = pseud_ramsey(seq,sample_rate,length_pi_over_2,tau,ch_on)

seq = ttl_pulse(seq, 2, length_pi_over_2);
seq = wait(seq, tau/2);
seq = ttl_pulse(seq, 2, 4*length_pi_over_2);
seq = wait(seq, tau/2);
seq = ttl_pulse(seq, 2, length_pi_over_2);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod ones(1,int64(sample_rate*(length_pi_over_2)))  zeros(1,int64(sample_rate*(tau/2))) ones(1,int64(sample_rate*(4*length_pi_over_2))) zeros(1,int64(sample_rate*(tau/2)))  ones(1,int64(sample_rate*(length_pi_over_2)))];
%debatable whether I should keep these ones for the whole sequence or put
%zeros in between pulses
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(6*length_pi_over_2+tau)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(6*length_pi_over_2+tau)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(6*length_pi_over_2+tau)))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(6*length_pi_over_2+tau)))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(6*length_pi_over_2+tau)))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(6*length_pi_over_2+tau)))];
end

if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(6*length_pi_over_2+tau)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(6*length_pi_over_2+tau)))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(6*length_pi_over_2+tau)))];
end

result_seq = seq;
