function result_seq = partial_adiabatic_inversion(seq,sample_rate,sweep_range,sweep_time,freqIQ,init_freq,ch_on)

%The passage is NOT symmetric around the resonant frequency;
%init_freq is the distance from the resonance. Positive init_freqs give
%passages that start at a frequency init_freq below resonance

%put mw pulse
seq = ttl_pulse(seq, 2, sweep_time);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(sweep_time)))];
t = (1/sample_rate/2):(1/sample_rate):sweep_time-(1/sample_rate/2);
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI chirp(t,-init_freq+freqIQ,sweep_time,-init_freq+sweep_range+freqIQ,'linear',0)];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ chirp(t,-init_freq+freqIQ,sweep_time,-init_freq+sweep_range+freqIQ,'linear',90)];
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
