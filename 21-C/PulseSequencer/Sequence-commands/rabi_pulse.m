function result_seq = rabi_pulse(seq,sample_rate,length_rabi_pulse)

seq = ttl_pulse(seq, 2, length_rabi_pulse);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod ones(1,int64(sample_rate*length_rabi_pulse))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*length_rabi_pulse))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*length_rabi_pulse))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*length_rabi_pulse))];

result_seq = seq;