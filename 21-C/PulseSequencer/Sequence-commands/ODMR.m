function result_seq = ODMR(seq,length_ODMR,sample_rate,ch_on)

seq = ttl_pulse(seq, 1, length_ODMR,0,false);
seq = ttl_pulse(seq, 2, length_ODMR,0,false);
seq = ttl_pulse(seq, 3, length_ODMR);    

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod ones(1,int64(sample_rate*length_ODMR))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*length_ODMR))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*length_ODMR))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*length_ODMR))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*length_ODMR))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*length_ODMR))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*length_ODMR))];
end

if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*length_ODMR))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*length_ODMR))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*length_ODMR))];
end


result_seq = seq;
