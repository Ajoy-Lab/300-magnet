function result_seq = ramsey(seq,sample_rate,length_pi_over_2,tau,wait_time,ch_on)

seq = ttl_pulse(seq, 2, wait_time+length_pi_over_2);
seq = wait(seq, tau);
seq = ttl_pulse(seq, 2, wait_time+length_pi_over_2);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(wait_time))) ones(1,int64(sample_rate*(length_pi_over_2)))  zeros(1,int64(sample_rate*(tau+wait_time)))  ones(1,int64(sample_rate*(length_pi_over_2)))];
%debatable whether I should keep these ones for the whole sequence or put
%zeros in between pulses
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(2*length_pi_over_2+tau+2*wait_time)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(2*length_pi_over_2+tau+2*wait_time)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(2*length_pi_over_2+tau+2*wait_time)))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(2*length_pi_over_2+tau+2*wait_time)))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(2*length_pi_over_2+tau+2*wait_time)))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(2*length_pi_over_2+tau+2*wait_time)))];
end

if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(2*length_pi_over_2+tau+2*wait_time)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(2*length_pi_over_2+tau+2*wait_time)))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(2*length_pi_over_2+tau+2*wait_time)))];
end

result_seq = seq;
