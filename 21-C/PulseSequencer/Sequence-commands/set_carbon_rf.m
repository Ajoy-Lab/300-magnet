function result_seq = set_carbon_rf(seq, C_freq, C_ampl)

c_channel_no = 4;

% it's a ttl pulsed channel
seq.Channels(c_channel_no).Frequency = C_freq;
seq.Channels(c_channel_no).Amplitude = C_ampl;

result_seq = seq;
