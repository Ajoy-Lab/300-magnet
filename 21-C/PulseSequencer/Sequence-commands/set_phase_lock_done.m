function result_seq = set_phase_lock_done(seq, new_freq, new_ampl,new_phase)

rf_channel_no = 4;

% it's a ttl pulsed channel
%seq.Channels(rf_channel_no).Frequency = new_freq;
seq.Channels(rf_channel_no).Amplitude = new_ampl;
seq.Channels(rf_channel_no).Phase = new_phase;

result_seq = seq;




