function result_seq = awg_trigger_pulse(seq,sample_rate,length_rabi_pulse)

rf_channel_no = 7;

seq.Channels(rf_channel_no).Frequency = 1;
seq.Channels(rf_channel_no).Amplitude = 1;

result_seq = seq;