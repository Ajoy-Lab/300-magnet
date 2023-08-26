function result_seq = set_rigol(seq, new_freq, new_ampl, new_offset)

rf_channel_no = 9;

% it's a ttl pulsed channel
seq.Channels(rf_channel_no).Frequency = new_freq;
seq.Channels(rf_channel_no).Amplitude = new_ampl;
seq.Channels(rf_channel_no).Phase = new_offset;

seq.Channels(8).Amplitude =0;
result_seq = seq;




