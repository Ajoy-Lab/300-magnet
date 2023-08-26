function result_seq = polarize(seq,sample_rate)

%polarize and acquire ref
seq = ttl_pulse(seq, 1, 2e-6);
seq = wait(seq, 1.5e-6);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*2.5e-6))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*2.5e-6))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*2.5e-6))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*2.5e-6))];

result_seq = seq;
