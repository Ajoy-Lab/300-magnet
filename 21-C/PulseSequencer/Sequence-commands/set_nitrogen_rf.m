function result_seq = set_nitrogen_rf(seq, N_freq, N_ampl)

n_channel_no = 5;

% it's a ttl pulsed channel
seq.Channels(n_channel_no).Frequency = N_freq;
seq.Channels(n_channel_no).Amplitude = N_ampl;

result_seq = seq;
