function result_seq =mod_rf_pulse(seq,sample_rate,length_rf_pulse,rf_freq,mod,ch_on)

seq = ttl_pulse(seq,5, length_rf_pulse);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(length_rf_pulse)))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(length_rf_pulse)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(length_rf_pulse)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(length_rf_pulse)))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(length_rf_pulse)))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(length_rf_pulse)))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(length_rf_pulse)))];
end

if ch_on(5)
t = (1/sample_rate/2):(1/sample_rate):length_rf_pulse-(1/sample_rate/2);
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(length_rf_pulse)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI mod*sin(2*pi*t*rf_freq)];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(length_rf_pulse)))];
end

result_seq = seq;
