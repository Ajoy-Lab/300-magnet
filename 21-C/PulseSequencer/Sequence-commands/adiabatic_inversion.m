function result_seq = adiabatic_inversion(seq,sample_rate,sweep_range,sweep_time,freqIQ,ch_on)

%put mw pulse
seq = ttl_pulse(seq, 2, sweep_time);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(sweep_time)))];
t = (1/sample_rate/2):(1/sample_rate):sweep_time-(1/sample_rate/2);
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI chirp(t,-sweep_range/2+freqIQ,sweep_time,sweep_range/2+freqIQ,'linear',0)];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ chirp(t,-sweep_range/2+freqIQ,sweep_time,sweep_range/2+freqIQ,'linear',90)];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(sweep_time)))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(sweep_time)))];
end

if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(sweep_time)))];
end

result_seq = seq;
