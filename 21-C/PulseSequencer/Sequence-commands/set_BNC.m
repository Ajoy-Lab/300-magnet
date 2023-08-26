function result_seq = set_BNC(seq, new_freq, new_ampl,new_phase)

rf_channel_no = 6;

% it's a ttl pulsed channel. 
%use frequency as a dummy for pulse length.
%seq.Channels(rf_channel_no).Frequency = new_length;
seq.Channels(rf_channel_no).Amplitude = new_ampl;
seq.Channels(rf_channel_no).Phase = new_phase;

result_seq = seq;




