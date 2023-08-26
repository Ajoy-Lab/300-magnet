function result_seq = set_rf(seq, new_freq, new_ampl)

rf_channel_no = 4;

% it's a ttl pulsed channel
seq.Channels(rf_channel_no).Frequency = new_freq;
seq.Channels(rf_channel_no).Amplitude = new_ampl;

result_seq = seq;




