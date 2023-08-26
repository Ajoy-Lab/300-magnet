function result_seq = ramsey_with_phase(seq,sample_rate,length_pi_over_2,phase,ch_on)

seq = ttl_pulse(seq, 2, 2*length_pi_over_2);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod ones(1,int64(sample_rate*(2*length_pi_over_2)))];
%debatable whether I should keep these ones for the whole sequence or put
%zeros in between pulses
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(2*length_pi_over_2)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(2*length_pi_over_2)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*length_pi_over_2)) phase*ones(1,int64(sample_rate*length_pi_over_2))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(2*length_pi_over_2)))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(2*length_pi_over_2)))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(2*length_pi_over_2)))];
end

if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(2*length_pi_over_2)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(2*length_pi_over_2)))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(2*length_pi_over_2)))];
end

result_seq = seq;
